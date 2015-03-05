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

local dropdown = CreateFrame("Frame", "LunaUnitDropDownMenuTarget", UIParent, "UIDropDownMenuTemplate")
function Luna_TargetDropDown_Initialize()
	local menu, name;
	if (UnitIsUnit("target", "player")) then
		menu = "SELF";
	elseif (UnitIsUnit("target", "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer("target")) then
		if (UnitInParty("target")) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end
	if (menu) then
		UnitPopup_ShowMenu(dropdown, menu, "target", name);
	end
end
UIDropDownMenu_Initialize(dropdown, Luna_TargetDropDown_Initialize, "MENU");

function Luna_Target_OnClick()
	local button = arg1
	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit("target");
		elseif (CursorHasItem()) then
			DropItemOnUnit("target");
		else
			TargetUnit("target");
		end
		return;
	end

	if (button == "RightButton") then
		if (SpellIsTargeting()) then
			SpellStopTargeting();
			return;
		end
	end

	if (not (IsAltKeyDown() or IsControlKeyDown() or IsShiftKeyDown())) then
		ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
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
	LunaTargetFrame.bars["Castbar"].Time:SetText(text)
	
	if (LunaTargetFrame.bars["Castbar"].casting) then
		local status = GetTime()
		if (status > LunaTargetFrame.bars["Castbar"].maxValue) then
			status = LunaTargetFrame.bars["Castbar"].maxValue
			LunaTargetFrame.bars["Castbar"].casting = nil
			LunaTargetFrame.AdjustBars()
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
	LunaTargetFrame:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	LunaTargetFrame.unit = "target"
	LunaTargetFrame:SetScript("OnEnter", UnitFrame_OnEnter)
	LunaTargetFrame:SetScript("OnLeave", UnitFrame_OnLeave)
	LunaTargetFrame:SetMovable(0)
	LunaTargetFrame:RegisterForDrag("LeftButton")
	LunaTargetFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaTargetFrame:SetClampedToScreen(1)
	LunaTargetFrame:SetFrameStrata("BACKGROUND")

	LunaTargetFrame.bars = {}
	
	LunaTargetFrame.bars["Portrait"] = CreateFrame("PlayerModel", nil, LunaTargetFrame)
	LunaTargetFrame.bars["Portrait"]:SetScript("OnShow",function() this:SetCamera(0) end)
	LunaTargetFrame.bars["Portrait"].type = "3D"
	LunaTargetFrame.bars["Portrait"].side = "right"

	LunaTargetFrame.AuraAnchor = CreateFrame("Frame", nil, LunaTargetFrame)
	
	LunaTargetFrame.Buffs = {}

	LunaTargetFrame.Buffs[1] = CreateFrame("Button", nil, LunaTargetFrame.AuraAnchor)
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
		LunaTargetFrame.Buffs[i] = CreateFrame("Button", nil, LunaTargetFrame.AuraAnchor)
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

	LunaTargetFrame.Debuffs[1] = CreateFrame("Button", nil, LunaTargetFrame.AuraAnchor)
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
		LunaTargetFrame.Debuffs[i] = CreateFrame("Button", nil, LunaTargetFrame.AuraAnchor)
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
	LunaTargetFrame.bars["Healthbar"]:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaTargetFrame.bars["Healthbar"]:SetFrameStrata("MEDIUM")
	
	local incHeal = CreateFrame("StatusBar", nil, LunaTargetFrame)
	incHeal:SetStatusBarTexture(LunaOptions.statusbartexture)
	incHeal:SetMinMaxValues(0, 1)
	incHeal:SetValue(1)
	incHeal:SetStatusBarColor(0, 1, 0, 0.6)
	LunaTargetFrame.incHeal = incHeal

	-- Healthbar background
	LunaTargetFrame.bars["Healthbar"].hpbg = LunaTargetFrame:CreateTexture(nil, "BACKGROUND")
	LunaTargetFrame.bars["Healthbar"].hpbg:SetAllPoints(LunaTargetFrame.bars["Healthbar"])
	LunaTargetFrame.bars["Healthbar"].hpbg:SetTexture(.25,.25,.25,.25)

	-- Healthbar text
	LunaTargetFrame.bars["Healthbar"].hpp = LunaTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetFrame.bars["Healthbar"])
	LunaTargetFrame.bars["Healthbar"].hpp:SetPoint("RIGHT", -2, 0)
	LunaTargetFrame.bars["Healthbar"].hpp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.bars["Healthbar"].hpp:SetShadowColor(0, 0, 0)
	LunaTargetFrame.bars["Healthbar"].hpp:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.bars["Healthbar"].hpp:SetTextColor(1,1,1)
	LunaTargetFrame.bars["Healthbar"].hpp:SetJustifyH("RIGHT")

	LunaTargetFrame.name = LunaTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetFrame.bars["Healthbar"])
	LunaTargetFrame.name:SetPoint("LEFT", 2, -1)
	LunaTargetFrame.name:SetJustifyH("LEFT")
	LunaTargetFrame.name:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.name:SetShadowColor(0, 0, 0)
	LunaTargetFrame.name:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.name:SetTextColor(1,1,1)

	-- Manabar
	LunaTargetFrame.bars["Powerbar"] = CreateFrame("StatusBar", nil, LunaTargetFrame)
	LunaTargetFrame.bars["Powerbar"]:SetStatusBarTexture(LunaOptions.statusbartexture)

	-- Manabar background
	LunaTargetFrame.bars["Powerbar"].ppbg = LunaTargetFrame.bars["Powerbar"]:CreateTexture(nil, "BORDER")
	LunaTargetFrame.bars["Powerbar"].ppbg:SetAllPoints(LunaTargetFrame.bars["Powerbar"])
	LunaTargetFrame.bars["Powerbar"].ppbg:SetTexture(.25,.25,.25,.25)

	LunaTargetFrame.bars["Powerbar"].ppp = LunaTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaTargetFrame.bars["Powerbar"])
	LunaTargetFrame.bars["Powerbar"].ppp:SetPoint("RIGHT", -2, 0)
	LunaTargetFrame.bars["Powerbar"].ppp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.bars["Powerbar"].ppp:SetShadowColor(0, 0, 0)
	LunaTargetFrame.bars["Powerbar"].ppp:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.bars["Powerbar"].ppp:SetTextColor(1,1,1)
	LunaTargetFrame.bars["Powerbar"].ppp:SetJustifyH("RIGHT")

	LunaTargetFrame.lvl = LunaTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY")
	LunaTargetFrame.lvl:SetPoint("LEFT", LunaTargetFrame.bars["Powerbar"], "LEFT", 2, -1)
	LunaTargetFrame.lvl:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.lvl:SetShadowColor(0, 0, 0)
	LunaTargetFrame.lvl:SetShadowOffset(0.8, -0.8)

	LunaTargetFrame.class = LunaTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY")
	LunaTargetFrame.class:SetPoint("LEFT", LunaTargetFrame.lvl, "RIGHT",  1, 0)
	LunaTargetFrame.class:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.class:SetShadowColor(0, 0, 0)
	LunaTargetFrame.class:SetShadowOffset(0.8, -0.8)

	-- Castbar
	local Castbar = CreateFrame("StatusBar", nil, LunaTargetFrame)
	Castbar:SetStatusBarTexture(LunaOptions.statusbartexture)
	Castbar:SetStatusBarColor(1, 0.7, 0.3)
	LunaTargetFrame.bars["Castbar"] = Castbar
	LunaTargetFrame.bars["Castbar"].maxValue = 0
	LunaTargetFrame.bars["Castbar"].casting = nil
	LunaTargetFrame.bars["Castbar"].channeling = nil
	LunaTargetFrame.bars["Castbar"]:Hide()

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
	LunaTargetFrame.bars["Castbar"].Time = Time

	-- Add spell text
	local Text = Castbar:CreateFontString(nil, "OVERLAY", castbar)
	Text:SetFont(LunaOptions.font, 10)
	Text:SetTextColor(1, 0.82, 0, 1)
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(0.8, -0.8)
	Text:SetPoint("LEFT", Castbar)
	LunaTargetFrame.bars["Castbar"].Text = Text
	
	LunaTargetFrame.cp = {}
	LunaTargetFrame.bars["Combo Bar"] = CreateFrame("Frame", nil, LunaTargetFrame)
	for i=1,5 do
		LunaTargetFrame.cp[i] = CreateFrame("StatusBar", nil, LunaTargetFrame.bars["Combo Bar"])
		LunaTargetFrame.cp[i]:SetStatusBarTexture(LunaOptions.statusbartexture)
		LunaTargetFrame.cp[i]:Hide()
		LunaTargetFrame.cp[i]:SetStatusBarColor(1, 0.80, 0)
	end
	LunaTargetFrame.cp[1]:SetPoint("TOPRIGHT", LunaTargetFrame.bars["Combo Bar"], "TOPRIGHT")
	for i=2,5 do
		LunaTargetFrame.cp[i]:SetPoint("TOPRIGHT", LunaTargetFrame.cp[i-1], "TOPLEFT",  -1, 0)
	end

	LunaTargetFrame.iconholder = CreateFrame("Frame", nil, LunaTargetFrame)
	LunaTargetFrame.iconholder:SetFrameStrata("MEDIUM")
	
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
	LunaTargetFrame.Leader:SetHeight(10)
	LunaTargetFrame.Leader:SetWidth(10)
	LunaTargetFrame.Leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")

	LunaTargetFrame.Loot = LunaTargetFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaTargetFrame.Loot:SetHeight(10)
	LunaTargetFrame.Loot:SetWidth(10)
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
	LunaTargetFrame:RegisterEvent("UNIT_LEVEL")
	LunaTargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	LunaTargetFrame:RegisterEvent("PLAYER_COMBO_POINTS")
	LunaTargetFrame:RegisterEvent("RAID_TARGET_UPDATE")
	LunaTargetFrame:RegisterEvent("PARTY_LEADER_CHANGED")
	LunaTargetFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	LunaTargetFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	LunaTargetFrame:RegisterEvent("UNIT_SPELLMISS")
	LunaTargetFrame:RegisterEvent("UNIT_COMBAT")
	LunaTargetFrame:RegisterEvent("UNIT_FACTION")
	LunaTargetFrame:SetScript("OnClick", Luna_Target_OnClick)
	LunaTargetFrame:SetScript("OnEvent", Luna_Target_OnEvent)
	LunaTargetFrame:SetScript("OnUpdate", CombatFeedback_OnUpdate)
	LunaTargetFrame.bars["Castbar"]:SetScript("OnUpdate", Castbar_OnUpdate)
	
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
		if LunaTargetFrame.bars["Castbar"].casting or LunaTargetFrame.bars["Castbar"].channeling then
			LunaTargetFrame.bars["Castbar"]:Show()
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
			LunaTargetFrame.bars["Portrait"]:SetHeight(frameHeight+1)
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
		if UnitExists("target") then
			LunaUnitFrames.TargetUpdateHeal(UnitName("target"))
		end
		local healthheight = (LunaTargetFrame.bars["Healthbar"]:GetHeight()/23.4)*11
		if healthheight > 0 then
			LunaTargetFrame.bars["Healthbar"].hpp:SetFont(LunaOptions.font, healthheight)
			LunaTargetFrame.name:SetFont(LunaOptions.font, healthheight)
		end
		if healthheight < 6 then
			LunaTargetFrame.bars["Healthbar"].hpp:Hide()
			LunaTargetFrame.name:Hide()
		else
			LunaTargetFrame.bars["Healthbar"].hpp:Show()
			LunaTargetFrame.name:Show()
		end
		local powerheight = (LunaTargetFrame.bars["Powerbar"]:GetHeight()/23.4)*11
		if powerheight > 0 then
			LunaTargetFrame.bars["Powerbar"].ppp:SetFont(LunaOptions.font, powerheight)
			LunaTargetFrame.lvl:SetFont(LunaOptions.font, powerheight)
			LunaTargetFrame.class:SetFont(LunaOptions.font, powerheight)
		end
		if powerheight < 6 then
			LunaTargetFrame.bars["Powerbar"].ppp:Hide()
			LunaTargetFrame.lvl:Hide()
			LunaTargetFrame.class:Hide()
		else
			LunaTargetFrame.bars["Powerbar"].ppp:Show()
			LunaTargetFrame.lvl:Show()
			LunaTargetFrame.class:Show()
		end
		local castheight = (LunaTargetFrame.bars["Castbar"]:GetHeight()/11.7)*11
		LunaTargetFrame.bars["Castbar"].Text:SetFont(LunaOptions.font, castheight)
		LunaTargetFrame.bars["Castbar"].Time:SetFont(LunaOptions.font, castheight)
		if castheight < 6 then
			LunaTargetFrame.bars["Castbar"].Text:Hide()
			LunaTargetFrame.bars["Castbar"].Time:Hide()
		else
			LunaTargetFrame.bars["Castbar"].Text:Show()
			LunaTargetFrame.bars["Castbar"].Time:Show()
		end
		SetIconPositions()
	end
	LunaTargetFrame.UpdateBuffSize = function ()
		local buffcount = LunaOptions.frames["LunaTargetFrame"].BuffInRow or 16
		if LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 1 then
			LunaTargetFrame:UnregisterEvent("UNIT_AURA")
			for i=1, 16 do
				LunaTargetFrame.Buffs[i]:Hide()
				LunaTargetFrame.Debuffs[i]:Hide()
			end
		elseif LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 2 then
			local buffsize = ((LunaTargetFrame:GetWidth()-(buffcount-1))/buffcount)
			LunaTargetFrame:RegisterEvent("UNIT_AURA")
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
			LunaTargetFrame:RegisterEvent("UNIT_AURA")
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
			LunaTargetFrame:RegisterEvent("UNIT_AURA")
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
			LunaTargetFrame:RegisterEvent("UNIT_AURA")
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
		LunaTargetFrame.bars["Castbar"].Text:SetText(spell)
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
		if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[3].BarSelect) then
			LunaOptionsFrame.pages[3].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[3].barorder:SetValue(k)
			break
		end
	end
	SetIconPositions()
	LunaTargetFrame.AdjustBars()
end

function Luna_Target_Events:PARTY_LOOT_METHOD_CHANGED()
	local Lootmaster;
	_, Lootmaster = GetLootMethod()
	if Lootmaster == 0 and UnitIsUnit("player", "target") then
		LunaTargetFrame.Loot:Show()
	elseif Lootmaster and UnitIsUnit("party"..Lootmaster, "target") then
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
	LunaTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax("target"))
	if not UnitIsConnected("target") then
		LunaTargetFrame.bars["Healthbar"].hpp:SetText("OFFLINE")
		LunaTargetFrame.bars["Healthbar"]:SetValue(0)
	elseif UnitHealth("target") < 1 then			-- This prevents negative health
		LunaTargetFrame.bars["Healthbar"].hpp:SetText("DEAD")
		LunaTargetFrame.bars["Healthbar"]:SetValue(0)
	else
		LunaTargetFrame.bars["Healthbar"]:SetValue(UnitHealth("target"))
		LunaTargetFrame.bars["Healthbar"].hpp:SetText(LunaUnitFrames:GetHealthString("target"))
	end
end
Luna_Target_Events.UNIT_MAXHEALTH = Luna_Target_Events.UNIT_HEALTH;

function Luna_Target_Events:UNIT_MANA()
	if UnitHealth("target") < 1 or not UnitIsConnected("target") then
		LunaTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax("target"))
		LunaTargetFrame.bars["Powerbar"]:SetValue(0)
		LunaTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString("target"))
	else
		LunaTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax("target"))
		LunaTargetFrame.bars["Powerbar"]:SetValue(UnitMana("target"))
		LunaTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString("target"))
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
		local color = LunaOptions.ClassColors[class]
		LunaTargetFrame.bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
		LunaTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
	elseif UnitIsTapped("target") and not UnitIsTappedByPlayer("target") then
		LunaTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.5, 0.5, 0.5)
		LunaTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.5, 0.5, 0.5, 0.25)
	else
		reaction = UnitReaction("target", "player")
		if reaction and reaction < 4 then
			LunaTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.9, 0, 0)
			LunaTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.9, 0, 0, 0.25)
		elseif reaction and reaction > 4 then
			LunaTargetFrame.bars["Healthbar"]:SetStatusBarColor(0, 0.8, 0)
			LunaTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0, 0.8, 0, 0.25)
		else
			LunaTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.93, 0.93, 0)
			LunaTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.93, 0.93, 0, 0.25)
		end
	end
	Luna_Target_Events.UNIT_HEALTH()
	Luna_Target_Events.UNIT_MANA()
	Luna_Target_Events.UNIT_DISPLAYPOWER()
	Luna_Target_Events.PLAYER_COMBO_POINTS()
	Luna_Target_Events.PARTY_LEADER_CHANGED()
	Luna_Target_Events.UNIT_PORTRAIT_UPDATE()
	Luna_Target_Events.UNIT_DISPLAYPOWER()
	Luna_Target_Events.UNIT_LEVEL()
	Luna_Target_Events.RAID_TARGET_UPDATE()
	Luna_Target_Events.UNIT_AURA()
	LunaTargetFrame.name:SetText(UnitName("target"))
	Luna_Target_Events:PARTY_LOOT_METHOD_CHANGED()
	
	if UnitIsPlayer("target") then
		LunaTargetFrame.class:SetText(UnitClass("target"))
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
		LunaTargetFrame.class:SetText(UnitCreatureType("target"))
		LunaTargetFrame.PVPRank:Hide()
	else
		LunaTargetFrame.class:SetText(UnitClassification("target").." "..UnitCreatureType("target"))
		LunaTargetFrame.PVPRank:Hide()
	end
end

function Luna_Target_Events:PARTY_LEADER_CHANGED()
	if UnitIsPartyLeader("target") then
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
	elseif not UnitIsDeadOrGhost("target") then
		LunaTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		LunaTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
	else
		LunaTargetFrame.bars["Powerbar"]:SetStatusBarColor(0, 0, 0, .25)
		LunaTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(0, 0, 0, .25)
	end
	Luna_Target_Events.UNIT_MANA()
end

function Luna_Target_Events:UNIT_PORTRAIT_UPDATE()
	local portrait = LunaTargetFrame.bars["Portrait"]
	if(portrait.type == "3D") then
		if(not UnitExists("target") or not UnitIsConnected("target") or not UnitIsVisible("target")) then
			portrait:SetModelScale(4.25)
			portrait:SetPosition(0, 0, -1)
			portrait:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
		else
			portrait:SetUnit("target")
			portrait:SetCamera(0)
		end
	else
		SetPortraitTexture(portrait, "target")
	end
end

function Luna_Target_Events:UNIT_LEVEL()
	local lvl = UnitLevel("target")
	if lvl < 1 then
		LunaTargetFrame.lvl:SetText("??")
	else
		LunaTargetFrame.lvl:SetText(lvl)
	end
end

function Luna_Target_Events:UNIT_COMBAT()
	if arg1 == this.unit then
		CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5)
	end
end

function Luna_Target_Events:UNIT_SPELLMISS()
	if arg1 == this.unit then
		CombatFeedback_OnSpellMissEvent(arg2)
	end
end