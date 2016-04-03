local Indicators = {
	list = {
		["status"] = {"Interface\\CharacterFrame\\UI-StateIcon"},
		["pvp"] = {"Interface\\TargetingFrame\\UI-PVP-FFA", "UNIT_FACTION"},
		["leader"] = {"Interface\\GroupFrame\\UI-Group-LeaderIcon", "PARTY_LEADER_CHANGED"},
		["masterLoot"] = {"Interface\\GroupFrame\\UI-Group-MasterLooter"},
		["raidTarget"] = {"Interface\\TargetingFrame\\UI-RaidTargetingIcons", "RAID_TARGET_UPDATE"},
		["happiness"] = {"Interface\\PetPaperDollFrame\\UI-PetHappiness", "UNIT_HAPPINESS"},
		["ready"] = {"Interface\\AddOns\\LunaUnitFrames\\media\\textures\\ReadyCheck-Waiting", "CHAT_MSG_ADDON"},
		["class"] = {"Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"},
		["rezz"] = {"Interface\\AddOns\\LunaUnitFrames\\media\\textures\\Raid-Icon-Rez"},
		["pvprank"] = {"Interface\\PvPRankBadges\\PvPRank01"},
		["elite"] = {"Interface\\AddOns\\LunaUnitFrames\\media\\textures\\UI-DialogBox-Gold-Dragon"},
	},
}
LunaUF:RegisterModule(Indicators, "indicators", LunaUF.L["Indicators"])
local AceEvent = LunaUF.AceEvent
local L = LunaUF.L
local HealComm = LunaUF.HealComm
local lootmaster
local readycheck = {}

local function AceOnEvent(arg1)
	if event == "HealComm_Ressupdate" then
		for _,frame in pairs(LunaUF.Units.frameList) do
			if frame.indicators and frame.indicators.rezz and LunaUF.db.profile.locked then
				if frame.unit and UnitName(frame.unit) == arg1 then
					if HealComm:UnitisResurrecting(UnitName(frame.unit)) and LunaUF.db.profile.units[frame.unitGroup].indicators.icons.rezz.enabled then
						frame.indicators.rezz:Show()
					else
						frame.indicators.rezz:Hide()
					end
				end
			end
		end
		return
	elseif event == "CHAT_MSG_SYSTEM" then
		_,_,lootmaster = string.find(arg1,L["(%a+) is now the loot master."])
		if not lootmaster then return end
	elseif event == "PARTY_LOOT_METHOD_CHANGED" then
		local LootMethod = GetLootMethod()
		if LootMethod ~= "master" and lootmaster then
			lootmaster = nil
		else
			return
		end
	end
	for _,frame in pairs(LunaUF.Units.frameList) do
		if frame.indicators and frame.indicators.masterLoot then
			if frame.unit and UnitName(frame.unit) == lootmaster then
				frame.indicators.masterLoot:Show()
			else
				frame.indicators.masterLoot:Hide()
			end
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
	if (UnitAffectingCombat(frame.unit) or not LunaUF.db.profile.locked) and config.status.enabled then
		frame.indicators.status:SetTexCoord(0.50, 1.0, 0.0, 0.49)
		frame.indicators.status:Show()
	elseif( frame.unitGroup == "player" and IsResting() and config.status.enabled ) then
		frame.indicators.status:SetTexCoord(0.0, 0.50, 0.0, 0.421875)
		frame.indicators.status:Show()
	else
		frame.indicators.status:Hide()
	end
end

local function clearReadyCheck()
	for groupmember,ready in pairs(readycheck) do
		readycheck[groupmember] = nil
	end
end

local function OnEvent()
	local frame = this:GetParent()
	local config = LunaUF.db.profile.units[frame.unitGroup].indicators.icons
	if event == "CHAT_MSG_ADDON" and arg1 == "CTRA" then
		if arg2 == "CHECKREADY" then
			clearReadyCheck()
		elseif arg2 == "READY" then
			--arg4 voted ready
		elseif arg2 == "NOTREADY" then
			--arg4 voted not ready
		end
	elseif event == "PARTY_LEADER_CHANGED" or event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
		if ((UnitIsPartyLeader(frame.unit) and (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0)) or not LunaUF.db.profile.locked) and config.leader.enabled then
			frame.indicators.leader:Show()
		else
			frame.indicators.leader:Hide()
		end
	elseif event == "RAID_TARGET_UPDATE" then
		if frame.indicators.raidTarget then
			if GetRaidTargetIndex(frame.unit) and config.raidTarget.enabled then
				SetRaidTargetIconTexture(frame.indicators.raidTarget, GetRaidTargetIndex(frame.unit))
				frame.indicators.raidTarget:Show()
			elseif not LunaUF.db.profile.locked and config.raidTarget.enabled then
				SetRaidTargetIconTexture(frame.indicators.raidTarget, 1)
				frame.indicators.raidTarget:Show()
			else
				frame.indicators.raidTarget:Hide()
			end
		end
	elseif event == "UNIT_HAPPINESS" then
		if frame.indicators.happiness then
			local happiness = GetPetHappiness()
			-- No pet
			if (not happiness and LunaUF.db.profile.locked) or not config.happiness.enabled then
				frame.indicators.happiness:Hide()
			-- Happy :D
			elseif happiness == 3 then
				frame.indicators.happiness:SetTexCoord(0, 0.1875, 0, 0.359375)
				frame.indicators.happiness:Show()
			-- Content :|
			elseif happiness == 2 then
				frame.indicators.happiness:SetTexCoord(0.1875, 0.375, 0, 0.359375)
				frame.indicators.happiness:Show()
			-- Unhappy :(
			elseif happiness == 1 then
				frame.indicators.happiness:SetTexCoord(0.375, 0.5625, 0, 0.359375)
				frame.indicators.happiness:Show()
			else
				frame.indicators.happiness:SetTexCoord(0, 0.1875, 0, 0.359375)
				frame.indicators.happiness:Show()
			-- Config mode
			end
		end
	elseif event == "UNIT_FACTION" then
		if frame.indicators.pvp then
			if( UnitIsPVP(frame.unit) and UnitFactionGroup(frame.unit) and config.pvp.enabled ) then
				frame.indicators.pvp:SetTexture(string.format("Interface\\TargetingFrame\\UI-PVP-%s", UnitFactionGroup(frame.unit)))
				frame.indicators.pvp:Show()
			elseif( UnitIsPVPFreeForAll(frame.unit) ) then
				frame.indicators.pvp:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
				frame.indicators.pvp:Show()
			elseif not LunaUF.db.profile.locked and config.pvp.enabled then
				frame.indicators.pvp:SetTexture(string.format("Interface\\TargetingFrame\\UI-PVP-%s", UnitFactionGroup("player")))
				frame.indicators.pvp:Show()
			else
				frame.indicators.pvp:Hide()
			end
		end
	end
end

function Indicators:OnEnable(frame)
	if not frame.indicators then
		frame.indicators = CreateFrame("Frame", nil, frame)
		frame.indicators.timeElapsed = 0
		frame.indicators:SetFrameLevel(5)
		for name in pairs(LunaUF.db.profile.units[frame.unitGroup].indicators.icons) do
			frame.indicators[name] = frame.indicators:CreateTexture(nil, "OVERLAY")
			frame.indicators[name]:SetTexture(self.list[name][1])
			if self.list[name][2] then
				frame.indicators:RegisterEvent(self.list[name][2])
			end
			if name == "leader" then
				frame.indicators:RegisterEvent("PARTY_MEMBERS_CHANGED")
				frame.indicators:RegisterEvent("RAID_ROSTER_UPDATE")
			end
		end
	end
	if not AceEvent:IsEventRegistered("CHAT_MSG_SYSTEM") then
		AceEvent:RegisterEvent("CHAT_MSG_SYSTEM", AceOnEvent)
	end
	if not AceEvent:IsEventRegistered("PARTY_LOOT_METHOD_CHANGED") then
		AceEvent:RegisterEvent("CHAT_MSG_SYSTEM", AceOnEvent)
	end
	if not AceEvent:IsEventRegistered("HealComm_Ressupdate") then
		AceEvent:RegisterEvent("HealComm_Ressupdate", AceOnEvent)
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
	if frame.indicators.pvprank then
		local rankNumber = UnitPVPRank(frame.unit)
		if rankNumber and config.pvprank.enabled then
			if not LunaUF.db.profile.locked then
				frame.indicators.pvprank:SetTexture("Interface\\PvPRankBadges\\PvPRank14");
				frame.indicators.pvprank:Show()
			elseif (rankNumber == 0) then
				frame.indicators.pvprank:Hide()
			elseif (rankNumber < 14) then
				rankNumber = rankNumber - 4
				frame.indicators.pvprank:SetTexture("Interface\\PvPRankBadges\\PvPRank0"..rankNumber);
				frame.indicators.pvprank:Show()
			else
				rankNumber = rankNumber - 4
				frame.indicators.pvprank:SetTexture("Interface\\PvPRankBadges\\PvPRank"..rankNumber);
				frame.indicators.pvprank:Show()
			end
		end
	end
	if frame.indicators.elite then
		local classification = UnitClassification(frame.unit)
		if (classification == "elite" or classification == "rareelite" or not LunaUF.db.profile.locked) and config.elite.enabled then
			if LunaUF.db.profile.units[frame.unitGroup].portrait.side == "right" then
				frame.indicators.elite:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\UI-DialogBox-Gold-Dragon-right")
			else
				frame.indicators.elite:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\UI-DialogBox-Gold-Dragon")
			end
			frame.indicators.elite:Show()
		else
			frame.indicators.elite:Hide()
		end
	end
	if frame.indicators.rezz then
		local rezztime = HealComm:UnitisResurrecting(UnitName(frame.unit))
		if (rezztime or not LunaUF.db.profile.locked) and config.rezz.enabled then
			frame.indicators.rezz:Show()
		else
			frame.indicators.rezz:Hide()
		end
	end
	if frame.indicators.masterLoot then
		if frame.unit and (UnitName(frame.unit) == lootmaster or not LunaUF.db.profile.locked) and config.masterLoot.enabled then
			frame.indicators.masterLoot:Show()
		else
			frame.indicators.masterLoot:Hide()
		end
	end
	if frame.indicators.leader then
		if ((UnitIsPartyLeader(frame.unit) and (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0)) or not LunaUF.db.profile.locked) and config.leader.enabled then
			frame.indicators.leader:Show()
		else
			frame.indicators.leader:Hide()
		end
	end
	if frame.indicators.pvp then
		if( UnitIsPVP(frame.unit) and UnitFactionGroup(frame.unit) and config.pvp.enabled) then
			--LunaUF.AllianceCheck
			frame.indicators.pvp:SetTexture(LunaUF.AllianceCheck[LunaUF.playerRace] and "Interface\\TargetingFrame\\UI-PVP-Alliance" or "Interface\\TargetingFrame\\UI-PVP-Horde")
			frame.indicators.pvp:Show()
		elseif( UnitIsPVPFreeForAll(frame.unit) and config.pvp.enabled ) then
			frame.indicators.pvp:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
			frame.indicators.pvp:Show()
		elseif not LunaUF.db.profile.locked and config.pvp.enabled then
			frame.indicators.pvp:SetTexture(LunaUF.AllianceCheck[LunaUF.playerRace] and "Interface\\TargetingFrame\\UI-PVP-Alliance" or "Interface\\TargetingFrame\\UI-PVP-Horde")
			frame.indicators.pvp:Show()
		else
			frame.indicators.pvp:Hide()
		end
	end
	if frame.indicators.status then
		if UnitAffectingCombat(frame.unit) and config.status.enabled then
			frame.indicators.status:SetTexCoord(0.50, 1.0, 0.0, 0.49)
			frame.indicators.status:Show()
		elseif( frame.unitGroup == "player" and IsResting() and config.status.enabled ) then
			frame.indicators.status:SetTexCoord(0.0, 0.50, 0.0, 0.421875)
			frame.indicators.status:Show()
		elseif not LunaUF.db.profile.locked and config.status.enabled then
			frame.indicators.status:SetTexCoord(0.50, 1.0, 0.0, 0.49)
			frame.indicators.status:Show()
		else
			frame.indicators.status:Hide()
		end
	end
	if frame.indicators.raidTarget then
		if GetRaidTargetIndex(frame.unit) and config.raidTarget.enabled then
			SetRaidTargetIconTexture(frame.indicators.raidTarget, GetRaidTargetIndex(frame.unit))
			frame.indicators.raidTarget:Show()
		elseif not LunaUF.db.profile.locked and config.raidTarget.enabled then
			SetRaidTargetIconTexture(frame.indicators.raidTarget, 1)
			frame.indicators.raidTarget:Show()
		else
			frame.indicators.raidTarget:Hide()
		end
	end
	if frame.indicators.happiness then
		local happiness = GetPetHappiness()
		-- No pet
		if (not happiness and LunaUF.db.profile.locked) or not config.happiness.enabled then
			frame.indicators.happiness:Hide()
		-- Happy :D
		elseif happiness == 3 then
			frame.indicators.happiness:SetTexCoord(0, 0.1875, 0, 0.359375)
			frame.indicators.happiness:Show()
		-- Content :|
		elseif happiness == 2 then
			frame.indicators.happiness:SetTexCoord(0.1875, 0.375, 0, 0.359375)
			frame.indicators.happiness:Show()
		-- Unhappy :(
		elseif happiness == 1 then
			frame.indicators.happiness:SetTexCoord(0.375, 0.5625, 0, 0.359375)
			frame.indicators.happiness:Show()
		else
			frame.indicators.happiness:SetTexCoord(0, 0.1875, 0, 0.359375)
			frame.indicators.happiness:Show()
		-- Config Mode
		end
	end
	if frame.indicators.class then
		local _,class = UnitClass(frame.unit)
		if( UnitIsPlayer(frame.unit) and class and config.class.enabled) then
			local coords = LunaUF.constants.CLASS_ICON_TCOORDS[class]
			frame.indicators.class:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
			frame.indicators.class:Show()
		else
			frame.indicators.class:Hide()
		end
	end
end