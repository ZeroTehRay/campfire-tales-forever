-- Campfire Tales: tells a spooky story when you sit down by the fire.
local ADDON, ns = ...

local PREFIX = "|cffff7f00[Campfire Tales]|r "
local STORY_COLOR = "|cffffd8a0"

local DEFAULTS = {
    enabled   = true,
    channel   = "AUTO",   -- AUTO (party chat in a group, else only you), SELF, PARTY, RAID, GUILD, EMOTE
    trigger   = "BUFF",   -- BUFF (campfire buff gained), SIT (any time you sit), ANY (either)
    cooldown  = 3600,     -- seconds between automatic stories (1 hour, survives /reload and logout)
    lineDelay = 4,        -- seconds between lines when there is no buff to pace by
    storyLength  = 60,    -- seconds a buff-started story lasts if the buff has no timer
    buffSpellIds = { 1229739 }, -- campfire buff that starts a story
}
local DB_VERSION = 5

local VALID_CHANNELS = { AUTO = true, SELF = true, PARTY = true, RAID = true, GUILD = true, EMOTE = true }
local VALID_TRIGGERS = { SIT = true, BUFF = true, ANY = true }

local db
local isSitting     = false
local hadFireBuff   = false
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
    -- v2: start on spell 7353 and post to party. Older saves kept "ANY"/"SELF".
    if (db.version or 1) < 2 then
        db.trigger = "BUFF"
        db.channel = "AUTO"
        db.buffNames = nil
    end
    -- v3: trigger spell changed from 7353 to 1289723.
    if (db.version or 1) < 3 then
        db.buffSpellIds = { 1289723 }
    end
    -- v4: corrected trigger spell ID to 1229739.
    if (db.version or 1) < 4 then
        db.buffSpellIds = { 1229739 }
    end
    -- v5: one automatic story per hour.
    if (db.version or 1) < 5 then
        db.cooldown = 3600
    end
    db.version = DB_VERSION
end

---------------------------------------------------------------------------
-- Aura helpers
-- WoW Forever marks most auras "secret": scanning them by index from an addon
-- throws "Auras cannot be accessed when secret". Every aura call is wrapped in
-- pcall, and we ask for our spell IDs directly instead of scanning.
---------------------------------------------------------------------------
local IsSecret = issecretvalue or function() return false end
local lastAuraError -- shown by /campfire buffs

local function SafeAura(fn, ...)
    if not fn then return nil end
    local ok, result = pcall(fn, ...)
    if not ok then lastAuraError = tostring(result); return nil end
    return result
end

-- Returns name, spellId, duration, expirationTime of the player's buff #i,
-- or false if the game won't let us read it.
local function GetBuffInfo(i)
    if C_UnitAuras and C_UnitAuras.GetBuffDataByIndex then
        local ok, data = pcall(C_UnitAuras.GetBuffDataByIndex, "player", i)
        if not ok then lastAuraError = tostring(data); return false end
        if not data then return nil end
        return data.name, data.spellId, data.duration, data.expirationTime
    end
    local ok, name, _, _, _, duration, expirationTime, _, _, _, spellId = pcall(UnitBuff, "player", i)
    if not ok then lastAuraError = tostring(name); return false end
    return name, spellId, duration, expirationTime
end

local function IsCampfireBuff(spellId)
    if spellId == nil or IsSecret(spellId) then return false end
    for _, id in ipairs(db.buffSpellIds) do
        if id == spellId then return true end
    end
    return false
end

local function CleanExpiration(t)
    if t == nil or IsSecret(t) then return 0 end
    return t
end

-- Returns the campfire buff's expiration time (0 if unknown), or nil if not found.
local function FindCampfireBuff()
    -- 1) Ask for each spell ID directly (works even when auras are secret).
    if C_UnitAuras then
        for _, id in ipairs(db.buffSpellIds) do
            local data = SafeAura(C_UnitAuras.GetPlayerAuraBySpellID, id)
            if data then return CleanExpiration(data.expirationTime) end
        end
    end
    -- 2) Fall back to scanning helpful auras, stopping at the first blocked one.
    for i = 1, 40 do
        local name, spellId, _, expirationTime = GetBuffInfo(i)
        if not name then return nil end
        if IsCampfireBuff(spellId) then return CleanExpiration(expirationTime) end
    end
    return nil
end

local function HasCampfireBuff()
    return FindCampfireBuff() ~= nil
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
    if ch == "AUTO" then return IsInGroup() and "PARTY" or "SELF" end
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

-- duration (optional): spread the story evenly over this many seconds.
local function TellStory(story, force, duration)
    if telling then
        if force then StopStory() else return end
    end
    story = story or NextStory()
    if not story then return end

    local channel = ResolveChannel()
    local lines = { "~ " .. Fill(story.title) .. " ~" }
    for _, l in ipairs(story.lines) do lines[#lines + 1] = Fill(l) end

    if not force then db.lastStoryAt = time() end -- /campfire tell doesn't use up the hour
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

    local delay = db.lineDelay
    if duration and #lines > 1 then
        -- First line now, last line a couple of seconds before the buff runs out.
        delay = math.max(1, (duration - 2) / (#lines - 1))
    end

    Step()
    if telling then
        telling.ticker = C_Timer.NewTicker(delay, Step)
    end
end

---------------------------------------------------------------------------
-- Triggering
---------------------------------------------------------------------------
local function CanAutoTell()
    if not db.enabled or telling then return false end
    if InCombatLockdown() or UnitIsDeadOrGhost("player") then return false end
    return (time() - (db.lastStoryAt or 0)) >= db.cooldown
end

local function OnSat()
    if db.trigger == "BUFF" then return end
    -- Short delay so a quick sit/stand (or a misdetected toggle) doesn't fire.
    C_Timer.After(1.5, function()
        if isSitting and CanAutoTell() then TellStory() end
    end)
end

local function OnFireBuffGained(expirationTime)
    if db.trigger == "SIT" then return end
    if not CanAutoTell() then return end
    local remaining = (expirationTime and expirationTime > 0) and (expirationTime - GetTime()) or 0
    if remaining < 5 then remaining = db.storyLength end
    TellStory(nil, false, remaining)
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
frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")

frame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
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
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- If the ID in the list is the spell you cast (not the buff), start on the cast.
        if db and IsCampfireBuff(arg3) and not hadFireBuff then OnFireBuffGained(nil) end
    elseif event == "UNIT_AURA" then
        if not db then return end
        local expirationTime = FindCampfireBuff()
        local has = expirationTime ~= nil
        if has and not hadFireBuff then OnFireBuffGained(expirationTime) end
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
    print("  /campfire channel AUTO|SELF|PARTY|RAID|GUILD|EMOTE (AUTO = party chat when grouped)")
    print("  /campfire trigger SIT|BUFF|ANY - what starts a story")
    print("  /campfire cooldown <seconds> | delay <seconds>")
    print("  /campfire buffs - show your current buffs and their spell IDs")
    print("  /campfire addbuff <spell ID> | clearbuffs - set which buffs start a story")
    print("  /campfire status")
end

local function Status()
    Print(("enabled=%s  channel=%s  trigger=%s  cooldown=%ds  delay=%ss"):format(
        tostring(db.enabled), db.channel, db.trigger, db.cooldown, db.lineDelay))
    local wait = db.cooldown - (time() - (db.lastStoryAt or 0))
    print("  next automatic story: " .. (wait > 0 and ("in %d min"):format(math.ceil(wait / 60)) or "ready"))
    print("  campfire buff spell IDs: " .. table.concat(db.buffSpellIds, ", ") .. "  (telling to " .. ResolveChannel() .. ")")
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
        if not VALID_CHANNELS[ch] then return Print("channel must be AUTO, SELF, PARTY, RAID, GUILD or EMOTE") end
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
        lastAuraError = nil
        Print("campfire buff (" .. table.concat(db.buffSpellIds, ", ") .. "): " ..
            (HasCampfireBuff() and "|cff00ff00found|r" or "|cffff4040not found|r"))
        Print("your current buffs:")
        for i = 1, 40 do
            local name, spellId, duration, expirationTime = GetBuffInfo(i)
            if name == false then print("  (the game is hiding the rest of your buffs from addons)"); break end
            if not name then break end
            if IsSecret(name) then name = "(hidden)" end
            local exp = CleanExpiration(expirationTime)
            local left = exp > 0 and ("  %ds left"):format(exp - GetTime()) or ""
            print(("  %s (spell %s)%s%s"):format(name, IsSecret(spellId) and "hidden" or tostring(spellId), left,
                IsCampfireBuff(spellId) and "  |cff00ff00<- campfire|r" or ""))
        end
        if lastAuraError then print("  last aura error: " .. lastAuraError) end
    elseif cmd == "addbuff" then
        local id = tonumber(rest)
        if not id then return Print("usage: /campfire addbuff <spell ID>") end
        table.insert(db.buffSpellIds, id)
        Print("now matching spell IDs: " .. table.concat(db.buffSpellIds, ", "))
    elseif cmd == "clearbuffs" then
        db.buffSpellIds = {}
        Print("campfire buff matches cleared")
    elseif cmd == "status" then
        Status()
    else
        Help()
    end
end
