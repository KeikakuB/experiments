"Miscelaneous" by Bill Tyros

Volume 1 - Kinds

Part 1 - Beverages

A liquid level is a kind of value. The liquid levels are completely full, mostly full, half full, mostly empty, and completely empty.
A beverage is a kind of thing with description "Peering inside, you see that it's [liquid level of the noun]."
A beverage has a liquid level. The liquid level of a beverage is usually completely full.

Before drinking a beverage (called the cup of coffee):
	if the cup of coffee is not carried by the player:
		try taking the cup of coffee.
Instead of drinking a beverage (called the cup of coffee):
	let amount be the liquid level of cup of coffee;
	if amount is completely empty:
		say "[The cup of coffee] is empty.";
	otherwise:
		now amount is the liquid level after amount;
		say "After you finish chugging, you see that [the cup of coffee] is now [amount].";
		now the liquid level of cup of coffee is amount.

Volume 2 - Dialogue

Part 1 - Self/Monologue Banter

[
To decide whether (index - a number) is in bounds of (table - a table name):
	let N be the number of rows in table;
	if the index is N + 1, decide no;
	decide yes.

Every turn during Arrival:
	if A1 index is in bounds of Table A1:
		if a random chance of 1 in 8 succeeds:
			say "[thought in row A1 index of the Table A1]";
			increment A1 index.

The A1 index is a number variable. The A1 index is 1.

[TODO:change tone of banter => funnier/lepic]
Table A1 - Intro Banter
thought
"INTROBANTER"
]