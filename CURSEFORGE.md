# CurseForge project page: Campfire Tales

Everything to paste into the CurseForge project form. The images are in `media/`.

## Project settings

| Field | Value |
|---|---|
| **Name** | Campfire Tales |
| **Summary** (one line) | Sit by a campfire and hear a spooky story, told line by line to you or your party. |
| **Logo / avatar** | `media/logo-400.png` (400 × 400) |
| **Main category** | Roleplay |
| **Other categories** | Chat & Communication, Miscellaneous |
| **Game version** | The WoW Forever flavor (interface 16001) |
| **License** | Pick one before publishing (for example MIT or All Rights Reserved) |
| **Source** | https://github.com/ZeroTehRay/campfire-tales-forever |

## Screenshots (upload in this order)

1. `media/1-sit-by-the-fire.png`: Sit down by a campfire
2. `media/2-story-over-a-minute.png`: A spooky story, told over one minute
3. `media/3-who-hears-it.png`: Party chat in a group, only you when solo
4. `media/4-once-an-hour.png`: One story an hour, plus the commands

## Description (paste below this line)

---

# 🔥 Campfire Tales

**Pull up a log. Someone's got a story to tell.**

Campfire Tales turns every campfire into a ghost-story circle. When you sit by a fire and get the **Cozy Fire** buff, your character starts telling one of **12 spooky tales** set around Azeroth, such as the gravedigger's lantern on Raven Hill, or the Westfall miner who never stopped digging.

## How it works

1. **Sit down by a campfire.** The Cozy Fire buff starts the story. You don't have to do anything else.
2. **The tale unfolds over one minute.** Lines are spread out over the buff's duration, so it feels like a real story told around the fire.
3. **Your party hears it too.** In a group, the story goes to party chat. Solo, only you see it.
4. **One story an hour.** Automatic stories happen at most once an hour, so the fire never gets old. The timer is kept across `/reload` and logout.

Getting into a fight stops the story.

## Commands

Type `/campfire` or `/tales`.

| Command | What it does |
|---|---|
| `/campfire tell [n]` | Tell a random story now, or story number n |
| `/campfire stop` | Stop the story in progress |
| `/campfire list` | List all the stories |
| `/campfire on` / `off` | Turn automatic stories on or off |
| `/campfire channel AUTO, SELF, PARTY, RAID, GUILD or EMOTE` | Choose who hears it (AUTO is party when grouped, otherwise just you) |
| `/campfire trigger BUFF, SIT or ANY` | Choose what starts a story (default BUFF) |
| `/campfire cooldown <seconds>` | Time between automatic stories (default 3600) |
| `/campfire status` | Show your settings |

**Why not /say?** Blizzard only lets addons post to /say and /yell inside instances or when you press a key. To share the story with players nearby, use `/campfire channel EMOTE`.

## Write your own tales

Open `Stories.lua` and add a story with a `title` and a list of `lines`. You can use `{player}` and `{zone}` in the text, and they're filled in when the story is told.

## Feedback

Found a bug or have a story idea? Open an issue on [GitHub](https://github.com/ZeroTehRay/campfire-tales-forever/issues).
