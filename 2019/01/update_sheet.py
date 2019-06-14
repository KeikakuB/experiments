#!/usr/bin/env python3
from __future__ import print_function

import sys
import json
import logging
import argparse

import time
import dateutil.parser
from googleapiclient.discovery import build
from httplib2 import Http
from oauth2client import file, client, tools

from pyartifact import Cards
from pyartifact import encode_deck
from pyartifact import decode_deck_string

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# If modifying these scopes, delete the file TOKEN_FILE
SCOPES = 'https://www.googleapis.com/auth/spreadsheets'
TOKEN_FILE = 'token.json'
CREDENTIALS_FILE = 'credentials.json'
SECRET_FILE = 'secret.json'
SECRET_KEY_SHEET_ID = 'sheet_id'

SHEET_DRAFTS = "Drafts"
SHEET_SET_DATA= "SetData"
SHEET_DECKS_DATA= "DecksData"

KEY_NAME = "name"
KEY_ID = "id"
KEY_START_TIME = "start_time"
KEY_END_TIME = "end_time"
KEY_URL = "url"
KEY_DECK = "deck"
KEY_WINS = "wins"
KEY_LOSSES = "losses"

IMPORTANT_TIERS = set(["S", "A"])
IMPORTANT_REQUIRED_COUNTS = {
        'S': 1,
        'A': 2,
        'B': 3,
        'C': 4,
        'D': 5,
        'F': 7
    }
IMPORTANT_TYPES = set(["Hero", "Spell", "Creep", "Improvement"])
SPREADSHEET_ID = None

def get_formattted_time(t):
    return t.strftime("%b %d %Y %H:%M")

def is_draft_in_progress(draft):
    return draft[KEY_WINS] == 0 and draft[KEY_LOSSES] == 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", action='store_true', help="increase output verbosity")
    args = parser.parse_args()
    # create console handler with a higher log level
    # create formatter and add it to the handlers
    # TODO(keikakub) fix logging (when -v is on we should see everything)

    with open(SECRET_FILE) as f:
        data = json.load(f)
        # The ID and range of a sample spreadsheet.
        try:
            SPREADSHEET_ID = data[SECRET_KEY_SHEET_ID]
        except:
            pass

    if not SPREADSHEET_ID:
        logger.error("no spreadsheet found...")
        sys.exit(1)

    # Get connection
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    store = file.Storage(TOKEN_FILE)
    creds = store.get()
    if not creds or creds.invalid:
        flow = client.flow_from_clientsecrets(CREDENTIALS_FILE, SCOPES)
        creds = tools.run_flow(flow, store)
    service = build('sheets', 'v4', http=creds.authorize(Http()))

    # Read drafts data for decoding the deck URLs/codes and exposing hero/card data in the sheet
    logger.info("Reading drafts data...")
    sheet = service.spreadsheets()
    result = sheet.values().get(spreadsheetId=SPREADSHEET_ID, range="{}!A2:F".format(SHEET_DRAFTS)).execute()
    values = result.get('values', [])
    if not values:
        logger.error('No data found.')
        sys.exit(1)
    drafts = []
    i = 1
    for row in values:
        i = i + 1
        draft = {}
        if len(row) == 0:
            continue
        draft[KEY_ID] = int(row[0])
        draft[KEY_START_TIME] = dateutil.parser.parse(row[1]) if len(row) > 1 and row[1] else ""
        draft[KEY_URL] = row[3] if len(row) > 3 else  ""
        draft[KEY_WINS] = int(row[4]) if len(row) > 4 else 0
        draft[KEY_LOSSES] = int(row[5]) if len(row) > 5 else 0
        try:
            deck_code_index = draft[KEY_URL].find("ADC")
            deck_code = draft[KEY_URL][deck_code_index:]
            deck = decode_deck_string(deck_code)
            draft[KEY_DECK] = deck
        except:
            logger.error("Can't parse deck '{}' due to its invalid URL '{}'".format(draft[KEY_ID], draft[KEY_URL]))
            sys.exit(1)
        drafts.append(draft)
        draft[KEY_END_TIME] = dateutil.parser.parse(row[2]) if len(row) > 2 and row[2] else ""

    all_cards = Cards()
    all_cards.load_all_sets()

    cards_dict = {}
    for card in all_cards:
        cards_dict[card.id] = card


    logger.info("Reading cards tier data...")
    result = sheet.values().get(spreadsheetId=SPREADSHEET_ID, range="{}!A2:H".format(SHEET_SET_DATA)).execute()
    values = result.get('values', [])
    if not values:
        logger.error('No data found.')
        sys.exit(1)
    card_tiers_dict = {}
    for row in values:
        if len(row) > 4:
            try:
                card_tiers_dict[int(row[0])] = row[4]
            except:
                pass

    heroes = all_cards.filter.type('Hero')
    valid_cards = list(all_cards.filter.type('Hero'))
    valid_cards.extend(all_cards.filter.type('Creep'))
    valid_cards.extend(all_cards.filter.type('Spell'))
    valid_cards.extend(all_cards.filter.type('Improvement'))
    valid_cards.extend(all_cards.filter.type('Item'))

    logger.info("Writing cards set data using tier data in order to preserve it if new cards are added one day...")
    data = []
    i = 1
    valid_cards.sort(key=lambda x: x.id)
    for card in valid_cards:
        i = i + 1
        color = ""
        try:
            color = card.color
        except:
            pass
        data.append(
            {
                'range': "{}!A{}:E{}".format(SHEET_SET_DATA, i, i),
                'values': [
                    [card.id, card.type, card.name, color, card_tiers_dict.get(card.id, "")]
                ]
            }
        )
    body = {
        'valueInputOption': "USER_ENTERED",
        'data': data
    }

    result = service.spreadsheets().values().batchUpdate(spreadsheetId=SPREADSHEET_ID, body=body).execute()
    logger.info('{0} cells updated.'.format(result.get('updatedCells')))

    drafts.sort(key=lambda d: d[KEY_ID], reverse=True)

    logger.info("Writing drafts data such the heroes used, a text overview of the deck used based on tier data...")
    data = []
    i = 1
    for draft in drafts:
        values = []
        i = i + 1
        deck = draft[KEY_DECK]
        heroes = deck["heroes"].copy()
        heroes.sort(key=lambda x: x["turn"])
        values = list(sum([(cards_dict[h["id"]].name,cards_dict[h["id"]].color) for h in heroes], ()))
        important_cards = []
        cards_to_check = heroes.copy()
        cards_to_check.extend(deck["cards"])
        for card in cards_to_check:
            if card["id"] in card_tiers_dict:
                kind = cards_dict[card["id"]].type
                tier = card_tiers_dict[card["id"]]
                if kind in IMPORTANT_TYPES and tier in IMPORTANT_TIERS:
                    msg = None
                    if "count" not in card:
                        # This card is a hero.
                        msg = "- {}".format(cards_dict[card["id"]].name)
                    else:
                        if card["count"] >= IMPORTANT_REQUIRED_COUNTS[tier]:
                            # This card is not a hero.
                            msg = "- {} {}x".format(cards_dict[card["id"]].name, card["count"])
                    if msg:
                        important_cards.append((kind, tier, msg))
        important_cards.sort(key=sort_important_cards, reverse=True)
        important_cards_msg = [msg for (kind, tier, msg) in important_cards]
        values.append('\n'.join(important_cards_msg))
        results = []
        results.append(draft.get(KEY_ID, ""))
        start_time = ""
        if KEY_START_TIME in draft and draft[KEY_START_TIME]:
            start_time = get_formattted_time(draft[KEY_START_TIME])
        results.append(start_time)
        end_time = ""
        if KEY_END_TIME in draft and draft[KEY_END_TIME]:
            end_time = get_formattted_time(draft[KEY_END_TIME])
        results.append(end_time)
        results.append(draft.get(KEY_URL, ""))
        wins = 0
        losses = 0
        if draft.get(KEY_WINS, None) or draft.get(KEY_LOSSES, None):
            wins = draft.get(KEY_WINS)
            losses = draft.get(KEY_LOSSES)
        results.append(wins)
        results.append(losses)
        results.extend(values)
        values = results
        data.append(
            {
                'range': "{}!A{}:Q{}".format(SHEET_DRAFTS, i, i),
                'values': [values]
            }
        )
    body = {
        'valueInputOption': "USER_ENTERED",
        'data': data
    }

    result = service.spreadsheets().values().batchUpdate(spreadsheetId=SPREADSHEET_ID, body=body).execute()
    logger.info('{0} cells updated.'.format(result.get('updatedCells')))

    # Update Deck Card data
    used_card_counts = {}
    used_card_ids = set()
    for draft in drafts:
        deck = draft[KEY_DECK]
        heroes = deck["heroes"].copy()
        for hero in heroes:
            if hero["id"] not in used_card_ids:
                used_card_ids.add(hero["id"])

        cards_to_check = deck["cards"].copy()
        for card in cards_to_check:
            if card["id"] not in used_card_ids:
                used_card_ids.add(card["id"])
    used_card_ids = list(used_card_ids)
    used_card_ids.sort()

    logger.info("Updating deck/card counts")
    drafts.sort(key=lambda d: d[KEY_ID])
    update_deck_sheet_data(service, SPREADSHEET_ID, drafts, used_card_ids, SHEET_DECKS_DATA, lambda d, c: c["count"] if "count" in c else sum([1 for h in d["heroes"] if h["id"] == c["id"]]))

def sort_important_cards(card):
    tier_values = {
        'S': 1,
        'A': 2,
        'B': 3,
        'C': 4,
        'D': 5,
        'F': 7
    }
    (kind, tier, msg) = card
    multiplier = 1 if kind == "Hero" else 1000
    return 1 / (multiplier * tier_values[tier])

def update_deck_sheet_data(service, spreadsheet_id, drafts, used_card_ids, sheet_name, fn, default_value=0):
    values = ["Deck ID \\ Card ID"]
    for card in used_card_ids:
        values.append(card)

    # Append first row with all the cards ids
    data = []
    data.append(
        {
            'range': "{}!A1:1".format(sheet_name),
            'values': [values]
        }
    )
    # Append value rows
    i = 1
    for draft in drafts:
        i = i + 1
        deck = draft[KEY_DECK]
        deck_cards = deck["heroes"].copy()
        deck_cards.extend(deck["cards"])
        values = [draft[KEY_ID]]
        from_column_index_to_value = {}
        for card in deck_cards:
            index = used_card_ids.index(card["id"]) + 1
            from_column_index_to_value[index] = fn(deck, card)
        for index in range(1, len(used_card_ids) + 1):
            val = default_value
            if index in from_column_index_to_value:
                val = from_column_index_to_value[index]
            values.append(val)
        data.append(
            {
                'range': "{}!{}:{}".format(sheet_name, i, i),
                'values': [values]
            }
        )
    body = {
        'valueInputOption': "USER_ENTERED",
        'data': data
    }

    clear_values_request_body = {
        # TODO: Add desired entries to the request body.
    }

    request = service.spreadsheets().values().clear(spreadsheetId=spreadsheet_id, range=sheet_name, body=clear_values_request_body)
    response = request.execute()

    result = service.spreadsheets().values().batchUpdate(spreadsheetId=spreadsheet_id, body=body).execute()
    logger.info('{0} cells updated.'.format(result.get('updatedCells')))


if __name__ == '__main__':
    main()
