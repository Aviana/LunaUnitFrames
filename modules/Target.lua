local HealComm = AceLibrary("HealComm-1.0")
local AceEvent = AceLibrary("AceEvent-2.0")
local Luna_Target_Events = {}

local function Luna_Target_OnEvent()
	local func = Luna_Target_Events[event]
	if (func) then
		func()
	else
		DEFAULT_CHAT_FRAME:AddMessage("Luna Unit Frames - Target: Report the following event error to the author: "..event)
	end
end

function Luna_TargetDropDown_Initialize()
	local menu, name;
	if (UnitIsUnit("target", "player")) then
		menu = "SELF";
	elseif (UnitIsUnit("target", "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer("target")) then
		if (UnitInParty("target") or UnitInRaid("target")) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end
	if (menu) then
		UnitPopup_ShowMenu(LunaTargetFrame.dropdown, menu, "target", name);
	end
end

local function Luna_HideBlizz(frame)
	frame:UnregisterAllEvents()
	frame:Hide()
end

local function Luna_Target_SetBuffTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	if (this.id > 16) then
		GameTooltip:SetUnitDebuff("target", this.id-16)
	else
		GameTooltip:SetUnitBuff("target", this.id)
	end
end

local function Luna_Target_SetBuffTooltipLeave()
	GameTooltip:Hide()
end

local function StartMoving()
	LunaTargetFrame:StartMoving()
end

local function StopMovingOrSizing()
	LunaTargetFrame:StopMovingOrSizing()
	_,_,_,LunaOptions.frames["LunaTargetFrame"].position.x, LunaOptions.frames["LunaTargetFrame"].position.y = LunaTargetFrame:GetPoint()
end

function LunaUnitFrames:ToggleTargetLock()
	if LunaTargetFrame:IsMovable() then
		LunaTargetFrame:SetScript("OnDragStart", nil)
		LunaTargetFrame:SetMovable(0)
	else
		LunaTargetFrame:SetScript("OnDragStart", StartMoving)
		LunaTargetFrame:SetMovable(1)
	end
end

local function SetIconPositions()
	LunaTargetFrame.PVPRank:SetHeight(10 * (LunaOptions.frames["LunaTargetFrame"].iconscale or 1))
	LunaTargetFrame.PVPRank:SetWidth(10 * (LunaOptions.frames["LunaTargetFrame"].iconscale or 1))
	LunaTargetFrame.Leader:SetHeight(8 * (LunaOptions.frames["LunaTargetFrame"].iconscale or 1))
	LunaTargetFrame.Leader:SetWidth(8 * (LunaOptions.frames["LunaTargetFrame"].iconscale or 1))
	LunaTargetFrame.Loot:SetHeight(8 * (LunaOptions.frames["LunaTargetFrame"].iconscale or 1))
	LunaTargetFrame.Loot:SetWidth(8 * (LunaOptions.frames["LunaTargetFrame"].iconscale or 1))
	if LunaOptions.frames["LunaTargetFrame"].portrait == 1 then
		LunaTargetFrame.RaidIcon:ClearAllPoints()
		LunaTargetFrame.RaidIcon:SetPoint("CENTER", LunaTargetFrame, "TOP")
		LunaTargetFrame.PVPRank:ClearAllPoints()
		LunaTargetFrame.PVPRank:SetPoint("CENTER", LunaTargetFrame, "BOTTOMRIGHT", 0, 2)
		LunaTargetFrame.Leader:ClearAllPoints()
		LunaTargetFrame.Leader:SetPoint("CENTER", LunaTargetFrame, "TOPRIGHT", 0, -2)
		LunaTargetFrame.Loot:ClearAllPoints()
		LunaTargetFrame.Loot:SetPoint("CENTER", LunaTargetFrame, "TOPRIGHT", 0, -12)
		LunaTargetFrame.feedbackText:ClearAllPoints()
		LunaTargetFrame.feedbackText:SetPoint("CENTER", LunaTargetFrame, "CENTER", 0, 0)
	elseif LunaOptions.fliptarget then
		LunaTargetFrame.RaidIcon:ClearAllPoints()
		LunaTargetFrame.RaidIcon:SetPoint("CENTER", LunaTargetFrame.bars["Portrait"], "TOPLEFT")
		LunaTargetFrame.PVPRank:ClearAllPoints()
		LunaTargetFrame.PVPRank:SetPoint("CENTER", LunaTargetFrame.bars["Portrait"], "BOTTOMRIGHT", -2, 2)
		LunaTargetFrame.Leader:ClearAllPoints()
		LunaTargetFrame.Leader:SetPoint("CENTER", LunaTargetFrame.bars["Portrait"], "TOPRIGHT", -2, -2)
		LunaTargetFrame.Loot:ClearAllPoints()
		LunaTargetFrame.Loot:SetPoint("CENTER", LunaTargetFrame.bars["Portrait"], "TOPRIGHT", -2, -12)
		LunaTargetFrame.feedbackText:ClearAllPoints()
		LunaTargetFrame.feedbackText:SetPoint("CENTER", LunaTargetFrame.bars["Portrait"], "CENTER", 0, 0)
	else
		LunaTargetFrame.RaidIcon:ClearAllPoints()
		LunaTargetFrame.RaidIcon:SetPoint("CENTER", LunaTargetFrame.bars["Portrait"], "TOPRIGHT")
		LunaTargetFrame.PVPRank:ClearAllPoints()
		LunaTargetFrame.PVPRank:SetPoint("CENTER", LunaTargetFrame.bars["Portrait"], "BOTTOMLEFT", 2, 2)
		LunaTargetFrame.Leader:ClearAllPoints()
		LunaTargetFrame.Leader:SetPoint("CENTER", LunaTargetFrame.bars["Portrait"], "TOPLEFT", 2, -2)
		LunaTargetFrame.Loot:ClearAllPoints()
		LunaTargetFrame.Loot:SetPoint("CENTER", LunaTargetFrame.bars["Portrait"], "TOPLEFT", 2, -12)
		LunaTargetFrame.feedbackText:ClearAllPoints()
		LunaTargetFrame.feedbackText:SetPoint("CENTER", LunaTargetFrame.bars["Portrait"], "CENTER", 0, 0)
	end
end

local function Castbar_OnUpdate()
	local sign
	local current_time = LunaTargetFrame.bars["Castbar"].maxValue - GetTime()
	if (LunaTargetFrame.bars["Castbar"].channeling) then
		current_time = LunaTargetFrame.bars["Castbar"].endTime - GetTime()
	end
	local text = string.sub(math.max(current_time,0)+0.001,1,4)
	if LunaTargetFrame.bars["Castbar"].casting or LunaTargetFrame.bars["Castbar"].channeling then
		LunaTargetFrame.bars["Castbar"].Time:SetText(text)
	else
		LunaTargetFrame.bars["Castbar"].Time:SetText("")
	end
	
	if (LunaTargetFrame.bars["Castbar"].casting) then
		local status = GetTime()
		if (status > LunaTargetFrame.bars["Castbar"].maxValue) then
			status = LunaTargetFrame.bars["Castbar"].maxValue
			LunaTargetFrame.bars["Castbar"].casting = nil
			LunaTargetFrame.AdjustBars()
			return
		end
		LunaTargetFrame.bars["Castbar"]:SetValue(status)
	elseif (LunaTargetFrame.bars["Castbar"].channeling) then
		local time = GetTime()
		if (time > LunaTargetFrame.bars["Castbar"].endTime) then
			time = LunaTargetFrame.bars["Castbar"].endTime
		end
		if (time == LunaTargetFrame.bars["Castbar"].endTime) then
			LunaTargetFrame.bars["Castbar"].channeling = nil
			LunaTargetFrame.AdjustBars()
			return
		end
		local barValue = LunaTargetFrame.bars["Castbar"].startTime + (LunaTargetFrame.bars["Castbar"].endTime - time)
		LunaTargetFrame.bars["Castbar"]:SetValue(barValue)
	end
end

function LunaUnitFrames:CreateTargetFrame()

	LunaTargetFrame = CreateFrame("Button", "LunaTargetFrame", UIParent)

	LunaTargetFrame:SetHeight(LunaOptions.frames["LunaTargetFrame"].size.y)
	LunaTargetFrame:SetWidth(LunaOptions.frames["LunaTargetFrame"].size.x)
	LunaTargetFrame:SetScale(LunaOptions.frames["LunaTargetFrame"].scale)
	LunaTargetFrame:SetBackdrop(LunaOptions.backdrop)
	LunaTargetFrame:SetBackdropColor(0,0,0,1)
	LunaTargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaTargetFrame"].position.x, LunaOptions.frames["LunaTargetFrame"].position.y)
	LunaTargetFrame:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
	LunaTargetFrame.unit = "target"
	LunaTargetFrame:SetScript("OnEnter", UnitFrame_OnEnter)
	LunaTargetFrame:SetScript("OnLeave", UnitFrame_OnLeave)
	LunaTargetFrame:SetMovable(0)
	LunaTargetFrame:RegisterForDrag("LeftButton")
	LunaTargetFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaTargetFrame:SetClampedToScreen(1)
	LunaTargetFrame:SetFrameStrata("BACKGROUND")

	local barsettings = {}
	for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
		barsettings[v[1]] = {}
		barsettings[v[1]][1] = v[4]
		barsettings[v[1]][2] = v[5]
	end
	
	LunaTargetFrame.bars = {}
	
	LunaTargetFrame.bars["Portrait"] = CreateFrame("Frame", nil, LunaTargetFrame)
	
	LunaTargetFrame.bars["Portrait"].texture = LunaTargetFrame.bars["Portrait"]:CreateTexture("TargetPortrait", "ARTWORK")
	LunaTargetFrame.bars["Portrait"].texture:SetAllPoints(LunaTargetFrame.bars["Portrait"])
	
	LunaTargetFrame.bars["Portrait"].model = CreateFrame("PlayerModel", nil, LunaTargetFrame)
	LunaTargetFrame.bars["Portrait"].model:SetPoint("TOPLEFT", LunaTargetFrame.bars["Portrait"], "TOPLEFT")
	LunaTargetFrame.bars["Portrait"].model:SetScript("OnShow",function() this:SetCamera(0) end)

	LunaTargetFrame.AuraAnchor = CreateFrame("Frame", nil, LunaTargetFrame)
	
	LunaTargetFrame.Buffs = {}

	LunaTargetFrame.Buffs[1] = CreateFrame("Button", "LunaTargetFrameBuff1", LunaTargetFrame.AuraAnchor)
	LunaTargetFrame.Buffs[1].texturepath = UnitBuff("target",1)
	LunaTargetFrame.Buffs[1].id = 1
	LunaTargetFrame.Buffs[1]:SetNormalTexture(LunaTargetFrame.Buffs[1].texturepath)
	LunaTargetFrame.Buffs[1]:SetScript("OnEnter", Luna_Target_SetBuffTooltip)
	LunaTargetFrame.Buffs[1]:SetScript("OnLeave", Luna_Target_SetBuffTooltipLeave)

	LunaTargetFrame.Buffs[1].stacks = LunaTargetFrame.Buffs[1]:CreateFontString(nil, "OVERLAY", LunaTargetFrame.Buffs[1])
	LunaTargetFrame.Buffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaTargetFrame.Buffs[1], 0, 0)
	LunaTargetFrame.Buffs[1].stacks:SetJustifyH("LEFT")
	LunaTargetFrame.Buffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaTargetFrame.Buffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.Buffs[1].stacks:SetTextColor(1,1,1)
	
	for i=2, 16 do
		LunaTargetFrame.Buffs[i] = CreateFrame("Button", "LunaTargetFrameBuff"..i, LunaTargetFrame.AuraAnchor)
		LunaTargetFrame.Buffs[i].texturepath = UnitBuff("target",i)
		LunaTargetFrame.Buffs[i].id = i
		LunaTargetFrame.Buffs[i]:SetNormalTexture(LunaTargetFrame.Buffs[i].texturepath)
		LunaTargetFrame.Buffs[i]:SetScript("OnEnter", Luna_Target_SetBuffTooltip)
		LunaTargetFrame.Buffs[i]:SetScript("OnLeave", Luna_Target_SetBuffTooltipLeave)
		
		LunaTargetFrame.Buffs[i].stacks = LunaTargetFrame.Buffs[i]:CreateFontString(nil, "OVERLAY", LunaTargetFrame.Buffs[i])
		LunaTargetFrame.Buffs[i].stacks:SetPoint("BOTTOMRIGHT", LunaTargetFrame.Buffs[i], 0, 0)
		LunaTargetFrame.Buffs[i].stacks:SetJustifyH("LEFT")
		LunaTargetFrame.Buffs[i].stacks:SetShadowColor(0, 0, 0)
		LunaTargetFrame.Buffs[i].stacks:SetShadowOffset(0.8, -0.8)
		LunaTargetFrame.Buffs[i].stacks:SetTextColor(1,1,1)
	end

	LunaTargetFrame.Debuffs = {}

	LunaTargetFrame.Debuffs[1] = CreateFrame("Button", "LunaTargetFrameDebuff1", LunaTargetFrame.AuraAnchor)
	LunaTargetFrame.Debuffs[1].texturepath = UnitDebuff("target",1)
	LunaTargetFrame.Debuffs[1].id = 17
	LunaTargetFrame.Debuffs[1]:SetNormalTexture(LunaTargetFrame.Debuffs[1].texturepath)
	LunaTargetFrame.Debuffs[1]:SetScript("OnEnter", Luna_Target_SetBuffTooltip)
	LunaTargetFrame.Debuffs[1]:SetScript("OnLeave", Luna_Target_SetBuffTooltipLeave)

	LunaTargetFrame.Debuffs[1].stacks = LunaTargetFrame.Debuffs[1]:CreateFontString(nil, "OVERLAY", LunaTargetFrame.Debuffs[1])
	LunaTargetFrame.Debuffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaTargetFrame.Debuffs[1], 0, 0)
	LunaTargetFrame.Debuffs[1].stacks:SetJustifyH("LEFT")
	LunaTargetFrame.Debuffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaTargetFrame.Debuffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.Debuffs[1].stacks:SetTextColor(1,1,1)

	for i=2, 16 do
		LunaTargetFrame.Debuffs[i] = CreateFrame("Button", "LunaTargetFrameDebuff"..i, LunaTargetFrame.AuraAnchor)
		LunaTargetFrame.Debuffs[i].texturepath = UnitDebuff("target",i)
		LunaTargetFrame.Debuffs[i].id = i+16
		LunaTargetFrame.Debuffs[i]:SetNormalTexture(LunaTargetFrame.Debuffs[i].texturepath)
		LunaTargetFrame.Debuffs[i]:SetScript("OnEnter", Luna_Target_SetBuffTooltip)
		LunaTargetFrame.Debuffs[i]:SetScript("OnLeave", Luna_Target_SetBuffTooltipLeave)
		
		LunaTargetFrame.Debuffs[i].stacks = LunaTargetFrame.Debuffs[i]:CreateFontString(nil, "OVERLAY", LunaTargetFrame.Debuffs[i])
		LunaTargetFrame.Debuffs[i].stacks:SetPoint("BOTTOMRIGHT", LunaTargetFrame.Debuffs[i], 0, 0)
		LunaTargetFrame.Debuffs[i].stacks:SetJustifyH("LEFT")
		LunaTargetFrame.Debuffs[i].stacks:SetShadowColor(0, 0, 0)
		LunaTargetFrame.Debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
		LunaTargetFrame.Debuffs[i].stacks:SetTextColor(1,1,1)
	end

	-- Healthbar
	LunaTargetFrame.bars["Healthbar"] = CreateFrame("StatusBar", nil, LunaTargetFrame)
	
	local incHeal = CreateFrame("StatusBar", nil, LunaTargetFrame)
	incHeal:SetMinMaxValues(0, 1)
	incHeal:SetValue(1)
	LunaTargetFrame.incHeal = incHeal

	-- Healthbar background
	LunaTargetFrame.bars["Healthbar"].hpbg = LunaTargetFrame:CreateTexture(nil, "BACKGROUND")
	LunaTargetFrame.bars["Healthbar"].hpbg:SetAllPoints(LunaTargetFrame.bars["Healthbar"])
	LunaTargetFrame.bars["Healthbar"].hpbg:SetTexture(.25,.25,.25,.25)

	-- Healthbar text
	LunaTargetFrame.bars["Healthbar"].righttext = LunaTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetFrame.bars["Healthbar"])
	LunaTargetFrame.bars["Healthbar"].righttext:SetPoint("RIGHT", -2, 0)
	LunaTargetFrame.bars["Healthbar"].righttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.bars["Healthbar"].righttext:SetShadowColor(0, 0, 0)
	LunaTargetFrame.bars["Healthbar"].righttext:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.bars["Healthbar"].righttext:SetJustifyH("RIGHT")
	LunaTargetFrame.bars["Healthbar"].righttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaTargetFrame.bars["Healthbar"].righttext, "target", barsettings["Healthbar"][2] or LunaOptions.defaultTags["Healthbar"][2])

	LunaTargetFrame.bars["Healthbar"].lefttext = LunaTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetFrame.bars["Healthbar"])
	LunaTargetFrame.bars["Healthbar"].lefttext:SetPoint("LEFT", 2, 0)
	LunaTargetFrame.bars["Healthbar"].lefttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.bars["Healthbar"].lefttext:SetShadowColor(0, 0, 0)
	LunaTargetFrame.bars["Healthbar"].lefttext:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.bars["Healthbar"].lefttext:SetJustifyH("LEFT")
	LunaTargetFrame.bars["Healthbar"].lefttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaTargetFrame.bars["Healthbar"].lefttext, "target", barsettings["Healthbar"][1] or LunaOptions.defaultTags["Healthbar"][1])

	-- Manabar
	LunaTargetFrame.bars["Powerbar"] = CreateFrame("StatusBar", nil, LunaTargetFrame)

	-- Manabar background
	LunaTargetFrame.bars["Powerbar"].ppbg = LunaTargetFrame.bars["Powerbar"]:CreateTexture(nil, "BORDER")
	LunaTargetFrame.bars["Powerbar"].ppbg:SetAllPoints(LunaTargetFrame.bars["Powerbar"])
	LunaTargetFrame.bars["Powerbar"].ppbg:SetTexture(.25,.25,.25,.25)

	LunaTargetFrame.bars["Powerbar"].righttext = LunaTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaTargetFrame.bars["Powerbar"])
	LunaTargetFrame.bars["Powerbar"].righttext:SetPoint("RIGHT", -2, 0)
	LunaTargetFrame.bars["Powerbar"].righttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.bars["Powerbar"].righttext:SetShadowColor(0, 0, 0)
	LunaTargetFrame.bars["Powerbar"].righttext:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.bars["Powerbar"].righttext:SetJustifyH("RIGHT")
	LunaTargetFrame.bars["Powerbar"].righttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaTargetFrame.bars["Powerbar"].righttext, "target", barsettings["Powerbar"][2] or LunaOptions.defaultTags["Powerbar"][2])

	LunaTargetFrame.bars["Powerbar"].lefttext = LunaTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaTargetFrame.bars["Powerbar"])
	LunaTargetFrame.bars["Powerbar"].lefttext:SetPoint("LEFT", 2, 0)
	LunaTargetFrame.bars["Powerbar"].lefttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.bars["Powerbar"].lefttext:SetShadowColor(0, 0, 0)
	LunaTargetFrame.bars["Powerbar"].lefttext:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.bars["Powerbar"].lefttext:SetJustifyH("LEFT")
	LunaTargetFrame.bars["Powerbar"].lefttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaTargetFrame.bars["Powerbar"].lefttext, "target", barsettings["Powerbar"][1] or LunaOptions.defaultTags["Powerbar"][1])

	-- Castbar
	local Castbar = CreateFrame("StatusBar", nil, LunaTargetFrame)
	LunaTargetFrame.bars["Castbar"] = Castbar
	LunaTargetFrame.bars["Castbar"].maxValue = 0
	LunaTargetFrame.bars["Castbar"].casting = nil
	LunaTargetFrame.bars["Castbar"].channeling = nil
	LunaTargetFrame.bars["Castbar"]:SetMinMaxValues(0,1)
	LunaTargetFrame.bars["Castbar"]:SetValue(0)

	-- Add a background
	local Background = Castbar:CreateTexture(nil, 'BACKGROUND')
	Background:SetAllPoints(Castbar)
	Background:SetTexture(0, 0, 1, 0.20)
	LunaTargetFrame.bars["Castbar"].bg = Background

	-- Add a timer
	local Time = Castbar:CreateFontString(nil, "OVERLAY", castbar)
	Time:SetFont(LunaOptions.font, 10)
	Time:SetTextColor(1, 0.82, 0, 1)
	Time:SetShadowColor(0, 0, 0)
	Time:SetShadowOffset(0.8, -0.8)
	Time:SetPoint("RIGHT", Castbar)
	Time:SetJustifyH("RIGHT")
	Time:SetJustifyV("MIDDLE")
	LunaTargetFrame.bars["Castbar"].Time = Time

	-- Add spell text
	local Text = Castbar:CreateFontString(nil, "OVERLAY", castbar)
	Text:SetFont(LunaOptions.font, 10)
	Text:SetTextColor(1, 0.82, 0, 1)
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(0.8, -0.8)
	Text:SetPoint("LEFT", Castbar)
	Text:SetJustifyH("LEFT")
	Text:SetJustifyV("MIDDLE")
	LunaTargetFrame.bars["Castbar"].Text = Text
	
	LunaTargetFrame.cp = {}
	LunaTargetFrame.bars["Combo Bar"] = CreateFrame("Frame", nil, LunaTargetFrame)
	for i=1,5 do
		LunaTargetFrame.cp[i] = CreateFrame("StatusBar", nil, LunaTargetFrame.bars["Combo Bar"])
		LunaTargetFrame.cp[i]:Hide()
	end
	LunaTargetFrame.cp[1]:SetPoint("TOPRIGHT", LunaTargetFrame.bars["Combo Bar"], "TOPRIGHT")
	for i=2,5 do
		LunaTargetFrame.cp[i]:SetPoint("TOPRIGHT", LunaTargetFrame.cp[i-1], "TOPLEFT",  -1, 0)
	end

	LunaTargetFrame.iconholder = CreateFrame("Frame", nil, LunaTargetFrame)
	
	LunaTargetFrame.feedbackText = LunaTargetFrame.iconholder:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
	LunaTargetFrame.feedbackText:SetTextColor(1,1,1)
	LunaTargetFrame.feedbackFontHeight = 20
	LunaTargetFrame.feedbackStartTime = 0
	
	LunaTargetFrame.RaidIcon = LunaTargetFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaTargetFrame.RaidIcon:SetHeight(20)
	LunaTargetFrame.RaidIcon:SetWidth(20)
	LunaTargetFrame.RaidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

	LunaTargetFrame.PVPRank = LunaTargetFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaTargetFrame.PVPRank:SetHeight(10)
	LunaTargetFrame.PVPRank:SetWidth(10)

	LunaTargetFrame.Leader = LunaTargetFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaTargetFrame.Leader:SetHeight(8)
	LunaTargetFrame.Leader:SetWidth(8)
	LunaTargetFrame.Leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")

	LunaTargetFrame.Loot = LunaTargetFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaTargetFrame.Loot:SetHeight(8)
	LunaTargetFrame.Loot:SetWidth(8)
	LunaTargetFrame.Loot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
	
	LunaTargetFrame:Hide()
	LunaTargetFrame:RegisterEvent("UNIT_HEALTH")
	LunaTargetFrame:RegisterEvent("UNIT_MAXHEALTH")
	LunaTargetFrame:RegisterEvent("UNIT_MAXMANA")
	LunaTargetFrame:RegisterEvent("UNIT_MANA")
	LunaTargetFrame:RegisterEvent("UNIT_RAGE")
	LunaTargetFrame:RegisterEvent("UNIT_MAXRAGE")
	LunaTargetFrame:RegisterEvent("UNIT_ENERGY")
	LunaTargetFrame:RegisterEvent("UNIT_MAXENERGY")
	LunaTargetFrame:RegisterEvent("UNIT_DISPLAYPOWER")
	LunaTargetFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	LunaTargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	LunaTargetFrame:RegisterEvent("PLAYER_COMBO_POINTS")
	LunaTargetFrame:RegisterEvent("RAID_TARGET_UPDATE")
	LunaTargetFrame:RegisterEvent("PARTY_LEADER_CHANGED")
	LunaTargetFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	LunaTargetFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	LunaTargetFrame:RegisterEvent("UNIT_SPELLMISS")
	LunaTargetFrame:RegisterEvent("UNIT_COMBAT")
	LunaTargetFrame:RegisterEvent("UNIT_FACTION")
	LunaTargetFrame:RegisterEvent("UNIT_AURA")
	LunaTargetFrame:SetScript("OnClick", Luna_OnClick)
	LunaTargetFrame:SetScript("OnEvent", Luna_Target_OnEvent)
	LunaTargetFrame:SetScript("OnUpdate", CombatFeedback_OnUpdate)
	LunaTargetFrame.bars["Castbar"]:SetScript("OnUpdate", Castbar_OnUpdate)
	
	LunaTargetFrame.dropdown = getglobal("TargetFrameDropDown")
	UIDropDownMenu_Initialize(LunaTargetFrame.dropdown, Luna_TargetDropDown_Initialize, "MENU")
	
	if not LunaOptions.BlizzTarget then
		Luna_HideBlizz(TargetFrame)
		Luna_HideBlizz(ComboFrame)
	end
	
	LunaTargetFrame.AdjustBars = function()
		local comboPoints = GetComboPoints()
		local frameHeight = LunaTargetFrame:GetHeight()
		local frameWidth
		local anchor
		local totalWeight = 0
		local gaps = -1
		local CastBarHeightWeight
		local textheights = {}
		local textbalance = {}
		for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
			if v[1] == "Castbar" then
				CastBarHeightWeight = v[2]
			end
			textheights[v[1]] = v[3] or 0.45
			textbalance[v[1]] = v[6] or 0.5
		end
		if ((LunaTargetFrame.bars["Castbar"].casting or LunaTargetFrame.bars["Castbar"].channeling) and CastBarHeightWeight > 0) then
			LunaTargetFrame.bars["Castbar"]:Show()
		elseif LunaOptions.statictargetcastbar then
			LunaTargetFrame.bars["Castbar"]:Show()
			LunaTargetFrame.bars["Castbar"].Time:SetText("")
			LunaTargetFrame.bars["Castbar"].Text:SetText("")
			LunaTargetFrame.bars["Castbar"]:SetMinMaxValues(0,1)
			LunaTargetFrame.bars["Castbar"]:SetValue(0)
		else
			LunaTargetFrame.bars["Castbar"]:Hide()
		end
		if ( comboPoints == 0 ) then
			LunaTargetFrame.bars["Combo Bar"]:Hide()
		else
			LunaTargetFrame.bars["Combo Bar"]:Show()
		end
		if LunaOptions.frames["LunaTargetFrame"].portrait > 1 then    -- We have a square portrait
			frameWidth = (LunaTargetFrame:GetWidth()-frameHeight)
			LunaTargetFrame.bars["Portrait"]:ClearAllPoints()
			LunaTargetFrame.bars["Portrait"]:SetHeight(frameHeight)
			LunaTargetFrame.bars["Portrait"]:SetWidth(frameHeight)
			if LunaOptions.fliptarget then
				LunaTargetFrame.bars["Portrait"]:SetPoint("TOPRIGHT", LunaTargetFrame, "TOPRIGHT")
				anchor = {"TOPRIGHT", LunaTargetFrame.bars["Portrait"], "TOPLEFT"}
			else
				LunaTargetFrame.bars["Portrait"]:SetPoint("TOPLEFT", LunaTargetFrame, "TOPLEFT")
				anchor = {"TOPLEFT", LunaTargetFrame.bars["Portrait"], "TOPRIGHT"}
			end
		else
			frameWidth = LunaTargetFrame:GetWidth()  -- We have a Bar-Portrait or no portrait
			anchor = {"TOPLEFT", LunaTargetFrame, "TOPLEFT"}
		end
		for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
			if LunaTargetFrame.bars[v[1]]:IsShown() then
				totalWeight = totalWeight + v[2]
				gaps = gaps + 1
			end
		end
		local firstbar = 1
		for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
			local bar = v[1]
			local weight = v[2]/totalWeight
			local height = (frameHeight-gaps)*weight
			LunaTargetFrame.bars[bar]:ClearAllPoints()
			LunaTargetFrame.bars[bar]:SetHeight(height)
			LunaTargetFrame.bars[bar]:SetWidth(frameWidth)
			LunaTargetFrame.bars[bar].rank = k
			LunaTargetFrame.bars[bar].weight = v[2]
			
			if not firstbar and LunaTargetFrame.bars[bar]:IsShown() then
				LunaTargetFrame.bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3], 0, -1)
				anchor = {"TOPLEFT", LunaTargetFrame.bars[bar], "BOTTOMLEFT"}
			elseif LunaTargetFrame.bars[bar]:IsShown() then
				LunaTargetFrame.bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3])
				firstbar = nil
				anchor = {"TOPLEFT", LunaTargetFrame.bars[bar], "BOTTOMLEFT"}
			end			
		end
		for i=1, MAX_COMBO_POINTS do
			if i <= comboPoints then
				LunaTargetFrame.cp[i]:Show()
			else
				LunaTargetFrame.cp[i]:Hide()
			end
			LunaTargetFrame.cp[i]:SetHeight(LunaTargetFrame.bars["Combo Bar"]:GetHeight())
			LunaTargetFrame.cp[i]:SetWidth((frameWidth-4)/5)
		end
		LunaTargetFrame.bars["Portrait"].model:SetHeight(LunaTargetFrame.bars["Portrait"]:GetHeight()+1)
		LunaTargetFrame.bars["Portrait"].model:SetWidth(LunaTargetFrame.bars["Portrait"]:GetWidth())
		if UnitExists("target") then
			LunaUnitFrames.TargetUpdateHeal(UnitName("target"))
		end
		local healthheight = (LunaTargetFrame.bars["Healthbar"]:GetHeight()*textheights["Healthbar"])
		LunaTargetFrame.bars["Healthbar"].righttext:SetFont(LunaOptions.font, healthheight)
		LunaTargetFrame.bars["Healthbar"].righttext:SetHeight(LunaTargetFrame.bars["Healthbar"]:GetHeight())
		LunaTargetFrame.bars["Healthbar"].righttext:SetWidth(LunaTargetFrame.bars["Healthbar"]:GetWidth()*(1-textbalance["Healthbar"]))
		LunaTargetFrame.bars["Healthbar"].lefttext:SetFont(LunaOptions.font, healthheight)
		LunaTargetFrame.bars["Healthbar"].lefttext:SetHeight(LunaTargetFrame.bars["Healthbar"]:GetHeight())
		LunaTargetFrame.bars["Healthbar"].lefttext:SetWidth(LunaTargetFrame.bars["Healthbar"]:GetWidth()*textbalance["Healthbar"])

		local powerheight = (LunaTargetFrame.bars["Powerbar"]:GetHeight()*textheights["Powerbar"])
		LunaTargetFrame.bars["Powerbar"].righttext:SetFont(LunaOptions.font, powerheight)
		LunaTargetFrame.bars["Powerbar"].righttext:SetHeight(LunaTargetFrame.bars["Powerbar"]:GetHeight())
		LunaTargetFrame.bars["Powerbar"].righttext:SetWidth(LunaTargetFrame.bars["Powerbar"]:GetWidth()*(1-textbalance["Powerbar"]))
		LunaTargetFrame.bars["Powerbar"].lefttext:SetHeight(LunaTargetFrame.bars["Powerbar"]:GetHeight())
		LunaTargetFrame.bars["Powerbar"].lefttext:SetWidth(LunaTargetFrame.bars["Powerbar"]:GetWidth()*textbalance["Powerbar"])
		LunaTargetFrame.bars["Powerbar"].lefttext:SetFont(LunaOptions.font, powerheight)
			
		local castheight = (LunaTargetFrame.bars["Castbar"]:GetHeight()*textheights["Castbar"])
		LunaTargetFrame.bars["Castbar"].Text:SetFont(LunaOptions.font, castheight)
		LunaTargetFrame.bars["Castbar"].Text:SetHeight(LunaTargetFrame.bars["Castbar"]:GetHeight())
		LunaTargetFrame.bars["Castbar"].Text:SetWidth(LunaTargetFrame.bars["Castbar"]:GetWidth()*(1-textbalance["Castbar"]))
		LunaTargetFrame.bars["Castbar"].Time:SetFont(LunaOptions.font, castheight)
		LunaTargetFrame.bars["Castbar"].Time:SetHeight(LunaTargetFrame.bars["Castbar"]:GetHeight())
		LunaTargetFrame.bars["Castbar"].Time:SetWidth(LunaTargetFrame.bars["Castbar"]:GetWidth()*textbalance["Castbar"])
		SetIconPositions()
		if not (LunaOptions.frames["LunaTargetFrame"].portrait > 1) and not LunaTargetFrame.bars["Portrait"].model:IsShown() then
			Luna_Target_Events.UNIT_PORTRAIT_UPDATE("target")
		end
	end
	LunaTargetFrame.UpdateBuffSize = function ()
		local buffcount = LunaOptions.frames["LunaTargetFrame"].BuffInRow or 16
		if LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 1 then
			for i=1, 16 do
				LunaTargetFrame.Buffs[i]:Hide()
				LunaTargetFrame.Debuffs[i]:Hide()
			end
		elseif LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 2 then
			local buffsize = ((LunaTargetFrame:GetWidth()-(buffcount-1))/buffcount)
			LunaTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetFrame.AuraAnchor:SetPoint("BOTTOMLEFT", LunaTargetFrame, "TOPLEFT", -1, 3)
			LunaTargetFrame.AuraAnchor:SetWidth(LunaTargetFrame:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetFrame.Buffs[buffid]:SetPoint("BOTTOMLEFT", LunaTargetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetFrame.Debuffs[buffid]:SetPoint("BOTTOMLEFT", LunaTargetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			Luna_Target_Events:UNIT_AURA()
		elseif LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 3 then
			local buffsize = ((LunaTargetFrame:GetWidth()-(buffcount-1))/buffcount)
			LunaTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetFrame.AuraAnchor:SetWidth(LunaTargetFrame:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetFrame.Buffs[buffid]:SetPoint("TOPLEFT", LunaTargetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetFrame.Debuffs[buffid]:SetPoint("TOPLEFT", LunaTargetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaTargetFrame.AuraAnchor:SetPoint("TOPLEFT", LunaTargetFrame, "BOTTOMLEFT", -1, -3)
			Luna_Target_Events:UNIT_AURA()
		elseif LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 4 then
			local buffsize = (((LunaTargetFrame:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetFrame.AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetFrame.Buffs[buffid]:SetPoint("TOPRIGHT", LunaTargetFrame.AuraAnchor, "TOPRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetFrame.Debuffs[buffid]:SetPoint("TOPRIGHT", LunaTargetFrame.AuraAnchor, "BOTTOMRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaTargetFrame.AuraAnchor:SetPoint("TOPRIGHT", LunaTargetFrame, "TOPLEFT", -3, 0)
			Luna_Target_Events:UNIT_AURA()
		else
			local buffsize = (((LunaTargetFrame:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetFrame.AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetFrame.Buffs[buffid]:SetPoint("TOPLEFT", LunaTargetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetFrame.Debuffs[buffid]:SetPoint("TOPLEFT", LunaTargetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaTargetFrame.AuraAnchor:SetPoint("TOPLEFT", LunaTargetFrame, "TOPRIGHT", 3, 0)
			Luna_Target_Events:UNIT_AURA()
		end
	end
	for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
		if v[2] == 0 then
			LunaTargetFrame.bars[v[1]]:Hide()
		end
	end
	LunaTargetFrame.AdjustBars()
	LunaTargetFrame.UpdateBuffSize()
	AceEvent:RegisterEvent("HealComm_Healupdate" , LunaUnitFrames.TargetUpdateHeal)
end

function LunaUnitFrames.TargetUpdateHeal(target)
	if target ~= UnitName("target") then
		return
	end
	local healed = HealComm:getHeal(target)
	local health, maxHealth = UnitHealth(LunaTargetFrame.unit), UnitHealthMax(LunaTargetFrame.unit)
	if MobHealth3 then
		health, maxHealth = MobHealth3:GetUnitHealth("target")
	end
	if( LunaOptions.HideHealing == nil and healed > 0 and (health < maxHealth or (LunaOptions.overheal or 20) > 0 )) then
		LunaTargetFrame.incHeal:Show()
		local healthWidth = LunaTargetFrame.bars["Healthbar"]:GetWidth() * (health / maxHealth)
		local incWidth = LunaTargetFrame.bars["Healthbar"]:GetWidth() * (healed / maxHealth)
		if( (healthWidth + incWidth) > (LunaTargetFrame.bars["Healthbar"]:GetWidth() * (1+((LunaOptions.overheal or 20)/100))) ) then
			incWidth = LunaTargetFrame.bars["Healthbar"]:GetWidth() * (1+((LunaOptions.overheal or 20)/100)) - healthWidth
		end
		LunaTargetFrame.incHeal:SetWidth(incWidth)
		LunaTargetFrame.incHeal:SetHeight(LunaTargetFrame.bars["Healthbar"]:GetHeight())
		LunaTargetFrame.incHeal:ClearAllPoints()
		LunaTargetFrame.incHeal:SetPoint("TOPLEFT", LunaTargetFrame.bars["Healthbar"], "TOPLEFT", healthWidth, 0)
	else
		LunaTargetFrame.incHeal:Hide()
	end
end

function LunaUnitFrames:StartTargetCast(start, spell, dur, isChannel)
	if (start+dur) > GetTime() then
		if isChannel then
			LunaTargetFrame.bars["Castbar"].maxValue = 1
			LunaTargetFrame.bars["Castbar"].endTime = (start + dur)
			LunaTargetFrame.bars["Castbar"].duration = dur
			LunaTargetFrame.bars["Castbar"]:SetMinMaxValues(start, LunaTargetFrame.bars["Castbar"].endTime)
			LunaTargetFrame.bars["Castbar"]:SetValue(LunaTargetFrame.bars["Castbar"].endTime)
			LunaTargetFrame.bars["Castbar"].casting = nil
			LunaTargetFrame.bars["Castbar"].channeling = 1	
		else
			LunaTargetFrame.bars["Castbar"].maxValue = (start + dur)
			LunaTargetFrame.bars["Castbar"].casting = 1
			LunaTargetFrame.bars["Castbar"].channeling = nil
			LunaTargetFrame.bars["Castbar"]:SetMinMaxValues(start, LunaTargetFrame.bars["Castbar"].maxValue)
			LunaTargetFrame.bars["Castbar"]:SetValue(start)
		end
		LunaTargetFrame.bars["Castbar"].startTime = start
		if LunaTargetFrame.bars["Castbar"].Text:GetFont() then
			LunaTargetFrame.bars["Castbar"].Text:SetText(spell)
		end
		LunaTargetFrame.AdjustBars()
	end
end

function LunaUnitFrames:StopTargetCast()
	LunaTargetFrame.bars["Castbar"].casting = nil
	LunaTargetFrame.bars["Castbar"].channeling = nil
	LunaTargetFrame.AdjustBars()
end
	
function LunaUnitFrames:ConvertTargetPortrait()
	if LunaOptions.frames["LunaTargetFrame"].portrait == 1 then
		table.insert(LunaOptions.frames["LunaTargetFrame"].bars, 1, {"Portrait", 4})
	else
		for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
			if v[1] == "Portrait" then
				table.remove(LunaOptions.frames["LunaTargetFrame"].bars, k)
			end
		end
	end
	UIDropDownMenu_SetText("Healthbar", LunaOptionsFrame.pages[3].BarSelect)
	LunaOptionsFrame.pages[3].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaTargetFrame"].bars))
	for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
		if v[1] == "Healthbar" then
			LunaOptionsFrame.pages[3].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[3].barorder:SetValue(k)
			LunaOptionsFrame.pages[3].lefttext:SetText(v[4] or LunaOptions.defaultTags["Healthbar"][1])
			LunaOptionsFrame.pages[3].righttext:SetText(v[5] or LunaOptions.defaultTags["Healthbar"][2])
			LunaOptionsFrame.pages[3].textsize:SetValue(v[3] or 0.45)
			break
		end
	end
	SetIconPositions()
	LunaTargetFrame.AdjustBars()
	Luna_Target_Events.UNIT_PORTRAIT_UPDATE("target")
end

function Luna_Target_Events:PARTY_LOOT_METHOD_CHANGED()
	local Lootmaster;
	_, Lootmaster = GetLootMethod()
	if Lootmaster == 0 and UnitIsUnit("player", "target") and LunaOptions.frames["LunaTargetFrame"].looticon then
		LunaTargetFrame.Loot:Show()
	elseif Lootmaster and UnitIsUnit("party"..Lootmaster, "target") and LunaOptions.frames["LunaTargetFrame"].looticon then
		LunaTargetFrame.Loot:Show()
	else
		LunaTargetFrame.Loot:Hide()
	end
end

function Luna_Target_Events:RAID_TARGET_UPDATE()
	local index = GetRaidTargetIndex("target")
	if (index) then
		SetRaidTargetIconTexture(LunaTargetFrame.RaidIcon, index)
		LunaTargetFrame.RaidIcon:Show()
	else
		LunaTargetFrame.RaidIcon:Hide()
	end
end

function Luna_Target_Events:UNIT_AURA()
	local pos
	local _,_,dtype = UnitDebuff("target", 1, 1)
	if dtype and LunaOptions.HighlightDebuffs and UnitCanAssist("player", "target") then
		LunaTargetFrame:SetBackdropColor(unpack(LunaOptions.DebuffTypeColor[dtype],1))
	else
		LunaTargetFrame:SetBackdropColor(0,0,0,1)
	end
	if LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 1 then
		return
	end
	for i=1, 16 do
		local path, stacks = UnitBuff("target",i)
		LunaTargetFrame.Buffs[i].texturepath = path
		if LunaTargetFrame.Buffs[i].texturepath then
			LunaTargetFrame.Buffs[i]:EnableMouse(1)
			LunaTargetFrame.Buffs[i]:Show()
			if stacks > 1 then
				LunaTargetFrame.Buffs[i].stacks:SetText(stacks)
				LunaTargetFrame.Buffs[i].stacks:Show()
			else
				LunaTargetFrame.Buffs[i].stacks:Hide()
			end
		else
			LunaTargetFrame.Buffs[i]:EnableMouse(0)
			LunaTargetFrame.Buffs[i]:Hide()
			if not pos then
				pos = i
			end
		end
		LunaTargetFrame.Buffs[i]:SetNormalTexture(LunaTargetFrame.Buffs[i].texturepath)
	end
	if not pos then
		pos = 17
	end
	LunaTargetFrame.AuraAnchor:SetHeight((LunaTargetFrame.Buffs[1]:GetHeight()*math.ceil((pos-1)/(LunaOptions.frames["LunaTargetFrame"].BuffInRow or 16)))+(math.ceil((pos-1)/(LunaOptions.frames["LunaTargetFrame"].BuffInRow or 16))-1)+1.1)
	for i=1, 16 do
		local path, stacks = UnitDebuff("target",i)
		LunaTargetFrame.Debuffs[i].texturepath = path
		if LunaTargetFrame.Debuffs[i].texturepath then
			LunaTargetFrame.Debuffs[i]:EnableMouse(1)
			LunaTargetFrame.Debuffs[i]:Show()
			if stacks > 1 then
				LunaTargetFrame.Debuffs[i].stacks:SetText(stacks)
				LunaTargetFrame.Debuffs[i].stacks:Show()
			else
				LunaTargetFrame.Debuffs[i].stacks:Hide()
			end
		else
			LunaTargetFrame.Debuffs[i]:EnableMouse(0)
			LunaTargetFrame.Debuffs[i]:Hide()
		end
		LunaTargetFrame.Debuffs[i]:SetNormalTexture(LunaTargetFrame.Debuffs[i].texturepath)
	end
end

function Luna_Target_Events:PLAYER_COMBO_POINTS()
	LunaTargetFrame.AdjustBars()
end

function Luna_Target_Events:PLAYER_TARGET_CHANGED()
	LunaUnitFrames:UpdateTargetFrame()
	LunaUnitFrames.TargetUpdateHeal(UnitName("target"))
end
Luna_Target_Events.UNIT_FACTION = Luna_Target_Events.PLAYER_TARGET_CHANGED

function Luna_Target_Events:UNIT_HEALTH()
	LunaUnitFrames.TargetUpdateHeal(UnitName("target"))
	local Health, maxHealth
	if MobHealth3 then
		Health, maxHealth = MobHealth3:GetUnitHealth("target")
	else
		Health = UnitHealth("target")
		maxHealth = UnitHealthMax("target")
	end
	LunaTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
	if not UnitIsConnected("target") then
		LunaTargetFrame.bars["Healthbar"]:SetValue(0)
	elseif Health < 1 or (Health == 1 and (UnitInParty("target") or UnitInRaid("target"))) then			-- This prevents negative health
		LunaTargetFrame.bars["Healthbar"]:SetValue(0)
	else
		LunaTargetFrame.bars["Healthbar"]:SetValue(Health)
		if not LunaOptions.hbarcolor and UnitIsPlayer("target") and not UnitIsEnemy("player","target") then
			local color = LunaUnitFrames:GetHealthColor("target")
			LunaTargetFrame.bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
			LunaTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
		end
	end
end
Luna_Target_Events.UNIT_MAXHEALTH = Luna_Target_Events.UNIT_HEALTH;

function Luna_Target_Events:UNIT_MANA()
	if UnitHealth("target") < 1 or not UnitIsConnected("target") then
		LunaTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax("target"))
		LunaTargetFrame.bars["Powerbar"]:SetValue(0)
	else
		LunaTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax("target"))
		LunaTargetFrame.bars["Powerbar"]:SetValue(UnitMana("target"))
	end
end
Luna_Target_Events.UNIT_MAXMANA = Luna_Target_Events.UNIT_MANA;
Luna_Target_Events.UNIT_ENERGY = Luna_Target_Events.UNIT_MANA;
Luna_Target_Events.UNIT_MAXENERGY = Luna_Target_Events.UNIT_MANA;
Luna_Target_Events.UNIT_RAGE = Luna_Target_Events.UNIT_MANA;
Luna_Target_Events.UNIT_MAXRAGE = Luna_Target_Events.UNIT_MANA;

function LunaUnitFrames:UpdateTargetFrame()
	if UnitExists("target") and LunaOptions.frames["LunaTargetFrame"].enabled == 1 then
		LunaTargetFrame:Show()
	else
		LunaTargetFrame:Hide()
		return
	end
	local _,class = UnitClass("target")
	
	if UnitIsPlayer("target") then
		local color
		if LunaOptions.hbarcolor then
			color = LunaOptions.ClassColors[class]
		elseif UnitIsEnemy("player","target") then
			color = LunaOptions.MiscColors["hostile"]
		else
			color = LunaUnitFrames:GetHealthColor("target")
		end
		LunaTargetFrame.bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
		LunaTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
	elseif UnitIsTapped("target") and not UnitIsTappedByPlayer("target") then
		LunaTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.5, 0.5, 0.5)
		LunaTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.5, 0.5, 0.5, 0.25)
	else
		reaction = UnitReaction("target", "player")
		if reaction and reaction < 4 then
			LunaTargetFrame.bars["Healthbar"]:SetStatusBarColor(unpack(LunaOptions.MiscColors["hostile"]))
			LunaTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(unpack(LunaOptions.MiscColors["hostile"]), 0.25)
		elseif reaction and reaction > 4 then
			LunaTargetFrame.bars["Healthbar"]:SetStatusBarColor(unpack(LunaOptions.MiscColors["friendly"]))
			LunaTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(unpack(LunaOptions.MiscColors["friendly"]), 0.25)
		else
			LunaTargetFrame.bars["Healthbar"]:SetStatusBarColor(unpack(LunaOptions.MiscColors["neutral"]))
			LunaTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(unpack(LunaOptions.MiscColors["neutral"]), 0.25)
		end
	end
	Luna_Target_Events.UNIT_HEALTH()
	Luna_Target_Events.UNIT_MANA()
	Luna_Target_Events.UNIT_DISPLAYPOWER()
	Luna_Target_Events.PLAYER_COMBO_POINTS()
	Luna_Target_Events.PARTY_LEADER_CHANGED()
	Luna_Target_Events.UNIT_PORTRAIT_UPDATE("target")
	Luna_Target_Events.UNIT_DISPLAYPOWER()
	Luna_Target_Events.RAID_TARGET_UPDATE()
	Luna_Target_Events.UNIT_AURA()
	Luna_Target_Events:PARTY_LOOT_METHOD_CHANGED()
	
	if UnitIsPlayer("target") and LunaOptions.frames["LunaTargetFrame"].pvprankicon then
		local rankNumber = UnitPVPRank("target");
		if (rankNumber == 0) then
			LunaTargetFrame.PVPRank:Hide();
		elseif (rankNumber < 14) then
			rankNumber = rankNumber - 4;
			LunaTargetFrame.PVPRank:SetTexture("Interface\\PvPRankBadges\\PvPRank0"..rankNumber);
			LunaTargetFrame.PVPRank:Show();
		else
			rankNumber = rankNumber - 4;
			LunaTargetFrame.PVPRank:SetTexture("Interface\\PvPRankBadges\\PvPRank"..rankNumber);
			LunaTargetFrame.PVPRank:Show();
		end
	elseif UnitClassification("target") == "normal" then
		LunaTargetFrame.PVPRank:Hide()
	else
		LunaTargetFrame.PVPRank:Hide()
	end
	SetIconPositions()
end

function Luna_Target_Events:PARTY_LEADER_CHANGED()
	if UnitIsPartyLeader("target") and LunaOptions.frames["LunaTargetFrame"].leadericon then
		LunaTargetFrame.Leader:Show()
	else
		LunaTargetFrame.Leader:Hide()
	end
end

Luna_Target_Events.PARTY_MEMBERS_CHANGED = Luna_Target_Events.PARTY_LEADER_CHANGED

function Luna_Target_Events:UNIT_DISPLAYPOWER()
	local targetpower = UnitPowerType("target")
	
	if UnitManaMax("target") == 0 then
		LunaTargetFrame.bars["Powerbar"]:SetStatusBarColor(0, 0, 0, .25)
		LunaTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(0, 0, 0, .25)
	elseif targetpower == 1 then
		LunaTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
		LunaTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
	elseif targetpower == 2 then
		LunaTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3])
		LunaTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3], 0.25)
	elseif targetpower == 3 then
		LunaTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
		LunaTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
	else
		LunaTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		LunaTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
	end
	Luna_Target_Events.UNIT_MANA()
end

function Luna_Target_Events.UNIT_PORTRAIT_UPDATE(unit)
	if arg1 ~= "target" and not unit then
		return
	end
	local portrait = LunaTargetFrame.bars["Portrait"]
	if LunaOptions.PortraitMode == 3 and UnitIsPlayer("target") then
		local _,class = UnitClass("target")
		portrait.model:Hide()
		portrait.texture:Show()
		portrait.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		portrait.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
	elseif LunaOptions.PortraitMode == 2 or (LunaOptions.PortraitMode == 3 and (LunaOptions.PortraitFallback == 3 or LunaOptions.PortraitFallback == 2)) then
		if LunaOptions.frames["LunaTargetFrame"].portrait > 1 then
			portrait.model:Hide()
			portrait.texture:Show()
			SetPortraitTexture(portrait.texture, "target")
			portrait.texture:SetTexCoord(.1, .90, .1, .90)
		else
			portrait.model:Hide()
			portrait.texture:Show()
			SetPortraitTexture(portrait.texture, "target")
			local aspect = portrait:GetHeight()/portrait:GetWidth()
			portrait.texture:SetTexCoord(0, 1, (0.5-0.5*aspect), 1-(0.5-0.5*aspect))
		end
	else
		portrait.model:Show()
		portrait.texture:Hide()
		if(not UnitExists("target") or not UnitIsConnected("target") or not UnitIsVisible("target")) then
			if LunaOptions.PortraitFallback == 3 and UnitIsPlayer("target") then
				portrait.model:Hide()
				portrait.texture:Show()
				local _,class = UnitClass("target")
				portrait.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
				portrait.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
			elseif LunaOptions.PortraitFallback == 2 or LunaOptions.PortraitFallback == 3 then
				if LunaOptions.frames["LunaTargetFrame"].portrait > 1 then
					portrait.model:Hide()
					portrait.texture:Show()
					SetPortraitTexture(portrait.texture, "target")
					portrait.texture:SetTexCoord(.1, .90, .1, .90)
				else
					portrait.model:Hide()
					portrait.texture:Show()
					SetPortraitTexture(portrait.texture, "target")
					local aspect = portrait:GetHeight()/portrait:GetWidth()
					portrait.texture:SetTexCoord(0, 1, .1+(0.4-0.4*aspect), .90-(0.4-0.4*aspect))
				end
			else
				portrait.model:Show()
				portrait.texture:Hide()
				portrait.model:SetModelScale(4.25)
				portrait.model:SetPosition(0, 0, -1)
				portrait.model:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
			end
		else
			portrait.model:Show()
			portrait.texture:Hide()
			portrait.model:SetUnit("target")
			portrait.model:SetCamera(0)
		end
	end
end

function Luna_Target_Events:UNIT_COMBAT()
	if arg1 == this.unit and LunaOptions.frames["LunaTargetFrame"].combattext then
		CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5)
	end
end

function Luna_Target_Events:UNIT_SPELLMISS()
	if arg1 == this.unit and LunaOptions.frames["LunaTargetFrame"].combattext then
		CombatFeedback_OnSpellMissEvent(arg2)
	end
end