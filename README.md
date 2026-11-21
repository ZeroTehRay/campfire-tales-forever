# Campfire Tales

A World of Warcraft Forever addon that tells a spooky campfire story when you sit down by the fire.

## Install
Copy the `CampfireTales` folder into `World of Warcraft/_forever_/Interface/AddOns/`, then restart or `/reload`.

If the addon shows as "out of date", either tick **Load out of date AddOns** or change `## Interface:` in `CampfireTales.toc` to your client's version (`/dump select(4, GetBuildInfo())` prints it).

## How it detects sitting
- Pressing the **Sit/Stand** key (default `X`), or typing `/sit`.
- Gaining a **campfire buff**. The match is on buff names containing `campfire` or `cozy fire`. If the new buff has another name, sit at a fire, type `/campfire buffs`, then `/campfire addbuff <part of name>`.
- Moving, jumping, casting, or entering combat counts as standing up. Combat also stops the story.

## Commands (`/campfire` or `/tales`)
| Command | What it does |
|---|---|
| `/campfire tell [n]` | Tell a random story now, or story number n |
| `/campfire stop` | Stop the story in progress |
| `/campfire list` | List the stories |
| `/campfire on` / `off` | Turn automatic stories on or off |
| `/campfire channel SELF\|PARTY\|RAID\|GUILD\|EMOTE` | Choose who hears the story (default SELF, which only you see) |
| `/campfire trigger SIT\|BUFF\|ANY` | Choose what starts a story (default ANY) |
| `/campfire cooldown <sec>` | Minimum time between automatic stories (default 300) |
| `/campfire delay <sec>` | Pause between lines (default 4) |
| `/campfire status` | Show the current settings |

**About SAY and YELL:** Blizzard blocks addons from posting to `/say` and `/yell` outside instances unless you press a key. A story is spread over several timed lines, so those channels can't be used. To have players near you see it, use `EMOTE`.

## Adding stories
Edit `Stories.lua`. Each entry has a `title` and a `lines` list. You can use `{player}` and `{zone}` in the text.
