-- Campfire Tales: tells a spooky story when you sit down by the fire.
local ADDON, ns = ...

local PREFIX = "|cffff7f00[Campfire Tales]|r "
local STORY_COLOR = "|cffffd8a0"

local DEFAULTS = {
    enabled   = true,
    channel   = "SELF",   -- SELF, PARTY, RAID, GUILD, EMOTE
    trigger   = "ANY",    -- SIT (any time you sit), BUFF (campfire buff gained), ANY (either)
    cooldown  = 300,      -- seconds between stories
    lineDelay = 4,        -- seconds between lines
    buffNames = { "campfire", "cozy fire" }, -- case-insensitive substrings of the campfire buff
}

local VALID_CHANNELS = { SELF = true, PARTY = true, RAID = true, GUILD = true, EMOTE = true }
local VALID_TRIGGERS = { SIT = true, BUFF = true, ANY = true }

local db
local isSitting     = false
local hadFireBuff   = false
local lastStoryTime = -math.huge
local telling       = nil   -- { lines = {...}, index = n, ticker = t }
local storyBag      = {}

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. msg)
end

---------------------------------------------------------------------------
-- Saved variables
---------------------------------------------------------------------------
local function InitDB()
    CampfireTalesDB = CampfireTalesDB or {}
    db = CampfireTalesDB
    for k, v in pairs(DEFAULTS) do
        if db[k] == nil then
            if type(v) == "table" then
                local copy = {}
                for i, x in ipairs(v) do copy[i] = x end
                db[k] = copy
            else
                db[k] = v
            end
        end
    end
end

---------------------------------------------------------------------------
-- Aura helpers (works with both old UnitBuff and newer C_UnitAuras APIs)
---------------------------------------------------------------------------
local function GetBuffName(i)
    if C_UnitAuras and C_UnitAuras.GetBuffDataByIndex then
        local data = C_UnitAuras.GetBuffDataByIndex("player", i)
        return data and data.name
    end
    return (UnitBuff("player", i))
end

local function IsCampfireBuff(name)
    local lower = name:lower()
    for _, pattern in ipairs(db.buffNames) do
        if lower:find(pattern:lower(), 1, true) then return true end
    end
    return false
end

local function HasCampfireBuff()
    for i = 1, 40 do
        local name = GetBuffName(i)
        if not name then return false end
        if IsCampfireBuff(name) then return true end
    end
    return false
end

---------------------------------------------------------------------------
-- Story selection & output
---------------------------------------------------------------------------
local function NextStory()
    local stories = ns.Stories
    if #storyBag == 0 then
        for i = 1, #stories do storyBag[i] = i end
        for i = #storyBag, 2, -1 do       -- shuffle so we don't repeat until all are told
            local j = math.random(i)
            storyBag[i], storyBag[j] = storyBag[j], storyBag[i]
        end
    end
    return stories[table.remove(storyBag)]
end

local function Fill(text)
    text = text:gsub("{player}", UnitName("player") or "traveler")
    text = text:gsub("{zone}", GetZoneText() or "these lands")
    if #text > 250 then text = text:sub(1, 247) .. "..." end
    return text
end

local function ResolveChannel()
    local ch = db.channel
    if ch == "PARTY" and not IsInGroup() then return "SELF" end
    if ch == "RAID" and not IsInRaid() then
        return IsInGroup() and "PARTY" or "SELF"
    end
    if ch == "GUILD" and not IsInGuild() then return "SELF" end
    return ch
end

local function Say(text, channel, isFirst)
    if channel == "SELF" then
        DEFAULT_CHAT_FRAME:AddMessage(STORY_COLOR .. text .. "|r")
    elseif channel == "EMOTE" then
        -- Emotes are prefixed with your name, so phrase them as narration.
        local lead = isFirst and "leans toward the fire and begins a tale: " or "continues, quietly: "
        SendChatMessage(lead .. text, "EMOTE")
    else
        SendChatMessage(text, channel)
    end
end

local function StopStory(reason)
    if not telling then return end
    if telling.ticker then telling.ticker:Cancel() end
    telling = nil
    if reason then Print(reason) end
end

local function TellStory(story, force)
    if telling then
        if force then StopStory() else return end
    end
    story = story or NextStory()
    if not story then return end

    local channel = ResolveChannel()
    local lines = { "~ " .. Fill(story.title) .. " ~" }
    for _, l in ipairs(story.lines) do lines[#lines + 1] = Fill(l) end

    lastStoryTime = GetTime()
    telling = { lines = lines, index = 1, channel = channel }

    local function Step()
        if not telling then return end
        local line = telling.lines[telling.index]
        if line then
            Say(line, telling.channel, telling.index == 1)
            telling.index = telling.index + 1
        end
        if telling.index > #telling.lines then
            StopStory()
        end
    end

    Step()
    if telling then
        telling.ticker = C_Timer.NewTicker(db.lineDelay, Step)
    end
end

---------------------------------------------------------------------------
-- Triggering
---------------------------------------------------------------------------
local function CanAutoTell()
    if not db.enabled or telling then return false end
    if InCombatLockdown() or UnitIsDeadOrGhost("player") then return false end
    return (GetTime() - lastStoryTime) >= db.cooldown
end

local function OnSat()
    if db.trigger == "BUFF" then return end
    -- Short delay so a quick sit/stand (or a misdetected toggle) doesn't fire.
    C_Timer.After(1.5, function()
        if isSitting and CanAutoTell() then TellStory() end
    end)
end

local function OnFireBuffGained()
    if db.trigger == "SIT" then return end
    if CanAutoTell() then TellStory() end
end

local function MarkStanding()
    isSitting = false
end

-- The X key ("Sit/Stand") binding toggles sitting.
if SitStandOrDescendStart then
    hooksecurefunc("SitStandOrDescendStart", function()
        if IsMounted() or IsSwimming() then return end
        isSitting = not isSitting
        if isSitting then OnSat() end
    end)
end

-- /sit and /stand emotes.
if DoEmote then
    hooksecurefunc("DoEmote", function(token)
        token = token and tostring(token):upper()
        if token == "SIT" then
            if not isSitting then isSitting = true; OnSat() end
        elseif token == "STAND" then
            isSitting = false
        end
    end)
end

-- Anything that makes you stand up resets the sitting state.
if JumpOrAscendStart then hooksecurefunc("JumpOrAscendStart", MarkStanding) end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_STARTED_MOVING")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterUnitEvent("UNIT_AURA", "player")
frame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON then
            InitDB()
            Print("loaded with " .. #ns.Stories .. " tales. Type |cffffff00/campfire|r for options.")
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        isSitting = false
        hadFireBuff = db and HasCampfireBuff() or false
    elseif event == "PLAYER_STARTED_MOVING" or event == "UNIT_SPELLCAST_START" then
        MarkStanding()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_DEAD" then
        MarkStanding()
        StopStory("The tale is cut short... something stirs in the dark!")
    elseif event == "UNIT_AURA" then
        if not db then return end
        local has = HasCampfireBuff()
        if has and not hadFireBuff then OnFireBuffGained() end
        hadFireBuff = has
    end
end)

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
local function Help()
    Print("commands:")
    print("  /campfire tell [n] - tell a story now (optionally story #n)")
    print("  /campfire stop - stop the current story")
    print("  /campfire list - list all stories")
    print("  /campfire on | off - enable/disable automatic stories")
    print("  /campfire channel SELF|PARTY|RAID|GUILD|EMOTE")
    print("  /campfire trigger SIT|BUFF|ANY - what starts a story")
    print("  /campfire cooldown <seconds> | delay <seconds>")
    print("  /campfire buffs - show your current buffs (find the campfire buff name)")
    print("  /campfire addbuff <text> | clearbuffs - set campfire buff name matches")
    print("  /campfire status")
end

local function Status()
    Print(("enabled=%s  channel=%s  trigger=%s  cooldown=%ds  delay=%ss"):format(
        tostring(db.enabled), db.channel, db.trigger, db.cooldown, db.lineDelay))
    print("  campfire buff matches: " .. table.concat(db.buffNames, ", "))
    print("  sitting=" .. tostring(isSitting) .. "  campfire buff=" .. tostring(HasCampfireBuff()))
end

SLASH_CAMPFIRETALES1 = "/campfire"
SLASH_CAMPFIRETALES2 = "/tales"
SlashCmdList.CAMPFIRETALES = function(msg)
    local cmd, rest = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = cmd:lower()

    if cmd == "" or cmd == "help" then
        Help()
    elseif cmd == "tell" or cmd == "test" then
        local n = tonumber(rest)
        local story = n and ns.Stories[n]
        if n and not story then return Print("No story #" .. n) end
        TellStory(story, true)
    elseif cmd == "stop" then
        StopStory("The fire crackles. The tale goes untold.")
    elseif cmd == "list" then
        for i, s in ipairs(ns.Stories) do print(("  %d. %s"):format(i, s.title)) end
    elseif cmd == "on" or cmd == "off" then
        db.enabled = (cmd == "on")
        Print("automatic stories " .. (db.enabled and "enabled" or "disabled"))
    elseif cmd == "channel" then
        local ch = rest:upper()
        if not VALID_CHANNELS[ch] then return Print("channel must be SELF, PARTY, RAID, GUILD or EMOTE") end
        db.channel = ch
        Print("stories will be told to " .. ch)
    elseif cmd == "trigger" then
        local t = rest:upper()
        if not VALID_TRIGGERS[t] then return Print("trigger must be SIT, BUFF or ANY") end
        db.trigger = t
        Print("trigger set to " .. t)
    elseif cmd == "cooldown" then
        local n = tonumber(rest)
        if not n or n < 0 then return Print("usage: /campfire cooldown <seconds>") end
        db.cooldown = n
        Print("cooldown set to " .. n .. "s")
    elseif cmd == "delay" then
        local n = tonumber(rest)
        if not n or n < 1 then return Print("usage: /campfire delay <seconds> (min 1)") end
        db.lineDelay = n
        Print("line delay set to " .. n .. "s")
    elseif cmd == "buffs" then
        Print("your current buffs:")
        for i = 1, 40 do
            local name = GetBuffName(i)
            if not name then break end
            print(("  %s%s"):format(name, IsCampfireBuff(name) and "  |cff00ff00<- campfire|r" or ""))
        end
    elseif cmd == "addbuff" then
        if rest == "" then return Print("usage: /campfire addbuff <part of buff name>") end
        table.insert(db.buffNames, rest:lower())
        Print("now matching: " .. table.concat(db.buffNames, ", "))
    elseif cmd == "clearbuffs" then
        db.buffNames = {}
        Print("campfire buff matches cleared")
    elseif cmd == "status" then
        Status()
    else
        Help()
    end
end
