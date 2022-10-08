-- Credits: Vika, Cladhaire, Tekkub, Aviana
--[[
# Element: Tags

Provides a system for text-based display of information by binding a tag string to a font string widget which in turn is
tied to a unit frame.

## Widget

A FontString to hold a tag string. Unlike other elements, this widget must not have a preset name.

## Notes

A `Tag` is a Lua string consisting of a function name surrounded by square brackets. The tag will be replaced by the
output of the function and displayed as text on the font string widget with that the tag has been registered. Literals
can be pre- or appended by separating them with a `>` before or `<` after the function name. The literals will be only
displayed when the function returns a non-nil value. I.e. `"[perhp<%]"` will display the current health as a percentage
of the maximum health followed by the % sign.

A `Tag String` is a Lua string consisting of one or multiple tags with optional literals between them. Each tag will be
updated individually and the output will follow the tags order. Literals will be displayed in the output string
regardless of whether the surrounding tag functions return a value. I.e. `"[curhp]/[maxhp]"` will resolve to something
like `2453/5000`.

A `Tag Function` is used to replace a single tag in a tag string by its output. A tag function receives only two
arguments - the unit and the realUnit of the unit frame used to register the tag (see Options for further details). The
tag function is called when the unit frame is shown or when a specified event has fired. It the tag is registered on an
eventless frame (i.e. one holding the unit "targettarget"), then the tag function is called in a set time interval.

A number of built-in tag functions exist. The layout can also define its own tag functions by adding them to the
`oUF.Tags.Methods` table. The events upon which the function will be called are specified in a white-space separated
list added to the `oUF.Tags.Events` table. Should an event fire without unit information, then it should also be listed
in the `oUF.Tags.SharedEvents` table as follows: `oUF.Tags.SharedEvents.EVENT_NAME = true`.

## Options

.overrideUnit    - if specified on the font string widget, the frame's realUnit will be passed as the second argument to
                   every tag function whose name is contained in the relevant tag string. Otherwise the second argument
                   is always nil (boolean)
.frequentUpdates - defines how often the correspondig tag function(s) should be called. This will override the events for
                   the tag(s), if any. If the value is a number, it is taken as a time interval in seconds. If the value
                   is a boolean, the time interval is set to 0.5 seconds (number or boolean)

## Attributes

.parent - the unit frame on which the tag has been registered

## Examples

    -- define the tag function
    oUF.Tags.Methods['mylayout:threatname'] = function(unit, realUnit)
        local color = _TAGS['threatcolor'](unit)
        local name = _TAGS['name'](unit, realUnit)
        return string.format('%s%s|r', color, name)
    end

    -- add the events
    oUF.Tags.Events['mylayout:threatname'] = 'UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE'

    -- create the text widget
    local info = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    info:SetPoint('LEFT')

    -- register the tag on the text widget with oUF
    self:Tag(info, '[mylayout:threatname]')
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private
local LHC = LibStub("LibHealComm-4.0")
local LT = LibStub("LibTargeted")

local _PATTERN = '%[..-%]+'

local function abbreviateName(text)
	return string.sub(text, 1, 1) .. ". "
end

local _ENV = {
	Hex = function(r, g, b)
		if(type(r) == 'table') then
			if(r.r) then
				r, g, b = r.r, r.g, r.b
			else
				r, g, b = unpack(r)
			end
		end

		-- ElvUI block
		if not r or type(r) == 'string' then --wtf?
			return '|cffFFFFFF'
		end
		-- end block

		return format('|cff%02x%02x%02x', r * 255, g * 255, b * 255)
	end,
	afkStatus = {},
	feignDeath = GetSpellInfo(5384),
	feigncheck = function(unit)
		if select(2,UnitClass(unit)) == "HUNTER" then
			for i=1,32 do
				local spell = select(10,UnitBuff(unit,i))
				if not spell then
					return
				elseif spell == 5384 then
					return true
				end
			end
		end
	end,
	DruidForms = {
		[24858] = GetSpellInfo(24858), --moonkin
		[1066] = GetSpellInfo(1066), -- seal
		[783] = GetSpellInfo(783), -- travel
		[768] = GetSpellInfo(768), -- cat
		[5487] = GetSpellInfo(5487), -- bear
		[9634] = GetSpellInfo(9634), -- dire bear
	},
	formatTime = function(seconds)
		if seconds >= 3600 then
			return string.format("%dh", seconds / 3600)
		elseif seconds >= 60 then
			return string.format("%dm", seconds / 60)
		end
		return string.format("%ds", seconds)
	end,
	abbrevCache = setmetatable({}, {
		__index = function(tbl, val)
			val = string.gsub(val, "([^%s]+) ", abbreviateName)
			rawset(tbl, val, val)
			return val
	end}),
	RARE = strmatch(GARRISON_MISSION_RARE,"%a*"),
	GHOST = GetSpellInfo(8326),
	LHC = LHC,
	LT = LT,
	GetHealTimeFrame = function() return oUF.TagsWithHealTimeFrame or 4 end,
	GetShowHots = function() if oUF.TagsWithHealDisableHots then return LHC.DIRECT_HEALS else return LHC.ALL_HEALS end end,
	DruidPower = function() if oUF.bearEnergy and UnitPowerType('player') == 1 then return UnitPower('player', 3) end return UnitPower('player', 0) end,
	DruidPowerMax = function() if oUF.bearEnergy and UnitPowerType('player') == 1 then return UnitPowerMax('player', 3) end return UnitPowerMax('player', 0) end,
}
_ENV.ColorGradient = function(...)
	return _ENV._FRAME:ColorGradient(...)
end

local _PROXY = setmetatable(_ENV, {__index = _G})

local tagStrings = {
	["afk"] = [[function(unit)
		return UnitIsAFK(unit) and AFK
	end]],

	["nameafk"] = [[function(unit)
		return UnitIsAFK(unit) and AFK or UnitName(unit)
	end]],

	["afktime"] = [[function(unit)
		if( not UnitIsConnected(unit) ) then return end
		local status = UnitIsAFK(unit) and AFK..":%s" or UnitIsDND(unit) and DND..":%s"
		if( status ) then
			afkStatus[unit] = afkStatus[unit] or GetTime()
			return string.format(status, formatTime(GetTime() - afkStatus[unit]))
		end
		afkStatus[unit] = nil
	end]],

	["numtargeting"] = [[function(unit)
		if UnitInRaid("player") then
			local count = 0
			for i = 1, GetNumGroupMembers() do
				if UnitIsUnit(unit, ("raid"..i.."target")) then
					count = count + 1
				end
			end
			return tostring(count)
		else
			local count
			if UnitIsUnit(unit, "target") then
				count = 1
			else
				count = 0
			end
			for i=1, GetNumSubgroupMembers() do
				if UnitIsUnit(unit, ("party"..i.."target")) then
					count = count + 1
				end
			end
			return tostring(count)
		end
	end]],

	["cnumtargeting"] = [[function(unit)
		local count = 0
		if UnitInRaid("player") then
			for i = 1, GetNumGroupMembers() do
				if UnitIsUnit(unit, ("raid"..i.."target")) then
					count = count + 1
				end
			end
		else
			if UnitIsUnit(unit, "target") then
				count = 1
			else
				count = 0
			end
			for i=1, GetNumSubgroupMembers() do
				if UnitIsUnit(unit, ("party"..i.."target")) then
					count = count + 1
				end
			end
		end
		if count == 0 then
			return Hex(1,0.5,0.5)..count.."|r"
		elseif (count > 5) then
			return Hex(0.5,1,0.5)..count.."|r"
		else
			return Hex(0.5,0.5,1)..count.."|r"
		end
	end]],

	["grpnum"] = [[function(unit)
		return strmatch(unit, "(%d+)") or 0
	end]],

	["happiness"] = [[function(unit)
		if not UnitIsUnit(unit,"pet") or select(2,UnitClass("player")) ~= "HUNTER" then
			return
		end
		if GetPetHappiness() == 1 then
			return PET_HAPPINESS1
		elseif GetPetHappiness() == 2 then
			return PET_HAPPINESS2
		else
			return PET_HAPPINESS3
		end
	end]],

	["combat"] = [[function(unit)
		if UnitAffectingCombat(unit) then
			return "("..COMBAT..")"
		end
	end]],

	["combatcolor"] = [[function(unit)
		if UnitAffectingCombat(unit) then
			return Hex(1,0,0)
		end
	end]],

	["range"] = [[function(unit)
		if UnitIsUnit("player", unit) then
			return "0"
		elseif CheckInteractDistance(unit, 3) then
			return "0-10"
		elseif CheckInteractDistance(unit, 4) then
			return "10-30"
		elseif UnitInRange(unit) then
			return "30-40"
		else
			return "~"
		end
	end]],

	["race"] = [[function(unit)
		local race = UnitRace(unit)
		if race then
			return race
		end
	end]],

	["rank"] = [[function(unit)
		local pvpname = UnitPVPName(unit)
		local name = UnitName(unit)
		if name and pvpname and name ~= pvpname then
			pvpname = string.gsub(pvpname, " "..name, "")
			return pvpname
		end
	end]],

	["numrank"] = [[function(unit)
		local rank = UnitPVPRank(unit)
		if rank == 0 then
			return
		end
		return rank-4
	end]],

	["creature"] = [[function(unit)
		local creature = UnitCreatureFamily(unit)
		if creature then
			return creature
		end
	end]],

	["faction"] = [[function(unit)
		local _,faction = UnitFactionGroup(unit)
		if faction then
			return faction
		end
	end]],

	["sex"] = [[function(unit)
		local sex = UnitSex(unit)
		if sex == 1 then
			return
		elseif sex == 2 then
			return MALE
		else
			return FEMALE
		end
	end]],

	["nocolor"] = [[function(unit) return "|r" end]],

	["druidform"] = [[function(unit)
		for i=1,32 do
			local form = select(10, UnitAura(unit, i, "HELPFUL"))
			if DruidForms[form] then
				return DruidForms[form]
			end
		end
		local _,class = UnitClass(unit)
		if class == "DRUID" then
			if UnitPowerType(unit) == 1 then
				return DruidForms[768]
			elseif UnitPowerType(unit) == 3 then
				return DruidForms[5487]
			end
		end
	end]],

	["guild"] = [[function(unit) return GetGuildInfo(unit) or "" end]],

	["guildrank"] = [[function(unit)
		return select(2,GetGuildInfo(unit)) or ""
	end]],

	["incheal"] = [[function(unit)
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local heal = LHC:GetHealAmount(UnitGUID(unit), GetShowHots(), GetTime() + GetHealTimeFrame()) or 0
		if heal > 0 then
			return math.floor(heal * mod)
		end
	end]],

	["directheal"] = [[function(unit)
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local heal = LHC:GetHealAmount(UnitGUID(unit), LHC.DIRECT_HEALS, GetTime() + GetHealTimeFrame()) or 0
		if heal > 0 then
			return math.floor(heal * mod)
		end
	end]],

	["incownheal"] = [[function(unit)
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local heal = LHC:GetHealAmount(UnitGUID(unit), LHC.DIRECT_HEALS, GetTime() + GetHealTimeFrame(), UnitGUID("player")) or 0
		if heal > 0 then
			return math.floor(heal * mod)
		end
	end]],

	["incpreheal"] = [[function(unit)
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local preHeal = 0
		local myHeal = LHC:GetHealAmount(UnitGUID(unit), LHC.DIRECT_HEALS, GetTime() + GetHealTimeFrame(), myGUID) or 0
		-- We can only scout up to 2 direct heals that would land before ours but thats good enough for most cases
		local healTime, healFrom, healAmount = LHC:GetNextHealAmount(UnitGUID(unit), LHC.DIRECT_HEALS, GetTime() + GetHealTimeFrame())
		if healFrom and healFrom ~= UnitGUID("player") and myHeal > 0 then
			preHeal = healAmount
			healTime, healFrom, healAmount = LHC:GetNextHealAmount(UnitGUID(unit), LHC.DIRECT_HEALS, GetTime() + GetHealTimeFrame(), healFrom)
			if healFrom and healFrom ~= UnitGUID("player") then
				preHeal = preHeal + healAmount
			end
		end
		if preHeal > 0 then
			return math.floor(preHeal * mod)
		end
	end]],

	["incafterheal"] = [[function(unit)
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local preHeal = 0
		local totalHeal = LHC:GetHealAmount(UnitGUID(unit), LHC.DIRECT_HEALS, GetTime() + GetHealTimeFrame()) or 0
		local myHeal = LHC:GetHealAmount(UnitGUID(unit), LHC.DIRECT_HEALS, GetTime() + GetHealTimeFrame(), myGUID) or 0
		-- We can only scout up to 2 direct heals that would land before ours but thats good enough for most cases
		local healTime, healFrom, healAmount = LHC:GetNextHealAmount(UnitGUID(unit), LHC.DIRECT_HEALS, GetTime() + GetHealTimeFrame())
		if healFrom and healFrom ~= UnitGUID("player") and myHeal > 0 then
			preHeal = healAmount
			healTime, healFrom, healAmount = LHC:GetNextHealAmount(UnitGUID(unit), LHC.DIRECT_HEALS, GetTime() + GetHealTimeFrame(), healFrom)
			if healFrom and healFrom ~= UnitGUID("player") then
				preHeal = preHeal + healAmount
			end
		end
		local afterHeal = totalHeal - preHeal - myHeal
		if afterHeal > 0 then
			return math.floor(afterHeal * mod)
		end
	end]],

	["hotheal"] = [[function(unit)
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local heal = LHC:GetHealAmount(UnitGUID(unit), bit.bor(LHC.HOT_HEALS, LHC.CHANNEL_HEALS, LHC.BOMB_HEALS), GetTime() + GetHealTimeFrame()) or 0
		if heal > 0 then
			return math.floor(heal * mod)
		end
	end]],

	["effheal"] = [[function(unit)
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local heal = LHC:GetHealAmount(UnitGUID(unit), LHC.DIRECT_HEALS, GetTime() + GetHealTimeFrame()) or 0
		heal = heal * mod
		local healthmissing = UnitHealthMax(unit) - UnitHealth(unit)
		heal = math.min(healthmissing, heal)
		if heal > 0 then
			return math.floor(heal)
		end
	end]],

	["overheal"] = [[function(unit)
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local heal = LHC:GetHealAmount(UnitGUID(unit), LHC.DIRECT_HEALS, GetTime() + GetHealTimeFrame()) or 0
		heal = heal * mod
		local healthmissing = UnitHealthMax(unit) - UnitHealth(unit)
		heal = heal - healthmissing
		if heal > 0 then
			return math.floor(heal * mod)
		end
	end]],

	["buffcount"] = [[function(unit)
		local num = 0
		while true do
			if UnitAura(unit, num + 1, "HELPFUL") then
				num = num + 1
			else
				return num
			end
		end
	end]],

	["numheals"] = [[function(unit) return LHC:GetNumHeals(UnitGUID(unit), GetTime() + GetHealTimeFrame()) end]],

	["pvp"] = [[function(unit) return UnitIsPVP(unit) and PVP or "" end]],

	["smarthealth"] = [[function(unit)
		local hp
		local maxhp
		hp = UnitHealth(unit)
		maxhp = UnitHealthMax(unit)
		if UnitIsGhost(unit) then
			return GHOST
		elseif not UnitIsConnected(unit) then
			return FRIENDS_LIST_OFFLINE
		elseif hp < 1 then
			if feigncheck(unit) then
				return feignDeath
			else
				return DEAD
			end
		end
		return hp.."/"..maxhp
	end]],

	["smarthealthp"] = [[function(unit)
		local hp = UnitHealth(unit)
		local maxhp = UnitHealthMax(unit)
		if UnitIsGhost(unit) then
			return GHOST
		elseif not UnitIsConnected(unit) then
			return FRIENDS_LIST_OFFLINE
		elseif hp < 1 then
			if feigncheck(unit) then
				return feignDeath
			else
				return DEAD
			end
		end
		return hp.."/"..maxhp.." "..math.ceil((UnitHealth(unit) / UnitHealthMax(unit)) * 100).."%"
	end]],

	["ssmarthealth"] = [[function(unit)
		local hp = UnitHealth(unit)
		local maxhp = UnitHealthMax(unit)
		if hp < 1 then
			if feigncheck(unit) then
				return feignDeath
			else
				return DEAD
			end
		end
		if UnitIsGhost(unit) then
			return GHOST
		elseif not UnitIsConnected(unit) then
			return FRIENDS_LIST_OFFLINE
		end
		if hp > 1000000 then
			hp = (math.floor(hp/10000)/100).."M"
		elseif hp > 1000 then
			hp = (math.floor(hp/100)/10).."K"
		end
		if maxhp > 1000000 then
			maxhp = (math.floor(maxhp/10000)/100).."M"
		elseif maxhp > 1000 then
			maxhp = (math.floor(maxhp/100)/10).."K"
		end
		return hp.."/"..maxhp
	end]],

	["ssmarthealthp"] = [[function(unit)
		local hp = UnitHealth(unit)
		local maxhp = UnitHealthMax(unit)
		if hp < 1 then
			if feigncheck(unit) then
				return feignDeath
			else
				return DEAD
			end
		end
		if UnitIsGhost(unit) then
			return GHOST
		elseif not UnitIsConnected(unit) then
			return FRIENDS_LIST_OFFLINE
		end
		if hp > 1000000 then
			hp = (math.floor(hp/10000)/100).."M"
		elseif hp > 1000 then
			hp = (math.floor(hp/100)/10).."K"
		end
		if maxhp > 1000000 then
			maxhp = (math.floor(maxhp/10000)/100).."M"
		elseif maxhp > 1000 then
			maxhp = (math.floor(maxhp/100)/10).."K"
		end
		return hp.."/"..maxhp.." "..math.ceil((UnitHealth(unit) / UnitHealthMax(unit)) * 100).."%"
	end]],

	["healhp"] = [[function(unit)
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local heal = LHC:GetHealAmount(UnitGUID(unit), GetShowHots(), GetTime() + GetHealTimeFrame()) or 0
		heal = math.floor(heal * mod)
		local hp
		hp = UnitHealth(unit)
		if heal > 0 then
			return Hex(0,1,0)..(hp+heal).."|r"
		else
			return hp
		end
	end]],

	["hp"] = [[function(unit)
		return UnitHealth(unit)
	end]],

	["shp"] = [[function(unit)
		local hp = UnitHealth(unit)
		if hp > 1000000 then
			return (math.floor(hp/10000)/100).."M"
		elseif hp > 1000 then
			return (math.floor(hp/100)/10).."K"
		else
			return hp
		end
	end]],

	["sshp"] = [[function(unit)
		local hp
		hp = UnitHealth(unit)
		if hp < 1 then
			if feigncheck(unit) then
				return feignDeath
			else
				return DEAD
			end
		end
		if hp > 1000000 then
			hp = (math.floor(hp/10000)/100).."M"
		elseif hp > 1000 then
			hp = (math.floor(hp/100)/10).."K"
		end
		if UnitIsGhost(unit) then
			return GHOST
		elseif not UnitIsConnected(unit) then
			return FRIENDS_LIST_OFFLINE
		end
		return hp
	end]],

	["maxhp"] = [[function(unit)
		return UnitHealthMax(unit)
	end]],

	["smaxhp"] = [[function(unit)
		local maxhp = UnitHealthMax(unit)
		if maxhp > 1000000 then
			return (math.floor(maxhp/10000)/100).."M"
		elseif maxhp > 1000 then
			return (math.floor(maxhp/100)/10).."K"
		else
			return maxhp
		end
	end]],

	["missinghp"] = [[function(unit)
		local hp,maxhp
		hp = UnitHealth(unit)
		maxhp = UnitHealthMax(unit)
		if maxhp-hp ~= 0 then
			return hp-maxhp
		end
	end]],

	["healmishp"] = [[function(unit)
		local hp,maxhp
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local heal = LHC:GetHealAmount(UnitGUID(unit), GetShowHots(), GetTime() + GetHealTimeFrame()) or 0
		heal = math.floor(heal * mod)
		hp = UnitHealth(unit)
		maxhp = UnitHealthMax(unit)
		local result = hp-maxhp+heal
		if result ~= 0 then
			if heal > 0 then
				return Hex(0,1,0)..result.."|r"
			else
				return result
			end
		end
	end]],

	["perhp"] = [[function(unit)
		local hp,maxhp
		hp = UnitHealth(unit)
		maxhp = UnitHealthMax(unit)
		if maxhp < 1 then
			return 0
		else
			return math.ceil((hp / maxhp) * 100)
		end
	end]],

	["perstatus"] = [[function(unit)
		local hp
		local maxhp
		hp = UnitHealth(unit)
		maxhp = UnitHealthMax(unit)
		if UnitIsGhost(unit) then
			return GHOST
		elseif not UnitIsConnected(unit) then
			return FRIENDS_LIST_OFFLINE
		elseif hp < 1 then
			if feigncheck(unit) then
				return feignDeath
			else
				return DEAD
			end
		else
			if maxhp < 1 then
				return "0%"
			else
				return math.ceil((hp / maxhp) * 100).."%"
			end
		end
	end]],

	["pp"] = [[function(unit) return UnitPower(unit) end]],

	["spp"] = [[function(unit)
		local power = UnitPower(unit)
		if power > 1000000 then
			return (math.floor(power/10000)/100).."M"
		elseif power > 1000 then
			return (math.floor(power/100)/10).."K"
		else
			return power
		end
	end]],

	["maxpp"] = [[function(unit) return UnitPowerMax(unit) end]],

	["smaxpp"] = [[function(unit)
		local maxpower = UnitPowerMax(unit)
		if maxpower > 1000000 then
			return (math.floor(maxpower/10000)/100).."M"
		elseif maxpower > 1000 then
			return (math.floor(maxpower/100)/10).."K"
		else
			return maxpower
		end
	end]],

	["missingpp"] = [[function(unit)
		local mana = UnitPower(unit)
		local manamax = UnitPowerMax(unit)
		if manamax-mana ~= 0 then
			return mana-manamax
		end
	end]],

	["perpp"] = [[function(unit)
		if UnitPowerMax(unit) < 1 then
			return 0
		else
			return math.floor(((UnitPower(unit) / UnitPowerMax(unit)) * 100)+0.5)
		end
	end]],

	["druid:pp"] = [[function(unit)
		if unit == "player" then
			return DruidPower()
		end
	end]],

	["druid:maxpp"] = [[function(unit)
		if unit == "player" then
			return DruidPowerMax()
		end
	end]],

	["druid:missingpp"] = [[function(unit)
		if unit ~= "player" then
			return
		end
		if DruidPowerMax()-DruidPower() == 0 then
			return
		else
			return DruidPower()-DruidPowerMax()
		end
	end]],

	["druid:perpp"] = [[function(unit)
		if unit ~= "player" then
			return
		end
		local mana,manamax = DruidPower(),DruidPowerMax()
		if manamax == 0 then
			return 0
		else
			return math.floor(((mana / manamax) * 100)+0.5)
		end
	end]],

	["level"] = [[function(unit)
		if UnitLevel(unit) == -1 then
			return "??"
		else
			return UnitLevel(unit)
		end
	end]],

	["smartlevel"] = [[function(unit)
		local level = UnitLevel(unit)
		if level == -1 then
			if UnitClassification(unit) == "worldboss" then
				return "??"
			else
				return (UnitLevel("player")+10).."+"
			end
		else
			return level
		end
	end]],

	["levelcolor"] = [[function(unit)
		local level = UnitLevel(unit)
		if level == -1 then
			level = 99
		end
		local color = GetQuestDifficultyColor(level)
		return Hex(color)
	end]],

	["name"] = [[function(unit) return UnitName(unit) or "" end]],

	["shortname"] = [[function(unit, realunit, var)
		local length = tonumber(var) or 3
		return UnitName(unit) and strsub(UnitName(unit),1,math.max(math.min(length, 12), 1)) or ""
	end]],

	["ignore"] = [[function(unit)
		if not UnitIsPlayer(unit) then
			return
		end
		local name = UnitName(unit)
		for i=1, C_FriendList.GetNumIgnores() do
			if name == C_FriendList.GetIgnoreName(i) then
				return IGNORED
			end
		end
	end]],

	["abbrev:name"] = [[function(unit)
		local name = UnitName(unit)
		if not name then
			return
		end
		return string.len(name) > 10 and abbrevCache[name] or name
	end]],

	["server"] = [[function(unit)
		local _,server = UnitName(unit)
		return server or GetRealmName()
	end]],

	["status"] = [[function(unit)
		local hp = UnitHealth(unit)
		if hp < 1 then
			if feigncheck(unit) then
				return feignDeath
			else
				return DEAD
			end
		elseif UnitIsGhost(unit) then
			return GHOST
		elseif not UnitIsConnected(unit) then
			return FRIENDS_LIST_OFFLINE
		end
	end]],

	["cpoints"] = [[function(unit)
		if UnitHasVehicleUI("player") then
			return GetComboPoints("pet", "target")
		else
			return GetComboPoints("player", "target")
		end
	end]],

	["rare"] = [[function(unit)
		local classif = UnitClassification(unit)
		if classif == "rare" or classif == "rareelite" then
			return RARE
		end
	end]],

	["elite"] = [[function(unit)
		local classif = UnitClassification(unit)
		if classif == "elite" or classif == "rareelite" then
			return ELITE
		end
	end]],

	["classification"] = [[function(unit)
		local classif = UnitClassification(unit)
		if classif == "rare" then
			return RARE
		elseif classif == "elite" then
			return ELITE
		elseif classif == "rareelite" then
			return RARE.." "..ELITE
		elseif classif == "worldboss" then
			return BOSS
		end
	end]],

	["shortclassification"] = [[function(unit)
		local classif = UnitClassification(unit)
		if classif == "rare" then
			return "R"
		elseif classif == "elite" then
			return "E"
		elseif classif == "rareelite" then
			return "RE"
		elseif classif == "worldboss" then
			return "BOSS"
		end
	end]],

	["group"] = [[function(unit)
		if UnitInRaid("player") then
			local name = UnitName(unit)
			for i=1, GetNumGroupMembers() do
				local raidName, _, group = GetRaidRosterInfo(i)
				if( raidName == name ) then
					return group
				end
			end
		elseif UnitInParty(unit) and GetNumGroupMembers() > 0 then
			return 1
		end
	end]],

	["threat"] = [[function(unit)
		local status, scaledPercentage
		if UnitCanAssist("player", unit) then
			status, scaledPercentage = select(2, UnitDetailedThreatSituation(unit, "target"))
		else
			status, scaledPercentage = select(2, UnitDetailedThreatSituation("player", unit))
		end
		if status then
			return ceil(scaledPercentage).."%"
		end
	end]],

	["aggrocolor"] = [[function(unit)
		local aggro = (UnitThreatSituation(unit) or 0) > 1
		if aggro then
			return Hex(1,0,0)
		end
	end]],

	["classcolor"] = [[function(unit)
		if not UnitIsPlayer(unit) then
			return Hex(1,1,1)
		end
		local _,class = UnitClass(unit)
		if class then
			return Hex(_COLORS.class[class])
		else
			return Hex(1,1,1)
		end
	end]],

	["class"] = [[function(unit) return UnitClass(unit) or "" end]],

	["smartclass"] = [[function(unit)
		if UnitIsPlayer(unit) then
			return UnitClass(unit) or ""
		else
			return UnitCreatureType(unit) or ""
		end
	end]],

	["reactcolor"] = [[function(unit)
		local reaction = UnitReaction("player",unit)
		if not reaction then
			return
		elseif reaction == 4 then
			return Hex(LUF.db.profile.colors["neutral"])
		elseif reaction < 4 then
			return Hex(LUF.db.profile.colors["hostile"])
		else
			return Hex(LUF.db.profile.colors["friendly"])
		end
	end]],

	["pvpcolor"] = [[function(unit)
		if UnitIsPlayer(unit) then
			if UnitIsPVP(unit) then
				if UnitIsEnemy("player",unit) then
					return Hex(1,0,0)
				else
					return Hex(0,1,0)
				end
			end
		end
		return Hex(1,1,1)
	end]],

	["smart:healmishp"] = [[function(unit)
		if UnitIsGhost(unit) then
			return GHOST
		elseif not UnitIsConnected(unit) then
			return FRIENDS_LIST_OFFLINE
		end
		local hp,maxhp
		hp = UnitHealth(unit)
		maxhp = UnitHealthMax(unit)
		if hp < 1 then
			if feigncheck(unit) then
				return feignDeath
			else
				return DEAD
			end
		end
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local heal = LHC:GetHealAmount(UnitGUID(unit), GetShowHots(), GetTime() + GetHealTimeFrame()) or 0
		heal = math.floor(heal * mod)
		local result = hp-maxhp+heal
		if result == 0 then
			return
		else
			if heal > 0 then
				return Hex(0,1,0)..result.."|r"
			else
				return result
			end
		end
	end]],

	["smartrace"] = [[function(unit)
		local race = UnitRace(unit)
		local ctype = UnitCreatureType(unit)
		if UnitIsPlayer(unit) then
			return race or ""
		else
			return ctype or ""
		end
	end]],

	["civilian"] = [[function(unit)
		if UnitIsCivilian(unit) then
			return "("..DISHONORABLE_KILLS..")"
		end
	end]],

	["loyalty"] = [[function(unit)
		local loyalty = GetPetLoyalty()
		if loyalty then
			return loyalty
		end
	end]],

	["healerhealth"] = [[function(unit)
		if UnitIsGhost(unit) then
			return GHOST
		elseif not UnitIsConnected(unit) then
			return FRIENDS_LIST_OFFLINE
		end
		local hp,maxhp
		hp = UnitHealth(unit)
		maxhp = UnitHealthMax(unit)
		if hp < 1 then
			if feigncheck(unit) then
				return feignDeath
			else
				return DEAD
			end
		end
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local heal = LHC:GetHealAmount(UnitGUID(unit), GetShowHots(), GetTime() + GetHealTimeFrame()) or 0
		heal = math.floor(heal * mod)
		if UnitIsEnemy("player", unit) then
			if heal == 0 then
				return hp.."/"..maxhp
			else
				return Hex(0,1,0)..hp.."|r/"..maxhp
			end
		end
		local result = hp-maxhp+heal
		if result == 0 then
			if heal == 0 then
				return
			else
				return Hex(0,1,0).."0".."|r"
			end
		else
			if heal > 0 then
				return Hex(0,1,0)..result.."|r"
			else
				return result
			end
		end
	end]],

	["namehealerhealth"] = [[function(unit)
		if UnitIsGhost(unit) then
			return GHOST
		elseif not UnitIsConnected(unit) then
			 return FRIENDS_LIST_OFFLINE
		end
		local hp,maxhp
		hp = UnitHealth(unit)
		maxhp = UnitHealthMax(unit)
		if hp < 1 then
			if feigncheck(unit) then
				return feignDeath
			else
				return DEAD
			end
		end
		local mod = LHC:GetHealModifier(UnitGUID(unit)) or 1
		local heal = LHC:GetHealAmount(UnitGUID(unit), GetShowHots(), GetTime() + GetHealTimeFrame()) or 0
		heal = math.floor(heal * mod)
		if UnitIsEnemy("player", unit) then
			if heal == 0 then
				return hp.."/"..maxhp
			else
				return Hex(0,1,0)..hp.."|r/"..maxhp
			end
		end
		local result = hp-maxhp+heal
		if result == 0 then
			if heal == 0 then
				return UnitName(unit)
			else
				return Hex(0,1,0).."0".."|r"
			end
		else
			if heal > 0 then
				return Hex(0,1,0)..result.."|r"
			else
				return result
			end
		end
	end]],

	["healthcolor"] = [[function(unit)
		local percent = UnitHealth(unit) / max(UnitHealthMax(unit),1)
		if( percent >= 1 ) then return Hex(LUF.db.profile.colors.green.r, LUF.db.profile.colors.green.g, LUF.db.profile.colors.green.b) end
		if( percent == 0 ) then return Hex(LUF.db.profile.colors.red.r, LUF.db.profile.colors.red.g, LUF.db.profile.colors.red.b) end
		
		local sR, sG, sB, eR, eG, eB = 0, 0, 0, 0, 0, 0
		local modifier, inverseModifier = percent * 2, 0
		if( percent > 0.50 ) then
			sR, sG, sB = LUF.db.profile.colors.green.r, LUF.db.profile.colors.green.g, LUF.db.profile.colors.green.b
			eR, eG, eB = LUF.db.profile.colors.yellow.r, LUF.db.profile.colors.yellow.g, LUF.db.profile.colors.yellow.b

			modifier = modifier - 1
		else
			sR, sG, sB = LUF.db.profile.colors.yellow.r, LUF.db.profile.colors.yellow.g, LUF.db.profile.colors.yellow.b
			eR, eG, eB = LUF.db.profile.colors.red.r, LUF.db.profile.colors.red.g, LUF.db.profile.colors.red.b
		end
		
		inverseModifier = 1 - modifier
		return Hex(eR * inverseModifier + sR * modifier, eG * inverseModifier + sG * modifier, eB * inverseModifier + sB * modifier)
	end]],

	["color"] = [[function(unit, realunit, color)
		if color and strlen(color) == 6 then
			return ("|cff"..strlower(color).."|h")
		else
			return "#invalidTag#"
		end
	end]],

	["br"] = [[function(unit) return "\n" end]],

	["castname"] = [[function(unit)
		return UnitCastingInfo(unit) or UnitChannelInfo(unit)
	end]],

	["casttime"] = [[function(unit)
		local name, _, texture, startTime, endTime = UnitCastingInfo(unit)
		local retTime
		if not name then
			name, _, texture, startTime, endTime = UnitChannelInfo(unit)
			if name then
				retTime = (endTime / 1000) - GetTime()
			end
		else
			retTime = (GetTime() - (endTime / 1000)) * -1
		end
		return retTime and math.floor(retTime * 10)/10
	end]],

	["xp"] = [[function(unit)
		if UnitIsUnit(unit,"pet") then
			local currentXP, maxXP = GetPetExperience()
			return currentXP.."/"..maxXP
		else
			return UnitXP(unit).."/"..UnitXPMax(unit)..(GetXPExhaustion() and (" (+"..GetXPExhaustion()..")") or "")
		end
	end]],

	["percxp"] = [[function(unit)
		if UnitIsUnit(unit,"pet") then
			local currentXP, maxXP = GetPetExperience()
			if maxXP == 0 then return end
			return math.floor(currentXP/maxXP*10000)/100 .. "%"
		else
			return math.floor(UnitXP("player")/UnitXPMax("player")*10000)/100 .. "%"
		end
	end]],

	["rep"] = [[function(unit)
		local name, standing, min, max, value, factionID = GetWatchedFactionInfo()
		if name then
			return (value-min).."/"..(max-min).." "..name
		end
	end]],

	["enumtargeting"] = [[function(unit)
		local num = LT:GetUnitTargetedCount(unit)
		if num > 0 then
			return num
		end
	end]],
}

local tags = setmetatable(
	{},
	{
		__index = function(self, key)
			local tagString = tagStrings[key]
			if(tagString) then
				self[key] = tagString
				tagStrings[key] = nil
			end

			return rawget(self, key)
		end,
		__newindex = function(self, key, val)
			if(type(val) == 'string') then
				local func, err = loadstring('return ' .. val)
				if(func) then
					val = func()
				else
					error(err, 3)
				end
			end

			assert(type(val) == 'function', 'Tag function must be a function or a string that evaluates to a function.')

			-- We don't want to clash with any custom envs
			if(getfenv(val) == _G) then
				-- pcall is needed for cases when Blizz functions are passed as
				-- strings, for intance, 'UnitPowerMax', an attempt to set a
				-- custom env will result in an error
				pcall(setfenv, val, _PROXY)
			end

			rawset(self, key, val)
		end,
	}
)

_ENV._TAGS = tags

local vars = setmetatable({}, {
	__newindex = function(self, key, val)
		if(type(val) == 'string') then
			local func = loadstring('return ' .. val)
			if(func) then
				val = func() or val
			end
		end

		rawset(self, key, val)
	end,
})

_ENV._VARS = vars

local LibEvents = {
	["HealComm_HealStarted"] = LHC,
	["HealComm_HealUpdated"] = LHC,
	["HealComm_HealDelayed"] = LHC,
	["HealComm_HealStopped"] = LHC,
	["HealComm_ModifierChanged"] = LHC,
	["HealComm_GUIDDisappeared"] = LHC,
	["TARGETED_COUNT_CHANGED"] = LT,
}

local tagEvents = {
	["afk"]                 = "PLAYER_FLAGS_CHANGED",
	["nameafk"]             = "PLAYER_FLAGS_CHANGED",
	["happiness"]           = "UNIT_HAPPINESS",
	["combat"]              = "UNIT_COMBAT UNIT_FLAGS PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED",
	["combatcolor"]         = "UNIT_COMBAT UNIT_FLAGS PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED",
	["race"]                = "UNIT_CLASSIFICATION_CHANGED", -- Just a guess to prevent OnUpdate
	["rank"]                = "PLAYER_PVP_RANK_CHANGED", -- Just a guess to prevent OnUpdate
	["numrank"]             = "PLAYER_PVP_RANK_CHANGED", -- Just a guess to prevent OnUpdate
	["creature"]            = "UNIT_CLASSIFICATION_CHANGED", -- Just a guess to prevent OnUpdate
	["faction"]             = "UNIT_FACTION",
	["sex"]                 = "UNIT_CLASSIFICATION_CHANGED", -- Just a guess to prevent OnUpdate
	["nocolor"]             = "PLAYER_LOGIN", -- Just a dummy to prevent OnUpdate
	["druidform"]           = "UNIT_AURA UNIT_DISPLAYPOWER",
	["guild"]               = "UNIT_NAME_UPDATE",
	["guildrank"]           = "UNIT_NAME_UPDATE",
	["incheal"]             = "HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["directheal"]			= "HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["incownheal"]          = "HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["incpreheal"]          = "HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["incafterheal"]        = "HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["hotheal"]             = "HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["effheal"]             = "HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["overheal"]            = "HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["buffcount"]           = "UNIT_AURA",
	["numheals"]            = "HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_GUIDDisappeared",
	["pvp"]                 = "PLAYER_FLAGS_CHANGED UNIT_FACTION",
	["smarthealth"]         = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION",
	["smarthealthp"]        = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION",
	["ssmarthealth"]        = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION",
	["ssmarthealthp"]       = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION",
	["healhp"]              = "UNIT_HEALTH_FREQUENT HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["hp"]                  = "UNIT_HEALTH_FREQUENT",
	["shp"]                 = "UNIT_HEALTH_FREQUENT",
	["sshp"]                = "UNIT_HEALTH_FREQUENT",
	["maxhp"]               = "UNIT_MAXHEALTH",
	["smaxhp"]              = "UNIT_MAXHEALTH",
	["missinghp"]           = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH",
	["healmishp"]           = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["perhp"]               = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH",
	["perstatus"]           = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION",
	["pp"]                  = "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER",
	["spp"]                 = "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER",
	["maxpp"]               = "UNIT_MAXPOWER UNIT_DISPLAYPOWER",
	["smaxpp"]              = "UNIT_MAXPOWER UNIT_DISPLAYPOWER",
	["missingpp"]           = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER",
	["perpp"]               = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER",
	["druid:pp"]            = "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER",
	["druid:maxpp"]         = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER",
	["druid:missingpp"]     = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER",
	["druid:perpp"]         = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER",
	["level"]               = "UNIT_LEVEL UNIT_FACTION PLAYER_LEVEL_UP",
	["smartlevel"]          = "UNIT_LEVEL UNIT_FACTION PLAYER_LEVEL_UP",
	["levelcolor"]          = "UNIT_LEVEL UNIT_FACTION PLAYER_LEVEL_UP",
	["name"]                = "UNIT_NAME_UPDATE",
	["shortname"]           = "UNIT_NAME_UPDATE",
	["ignore"]              = "IGNORELIST_UPDATE",
	["abbrev:name"]         = "UNIT_NAME_UPDATE",
	["server"]              = "UNIT_NAME_UPDATE",
	["status"]              = "UNIT_HEALTH UNIT_CONNECTION",
	["cpoints"]             = "UNIT_POWER_FREQUENT UNIT_POWER_UPDATE",
	["rare"]                = "UNIT_CLASSIFICATION_CHANGED",
	["elite"]               = "UNIT_CLASSIFICATION_CHANGED",
	["classification"]      = "UNIT_CLASSIFICATION_CHANGED",
	["shortclassification"] = "UNIT_CLASSIFICATION_CHANGED",
	["group"]               = "GROUP_ROSTER_UPDATE",
	["threat"]              = "UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE",
	["aggrocolor"]          = "UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE",
	["classcolor"]          = "UNIT_CLASSIFICATION_CHANGED",
	["class"]               = "UNIT_CLASSIFICATION_CHANGED",
	["smartclass"]          = "UNIT_CLASSIFICATION_CHANGED",
	["reactcolor"]          = "UNIT_CLASSIFICATION_CHANGED",
	["pvpcolor"]            = "PLAYER_FLAGS_CHANGED UNIT_FACTION",
	["smart:healmishp"]     = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["smartrace"]           = "UNIT_CLASSIFICATION_CHANGED",
	["civilian"]            = "UNIT_LEVEL UNIT_FACTION PLAYER_LEVEL_UP",
	["loyalty"]             = "UNIT_PET UNIT_PET_TRAINING_POINTS",
	["healerhealth"]        = "PLAYER_UPDATE_RESTING UNIT_CONNECTION UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["namehealerhealth"]    = "PLAYER_UPDATE_RESTING UNIT_CONNECTION UNIT_NAME_UPDATE UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH HealComm_HealStarted HealComm_HealUpdated HealComm_HealStopped HealComm_ModifierChanged HealComm_GUIDDisappeared",
	["healthcolor"]         = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH",
	["color"]               = "PLAYER_LOGIN", -- Dummy
	["br"]                  = "PLAYER_LOGIN", -- Dummy
	["castname"]            = "UNIT_SPELLCAST_START UNIT_SPELLCAST_CHANNEL_START UNIT_SPELLCAST_STOP",
	["xp"]                  = "PLAYER_XP_UPDATE UPDATE_EXHAUSTION",
	["percxp"]              = "PLAYER_XP_UPDATE",
	["xpPet"]               = "UNIT_PET_EXPERIENCE UNIT_LEVEL",
	["percxpPet"]           = "UNIT_PET_EXPERIENCE UNIT_LEVEL",
	["rep"]                 = "UPDATE_FACTION",
}

local unitlessEvents = {
	UNIT_POWER_UPDATE = true,
	GROUP_ROSTER_UPDATE = true,
	PARTY_LEADER_CHANGED = true,
	PLAYER_LEVEL_UP = true,
	PLAYER_TARGET_CHANGED = true,
	PLAYER_UPDATE_RESTING = true,
	PLAYER_LOGIN = true,
	UPDATE_FACTION = true,
}

local events = {}

local function TagEventHandler(self, event, unit, ...)
	local strings = events[event]
	if(strings) then
		for _, fs in next, strings do
			if(fs:IsShown() and (unitlessEvents[event] or fs.parent.unit == unit or UnitGUID(fs.parent.unit) == unit or (fs.extraUnits and fs.extraUnits[unit]))) then
				fs:UpdateTag()
			end
		end
	end
end

local eventFrame = CreateFrame('Frame')
eventFrame:SetScript('OnEvent', TagEventHandler)

local onUpdates = {}
local eventlessUnits = {}

local function createOnUpdate(timer)
	if(not onUpdates[timer]) then
		local total = timer
		local frame = CreateFrame('Frame')
		local strings = eventlessUnits[timer]

		frame:SetScript('OnUpdate', function(self, elapsed)
			if(total >= timer) then
				for _, fs in next, strings do
					if(fs:IsVisible() and UnitExists(fs.parent.unit)) then
						fs:UpdateTag()
					end
				end

				total = 0
			end

			total = total + elapsed
		end)

		onUpdates[timer] = frame
	end
end

--[[ Tags: frame:UpdateTags()
Used to update all tags on a frame.

* self - the unit frame from which to update the tags
--]]
local function Update(self)
	if(self.__tags) then
		for fs in next, self.__tags do
			fs:UpdateTag()
		end
	end
end

-- ElvUI block
local onEnter = function(self) for fs in next, self.__mousetags do fs:SetAlpha(1) end end
local onLeave = function(self) for fs in next, self.__mousetags do fs:SetAlpha(0) end end
local onUpdateDelay = {}

onUpdateDelay["numtargeting"] = 0.5
onUpdateDelay["cnumtargeting"] = 0.5
onUpdateDelay["afktime"] = 0.5

local escapeSequences = {
	["||c"] = "|c",
	["||r"] = "|r",
	["||T"] = "|T",
	["||t"] = "|t",
}
-- end block

local tagPool = {}
local funcPool = {}
local tmp = {}

local function getTagName(tag)
	local tagStart = tag:match('>+()') or 2
	local tagEnd = (tag:match('.-()<') or -1) - 1

	return tag:sub(tagStart, tagEnd), tagStart, tagEnd
end

local function getTagFunc(tagstr)
	local func = tagPool[tagstr]
	if(not func) then
		local format, numTags = tagstr:gsub('%%', '%%%%'):gsub(_PATTERN, '%%s')
		local args = {}

		for bracket in tagstr:gmatch(_PATTERN) do
			local tagFunc = funcPool[bracket] or tags[bracket:sub(2, -2)]
			if(not tagFunc) then
				local tagName, tagStart, tagEnd = getTagName(bracket)

				local tag = tags[tagName]
				local var
				if not tag then
					tagName, var = strmatch(tagName, "^(%a*):(.*)$")
					tag = tags[tagName]
				end
				
				if(tag) then
					tagStart = tagStart - 2
					tagEnd = tagEnd + 2

					if(tagStart ~= 0 and tagEnd ~= 0) then
						local prefix = bracket:sub(2, tagStart)
						local suffix = bracket:sub(tagEnd, -2)

						tagFunc = function(unit, realUnit)
							local str = tag(unit, realUnit, var)
							if(str) then
								return prefix .. str .. suffix
							end
						end
					elseif(tagStart ~= 0) then
						local prefix = bracket:sub(2, tagStart)

						tagFunc = function(unit, realUnit)
							local str = tag(unit, realUnit, var)
							if(str) then
								return prefix .. str
							end
						end
					elseif(tagEnd ~= 0) then
						local suffix = bracket:sub(tagEnd, -2)

						tagFunc = function(unit, realUnit)
							local str = tag(unit, realUnit, var)
							if(str) then
								return str .. suffix
							end
						end
					else
						tagFunc = function(unit, realUnit)
							local str = tag(unit, realUnit, var)
							if(str) then
								return str
							end
						end
					end

					funcPool[bracket] = tagFunc
				end
			end

			-- ElvUI changed
			if(tagFunc) then
				tinsert(args, tagFunc)
			else
				numTags = -1
				func = function(self)
					return self:SetText(bracket)
				end
			end
			-- end block
		end

		if numTags ~= -1 then -- ElvUI replaced
			func = function(self)
				local parent = self.parent
				local unit = parent.unit

				local customArgs = parent.__customargs
				local realUnit = self.overrideUnit and parent.realUnit

				_ENV._COLORS = parent.colors
				_ENV._FRAME = parent
				for i, fnc in next, args do
					tmp[i] = fnc(unit, realUnit, customArgs[self]) or ''
				end

				-- We do 1, numTags because tmp can hold several unneeded variables.
				return self:SetFormattedText(format, unpack(tmp, 1, numTags))
			end
		end

		-- ElvUI added check
		if numTags ~= -1 then
			tagPool[tagstr] = func
		end
		-- end block
	end

	return func
end

local function LibEventsWrapper(event, ...)
	if strmatch(event, "^HealComm_Heal.*$") then -- HealComm special case
		for i = 5, select("#", ...) do
			TagEventHandler(eventFrame, event, select(i, ...))
		end
	else
		TagEventHandler(eventFrame, event, ...)
	end
end

local function registerEvent(fontstr, event)
	if(not events[event]) then events[event] = {} end

	if not LibEvents[event] then
		eventFrame:RegisterEvent(event)
	else
		LibEvents[event].RegisterCallback(eventFrame, event, LibEventsWrapper)
	end
	tinsert(events[event], fontstr)
end

local function registerEvents(fontstr, tagstr)
	for tag in tagstr:gmatch(_PATTERN) do
		tag = getTagName(tag)
		local tagevents = tagEvents[tag]
		if(tagevents) then
			for event in tagevents:gmatch('%S+') do
				registerEvent(fontstr, event)
			end
		end
	end
end

local function unregisterEvents(fontstr)
	for event, data in next, events do
		for i, tagfsstr in next, data do
			if(tagfsstr == fontstr) then
				if(#data == 1) then
					if LibEvents[event] then
						LibEvents[event].UnregisterCallback(eventFrame, event)
					else
						eventFrame:UnregisterEvent(event)
					end
				end

				tremove(data, i)
			end
		end
	end
end

local taggedFS = {}

--[[ Tags: frame:Tag(fs, tagstr, ...)
Used to register a tag on a unit frame.

* self   - the unit frame on which to register the tag
* fs     - the font string to display the tag (FontString)
* tagstr - the tag string (string)
* ...    - additional optional unitID(s) the tag should update for
--]]
local function Tag(self, fs, tagstr, ...)
	if(not fs or not tagstr) then return end

	if(not self.__tags) then
		self.__tags = {}
		self.__mousetags = {} -- ElvUI
		self.__customargs = {} -- ElvUI

		tinsert(self.__elements, Update)
	elseif(self.__tags[fs]) then
		-- We don't need to remove it from the __tags table as Untag handles
		-- that for us.
		self:Untag(fs)
	end

	-- ElvUI
	for escapeSequence, replacement in next, escapeSequences do
		while tagstr:find(escapeSequence) do
			tagstr = tagstr:gsub(escapeSequence, replacement)
		end
	end

	local customArgs = tagstr:match('{(.-)}%]')
	if customArgs then
		self.__customargs[fs] = customArgs
		tagstr = tagstr:gsub('{.-}%]', ']')
	else
		self.__customargs[fs] = nil
	end

	if tagstr:find('%[mouseover%]') then
		self.__mousetags[fs] = true
		fs:SetAlpha(0)
		if not self.__HookFunc then
			self:HookScript('OnEnter', onEnter)
			self:HookScript('OnLeave', onLeave)
			self.__HookFunc = true;
		end
		tagstr = tagstr:gsub('%[mouseover%]', '')
	else
		for fontString in next, self.__mousetags do
			if fontString == fs then
				self.__mousetags[fontString] = nil
				fs:SetAlpha(1)
			end
		end
	end

	local containsOnUpdate
	for tag in tagstr:gmatch(_PATTERN) do
		tag = getTagName(tag)
		if not tagEvents[tag] then
			containsOnUpdate = onUpdateDelay[tag] or 0.15;
		end
	end
	-- end block

	fs.parent = self
	fs.UpdateTag = getTagFunc(tagstr)

	if(self.__eventless or fs.frequentUpdates) or containsOnUpdate then -- ElvUI changed
		local timer
		if(type(fs.frequentUpdates) == 'number') then
			timer = fs.frequentUpdates
		-- ElvUI added check
		elseif containsOnUpdate then
			timer = containsOnUpdate
		-- end block
		else
			timer = .5
		end

		if(not eventlessUnits[timer]) then eventlessUnits[timer] = {} end
		tinsert(eventlessUnits[timer], fs)

		createOnUpdate(timer)
	else
		registerEvents(fs, tagstr)

		if(...) then
			if(not fs.extraUnits) then
				fs.extraUnits = {}
			end

			for index = 1, select('#', ...) do
				fs.extraUnits[select(index, ...)] = true
			end
		end
	end

	taggedFS[fs] = tagstr
	self.__tags[fs] = true
end

--[[ Tags: frame:Untag(fs)
Used to unregister a tag from a unit frame.

* self - the unit frame from which to unregister the tag
* fs   - the font string holding the tag (FontString)
--]]
local function Untag(self, fs)
	if(not fs or not self.__tags) then return end

	unregisterEvents(fs)
	for _, timers in next, eventlessUnits do
		for i, fontstr in next, timers do
			if(fs == fontstr) then
				tremove(timers, i)
			end
		end
	end

	fs.UpdateTag = nil

	taggedFS[fs] = nil
	self.__tags[fs] = nil
end

oUF.TagsWithHeal = {
	Methods = tags,
	Events = tagEvents,
	SharedEvents = unitlessEvents,
	OnUpdateThrottle = onUpdateDelay, -- ElvUI
	Vars = vars,
	RefreshMethods = function(self, tag)
		if(not tag) then return end

		funcPool['[' .. tag .. ']'] = nil

		tag = '%[' .. tag:gsub('[%^%$%(%)%%%.%*%+%-%?]', '%%%1') .. '%]'
		for tagstr, func in next, tagPool do
			if(tagstr:gsub("%[[^%[%]]*>", "["):gsub("<[^%[%]]*%]", "]"):match(tag)) then
				tagPool[tagstr] = nil

				for fs in next, taggedFS do
					if(fs.UpdateTag == func) then
						fs.UpdateTag = getTagFunc(tagstr)

						if(fs:IsVisible()) then
							fs:UpdateTag()
						end
					end
				end
			end
		end
	end,
	RefreshEvents = function(self, tag)
		if(not tag) then return end

		tag = '%[' .. tag:gsub('[%^%$%(%)%%%.%*%+%-%?]', '%%%1') .. '%]'
		for tagstr in next, tagPool do
			if(tagstr:gsub("%[[^%[%]]*>", "["):gsub("<[^%[%]]*%]", "]"):match(tag)) then
				for fs, ts in next, taggedFS do
					if(ts == tagstr) then
						unregisterEvents(fs)
						registerEvents(fs, tagstr)
					end
				end
			end
		end
	end,
}

oUF:RegisterMetaFunction('Tag', Tag)
oUF:RegisterMetaFunction('Untag', Untag)
oUF:RegisterMetaFunction('UpdateTags', Update)
