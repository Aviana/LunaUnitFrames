local Range = {}
AceLibrary("AceHook-2.1"):embed(Range)
AceLibrary("AceEvent-2.0"):embed(Range)
local L = LunaUF.L
local BS = LunaUF.BS
local BZ = AceLibrary("Babble-Zone-2.2")
local ScanTip = LunaUF.ScanTip
local rosterLib = AceLibrary("RosterLib-2.0")
LunaUF:RegisterModule(Range, "range", L["Range"])
local Continent,Zone,ZoneName
local roster = {}
local ZoneWatch = CreateFrame("Frame")
local _, playerClass = UnitClass("player")

-- Big thx to Renew & Astrolabe
local MapScales = {
	[0] = {[0] = {x = 29688.932932224,	y = 44537.340058402}}, -- World Map

	[-1] = { -- Battlegrounds
		[0] = {x=0.0000000001,y=0.0000000001}, -- dummy
		[BZ["Alterac Valley"]] = {x=0.00025277584791183,y=0.0003791834626879}, -- Alterac Valley
		[BZ["Arathi Basin"]] = {x=0.00060996413230886,y=0.00091460134301867}, -- Arathi Basin
		[BZ["Warsong Gulch"]] = {x=0.000934666820934484,y=0.0013986080884933}, -- Warsong Gulch
	},

	[1] = { -- Kalimdor
		[0] = {x = 24533.025279205, y = 36800.210572494}, -- No local Map
		[1] = {x=0.00018538534641226,y=0.00027837923594884}, -- Ashenvale
		[2] = {x=0.0002110515322004,y=0.00031666883400508}, -- Aszhara
		[3] = {x=0.00016346999577114,y=0.0002448782324791}, -- Darkshore
		[4] = {x=0.001011919762407,y=0.0015176417572158}, -- Darnassus
		[5] = {x=0.000238049243117769,y=0.00035701000264713}, -- Desolace
		[6] = {x=0.000202241752828887,y=0.00030311250260898},  -- Durotar
		[7] = {x=0.00020404585770198,y=0.00030594425542014}, -- Dustwallow Marsh
		[8] = {x=0.00018605589866638,y=0.00027919347797121}, -- Felwood
		[9] = {x=0.00015413335391453,y=0.00023112978254046}, -- Feralas
		[10] = {x=0.00046338992459433,y=0.00069469745670046}, -- Moonglade
		[11] = {x=0.00020824585642133,y=0.00031234536852155}, -- Mulgore
		[12] = {x=0.00076302673135485,y=0.0011450946331024}, -- Orgrimmar
		[13] = {x=0.00030702139650072,y=0.00046115900788988}, -- Silithus
		[14] = {x=0.0002192035317421,y=0.00032897400004523}, -- Stonetalon Mountains
		[15] = {x=0.00015519559383392,y=0.00023255497217178}, -- Tanaris
		[16] = {x=0.00021010743720191,y=0.00031522342136928}, -- Teldrassil
		[17] = {x=0.0001055257661002,y=0.00015825512153762}, -- Barrens
		[18] = {x=0.00024301665169852,y=0.00036516572747912}, -- Thousand Needles
		[19] = {x=0.00102553303755263,y=0.0015390366315842}, -- Thunderbluff
		[20] = {x=0.00028926772730691,y=0.0004336131470544}, -- Un'Goro Crater
		[21] = {x=0.0001503484589713,y=0.0002260080405644}, -- Winterspring
	},

	[2] = { -- Eastern Kingdoms
		[0] = {x = 27149.795290881, y = 40741.175327834}, -- No local Map
		[1] = {x=0.00038236060312816,y=0.00057270910058703}, -- Alterac Mountains
		[2] = {x=0.00029711957488741,y=0.00044587893145425}, -- Arathi Highlands
		[3] = {x=0.00043004538331713,y=0.00064518196242196}, -- Badlands
		[4] = {x=0.00031955327306475,y=0.00047930649348668}, -- Blasted Lands
		[5] = {x=0.00036544565643583,y=0.00054845426763807}, -- Burning Steppes
		[6] = {x=0.00042719074657985,y=0.00064268921102796}, -- Deadwind Pass
		[7] = {x=0.00021748670509883,y=0.00032613213573183}, -- Dun Morogh
		[8] = {x=0.00039665134889739,y=0.000594192317755393},-- Duskwood
		[9] = {x=0.00027669753347124,y=0.00041501436914716}, -- Eastern Plaguelands
		[10] = {x=0.00030816452843802,y=0.00046261719294957}, -- Elwynn Forest
		[11] = {x=0.00033472904137203,y=0.00050214784485953}, -- Hillsbrad Foothills
		[12] = {x=0.0013541845338685,y=0.0020301469734737}, -- Ironforge
		[13] = {x=0.00038827742849077,y=0.000582420040021079}, -- Loch Modan
		[14] = {x=0.00049317521708352,y=0.0007399320602417}, -- Redridge Mountains
		[15] = {x=0.00047916280371802,y=0.00071918751512255}, -- Searing Gorge
		[16] = {x=0.00025506743362975,y=0.00038200191089085}, -- Silverpine
		[17] = {x=0.00079576990434102,y=0.0011931381055287}, -- Stormwind
		[18] = {x=0.00016783603600093,y=0.00025128040994917}, -- Stranglethorn
		[19] = {x=0.00046689595494952,y=0.00070027368409293}, -- Swamp of Sorrows
		[20] = {x=0.0002777065549578,y=0.00041729531117848}, -- Hinterlands
		[21] = {x=0.00023638989244189,y=0.0003550010068076}, -- Tirisfal
		[22] = {x=0.0011167100497655,y=0.0016737942184721}, -- Undercity
		[23] = {x=0.00024908781051636,y=0.00037342309951782}, -- Western Plaguelands
		[24] = {x=0.00030591232436044,y=0.00045816733368805},-- Westfall
		[25] = {x=0.00025879591703415,y=0.00038863212934562}, -- Wetlands
	}
}

local ZonemapzhCN = {
	[1] = {
		[0] = 0,
		[1] = 21,
		[2] = 5,
		[3] = 18,
		[4] = 15,
		[5] = 12,
		[6] = 20,
		[7] = 7,
		[8] = 13,
		[9] = 10,
		[10] = 6,
		[11] = 16,
		[12] = 1,
		[13] = 14,
		[14] = 2,
		[15] = 11,
		[16] = 9,
		[17] = 17,
		[18] = 8,
		[19] = 4,
		[20] = 20,
		[21] = 3,
	},
	[2] = {
		[0] = 0,
		[1] = 9,
		[2] = 7,
		[3] = 1,
		[4] = 11,
		[5] = 22,
		[6] = 19,
		[7] = 21,
		[8] = 8,
		[9] = 17,
		[10] = 13,
		[11] = 25,
		[12] = 15,
		[13] = 5,
		[14] = 10,
		[15] = 18,
		[16] = 3,
		[17] = 23,
		[18] = 24,
		[19] = 4,
		[20] = 14,
		[21] = 20,
		[22] = 6,
		[23] = 12,
		[24] = 16,
		[25] = 2,
	},
}

local HealSpells = {
    ["DRUID"] = {
		[string.lower(BS["Healing Touch"])] = true,
		[string.lower(BS["Regrowth"])] = true,
		[string.lower(BS["Rejuvenation"])] = true,
	},
    ["PALADIN"] = {
		[string.lower(BS["Flash of Light"])] = true,
		[string.lower(BS["Holy Light"])] = true,
	},
    ["PRIEST"] = {
		[string.lower(BS["Flash Heal"])] = true,
		[string.lower(BS["Lesser Heal"])] = true,
		[string.lower(BS["Heal"])] = true,
		[string.lower(BS["Greater Heal"])] = true,
		[string.lower(BS["Renew"])] = true,
	},
    ["SHAMAN"] = {
		[string.lower(BS["Chain Heal"])] = true,
		[string.lower(BS["Lesser Healing Wave"])] = true,
		[string.lower(BS["Healing Wave"])] = true,
	},
}

-- This table needs to be localized, of course
local events

if ( GetLocale() == "koKR" ) then
	events = {
		CHAT_MSG_COMBAT_PARTY_HITS = "(.+)|1이;가; .-|1을;를; 공격하여 %d+의 [^%s]+ 입혔습니다",
		CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS = "(.+)|1이;가; .-|1을;를; 공격하여 %d+의 [^%s]+ 입혔습니다",
		CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS = ".-의 공격을 받아 %d+의 [^%s]+ 입었습니다",
		CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS = ".+|1이;가; ([^%s]+)|1을;를; 공격하여 %d+의 [^%s]+ 입혔습니다",
		CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS = ".+|1이;가; ([^%s]+)|1을;를; 공격하여 %d+의 [^%s]+ 입혔습니다",

		CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE = {".-|1이;가; .+|1으로;로; 당신에게 %d+의 .- 입혔습니다", ".-|1이;가; .-|1으로;로; 공격했지만 저항했습니다"},
		CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE = {".-|1이;가; .+|1으로;로; (.-)에게 %d+의 .- 입혔습니다", ".-|1이;가; .-|1으로;로; (.-)|1을;를; 공격했지만 저항했습니다"},
		CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE = {".-|1이;가; .+|1으로;로; (.-)에게 %d+의 .- 입혔습니다", ".-|1이;가; .-|1으로;로; (.-)|1을;를; 공격했지만 저항했습니다"},

		CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF = "([^%s]+)의 .+%.",
		CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE = "(.-)|1이;가; .+|1으로;로; .-에게 %d+의 .- 입혔습니다",
		CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE = ".-|1이;가; .+|1으로;로; (.-)에게 %d+의 .- 입혔습니다",
		CHAT_MSG_SPELL_PARTY_BUFF = "([^%s]+)의 .+%.",
		CHAT_MSG_SPELL_PARTY_DAMAGE = "(.-)|1이;가; .+|1으로;로; .-에게 %d+의 .- 입혔습니다",
		--CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE = ".-|1이;가; ([^%s]+)의 .-에 의해 %d+의 .+",
		CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS = "([^%s]+)|1이;가; .+%.",
		CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE = "([^%s]+)|1이;가; .-에 의해 %d+의 .+",
		CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE = "([^%s]+)|1이;가; .-에 의해 %d+의 .+",
		CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE = "([^%s]+)|1이;가; .-에 의해 %d+의 .+",
		CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS = "([^%s]+)|1이;가; .+%.",
	}
else
	events = {
		CHAT_MSG_COMBAT_PARTY_HITS = {L["CHAT_MSG_COMBAT_HITS"],L["CHAT_MSG_COMBAT_CRITS"]},
		CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS = {L["CHAT_MSG_COMBAT_HITS"],L["CHAT_MSG_COMBAT_CRITS"]},
		CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS = {L["CHAT_MSG_COMBAT_CREATURE_VS_HITS"],L["CHAT_MSG_COMBAT_CREATURE_VS_CRITS"]},
		CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS = {L["CHAT_MSG_COMBAT_CREATURE_VS_HITS"],L["CHAT_MSG_COMBAT_CREATURE_VS_CRITS"]},
		CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS = {L["CHAT_MSG_COMBAT_CREATURE_VS_HITS"],L["CHAT_MSG_COMBAT_CREATURE_VS_CRITS"],L["CHAT_MSG_COMBAT_CREATURE_VS_CRITS2"]},

		CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE = {L["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE1"], L["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE2"], L["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE3"]},
		CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE = {L["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE1"], L["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE2"], L["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE3"]},
		CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE = {L["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE1"], L["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE2"], L["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE3"]},

		CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF = L["CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF"],
		CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE = {L["CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE"],L["CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE2"]},
		CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE = L["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE1"],
		CHAT_MSG_SPELL_PARTY_BUFF = L["CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF"],
		CHAT_MSG_SPELL_PARTY_DAMAGE = {L["CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE"],L["CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE2"]},
		CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS = L["CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS"],
		CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE = {L["CHAT_MSG_SPELL_PERIODIC_DAMAGE"], L["CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"]},
		CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE = {L["CHAT_MSG_SPELL_PERIODIC_DAMAGE"], L["CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"]},
		CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE = L["CHAT_MSG_SPELL_PERIODIC_DAMAGE"],
		CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS = {L["CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS1"], L["CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS2"]},

		CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES = {L["CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES1"], L["CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES2"], L["CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES3"], L["CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES4"]},
		CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF = {L["CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF1"], L["CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF"]},
	}
end

local function ParseCombatMessage(eventstr, clString)
	local unit
	if type(eventstr) == "string" then
		local _, _, unitname = string.find(clString, eventstr)
		if unitname and (unitname ~= L["you"] and unitname ~= L["You"]) then
			unit = rosterLib:GetUnitIDFromName(unitname)
			if unit then
				roster[unit] = GetTime()
			end
		end
	elseif type(eventstr) == "table" then
		for _,val in pairs(eventstr) do
			local _, _, unitname = string.find(clString, val)
			if unitname and (unitname ~= L["you"] and unitname ~= L["You"]) then
				unit = rosterLib:GetUnitIDFromName(unitname)
				if unit then
					roster[unit] = GetTime()
					return
				end
			end
		end
	end
end

local function OnUpdate()
	Range:FullUpdate(this:GetParent())
end

local function OnEvent()
	if event == "ZONE_CHANGED_NEW_AREA" or not event then
		SetMapToCurrentZone()
		Continent = GetCurrentMapContinent()
		Zone = GetCurrentMapZone()
		if GetLocale() == "zhCN" and Continent > 0 then
			Zone = ZonemapzhCN[Continent][Zone]
		end
		ZoneName = GetZoneText()
		if ZoneName == BZ["Warsong Gulch"] or ZoneName == BZ["Arathi Basin"] or ZoneName == BZ["Alterac Valley"] then
			Zone = ZoneName
		end
	elseif LunaUF.db.profile.RangeCLparsing and events[event] then
		ParseCombatMessage(events[event], arg1)
	end
end

OnEvent()
ZoneWatch:SetScript("OnEvent", OnEvent)
ZoneWatch:RegisterEvent("ZONE_CHANGED_NEW_AREA")
for i in pairs(events) do ZoneWatch:RegisterEvent(i) end

function Range:GetRange(UnitID)
    if UnitExists(UnitID) and UnitIsVisible(UnitID) then
		local _,instance = IsInInstance()

		if CheckInteractDistance(UnitID, 1) then
			return 10
		elseif CheckInteractDistance(UnitID, 3) then
			return 10
		elseif CheckInteractDistance(UnitID, 4) then
			return 30
		elseif (instance == "none" or instance == "pvp") and not WorldMapFrame:IsVisible() then
			local px, py, ux, uy, distance
			SetMapToCurrentZone()
			px, py = GetPlayerMapPosition("player")
			ux, uy = GetPlayerMapPosition(UnitID)
			if Zone ~= 0 and Continent ~= 0 then
				distance = sqrt(((px - ux)/MapScales[Continent][Zone].x)^2 + ((py - uy)/MapScales[Continent][Zone].y)^2)
			else
				local xDelta, yDelta;
				px, py = px*MapScales[Continent][Zone].x, py*MapScales[Continent][Zone].y
				ux, uy = ux*MapScales[Continent][Zone].x, uy*MapScales[Continent][Zone].y
				xDelta = (ux - px)
				yDelta = (uy - py)
				distance = sqrt(xDelta*xDelta + yDelta*yDelta)
			end
			return distance
		elseif (GetTime() - (roster[UnitID] or 0)) < 4 then
			return 40
		else
			return 45
		end
    end
	return 100
end

function Range:ScanRoster()
	if not SpellIsTargeting() then return end
	-- We have a valid 40y spell on the cursor so we can now easily check the range.
	for i=1,40 do
		local unit = "raid"..i
		if not UnitExists(unit) then
			break
		end
		if SpellCanTargetUnit(unit) then
			roster[unit] = GetTime()
		end
		unit = "raidpet"..i
		if UnitExists(unit) and SpellCanTargetUnit(unit) then
			roster[unit] = GetTime()
		end
	end
	for i=1,4 do
		local unit = "party"..i
		if not UnitExists(unit) then
			break
		end
		if SpellCanTargetUnit(unit) then
			roster[unit] = GetTime()
		end
		unit = "partypet"..i
		if UnitExists(unit) and SpellCanTargetUnit(unit) then
			roster[unit] = GetTime()
		end
	end
end

function Range:CastSpell(spellId, spellbookTabNum)
	self.hooks.CastSpell(spellId, spellbookTabNum)
	if SpellIsTargeting() then
		local spell = GetSpellName(spellId, spellbookTabNum)
		spell = string.lower(spell)
		if HealSpells[playerClass] and HealSpells[playerClass][spell] then
			if not self:IsEventScheduled("ScanRoster") then
				self:ScheduleRepeatingEvent("ScanRoster", self.ScanRoster, 2)
			end
			self:ScanRoster()
		end
	end
end

function Range:CastSpellByName(spellName, onSelf)
	self.hooks.CastSpellByName(spellName, onSelf)
	if SpellIsTargeting() then
		local _,_,spell = string.find(spellName, "^([^%(]+)")
		spell = string.lower(spell)
		if HealSpells[playerClass] and HealSpells[playerClass][spell] then
			if not self:IsEventScheduled("ScanRoster") then
				self:ScheduleRepeatingEvent("ScanRoster", self.ScanRoster, 2)
			end
			self:ScanRoster()
		end
	end
end

function Range:UseAction(slot, checkCursor, onSelf)
	self.hooks.UseAction(slot, checkCursor, onSelf)
	if not GetActionText(slot) and SpellIsTargeting() then
		ScanTip:ClearLines()
		ScanTip:SetAction(slot)
		local spell = LunaScanTipTextLeft1:GetText()
		spell = string.lower(spell)
		if HealSpells[playerClass] and HealSpells[playerClass][spell] then
			if not self:IsEventScheduled("ScanRoster") then
				self:ScheduleRepeatingEvent("ScanRoster", self.ScanRoster, 2)
			end
			self:ScanRoster()
		end
	end
end

function Range:SpellStopTargeting()
	self.hooks.SpellStopTargeting()
	if self:IsEventScheduled("ScanRoster") then
		self:CancelScheduledEvent("ScanRoster")
	end
end

function Range:OnEnable(frame)
	if not frame.range then
		frame.range = CreateFrame("Frame", nil, frame)
	end
	frame.range.lastUpdate = GetTime() - 5
	frame.range:SetScript("OnUpdate", OnUpdate)
end

function Range:OnDisable(frame)
	if frame.range then
		frame.range:SetScript("OnUpdate", nil)
	end
end

function Range:FullUpdate(frame)
	if frame.DisableRangeAlpha or (GetTime() - frame.range.lastUpdate) < (LunaUF.db.profile.RangePolRate or 1.5) then return end
	frame.range.lastUpdate = GetTime()
	local range = self:GetRange(frame.unit)

	local healththreshold = LunaUF.db.profile.units.raid.healththreshold
	if (not healththreshold.enabled) then
		if range <= 40 then
			frame:SetAlpha(LunaUF.db.profile.units[frame.unitGroup].fader.enabled and LunaUF.db.profile.units[frame.unitGroup].fader.combatAlpha or 1)
		else
			frame:SetAlpha(LunaUF.db.profile.units[frame.unitGroup].range.alpha)
		end
	else -- TODO Remove dependency on the Range module for healththreshold.
		local percent = UnitHealth(frame.unit) / UnitHealthMax(frame.unit)
		if (range <= 40) then
			if (percent <= healththreshold.threshold) then				
				frame:SetAlpha(healththreshold.inRangeBelowAlpha)
			else
				frame:SetAlpha(healththreshold.inRangeAboveAlpha)
			end
		else
			if (percent <= healththreshold.threshold) then
				frame:SetAlpha(healththreshold.outOfRangeBelowAlpha)
			else
				frame:SetAlpha(LunaUF.db.profile.units[frame.unitGroup].range.alpha)
			end
		end
	end


end

if HealSpells[playerClass] then -- only hook on healing classes
	Range:Hook("CastSpell")
	Range:Hook("CastSpellByName")
	Range:Hook("UseAction")
	Range:Hook("SpellStopTargeting")
end
