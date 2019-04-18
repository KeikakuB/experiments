from __future__ import print_function

import sys
import re
import json

from os import listdir
from os.path import isfile, join

# coded in Python 3.6.5

# Takes a file (a reasonable and user friendly intermediate json file) as input and prints out the more cumbersome and messy but required .asset file and notifies you through stderr of any unused sound files if there are any.

# This allows for much faster creation and iteration of advisor mods (at least it was for my Arnold Schwarzenegger Advisor (https://steamcommunity.com/sharedfiles/filedetails/?id=1546463595)

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

if not len(sys.argv) == 2:
    sys.exit(1)

filename = sys.argv[-1]
with open(filename) as f:
    data = json.load(f)

# check for unused files
used_files = []
for e in data["events"]:
    used_files.extend(e["files"])
used_files = set(used_files)

path = data["file_relative_path"]
files = [f[:-(len(data["file_extension"]) + 1)] for f in listdir(path) if f.endswith(data["file_extension"]) and isfile(join(path, f))]
unused_files = [f for f in files if f not in used_files]
unused_files.sort()
if len(unused_files) > 0:
    for f in unused_files:
        eprint("{} file is unused.".format(f))

# output text for the .asset file
for e in data["events"]:
    number = 1
    for f in e["files"]:
        print("sound =")
        print("{")
        suffix = "_{:02}".format(number)
        print("\tname = \"{}_{}{}\"".format(data["multi_file_prefix"],e["name"], suffix))
        print("\tfile = \"{}{}.{}\"".format(data["file_relative_path"],f, data["file_extension"]))
        print("}")
        number = number + 1


print("soundgroup =")
print("{")
print("\tname = {}".format(data["advisor_name"]))
print("\tsort_order = 100")

print("\tsoundeffectoverrides =")
print("\t{")
for e in data["events"]:
    print("\t\t{} = {}_{}".format(e["name"], data["multi_file_prefix"], e["name"]))
print("\t}")

print("}")

for e in data["events"]:
    print("soundeffect = {")
    print("\tname = {}_{}".format(data["multi_file_prefix"], e["name"]))
    print("\tsounds = {")
    for i in range(1, len(e["files"])+1):
        print("\t\tsound = {}_{}_{:02}".format(data["multi_file_prefix"], e["name"], i))
    print("\t}")
    print("\tvolume = 0.45")
    print("\tmax_audible = 1")
    print("\tmax_audible_behaviour = fail")
    print("}")

print("category = {")
print("\tname = \"Voice\"")
print("\tsoundeffects = {")
for e in data["events"]:
    print("\t\t{}_{}".format(data["multi_file_prefix"], e["name"]))
print("\t}")
print("}")

