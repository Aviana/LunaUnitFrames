local HealComm = AceLibrary("HealComm-1.0")
local AceEvent = AceLibrary("AceEvent-2.0")
local roster = AceLibrary("RosterLib-2.0")
local banzai = AceLibrary("Banzai-1.0")
local Tags = {}
local hbRefresh = {}

local function abbreviateName(text)
	return string.sub(text, 1, 1) .. "."
end

local abbrevCache = setmetatable({}, {
	__index = function(tbl, val)
		val = string.gsub(val, "([^%s]+) ", abbreviateName)
		rawset(tbl, val, val)
		return val
end})

local DruidForms = {
	["Interface\\Icons\\Ability_Druid_CatForm"] = "Cat ",
	["Interface\\Icons\\Ability_Racial_BearForm"] = "Bear ",
	["Interface\\Icons\\Spell_Nature_ForceOfNature"] = "Moonkin ",
	["Interface\\Icons\\Ability_Druid_AquaticForm"] = "Aquatic ",
	["Interface\\Icons\\Ability_Druid_TravelForm"] = "Travel "
}

Tags.fontStrings = {}

Tags.defaultEvents = {
	["combat"]				= "PLAYER_REGEN_ENABLED PLAYER_REGEN_DISABLED",
	["color:combat"]		= "PLAYER_REGEN_ENABLED PLAYER_REGEN_ENABLED",
	["druidform"]			= "UNIT_AURA",
	["guild"]				= "UNIT_NAME_UPDATE", -- Not sure when this data is available, guessing
	["incheal"]				= "HealComm_Healupdate",
	["pvp"]					= "PLAYER_FLAGS_CHANGED",
	["smarthealth"]			= "UNIT_HEALTH UNIT_MAXHEALTH",
	["healhp"]				= "UNIT_HEALTH HealComm_Healupdate",
	["hp"]            	    = "UNIT_HEALTH",
	["maxhp"]				= "UNIT_HEALTH UNIT_MAXHEALTH",
	["missinghp"]           = "UNIT_HEALTH UNIT_MAXHEALTH",
	["healmishp"]			= "UNIT_HEALTH UNIT_MAXHEALTH HealComm_Healupdate",
	["perhp"]               = "UNIT_HEALTH UNIT_MAXHEALTH",
	["pp"]            	    = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_DISPLAYPOWER",
	["maxpp"]				= "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_DISPLAYPOWER UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE",
	["missingpp"]           = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE",
	["perpp"]               = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE",
	["druid:pp"]			= "DruidManaLib_Manaupdate",
	["druid:maxpp"]			= "DruidManaLib_Manaupdate",
	["druid:missingpp"]		= "DruidManaLib_Manaupdate",
	["druid:perpp"]			= "DruidManaLib_Manaupdate",
	["level"]               = "UNIT_LEVEL",
	["smartlevel"]          = "UNIT_LEVEL UNIT_CLASSIFICATION_CHANGED",
	["levelcolor"]			= "UNIT_LEVEL",
	["name"]                = "UNIT_NAME_UPDATE",
	["rank"]				= "UNIT_NAME_UPDATE",
	["numrank"]				= "UNIT_NAME_UPDATE",
	["abbrev:name"]			= "UNIT_NAME_UPDATE",
	["server"]				= "UNIT_NAME_UPDATE",
	["status"]              = "UNIT_HEALTH",
	["cpoints"]             = "UNIT_COMBO_POINTS",
	["elite"]                = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE",
	["rare"]                = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE",
	["classification"]      = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE",
	["shortclassification"] = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE",
	["group"]				= "RAID_ROSTER_UPDATE PARTY_MEMBERS_CHANGED",
	["color:aggro"]			= "Banzai_UnitGainedAggro Banzai_UnitLostAggro",
	["ignore"]				= "IGNORELIST_UPDATE",
	["smart:healmishp"]		= "UNIT_HEALTH UNIT_MAXHEALTH HealComm_Healupdate",
	["pvpcolor"]			= "PLAYER_FLAGS_CHANGED",
	["reactcolor"]			= "UNIT_FACTION",
	["healerhealth"]		= "UNIT_HEALTH UNIT_MAXHEALTH HealComm_Healupdate"
}

local function Hex(r, g, b)
	if r == nil then
		return string.format("|cff%02x%02x%02x", 255, 255, 255)
	end
	if( type(r) == "table" ) then
		if( r.r ) then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end
	return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function tagsplit(pString)
	local Table = {}
	local fpat = "%[(.-)%]"
	local _, s, tag = strfind(pString, fpat)
	while tag do
		table.insert(Table,tag)
		_, s, tag = strfind(pString, fpat, s)
	end
	return Table
end

Tags.defaultTags = {
	["combat"]				= function(unit)
								if UnitAffectingCombat(unit) then
									return "(c)"
								else
									return ""
								end
							end;
	["color:combat"]		= function(unit)
								if UnitAffectingCombat(unit) then
									return Hex(1,0,0)
								else
									return ""
								end
							end;
	["race"]				= function(unit)
								local race = UnitRace(unit)
								if race then
									return race
								else
									return ""
								end
							end;
	["rank"]				= function(unit)
								local pvpname = UnitPVPName(unit)
								local name = UnitName(unit)
								if name == pvpname then
									return ""
								else
									pvpname = string.gsub(pvpname, " "..name, "")
									return pvpname
								end
							end;
	["numrank"]				= function(unit)
								local rank = UnitPVPRank(unit)
								if rank == 0 then
									return ""
								end
								return rank-4
							end;
	["creature"]			= function(unit)
								local creature = UnitCreatureFamily(unit)
								if creature then
									return creature
								else
									return ""
								end
							end;
	["faction"]				= function(unit)
								local faction = UnitFactionGroup(unit)
								if faction then
									return faction
								else
									return ""
								end
							end;
	["sex"]					= function(unit)
								local sex = UnitSex(unit)
								if sex == 1 then
									return ""
								elseif sex == 2 then
									return "male"
								else
									return "female"
								end
							end;
	["nocolor"]				= function(unit) return Hex(1,1,1) end;
	["druidform"]			= function(unit)
								local _,class = UnitClass(unit)
								if class == "DRUID" then
									if UnitPowerType(unit) == 1 then
										return "Bear "
									elseif UnitPowerType(unit) == 3 then
										return "Cat "
									end
								end
								local form
								for i=1,24 do
									if DruidForms[UnitBuff(unit,i)] then
										form = DruidForms[UnitBuff(unit,i)]
										break
									end
								end
								return form or ""
							end;
	["guild"]				= function(unit) return GetGuildInfo(unit) or "" end;
	["incheal"]				= function(unit)
								local heal = HealComm:getHeal(UnitName(unit))
								if heal > 0 then
									return heal
								else
									return ""
								end
							end;
	["pvp"]					= function(unit) return UnitIsPVP(unit) and "PVP" or "" end;
	["smarthealth"]			= function(unit)
								local hp
								local maxhp
								if MobHealth3 then
									hp,maxhp = MobHealth3:GetUnitHealth(unit)
								else
									hp = UnitHealth(unit)
									maxhp = UnitHealthMax(unit)
								end
								if UnitIsGhost(unit) then
									return "Ghost"
								elseif not UnitIsConnected(unit) then
									return "Offline"
								elseif hp < 1 or (hp == 1 and (UnitInParty(unit) or UnitInRaid(unit))) then
									return "Dead"
								end
								return hp.."/"..maxhp
							end;
	["healhp"]				= function(unit)
								local heal = HealComm:getHeal(UnitName(unit))
								local hp
								if MobHealth3 then
									hp = MobHealth3:GetUnitHealth(unit)
								else
									hp = UnitHealth(unit)
								end
								if heal > 0 then
									return Hex(0,1,0)..(hp+heal)..Hex(1,1,1)
								else
									return hp
								end
							end;
	["hp"]            	    = function(unit)
								local hp
								if MobHealth3 then
									hp = MobHealth3:GetUnitHealth(unit)
								else
									hp = UnitHealth(unit)
								end
								return hp
							end;
	["maxhp"]				= function(unit)
								local hpmax
								if MobHealth3 then
									_,hpmax = MobHealth3:GetUnitHealth(unit)
								else
									hpmax = UnitHealthMax(unit)
								end
								return hpmax
							end;
	["missinghp"]           = function(unit)
								local hp,maxhp
								if MobHealth3 then
									hp,maxhp = MobHealth3:GetUnitHealth(unit)
								else
									hp = UnitHealth(unit)
									maxhp = UnitHealthMax(unit)
								end
								if maxhp-hp == 0 then
									return ""
								else
									return hp-maxhp
								end
							end;
	["healmishp"]			= function(unit)
								local hp,maxhp
								local heal = HealComm:getHeal(UnitName(unit))
								if MobHealth3 then
									hp,maxhp = MobHealth3:GetUnitHealth(unit)
								else
									hp = UnitHealth(unit)
									maxhp = UnitHealthMax(unit)
								end
								local result = hp-maxhp+heal
								if result == 0 then
									return ""
								else
									if heal > 0 then
										return Hex(0,1,0)..result..Hex(1,1,1)
									else
										return result
									end
								end
							end;
	["perhp"]               = function(unit)
								local hp,maxhp
								if MobHealth3 then
									hp,maxhp = MobHealth3:GetUnitHealth(unit)
								else
									hp = UnitHealth(unit)
									maxhp = UnitHealthMax(unit)
								end
								if maxhp < 1 then
									return 0
								else
									return math.floor(((hp / maxhp) * 100)+0.5)
								end
							end;
	["pp"]            	    = function(unit) return UnitMana(unit) end;
	["maxpp"]				= function(unit) return UnitManaMax(unit) end;
	["missingpp"]           = function(unit)
								local mana = UnitMana(unit)
								local manamax = UnitManaMax(unit)
								if manamax-mana == 0 then
									return ""
								else
									return mana-manamax
								end
							end;
	["perpp"]               = function(unit)
								if UnitManaMax(unit) < 1 then
									return 0
								else
									return math.floor(((UnitMana(unit) / UnitManaMax(unit)) * 100)+0.5)
								end
							end;
	["druid:pp"]			= function(unit)
								if unit ~= "player" then
									return ""
								end
								local mana = DruidManaLib:GetMana()
								return mana
							end;
	["druid:maxpp"]			= function(unit)
								if unit ~= "player" then
									return ""
								end
								local _,manamax = DruidManaLib:GetMana()
								return manamax
							end;
	["druid:missingpp"]		= function(unit)
								if unit ~= "player" then
									return ""
								end
								local mana,manamax = DruidManaLib:GetMana()
								if manamax-mana == 0 then
									return ""
								else
									return mana-manamax
								end
							end;
	["druid:perpp"]			= function(unit)
								if unit ~= "player" then
									return ""
								end
								local mana,manamax = DruidManaLib:GetMana()
								if manamax == 0 then
									return 0
								else
									return math.floor(((mana / manamax) * 100)+0.5)
								end
							end;
	["level"]               = function(unit)
								if UnitLevel(unit) == -1 then
									return "??"
								else
									return UnitLevel(unit)
								end
							end;
	["smartlevel"]          = function(unit)
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
							end;
	["levelcolor"]			= function(unit)
								local level = UnitLevel(unit)
								if level == -1 then
									level = 99
								end
								local color = GetDifficultyColor(level)
								return Hex(color)
							end;
	["name"]                = function(unit) return UnitName(unit) or "" end;
	["ignore"]				= function(unit)
								if not UnitIsPlayer(unit) then
									return ""
								end
								local name = UnitName(unit)
								for i=1, GetNumIgnores() do
									if name == GetIgnoreName(i) then
										return "(i)"
									end
								end
								return ""
							end;	
	["abbrev:name"]			= function(unit)
								local name = UnitName(unit)
								if not name then
									return ""
								end
								return string.len(name) > 10 and abbrevCache[name] or name
							end;
	["server"]				= function(unit)
								local _,server = UnitName(unit)
								return server or GetRealmName()
							end;
	["status"]              = function(unit)
								if UnitIsDead(unit) then
									return "Dead"
								elseif UnitIsGhost(unit) then
									return "Ghost"
								elseif not UnitIsConnected(unit) then
									return "Offline"
								else
									return ""
								end
							end;
	["cpoints"]             = function(unit)
								if unit ~= "target" then
									return ""
								end
								return GetComboPoints()
							end;
	["rare"]                = function(unit)
								local classif = UnitClassification(unit)
								if classif == "rare" or classif == "rareelite" then
									return "rare"
								else
									return ""
								end
							end;
	["elite"]     			= function(unit)
								local classif = UnitClassification(unit)
								if classif == "elite" or classif == "rareelite" then
									return "elite"
								else
									return ""
								end
							end;
	["classification"]    	= function(unit)
								local classif = UnitClassification(unit)
								if classif == "normal" then
									return ""
								else
									return classif
								end
							end;						
	["shortclassification"] = function(unit)
								local classif = UnitClassification(unit)
								if classif == "rare" then
									return "R"
								elseif classif == "elite" then
									return "E"
								elseif classif == "rareelite" then
									return "RE"
								elseif classif == "worldboss" then
									return "BOSS"
								else
									return ""
								end
							end;
	["group"]				= function(unit)
								if UnitInParty(unit) or UnitIsUnit("player",unit) then
									if(GetNumRaidMembers() == 0) then
										if GetNumPartyMembers() == 0 then
											return ""
										else
											return 1
										end
									end
									local name = UnitName(unit)
									for i=1, GetNumRaidMembers() do
										local raidName, _, group = GetRaidRosterInfo(i)
										if( raidName == name ) then
											return group
										end
									end
								else
									return ""
								end
							end;
	["color:aggro"]			= function(unit)
								local aggro = banzai:GetUnitAggroByUnitId(unit)
								if aggro then
									return Hex(1,0,0)
								else
									return ""
								end
							end;
	["classcolor"]			= function(unit)
								if not UnitIsPlayer(unit) then
									return Hex(1,1,1)
								end
								local _,class = UnitClass(unit)
								if class then
									return Hex(unpack(LunaOptions.ClassColors[class]))
								else
									return Hex(1,1,1)
								end
							end;
	["class"]				= function(unit) return UnitClass(unit) or "" end;
	["smartclass"]			= function(unit)
								if UnitIsPlayer(unit) then
									return UnitClass(unit) or ""
								else
									return UnitCreatureType(unit) or ""
								end
							end;
	["reactcolor"]			= function(unit)
								local reaction = UnitReaction("player",unit)
								if reaction == 4 then
									return Hex(LunaOptions.MiscColors["neutral"])
								elseif reaction < 4 then
									return Hex(LunaOptions.MiscColors["hostile"])
								elseif reaction then
									return Hex(LunaOptions.MiscColors["friendly"])
								else
									return ""
								end
							end;
	["pvpcolor"]			= function(unit)
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
							end;
	["smart:healmishp"]		= function(unit)
								if UnitIsGhost(unit) then
									return "Ghost"
								elseif not UnitIsConnected(unit) then
									return "Offline"
								end
								local hp,maxhp
								if MobHealth3 then
									hp,maxhp = MobHealth3:GetUnitHealth(unit)
								else
									hp = UnitHealth(unit)
									maxhp = UnitHealthMax(unit)
								end
								if hp < 1 or (hp == 1 and (UnitInParty(unit) or UnitInRaid(unit))) then
									return "Dead"
								end
								local heal = HealComm:getHeal(UnitName(unit))
								local result = hp-maxhp+heal
								if result == 0 then
									return ""
								else
									if heal > 0 then
										return Hex(0,1,0)..result..Hex(1,1,1)
									else
										return result
									end
								end
							end;
	["smartrace"]			= function(unit)
								local race = UnitRace(unit)
								local ctype = UnitCreatureType(unit)
								if UnitIsPlayer(unit) then
									return race or ""
								else
									return ctype or ""
								end
							end;
	["civilian"]			= function(unit)
								if UnitIsCivilian(unit) then
									return "(civ)"
								else
									return ""
								end
							end;
	["healerhealth"]		= function(unit)
								if UnitIsGhost(unit) then
									return "Ghost"
								elseif not UnitIsConnected(unit) then
									return "Offline"
								end
								local hp,maxhp
								if MobHealth3 then
									hp,maxhp = MobHealth3:GetUnitHealth(unit)
								else
									hp = UnitHealth(unit)
									maxhp = UnitHealthMax(unit)
								end
								if hp < 1 or (hp == 1 and (UnitInParty(unit) or UnitInRaid(unit))) then
									return "Dead"
								end
								local heal = HealComm:getHeal(UnitName(unit))
								if UnitIsEnemy("player", unit) then
									if heal == 0 then
										return hp.."/"..maxhp
									else
										return Hex(0,1,0)..hp..Hex(1,1,1).."/"..maxhp
									end
								end
								local result = hp-maxhp+heal
								if result == 0 then
									if heal == 0 then
										return ""
									else
										return Hex(0,1,0).."0"..Hex(1,1,1)
									end
								else
									if heal > 0 then
										return Hex(0,1,0)..result..Hex(1,1,1)
									else
										return result
									end
								end
							end;
}
--To-Do:
-- Custom color tag

local function strsplit(pString, pPattern)
	local Table = {}
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = strfind(pString, fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(Table,cap)
		end
		last_end = e+1
		s, e, cap = strfind(pString, fpat, last_end)
	end
	if last_end <= strlen(pString) then
		cap = strsub(pString, last_end)
		table.insert(Table, cap)
	end
	return Table
end

local function getEventList(tagString)
	local tags = tagsplit(tagString)
	local events = {}
	for _,k in pairs(tags) do
		if Tags.defaultEvents[k] then
			local eventlist = Tags.defaultEvents[k]
			local eventtable = strsplit(eventlist," ")
			for _,k in pairs(eventtable) do
				events[k] = true
			end
		end
	end
	return events
end

local function updateTagString(unit, fontString, event)
	if event and Tags.fontStrings[unit][fontString].events[event] or not event then
		local text
		local tagstring = Tags.fontStrings[unit][fontString].tagString
		if tagstring == "" then
			return ""
		end
		local fpat = "%[(.-)%]"
		local ending
		local start, e, tag = strfind(tagstring, fpat)
		if start and start > 1 then
			text = string.sub(tagstring,1,(start-1))
		elseif not start then
			text = tagstring
		else
			text = ""
		end
		while tag do
			if Tags.defaultTags[tag] then
--				ChatFrame1:AddMessage(tag)
				text = text..Tags.defaultTags[tag](unit)
			end
			if tag == "combat" or tag == "color:combat" then
				hbRefresh[unit] = true
			end
			start, ending, tag = strfind(tagstring, fpat, e)
			if start then
				text = text..string.sub(tagstring,(e+1),(start-1))
				e = ending
			end
		end
		if e then
			text = text..string.sub(tagstring,(e+1))
		end
		return text
	end
end

function LunaUnitFrames:RegisterFontstring(fontString, unit, tagString)
	if not Tags.fontStrings[unit] then
		Tags.fontStrings[unit] = {}
	end
	Tags.fontStrings[unit][fontString] = {}
	Tags.fontStrings[unit][fontString].events = getEventList(tagString)
	Tags.fontStrings[unit][fontString].tagString = tagString
	LunaUnitFrames:UpdateTags(unit, fontString)
end

function LunaUnitFrames:UpdateTags(unit, fontString, event)
	if not fontString and not event then
		if Tags.fontStrings[unit] then
			for k,v in pairs(Tags.fontStrings[unit]) do
				local text = updateTagString(unit, k)
				if text and k:GetFont() then
					k:SetText(text)
				end
			end
		end
	elseif event then
		if Tags.fontStrings[unit] then
			for k,v in pairs(Tags.fontStrings[unit]) do
				local text = updateTagString(unit, k, event)
				if text and k:GetFont() then
					k:SetText(text)
				end
			end
		end
	elseif fontString then
		local text = updateTagString(unit, fontString)
		if text and fontString:GetFont() then
			fontString:SetText(text)
		end
	end
end

local function onEvent(arg1)
	if event == "UNIT_PET" and arg1 == "player" then
		LunaUnitFrames:UpdateTags("pet")
	elseif event == "PLAYER_ENTERING_WORLD" then
		LunaUnitFrames:UpdateTags("player")
	elseif event == "DruidManaLib_Manaupdate" then
		LunaUnitFrames:UpdateTags("player", nil, event)
	elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
		LunaUnitFrames:UpdateTags("player", nil, "PARTY_MEMBERS_CHANGED")
		for i=1, 4 do
			local unit = "party"..i
			if UnitExists(unit) and Tags.fontStrings[unit] then
				LunaUnitFrames:UpdateTags(unit)
			end
		end
		for i=1, 40 do
		local unit = "raid"..i
			if UnitExists(unit) and Tags.fontStrings[unit] then
				LunaUnitFrames:UpdateTags(unit)
			end
		end
	elseif event == "UNIT_COMBO_POINTS" then
		LunaUnitFrames:UpdateTags("target", nil, "UNIT_COMBO_POINTS")
	elseif event == "PLAYER_TARGET_CHANGED" then
		LunaUnitFrames:UpdateTags("target")
	elseif event == "HealComm_Healupdate" then
		local unit = roster:GetUnitIDFromName(arg1)
		if unit and UnitIsUnit(unit, "target") then
			LunaUnitFrames:UpdateTags("target", nil, event)
		end
		LunaUnitFrames:UpdateTags(unit, nil, event)
	elseif event == "IGNORELIST_UPDATE" then
		LunaUnitFrames:UpdateTags("target")
	else
		LunaUnitFrames:UpdateTags(arg1, nil, event)
	end
end

local function refreshTags()
	for k,v in pairs(hbRefresh) do
		if v then
			LunaUnitFrames:UpdateTags(k, nil, "PLAYER_REGEN_ENABLED")
		end
	end
end

AceEvent:ScheduleRepeatingEvent(refreshTags, 1)

AceEvent:RegisterEvent("PLAYER_REGEN_ENABLED", onEvent)
AceEvent:RegisterEvent("PLAYER_REGEN_DISABLED", onEvent)
AceEvent:RegisterEvent("UNIT_ENERGY", onEvent)
AceEvent:RegisterEvent("UNIT_FOCUS", onEvent)
AceEvent:RegisterEvent("UNIT_MANA", onEvent)
AceEvent:RegisterEvent("UNIT_RAGE", onEvent)
AceEvent:RegisterEvent("UNIT_DISPLAYPOWER", onEvent)
AceEvent:RegisterEvent("UNIT_MAXENERGY", onEvent)
AceEvent:RegisterEvent("UNIT_MAXFOCUS", onEvent)
AceEvent:RegisterEvent("UNIT_MAXMANA", onEvent)
AceEvent:RegisterEvent("UNIT_MAXRAGE", onEvent)
AceEvent:RegisterEvent("UNIT_MAXHEALTH", onEvent)
AceEvent:RegisterEvent("UNIT_HEALTH", onEvent)
AceEvent:RegisterEvent("HealComm_Healupdate", onEvent)
AceEvent:RegisterEvent("Banzai_UnitGainedAggro", onEvent)
AceEvent:RegisterEvent("Banzai_UnitLostAggro", onEvent)
AceEvent:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", onEvent)
AceEvent:RegisterEvent("UNIT_LEVEL", onEvent)
AceEvent:RegisterEvent("UNIT_NAME_UPDATE", onEvent)
AceEvent:RegisterEvent("UNIT_AURA", onEvent)
AceEvent:RegisterEvent("PLAYER_FLAGS_CHANGED", onEvent)
AceEvent:RegisterEvent("DruidManaLib_Manaupdate", onEvent)
AceEvent:RegisterEvent("PARTY_MEMBERS_CHANGED", onEvent)
AceEvent:RegisterEvent("RAID_ROSTER_UPDATE", onEvent)
AceEvent:RegisterEvent("UNIT_COMBO_POINTS", onEvent)
AceEvent:RegisterEvent("PLAYER_TARGET_CHANGED", onEvent)
AceEvent:RegisterEvent("PLAYER_ENTERING_WORLD", onEvent)
AceEvent:RegisterEvent("UNIT_PET", onEvent)
AceEvent:RegisterEvent("IGNORELIST_UPDATE", onEvent)
AceEvent:RegisterEvent("UNIT_FACTION", onEvent)
