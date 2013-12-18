local Luna_Pet_Events = {}

local function Luna_HideBlizz(frame)
	frame:UnregisterAllEvents()
	frame:Hide()
end	
	
local function Luna_Pet_Tip()
	UnitFrame_OnEnter()
end
	
local function Luna_Party_SetBuffTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	if (this.id > 16) then
		GameTooltip:SetUnitDebuff(this:GetParent().unit, this.id-16)
	else
		GameTooltip:SetUnitBuff(this:GetParent().unit, this.id)
	end
end

local function Luna_Party_SetBuffTooltipLeave()
	GameTooltip:Hide()
end

local dropdown = CreateFrame("Frame", "LunaPetDropDownMenu", UIParent, "UIDropDownMenuTemplate")
function Luna_PlayerDropDown_Initialize()
	UnitPopup_ShowMenu(dropdown, "PET" , "pet")
end

local function Luna_Pet_OnClick()
	local button = arg1
	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit("pet");
		elseif (CursorHasItem()) then
			DropItemOnUnit("pet");
		else
			TargetUnit("pet");
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
		ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0);
	end
end

local function Luna_Pet_OnEvent()
	local func = Luna_Pet_Events[event]
	if (func) then
		func()
	else
		DEFAULT_CHAT_FRAME:AddMessage("Luna Unit Frames - Pet: Report the following event error to the author: "..event)
	end
end

local function StartMoving()
	LunaPetFrame:StartMoving()
end

local function StopMovingOrSizing()
	LunaPetFrame:StopMovingOrSizing()
	_,_,_,LunaOptions.frames["LunaPetFrame"].position.x, LunaOptions.frames["LunaPetFrame"].position.y = LunaPetFrame:GetPoint()
end

function LunaUnitFrames:TogglePetLock()
	if LunaPetFrame:IsMovable() then
		LunaPetFrame:SetScript("OnDragStart", nil)
		LunaPetFrame:SetMovable(0)
	else
		LunaPetFrame:SetScript("OnDragStart", StartMoving)
		LunaPetFrame:SetMovable(1)
	end
end

function LunaUnitFrames:CreatePetFrame()	
	LunaPetFrame = CreateFrame("Button", "LunaPetFrame", UIParent)

	LunaPetFrame:SetHeight(LunaOptions.frames["LunaPetFrame"].size.y)
	LunaPetFrame:SetWidth(LunaOptions.frames["LunaPetFrame"].size.x)
	LunaPetFrame:SetScale(LunaOptions.frames["LunaPetFrame"].scale)
	LunaPetFrame:SetBackdrop(LunaOptions.backdrop)
	LunaPetFrame:SetBackdropColor(0,0,0,1)
	LunaPetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaPetFrame"].position.x, LunaOptions.frames["LunaPetFrame"].position.y)
	LunaPetFrame:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
	LunaPetFrame.unit = "pet"
	LunaPetFrame:SetScript("OnEnter", Luna_Pet_Tip)
	LunaPetFrame:SetScript("OnLeave", UnitFrame_OnLeave)
	LunaPetFrame:SetMovable(0)
	LunaPetFrame:RegisterForDrag("LeftButton")
	LunaPetFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaPetFrame:SetClampedToScreen(1)

	LunaPetFrame.Buffs = {}

	LunaPetFrame.Buffs[1] = CreateFrame("Button", nil, LunaPetFrame)
	LunaPetFrame.Buffs[1].texturepath = UnitBuff(LunaPetFrame.unit,1)
	LunaPetFrame.Buffs[1].id = 1
	LunaPetFrame.Buffs[1]:SetNormalTexture(LunaPetFrame.Buffs[1].texturepath)
	LunaPetFrame.Buffs[1]:SetScript("OnEnter", Luna_Party_SetBuffTooltip)
	LunaPetFrame.Buffs[1]:SetScript("OnLeave", Luna_Party_SetBuffTooltipLeave)

	LunaPetFrame.Buffs[1].stacks = LunaPetFrame.Buffs[1]:CreateFontString(nil, "OVERLAY", LunaPetFrame.Buffs[1])
	LunaPetFrame.Buffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaPetFrame.Buffs[1], 0, 0)
	LunaPetFrame.Buffs[1].stacks:SetJustifyH("LEFT")
	LunaPetFrame.Buffs[1].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.Buffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaPetFrame.Buffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.Buffs[1].stacks:SetTextColor(1,1,1)
	LunaPetFrame.Buffs[1].stacks:SetText("8")

	for z=2, 16 do
		LunaPetFrame.Buffs[z] = CreateFrame("Button", nil, LunaPetFrame)
		LunaPetFrame.Buffs[z].texturepath = UnitBuff(LunaPetFrame.unit,z)
		LunaPetFrame.Buffs[z].id = z
		LunaPetFrame.Buffs[z]:SetNormalTexture(LunaPetFrame.Buffs[z].texturepath)
		LunaPetFrame.Buffs[z]:SetScript("OnEnter", Luna_Party_SetBuffTooltip)
		LunaPetFrame.Buffs[z]:SetScript("OnLeave", Luna_Party_SetBuffTooltipLeave)
		
		LunaPetFrame.Buffs[z].stacks = LunaPetFrame.Buffs[z]:CreateFontString(nil, "OVERLAY", LunaPetFrame.Buffs[z])
		LunaPetFrame.Buffs[z].stacks:SetPoint("BOTTOMRIGHT", LunaPetFrame.Buffs[z], 0, 0)
		LunaPetFrame.Buffs[z].stacks:SetJustifyH("LEFT")
		LunaPetFrame.Buffs[z].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPetFrame.Buffs[z].stacks:SetShadowColor(0, 0, 0)
		LunaPetFrame.Buffs[z].stacks:SetShadowOffset(0.8, -0.8)
		LunaPetFrame.Buffs[z].stacks:SetTextColor(1,1,1)
		LunaPetFrame.Buffs[z].stacks:SetText("8")
	end

	LunaPetFrame.Debuffs = {}

	LunaPetFrame.Debuffs[1] = CreateFrame("Button", nil, LunaPetFrame)
	LunaPetFrame.Debuffs[1].texturepath = UnitDebuff(LunaPetFrame.unit,1)
	LunaPetFrame.Debuffs[1].id = 17
	LunaPetFrame.Debuffs[1]:SetNormalTexture(LunaPetFrame.Debuffs[1].texturepath)
	LunaPetFrame.Debuffs[1]:SetScript("OnEnter", Luna_Party_SetBuffTooltip)
	LunaPetFrame.Debuffs[1]:SetScript("OnLeave", Luna_Party_SetBuffTooltipLeave)

	LunaPetFrame.Debuffs[1].stacks = LunaPetFrame.Debuffs[1]:CreateFontString(nil, "OVERLAY", LunaPetFrame.Debuffs[1])
	LunaPetFrame.Debuffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaPetFrame.Debuffs[1], 0, 0)
	LunaPetFrame.Debuffs[1].stacks:SetJustifyH("LEFT")
	LunaPetFrame.Debuffs[1].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.Debuffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaPetFrame.Debuffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.Debuffs[1].stacks:SetTextColor(1,1,1)
	LunaPetFrame.Debuffs[1].stacks:SetText("8")

	for z=2, 16 do
		LunaPetFrame.Debuffs[z] = CreateFrame("Button", nil, LunaPetFrame)
		LunaPetFrame.Debuffs[z].texturepath = UnitDebuff(LunaPetFrame.unit,z)
		LunaPetFrame.Debuffs[z].id = z+16
		LunaPetFrame.Debuffs[z]:SetNormalTexture(LunaPetFrame.Debuffs[z].texturepath)
		LunaPetFrame.Debuffs[z]:SetScript("OnEnter", Luna_Party_SetBuffTooltip)
		LunaPetFrame.Debuffs[z]:SetScript("OnLeave", Luna_Party_SetBuffTooltipLeave)
		
		LunaPetFrame.Debuffs[z].stacks = LunaPetFrame.Debuffs[z]:CreateFontString(nil, "OVERLAY", LunaPetFrame.Debuffs[z])
		LunaPetFrame.Debuffs[z].stacks:SetPoint("BOTTOMRIGHT", LunaPetFrame.Debuffs[z], 0, 0)
		LunaPetFrame.Debuffs[z].stacks:SetJustifyH("LEFT")
		LunaPetFrame.Debuffs[z].stacks:SetFont(LunaOptions.font, LunaOptions.fontHeight)
		LunaPetFrame.Debuffs[z].stacks:SetShadowColor(0, 0, 0)
		LunaPetFrame.Debuffs[z].stacks:SetShadowOffset(0.8, -0.8)
		LunaPetFrame.Debuffs[z].stacks:SetTextColor(1,1,1)
		LunaPetFrame.Debuffs[z].stacks:SetText("8")
	end

	LunaPetFrame.portrait = CreateFrame("PlayerModel", nil, LunaPetFrame)
	LunaPetFrame.portrait:SetScript("OnShow",function() this:SetCamera(0) end)
	LunaPetFrame.portrait.type = "3D"
	LunaPetFrame.portrait:SetPoint("TOPLEFT", LunaPetFrame, "TOPLEFT")
	LunaPetFrame.portrait.side = "left"

	-- Healthbar
	LunaPetFrame.HealthBar = CreateFrame("StatusBar", nil, LunaPetFrame)
	LunaPetFrame.HealthBar:SetHeight(16)
	LunaPetFrame.HealthBar:SetWidth(210)
	LunaPetFrame.HealthBar:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaPetFrame.HealthBar:SetPoint("TOPLEFT", LunaPetFrame.portrait, "TOPRIGHT", 1, 0)


	-- Healthbar background
	LunaPetFrame.HealthBar.hpbg = LunaPetFrame.HealthBar:CreateTexture(nil, "BORDER")
	LunaPetFrame.HealthBar.hpbg:SetAllPoints(LunaPetFrame.HealthBar)
	LunaPetFrame.HealthBar.hpbg:SetTexture(.25,.25,.25)

	-- Healthbar text
	LunaPetFrame.HealthBar.hpp = LunaPetFrame.HealthBar:CreateFontString(nil, "OVERLAY", LunaPetFrame.HealthBar)
	LunaPetFrame.HealthBar.hpp:SetPoint("RIGHT", -2, -1)
	LunaPetFrame.HealthBar.hpp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.HealthBar.hpp:SetShadowColor(0, 0, 0)
	LunaPetFrame.HealthBar.hpp:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.HealthBar.hpp:SetTextColor(1,1,1)

	LunaPetFrame.name = LunaPetFrame.HealthBar:CreateFontString(nil, "OVERLAY", LunaPetFrame.HealthBar)
	LunaPetFrame.name:SetPoint("LEFT", 2, -1)
	LunaPetFrame.name:SetJustifyH("LEFT")
	LunaPetFrame.name:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.name:SetShadowColor(0, 0, 0)
	LunaPetFrame.name:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.name:SetTextColor(1,1,1)
	LunaPetFrame.name:SetText(UnitName("pet"))

	-- Manabar
	LunaPetFrame.PowerBar = CreateFrame("StatusBar", nil, LunaPetFrame)
	LunaPetFrame.PowerBar:SetHeight(12)
	LunaPetFrame.PowerBar:SetWidth(210)
	LunaPetFrame.PowerBar:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaPetFrame.PowerBar:SetPoint("TOPLEFT", LunaPetFrame.HealthBar, "BOTTOMLEFT", 0, -1)

	-- Manabar background
	LunaPetFrame.PowerBar.ppbg = LunaPetFrame.PowerBar:CreateTexture(nil, "BORDER")
	LunaPetFrame.PowerBar.ppbg:SetAllPoints(LunaPetFrame.PowerBar)
	LunaPetFrame.PowerBar.ppbg:SetTexture(.25,.25,.25)

	LunaPetFrame.PowerBar.ppp = LunaPetFrame.PowerBar:CreateFontString(nil, "OVERLAY", LunaPetFrame.PowerBar)
	LunaPetFrame.PowerBar.ppp:SetPoint("RIGHT", -2, -1)
	LunaPetFrame.PowerBar.ppp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.PowerBar.ppp:SetShadowColor(0, 0, 0)
	LunaPetFrame.PowerBar.ppp:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.PowerBar.ppp:SetTextColor(1,1,1)

	LunaPetFrame.lvl = LunaPetFrame.PowerBar:CreateFontString(nil, "OVERLAY")
	LunaPetFrame.lvl:SetPoint("LEFT", LunaPetFrame.PowerBar, "LEFT", 2, -1)
	LunaPetFrame.lvl:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.lvl:SetShadowColor(0, 0, 0)
	LunaPetFrame.lvl:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.lvl:SetText(UnitLevel("pet"))

	LunaPetFrame.class = LunaPetFrame.PowerBar:CreateFontString(nil, "OVERLAY")
	LunaPetFrame.class:SetPoint("LEFT", LunaPetFrame.lvl, "RIGHT",  1, 0)
	LunaPetFrame.class:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPetFrame.class:SetShadowColor(0, 0, 0)
	LunaPetFrame.class:SetShadowOffset(0.8, -0.8)
	LunaPetFrame.class:SetText(UnitClass("pet"))

	LunaPetFrame:RegisterEvent("UNIT_HEALTH")
	LunaPetFrame:RegisterEvent("UNIT_MAXHEALTH")
	LunaPetFrame:RegisterEvent("UNIT_MANA")
	LunaPetFrame:RegisterEvent("UNIT_MAXMANA")
	LunaPetFrame:RegisterEvent("UNIT_RAGE")
	LunaPetFrame:RegisterEvent("UNIT_MAXRAGE")
	LunaPetFrame:RegisterEvent("UNIT_ENERGY")
	LunaPetFrame:RegisterEvent("UNIT_MAXENERGY")
	LunaPetFrame:RegisterEvent("UNIT_FOCUS")
	LunaPetFrame:RegisterEvent("UNIT_MAXFOCUS")
	LunaPetFrame:RegisterEvent("UNIT_HAPPINESS")
	LunaPetFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	LunaPetFrame:RegisterEvent("UNIT_MODEL_CHANGED")
	LunaPetFrame:RegisterEvent("UNIT_PET")
	LunaPetFrame:RegisterEvent("UNIT_LEVEL")
	LunaPetFrame:RegisterEvent("UNIT_NAME_UPDATE")
	LunaPetFrame:SetScript("OnClick", Luna_Pet_OnClick)
	LunaPetFrame:SetScript("OnEvent", Luna_Pet_OnEvent)
	UIDropDownMenu_Initialize(dropdown, Luna_PlayerDropDown_Initialize, "MENU")
	LunaUnitFrames:UpdatePetFrame()
	
	LunaPetFrame.AdjustBars = function()
		local frameHeight = LunaPetFrame:GetHeight()
		local frameWidth = (LunaPetFrame:GetWidth()-frameHeight)
		LunaPetFrame.portrait:SetHeight(frameHeight+1)
		LunaPetFrame.portrait:SetWidth(frameHeight) --square it
		LunaPetFrame.HealthBar:SetWidth(frameWidth-1)
		LunaPetFrame.PowerBar:SetWidth(frameWidth-1)
		LunaPetFrame.HealthBar:SetHeight(frameHeight*0.58)
		LunaPetFrame.PowerBar:SetHeight(frameHeight-(frameHeight*0.58)-1)
	end
	LunaPetFrame.AdjustBars()
	LunaUnitFrames:UpdatePetBuffLayout()
end

function LunaUnitFrames:UpdatePetFrame()
	if not UnitExists("pet") or LunaOptions.frames["LunaPetFrame"].enabled == 0 then
		LunaPetFrame:Hide()
		return
	else
		LunaPetFrame:Show()
	end
	if(LunaPetFrame.portrait.type == "3D") then
		if(not UnitExists(LunaPetFrame.unit) or not UnitIsConnected(LunaPetFrame.unit) or not UnitIsVisible(LunaPetFrame.unit)) then
			LunaPetFrame.portrait:SetModelScale(4.25)
			LunaPetFrame.portrait:SetPosition(0, 0, -1)
			LunaPetFrame.portrait:SetModel"Interface\\Buttons\\talktomequestionmark.mdx"
		else
			LunaPetFrame.portrait:SetUnit(LunaPetFrame.unit)
			LunaPetFrame.portrait:SetCamera(0)
			LunaPetFrame.portrait:Show()
		end
	else
		SetPortraitTexture(LunaPetFrame.portrait, LunaPetFrame.unit)
	end
	Luna_Pet_Events.UNIT_HAPPINESS()

	petpower = UnitPowerType("pet")
	if UnitManaMax("pet") == 0 then
		LunaPetFrame.PowerBar:SetStatusBarColor(0, 0, 0, .25)
		LunaPetFrame.PowerBar.ppbg:SetVertexColor(0, 0, 0, .25)
	elseif petpower == 1 then
		LunaPetFrame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
		LunaPetFrame.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
	elseif petpower == 2 then
		LunaPetFrame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3])
		LunaPetFrame.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3], 0.25)
	elseif petpower == 3 then
		LunaPetFrame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
		LunaPetFrame.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
	elseif not UnitIsDeadOrGhost("pet") then
		LunaPetFrame.PowerBar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		LunaPetFrame.PowerBar.ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
	else
		LunaPetFrame.PowerBar:SetStatusBarColor(0, 0, 0, .25)
		LunaPetFrame.PowerBar.ppbg:SetVertexColor(0, 0, 0, .25)
	end
	
	for z=1, 16 do
		local path, stacks = UnitBuff(LunaPetFrame.unit,z)
		LunaPetFrame.Buffs[z].texturepath = path
		if LunaPetFrame.Buffs[z].texturepath then
			LunaPetFrame.Buffs[z]:EnableMouse(1)
			LunaPetFrame.Buffs[z]:Show()
			if stacks > 1 then
				LunaPetFrame.Buffs[z].stacks:SetText(stacks)
				LunaPetFrame.Buffs[z].stacks:Show()
			else
				LunaPetFrame.Buffs[z].stacks:Hide()
			end
		else
			LunaPetFrame.Buffs[z]:EnableMouse(0)
			LunaPetFrame.Buffs[z]:Hide()
		end
		LunaPetFrame.Buffs[z]:SetNormalTexture(LunaPetFrame.Buffs[z].texturepath)
	end

	for z=1, 16 do
		local path, stacks = UnitDebuff(LunaPetFrame.unit,z)
		LunaPetFrame.Debuffs[z].texturepath = path
		if LunaPetFrame.Debuffs[z].texturepath then
			LunaPetFrame.Debuffs[z]:EnableMouse(1)
			LunaPetFrame.Debuffs[z]:Show()
			if stacks > 1 then
				LunaPetFrame.Debuffs[z].stacks:SetText(stacks)
				LunaPetFrame.Debuffs[z].stacks:Show()
			else
				LunaPetFrame.Debuffs[z].stacks:Hide()
			end
		else
			LunaPetFrame.Debuffs[z]:EnableMouse(0)
			LunaPetFrame.Debuffs[z]:Hide()
		end
		LunaPetFrame.Debuffs[z]:SetNormalTexture(LunaPetFrame.Debuffs[z].texturepath)
	end
	
	LunaPetFrame.name:SetText(UnitName(LunaPetFrame.unit))
	LunaPetFrame.class:SetText(UnitCreatureFamily(LunaPetFrame.unit))
	LunaPetFrame.lvl:SetText(UnitLevel(LunaPetFrame.unit))
	Luna_Pet_Events.UNIT_HEALTH()
	Luna_Pet_Events.UNIT_MANA()
end

function LunaUnitFrames:UpdatePetBuffLayout()
	if LunaOptions.frames["LunaPetFrame"].ShowBuffs == 1 then
		LunaPetFrame:UnregisterEvent("UNIT_AURA")
		for i=1, 16 do
			LunaPetFrame.Buffs[i]:Hide()
			LunaPetFrame.Debuffs[i]:Hide()
		end
	elseif LunaOptions.frames["LunaPetFrame"].ShowBuffs == 2 then
		LunaPetFrame:RegisterEvent("UNIT_AURA")
		LunaPetFrame.Buffs[1]:ClearAllPoints()
		LunaPetFrame.Buffs[1]:SetPoint("BOTTOMLEFT", LunaPetFrame, "TOPLEFT", -1, 3)
		LunaPetFrame.Debuffs[1]:ClearAllPoints()
		LunaPetFrame.Debuffs[1]:SetPoint("BOTTOMLEFT", LunaPetFrame.Buffs[1], "TOPLEFT", 0, 3)
		for i=2, 16 do
			LunaPetFrame.Buffs[i]:ClearAllPoints()
			LunaPetFrame.Buffs[i]:SetPoint("TOPLEFT", LunaPetFrame.Buffs[i-1], "TOPRIGHT",1, 0)
			LunaPetFrame.Debuffs[i]:ClearAllPoints()
			LunaPetFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaPetFrame.Debuffs[i-1], "TOPRIGHT",1, 0)
		end
		LunaUnitFrames:UpdatePetBuffSize()
		Luna_Pet_Events:UNIT_AURA()
	elseif LunaOptions.frames["LunaPetFrame"].ShowBuffs == 3 then
		LunaPetFrame:RegisterEvent("UNIT_AURA")
		LunaPetFrame.Buffs[1]:ClearAllPoints()
		LunaPetFrame.Buffs[1]:SetPoint("TOPLEFT", LunaPetFrame, "BOTTOMLEFT", -1, -3)
		LunaPetFrame.Debuffs[1]:ClearAllPoints()
		LunaPetFrame.Debuffs[1]:SetPoint("TOPLEFT", LunaPetFrame.Buffs[1], "BOTTOMLEFT", 0, -3)
		for i=2, 16 do
			LunaPetFrame.Buffs[i]:ClearAllPoints()
			LunaPetFrame.Buffs[i]:SetPoint("TOPLEFT", LunaPetFrame.Buffs[i-1], "TOPRIGHT", 1, 0)
			LunaPetFrame.Debuffs[i]:ClearAllPoints()
			LunaPetFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaPetFrame.Debuffs[i-1], "TOPRIGHT", 1, 0)
		end
		LunaUnitFrames:UpdatePetBuffSize()
		Luna_Pet_Events:UNIT_AURA()
	elseif LunaOptions.frames["LunaPetFrame"].ShowBuffs == 4 then
		LunaPetFrame:RegisterEvent("UNIT_AURA")
		LunaPetFrame.Buffs[1]:ClearAllPoints()
		LunaPetFrame.Buffs[1]:SetPoint("TOPRIGHT", LunaPetFrame, "TOPLEFT", -3, 1)
		LunaPetFrame.Debuffs[1]:ClearAllPoints()
		LunaPetFrame.Debuffs[1]:SetPoint("TOPLEFT", LunaPetFrame.Buffs[9], "BOTTOMLEFT", 0, -1)
		LunaPetFrame.Buffs[9]:ClearAllPoints()
		LunaPetFrame.Buffs[9]:SetPoint("TOPLEFT", LunaPetFrame.Buffs[1], "BOTTOMLEFT", 0, -1)
		LunaPetFrame.Debuffs[9]:ClearAllPoints()
		LunaPetFrame.Debuffs[9]:SetPoint("TOPLEFT", LunaPetFrame.Debuffs[1], "BOTTOMLEFT", 0, -1)
		for i=2, 8 do
			LunaPetFrame.Buffs[i]:ClearAllPoints()
			LunaPetFrame.Buffs[i]:SetPoint("TOPRIGHT", LunaPetFrame.Buffs[i-1], "TOPLEFT",1, 0)
			LunaPetFrame.Debuffs[i]:ClearAllPoints()
			LunaPetFrame.Debuffs[i]:SetPoint("TOPRIGHT", LunaPetFrame.Debuffs[i-1], "TOPLEFT",1, 0)
		end
		for i=10, 16 do
			LunaPetFrame.Buffs[i]:ClearAllPoints()
			LunaPetFrame.Buffs[i]:SetPoint("TOPRIGHT", LunaPetFrame.Buffs[i-1], "TOPLEFT",1, 0)
			LunaPetFrame.Debuffs[i]:ClearAllPoints()
			LunaPetFrame.Debuffs[i]:SetPoint("TOPRIGHT", LunaPetFrame.Debuffs[i-1], "TOPLEFT",1, 0)
		end
		LunaUnitFrames:UpdatePetBuffSize()
		Luna_Pet_Events:UNIT_AURA()
	else
		LunaPetFrame:RegisterEvent("UNIT_AURA")
		LunaPetFrame.Buffs[1]:ClearAllPoints()
		LunaPetFrame.Buffs[1]:SetPoint("TOPLEFT", LunaPetFrame, "TOPRIGHT", 3, 1)
		LunaPetFrame.Debuffs[1]:ClearAllPoints()
		LunaPetFrame.Debuffs[1]:SetPoint("TOPLEFT", LunaPetFrame.Buffs[9], "BOTTOMLEFT", 0, -1)
		LunaPetFrame.Buffs[9]:ClearAllPoints()
		LunaPetFrame.Buffs[9]:SetPoint("TOPLEFT", LunaPetFrame.Buffs[1], "BOTTOMLEFT", 0, -1)
		LunaPetFrame.Debuffs[9]:ClearAllPoints()
		LunaPetFrame.Debuffs[9]:SetPoint("TOPLEFT", LunaPetFrame.Debuffs[1], "BOTTOMLEFT", 0, -1)
		for i=2, 8 do
			LunaPetFrame.Buffs[i]:ClearAllPoints()
			LunaPetFrame.Buffs[i]:SetPoint("TOPLEFT", LunaPetFrame.Buffs[i-1], "TOPRIGHT",1, 0)
			LunaPetFrame.Debuffs[i]:ClearAllPoints()
			LunaPetFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaPetFrame.Debuffs[i-1], "TOPRIGHT",1, 0)
		end
		for i=10, 16 do
			LunaPetFrame.Buffs[i]:ClearAllPoints()
			LunaPetFrame.Buffs[i]:SetPoint("TOPLEFT", LunaPetFrame.Buffs[i-1], "TOPRIGHT",1, 0)
			LunaPetFrame.Debuffs[i]:ClearAllPoints()
			LunaPetFrame.Debuffs[i]:SetPoint("TOPLEFT", LunaPetFrame.Debuffs[i-1], "TOPRIGHT",1, 0)
		end
		LunaUnitFrames:UpdatePetBuffSize()
		Luna_Pet_Events:UNIT_AURA()
	end
end

function LunaUnitFrames:UpdatePetBuffSize()
	local size
	if LunaOptions.frames["LunaPetFrame"].ShowBuffs == 2 or LunaOptions.frames["LunaPetFrame"].ShowBuffs == 3 then
		size = (LunaPetFrame:GetWidth()-15)/16
	else
		size = (LunaPetFrame:GetHeight()-3)/4
	end
	for i=1, 16 do
		LunaPetFrame.Buffs[i]:SetHeight(size)
		LunaPetFrame.Buffs[i]:SetWidth(size)
		LunaPetFrame.Buffs[i].stacks:SetFont(LunaOptions.font, size*0.75)
		LunaPetFrame.Debuffs[i]:SetHeight(size)
		LunaPetFrame.Debuffs[i]:SetWidth(size)
		LunaPetFrame.Debuffs[i].stacks:SetFont(LunaOptions.font, size*0.75)
	end	
end

function Luna_Pet_Events:UNIT_AURA()
	if this.unit == arg1 then
		for i=1, 16 do
			local path, stacks = UnitBuff(this.unit,i)
			this.Buffs[i].texturepath = path
			if this.Buffs[i].texturepath then
				this.Buffs[i]:EnableMouse(1)
				this.Buffs[i]:Show()
				if stacks > 1 then
					this.Buffs[i].stacks:SetText(stacks)
					this.Buffs[i].stacks:Show()
				else
					this.Buffs[i].stacks:Hide()
				end
			else
				this.Buffs[i]:EnableMouse(0)
				this.Buffs[i]:Hide()
			end
			this.Buffs[i]:SetNormalTexture(this.Buffs[i].texturepath)
		end

		for i=1, 16 do
			local path, stacks = UnitDebuff(this.unit,i)
			this.Debuffs[i].texturepath = path
			if this.Debuffs[i].texturepath then
				this.Debuffs[i]:EnableMouse(1)
				this.Debuffs[i]:Show()
				if stacks > 1 then
					this.Debuffs[i].stacks:SetText(stacks)
					this.Debuffs[i].stacks:Show()
				else
					this.Debuffs[i].stacks:Hide()
				end
			else
				this.Debuffs[i]:EnableMouse(0)
				this.Debuffs[i]:Hide()
			end
			this.Debuffs[i]:SetNormalTexture(this.Debuffs[i].texturepath)
		end
	end
end

function Luna_Pet_Events:UNIT_HEALTH()
	LunaPetFrame.HealthBar:SetMinMaxValues(0, UnitHealthMax("pet"))
	LunaPetFrame.HealthBar:SetValue(UnitHealth("pet"))
	LunaPetFrame.HealthBar.hpp:SetText(UnitHealth("pet").."/"..UnitHealthMax("pet"))
	if UnitIsDead("pet") then
		LunaPetFrame.HealthBar:SetValue(0)
	end
end
Luna_Pet_Events.UNIT_MAXHEALTH = Luna_Pet_Events.UNIT_HEALTH

function Luna_Pet_Events:UNIT_MANA()
	LunaPetFrame.PowerBar:SetMinMaxValues(0, UnitManaMax("pet"))
	LunaPetFrame.PowerBar:SetValue(UnitMana("pet"))
	LunaPetFrame.PowerBar.ppp:SetText(UnitMana("pet").."/"..UnitManaMax("pet"))
end
Luna_Pet_Events.UNIT_MAXMANA = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_ENERGY = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_MAXENERGY = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_RAGE = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_MAXRAGE = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_FOCUS = Luna_Pet_Events.UNIT_MANA
Luna_Pet_Events.UNIT_MAXFOCUS = Luna_Pet_Events.UNIT_MANA

function Luna_Pet_Events:UNIT_HAPPINESS()
	local happiness = GetPetHappiness()
	if happiness == 1 then
		LunaPetFrame.HealthBar:SetStatusBarColor(LunaOptions.MiscColors["hostile"][1],LunaOptions.MiscColors["hostile"][2],LunaOptions.MiscColors["hostile"][3])
		LunaPetFrame.HealthBar.hpbg:SetVertexColor(LunaOptions.MiscColors["hostile"][1],LunaOptions.MiscColors["hostile"][2],LunaOptions.MiscColors["hostile"][3], 0.25)
	elseif happiness == 2 then
		LunaPetFrame.HealthBar:SetStatusBarColor(LunaOptions.MiscColors["neutral"][1],LunaOptions.MiscColors["neutral"][2],LunaOptions.MiscColors["neutral"][3])
		LunaPetFrame.HealthBar.hpbg:SetVertexColor(LunaOptions.MiscColors["neutral"][1],LunaOptions.MiscColors["neutral"][2],LunaOptions.MiscColors["neutral"][3], 0.25)
	else
		LunaPetFrame.HealthBar:SetStatusBarColor(LunaOptions.MiscColors["friendly"][1],LunaOptions.MiscColors["friendly"][2],LunaOptions.MiscColors["friendly"][3])
		LunaPetFrame.HealthBar.hpbg:SetVertexColor(LunaOptions.MiscColors["friendly"][1],LunaOptions.MiscColors["friendly"][2],LunaOptions.MiscColors["friendly"][3], 0.25)
	end
end

function Luna_Pet_Events:UNIT_PORTRAIT_UPDATE()
	if arg1 == this.unit then
		local portrait = this.portrait
		if(portrait.type == "3D") then
			if(not UnitExists(arg1) or not UnitIsConnected(arg1) or not UnitIsVisible(arg1)) then
				portrait:SetModelScale(4.25)
				portrait:SetPosition(0, 0, -1)
				portrait:SetModel"Interface\\Buttons\\talktomequestionmark.mdx"
			else
				portrait:SetUnit(arg1)
				portrait:SetCamera(0)
				portrait:Show()
			end
		else
			SetPortraitTexture(portrait, arg1)
		end
	end
end
Luna_Pet_Events.UNIT_MODEL_CHANGED = Luna_Pet_Events.UNIT_PORTRAIT_UPDATE

function Luna_Pet_Events:UNIT_LEVEL()
	LunaPetFrame.lvl:SetText(UnitLevel(LunaPetFrame.unit))
end

function Luna_Pet_Events:UNIT_PET()
	LunaUnitFrames:UpdatePetFrame()
end

function Luna_Pet_Events:UNIT_NAME_UPDATE()
	if arg1 == "pet" then
		LunaPetFrame.name:SetText(UnitName(LunaPetFrame.unit))
	end
end