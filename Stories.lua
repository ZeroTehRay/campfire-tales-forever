-- Campfire Tales - story collection.
-- Add your own! Each story needs a title and a list of lines.
-- Keep each line under ~240 characters (WoW chat limit is 255).
-- Placeholders: {player} = your character's name, {zone} = current zone.
local _, ns = ...

ns.Stories = {
    {
        title = "The Lantern on Raven Hill",
        lines = {
            "They say a gravedigger once worked the cemetery on Raven Hill, out past Darkshire. Every night he walked the rows with a single green lantern.",
            "One autumn the Night Watch found his shovel standing upright in fresh dirt... and no gravedigger anywhere.",
            "The lantern still burned, swinging gently, though there was no wind and no hand to hold it.",
            "A young watchman went to fetch it. When he lifted it, he heard digging. Below him. Coming UP.",
            "They never found the watchman either. But on foggy nights you can see TWO lanterns on Raven Hill now.",
            "And if you see a third one... well. That means they've started digging for you, {player}.",
        },
    },
    {
        title = "The Miner Who Kept Digging",
        lines = {
            "Before the Defias took the Deadmines, there was a Westfall miner named Old Garrick who swore he heard singing behind the rock.",
            "The foreman laughed. Garrick didn't. He kept swinging his pick, long after the whistle, long after the others went home.",
            "One morning his pick was found on the tunnel floor, and the wall before it was smooth as glass.",
            "Kobolds won't go near that tunnel. Every candle they bring snuffs out at the same spot.",
            "And if you press your ear to the stone, you'll hear it: tink... tink... tink...",
            "Garrick is still digging. Problem is... he's digging OUT.",
        },
    },
    {
        title = "The Bell of the Scarlet Chapel",
        lines = {
            "In Tirisfal there's a ruined chapel the Scarlet Crusade abandoned. Its bell has no rope. Its tower has no stairs.",
            "Still, every so often, the bell rings. Once.",
            "The Forsaken say it rings for someone who is about to die. Which is funny, because most of THEM already have.",
            "An apothecary went to study it. He wrote in his journal: 'The bell rang. I heard my name in the echo.'",
            "That was his last entry. The rest of the pages were full of one word, written over and over: 'Purify.'",
            "Listen... did you hear that? No? Good. Neither did I. Probably.",
        },
    },
    {
        title = "The Seamstress of Duskwood",
        lines = {
            "Everyone in Darkshire knows about the abomination that shambled out of Raven Hill and into town. Fewer know who sewed him.",
            "She was a quiet woman who mended cloaks for the Night Watch. Her stitches were so fine you couldn't find the seams.",
            "Then folks started noticing their mended cloaks were... warmer. Heavier. Sometimes they twitched.",
            "When the Watch broke down her door, they found only her needle, still threaded with something that wasn't thread.",
            "So if your armor ever needs repairing in Duskwood, check the stitching carefully.",
            "Count them. And if there's one more stitch than there was this morning... take it off. Quickly.",
        },
    },
    {
        title = "The Last Dinner Guest",
        lines = {
            "Lord Arugal held grand dinners at Shadowfang Keep, back before the worgen. Twelve seats, always twelve guests.",
            "One night thirteen arrived. Nobody remembered inviting the thirteenth, but he was so polite, so charming.",
            "He never ate. He only watched, smiling, and every time the candles flickered, he seemed a little closer to someone's chair.",
            "By dessert, the guests began howling.",
            "They say the thirteenth guest left before dawn, bowing at the gate, and thanked Arugal for 'such a lovely flock.'",
            "Some say he still travels the roads, looking for a warm fire and good company. Just like this one.",
        },
    },
    {
        title = "The Dreaming Oasis",
        lines = {
            "Travelers crossing the Barrens sometimes find an oasis that isn't on any map. Clear water. Soft grass. Perfect quiet.",
            "A Tauren hunter found it once. He lay down to rest, just for a moment, and dreamed of green forests and endless rain.",
            "When he woke, his kodo had bones where its fur should be, and his beard reached his belt.",
            "The druids of the Wailing Caverns say the Nightmare is patient. It doesn't need to chase you. It only needs you to rest.",
            "So by all means, sit by the fire. Get cozy. Close your eyes.",
            "...Just make sure someone wakes you up.",
        },
    },
    {
        title = "The Murloc Who Remembered",
        lines = {
            "Fishermen along the Westfall coast tell of a murloc that stood apart from the others. It never charged. It only watched.",
            "It watched them pull in their nets. It watched them light their fires. It watched them sleep.",
            "One fisherman woke to find it sitting beside his campfire, warming its webbed hands, staring at him with those huge wet eyes.",
            "It opened its mouth and said, perfectly, in Common: 'Your turn to sleep in the water.'",
            "They found his boots on the dock the next morning. Neatly placed. Full of seawater.",
            "...Mrglglglgl.",
        },
    },
    {
        title = "The Attendance Roll",
        lines = {
            "There's a book in the Scholomance, in a classroom nobody uses anymore. An attendance roll.",
            "Every name on it is crossed out in red ink. Students. Teachers. Adventurers who went in looking for treasure.",
            "A rogue once snuck in to steal it, thinking it was some valuable tome. He flipped to the last page and went pale.",
            "The ink was still wet on the newest entry. It wasn't crossed out yet.",
            "He threw the book in the lake and ran all the way to Chillwind Camp, and never spoke of what name he saw.",
            "But before he died, he said only that it was a name he'd heard around a campfire. A name like... {player}.",
        },
    },
    {
        title = "The Hearthstone That Went Wrong",
        lines = {
            "A hearthstone is supposed to take you home. That's the whole point. You bind it at the inn, and it brings you back.",
            "A dwarf from Ironforge once used his hearthstone in the middle of a storm. The lightning struck just as the spell finished.",
            "He arrived at his inn. Same bar, same keeper, same stew. But the windows showed only black, and nobody would look at him.",
            "He used his hearthstone again. And again. Every time, the same inn. Every time, the shadows in the corners stood closer.",
            "Some nights, when you use your hearth, you'll hear a knocking on the inside of the stone.",
            "Don't answer it. He's been trying to get back for a very long time... and he's not picky about who takes his place.",
        },
    },
    {
        title = "The Fire That Remembers",
        lines = {
            "In the Eastern Plaguelands there once was a village called Darrowshire. On its last night, the villagers huddled around a great bonfire.",
            "The Scourge came anyway. But the fire... the fire remembered every face that sat beside it.",
            "They say that's why campfires crackle and pop. It's not the wood. It's the voices of everyone who ever sat close.",
            "And every fire is the same fire, deep down. Connected, like roots under the soil.",
            "So the fire before you now has heard every story ever told in {zone}... and it's listening to you.",
            "Lean in, {player}. Hear that crackle? It just said your name.",
        },
    },
    {
        title = "The Gnome in the Pipes",
        lines = {
            "When Gnomeregan was flooded with radiation, most gnomes fled. One mechanic, Fizzlecog, refused. He said he could fix it.",
            "He crawled into the pipes with a wrench and a lantern. The others heard him banging for days. Then weeks.",
            "Then the banging changed. It wasn't a wrench anymore. It sounded like... knuckles.",
            "The troggs avoid one particular pipe. When asked why, a captured trogg only drew a picture: a tiny figure with glowing eyes and far too many teeth.",
            "So if you're ever in Dun Morogh and hear tapping in the pipes, tap back. Three times. It's polite.",
            "He gets lonely. And you don't want him coming out to find company.",
        },
    },
    {
        title = "The Night Elf Who Couldn't Sleep",
        lines = {
            "In Ashenvale there's a sentinel who has stood watch at the same tree for ten thousand years. She never blinks.",
            "Travelers greet her. She never answers. Some say she's a statue. Some say she's a ghost.",
            "A curious gnome once stood right in front of her and waved his hand before her eyes. Nothing.",
            "He turned to leave, laughing, and heard a voice whisper behind him: 'I'm not watching the road, little one.'",
            "'I'm watching what's IN the trees. And it has finally noticed you.'",
            "That's why you keep your fire lit at night in the forest. It's not to keep you warm. It's so they can't see your shadow move.",
        },
    },
    {
        title = "The Toll at Thandol Span",
        lines = {
            "Thandol Span crosses the gorge between the Wetlands and Arathi. The dwarves who built it say every bridge needs a keystone. They never said what this one used.",
            "Caravan drivers learned to count their crew before crossing. Seven on one side meant seven on the other. That was the rule.",
            "One foggy night a peddler crossed alone, laughing at the old superstition. Halfway over, he heard footsteps matching his own.",
            "He stopped. The footsteps took one more step.",
            "On the far side the guards counted him twice. Once standing in the road... and once hanging under the bridge, looking up at them, waving.",
            "Crossing the Span soon, {player}? Count your party first. And if the number comes out one higher... don't let the extra one go first.",
        },
    },
}
