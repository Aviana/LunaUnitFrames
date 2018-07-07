local LunaUF = LunaUF
local Indicators = {
	list = {
		["status"] = {"Interface\\CharacterFrame\\UI-StateIcon"},
		["pvp"] = {"Interface\\TargetingFrame\\UI-PVP-FFA", "UNIT_FACTION"},
		["leader"] = {"Interface\\GroupFrame\\UI-Group-LeaderIcon", "PARTY_LEADER_CHANGED"},
		["masterLoot"] = {"Interface\\GroupFrame\\UI-Group-MasterLooter", "PARTY_LOOT_METHOD_CHANGED"},
		["raidTarget"] = {"Interface\\TargetingFrame\\UI-RaidTargetingIcons", "RAID_TARGET_UPDATE"},
		["happiness"] = {"Interface\\PetPaperDollFrame\\UI-PetHappiness", "UNIT_HAPPINESS"},
		["ready"] = {"Interface\\AddOns\\LunaUnitFrames\\media\\textures\\ReadyCheck-Waiting"},
		["class"] = {"Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"},
		["rezz"] = {"Interface\\AddOns\\LunaUnitFrames\\media\\textures\\Raid-Icon-Rez"},
		["pvprank"] = {"Interface\\PvPRankBadges\\PvPRank01", "PLAYER_PVP_RANK_CHANGED"},
		["elite"] = {"Interface\\AddOns\\LunaUnitFrames\\media\\textures\\UI-DialogBox-Gold-Dragon"},
	},
}
LunaUF:RegisterModule(Indicators, "indicators", LunaUF.L["Indicators"])
local L = LunaUF.L
local HealComm = LunaUF.HealComm
local readychecking, afterreadycheck
local numVoted = 0
local readycheck = {}
local lootmaster	-- this value only updates in OnAceEvent

-- the config.%s.enabled must be checked first because it's a must-check term
-- the LunaUF.db.profile.locked must be checked as late as possible because this will usually be a true value
-- here is an example for it, this will improve the speed of the framework
local function UpdateHappiness(enabled, indicator)
	if not enabled then
		indicator:Hide()
	else

		local happiness = GetPetHappiness()

		-- Happy :D
		if happiness == 3 then
			indicator:SetTexCoord(0, 0.1875, 0, 0.359375)
		-- Content :|
		elseif happiness == 2 then
			indicator:SetTexCoord(0.1875, 0.375, 0, 0.359375)
		-- Unhappy :(
		elseif happiness == 1 then
			indicator:SetTexCoord(0.375, 0.5625, 0, 0.359375)
		-- Config Mode
		else
			indicator:SetTexCoord(0, 0.1875, 0, 0.359375)
		end

		if happiness or not LunaUF.db.profile.locked then
			indicator:Show()
		else
			indicator:Hide()
		end
	end
end

local function UpdatePVP(enabled, indicator, unit)
	if not enabled then
		indicator:Hide()
	else
		if UnitIsPVPFreeForAll(unit) then
			indicator:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
			indicator:Show()
		elseif UnitIsPVP(unit) or not LunaUF.db.profile.locked then
			local _,race = UnitRace(unit)
			indicator:SetTexture((UnitFactionGroup(unit) == "Alliance" or LunaUF.AllianceCheck[race]) and "Interface\\TargetingFrame\\UI-PVP-Alliance" or "Interface\\TargetingFrame\\UI-PVP-Horde")
			indicator:Show()
		else
			indicator:Hide()
		end
	end
end

local function UpdateRaidTarget(enabled, indicator, unit)
	if not enabled then
		indicator:Hide()
	elseif GetRaidTargetIndex(unit) then
		SetRaidTargetIconTexture(indicator, GetRaidTargetIndex(unit))
		indicator:Show()
	elseif not LunaUF.db.profile.locked then
		SetRaidTargetIconTexture(indicator, 1)
		indicator:Show()
	else
		indicator:Hide()
	end
end

local function UpdateLeader(enabled, indicator, unit)
	if not enabled then
		indicator:Hide()
	elseif ((UnitIsPartyLeader(unit) and (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0)) or not LunaUF.db.profile.locked) then
		indicator:Show()
	else
		indicator:Hide()
	end
end

local function UpdatePVPRank(enabled, indicator, unit)
	if not enabled then
		indicator:Hide()
	else
		local rank = UnitPVPRank(unit)
		if rank then
			if rank < 5 then
				indicator:Hide()
			else
				rank = rank - 4
				if rank < 10 then
					indicator:SetTexture("Interface\\PvPRankBadges\\PvPRank0"..rank);
				else
					indicator:SetTexture("Interface\\PvPRankBadges\\PvPRank"..rank);
				end
				indicator:Show()
			end
		elseif not LunaUF.db.profile.locked then
			indicator:SetTexture("Interface\\PvPRankBadges\\PvPRank14");
			indicator:Show()
		else
			indicator:Hide()
		end
	end
end

local function UpdateKOS(enabled, indicator, unit, unitGroup)
	if not UnitIsPlayer(unit) then return end
	if not enabled then
		indicator:Hide()
	else
		local classification
		local guild = string.gsub(string.lower(GetGuildInfo(unit) or "_"), "%s", "_")
		local name = string.lower(UnitName(unit))
		if OpiumData and OpiumData.kosPlayer[GetCVar("realmName")] and OpiumData.kosPlayer[GetCVar("realmName")][name] then
			classification = "elite"
		elseif OpiumData and OpiumData.kosGuild[GetCVar("realmName")] and OpiumData.kosGuild[GetCVar("realmName")][guild] then
			classification = "rare"
		end
		local texture
		if classification == "elite" or classification == "rareelite" or classification == "worldboss" or not LunaUF.db.profile.locked then
			texture = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\UI-DialogBox-Gold-Dragon"
		elseif classification == "rare" then
			texture = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\UI-DialogBox-Silver-Dragon"
		else
			texture = nil
		end

		if texture then
			if LunaUF.db.profile.units[unitGroup].portrait.side == "right" then
				texture = texture .. "-right"
			end
			indicator:SetTexture(texture)
			indicator:Show()
		else
			indicator:Hide()
		end
	end
end

local function UpdateElite(enabled, indicator, unit, unitGroup)
	if UnitIsPlayer(unit) then return end
	if not enabled then
		indicator:Hide()
	else
		local classification = UnitClassification(unit)
		local texture
		if classification == "elite" or classification == "rareelite" or classification == "worldboss" or not LunaUF.db.profile.locked then
			texture = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\UI-DialogBox-Gold-Dragon"
		elseif classification == "rare" then
			texture = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\UI-DialogBox-Silver-Dragon"
		else
			texture = nil
		end

		if texture then
			if LunaUF.db.profile.units[unitGroup].portrait.side == "right" then
				texture = texture .. "-right"
			end
			indicator:SetTexture(texture)
			indicator:Show()
		else
			indicator:Hide()
		end
	end
end

local function UpdateRezz(enabled, indicator, unit)
	if not enabled then
		indicator:Hide()
	else
		if HealComm:UnitisResurrecting(UnitName(unit)) or not LunaUF.db.profile.locked then
			indicator:Show()
		else
			indicator:Hide()
		end
	end
end

local function GetLootMaster()
	local lootmethod, pid, rid = GetLootMethod()
	if lootmethod == "master" and (UnitInRaid("player") or GetNumPartyMembers() > 0) then
		if pid then
			return GetUnitName(pid == 0 and "player" or "party"..pid)
		elseif rid then
			return GetUnitName("raid"..rid)
		else
			return lootmaster
		end
	elseif lootmethod == "group" and pid then
		return GetUnitName((pid == 0 and "player") or "party"..pid)
	end
end

local function UpdateMasterLoot(enabled, indicator, unit)
	if not enabled or not (UnitInRaid("player") or GetNumPartyMembers() > 0) then
		indicator:Hide()
	else
		local name = UnitName(unit)
		if (name and name == GetLootMaster()) or not LunaUF.db.profile.locked then
			indicator:Show()
		else
			indicator:Hide()
		end
	end
end

local function UpdateReady(enabled, indicator, unit)
	if not enabled then
		indicator:Hide()
	elseif not LunaUF.db.profile.locked then
		indicator:Show()
	elseif not readychecking and not afterreadycheck then
		indicator:Hide()
	else
		local v = UnitName(unit)
		if not v then
			indicator:Hide()
		elseif not afterreadycheck then
			v = readycheck[v]
			if v == 2 then
				indicator:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\ReadyCheck-NotReady")
			elseif v == 1 then
				indicator:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\ReadyCheck-Ready")
			else
				indicator:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\ReadyCheck-Waiting")
			end
			indicator:Show()
		else
			v = readycheck[v]
			if v == 2 then
				indicator:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\ReadyCheck-NotReady")
			else
				indicator:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\ReadyCheck-Ready")
			end
			indicator:Show()
		end
	end
end

local function UpdateStatus(enabled, indicator, unit, unitGroup)
	if not enabled then
		indicator:Hide()
	elseif UnitAffectingCombat(unit) or not LunaUF.db.profile.locked then
		indicator:SetTexCoord(0.50, 1.0, 0.0, 0.49)
		indicator:Show()
	elseif unitGroup == "player" and IsResting() then
		indicator:SetTexCoord(0.0, 0.50, 0.0, 0.421875)
		indicator:Show()
	else
		indicator:Hide()
	end
end

local function UpdateClass(enabled, indicator, unit)
	if not enabled then
		indicator:Hide()
	else
		local _,class = UnitClass(unit)
		if UnitIsPlayer(unit) and class then
			local coords = LunaUF.constants.CLASS_ICON_TCOORDS[class]
			indicator:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
			indicator:Show()
		else
			indicator:Hide()
		end
	end
end

local function updateFramesReady()
	for _,frame in pairs(LunaUF.Units.frameList) do
		if frame.indicators and frame.indicators.ready then
			UpdateReady(LunaUF.db.profile.units[frame.unitGroup].indicators.icons.ready.enabled, frame.indicators.ready, frame.unit)
		end
	end
end

local function endReadyCheck()
	if readychecking then
		readychecking = nil
		afterreadycheck = true
		LunaUF:ScheduleEvent("LunaEndReadyCheckAfter", endReadyCheck, 10)
	else
		afterreadycheck = nil
		for groupmember,ready in pairs(readycheck) do
			readycheck[groupmember] = nil
		end
		updateFramesReady()
	end
end

local function clearReadyCheck()
	LunaUF:Debug("Starting readycheck")
	numVoted = 0
	readychecking = true
	afterreadycheck = nil
	for groupmember,ready in pairs(readycheck) do
		readycheck[groupmember] = nil
	end
	LunaUF:ScheduleEvent("LunaEndReadyCheck", endReadyCheck, 31)
end

local function AceOnEvent(arg1)
	if event == "HealComm_Ressupdate" then
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.indicators and frame.indicators.rezz then
				if frame.unit and UnitName(frame.unit) == arg1 then
					UpdateRezz(LunaUF.db.profile.units[frame.unitGroup].indicators.icons.rezz.enabled, frame.indicators.rezz, frame.unit)
				end
			end
		end
		return
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == "CTRA" then
			if arg2 == "CHECKREADY" then
				clearReadyCheck()
				readycheck[arg4] = 1 -- leader always ready
				numVoted = numVoted + 1
				updateFramesReady()
			elseif arg2 == "READY" then
				readycheck[arg4] = 1
				numVoted = numVoted + 1
				if numVoted >= GetNumRaidMembers() then
					LunaUF:CancelScheduledEvent("LunaEndReadyCheck")
					endReadyCheck()
				end
				updateFramesReady()
			elseif arg2 == "NOTREADY" then
				readycheck[arg4] = 2
				numVoted = numVoted + 1
				if numVoted >= GetNumRaidMembers() then
					LunaUF:CancelScheduledEvent("LunaEndReadyCheck")
					endReadyCheck()
				end
				updateFramesReady()
			end
		end
		return
	elseif event == "CHAT_MSG_SYSTEM" then
		-- loot master
		local _,_,name = string.find(arg1, L["(%a+) is now the loot master."])
		if name then
			lootmaster = name
		end
	elseif event == "PARTY_LOOT_METHOD_CHANGED" then
		lootmaster = GetLootMaster()  -- update loot master
	else
		LunaUF:Debug("Unhandled Indicator AceOnEvent: %s", event)
		return
	end
	for _,frame in pairs(LunaUF.Units.frameList) do
		if frame.indicators and frame.indicators.masterLoot then
			UpdateMasterLoot(LunaUF.db.profile.units[frame.unitGroup].indicators.icons.masterLoot.enabled, frame.indicators.masterLoot, frame.unit)
		end
	end
end

-- Non-player units do not give events when they enter or leave combat, so polling is necessary
local function combatMonitor()
	this.timeElapsed = this.timeElapsed + arg1
	if( this.timeElapsed < 1 ) then return end
	this.timeElapsed = this.timeElapsed - 1

	local frame = this:GetParent()
	local config = LunaUF.db.profile.units[frame.unitGroup].indicators.icons
	UpdateStatus(config.status.enabled, frame.indicators.status, frame.unit, frame.unitGroup)
end

local function OnEvent()
	local frame = this:GetParent()
	local config = LunaUF.db.profile.units[frame.unitGroup].indicators.icons

	if event == "PARTY_LEADER_CHANGED" then
		if frame.indicators.leader then UpdateLeader(config.leader.enabled, frame.indicators.leader, frame.unit) end
	elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
		if frame.indicators.masterLoot then UpdateMasterLoot(config.masterLoot.enabled, frame.indicators.masterLoot, frame.unit) end
		if frame.indicators.leader then UpdateLeader(config.leader.enabled, frame.indicators.leader, frame.unit) end
	elseif event == "RAID_TARGET_UPDATE" then
		if frame.indicators.raidTarget then UpdateRaidTarget(config.raidTarget.enabled, frame.indicators.raidTarget, frame.unit) end
	elseif event == "UNIT_HAPPINESS" then
		if frame.indicators.happiness then UpdateHappiness(config.happiness.enabled, frame.indicators.happiness) end
	elseif event == "UNIT_FACTION" then
		if frame.indicators.pvp then UpdatePVP(config.pvp.enabled, frame.indicators.pvp, frame.unit) end
	elseif event == "PLAYER_PVP_RANK_CHANGED" then
		if frame.indicators.pvprank then UpdatePVPRank(config.pvprank.enabled, frame.indicators.pvprank, frame.unit) end
	elseif event == "PARTY_LOOT_METHOD_CHANGED" then
		if frame.indicators.masterLoot then UpdateMasterLoot(config.masterLoot.enabled, frame.indicators.masterLoot, frame.unit) end
	else
		LunaUF:Debug("Unhandled Indicator OnEvent: %s", event)
	end
end

function Indicators:OnEnable(frame)
	if not frame.indicators then
		frame.indicators = CreateFrame("Frame", nil, frame)
		frame.indicators.timeElapsed = 0
		frame.indicators:SetFrameLevel(5)
		for name in pairs(LunaUF.db.profile.units[frame.unitGroup].indicators.icons) do
			if name == "elite" then
				frame.indicators[name] = frame.indicators:CreateTexture(nil, "ARTWORK")
			else
				frame.indicators[name] = frame.indicators:CreateTexture(nil, "OVERLAY")
			end
			frame.indicators[name]:SetTexture(self.list[name][1])
			if self.list[name][2] then
				frame.indicators:RegisterEvent(self.list[name][2])
			end
			if name == "leader" then
				frame.indicators:RegisterEvent("PARTY_MEMBERS_CHANGED")
				frame.indicators:RegisterEvent("RAID_ROSTER_UPDATE")
			elseif name == "ready" then
				frame.indicators:RegisterEvent("CHAT_MSG_SYSTEM")
			end
		end
	end
	
	
	if not LunaUF:IsEventRegistered("CHAT_MSG_ADDON", AceOnEvent) then
		LunaUF:RegisterEvent("CHAT_MSG_ADDON", AceOnEvent)
	end
	if not LunaUF:IsEventRegistered("PARTY_LOOT_METHOD_CHANGED", AceOnEvent) then
		LunaUF:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", AceOnEvent)
	end
	if not LunaUF:IsEventRegistered("CHAT_MSG_SYSTEM", AceOnEvent) then
		LunaUF:RegisterEvent("CHAT_MSG_SYSTEM", AceOnEvent)
	end
	if not LunaUF:IsEventRegistered("READY_CHECK", AceOnEvent) then
		LunaUF:RegisterEvent("READY_CHECK", AceOnEvent)
	end
	if not LunaUF:IsEventRegistered("HealComm_Ressupdate") then
		LunaUF:RegisterEvent("HealComm_Ressupdate", AceOnEvent)
	end

	frame.indicators:SetScript("OnEvent", OnEvent)
	if frame.indicators.status then
		frame.indicators:SetScript("OnUpdate", combatMonitor)
	end
end

function Indicators:OnDisable(frame)
	if frame.indicators then
		frame.indicators:UnregisterAllEvents()
		frame.indicators:SetScript("OnEvent", nil)
		frame.indicators:SetScript("OnUpdate", nil)
	end
end

function Indicators:FullUpdate(frame)
	local config = LunaUF.db.profile.units[frame.unitGroup].indicators.icons
	for name,settings in pairs(config) do
		if name ~= "enabled" then
			frame.indicators[name]:ClearAllPoints()
			frame.indicators[name]:SetPoint("CENTER", frame, settings.anchorPoint, settings.x, settings.y)
			frame.indicators[name]:SetHeight(settings.size)
			frame.indicators[name]:SetWidth(settings.size)
			frame.indicators[name]:Hide()
		end
	end
	if frame.indicators.pvprank then UpdatePVPRank(config.pvprank.enabled, frame.indicators.pvprank, frame.unit) end
	if frame.indicators.elite then UpdateElite(config.elite.enabled, frame.indicators.elite, frame.unit, frame.unitGroup) end
	if frame.indicators.elite then UpdateKOS(config.elite.kos, frame.indicators.elite, frame.unit, frame.unitGroup) end
	if frame.indicators.rezz then UpdateRezz(config.rezz.enabled, frame.indicators.rezz, frame.unit) end
	if frame.indicators.masterLoot then UpdateMasterLoot(config.masterLoot.enabled, frame.indicators.masterLoot, frame.unit) end
	if frame.indicators.leader then UpdateLeader(config.leader.enabled, frame.indicators.leader, frame.unit) end
	if frame.indicators.pvp then UpdatePVP(config.pvp.enabled, frame.indicators.pvp, frame.unit) end
	if frame.indicators.status then UpdateStatus(config.status.enabled, frame.indicators.status, frame.unit, frame.unitGroup) end
	if frame.indicators.raidTarget then UpdateRaidTarget(config.raidTarget.enabled, frame.indicators.raidTarget, frame.unit) end
	if frame.indicators.happiness then UpdateHappiness(config.happiness.enabled, frame.indicators.happiness) end
	if frame.indicators.class then UpdateClass(config.class.enabled, frame.indicators.class, frame.unit) end
	if frame.indicators.ready then UpdateReady(config.ready.enabled, frame.indicators.ready, frame.unit) end
end

local oldOpiumUpdate
if Opium_KosUpdate then
	oldOpiumUpdate = Opium_KosUpdate
	Opium_KosUpdate = function()
		oldOpiumUpdate()
		if LUFUnittarget then
			Indicators:FullUpdate(LUFUnittarget)
		end
	end
end