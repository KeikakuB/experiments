"Calypso's Highly Unlikely Descent" by Bill Tyros

Volume 1 - Set Up

The story headline is "An Overly Serious Tale Inspired by a True Story".
When play begins:
	now the time of day is 9:15 PM.

Book 1 - Settings

Use fast route-finding. Use undo prevention. Use VERBOSE room descriptions. 

Book 2 - Includes

Part 1 - Misc

Include Player Experience Upgrade by Aaron Reed.
Include Far Away by Jon Ingold.

Part 2 - Help

Include Basic IF Help by Andrew Plotkin.

Understand the commands "hint", "hints", "info" as "help".

When play begins:
	now help-about is game-available;
	now the time of day is 5:00 PM.

Understand "about" as abouting. Abouting is an action applying to nothing.

Report abouting:
	say "TODO:ABOUTABOTTUBMATBTATBUTBA"

Part 3 - Keyword Interace

[text highlighting]
Include Keyword Interface by Aaron Reed.

Topic keyword highlighting is true. Parser highlighting is true. 

When play begins: 
	now every scenery thing is keyworded.

Every room has some text called the exits text.

First carry out listing exits: 
	unless the exits text of location is "":
		say the exits text of location;
		say line break;
	stop the action.

After looking: try listing exits.

Part 4 - Bulky Items

Include Bulky Items by Juhana Leinonen.

 Instead of inserting something bulky into the messenger bag:
		say "[The noun] is just too big to fit inside [the messenger bag]."

[aside]
Rule for deciding whether all includes things in containers worn by the player:
	it does not.

[TAKE ALL command ignores bulky items]
Rule for deciding whether all includes bulky things:
	it does not.
Every turn when multiple taking:
	if a bulky handled thing is in the location and the current action is taking:
		say "(bulky items, i.e. [the list of bulky handled things in the location], were ignored)[line break]".

[inserting a bulky item into a container makes the container bulky]
Check inserting something bulky into something (called the box):
	if a bulky thing is in the box:
		say "There's no room for [the noun] anymore when [the random bulky thing in the box] is in [the box]." instead.

After inserting something bulky into something (called the box):
	now the box is bulky;
	continue the action.

After taking something:
	if the noun is enclosed by something (called the box):
		if the number of bulky things enclosed by the box is 0:
			now the box is not bulky;
	continue the action.

[block]
The making room before taking a bulky item rule is not listed in any rulebook.
	The dropping a bulky item before taking something else rule is not listed in any rulebook.

Instead of taking a bulky thing when the player is carrying something not bulky:
	say "[The noun] is too bulky to carry with you carrying [the list of thing carried by the player].".

Instead of taking something when the player is carrying a bulky thing:
	say "You can't carry anything else as long as you're hauling [the random bulky thing carried by the player] with you.".
	
[changes what is said when picking up a bulky item]
The bulky item taken rule is not listed in any rulebook.
Report taking a bulky thing:
	say "With some effort you take [the noun].[command clarification break]".

[can't open bulky containers if carrying them]
Before opening a bulky container (called the box):
	if the box is carried by the player:
		say "[The box] is too big to carry and open at the same time.";
		stop the action;
	continue the action.


Book 3 - Cheats - Not for release 

Include Object Response Tests by Juhana Leinonen. [for testing objects]
Universal door opening is an action applying to nothing. Understand "open def" as universal door opening.
Carry out universal door opening:
	say "[The list of locked doors in the location of the player] [has-have] been unlocked and opened!";
	now all locked doors in the location of the player are unlocked;
	now all closed doors in the location of the player are open.
Universal container opening is an action applying to nothing. Understand "open abc" as universal container opening.
Carry out universal container opening:
	say "[The list of locked containers in the location of the player] [has-have] been unlocked and opened!";
	now all locked containers in the location of the player are unlocked;
	now all closed containers in the location of the player are open.

Book 4 - World Set Up

Part 1 - Misc

Use no scoring. 

When play begins, change the right hand status line to "".

Part 2 - Kinds

Chapter 1 - Light Source

Section 1 - Non-Rechargeable

A light source is a kind of device. A light source is either lit or unlit. A light source is usually unlit.
Check switching off a light source: if the noun is unlit, say "[The noun] is all ready off." instead.
Check switching on a light source: if the noun is lit, say "[The noun] is all ready on." instead.
Carry out switching off a light source: now the noun is unlit. 
Carry out switching on a light source: now the noun is lit.
Understand "toggle [something switched off]" as switching on. Understand "toggle [something switched on]" as switching off. Understand "toggle [something]" as switching on.

Section 2 - Rechargeable

A rechargeable light is a kind of light source.
A battery is a kind of thing. 
A battery has a number called charge. The charge of a battery is usually 5.
A battery has a number called maximum. The maximum of a battery is usually 60.
A battery is part of every rechargeable light.

Understand "charge [something preferably held]" as charging. Charging is an action applying to one carried thing.
Check charging something:
	if a battery (called the cell) is part of the noun:
		if the maximum of the cell minus the charge of the cell is less than ten, say "[The noun] is fully charged." instead;
	otherwise:
		say "[The noun] doesn't have a battery to charge." instead.
Carry out charging something  (called the chargeable):
	if a battery (called the cell) is part of the chargeable:
		let X be a random number between the charge of the cell and the maximum of the cell;
		let B be 15;
		if X + B is greater than the maximum of the cell:
			now the charge of the cell is the maximum of the cell;
		otherwise:
			now the charge of the cell is X + B.
Report charging something  (called the chargeable):
	say "[The chargeable] is more charged than it was before.".

Definition: a battery is discharged if its charge < 1.

Every turn: 
	repeat with light running through rechargeable lights: 
		if a battery (called cell) is part of the light:
			if the light is switched on:
				decrement the charge of the cell; 
				carry out the warning about failure activity with the light; 
				if the cell is discharged, carry out the putting out activity with the light.

Warning about failure of something is an activity. 
Rule for warning about failure of a device (called the machine): 
	if a battery (called power source) is part of the machine: 
		if the charge of the power source is 2, say "[The machine] is obviously going to go out quite soon." 

Putting out something is an activity. 
Rule for putting out a device (called the machine): 
	say "[The machine] loses power and switches off![line break]"; 
	silently try switching off the machine. 

Instead of switching on an empty device: 
	say "[The noun] can't be switched on, its battery isn't charged." 

Definition: a device (called the light) is empty: 
	if a battery (called the power source) is part of the light: 
		if the power source is discharged, yes;
		no; 
	yes.

Chapter 2 - Book


A book is a kind of thing. Understand "book" as a book. A book has a table name called the contents.
To say list entries for (book - a book):
	say "[The noun] has entries on the following topics: ";
	repeat with N running from 1 to the number of rows in the contents of the noun:
		choose row N from the contents of the noun;
		if N is not the number of rows in the contents of the noun:
			say "[name entry], [no line break]";
		otherwise:
			say "[name entry].".
Instead of consulting a book about a topic listed in the contents of the noun:
	say "[reply entry][paragraph break]". 
Report consulting a book about: 
	say "You flip through [the noun], but find no reference to [the topic understood].[paragraph break][list entries for the noun]" instead.


Part 3 - Commands

Chapter 1 - Praying 
 
 A thing can be holy.
Understand "pray [something]" or "pray with [something]" as praying. Praying is an action applying to one carried thing.
Check praying:
	if the noun is not something holy, say "You must have something holy to pray with." instead.
Report praying:
	choose a random row from the Table of Prayers;
	say "You grasp [the noun] tightly in your hands.[paragraph break]You [position entry] [no line break]";
	choose a random row from the Table of Prayers;
	say "and [prayer entry].".

Table of Prayers
prayer	position
"whisper a prayer from your childhood"	"bend down on your knees"
"draw out a cross on your body, warding off evil"	"lift your head up high"
"say six hundred and sixty six , six times"	"sit upon the ground cross-legged"
"put your right-index finger on your neck to take your pulse"	"cross your arms across your chest"
"place your right fist into the air"	"bring your shoulders forward, tilt your head forwards"

Chapter 2 - Blessing

Understand "bless [something] [something]" or "bless [something] with [something]" as blessing. Blessing is an action applying to one visible thing and one carried thing.
Check blessing:
	if the noun is the player, say "I'm as holy as can be." instead;
	if the noun is not a person, say "Only people can be blessed." instead;
	if the second noun is not holy, say "You must have something holy to perform blessings." instead.
Report blessing:
	choose a random row from the Table of Blessings;
	say "You grasp [the second noun] tightly in your hands.[paragraph break]You looks towards [the noun] with warmth and exclaim, '[blessing entry].'";

Table of Blessings
blessing
"May thy life be long and happy"
"May you never live with fear and stress upon your mind"
"May the demons stray far from this one"
"May thy living breath stave away evil"
"May thy heart's blood flow through your body for as long as necessary"

Book 5 - People Items and Convo

Part 1 - The Player (Calypso)

Chapter 1 - Items

Calypso is a person. Calypso is in the Graveyard. The player is Calypso.
The carrying capacity of the player is 3.

The player is wearing the messenger bag, the top hat, the gothic trenchcoat, the sexy wristwatch, the tight jeans, the knee-high boots and the long tube.

The messenger bag is a closed, openable container with description "A legendary messenger bag with the words 'Bag of Holding' and a stitching of a 20-sided die on its front flap. Imitations of my messenger bag are sold far and wide but mine and mine alone has the ability to store a number of items larger than infinity... Plus one." The messenger bag is the player's holdall.

The top hat is a wearable thing with description "A tall, flat-crowned, cylindrical black hat rumoured to be the source of my mythical powers. I will neither deny nor confirm these allegations at this point in time."

The gothic trenchcoat is a wearable thing with description "A gift given to be by the priests of Asgard II for saving their planet from the wrath the Cthulhu."

The sexy wristwatch is a wearable thing with description "A sleek, shiny, digital watch, it reads [time of day]. Nothing special about it, expect its unnatural sexiness factor."

The tight jeans are a wearable thing with description "A pair of pristine black jeans. In my thousands of years of time-bending adventures, they've never torn or worn out." The indefinite article is "a pair of".

The knee-high boots are wearable thing with description "A pair of long black leather boots. A Glixglack from Terra Cotta named Sarah Maldova, tired of of living as the sexiest woman to have ever lived ever, took her own life. Due to my position as her only lover, I was given her boots." The indefinite article is "a pair of". 

A dull katana is a thing in the messenger bag with description "A katana, with a blunted edge. Made before the dawn of time, by gods unknown to most men, it personally given to me thousands of years ago. It's edge has dulled over the years because I'm just too awesome for it. I keep for the memories, not for its usefullness in battle."


The Monster Manual is a book in the messenger bag with description "A thick iron-clasped tome. It's proven itself more than enough times to warrant lugging its heavy ass around everywhere I go. CONSULT manual ABOUT X. [paragraph break][list entries for the Monster Manual][line break]If I get into trouble I might want to CONSULT it ABOUT whatever it is I'm getting torn apart by."
The contents of the Manual is the Table of Monsters.
Instead of consulting the Monster Manual about a topic listed in the contents of the noun: 
	say 
	"[bold type][name entry][roman type] ([italic type][latin entry][roman type]): [reply entry][paragraph break][italic type]Strengths[roman type]: [strengths entry][paragraph break][italic type]Weaknesses[roman type]: [weaknesses entry][paragraph break]". 

[TODO]
Table of Monsters
topic	name	latin	weaknesses	strengths	reply
"necromancers/necromancer"	"necromancers"	"modo tacita mortuis"	"Bad eyesight."	"Can summon the dead back to life."	"Powerful mages who specialize in the ungodly magic of the dead."
"angels/angel"	"angels"	"servis Dei"	"None."	"Immortal, beautiful, can fly."	"Beautiful winged humanoids created by God to be his eternal servants."
"demons/demon"	"demons"	"infernum terminales"	"Angers easily, dislikes water."	"Fire resistant, unpredictable."	"Creatures of many shapes and sizes birthed in the depths of Hell."
"golems/golem"	"golems"	"judeus servus"	"Heavy, stupid."	"Big, very strong, durable."	"Big hulking machines built using the souls of the living."
"vampires/vampire"	"vampires"	"sanguis vitulamen"	"Daylight, garlic, religious symbols, stake to the heart, can't enter a home without being invited in."	"Seductive, cunning, experienced, strong."	"Vampires are human-looking creatures of the night who feed on the blood of the innocent. Vampires are sired (read created) by a vampire taking the human life and mixing their demonic blood with that of the human bringing him or her back as a vampire."
"ghouls/ghoul"	"ghouls"	"ambulans mortuus"	"Praying in their vicinity hurts them, stupid, slow."	"Determined."	"Shambling corpses brought back from the dead through necromancy."
"zombies/zombie"	"zombies"	"cerebrum comedenti"	"Blows to the brain."	"Numbers can overwhelm."	"Humans infected with a virus of demonic origin causing them to transform into brainless brain-eaters upon death."








Volume 2 - Adventure

Book 1 - Cemetery

[Character thinks that he's the star of a show/video game?]

Part 1 - Scenes

The Arrival is a scene. Arrival begins when the player is in the Cemetery for the first time.
When Arrival begins:
	say 
"I, Calypso, am the one and only, world-renowned, pop rock star and legendary destroyer of demons, vaporizer of vampires and underminer of the undead. Tales of my gazillions of conquests are told near warm campfires across time and space within all galaxies that ever were and ever will be.

A destroyer of evil by day and a destroyer of evil by night.  Wherever the forces of evil gather, I, Calypso, shall be called to annihilate them with the power of over nine-thousand supernovas. Day in and day out, I, Calypso, risk my life, fighting against the forces of darkness, not for the glory or the sexual gratification it provides me... But in order to protect the innocent from a darkness that would otherwise engulf them.

Tonight is a night like every other night.
	
There have been reports of the undead rising up in droves in Los Demonios. The name of Valhallery the Malevolent is whispered in dark circles, it is said that she is responsible for the recent risings. I, Calypso, shall defeat the evil necromancerette once and for all. The woman I once called... mother, shall die by my hand tonight.

I, Calypso, have arrived at the cemetery on the outskirts of town where Valhallery is residing. My highly outrageous and, some say, very unlikely story begins like so,[paragraph break]"

Part 2 - Rooms

The Cemetery is a region. The Graveyard, the Tomb, the Mausoleum and the Grove are in the Cemetery.

Chapter 1 - Graveyard

The Graveyard is a room with description "[A statue of Death] himself lies in the middle of the graveyard, menacingly towering over an endless sea of great grey and brown [tombstones]. Beneath a dark and foreboding [sky], a thick [fog] engulfs everything as far as the eye can see." and exits text "A small forest path leads to the [east]. Towards the [west], a large tomb lays at the head of a well-trodden path. To the [south], a carefully hidden mausoleum can be seen. [An archway] with stairs leading [down] underground seems to call out to you from within the fog.".
Instead of smelling the Graveyard, say "The scent of Death, disease and death."
Instead of listening to the Graveyard, say "The howling of a pack of cyber-wolves can be heard in the distance."

Some tombstones are scenery in the Graveyard with description 
"Many tombstones of all shapes and sizes tower over this God forsaken land. 

The intense emotions that would be provoked within the average man by these tombstones would be fear, uncertainty and more fear. Calypso feels only a profound need to congratulate the landscaper for doing such a fine job with the place."

The sky is a distant backdrop in the Graveyard with description 
"A menacing, dark and cloudy sky. 

The sky can moan and cry all she wants. She's lucky Calypso is going underground tonight, if not, he would have go up there and talk some sense into her."

The fog is a backdrop in the Graveyard with description 
"A thick, unnatural and unsettling fog that would make most men cry out for their mothers.

Calypso is not most men."

The archway is a scenery in the Graveyard with description 
"A large archway leading underground.

Calypso has been to the fiery depths of hell one thousand three hundred and thirty seven times now. Calypso fears not the hallow halls beneath the ground. 

[bracket]However, Calypso does wish to keep your clothes and hair as sexy as possible, he cannot risk damaging anything by walking in underground tunnels without a light.[close bracket]"

The statue of Death is scenery in the Graveyard with description 
"A statue of Death himself, pointing his massive scythe straight up towards the sky.

Calypso would be frightened by Death if he hadn't met and befriended the Grim Reaper over one thousand years ago. A nice man, he was, a little violent to say the least but, overall a nice man.

Below it, lies an engraved [o]poem[x]." 
The statue has a keyword "statue".

The poem is a part of the statue. 
The poem is a thing with description 
" Most, dead men walking flock to the light,[line break]
The living dead fear the wrath of God's might,[line break]
Prayer shall break his will against your demands,[line break]
Freedom is given only to those who grip Death in their hands.

It might hold the clue to reaching the underground. Calypso is worshipped as a god in hundreds of religions across this universe and the next. One such as Calypso does not need clues. No, the clues need Calypso."

The small box is a closed, lockable and locked container with description  "A small box. you notice a skull-shaped hole in the middle of it." 
The skull staff unlocks the small box.

The electric lantern is a rechargeable light in the small box with description "[A lantern] of moderate size. A [o][lever][x] is attached beneath its base. [if lit]Its light shines brightly upon your surroundings.".
The lever is part of the lantern.
The lever is a thing with description 
"A small lever meant to be twisted clockwise.

One as mighty and powerful as Calypso does not need to be told that it is used for charging [the lantern].".

Instead of charging, pushing, pulling or turning the lever:
	try charging the lantern.
Rule for warning about failure of the lantern:
	if a battery (called power source) is part of the lantern: 
		if the charge of the power source is 2, say "[The lantern]'s light begins to go out in short flashes."
Report charging the lantern:
	say "Calypso valiantly turns the lever beneath [the lantern] clockwise about [a random number between 10 and 30 in words] time[s].[command clarification break]".

Before examining the statue for the first time:
	now the small box is in the Graveyard;
	say "As Calypso looks closer, he notices [a small box] hidden beneath dense shrubberry next to the statue.".

Chapter 2 - Tomb

The Tomb is west of the Graveyard.
The Tomb is a room with description "The tomb's walls are pierced with empty [holes] meant for holding the dead. The white and teal [tiles] upon the floor are smeared with dry blood. [An altar] stands defiantly at the head of [a ritual circle] with [a chest], [chest lid state], laying upon it. A[if pillar is shifted]slightly off-center[end if] [pillar] is found in the middle of a ritual circle traced in blood around which a dozen or so [candles] stand with flames flickering back and forth unnaturally." and exits text "To the [east], lies a small path back towards the graveyard.".

To say chest lid state:
	if the chest is open:
		say "lid swung open";
	otherwise:
		say "lid shut tight".

Some holes are scenery in the Tomb with description "Holes meant for the dead."

The pillar is a scenery and fixed in place thing in the Tomb with description "A intricately designed pillar. Calyspo notices light markings beneath it as if it had been recently moved due to his super-human senses."
The pillar can be shifted.
Instead of pushing or pulling the pillar:
	if the pillar is shifted:
		now the pillar is not shifted;
		say "As Calypso nudges [the pillar] back into it's original position, [if the chest is open]he sees [the altar]'s chest swing shut accompanied by a[otherwise]he hears a sharp twanging sound and a[end if] loud grinding sound coming from [the altar].";
		now the chest is closed;
		now the chest is locked;
	otherwise:
		now the pillar is shifted;
		now the chest is unlocked;
		say "As Calypso nudges [the pillar] away from [the circle], he hears the sound of old rusty gears moving into action and a sharp thwanging sound coming from [the altar].";
	continue the action.
After touching the pillar:
	say "[The noun] doesn't seem to be fixed in place. Interesting."

Some candles are scenery and lit thing in the Tomb with description 
"A dozen lit candles, placed upon the edge of the demonic circle, flutter back and forth summoning horrifying shadows upon the walls of the tomb. 

Calypso was once tempted by the a demon's flesh roasting within a summoning circle similar to this one. Surprisingly, the demon tasted like chicken."
Some tiles are a scenery thing in the Tomb with description 
"Grimy and bloody white and teal tiles placed uniformly around the tomb.

By glancing at them for exactly zero point zero zero zero zero zero zero sixty nine nanoseconds, Calypso realizes that this particular arrangement of tiles demonstrates perfectly the theories present within Epitoff's seminal paper titled 'Conjectures on Pattern Recognition within Floor Tiles'. A very philosophical read."

The ritual circle is a scenery thing in the Tomb with description 
"A 7-foot radius circle drawn in blood surrounded by many intricate paintings of evil symbols, including the portrait of a certain Mauzlym prophet, an actual red cross and the words 'I just want to be friends, it's not you it's me.'"

An altar is a scenery, fixed in place thing in the Tomb with description 
"A short red altar with [a chest] entrenched within it. Encarved on either side are two statuettes, one of an angel and the other of a snarling demon, holding hands.

Calypso appreciates the profound and deep-seated symbolism present within this artistic masterpiece."

A ceremonial chest is a closed, locked and fixed in place container on the altar with description 
"A medium-sized ceremonial chest.

During his adventures, Calypso has experienced many encounters with chests of all shapes and sizes, although he has been known to prefer those graced with two round, soft and large mounds upon them the most."

A chained cross is a wearable thing in the chest with description 
"A long chain[if cross is not holy], tinted red with blood,[end if] upon which hangs an intricate golden cross.[if cross is holy] It emanates an aura of supreme holiness.[end if] 

As a god, Calypso bows down to no one. However upon occasion, he has asked himself for forgiveness, has paid himself indulgences and has touched himself in hopes of awakening the priest within him... All to no avail. However, Calypso might be willing to give prayer a shot especially if, through some very contrived circumstances, it will help him reach Valhallery."

A prayer book is a thing on the altar with description 
"A thick leather-bound tome with most pages ruined by the passage of time. Only [the number of things which are part of the prayer book in words] page[s] are legible, [the list of things which are part of the prayer book].

Calypso has been known to read upon occasion, not to gain any new knowledge, for all the knowledges are belong to him, but in order to gain insight on the backstory of his own adventures."
The Litany Against Fear is part of the prayer book. The description is 
"'We must not fear death. Fear is the mind-killer. The fear of death leads toward a path of of total obliteration. We will face our fear. We will permit it to pass over us and through us. And when it has gone past we will turn the inner eye to see its path. Where the fear has gone there will be nothing... Only acceptance shall remain.'[line break]- Brother Herbert (1548)".
The Nota Bene on Death is part of the prayer book. The description is 
"Death's scythe strikes fear into all of us at first. Tis normal to fear death. But, breaking from his steely grasp is not something that one should strive towards.  Rather, accepting the presence of death is the only to for an earthly creature to prepare themselves for their crossing to the other side. 

Few remember that, death is the greatest equalizer, we all shall die. Death does not judge and he does not steal, he only takes what he is given. That is to say our lives. He takes life, tis true. But, without death there would be no new life. Evolution is only possible through the manipulation of the cycle of Life, or rather the cycle of Life and Death.

Furthermore, Heaven and Hell are mere lies told by men to try and pacify their fears. The idea that in the end there is nothing, absolutely nothing, is too hard for some to believe. We only walk upon this Earth once, therefore we should be honest to ourselves, accept the presence of death and live our lives to the fullest while it lasts.[line break]- Reverend Morte (1611)".
The Valentine Commentary is part of the prayer book. The description is 
"'We're wasting precious time, the clock is ticking. Hearing the clock tick with every hour. Lord Death give me thy power, give me the strength to carry on until I hear my demise ringing. Never before, never again shall I behold your grand adversary, the Light One. We are all born to die. Tis shall remain true till the End of Days.'[line break]- Bala Valentine (1409)".
The Guardian Angel Death is part of the prayer book. The description is "'Angel of Death, my Guardian dear, to whom thy hate commits me here, ever this day (or night) be at my side, to bring forth darkness where light has shone, to take and to hate. Amen.'".

Chapter 3 - Grove

The Grove is east of the Graveyard.
The Grove is a room with description "At the far edge of the grove, [a fountain], decorated with the words 'To Cleanse Is To Kill' spelled in blood, its [basin] [basin state], stands on its own with [crooked lever] at ready upon its side. A great number of ancient [trees] with long and [twisted branches] produce creaking and cracking sounds while swaying in the [gentle breeze]. The tree trunks seem to bend inwards toward the fountain, protecting it from some unknown evil." and exits text "A small dirt road lies [west], back towards the graveyard."

To say basin state:
	if the number of things in the basin is not zero:
		say "filled with [a list of things in the basin][no line break]";
	otherwise:
		say "empty[no line break]".

Some trees are scenery in the Grove with description 
"Dozens of dark trees forming a protective circle around the fountain with their trunks tilted inwards.

Calypso does not approve of plant life that emulates human-like behaviors in order to be creepy. It is unbecoming of them."

Some twisted branches are scenery in the Grove with description 
"Long, zig-zagging branches bursting forth from their trees unnaturally.ow

As all who've travelled through the galaxy know, Zig-zagging is a pattern only present within the unnatural."

The gentle breeze is scenery in the Grove with description "A gently, cool breeze."

The fountain is a scenery thing in the Grove with description "A circular [fountain] with adorned with Greco-Roman sculptures inter-connected by the simultaneous experience of an in-process, lead-fuelled, orgy. [paragraph break][The list of things which are part of the fountain] are part of the fountain.".
The basin and crooked lever are part of the fountain.

The basin is an open, fixed in place container with description "A small [basin] with dried blood smeared around its edge."

The crooked lever is a thing with description "[A lever] slightly bent out of shape.".
After pushing or pulling the crooked lever:
	say "You push [the lever]. [no line break]";
	if the holy water is in the basin:
		say "Some more [holy water] falls into [the basin], spilling some onto the ground.";
	otherwise:
		say "Some [holy water] fills [the basin].";
		now the holy water is in the basin;
		if the cross is in the basin:
			now the cross is holy.

Some holy water is a fixed in place thing with description "Clear. Smells of alcohol."
Instead of taking the holy water:
	say "I'd better leave [the noun] where it belongs. I'd hate to get wet for no good reason.";
	stop the action.

Instead of inserting something into the fountain:
	try inserting the noun into the basin.
Instead of inserting something into the holy water:
	try inserting the noun into the basin.
Instead of inserting something into the basin:
	if the noun is the cross:
		say "You place [the noun] into the basin.[command clarification break]";
		if the holy water is in the basin:
			now the noun is holy;
		continue the action;
	otherwise:
		if the holy water is in the basin:
			say "I'm sure I can find something better suited for a holy bath than [a noun].[command clarification break]";
			stop the action;
		otherwise:
			continue the action.

Chapter 4 - Mausoleum

The Mausoleum is a room with description "Within the mausoleum, [the cold air] sinks into your flesh causing you to shiver. Out of the corner of your line of sight, [a hoard of spiders] can be seen darting away from you in fear. [The stone floor] littered with dozens discarded pieces of human flesh and bone." and exits text "Towards the [north] lies a path leading back to the graveyard."
The Mausoleum is south of the Graveyard.

The cold air is scenery in the Mausoleum with description "Its icy touch pushes itself against you."
A hoard of spiders is distant scenery in the Mausoleum with description "Dozens of tiny, long-legged spiders cowering in fear in the darkness above you."
The stone floor is scenery in the Mausoleum with description "A floor covered by the remains of the dead, built from flat rocks and stones, seemingly bursting forth from the ground due the uneven surface beneath them."
An oak coffin is a bulky, closed, openable container in the Mausoleum with description "An old oak coffin with [if closed]lid closed tightly shut.[otherwise]lid flung wide open.[end if][if the stiff ghoul is in the coffin] You sense an evil presence emanating from within.".
The oak coffin can be stuck or unstuck. The coffin is stuck.
Instead of opening the oak coffin:
	if the coffin is stuck:
		if the player carries the dull katana:
			say "You pry open [the noun]'s lid using the dull katana.";
			now the coffin is unstuck;
			continue the action;
		otherwise:
			say "[The noun]'s lid is stuck. I need to pry it open with something.";
			stop the action;
	otherwise:
		continue the action.

Some clerical robes are a wearable thing in the coffin with description "Priestly looking."

An envelope is an openable and closed container in the coffin with description "[if open]An [envelope] with an unfolded upper flap.[otherwise]A sealed [envelope]."
The envelope has carrying capacity 1.

A letter is a thing in the envelope with description
"A crumpled and dusty [letter] addressed to Jonathan Strange on 4242564 Dead End Drive, it reads,

Dear Jonathan,[line break]
I've had objections towards our personal 'project' ever since we began. Your dreams are grand but not everything is meant to be. My love for you is all that kept me working every waking moment of my existence on this painfully wrong and misguided endeavor. Science has brought upon this world as much good as it has bad. I do not doubt that we could have accomplished what you set out to do from the start. However, you must understand me when I say that some things are never meant to be.

Your quest to gain supremacy over the laws of life and death is one of them. My love for you has waned ever since we began this ill-fated and God-forsaken mission. I will not let this dream of yours taint the lives of every single being on this planet. This madness has gone on for far too long and I have decided to put a stop to it. If you are reading this now Jonathan, then it will already be too late. You shall die in the next hour and you shall take your evil plans to the grave with you.

I did love you once, but no longer. In time, you will realize that immortality belongs only to God. No man can rid himself of his fate, to do so is heresy. Death cannot be tricked, by love, by cunning or by prayer. Death treats all men equally.

Love,[line break]Carline."
A ghoul is a thing in the coffin with description "A corpse brought back from the dead, also known as [a ghoul]. [A ghoul] strength directly relates to the power of its summoner. This one can't even move. Conclusion... Really bad necromancer".
The ghoul can be stiff or slack. The ghoul is stiff.
Instead of examining the ghoul:
	say "[A ghoul] with [if the ghoul is stiff][a staff] in his firm grasp.[otherwise]slack hands at his side."

A skull staff is thing in the coffin with description "An old-looking staff with an intricate carving of a skull on one end."
After praying in the Mausoleum:
	now the ghoul is slack;
	if the coffin is closed:
		say "You sense a slight movement from within [the coffin].";
	otherwise:
		say "[The ghoul] has loosened his grip on [the staff]."
Instead taking the staff in the Mausoleum:
	if the ghoul is stiff:
		say "You try to take [the staff] but [the ghoul]'s grasp is too tight.";
	otherwise:
		say "You grip [the staff] and wrench it from [the ghoul]'s cold, doubly-dead hands.";
		continue the action.

Book 2 - Crypt

Part 1 - Scenes

Arrival ends when the player is in the Crypt.
The Crawl is a scene. The Crawl begins when the Arrival ends.

Part 2 - Rooms

The Crypt is a region. The Entrance, the Corridor, the Passage, the Prison, the Hole, the Storage Room, the Hall and the Pantry are in the Crypt.

Chapter 1 - Entrance

The Entrance is below the Graveyard.
The Entrance is a dark room with description "[A damp path] leads to [an ornate door] accompanied by two [hooded figures] made of stone, one on either side of it. Filth of all kinds lies scattered across the floor. [A puddle of dirty water], beneath [the cracked ceiling] that spawned it, reeks of the dead and dying." and exits text "Some stairs snake upwards [d]behind[x] you. [The ornate door] leading deeper into the crypt lies in [d]front[x] of you."
Understand "behind" as up when location is the Entrance. Understand "front" as east when location is the Entrance.

Before going to the Entrance from the Graveyard:
	if the lantern is in the messenger bag:
		silently try taking the lantern;
	if the player has the lantern:
		try switching on the lantern;
		if the lantern is not empty:
			say "Good, this [lantern] should give off enough light to let me enter the crypt safely.[line break]";
			continue the action;
		otherwise:
			say "I'm definitely not going in there with the [lantern] turned off for fear of stepping on something ikky.";
			stop the action;
	otherwise:
		say "It's much too dark down there. I'll mess up my hair if I go down there without a light source of some kind.";
		stop the action.

The cracked ceiling is scenery in the Entrance with description "A ceiling painted with a black and dark green criss-crossing pattern. In one corner, it bulges downward unnaturally letting water slowly drip into a puddle below."

[TODO:mop up puddle with mop(storage room)=> find something?]
The puddle of dirty water is scenery in the Entrance with description "A shallow puddle of water, so dirty and grimy that you cannot see the floor beneath it."
The keyword of the puddle is "puddle".

The damp path is scenery in the Entrance with description "A slimey path leading to [the ornate door]. Its many cracks and uneven grooves hint at the age of this place."
The ornate door is a scenery, not openable, open, not lockable, not locked, door with description "TODO:A door made of clay and stone.".
The ornate door is east of the Entrance and west of the Hall.

Some hooded figures are scenery in the Entrance with description "Two hooded figures, at least three times your size, chiseled from rock lying on either side of [the ornate door]. Covered in their dark hooded robes, they are bent forward in a gesture of worship with their hands joined in front of them. You guess that these represent priests of some kind from an age long past.".

Chapter 2 - The Hall

The Hall is a dark room with description "TODO." and exits text "[d]Behind[x] you lies the entrance. Two passages lie on either side of you. To your [d]left[x], a dark corridor. To your [d]right[x], a dark passage.".
Understand "left" as north when location is the Hall. Understand "right" as south when location is the Hall. 

Chapter 3 - Prison n' Cell

The Prison is east of the Corridor.
The Prison is room with description "[A odd torch] with a bright blue flame sheds an oddly coloured light onto your surroundings. [A painting] of a sad looking [dark-haired woman] hangs in front of you. To your right, lies the remains of various [cages], big and small, smashed almost beyond recognition. A single [prison cell] remains unscathed from the chaos and destruction that was brought forth within these walls." and exits text "To the [west], lies the twisted passage leading back to the corridor.".

An odd torch is scenery in the Prison with description "A torch adorned by a deep blue flame cast from the open maw of metallic snake wrapped around its cylindrical body."
The metallic snake is a thing with description "A jet of deep blue flame spews from its mouth. Decidly evil looking."
The metallic snake is part of the odd torch.

A grim painting is scenery in the Prison with description "[A painting] of [a dark-haired woman] held within an imposing frame made of bones.".
A dark-haired woman is a thing with description "A sullen faced woman with silky dark hair and blue eyes fully covered in black dress.  Her gaze seems to follow your movements, she would be cute... If she wasn't so creepy.".
The dark-haired woman is part of the painting.

Some cages are scenery in the Prison with description "Cages, broken beyond repair. You've read it that the cage is a symbol used by artists and writers today to symbolize a deity worshipped in a time long gone on Earth Prime. They called him the One True God."

The prison cell is a scenery, fixed in place, transparent, locked, lockable, closed, openable, container in the Prison with description "The only intact [prison cell] I can see.".
The silver key unlocks the prison cell.
A shiny bauble is a thing in the cell with description "Oooh... So shiny. My precious.".

The rotten desk is a bulky, enterable and portable supporter in the Prison with description "A slanted three-legged triangular stone desk.".

The scribbled note is a thing on the desk with description "A yellow-stained handwritten note. It reads,[paragraph break]Ok, ok. I need to get this cube open before Jared comes back or I'm gonna get a mouthful of undead meat sandwich. [paragraph break]What was the combination? Was it 1, 2, 5? Or was it 2, 3, 5? No... It can't be, how about 4, 6, 5? Does it or doesn't it have to be ordered? I forget.".

The puzzle cube is a closed container on the rotten desk with description "A wooden [puzzle cube], just the right size to grasp in the palm of your hand.[paragraph break]Each side of the cube has a single button in the middle with a different dotted code on it, including: [a list of things that are part of the puzzle cube].".
The puzzle cube has carrying capacity 1. The printed name of the puzzle cube is "puzzle cube".
The silver key is a thing in the puzzle cube  with description "A slender silver key with a handle shaped in the image of a headless woman's body with large breasts and no pubic hair. Perverted shizzle.".

Instead of attacking the puzzle cube:
	if the player carries the sledge hammer:
		say "You wield [the sledge hammer] with a confidence unknown to most men, you lift it above your head and let it come crashing down on the poor innocent cube as it explodes into thousands of pieces. Only [a list of things in the puzzle cube] remain[s] in the wake of your destruction.";
		now all the things in the puzzle cube are in the location of the player;
		remove the puzzle cube from play;
	otherwise:
		say "You throw [the puzzle cube] onto the ground with a surprising amount of force but it remains unscathed.".

A button is a kind of thing. A vertical state is a kind of value. The vertical states are pressed and unpressed. A button has a vertical state. The vertical state of a button is usually unpressed.
Instead pushing a button (called the knob):
	if the vertical state of the knob is pressed:
		now the vertical state of the knob is unpressed;
	otherwise:
		now the vertical state of the knob is pressed;
	continue the action.
After pushing a button (called the knob):
	if the vertical state of the knob is pressed:
		say "[The knob] sets itself snug into its groove.";
	otherwise:
		say "[The knob] springs back into its original position.".
The one-dot button, two-dot button, three-dot button, four-dot button, five-dot button and six-dot button are buttons. 
The one-dot button, two-dot button, three-dot button, four-dot button, five-dot button and six-dot button are part of the puzzle cube. 
The printed name of the one-dot is "[vertical state of one-dot button] one-dot button". The printed name of the two-dot is "[vertical state of two-dot button] two-dot button". The printed name of the three-dot is "[vertical state of three-dot button] three-dot button". The printed name of the four-dot is "[vertical state of four-dot button] four-dot button". The printed name of the five-dot is "[vertical state of five-dot button] five-dot button". The printed name of the six-dot is "[vertical state of six-dot button] six-dot button". 

Chapter 4 - Corridor

The Corridor is north of the Hall.
The Corridor is a dark room with description "TODO:CORRIDOR" and exits text "[east] and [west]".
Some rubble is a scenery thing in the Corridor with description "Many large rocks make the tight corridor even tighter. That's how I like it."
Instead of taking, pushing or pulling the rubble:
	say "The rubble is too heavy to be moved."

Some crosses are scenery in the Corridor with description "Numerous [crosses] hang from the walls of this dark corridor.". The printed name of the crosses is "[if crosses are inverted]upside down [end if]crosses".
The crosses can be inverted or not inverted. The crosses are inverted.
Instead of pushing, pulling or turning the crosses:
	say "TODO: THIS COULD DO SOMETHING COOL. UNLOCK/MAKE NEW PASSAGE";
	now the crosses are not inverted;
	continue the action.

Chapter 5 - Passage

The Passage is south of the Hall.
The Passage is a dark room with description "TODO:A small passage way. You have to bend down not to hit your head on the low ceiling. ".

Chapter 6 - Hole

The Hole is west of the Corridor. 
The Hole is a dark room with description "TODO:A hole that doesn't seem to end." and exits text "[east]".
Instead of dropping something when the player is in the Hole:
	say "If I drop anything here, I won't be getting it back. Ever.[paragraph break]Let me think about that for a sec...[paragraph break]...[paragraph break]Nope!";
	stop the action.

Chapter 7 - Storage Room

The Storage Room is west of the Passage.
The Storage Room is dark room with description "TODO:STORAGE ROOM" and exits text "[east]".

The well is a scenery thing in the Storage Room with description "A deep well filled with brackish water."

The bucket is an open container in the Storage Room with description "A small wooden bucket."

[TODO:use to soak up water in Entrance]
A dirty mop is a thing in the Storage Room with description "[A dirty mop]. It's way too dirty to clean anything with but it could probably soak up a fair amount of water."

Some shelves are a fixed in place thing in the Storage Room with description "Barely filled shelves with vines growing on them."

The sledge hammer is bulky, distant thing on the shelves with description "A big and heavy [sledge hammer], good for smashing things.".
Before taking the sledge hammer:
	if the sledge hammer is distant:
		if the rotten desk is in the Storage Room:
			if the player is on the rotten desk:
				now the sledge hammer is near;
	continue the action.
After taking the sledge hammer for the first time:
	say "You reach up towards the highest shelf, grip [the sledge hammer] in both hands and with some effort you gently lower it near your chest.".
Instead of putting the sledge hammer on the shelves:
	say "I worked so hard to get [the sledge hammer] down from there. I'll throw it away but I'm not going to put it back.".

Chapter 8 - Pantry

The Pantry is east of the Passage.
The Pantry is a dark room with description "TODO:PANTRY." and exits text "[west]".

