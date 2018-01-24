local LunaUF = LunaUF
local Tags = {}
LunaUF:RegisterModule(Tags, "tags", LunaUF.L["Tags"])

local L = LunaUF.L
local HealComm = LunaUF.HealComm
local DruidManaLib = LunaUF.DruidManaLib
local banzai = LunaUF.Banzai
local tooltip = LunaUF.ScanTip
local UnitHealth = UnitHealth
local realUnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local realUnitHealthMax = UnitHealthMax

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
	["Interface\\Icons\\Ability_Druid_CatForm"] = L["form_cat"],
	["Interface\\Icons\\Ability_Racial_BearForm"] = L["form_bear"],
	["Interface\\Icons\\Spell_Nature_ForceOfNature"] = L["form_moonkin"],
	["Interface\\Icons\\Ability_Druid_AquaticForm"] = L["form_aquatic"],
	["Interface\\Icons\\Ability_Druid_TravelForm"] = L["form_travel"],
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

local function feigncheck(unit)
	local _,class = UnitClass(unit)
	if class ~= "HUNTER" then return end
	for i=1,32 do
		if not UnitBuff(unit,i) then
			return
		end
		tooltip:ClearLines()
		tooltip:SetUnitBuff(unit,i)
		if LunaScanTipTextLeft1:GetText() == L["Feign Death"] then
			return true
		end
	end
end

local defaultTags = {
	["numtargeting"]		= function(unit)
								if UnitInRaid("player") then
									local count = 0
									for i = 1, GetNumRaidMembers() do
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
									for i=1, GetNumPartyMembers() do
										if UnitIsUnit(unit, ("party"..i.."target")) then
											count = count + 1
										end
									end
									return tostring(count)
								end
							end;
	["cnumtargeting"]		= function(unit)
								local count = 0
								if UnitInRaid("player") then
									for i = 1, GetNumRaidMembers() do
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
									for i=1, GetNumPartyMembers() do
										if UnitIsUnit(unit, ("party"..i.."target")) then
											count = count + 1
										end
									end
								end
								if count == 0 then
									return Hex(1,0.5,0.5)..count..Hex(1,1,1)
								elseif (count > 5) then
									return Hex(0.5,1,0.5)..count..Hex(1,1,1)
								else
									return Hex(0.5,0.5,1)..count..Hex(1,1,1)
								end
							end;
	["happiness"]			= function(unit)
								if unit ~= "pet" then
									return ""
								end
								if GetPetHappiness() == 1 then
									return L["unhappy"]
								elseif GetPetHappiness() == 2 then
									return L["content"]
								else
									return L["happy"]
								end
							end;
	["combat"]				= function(unit)
								if UnitAffectingCombat(unit) then
									return L["(c)"]
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
	["range"]				= function(unit)
								local range = LunaUF.modules.range:GetRange(unit)
								if range == 10 then
									return "0-10"
								elseif range == 30 then
									return "10-30"
								else
									return ">30"
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
								if name and pvpname and name ~= pvpname then
									pvpname = string.gsub(pvpname, " "..name, "")
									return pvpname
								else
									return ""
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
								local _,faction = UnitFactionGroup(unit)
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
									return L["male"]
								else
									return L["female"]
								end
							end;
	["nocolor"]				= function(unit) return Hex(1,1,1) end;
	["druidform"]			= function(unit)
								local _,class = UnitClass(unit)
								if class == "DRUID" then
									if UnitPowerType(unit) == 1 then
										return L["form_bear"]
									elseif UnitPowerType(unit) == 3 then
										return L["form_cat"]
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
	["numheals"]			= function(unit) return HealComm:getNumHeals(UnitName(unit)) end;
	["pvp"]					= function(unit) return UnitIsPVP(unit) and "PVP" or "" end;
	["smarthealth"]			= function(unit)
								local hp
								local maxhp
								hp = UnitHealth(unit)
								maxhp = UnitHealthMax(unit)
								if UnitIsGhost(unit) then
									return L["Ghost"]
								elseif not UnitIsConnected(unit) then
									return L["Offline"]
								elseif hp < 1 or (hp == 1 and not UnitIsVisible(unit)) then
									if feigncheck(unit) then
										return L["Feigned"]
									else
										return L["Dead"]
									end
								end
								return hp.."/"..maxhp
							end;
	["ssmarthealth"]			= function(unit)
								local hp = UnitHealth(unit)
								if hp < 1 or (hp == 1 and not UnitIsVisible(unit)) then
									if feigncheck(unit) then
										return L["Feigned"]
									else
										return L["Dead"]
									end
								end
								if hp > 10000 then
									hp = math.floor(hp/1000).."K"
								end
								local maxhp = UnitHealthMax(unit)
								if maxhp > 10000 then
									maxhp = math.floor(maxhp/1000).."K"
								end
								if UnitIsGhost(unit) then
									return L["Ghost"]
								elseif not UnitIsConnected(unit) then
									return L["Offline"]
								end
								return hp.."/"..maxhp
							end;
	["healhp"]				= function(unit)
								local heal = HealComm:getHeal(UnitName(unit))
								local hp
								hp = UnitHealth(unit)
								if heal > 0 then
									return Hex(0,1,0)..(hp+heal)..Hex(1,1,1)
								else
									return hp
								end
							end;
	["hp"]            	    = function(unit)
								return UnitHealth(unit)
							end;
	["shp"]					= function(unit)
								if UnitHealth(unit) > 10000 then
									return math.floor(UnitHealth(unit)/1000).."K"
								else
									return UnitHealth(unit)
								end
							end;
	["maxhp"]				= function(unit)
								return UnitHealthMax(unit)
							end;
	["smaxhp"]				= function(unit)
								if UnitHealthMax(unit) > 10000 then
									return math.floor(UnitHealthMax(unit)/1000).."K"
								else
									return UnitHealthMax(unit)
								end
							end;
	["missinghp"]           = function(unit)
								local hp,maxhp
								hp = UnitHealth(unit)
								maxhp = UnitHealthMax(unit)
								if maxhp-hp == 0 then
									return ""
								else
									return hp-maxhp
								end
							end;
	["healmishp"]			= function(unit)
								local hp,maxhp
								local heal = HealComm:getHeal(UnitName(unit))
								hp = UnitHealth(unit)
								maxhp = UnitHealthMax(unit)
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
								hp = UnitHealth(unit)
								maxhp = UnitHealthMax(unit)
								if maxhp < 1 then
									return 0
								else
									return math.floor(((hp / maxhp) * 100)+0.5)
								end
							end;
	["pp"]            	    = function(unit) return UnitMana(unit) end;
	["spp"]            	    = function(unit)
								if UnitMana(unit) > 10000 then
									return math.floor(UnitMana(unit)/1000).."K"
								else
									return UnitMana(unit)
								end
							end;
	["maxpp"]				= function(unit) return UnitManaMax(unit) end;
	["smaxpp"]            	    = function(unit)
								if UnitManaMax(unit) > 10000 then
									return math.floor(UnitManaMax(unit)/1000).."K"
								else
									return UnitManaMax(unit)
								end
							end;
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
	["shortname"]			= function(unit, length)
								if length == nil then
									length = 3
								end
								return UnitName(unit) and strsub(UnitName(unit),1,math.max(math.min(length, 12), 1)) or ""
							end;
	["ignore"]				= function(unit)
								if not UnitIsPlayer(unit) then
									return ""
								end
								local name = UnitName(unit)
								for i=1, GetNumIgnores() do
									if name == GetIgnoreName(i) then
										return L["(i)"]
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
								local hp = UnitHealth(unit)
								if hp < 1 or (hp == 1 and not UnitIsVisible(unit)) then
									if feigncheck(unit) then
										return L["Feigned"]
									else
										return L["Dead"]
									end
								elseif UnitIsGhost(unit) then
									return L["Ghost"]
								elseif not UnitIsConnected(unit) then
									return L["Offline"]
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
									return L["rare"]
								else
									return ""
								end
							end;
	["elite"]     			= function(unit)
								local classif = UnitClassification(unit)
								if classif == "elite" or classif == "rareelite" then
									return L["elite"]
								else
									return ""
								end
							end;
	["classification"]    	= function(unit)
								local classif = UnitClassification(unit)
								if classif == "normal" then
									return ""
								else
									return L[classif]
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
								if GetNumRaidMembers() > 0 then
									local name = UnitName(unit)
									for i=1, GetNumRaidMembers() do
										local raidName, _, group = GetRaidRosterInfo(i)
										if( raidName == name ) then
											return group
										end
									end
								elseif UnitInParty(unit) and GetNumPartyMembers() > 0 then
									return 1
								
								end
								return ""
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
									return Hex(LunaUF.db.profile.classColors[class])
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
								if not reaction then
									return ""
								elseif reaction == 4 then
									return Hex(LunaUF.db.profile.healthColors["neutral"])
								elseif reaction < 4 then
									return Hex(LunaUF.db.profile.healthColors["hostile"])
								else
									return Hex(LunaUF.db.profile.healthColors["friendly"])
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
								hp = UnitHealth(unit)
								maxhp = UnitHealthMax(unit)
								if hp < 1 or (hp == 1 and not UnitIsVisible(unit)) then
									if feigncheck(unit) then
										return L["Feigned"]
									else
										return L["Dead"]
									end
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
									return L["(civ)"]
								else
									return ""
								end
							end;
	["loyalty"]				= function(unit)
								local loyalty = GetPetLoyalty()
								if loyalty then
									return loyalty
								else
									return ""
								end
							end;
	["healerhealth"]		= function(unit)
								if UnitIsGhost(unit) then
									return L["Ghost"]
								elseif not UnitIsConnected(unit) then
									return L["Offline"]
								end
								local hp,maxhp
								hp = UnitHealth(unit)
								maxhp = UnitHealthMax(unit)
								if hp < 1 or (hp == 1 and not UnitIsVisible(unit)) then
									if feigncheck(unit) then
										return L["Feigned"]
									else
										return L["Dead"]
									end
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
	["namehealerhealth"]		= function(unit)
								if UnitIsGhost(unit) then
									return "Ghost"
								elseif not UnitIsConnected(unit) then
									return "Offline"
								end
								local hp,maxhp
								hp = UnitHealth(unit)
								maxhp = UnitHealthMax(unit)
								if hp < 1 or (hp == 1 and not UnitIsVisible(unit)) then
									if feigncheck(unit) then
										return L["Feigned"]
									else
										return L["Dead"]
									end
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
										return UnitName(unit)
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
	["healthcolor"]			=function(unit)
								local percent = UnitHealth(unit) / UnitHealthMax(unit)
								if( percent >= 1 ) then return Hex(LunaUF.db.profile.healthColors.green.r, LunaUF.db.profile.healthColors.green.g, LunaUF.db.profile.healthColors.green.b) end
								if( percent == 0 ) then return Hex(LunaUF.db.profile.healthColors.red.r, LunaUF.db.profile.healthColors.red.g, LunaUF.db.profile.healthColors.red.b) end
								
								local sR, sG, sB, eR, eG, eB = 0, 0, 0, 0, 0, 0
								local modifier, inverseModifier = percent * 2, 0
								if( percent > 0.50 ) then
									sR, sG, sB = LunaUF.db.profile.healthColors.green.r, LunaUF.db.profile.healthColors.green.g, LunaUF.db.profile.healthColors.green.b
									eR, eG, eB = LunaUF.db.profile.healthColors.yellow.r, LunaUF.db.profile.healthColors.yellow.g, LunaUF.db.profile.healthColors.yellow.b

									modifier = modifier - 1
								else
									sR, sG, sB = LunaUF.db.profile.healthColors.yellow.r, LunaUF.db.profile.healthColors.yellow.g, LunaUF.db.profile.healthColors.yellow.b
									eR, eG, eB = LunaUF.db.profile.healthColors.red.r, LunaUF.db.profile.healthColors.red.g, LunaUF.db.profile.healthColors.red.b
								end
								
								inverseModifier = 1 - modifier
								return Hex(eR * inverseModifier + sR * modifier, eG * inverseModifier + sG * modifier, eB * inverseModifier + sB * modifier)
							end;
	["color"]				= function(color)
								if color and strlen(color) == 6 then
									return ("|cff"..color.."|h")
								else
									return L["#invalidTag#"]
								end
							end;
	["br"]					= function(unit)
								return "\n"
							end;
}

function GetTagText(fontstring)
	local stringText = ""
	local array = fontstring.Parts
	if not array then return "" end
	for i=1,getn(array) do
		if type(array[i]) == "string" then
			stringText = stringText .. array[i]
		else
			stringText = stringText .. array[i][0](array[i][1],array[i][2])
		end
	end
	return stringText
end

local function OnUpdate()
	local frame = this:GetParent()
	local bartags = LunaUF.db.profile.units[frame.unitGroup].tags.bartags
	for barname,barfontstrings in pairs(frame.fontstrings) do
		for align,fontstring in pairs(barfontstrings) do
			fontstring:SetText(GetTagText(fontstring))
		end
	end
end

function Tags:OnEnable(frame)
	if not frame.tags then
		frame.tags = CreateFrame("Frame", nil, frame)
	end
	frame.tags:SetScript("OnUpdate", OnUpdate)
	for barname,barfontstrings in pairs(frame.fontstrings) do
		for align,fontstring in pairs(barfontstrings) do
			fontstring:Show()
		end
	end
end

function Tags:OnDisable(frame)
	if frame.tags then
		frame.tags:SetScript("OnUpdate", nil)
		for barname,barfontstrings in pairs(frame.fontstrings) do
			for align,fontstring in pairs(barfontstrings) do
				fontstring:SetText("")
				fontstring:Hide()
			end
		end
	end
end

function Tags:SplitTags(fontstring,tagline,unit)
	local currTag, tagArg, startPos, endPos
	local PartNr = 1
	local text = tagline or ""
	
	-- Empty the Table
	if not fontstring.Parts then
		fontstring.Parts = {}
	else
		for k in pairs(fontstring.Parts) do
			fontstring.Parts[k] = nil
		end
	end
	
	if text == "" then return end
	
	startPos,endPos,currTag = string.find(text,"%[([%w:]+)%]")
	if not currTag then
		-- We only have static text in the fontstring
		fontstring.Parts[PartNr] = text
		return
	end
	while currTag do
		if defaultTags[currTag] then
			if startPos > 1 then
				fontstring.Parts[PartNr] = string.sub(text,1,startPos-1)
				PartNr = PartNr + 1
			end
			fontstring.Parts[PartNr] = {
				[0] = defaultTags[currTag],
				[1] = unit,
			}
			PartNr = PartNr + 1
			text = string.sub(text,endPos+1)
		elseif string.find(currTag,"color:(%x%x%x%x%x%x)") then
			_,_,tagArg = string.find(currTag,"color:(%x%x%x%x%x%x)")
			if startPos > 1 then
				fontstring.Parts[PartNr] = string.sub(text,1,startPos-1)
				PartNr = PartNr + 1
			end
			fontstring.Parts[PartNr] = {
				[0] = defaultTags["color"],
				[1] = tagArg,
			}
			PartNr = PartNr + 1
			text = string.sub(text,endPos+1)
		elseif string.find(currTag,"shortname:(%d+)") then
			_,_,tagArg = string.find(currTag,"shortname:(%d+)")
			if startPos > 1 then
				fontstring.Parts[PartNr] = string.sub(text,1,startPos-1)
				PartNr = PartNr + 1
			end
			fontstring.Parts[PartNr] = {
				[0] = defaultTags["shortname"],
				[1] = unit,
				[2] = tagArg,
			}
			PartNr = PartNr + 1
			text = string.sub(text,endPos+1)
		else
			fontstring.Parts[PartNr] = L["#invalidTag#"]
			PartNr = PartNr + 1
			text = string.sub(text,endPos+1)
		end
		startPos,endPos,currTag = string.find(text,"%[([%w:]+)%]")
	end
	if text ~= "" then
		fontstring.Parts[PartNr] = text
	end
end

function Tags:FullUpdate(frame)
	local bartags = LunaUF.db.profile.units[frame.unitGroup].tags.bartags
	for barname,barfontstrings in pairs(frame.fontstrings) do
		for align,fontstring in pairs(barfontstrings) do
			-- Split into functions and store
			self:SplitTags(fontstring,bartags[barname][align],frame.unit)
		end
	end
end

LunaUF:RegisterEvent("VARIABLES_LOADED", function ()
	if MobHealth3 then
		UnitHealth = function(unit)
				local hp = MobHealth3:GetUnitHealth(unit)
				return hp
			end
		UnitHealthMax = function(unit)
				local _,maxhp = MobHealth3:GetUnitHealth(unit)
				return maxhp
			end
	elseif MobHealthFrame then
		UnitHealth = function(unit)
			local hp
			if unit == "target" then
				hp = MobHealth_GetTargetCurHP()
			end
			if not hp then
				hp = realUnitHealth(unit)
			end
			return hp
		end
		UnitHealthMax = function(unit)
			local maxhp
			if unit == "target" then
				maxhp = MobHealth_GetTargetMaxHP()
			end
			if not maxhp then
				maxhp = realUnitHealthMax(unit)
			end
			return maxhp
		end
	end
end)
