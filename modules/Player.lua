local info = {text = "Reset Instances", func = ResetInstances, notCheckable = 1}
local Luna_Player_Events = {}

local dropdown = CreateFrame("Frame", "LunaUnitDropDownMenu", UIParent, "UIDropDownMenuTemplate")
local function Luna_PlayerDropDown_Initialize()
	UnitPopup_ShowMenu(dropdown, "SELF" , "player")
end

local function Luna_Player_OnClick()
	local button = arg1
	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit("player");
		elseif (CursorHasItem()) then
			DropItemOnUnit("player");
		else
			TargetUnit("player");
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
		if UnitIsPartyLeader("player") then
			UIDropDownMenu_AddButton(info, 1)
		end
	end
end

local function Luna_HideBlizz(frame)
	frame:UnregisterAllEvents()
	frame:Hide()
end

local function Luna_Player_Tip()
	UnitFrame_OnEnter()
end

local function Luna_Player_SetBuffTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	if (this.id > 16) then
		GameTooltip:SetUnitDebuff("player", this.id-16)
	else
		GameTooltip:SetUnitBuff("player", this.id)
	end
end

local function Luna_Player_SetBuffTooltipLeave()
	GameTooltip:Hide()
end

local function StartMoving()
	LunaPlayerFrame:StartMoving()
end

local function StopMovingOrSizing()
	LunaPlayerFrame:StopMovingOrSizing()
	_,_,_,LunaOptions.frames["LunaPlayerFrame"].position.x, LunaOptions.frames["LunaPlayerFrame"].position.y = LunaPlayerFrame:GetPoint()
end

local function Luna_Player_OnEvent()
	local func = Luna_Player_Events[event]
	if (func) then
		func()
	else
		DEFAULT_CHAT_FRAME:AddMessage("Luna Unit Frames - Player: Report the following event error to the author: "..event)
	end
end

function LunaUnitFrames:TogglePlayerLock()
	if LunaPlayerFrame:IsMovable() then
		LunaPlayerFrame:SetScript("OnDragStart", nil)
		LunaPlayerFrame:SetMovable(0)
		LunaOptionsFrame.Button7:SetText("Unlock Frames")
	else
		LunaPlayerFrame:SetScript("OnDragStart", StartMoving)
		LunaPlayerFrame:SetMovable(1)
		
		LunaOptionsFrame.Button7:SetText("Lock Frames")
	end
end

local function AdjustForCastbar(isCasting)
	if isCasting == 1 then
		local frameHeight = LunaPlayerFrame:GetHeight()
		LunaPlayerFrame.HealthBar:SetHeight((frameHeight*0.43)-1)
		LunaPlayerFrame.PowerBar:SetHeight(frameHeight-(frameHeight*0.69))
		LunaPlayerFrame.Castbar:Show()
	else
		local frameHeight = LunaPlayerFrame:GetHeight()
		LunaPlayerFrame.HealthBar:SetHeight(frameHeight*0.58)
		LunaPlayerFrame.PowerBar:SetHeight(frameHeight-(frameHeight*0.58)-1)
		LunaPlayerFrame.Castbar:Hide()
	end
end
			
local function Luna_Player_OnUpdate()
	local sign
	local current_time = LunaPlayerFrame.Castbar.maxValue - GetTime()
	if (LunaPlayerFrame.Castbar.channeling) then
		current_time = LunaPlayerFrame.Castbar.endTime - GetTime()
	end
	local text = string.sub(math.max(current_time,0)+0.001,1,4)
	if (LunaPlayerFrame.Castbar.delaySum ~= 0) then
		local delay = string.sub(math.max(LunaPlayerFrame.Castbar.delaySum/1000, 0)+0.001,1,4)
		if (LunaPlayerFrame.Castbar.channeling == 1) then
			sign = "-"
		else
			sign = "+"
		end
		text = "|cffcc0000"..sign..delay.."|r "..text
	end
	LunaPlayerFrame.Castbar.Time:SetText(text)
	
	if (LunaPlayerFrame.Castbar.casting) then
		local status = GetTime()
		if (status > LunaPlayerFrame.Castbar.maxValue) then
			status = LunaPlayerFrame.Castbar.maxValue
		end
		LunaPlayerFrame.Castbar:SetValue(status)
	elseif (LunaPlayerFrame.Castbar.channeling) then
		local time = GetTime()
		if (time > LunaPlayerFrame.Castbar.endTime) then
			time = LunaPlayerFrame.Castbar.endTime
		end
		if (time == LunaPlayerFrame.Castbar.endTime) then
			LunaPlayerFrame.Castbar.channeling = nil
			AdjustForCastbar(0)
			return
		end
		local barValue = LunaPlayerFrame.Castbar.startTime + (LunaPlayerFrame.Castbar.endTime - time)
		LunaPlayerFrame.Castbar:SetValue(barValue)
	end
end

function LunaUnitFrames:CreatePlayerFrame()
	LunaPlayerFrame = CreateFrame("Button", "LunaPlayerFrame", UIParent)

	LunaPlayerFrame:SetHeight(LunaOptions.frames["LunaPlayerFrame"].size.y)
	LunaPlayerFrame:SetWidth(LunaOptions.frames["LunaPlayerFrame"].size.x)
	LunaPlayerFrame:SetScale(LunaOptions.frames["LunaPlayerFrame"].scale)
	LunaPlayerFrame:SetBackdrop(LunaOptions.backdrop)
	LunaPlayerFrame:SetBackdropColor(0,0,0,1)
	LunaPlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaPlayerFrame"].position.x, LunaOptions.frames["LunaPlayerFrame"].position.y)
	LunaPlayerFrame:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
	LunaPlayerFrame.unit = "player"
	LunaPlayerFrame:SetScript("OnEnter", Luna_Player_Tip)
	LunaPlayerFrame:SetScript("OnLeave", UnitFrame_OnLeave)
	LunaPlayerFrame:SetMovable(0)
	LunaPlayerFrame:RegisterForDrag("LeftButton")
	LunaPlayerFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaPlayerFrame:SetClampedToScreen(1)


	LunaPlayerFrame.portrait = CreateFrame("PlayerModel", nil, LunaPlayerFrame)
	LunaPlayerFrame.portrait:SetScript("OnShow",function() this:SetCamera(0) end)
	LunaPlayerFrame.portrait.type = "3D"
	LunaPlayerFrame.portrait:SetPoint("TOPLEFT", LunaPlayerFrame, "TOPLEFT")
	LunaPlayerFrame.portrait.side = "left"

	LunaPlayerFrame.feedbackText = LunaPlayerFrame.portrait:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
	LunaPlayerFrame.feedbackText:SetPoint("CENTER", LunaPlayerFrame.portrait, "CENTER", 0, 0)
	LunaPlayerFrame.feedbackText:SetTextColor(1,1,1)
	LunaPlayerFrame.feedbackFontHeight = 20
	LunaPlayerFrame.feedbackStartTime = 0
	

	LunaPlayerFrame.Buffs = {}

	LunaPlayerFrame.Buffs[1] = CreateFrame("Button", nil, LunaPlayerFrame)
	LunaPlayerFrame.Buffs[1].texturepath = UnitBuff("player",1)
	LunaPlayerFrame.Buffs[1].id = 1
	LunaPlayerFrame.Buffs[1]:SetNormalTexture(LunaPlayerFrame.Buffs[1].texturepath)
	LunaPlayerFrame.Buffs[1]:SetScript("OnEnter", Luna_Player_SetBuffTooltip)
	LunaPlayerFrame.Buffs[1]:SetScript("OnLeave", Luna_Player_SetBuffTooltipLeave)

	LunaPlayerFrame.Buffs[1].stacks = LunaPlayerFrame.Buffs[1]:CreateFontString(nil, "OVERLAY", LunaPlayerFrame.Buffs[1])
	LunaPlayerFrame.Buffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaPlayerFrame.Buffs[1], 0, 0)
	LunaPlayerFrame.Buffs[1].stacks:SetJustifyH("LEFT")
	LunaPlayerFrame.Buffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaPlayerFrame.Buffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaPlayerFrame.Buffs[1].stacks:SetTextColor(1,1,1)
	
	for i=2, 16 do
		LunaPlayerFrame.Buffs[i] = CreateFrame("Button", nil, LunaPlayerFrame)
		LunaPlayerFrame.Buffs[i].texturepath = UnitBuff("player",i)
		LunaPlayerFrame.Buffs[i].id = i
		LunaPlayerFrame.Buffs[i]:SetNormalTexture(LunaPlayerFrame.Buffs[i].texturepath)
		LunaPlayerFrame.Buffs[i]:SetScript("OnEnter", Luna_Player_SetBuffTooltip)
		LunaPlayerFrame.Buffs[i]:SetScript("OnLeave", Luna_Player_SetBuffTooltipLeave)
		
		LunaPlayerFrame.Buffs[i].stacks = LunaPlayerFrame.Buffs[i]:CreateFontString(nil, "OVERLAY", LunaPlayerFrame.Buffs[i])
		LunaPlayerFrame.Buffs[i].stacks:SetPoint("BOTTOMRIGHT", LunaPlayerFrame.Buffs[i], 0, 0)
		LunaPlayerFrame.Buffs[i].stacks:SetJustifyH("LEFT")
		LunaPlayerFrame.Buffs[i].stacks:SetShadowColor(0, 0, 0)
		LunaPlayerFrame.Buffs[i].stacks:SetShadowOffset(0.8, -0.8)
		LunaPlayerFrame.Buffs[i].stacks:SetTextColor(1,1,1)
	end

	LunaPlayerFrame.Debuffs = {}

	LunaPlayerFrame.Debuffs[1] = CreateFrame("Button", nil, LunaPlayerFrame)
	LunaPlayerFrame.Debuffs[1].texturepath = UnitDebuff("player",1)
	LunaPlayerFrame.Debuffs[1].id = 17
	LunaPlayerFrame.Debuffs[1]:SetNormalTexture(LunaPlayerFrame.Debuffs[1].texturepath)
	LunaPlayerFrame.Debuffs[1]:SetScript("OnEnter", Luna_Player_SetBuffTooltip)
	LunaPlayerFrame.Debuffs[1]:SetScript("OnLeave", Luna_Player_SetBuffTooltipLeave)

	LunaPlayerFrame.Debuffs[1].stacks = LunaPlayerFrame.Debuffs[1]:CreateFontString(nil, "OVERLAY", LunaPlayerFrame.Debuffs[1])
	LunaPlayerFrame.Debuffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaPlayerFrame.Debuffs[1], 0, 0)
	LunaPlayerFrame.Debuffs[1].stacks:SetJustifyH("LEFT")
	LunaPlayerFrame.Debuffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaPlayerFrame.Debuffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaPlayerFrame.Debuffs[1].stacks:SetTextColor(1,1,1)

	for i=2, 16 do
		LunaPlayerFrame.Debuffs[i] = CreateFrame("Button", nil, LunaPlayerFrame)
		LunaPlayerFrame.Debuffs[i].texturepath = UnitDebuff("player",i)
		LunaPlayerFrame.Debuffs[i].id = i+16
		LunaPlayerFrame.Debuffs[i]:SetNormalTexture(LunaPlayerFrame.Debuffs[i].texturepath)
		LunaPlayerFrame.Debuffs[i]:SetScript("OnEnter", Luna_Player_SetBuffTooltip)
		LunaPlayerFrame.Debuffs[i]:SetScript("OnLeave", Luna_Player_SetBuffTooltipLeave)
		
		LunaPlayerFrame.Debuffs[i].stacks = LunaPlayerFrame.Debuffs[i]:CreateFontString(nil, "OVERLAY", LunaPlayerFrame.Debuffs[i])
		LunaPlayerFrame.Debuffs[i].stacks:SetPoint("BOTTOMRIGHT", LunaPlayerFrame.Debuffs[i], 0, 0)
		LunaPlayerFrame.Debuffs[i].stacks:SetJustifyH("LEFT")
		LunaPlayerFrame.Debuffs[i].stacks:SetShadowColor(0, 0, 0)
		LunaPlayerFrame.Debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
		LunaPlayerFrame.Debuffs[i].stacks:SetTextColor(1,1,1)
	end
	
	-- Healthbar
	local hp = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	hp:SetStatusBarTexture(LunaOptions.statusbartexture)
	hp:SetPoint("TOPLEFT", LunaPlayerFrame.portrait, "TOPRIGHT", 0, 0)
	LunaPlayerFrame.HealthBar = hp

	-- Healthbar background
	local hpbg = hp:CreateTexture(nil, "BORDER")
	hpbg:SetAllPoints(hp)
	hpbg:SetTexture(.25,.25,.25)
	LunaPlayerFrame.HealthBar.hpbg = hpbg

	-- Healthbar text
	local hpp = hp:CreateFontString(nil, "OVERLAY", hp)
	hpp:SetPoint("RIGHT", -2, -1)
	hpp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	hpp:SetShadowColor(0, 0, 0)
	hpp:SetShadowOffset(0.8, -0.8)
	hpp:SetTextColor(1,1,1)
	LunaPlayerFrame.HealthBar.hpp = hpp

	local name = hp:CreateFontString(nil, "OVERLAY", hp)
	name:SetPoint("LEFT", 2, -1)
	name:SetJustifyH("LEFT")
	name:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	name:SetShadowColor(0, 0, 0)
	name:SetShadowOffset(0.8, -0.8)
	name:SetTextColor(1,1,1)
	name:SetText(UnitName("player"))
	LunaPlayerFrame.name = name

	-- Manabar
	local pp = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	pp:SetStatusBarTexture(LunaOptions.statusbartexture)
	pp:SetPoint("TOPLEFT", LunaPlayerFrame.HealthBar, "BOTTOMLEFT", 0, -1)
	LunaPlayerFrame.PowerBar = pp
	
	LunaPlayerFrame.PowerBar.EnergyUpdate = function()
		local time = GetTime()
		if (time - LunaPlayerFrame.PowerBar.Ticker.startTime) >= 2 then 		--Ticks happen every 2 sec
			LunaPlayerFrame.PowerBar.Ticker.startTime = GetTime()
		end
		local sparkPosition = (((time - LunaPlayerFrame.PowerBar.Ticker.startTime) / 2)* LunaPlayerFrame.PowerBar:GetWidth())
		LunaPlayerFrame.PowerBar.Ticker:SetPoint("CENTER", LunaPlayerFrame.PowerBar, "LEFT", sparkPosition, 0)
	end

	-- Manabar background
	local ppbg = pp:CreateTexture(nil, "BORDER")
	ppbg:SetAllPoints(pp)
	ppbg:SetTexture(.25,.25,.25)
	LunaPlayerFrame.PowerBar.ppbg = ppbg

	local ppp = pp:CreateFontString(nil, "OVERLAY", pp)
	ppp:SetPoint("RIGHT", -2, -1)
	ppp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	ppp:SetShadowColor(0, 0, 0)
	ppp:SetShadowOffset(0.8, -0.8)
	ppp:SetTextColor(1,1,1)
	LunaPlayerFrame.PowerBar.ppp = ppp

	LunaPlayerFrame.PowerBar.Ticker = LunaPlayerFrame.PowerBar:CreateTexture(nil, "OVERLAY")
	LunaPlayerFrame.PowerBar.Ticker:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	LunaPlayerFrame.PowerBar.Ticker:SetVertexColor(1, 1, 1, 0.5)
	LunaPlayerFrame.PowerBar.Ticker:SetBlendMode("ADD")
	LunaPlayerFrame.PowerBar.Ticker:SetWidth(3)
	LunaPlayerFrame.PowerBar.oldMana = 100
	LunaPlayerFrame.PowerBar.Ticker.startTime = GetTime()
	
	local lvl
	lvl = pp:CreateFontString(nil, "OVERLAY")
	lvl:SetPoint("LEFT", pp, "LEFT", 2, -1)
	lvl:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	lvl:SetShadowColor(0, 0, 0)
	lvl:SetShadowOffset(0.8, -0.8)
	lvl:SetText(UnitLevel("player"))
	LunaPlayerFrame.Lvl = lvl

	local class = pp:CreateFontString(nil, "OVERLAY")
	class:SetPoint("LEFT", lvl, "RIGHT",  1, 0)
	class:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	class:SetShadowColor(0, 0, 0)
	class:SetShadowOffset(0.8, -0.8)
	class:SetText(UnitClass("player"))
	LunaPlayerFrame.Class = class

	-- Castbar
	local Castbar = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	Castbar:SetStatusBarTexture(LunaOptions.statusbartexture)
	Castbar:SetStatusBarColor(1, 0.7, 0.3)
	Castbar:SetPoint("TOP", pp, "BOTTOM", 0, -1)
	LunaPlayerFrame.Castbar = Castbar
	LunaPlayerFrame.Castbar.maxValue = 0
	LunaPlayerFrame.Castbar.delaySum = 0
	LunaPlayerFrame.Castbar.holdTime = 0

	-- Add a background
	local Background = Castbar:CreateTexture(nil, 'BACKGROUND')
	Background:SetAllPoints(Castbar)
	Background:SetTexture(0, 0, 1, 0.20)
	LunaPlayerFrame.Castbar.bg = Background

	-- Add a spark
	local Spark = Castbar:CreateTexture(nil, "OVERLAY")
	Spark:SetBlendMode("ADD")
	LunaPlayerFrame.Castbar.Spark = Spark

	-- Add a timer
	local Time = Castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	Time:SetPoint("RIGHT", Castbar)
	LunaPlayerFrame.Castbar.Time = Time

	-- Add spell text
	local Text = Castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	Text:SetPoint("LEFT", Castbar)
	LunaPlayerFrame.Castbar.Text = Text

	LunaPlayerFrame.Castbar:Hide()

	local icon = LunaPlayerFrame.portrait:CreateTexture(nil, "OVERLAY")
	icon:SetHeight(20)
	icon:SetWidth(20)
	icon:SetPoint("CENTER", LunaPlayerFrame.portrait, "TOPRIGHT", 0, 0)
	icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	LunaPlayerFrame.RaidIcon = icon

	local rank = LunaPlayerFrame.portrait:CreateTexture(nil, "OVERLAY")
	rank:SetHeight(10)
	rank:SetWidth(10)
	rank:SetPoint("CENTER", LunaPlayerFrame.portrait, "BOTTOMLEFT", 2, 2)
	LunaPlayerFrame.PVPRank = rank

	local leader = LunaPlayerFrame.portrait:CreateTexture(nil, "OVERLAY")
	leader:SetHeight(10)
	leader:SetWidth(10)
	leader:SetPoint("CENTER", LunaPlayerFrame.portrait, "TOPLEFT", 2, -2)
	leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
	LunaPlayerFrame.Leader = leader

	local loot = LunaPlayerFrame.portrait:CreateTexture(nil, "OVERLAY")
	loot:SetHeight(10)
	loot:SetWidth(10)
	loot:SetPoint("CENTER", LunaPlayerFrame.portrait, "TOPLEFT", 2, -12)
	loot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
	LunaPlayerFrame.Loot = loot

	local state = LunaPlayerFrame.portrait:CreateTexture(nil, "OVERLAY")
	state:SetHeight(14)
	state:SetWidth(14)
	state:SetPoint("CENTER", LunaPlayerFrame.portrait, "BOTTOMRIGHT", -2, 2)
	state:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	state:SetTexCoord(0.57, 0.90, 0.08, 0.41)
	LunaPlayerFrame.Combat = state
		
	-- Registering Shit
	LunaPlayerFrame:RegisterEvent("UNIT_HEALTH")
	LunaPlayerFrame:RegisterEvent("UNIT_MAXHEALTH")
	LunaPlayerFrame:RegisterEvent("UNIT_MAXMANA")
	LunaPlayerFrame:RegisterEvent("UNIT_MANA")
	LunaPlayerFrame:RegisterEvent("UNIT_RAGE")
	LunaPlayerFrame:RegisterEvent("UNIT_MAXRAGE")
	LunaPlayerFrame:RegisterEvent("UNIT_ENERGY")
	LunaPlayerFrame:RegisterEvent("UNIT_MAXENERGY")
	LunaPlayerFrame:RegisterEvent("UNIT_DISPLAYPOWER")
	LunaPlayerFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	LunaPlayerFrame:RegisterEvent("UNIT_MODEL_CHANGED")
	LunaPlayerFrame:RegisterEvent("UNIT_LEVEL")
	LunaPlayerFrame:RegisterEvent("RAID_TARGET_UPDATE")
	LunaPlayerFrame:RegisterEvent("PARTY_LEADER_CHANGED")
	LunaPlayerFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	LunaPlayerFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	LunaPlayerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	LunaPlayerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	LunaPlayerFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
	LunaPlayerFrame:RegisterEvent("UNIT_SPELLMISS")
	LunaPlayerFrame:RegisterEvent("UNIT_COMBAT")
	LunaPlayerFrame:RegisterEvent("PLAYER_ALIVE")
	
	if LunaOptions.hideCastbar == 0 then
		LunaPlayerFrame:RegisterEvent("SPELLCAST_CHANNEL_START")
		LunaPlayerFrame:RegisterEvent("SPELLCAST_CHANNEL_STOP")
		LunaPlayerFrame:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
		LunaPlayerFrame:RegisterEvent("SPELLCAST_DELAYED")
		LunaPlayerFrame:RegisterEvent("SPELLCAST_FAILED")
		LunaPlayerFrame:RegisterEvent("SPELLCAST_INTERRUPTED")
		LunaPlayerFrame:RegisterEvent("SPELLCAST_START")
		LunaPlayerFrame:RegisterEvent("SPELLCAST_STOP")
	end
	LunaPlayerFrame:SetScript("OnClick", Luna_Player_OnClick)
	LunaPlayerFrame:SetScript("OnEvent", Luna_Player_OnEvent)
	LunaPlayerFrame.Castbar:SetScript("OnUpdate", Luna_Player_OnUpdate)
	if LunaOptions.EnergyTicker == 1 then
		LunaPlayerFrame.PowerBar:SetScript("OnUpdate", LunaPlayerFrame.PowerBar.EnergyUpdate)
	end
	if LunaOptions.hideBlizzCastbar == 1 then
		Luna_HideBlizz(CastingBarFrame)
	end
	
	LunaPlayerFrame:SetScript("OnUpdate", CombatFeedback_OnUpdate)
	
	UIDropDownMenu_Initialize(dropdown, Luna_PlayerDropDown_Initialize, "MENU")
	
	LunaPlayerFrame.AdjustBars = function()
		local frameHeight = LunaPlayerFrame:GetHeight()
		local frameWidth = (LunaPlayerFrame:GetWidth()-frameHeight)
		LunaPlayerFrame.portrait:SetHeight(frameHeight+1)
		LunaPlayerFrame.portrait:SetWidth(frameHeight) --square it
		LunaPlayerFrame.HealthBar:SetWidth(frameWidth)
		LunaPlayerFrame.PowerBar:SetWidth(frameWidth)
		LunaPlayerFrame.Castbar:SetWidth(frameWidth)
		LunaPlayerFrame.HealthBar:SetHeight(frameHeight*0.58)
		LunaPlayerFrame.PowerBar:SetHeight(frameHeight-(frameHeight*0.58)-1)
		LunaPlayerFrame.PowerBar.Ticker:SetHeight(LunaPlayerFrame.PowerBar:GetHeight())
		LunaPlayerFrame.Castbar:SetHeight(frameHeight*0.25)
	end
	LunaPlayerFrame.AdjustBars()
	LunaUnitFrames:UpdatePlayerBuffLayout()
	LunaUnitFrames:UpdatePlayerFrame()
end

function LunaUnitFrames:UpdatePlayerBuffLayout()
	if LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 1 then
		LunaPlayerFrame:UnregisterEvent("UNIT_AURA")
		for i=1, 16 do
			LunaPlayerFrame.Buffs[i]:Hide()
			LunaPlayerFrame.Debuffs[i]:Hide()
		end
	elseif LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 2 then
		LunaPlayerFrame:RegisterEvent("UNIT_AURA")
		LunaPlayerFrame.Buffs[1]:ClearAllPoints()
		LunaPlayerFrame.Buffs[1]:SetPoint("BOTTOMLEFT", LunaPlayerFrame, "TOPLEFT", -1, 3)
		LunaPlayerFrame.Debuffs[1]:ClearAllPoints()
		LunaPlayerFrame.Debuffs[1]:SetPoint("BOTTOMLEFT", LunaPlayerFrame.Buffs[1], "TOPLEFT", 0, 3)
		for i=2, 16 do
			LunaPlayerFrame.Buffs[i]:ClearAllPoints()
			LunaPlayerFrame.Buffs[i]:SetPoint("TOPLEFT", LunaPlayerFrame.Buffs[i-1], "TOPRIGHT",1, 0)
			LunaPlayerFrame.Debuffs[i]:ClearAllPoints()
			LunaPlayerFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaPlayerFrame.Debuffs[i-1], "TOPRIGHT",1, 0)
		end
		LunaUnitFrames:UpdatePlayerBuffSize()
		Luna_Player_Events:UNIT_AURA()
	elseif LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 3 then
		LunaPlayerFrame:RegisterEvent("UNIT_AURA")
		LunaPlayerFrame.Buffs[1]:ClearAllPoints()
		if LunaUnitFrames.frames.ExperienceBar and LunaUnitFrames.frames.ExperienceBar:IsShown() then
			LunaPlayerFrame.Buffs[1]:SetPoint("TOPLEFT", LunaPlayerFrame, "BOTTOMLEFT", -1, -15)
		else
			LunaPlayerFrame.Buffs[1]:SetPoint("TOPLEFT", LunaPlayerFrame, "BOTTOMLEFT", -1, -3)
		end
		LunaPlayerFrame.Debuffs[1]:ClearAllPoints()
		LunaPlayerFrame.Debuffs[1]:SetPoint("TOPLEFT", LunaPlayerFrame.Buffs[1], "BOTTOMLEFT", 0, -3)
		for i=2, 16 do
			LunaPlayerFrame.Buffs[i]:ClearAllPoints()
			LunaPlayerFrame.Buffs[i]:SetPoint("TOPLEFT", LunaPlayerFrame.Buffs[i-1], "TOPRIGHT", 1, 0)
			LunaPlayerFrame.Debuffs[i]:ClearAllPoints()
			LunaPlayerFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaPlayerFrame.Debuffs[i-1], "TOPRIGHT", 1, 0)
		end
		LunaUnitFrames:UpdatePlayerBuffSize()
		Luna_Player_Events:UNIT_AURA()
	elseif LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 4 then
		LunaPlayerFrame:RegisterEvent("UNIT_AURA")
		LunaPlayerFrame.Buffs[1]:ClearAllPoints()
		LunaPlayerFrame.Buffs[1]:SetPoint("TOPRIGHT", LunaPlayerFrame, "TOPLEFT", -3, 1)
		LunaPlayerFrame.Debuffs[1]:ClearAllPoints()
		LunaPlayerFrame.Debuffs[1]:SetPoint("TOPLEFT", LunaPlayerFrame.Buffs[9], "BOTTOMLEFT", 0, -1)
		LunaPlayerFrame.Buffs[9]:ClearAllPoints()
		LunaPlayerFrame.Buffs[9]:SetPoint("TOPLEFT", LunaPlayerFrame.Buffs[1], "BOTTOMLEFT", 0, -1)
		LunaPlayerFrame.Debuffs[9]:ClearAllPoints()
		LunaPlayerFrame.Debuffs[9]:SetPoint("TOPLEFT", LunaPlayerFrame.Debuffs[1], "BOTTOMLEFT", 0, -1)
		for i=2, 8 do
			LunaPlayerFrame.Buffs[i]:ClearAllPoints()
			LunaPlayerFrame.Buffs[i]:SetPoint("TOPRIGHT", LunaPlayerFrame.Buffs[i-1], "TOPLEFT",1, 0)
			LunaPlayerFrame.Debuffs[i]:ClearAllPoints()
			LunaPlayerFrame.Debuffs[i]:SetPoint("TOPRIGHT", LunaPlayerFrame.Debuffs[i-1], "TOPLEFT",1, 0)
		end
		for i=10, 16 do
			LunaPlayerFrame.Buffs[i]:ClearAllPoints()
			LunaPlayerFrame.Buffs[i]:SetPoint("TOPRIGHT", LunaPlayerFrame.Buffs[i-1], "TOPLEFT",1, 0)
			LunaPlayerFrame.Debuffs[i]:ClearAllPoints()
			LunaPlayerFrame.Debuffs[i]:SetPoint("TOPRIGHT", LunaPlayerFrame.Debuffs[i-1], "TOPLEFT",1, 0)
		end
		LunaUnitFrames:UpdatePlayerBuffSize()
		Luna_Player_Events:UNIT_AURA()
	else
		LunaPlayerFrame:RegisterEvent("UNIT_AURA")
		LunaPlayerFrame.Buffs[1]:ClearAllPoints()
		LunaPlayerFrame.Buffs[1]:SetPoint("TOPLEFT", LunaPlayerFrame, "TOPRIGHT", 3, 1)
		LunaPlayerFrame.Debuffs[1]:ClearAllPoints()
		LunaPlayerFrame.Debuffs[1]:SetPoint("TOPLEFT", LunaPlayerFrame.Buffs[9], "BOTTOMLEFT", 0, -1)
		LunaPlayerFrame.Buffs[9]:ClearAllPoints()
		LunaPlayerFrame.Buffs[9]:SetPoint("TOPLEFT", LunaPlayerFrame.Buffs[1], "BOTTOMLEFT", 0, -1)
		LunaPlayerFrame.Debuffs[9]:ClearAllPoints()
		LunaPlayerFrame.Debuffs[9]:SetPoint("TOPLEFT", LunaPlayerFrame.Debuffs[1], "BOTTOMLEFT", 0, -1)
		for i=2, 8 do
			LunaPlayerFrame.Buffs[i]:ClearAllPoints()
			LunaPlayerFrame.Buffs[i]:SetPoint("TOPLEFT", LunaPlayerFrame.Buffs[i-1], "TOPRIGHT",1, 0)
			LunaPlayerFrame.Debuffs[i]:ClearAllPoints()
			LunaPlayerFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaPlayerFrame.Debuffs[i-1], "TOPRIGHT",1, 0)
		end
		for i=10, 16 do
			LunaPlayerFrame.Buffs[i]:ClearAllPoints()
			LunaPlayerFrame.Buffs[i]:SetPoint("TOPLEFT", LunaPlayerFrame.Buffs[i-1], "TOPRIGHT",1, 0)
			LunaPlayerFrame.Debuffs[i]:ClearAllPoints()
			LunaPlayerFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaPlayerFrame.Debuffs[i-1], "TOPRIGHT",1, 0)
		end
		LunaUnitFrames:UpdatePlayerBuffSize()
		Luna_Player_Events:UNIT_AURA()
	end
end

function LunaUnitFrames:UpdatePlayerBuffSize()
	local size
	if LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 2 or LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 3 then
		size = (LunaPlayerFrame:GetWidth()-15)/16
	else
		size = (LunaPlayerFrame:GetHeight()-3)/4
	end
	for i=1, 16 do
		LunaPlayerFrame.Buffs[i]:SetHeight(size)
		LunaPlayerFrame.Buffs[i]:SetWidth(size)
		LunaPlayerFrame.Buffs[i].stacks:SetFont(LunaOptions.font, size*0.75)
		LunaPlayerFrame.Debuffs[i]:SetHeight(size)
		LunaPlayerFrame.Debuffs[i]:SetWidth(size)
		LunaPlayerFrame.Debuffs[i].stacks:SetFont(LunaOptions.font, size*0.75)
	end	
end

function LunaUnitFrames:UpdatePlayerFrame()
	Luna_HideBlizz(PlayerFrame)
	if LunaOptions.frames["LunaPlayerFrame"].enabled == 0 then
		LunaPlayerFrame:Hide()
		return
	else
		LunaPlayerFrame:Show()
	end
	local class = UnitClass("player")
	local maxHealth = UnitHealthMax("player")
	local health = UnitHealth("player")
	local maxMana = UnitManaMax("player")
	local mana = UnitMana("player")
	
	local rankNumber = UnitPVPRank("player");
	if (rankNumber == 0) then
		LunaPlayerFrame.PVPRank:Hide();
	elseif (rankNumber < 14) then
		rankNumber = rankNumber - 4;
		LunaPlayerFrame.PVPRank:SetTexture("Interface\\PvPRankBadges\\PvPRank0"..rankNumber);
		LunaPlayerFrame.PVPRank:Show();
	else
		rankNumber = rankNumber - 4;
		LunaPlayerFrame.PVPRank:SetTexture("Interface\\PvPRankBadges\\PvPRank"..rankNumber);
		LunaPlayerFrame.PVPRank:Show();
	end
	
	LunaPlayerFrame.HealthBar:SetMinMaxValues(0, maxHealth)
	LunaPlayerFrame.HealthBar:SetValue(health)
	LunaPlayerFrame.HealthBar.hpp:SetText(health.."/"..maxHealth)
	local color = LunaOptions.ClassColors[class]
	LunaPlayerFrame.HealthBar:SetStatusBarColor(color[1],color[2],color[3])
	LunaPlayerFrame.HealthBar.hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)

	LunaPlayerFrame.PowerBar:SetMinMaxValues(0, maxMana)
	LunaPlayerFrame.PowerBar:SetValue(mana)
	LunaPlayerFrame.PowerBar.ppp:SetText(mana.."/"..maxMana)
	
	Luna_Player_Events.PARTY_LEADER_CHANGED()
	Luna_Player_Events.RAID_TARGET_UPDATE()
	Luna_Player_Events.UNIT_DISPLAYPOWER()
	Luna_Player_Events.UNIT_PORTRAIT_UPDATE()
	Luna_Player_Events.UNIT_LEVEL()
	Luna_Player_Events.PARTY_LOOT_METHOD_CHANGED()
	Luna_Player_Events.PLAYER_UPDATE_RESTING()
end

function Luna_Player_Events:SPELLCAST_CHANNEL_START()
	LunaPlayerFrame.Castbar.maxValue = 1
	LunaPlayerFrame.Castbar.startTime = GetTime()
	LunaPlayerFrame.Castbar.endTime = LunaPlayerFrame.Castbar.startTime + (arg1 / 1000)
	LunaPlayerFrame.Castbar.duration = arg1 / 1000
	LunaPlayerFrame.Castbar:SetMinMaxValues(LunaPlayerFrame.Castbar.startTime, LunaPlayerFrame.Castbar.endTime)
	LunaPlayerFrame.Castbar:SetValue(LunaPlayerFrame.Castbar.endTime)
	LunaPlayerFrame.Castbar.holdTime = 0
	LunaPlayerFrame.Castbar.casting = nil
	LunaPlayerFrame.Castbar.channeling = 1
	LunaPlayerFrame.Castbar.delaySum = 0	
	LunaPlayerFrame.Castbar.Text:SetText("Channeling")
	AdjustForCastbar(1)
end

function Luna_Player_Events:SPELLCAST_CHANNEL_UPDATE()
	if (arg1 == 0) then
		LunaPlayerFrame.Castbar.channeling = nil
		LunaPlayerFrame.Castbar.delaySum = 0
		AdjustForCastbar(0)
	elseif (LunaPlayerFrame.Castbar:IsShown()) then
		local origDuration = LunaPlayerFrame.Castbar.endTime - LunaPlayerFrame.Castbar.startTime
		local elapsedTime = GetTime() - LunaPlayerFrame.Castbar.startTime;
		local losttime = origDuration*1000 - elapsedTime*1000 - arg1;
		LunaPlayerFrame.Castbar.delaySum = LunaPlayerFrame.Castbar.delaySum + losttime;
		LunaPlayerFrame.Castbar.startTime = LunaPlayerFrame.Castbar.endTime - origDuration;
		LunaPlayerFrame.Castbar.endTime = GetTime() + (arg1 / 1000);
		LunaPlayerFrame.Castbar:SetMinMaxValues(LunaPlayerFrame.Castbar.startTime, LunaPlayerFrame.Castbar.endTime);
	end
end

function Luna_Player_Events:SPELLCAST_DELAYED()
	if (arg1) and LunaPlayerFrame.Castbar.startTime then
		LunaPlayerFrame.Castbar.startTime = LunaPlayerFrame.Castbar.startTime + (arg1 / 1000);
		LunaPlayerFrame.Castbar.maxValue = LunaPlayerFrame.Castbar.maxValue + (arg1 / 1000);
		LunaPlayerFrame.Castbar.delaySum = LunaPlayerFrame.Castbar.delaySum + arg1;
		LunaPlayerFrame.Castbar:SetMinMaxValues(LunaPlayerFrame.Castbar.startTime, LunaPlayerFrame.Castbar.maxValue);
	end
end

function Luna_Player_Events:SPELLCAST_START()
	LunaPlayerFrame.Castbar.startTime = GetTime()
	LunaPlayerFrame.Castbar.maxValue = LunaPlayerFrame.Castbar.startTime + (arg2 / 1000)
	LunaPlayerFrame.Castbar.holdTime = 0
	LunaPlayerFrame.Castbar.casting = 1
	LunaPlayerFrame.Castbar.delaySum = 0	
	LunaPlayerFrame.Castbar.Text:SetText(arg1)
	LunaPlayerFrame.Castbar:SetMinMaxValues(LunaPlayerFrame.Castbar.startTime, LunaPlayerFrame.Castbar.maxValue)
	LunaPlayerFrame.Castbar:SetValue(LunaPlayerFrame.Castbar.startTime)
	AdjustForCastbar(1)
end

function Luna_Player_Events:SPELLCAST_STOP()
	if LunaPlayerFrame.Castbar.casting == 1 or event == "SPELLCAST_CHANNEL_STOP" then
		AdjustForCastbar(0)
	end
end
Luna_Player_Events.SPELLCAST_INTERRUPTED = Luna_Player_Events.SPELLCAST_STOP
Luna_Player_Events.SPELLCAST_FAILED = Luna_Player_Events.SPELLCAST_STOP
Luna_Player_Events.SPELLCAST_CHANNEL_STOP = Luna_Player_Events.SPELLCAST_STOP

function Luna_Player_Events:PLAYER_ALIVE()
	LunaUnitFrames:UpdatePlayerFrame()
end

function Luna_Player_Events:UNIT_AURA()
	for i=1, 16 do
		local path, stacks = UnitBuff("player",i)
		LunaPlayerFrame.Buffs[i].texturepath = path
		if LunaPlayerFrame.Buffs[i].texturepath then
			LunaPlayerFrame.Buffs[i]:EnableMouse(1)
			LunaPlayerFrame.Buffs[i]:Show()
			if stacks > 1 then
				LunaPlayerFrame.Buffs[i].stacks:SetText(stacks)
				LunaPlayerFrame.Buffs[i].stacks:Show()
			else
				LunaPlayerFrame.Buffs[i].stacks:Hide()
			end
		else
			LunaPlayerFrame.Buffs[i]:EnableMouse(0)
			LunaPlayerFrame.Buffs[i]:Hide()
		end
		LunaPlayerFrame.Buffs[i]:SetNormalTexture(LunaPlayerFrame.Buffs[i].texturepath)
	end
	for i=1, 16 do
		local path, stacks = UnitDebuff("player",i)
		LunaPlayerFrame.Debuffs[i].texturepath = path
		if LunaPlayerFrame.Debuffs[i].texturepath then
			LunaPlayerFrame.Debuffs[i]:EnableMouse(1)
			LunaPlayerFrame.Debuffs[i]:Show()
			if stacks > 1 then
				LunaPlayerFrame.Debuffs[i].stacks:SetText(stacks)
				LunaPlayerFrame.Debuffs[i].stacks:Show()
			else
				LunaPlayerFrame.Debuffs[i].stacks:Hide()
			end
		else
			LunaPlayerFrame.Debuffs[i]:EnableMouse(0)
			LunaPlayerFrame.Debuffs[i]:Hide()
		end
		LunaPlayerFrame.Debuffs[i]:SetNormalTexture(LunaPlayerFrame.Debuffs[i].texturepath)
	end
end

function Luna_Player_Events:PLAYER_UPDATE_RESTING()
	if (event == "PLAYER_REGEN_DISABLED") then
		InCombat = 1;
		LunaPlayerFrame.Combat:SetTexCoord(0.5, 1.0, 0.0, 0.48);
		LunaPlayerFrame.Combat:Show();
	elseif (event == "PLAYER_REGEN_ENABLED") then
		InCombat = 0;
		LunaPlayerFrame.Combat:Hide();
	elseif (IsResting()) then
		if (InCombat == 1) then
			return;
		else
			LunaPlayerFrame.Combat:SetTexCoord(0, 0.5, 0.0, 0.48);
			LunaPlayerFrame.Combat:Show();
		end
	else
		if (InCombat == 1) then
			return;
		else
			LunaPlayerFrame.Combat:Hide();
		end
	end
end
Luna_Player_Events.PLAYER_REGEN_DISABLED = Luna_Player_Events.PLAYER_UPDATE_RESTING;
Luna_Player_Events.PLAYER_REGEN_ENABLED = Luna_Player_Events.PLAYER_UPDATE_RESTING;

function Luna_Player_Events:PARTY_LOOT_METHOD_CHANGED()
	local lootmaster;
	_, lootmaster = GetLootMethod()
	if lootmaster == 0 then
		LunaPlayerFrame.Loot:Show()
	else
		LunaPlayerFrame.Loot:Hide()
	end
end

function Luna_Player_Events:PARTY_LEADER_CHANGED()
	if UnitIsPartyLeader("player") then
		LunaPlayerFrame.Leader:Show()
	else
		LunaPlayerFrame.Leader:Hide()
	end
end
Luna_Player_Events.PARTY_MEMBERS_CHANGED = Luna_Player_Events.PARTY_LEADER_CHANGED

function Luna_Player_Events:RAID_TARGET_UPDATE()
	local index = GetRaidTargetIndex("player")
	if (index) then
		SetRaidTargetIconTexture(LunaPlayerFrame.RaidIcon, index)
		LunaPlayerFrame.RaidIcon:Show()
	else
		LunaPlayerFrame.RaidIcon:Hide()
	end
end

function Luna_Player_Events:UNIT_HEALTH()
	LunaPlayerFrame.HealthBar:SetMinMaxValues(0, UnitHealthMax("player"))
	LunaPlayerFrame.HealthBar:SetValue(UnitHealth("player"))
	LunaPlayerFrame.HealthBar.hpp:SetText(UnitHealth("player").."/"..UnitHealthMax("player"))
	if (UnitIsDead("player") or UnitIsGhost("player")) then
		LunaPlayerFrame.HealthBar:SetValue(0)
	end
end
Luna_Player_Events.UNIT_MAXHEALTH = Luna_Player_Events.UNIT_HEALTH;

function Luna_Player_Events:UNIT_MANA()
	if not LunaPlayerFrame.PowerBar.Ticker.startTime or UnitMana("player") > LunaPlayerFrame.PowerBar.oldMana then
		LunaPlayerFrame.PowerBar.Ticker.startTime = GetTime()
	end
	LunaPlayerFrame.PowerBar.oldMana = UnitMana("player")
	LunaPlayerFrame.PowerBar:SetMinMaxValues(0, UnitManaMax("player"))
	LunaPlayerFrame.PowerBar:SetValue(UnitMana("player"))
	LunaPlayerFrame.PowerBar.ppp:SetText(UnitMana("player").."/"..UnitManaMax("player"))
end
Luna_Player_Events.UNIT_MAXMANA = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_ENERGY = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_MAXENERGY = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_RAGE = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_MAXRAGE = Luna_Player_Events.UNIT_MANA;

function Luna_Player_Events:UNIT_DISPLAYPOWER()
	playerpower = UnitPowerType("player")
	
	if playerpower == 1 then
		LunaPlayerFrame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
		LunaPlayerFrame.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
		LunaPlayerFrame.PowerBar.Ticker:Hide()
	elseif playerpower == 3 then
		LunaPlayerFrame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
		LunaPlayerFrame.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
		if LunaOptions.EnergyTicker == 1 then
			LunaPlayerFrame.PowerBar.Ticker:Show()
		else
			LunaPlayerFrame.PowerBar.Ticker:Hide()
		end
	else
		LunaPlayerFrame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		LunaPlayerFrame.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
		LunaPlayerFrame.PowerBar.Ticker:Hide()
	end
	Luna_Player_Events.UNIT_MANA()
end

function Luna_Player_Events:UNIT_PORTRAIT_UPDATE()
	local portrait = LunaPlayerFrame.portrait
	if(portrait.type == "3D") then
		if(not UnitExists("player") or not UnitIsConnected("player") or not UnitIsVisible("player")) then
			portrait:SetModelScale(4.25)
			portrait:SetPosition(0, 0, -1)
			portrait:SetModel"Interface\\Buttons\\talktomequestionmark.mdx"
		else
			portrait:SetUnit("player")
			portrait:SetCamera(0)
			portrait:Show()
		end
	else
		SetPortraitTexture(portrait, "player")
	end
end
Luna_Player_Events.UNIT_MODEL_CHANGED = Luna_Player_Events.UNIT_PORTRAIT_UPDATE

function Luna_Player_Events:UNIT_LEVEL()
	LunaPlayerFrame.Lvl:SetText(UnitLevel("player"))
end

function Luna_Player_Events:UNIT_COMBAT()
	if arg1 == "player" then
		CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5)
	end
end

function Luna_Player_Events:UNIT_SPELLMISS()
	if arg1 == "player" then
		CombatFeedback_OnSpellMissEvent(arg2)
	end
end