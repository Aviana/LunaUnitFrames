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

Luna_HideBlizz(TargetFrame)
Luna_HideBlizz(ComboFrame)

local function Luna_Target_Tip()
	UnitFrame_OnEnter()
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

local function AdjustForCP(hasCP)
	if hasCP == 1 then
		local frameHeight = LunaTargetFrame:GetHeight()
		LunaTargetFrame.HealthBar:SetHeight((frameHeight*0.42)-1)
		LunaTargetFrame.PowerBar:SetHeight(frameHeight-(frameHeight*0.58)-1)
		LunaTargetFrame.portrait:SetHeight(frameHeight-LunaTargetFrame.cp[1]:GetHeight())
	else
		local frameHeight = LunaTargetFrame:GetHeight()
		LunaTargetFrame.HealthBar:SetHeight(frameHeight*0.58)
		LunaTargetFrame.PowerBar:SetHeight(frameHeight-(frameHeight*0.58)-1)
		LunaTargetFrame.portrait:SetHeight(frameHeight)
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
	LunaTargetFrame:SetScript("OnEnter", Luna_Target_Tip)
	LunaTargetFrame:SetScript("OnLeave", UnitFrame_OnLeave)
	LunaTargetFrame:SetMovable(0)
	LunaTargetFrame:RegisterForDrag("LeftButton")
	LunaTargetFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaTargetFrame:SetClampedToScreen(1)

	LunaTargetFrame.portrait = CreateFrame("PlayerModel", nil, LunaTargetFrame)
	LunaTargetFrame.portrait:SetScript("OnShow",function() this:SetCamera(0) end)
	LunaTargetFrame.portrait.type = "3D"
	LunaTargetFrame.portrait:SetPoint("TOPRIGHT", LunaTargetFrame, "TOPRIGHT", 1, 0)
	LunaTargetFrame.portrait.side = "right"

	LunaTargetFrame.feedbackText = LunaTargetFrame.portrait:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
	LunaTargetFrame.feedbackText:SetPoint("CENTER", LunaTargetFrame.portrait, "CENTER", 0, 0)
	LunaTargetFrame.feedbackText:SetTextColor(1,1,1)
	LunaTargetFrame.feedbackFontHeight = 20
	LunaTargetFrame.feedbackStartTime = 0

	LunaTargetFrame.Buffs = {}

	LunaTargetFrame.Buffs[1] = CreateFrame("Button", nil, LunaTargetFrame)
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
		LunaTargetFrame.Buffs[i] = CreateFrame("Button", nil, LunaTargetFrame)
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

	LunaTargetFrame.Debuffs[1] = CreateFrame("Button", nil, LunaTargetFrame)
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
		LunaTargetFrame.Debuffs[i] = CreateFrame("Button", nil, LunaTargetFrame)
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
	LunaTargetFrame.HealthBar = CreateFrame("StatusBar", nil, LunaTargetFrame)
	LunaTargetFrame.HealthBar:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaTargetFrame.HealthBar:SetPoint("TOPRIGHT", LunaTargetFrame.portrait, "TOPLEFT", -1, 0)

	-- Healthbar background
	LunaTargetFrame.HealthBar.hpbg = LunaTargetFrame.HealthBar:CreateTexture(nil, "BORDER")
	LunaTargetFrame.HealthBar.hpbg:SetAllPoints(LunaTargetFrame.HealthBar)
	LunaTargetFrame.HealthBar.hpbg:SetTexture(.25,.25,.25, 0.25)

	-- Healthbar text
	LunaTargetFrame.HealthBar.hpp = LunaTargetFrame.HealthBar:CreateFontString(nil, "OVERLAY", LunaTargetFrame.HealthBar)
	LunaTargetFrame.HealthBar.hpp:SetPoint("RIGHT", -2, -1)
	LunaTargetFrame.HealthBar.hpp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.HealthBar.hpp:SetShadowColor(0, 0, 0)
	LunaTargetFrame.HealthBar.hpp:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.HealthBar.hpp:SetTextColor(1,1,1)

	LunaTargetFrame.name = LunaTargetFrame.HealthBar:CreateFontString(nil, "OVERLAY", LunaTargetFrame.HealthBar)
	LunaTargetFrame.name:SetPoint("LEFT", 2, -1)
	LunaTargetFrame.name:SetJustifyH("LEFT")
	LunaTargetFrame.name:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.name:SetShadowColor(0, 0, 0)
	LunaTargetFrame.name:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.name:SetTextColor(1,1,1)
	LunaTargetFrame.name:SetText(UnitName("target"))

	-- Manabar
	LunaTargetFrame.PowerBar = CreateFrame("StatusBar", nil, LunaTargetFrame)
	LunaTargetFrame.PowerBar:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaTargetFrame.PowerBar:SetPoint("TOPLEFT", LunaTargetFrame.HealthBar, "BOTTOMLEFT", 0, -1)

	-- Manabar background
	LunaTargetFrame.PowerBar.ppbg = LunaTargetFrame.PowerBar:CreateTexture(nil, "BORDER")
	LunaTargetFrame.PowerBar.ppbg:SetAllPoints(LunaTargetFrame.PowerBar)
	LunaTargetFrame.PowerBar.ppbg:SetTexture(.25,.25,.25)

	LunaTargetFrame.PowerBar.ppp = LunaTargetFrame.PowerBar:CreateFontString(nil, "OVERLAY", LunaTargetFrame.PowerBar)
	LunaTargetFrame.PowerBar.ppp:SetPoint("RIGHT", -2, -1)
	LunaTargetFrame.PowerBar.ppp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.PowerBar.ppp:SetShadowColor(0, 0, 0)
	LunaTargetFrame.PowerBar.ppp:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.PowerBar.ppp:SetTextColor(1,1,1)

	LunaTargetFrame.lvl = LunaTargetFrame.PowerBar:CreateFontString(nil, "OVERLAY")
	LunaTargetFrame.lvl:SetPoint("LEFT", LunaTargetFrame.PowerBar, "LEFT", 2, -1)
	LunaTargetFrame.lvl:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.lvl:SetShadowColor(0, 0, 0)
	LunaTargetFrame.lvl:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.lvl:SetText(UnitLevel("target"))

	LunaTargetFrame.class = LunaTargetFrame.PowerBar:CreateFontString(nil, "OVERLAY")
	LunaTargetFrame.class:SetPoint("LEFT", LunaTargetFrame.lvl, "RIGHT",  1, 0)
	LunaTargetFrame.class:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetFrame.class:SetShadowColor(0, 0, 0)
	LunaTargetFrame.class:SetShadowOffset(0.8, -0.8)
	LunaTargetFrame.class:SetText(UnitClass("target"))

	LunaTargetFrame.cp = {}

	for i=1,5 do
		LunaTargetFrame.cp[i] = CreateFrame("StatusBar", nil, LunaTargetFrame)
		LunaTargetFrame.cp[i]:SetStatusBarTexture(LunaOptions.statusbartexture)
		LunaTargetFrame.cp[i]:Hide()
		LunaTargetFrame.cp[i]:SetStatusBarColor(1, 0.80, 0)
	end
	LunaTargetFrame.cp[1]:SetPoint("TOPRIGHT", LunaTargetFrame.portrait, "BOTTOMRIGHT",  -1, 0)
	for i=2,5 do
		LunaTargetFrame.cp[i]:SetPoint("TOPRIGHT", LunaTargetFrame.cp[i-1], "TOPLEFT",  -1, 0)
	end

	LunaTargetFrame.icon = LunaTargetFrame.portrait:CreateTexture(nil, "OVERLAY")
	LunaTargetFrame.icon:SetHeight(20)
	LunaTargetFrame.icon:SetWidth(20)
	LunaTargetFrame.icon:SetPoint("CENTER", LunaTargetFrame.portrait, "TOPLEFT", 0, 0)
	LunaTargetFrame.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

	LunaTargetFrame.rank = LunaTargetFrame.portrait:CreateTexture(nil, "OVERLAY")
	LunaTargetFrame.rank:SetHeight(10)
	LunaTargetFrame.rank:SetWidth(10)
	LunaTargetFrame.rank:SetPoint("CENTER", LunaTargetFrame.portrait, "BOTTOMRIGHT", -2, 2)

	LunaTargetFrame.leader = LunaTargetFrame.portrait:CreateTexture(nil, "OVERLAY")
	LunaTargetFrame.leader:SetHeight(10)
	LunaTargetFrame.leader:SetWidth(10)
	LunaTargetFrame.leader:SetPoint("CENTER", LunaTargetFrame.portrait, "TOPRIGHT", -2, -2)
	LunaTargetFrame.leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")

	LunaTargetFrame.loot = LunaTargetFrame.portrait:CreateTexture(nil, "OVERLAY")
	LunaTargetFrame.loot:SetHeight(10)
	LunaTargetFrame.loot:SetWidth(10)
	LunaTargetFrame.loot:SetPoint("CENTER", LunaTargetFrame.portrait, "TOPRIGHT", -2, -12)
	LunaTargetFrame.loot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
	
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
	
	LunaTargetFrame.AdjustBars = function()
		local frameHeight = LunaTargetFrame:GetHeight()
		local frameWidth = (LunaTargetFrame:GetWidth()-frameHeight)
		LunaTargetFrame.portrait:SetHeight(frameHeight+1)
		LunaTargetFrame.portrait:SetWidth(frameHeight) --square it
		LunaTargetFrame.HealthBar:SetWidth(frameWidth)
		LunaTargetFrame.PowerBar:SetWidth(frameWidth)
		for i=1, 5 do
			LunaTargetFrame.cp[i]:SetWidth(((frameWidth+frameHeight)/5)-1)
		end
		LunaTargetFrame.cp[5]:SetWidth(LunaTargetFrame.cp[5]:GetWidth()+1)
		LunaTargetFrame.HealthBar:SetHeight(frameHeight*0.58)
		LunaTargetFrame.PowerBar:SetHeight(frameHeight-(frameHeight*0.58)-1)
		for i=1, MAX_COMBO_POINTS do
			LunaTargetFrame.cp[i]:SetHeight(frameHeight*0.15)
		end
	end
	LunaTargetFrame.AdjustBars()
	LunaUnitFrames:UpdateTargetBuffLayout()
end

function LunaUnitFrames:UpdateTargetBuffLayout()
	if LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 1 then
		LunaTargetFrame:UnregisterEvent("UNIT_AURA")
		for i=1, 16 do
			LunaTargetFrame.Buffs[i]:Hide()
			LunaTargetFrame.Debuffs[i]:Hide()
		end
	elseif LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 2 then
		LunaTargetFrame:RegisterEvent("UNIT_AURA")
		LunaTargetFrame.Buffs[1]:ClearAllPoints()
		LunaTargetFrame.Buffs[1]:SetPoint("BOTTOMLEFT", LunaTargetFrame, "TOPLEFT", -1, 3)
		LunaTargetFrame.Debuffs[1]:ClearAllPoints()
		LunaTargetFrame.Debuffs[1]:SetPoint("BOTTOMLEFT", LunaTargetFrame.Buffs[1], "TOPLEFT", 0, 3)
		for i=2, 16 do
			LunaTargetFrame.Buffs[i]:ClearAllPoints()
			LunaTargetFrame.Buffs[i]:SetPoint("TOPLEFT", LunaTargetFrame.Buffs[i-1], "TOPRIGHT",1, 0)
			LunaTargetFrame.Debuffs[i]:ClearAllPoints()
			LunaTargetFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaTargetFrame.Debuffs[i-1], "TOPRIGHT",1, 0)
		end
		LunaUnitFrames:UpdateTargetBuffSize()
		Luna_Target_Events:UNIT_AURA()
	elseif LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 3 then
		LunaTargetFrame:RegisterEvent("UNIT_AURA")
		LunaTargetFrame.Buffs[1]:ClearAllPoints()
		LunaTargetFrame.Buffs[1]:SetPoint("TOPLEFT", LunaTargetFrame, "BOTTOMLEFT", -1, -3)
		LunaTargetFrame.Debuffs[1]:ClearAllPoints()
		LunaTargetFrame.Debuffs[1]:SetPoint("TOPLEFT", LunaTargetFrame.Buffs[1], "BOTTOMLEFT", 0, -3)
		for i=2, 16 do
			LunaTargetFrame.Buffs[i]:ClearAllPoints()
			LunaTargetFrame.Buffs[i]:SetPoint("TOPLEFT", LunaTargetFrame.Buffs[i-1], "TOPRIGHT", 1, 0)
			LunaTargetFrame.Debuffs[i]:ClearAllPoints()
			LunaTargetFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaTargetFrame.Debuffs[i-1], "TOPRIGHT", 1, 0)
		end
		LunaUnitFrames:UpdateTargetBuffSize()
		Luna_Target_Events:UNIT_AURA()
	elseif LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 4 then
		LunaTargetFrame:RegisterEvent("UNIT_AURA")
		LunaTargetFrame.Buffs[1]:ClearAllPoints()
		LunaTargetFrame.Buffs[1]:SetPoint("TOPRIGHT", LunaTargetFrame, "TOPLEFT", -3, 1)
		LunaTargetFrame.Debuffs[1]:ClearAllPoints()
		LunaTargetFrame.Debuffs[1]:SetPoint("TOPLEFT", LunaTargetFrame.Buffs[9], "BOTTOMLEFT", 0, -1)
		LunaTargetFrame.Buffs[9]:ClearAllPoints()
		LunaTargetFrame.Buffs[9]:SetPoint("TOPLEFT", LunaTargetFrame.Buffs[1], "BOTTOMLEFT", 0, -1)
		LunaTargetFrame.Debuffs[9]:ClearAllPoints()
		LunaTargetFrame.Debuffs[9]:SetPoint("TOPLEFT", LunaTargetFrame.Debuffs[1], "BOTTOMLEFT", 0, -1)
		for i=2, 8 do
			LunaTargetFrame.Buffs[i]:ClearAllPoints()
			LunaTargetFrame.Buffs[i]:SetPoint("TOPRIGHT", LunaTargetFrame.Buffs[i-1], "TOPLEFT",1, 0)
			LunaTargetFrame.Debuffs[i]:ClearAllPoints()
			LunaTargetFrame.Debuffs[i]:SetPoint("TOPRIGHT", LunaTargetFrame.Debuffs[i-1], "TOPLEFT",1, 0)
		end
		for i=10, 16 do
			LunaTargetFrame.Buffs[i]:ClearAllPoints()
			LunaTargetFrame.Buffs[i]:SetPoint("TOPRIGHT", LunaTargetFrame.Buffs[i-1], "TOPLEFT",1, 0)
			LunaTargetFrame.Debuffs[i]:ClearAllPoints()
			LunaTargetFrame.Debuffs[i]:SetPoint("TOPRIGHT", LunaTargetFrame.Debuffs[i-1], "TOPLEFT",1, 0)
		end
		LunaUnitFrames:UpdateTargetBuffSize()
		Luna_Target_Events:UNIT_AURA()
	else
		LunaTargetFrame:RegisterEvent("UNIT_AURA")
		LunaTargetFrame.Buffs[1]:ClearAllPoints()
		LunaTargetFrame.Buffs[1]:SetPoint("TOPLEFT", LunaTargetFrame, "TOPRIGHT", 3, 1)
		LunaTargetFrame.Debuffs[1]:ClearAllPoints()
		LunaTargetFrame.Debuffs[1]:SetPoint("TOPLEFT", LunaTargetFrame.Buffs[9], "BOTTOMLEFT", 0, -1)
		LunaTargetFrame.Buffs[9]:ClearAllPoints()
		LunaTargetFrame.Buffs[9]:SetPoint("TOPLEFT", LunaTargetFrame.Buffs[1], "BOTTOMLEFT", 0, -1)
		LunaTargetFrame.Debuffs[9]:ClearAllPoints()
		LunaTargetFrame.Debuffs[9]:SetPoint("TOPLEFT", LunaTargetFrame.Debuffs[1], "BOTTOMLEFT", 0, -1)
		for i=2, 8 do
			LunaTargetFrame.Buffs[i]:ClearAllPoints()
			LunaTargetFrame.Buffs[i]:SetPoint("TOPLEFT", LunaTargetFrame.Buffs[i-1], "TOPRIGHT",1, 0)
			LunaTargetFrame.Debuffs[i]:ClearAllPoints()
			LunaTargetFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaTargetFrame.Debuffs[i-1], "TOPRIGHT",1, 0)
		end
		for i=10, 16 do
			LunaTargetFrame.Buffs[i]:ClearAllPoints()
			LunaTargetFrame.Buffs[i]:SetPoint("TOPLEFT", LunaTargetFrame.Buffs[i-1], "TOPRIGHT",1, 0)
			LunaTargetFrame.Debuffs[i]:ClearAllPoints()
			LunaTargetFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaTargetFrame.Debuffs[i-1], "TOPRIGHT",1, 0)
		end
		LunaUnitFrames:UpdateTargetBuffSize()
		Luna_Target_Events:UNIT_AURA()
	end
end

function LunaUnitFrames:UpdateTargetBuffSize()
	local size
	if LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 2 or LunaOptions.frames["LunaTargetFrame"].ShowBuffs == 3 then
		size = (LunaTargetFrame:GetWidth()-15)/16
	else
		size = (LunaTargetFrame:GetHeight()-3)/4
	end
	for i=1, 16 do
		LunaTargetFrame.Buffs[i]:SetHeight(size)
		LunaTargetFrame.Buffs[i]:SetWidth(size)
		LunaTargetFrame.Buffs[i].stacks:SetFont(LunaOptions.font, size*0.75)
		LunaTargetFrame.Debuffs[i]:SetHeight(size)
		LunaTargetFrame.Debuffs[i]:SetWidth(size)
		LunaTargetFrame.Debuffs[i].stacks:SetFont(LunaOptions.font, size*0.75)
	end	
end

function Luna_Target_Events:PARTY_LOOT_METHOD_CHANGED()
	local lootmaster;
	_, lootmaster = GetLootMethod()
	if lootmaster == 0 and UnitIsUnit("player", "target") then
		LunaTargetFrame.loot:Show()
	elseif lootmaster and UnitIsUnit("party"..lootmaster, "target") then
		LunaTargetFrame.loot:Show()
	else
		LunaTargetFrame.loot:Hide()
	end
end

function Luna_Target_Events:RAID_TARGET_UPDATE()
	local index = GetRaidTargetIndex("target");
	if (index) then
		SetRaidTargetIconTexture(LunaTargetFrame.icon, index);
		LunaTargetFrame.icon:Show();
	else
		LunaTargetFrame.icon:Hide();
	end
end

function Luna_Target_Events:UNIT_AURA()
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
		end
		LunaTargetFrame.Buffs[i]:SetNormalTexture(LunaTargetFrame.Buffs[i].texturepath)
	end
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
	local combopoints = GetComboPoints()
	if combopoints > 0 then
		AdjustForCP(1)
		for i=1,combopoints do
			LunaTargetFrame.cp[i]:Show()
		end
	else
		AdjustForCP(0)
		Luna_Target_Events.UNIT_PORTRAIT_UPDATE()
		for i=1, MAX_COMBO_POINTS do
			LunaTargetFrame.cp[i]:Hide()
		end
	end
end

function Luna_Target_Events:PLAYER_TARGET_CHANGED()
	LunaUnitFrames:UpdateTargetFrame()
end
Luna_Target_Events.UNIT_FACTION = Luna_Target_Events.PLAYER_TARGET_CHANGED

function Luna_Target_Events:UNIT_HEALTH()
	LunaTargetFrame.HealthBar:SetMinMaxValues(0, UnitHealthMax("target"))
	LunaTargetFrame.HealthBar:SetValue(UnitHealth("target"))
	LunaTargetFrame.HealthBar.hpp:SetText(UnitHealth("target").."/"..UnitHealthMax("target"))
	if (UnitIsDead("target") or UnitIsGhost("target")) then			-- This prevents negative health
		LunaTargetFrame.HealthBar:SetValue(0)
	end
end
Luna_Target_Events.UNIT_MAXHEALTH = Luna_Target_Events.UNIT_HEALTH;

function Luna_Target_Events:UNIT_MANA()
	if (UnitIsDead("target") or UnitIsGhost("target")) then
		LunaTargetFrame.PowerBar:SetValue(0)
		LunaTargetFrame.PowerBar.ppp:SetText("0/"..UnitManaMax("target"))
	else
		LunaTargetFrame.PowerBar:SetMinMaxValues(0, UnitManaMax("target"))
		LunaTargetFrame.PowerBar:SetValue(UnitMana("target"))
		LunaTargetFrame.PowerBar.ppp:SetText(UnitMana("target").."/"..UnitManaMax("target"))
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
	end
	local class = UnitClass("target")
	if UnitIsPlayer("target") then
		local color = LunaOptions.ClassColors[class]
		LunaTargetFrame.HealthBar:SetStatusBarColor(color[1],color[2],color[3])
		LunaTargetFrame.HealthBar.hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
	elseif UnitIsTapped("target") and not UnitIsTappedByPlayer("target") then
		LunaTargetFrame.HealthBar:SetStatusBarColor(0.5, 0.5, 0.5)
		LunaTargetFrame.HealthBar.hpbg:SetVertexColor(0.5, 0.5, 0.5, 0.25)
	else
		reaction = UnitReaction("target", "player")
		if reaction and reaction < 4 then
			LunaTargetFrame.HealthBar:SetStatusBarColor(0.9, 0, 0)
			LunaTargetFrame.HealthBar.hpbg:SetVertexColor(0.9, 0, 0, 0.25)
		elseif reaction and reaction > 4 then
			LunaTargetFrame.HealthBar:SetStatusBarColor(0, 0.8, 0)
			LunaTargetFrame.HealthBar.hpbg:SetVertexColor(0, 0.8, 0, 0.25)
		else
			LunaTargetFrame.HealthBar:SetStatusBarColor(0.93, 0.93, 0)
			LunaTargetFrame.HealthBar.hpbg:SetVertexColor(0.93, 0.93, 0, 0.25)
		end
	end
	if (UnitIsDead(LunaTargetFrame.unit) or UnitIsGhost(LunaTargetFrame.unit) or not UnitIsConnected(LunaTargetFrame.unit)) then
		LunaTargetFrame.HealthBar:SetMinMaxValues(0, UnitHealthMax(LunaTargetFrame.unit))
		LunaTargetFrame.HealthBar:SetValue(0)
		LunaTargetFrame.HealthBar.hpp:SetText("0/"..UnitHealthMax(LunaTargetFrame.unit))
			
		LunaTargetFrame.PowerBar:SetMinMaxValues(0, UnitManaMax(LunaTargetFrame.unit))
		LunaTargetFrame.PowerBar:SetValue(0)
		LunaTargetFrame.PowerBar.ppp:SetText("0/"..UnitManaMax(LunaTargetFrame.unit))
	else
		LunaTargetFrame.HealthBar:SetMinMaxValues(0, UnitHealthMax(LunaTargetFrame.unit))
		LunaTargetFrame.HealthBar:SetValue(UnitHealth(LunaTargetFrame.unit))
		LunaTargetFrame.HealthBar.hpp:SetText(UnitHealth(LunaTargetFrame.unit).."/"..UnitHealthMax(LunaTargetFrame.unit))
			
		LunaTargetFrame.PowerBar:SetMinMaxValues(0, UnitManaMax(LunaTargetFrame.unit))
		LunaTargetFrame.PowerBar:SetValue(UnitMana(LunaTargetFrame.unit))
		LunaTargetFrame.PowerBar.ppp:SetText(UnitMana(LunaTargetFrame.unit).."/"..UnitManaMax(LunaTargetFrame.unit))
	end	
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
			LunaTargetFrame.rank:Hide();
		elseif (rankNumber < 14) then
			rankNumber = rankNumber - 4;
			LunaTargetFrame.rank:SetTexture("Interface\\PvPRankBadges\\PvPRank0"..rankNumber);
			LunaTargetFrame.rank:Show();
		else
			rankNumber = rankNumber - 4;
			LunaTargetFrame.rank:SetTexture("Interface\\PvPRankBadges\\PvPRank"..rankNumber);
			LunaTargetFrame.rank:Show();
		end
	elseif UnitClassification("target") == "normal" then
		LunaTargetFrame.class:SetText(UnitCreatureType("target"))
		LunaTargetFrame.rank:Hide()
	else
		LunaTargetFrame.class:SetText(UnitClassification("target").." "..UnitCreatureType("target"))
		LunaTargetFrame.rank:Hide()
	end
end

function Luna_Target_Events:PARTY_LEADER_CHANGED()
	if UnitIsPartyLeader("target") then
		LunaTargetFrame.leader:Show()
	else
		LunaTargetFrame.leader:Hide()
	end
end

Luna_Target_Events.PARTY_MEMBERS_CHANGED = Luna_Target_Events.PARTY_LEADER_CHANGED

function Luna_Target_Events:UNIT_DISPLAYPOWER()
	local targetpower = UnitPowerType("target")
	
	if UnitManaMax("target") == 0 then
		LunaTargetFrame.PowerBar:SetStatusBarColor(0, 0, 0, .25)
		LunaTargetFrame.PowerBar.ppbg:SetVertexColor(0, 0, 0, .25)
	elseif targetpower == 1 then
		LunaTargetFrame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
		LunaTargetFrame.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
	elseif targetpower == 2 then
		LunaTargetFrame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3])
		LunaTargetFrame.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3], 0.25)
	elseif targetpower == 3 then
		LunaTargetFrame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
		LunaTargetFrame.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
	elseif not UnitIsDeadOrGhost("target") then
		LunaTargetFrame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		LunaTargetFrame.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
	else
		LunaTargetFrame.PowerBar:SetStatusBarColor(0, 0, 0, .25)
		LunaTargetFrame.PowerBar.ppbg:SetVertexColor(0, 0, 0, .25)
	end
	Luna_Target_Events.UNIT_MANA()
end

function Luna_Target_Events:UNIT_PORTRAIT_UPDATE()
	local portrait = LunaTargetFrame.portrait
	if(portrait.type == "3D") then
		if(not UnitExists("target") or not UnitIsConnected("target") or not UnitIsVisible("target")) then
			portrait:SetModelScale(4.25)
			portrait:SetPosition(0, 0, -1)
			portrait:SetModel"Interface\\Buttons\\talktomequestionmark.mdx"
		else
			portrait:SetUnit("target")
			portrait:SetCamera(0)
			portrait:Show()
		end
	else
		SetPortraitTexture(portrait, "target")
	end
end

function Luna_Target_Events:UNIT_LEVEL()
	local lvl = UnitLevel("target")
	if lvl == -1 then
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