# Campfire Tales

A World of Warcraft Forever addon that tells a spooky campfire story when you sit down by the fire.

## Install
Copy the `CampfireTales` folder into `World of Warcraft/_forever_/Interface/AddOns/`, then restart or `/reload`.

If the addon shows as "out of date", either tick **Load out of date AddOns** or change `## Interface:` in `CampfireTales.toc` to your client's version (`/dump select(4, GetBuildInfo())` prints it).

## When a story starts
- By default, when you gain the campfire buff with spell ID **1229739**. The story is spread evenly over the time left on that buff (about 1 minute).
- In a party, the story goes to party chat. Solo, only you see it. (`/campfire channel AUTO`, the default.)
- Want sitting to start it as well? `/campfire trigger ANY` (or `SIT` for sitting only). Sit-started stories use `/campfire delay` between lines.
- To match another buff, find its spell ID with `/campfire buffs`, then `/campfire addbuff <spell ID>`.
- Combat stops the story.

## Commands (`/campfire` or `/tales`)
| Command | What it does |
|---|---|
| `/campfire tell [n]` | Tell a random story now, or story number n |
| `/campfire stop` | Stop the story in progress |
| `/campfire list` | List the stories |
| `/campfire on` / `off` | Turn automatic stories on or off |
| `/campfire channel AUTO\|SELF\|PARTY\|RAID\|GUILD\|EMOTE` | Choose who hears the story (default AUTO: party chat when grouped, otherwise only you) |
| `/campfire trigger BUFF\|SIT\|ANY` | Choose what starts a story (default BUFF) |
| `/campfire cooldown <sec>` | Minimum time between automatic stories (default 3600, one hour; kept across /reload and logout) |
| `/campfire delay <sec>` | Pause between lines for stories not started by the buff (default 4) |
| `/campfire buffs` | List your buffs with their spell IDs |
| `/campfire status` | Show the current settings |

**About SAY and YELL:** Blizzard blocks addons from posting to `/say` and `/yell` outside instances unless you press a key. A story is spread over several timed lines, so those channels can't be used. To have players near you see it, use `EMOTE`.

## Adding stories
Edit `Stories.lua`. Each entry has a `title` and a `lines` list. You can use `{player}` and `{zone}` in the text.
