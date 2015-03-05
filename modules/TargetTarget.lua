local Luna_TargetTarget_Events = {}

local tot = CreateFrame("Frame")
tot.time = 0

local dropdown = CreateFrame("Frame", "LunaUnitDropDownMenuTargetTarget", UIParent, "UIDropDownMenuTemplate")
function Luna_TargetTargetDropDown_Initialize()
	local menu, name;
	if (UnitIsUnit("targettarget", "player")) then
		menu = "SELF";
	elseif (UnitIsUnit("targettarget", "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer("targettarget")) then
		if (UnitInParty("targettarget")) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end
	if (menu) then
		UnitPopup_ShowMenu(dropdown, menu, "targettarget", name);
	end
end
UIDropDownMenu_Initialize(dropdown, Luna_TargetTargetDropDown_Initialize, "MENU")

local dropdown2 = CreateFrame("Frame", "LunaUnitDropDownMenuTargetTargetTarget", UIParent, "UIDropDownMenuTemplate")
function Luna_TargetTargetTargetDropDown_Initialize()
	local menu, name
	if (UnitIsUnit("targettargettarget", "player")) then
		menu = "SELF"
	elseif (UnitIsUnit("targettargettarget", "pet")) then
		menu = "PET"
	elseif (UnitIsPlayer("targettargettarget")) then
		if (UnitInParty("targettargettarget")) then
			menu = "PARTY"
		else
			menu = "PLAYER"
		end
	else
		menu = "RAID_TARGET_ICON"
		name = RAID_TARGET_ICON
	end
	if (menu) then
		UnitPopup_ShowMenu(dropdown2, menu, "targettargettarget", name);
	end
end
UIDropDownMenu_Initialize(dropdown2, Luna_TargetTargetTargetDropDown_Initialize, "MENU")

function Luna_TargetTarget_OnClick()
	local button = arg1
	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit(this.unit)
		elseif (CursorHasItem()) then
			DropItemOnUnit(this.unit)
		else
			TargetUnit(this.unit)
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
		if this.unit == "targettarget" then
			ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
		else
			ToggleDropDownMenu(1, nil, dropdown2, "cursor", 0, 0)
		end
	end
end

function Luna_TargetTarget_OnEvent()
	local func = Luna_TargetTarget_Events[event]
	if (func) then
		func()
	else
		DEFAULT_CHAT_FRAME:AddMessage("Luna Unit Frames - TargetTarget: Report the following event error to the author: "..event)
	end
end

function Luna_TargetTarget_OnUpdate()
	tot.time = tot.time + arg1;
	if (tot.time > 0.2) then
		tot.time = 0;
		LunaUnitFrames:UpdateTargetTargetFrame()
		LunaUnitFrames:UpdateTargetTargetTargetFrame()
	end
end

local function StartMoving()
	this:StartMoving()
end

local function StopMovingOrSizing()
	this:StopMovingOrSizing()
	_,_,_,LunaOptions.frames[this:GetName()].position.x, LunaOptions.frames[this:GetName()].position.y = this:GetPoint()
end

function LunaUnitFrames:ToggleTargetTargetLock()
	if LunaTargetTargetFrame:IsMovable() then
		LunaTargetTargetFrame:SetScript("OnDragStart", nil)
		LunaTargetTargetFrame:SetMovable(0)
		LunaTargetTargetTargetFrame:SetScript("OnDragStart", nil)
		LunaTargetTargetTargetFrame:SetMovable(0)
	else
		LunaTargetTargetFrame:SetScript("OnDragStart", StartMoving)
		LunaTargetTargetFrame:SetMovable(1)
		LunaTargetTargetTargetFrame:SetScript("OnDragStart", StartMoving)
		LunaTargetTargetTargetFrame:SetMovable(1)
	end
end

function LunaUnitFrames:CreateTargetTargetFrame()
	LunaTargetTargetFrame = CreateFrame("Button", "LunaTargetTargetFrame", UIParent)

	LunaTargetTargetFrame:SetHeight(LunaOptions.frames["LunaTargetTargetFrame"].size.y)
	LunaTargetTargetFrame:SetWidth(LunaOptions.frames["LunaTargetTargetFrame"].size.x)
	LunaTargetTargetFrame:SetScale(LunaOptions.frames["LunaTargetTargetFrame"].scale)
	LunaTargetTargetFrame:SetBackdrop(LunaOptions.backdrop)
	LunaTargetTargetFrame:SetBackdropColor(0,0,0,1)
	LunaTargetTargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaTargetTargetFrame"].position.x, LunaOptions.frames["LunaTargetTargetFrame"].position.y)
	LunaTargetTargetFrame:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	LunaTargetTargetFrame.unit = "targettarget"
	LunaTargetTargetFrame:SetScript("OnEnter", UnitFrame_OnEnter)
	LunaTargetTargetFrame:SetScript("OnLeave", UnitFrame_OnLeave)
	LunaTargetTargetFrame:SetMovable(0)
	LunaTargetTargetFrame:RegisterForDrag("LeftButton")
	LunaTargetTargetFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaTargetTargetFrame:SetClampedToScreen(1)

	LunaTargetTargetFrame.bars = {}
	
	-- Healthbar
	local hp = CreateFrame("StatusBar", nil, LunaTargetTargetFrame)
	hp:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaTargetTargetFrame.bars["Healthbar"] = hp

	-- Healthbar background
	local hpbg = LunaTargetTargetFrame.bars["Healthbar"]:CreateTexture(nil, "BORDER")
	hpbg:SetAllPoints(LunaTargetTargetFrame.bars["Healthbar"])
	hpbg:SetTexture(.25,.25,.25,.25)
	LunaTargetTargetFrame.bars["Healthbar"].hpbg = hpbg

	-- Healthbar text
	local hpp = LunaTargetTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetFrame.bars["Healthbar"])
	hpp:SetPoint("RIGHT", -2, 0)
	hpp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	hpp:SetShadowColor(0, 0, 0)
	hpp:SetShadowOffset(0.8, -0.8)
	hpp:SetTextColor(1,1,1)
	hpp:SetJustifyH("RIGHT")
	LunaTargetTargetFrame.bars["Healthbar"].hpp = hpp

	local name = LunaTargetTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetFrame.bars["Healthbar"])
	name:SetPoint("LEFT", LunaTargetTargetFrame.bars["Healthbar"], 2, -1)
	name:SetJustifyH("LEFT")
	name:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	name:SetShadowColor(0, 0, 0)
	name:SetShadowOffset(0.8, -0.8)
	name:SetTextColor(1,1,1)
	name:SetText(UnitName("target"))
	LunaTargetTargetFrame.name = name

	local icon = LunaTargetTargetFrame.bars["Healthbar"]:CreateTexture(nil, "OVERLAY")
	icon:SetHeight(20)
	icon:SetWidth(20)
	icon:SetPoint("CENTER", LunaTargetTargetFrame.bars["Healthbar"], "TOP", 0, 0)
	icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	LunaTargetTargetFrame.RaidIcon = icon
	
		-- Manabar
	local pp = CreateFrame("StatusBar", nil, LunaTargetTargetFrame)
	pp:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaTargetTargetFrame.bars["Powerbar"] = pp
	
	-- Manabar background
	local ppbg = LunaTargetTargetFrame.bars["Powerbar"]:CreateTexture(nil, "BORDER")
	ppbg:SetAllPoints(LunaTargetTargetFrame.bars["Powerbar"])
	ppbg:SetTexture(.25,.25,.25,.25)
	LunaTargetTargetFrame.bars["Powerbar"].ppbg = ppbg

	local ppp = LunaTargetTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetFrame.bars["Powerbar"])
	ppp:SetPoint("RIGHT", -2, 0)
	ppp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	ppp:SetShadowColor(0, 0, 0)
	ppp:SetShadowOffset(0.8, -0.8)
	ppp:SetTextColor(1,1,1)
	ppp:SetJustifyH("RIGHT")
	LunaTargetTargetFrame.bars["Powerbar"].ppp = ppp
	
	local lvl
	lvl = LunaTargetTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY")
	lvl:SetPoint("LEFT", LunaTargetTargetFrame.bars["Powerbar"], "LEFT", 2, -1)
	lvl:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	lvl:SetShadowColor(0, 0, 0)
	lvl:SetShadowOffset(0.8, -0.8)
	LunaTargetTargetFrame.Lvl = lvl
	
	LunaTargetTargetFrame.class = LunaTargetTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY")
	LunaTargetTargetFrame.class:SetPoint("LEFT", LunaTargetTargetFrame.Lvl, "RIGHT",  1, 0)
	LunaTargetTargetFrame.class:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetTargetFrame.class:SetShadowColor(0, 0, 0)
	LunaTargetTargetFrame.class:SetShadowOffset(0.8, -0.8)
	
	LunaTargetTargetFrame:Hide()
	
	LunaTargetTargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	
	LunaTargetTargetFrame:SetScript("OnClick", Luna_TargetTarget_OnClick)
	LunaTargetTargetFrame:SetScript("OnEvent", Luna_TargetTarget_OnEvent)
	tot:SetScript("OnUpdate", Luna_TargetTarget_OnUpdate)
	
	LunaTargetTargetFrame.AdjustBars = function()
		local frameHeight = LunaTargetTargetFrame:GetHeight()
		local frameWidth = LunaTargetTargetFrame:GetWidth()
		local anchor
		local totalWeight = 0
		local gaps = -1
		anchor = {"TOPLEFT", LunaTargetTargetFrame, "TOPLEFT"}
		for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
			if LunaTargetTargetFrame.bars[v[1]]:IsShown() then
				totalWeight = totalWeight + v[2]
				gaps = gaps + 1
			end
		end
		local firstbar = 1
		for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
			local bar = v[1]
			local weight = v[2]/totalWeight
			local height = (frameHeight-gaps)*weight
			LunaTargetTargetFrame.bars[bar]:ClearAllPoints()
			LunaTargetTargetFrame.bars[bar]:SetHeight(height)
			LunaTargetTargetFrame.bars[bar]:SetWidth(frameWidth)
			LunaTargetTargetFrame.bars[bar].rank = k
			LunaTargetTargetFrame.bars[bar].weight = v[2]
			if not firstbar and LunaTargetTargetFrame.bars[bar]:IsShown() then
				LunaTargetTargetFrame.bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3], 0, -1)
				anchor = {"TOPLEFT", LunaTargetTargetFrame.bars[bar], "BOTTOMLEFT"}
			elseif LunaTargetTargetFrame.bars[bar]:IsShown() then
				LunaTargetTargetFrame.bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3])
				firstbar = nil
				anchor = {"TOPLEFT", LunaTargetTargetFrame.bars[bar], "BOTTOMLEFT"}
			end			
		end
		local healthheight = (LunaTargetTargetFrame.bars["Healthbar"]:GetHeight()/23.4)*11
		if healthheight > 0 then
			LunaTargetTargetFrame.bars["Healthbar"].hpp:SetFont(LunaOptions.font, healthheight)
			LunaTargetTargetFrame.name:SetFont(LunaOptions.font, healthheight)
		end
		if healthheight < 6 then
			LunaTargetTargetFrame.bars["Healthbar"].hpp:Hide()
			LunaTargetTargetFrame.name:Hide()
		else
			LunaTargetTargetFrame.bars["Healthbar"].hpp:Show()
			LunaTargetTargetFrame.name:Show()
		end
		local powerheight = (LunaTargetTargetFrame.bars["Powerbar"]:GetHeight()/23.4)*11
		if powerheight > 0 then
			LunaTargetTargetFrame.bars["Powerbar"].ppp:SetFont(LunaOptions.font, powerheight)
			LunaTargetTargetFrame.Lvl:SetFont(LunaOptions.font, powerheight)
			LunaTargetTargetFrame.class:SetFont(LunaOptions.font, powerheight)
		end
		if powerheight < 6 then
			LunaTargetTargetFrame.bars["Powerbar"].ppp:Hide()
			LunaTargetTargetFrame.Lvl:Hide()
			LunaTargetTargetFrame.class:Hide()
		else
			LunaTargetTargetFrame.bars["Powerbar"].ppp:Show()
			LunaTargetTargetFrame.Lvl:Show()
			LunaTargetTargetFrame.class:Show()
		end
	end
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
		if v[2] == 0 then
			LunaTargetTargetFrame.bars[v[1]]:Hide()
		end
	end
	LunaTargetTargetFrame.AdjustBars()	
end

function Luna_TargetTarget_Events:PLAYER_TARGET_CHANGED()
	LunaUnitFrames:UpdateTargetTargetFrame()
	LunaUnitFrames:UpdateTargetTargetTargetFrame()
end

function LunaUnitFrames:UpdateTargetTargetFrame()
	if LunaOptions.frames["LunaTargetTargetFrame"].enabled == 1 and UnitExists("targettarget") then
		LunaTargetTargetFrame:Show()
	else
		LunaTargetTargetFrame:Hide()
		return
	end
	local _,class = UnitClass("targettarget")
	if UnitIsPlayer("targettarget") then
		local color = LunaOptions.ClassColors[class]
		LunaTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
		LunaTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
	elseif UnitIsTapped("targettarget") and not UnitIsTappedByPlayer("targettarget") then
		LunaTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.5, 0.5, 0.5)
		LunaTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.5, 0.5, 0.5, 0.25)
	else
		reaction = UnitReaction("targettarget", "player")
		if reaction and reaction < 4 then
			LunaTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.9, 0, 0)
			LunaTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.9, 0, 0, 0.25)
		elseif reaction and reaction > 4 then
			LunaTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(0, 0.8, 0)
			LunaTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0, 0.8, 0, 0.25)
		else
			LunaTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.93, 0.93, 0)
			LunaTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.93, 0.93, 0, 0.25)
		end
	end
	if not UnitIsConnected(LunaTargetTargetFrame.unit) then
		LunaTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Healthbar"]:SetValue(0)
		LunaTargetTargetFrame.bars["Healthbar"].hpp:SetText("OFFLINE")
			
		LunaTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Powerbar"]:SetValue(0)
		LunaTargetTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaTargetTargetFrame.unit))
	elseif UnitHealth(LunaTargetTargetFrame.unit) < 1 then
		LunaTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Healthbar"]:SetValue(0)
		LunaTargetTargetFrame.bars["Healthbar"].hpp:SetText("DEAD")
			
		LunaTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Powerbar"]:SetValue(0)
		LunaTargetTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaTargetTargetFrame.unit))
	else
		LunaTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Healthbar"]:SetValue(UnitHealth(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Healthbar"].hpp:SetText(LunaUnitFrames:GetHealthString("targettarget"))
			
		LunaTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Powerbar"]:SetValue(UnitMana(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaTargetTargetFrame.unit))
	end
	local targetpower = UnitPowerType("targettarget")
	
	if UnitManaMax("targettarget") == 0 then
		LunaTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(0, 0, 0, .25)
		LunaTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(0, 0, 0, .25)
	elseif targetpower == 1 then
		LunaTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
		LunaTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
	elseif targetpower == 2 then
		LunaTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3])
		LunaTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3], 0.25)
	elseif targetpower == 3 then
		LunaTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
		LunaTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
	elseif not UnitIsDeadOrGhost("targettarget") then
		LunaTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		LunaTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
	else
		LunaTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(0, 0, 0, .25)
		LunaTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(0, 0, 0, .25)
	end
	
	if UnitIsPlayer("targettarget") then
		LunaTargetTargetFrame.class:SetText(UnitClass("targettarget"))
	elseif UnitClassification("targettarget") == "normal" then
		LunaTargetTargetFrame.class:SetText(UnitCreatureType("targettarget"))
	else
		LunaTargetTargetFrame.class:SetText(UnitClassification("targettarget").." "..UnitCreatureType("targettarget"))
	end
	if UnitLevel("targettarget") > 0 then
		LunaTargetTargetFrame.Lvl:SetText(UnitLevel("targettarget"))
	else
		LunaTargetTargetFrame.Lvl:SetText("??")
	end
	LunaTargetTargetFrame.name:SetText(UnitName("targettarget"))
	local index = GetRaidTargetIndex("targettarget")
	if (index) then
		SetRaidTargetIconTexture(LunaTargetTargetFrame.RaidIcon, index)
		LunaTargetTargetFrame.RaidIcon:Show()
	else
		LunaTargetTargetFrame.RaidIcon:Hide()
	end
end

function LunaUnitFrames:CreateTargetTargetTargetFrame()
	LunaTargetTargetTargetFrame = CreateFrame("Button", "LunaTargetTargetTargetFrame", UIParent)

	LunaTargetTargetTargetFrame:SetHeight(LunaOptions.frames["LunaTargetTargetTargetFrame"].size.y)
	LunaTargetTargetTargetFrame:SetWidth(LunaOptions.frames["LunaTargetTargetTargetFrame"].size.x)
	LunaTargetTargetTargetFrame:SetScale(LunaOptions.frames["LunaTargetTargetTargetFrame"].scale)
	LunaTargetTargetTargetFrame:SetBackdrop(LunaOptions.backdrop)
	LunaTargetTargetTargetFrame:SetBackdropColor(0,0,0,1)
	LunaTargetTargetTargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaTargetTargetTargetFrame"].position.x, LunaOptions.frames["LunaTargetTargetTargetFrame"].position.y)
	LunaTargetTargetTargetFrame:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
	LunaTargetTargetTargetFrame.unit = "targettargettarget"
	LunaTargetTargetTargetFrame:SetScript("OnEnter", UnitFrame_OnEnter)
	LunaTargetTargetTargetFrame:SetScript("OnLeave", UnitFrame_OnLeave)
	LunaTargetTargetTargetFrame:SetMovable(0)
	LunaTargetTargetTargetFrame:RegisterForDrag("LeftButton")
	LunaTargetTargetTargetFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaTargetTargetTargetFrame:SetClampedToScreen(1)

	LunaTargetTargetTargetFrame.bars = {}
	
	-- Healthbar
	local hp = CreateFrame("StatusBar", nil, LunaTargetTargetTargetFrame)
	hp:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaTargetTargetTargetFrame.bars["Healthbar"] = hp

	-- Healthbar background
	local hpbg = LunaTargetTargetTargetFrame.bars["Healthbar"]:CreateTexture(nil, "BORDER")
	hpbg:SetAllPoints(LunaTargetTargetTargetFrame.bars["Healthbar"])
	hpbg:SetTexture(.25,.25,.25,.25)
	LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg = hpbg

	-- Healthbar text
	local hpp = LunaTargetTargetTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetTargetFrame.bars["Healthbar"])
	hpp:SetPoint("RIGHT", -2, 0)
	hpp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	hpp:SetShadowColor(0, 0, 0)
	hpp:SetShadowOffset(0.8, -0.8)
	hpp:SetTextColor(1,1,1)
	hpp:SetJustifyH("RIGHT")
	LunaTargetTargetTargetFrame.bars["Healthbar"].hpp = hpp

	local name = LunaTargetTargetTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetTargetFrame.bars["Healthbar"])
	name:SetPoint("LEFT", LunaTargetTargetTargetFrame.bars["Healthbar"], 2, -1)
	name:SetJustifyH("LEFT")
	name:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	name:SetShadowColor(0, 0, 0)
	name:SetShadowOffset(0.8, -0.8)
	name:SetTextColor(1,1,1)
	name:SetText(UnitName("target"))
	LunaTargetTargetTargetFrame.name = name

	local icon = LunaTargetTargetTargetFrame.bars["Healthbar"]:CreateTexture(nil, "OVERLAY")
	icon:SetHeight(20)
	icon:SetWidth(20)
	icon:SetPoint("CENTER", LunaTargetTargetTargetFrame.bars["Healthbar"], "TOP", 0, 0)
	icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	LunaTargetTargetTargetFrame.RaidIcon = icon
	
		-- Manabar
	local pp = CreateFrame("StatusBar", nil, LunaTargetTargetTargetFrame)
	pp:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaTargetTargetTargetFrame.bars["Powerbar"] = pp
	
	-- Manabar background
	local ppbg = LunaTargetTargetTargetFrame.bars["Powerbar"]:CreateTexture(nil, "BORDER")
	ppbg:SetAllPoints(LunaTargetTargetTargetFrame.bars["Powerbar"])
	ppbg:SetTexture(.25,.25,.25,.25)
	LunaTargetTargetTargetFrame.bars["Powerbar"].ppbg = ppbg

	local ppp = LunaTargetTargetTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetTargetFrame.bars["Powerbar"])
	ppp:SetPoint("RIGHT", -2, 0)
	ppp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	ppp:SetShadowColor(0, 0, 0)
	ppp:SetShadowOffset(0.8, -0.8)
	ppp:SetTextColor(1,1,1)
	ppp:SetJustifyH("RIGHT")
	LunaTargetTargetTargetFrame.bars["Powerbar"].ppp = ppp
	
	local lvl
	lvl = LunaTargetTargetTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY")
	lvl:SetPoint("LEFT", LunaTargetTargetTargetFrame.bars["Powerbar"], "LEFT", 2, -1)
	lvl:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	lvl:SetShadowColor(0, 0, 0)
	lvl:SetShadowOffset(0.8, -0.8)
	LunaTargetTargetTargetFrame.Lvl = lvl
	
	LunaTargetTargetTargetFrame.class = LunaTargetTargetTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY")
	LunaTargetTargetTargetFrame.class:SetPoint("LEFT", LunaTargetTargetTargetFrame.Lvl, "RIGHT",  1, 0)
	LunaTargetTargetTargetFrame.class:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetTargetTargetFrame.class:SetShadowColor(0, 0, 0)
	LunaTargetTargetTargetFrame.class:SetShadowOffset(0.8, -0.8)
	
	LunaTargetTargetTargetFrame:Hide()
		
	LunaTargetTargetTargetFrame:SetScript("OnClick", Luna_TargetTarget_OnClick)
	LunaTargetTargetTargetFrame:SetScript("OnEvent", Luna_TargetTarget_OnEvent)
	tot:SetScript("OnUpdate", Luna_TargetTarget_OnUpdate)
	
	LunaTargetTargetTargetFrame.AdjustBars = function()
		local frameHeight = LunaTargetTargetTargetFrame:GetHeight()
		local frameWidth = LunaTargetTargetTargetFrame:GetWidth()
		local anchor
		local totalWeight = 0
		local gaps = -1
		anchor = {"TOPLEFT", LunaTargetTargetTargetFrame, "TOPLEFT"}
		for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
			if LunaTargetTargetTargetFrame.bars[v[1]]:IsShown() then
				totalWeight = totalWeight + v[2]
				gaps = gaps + 1
			end
		end
		local firstbar = 1
		for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
			local bar = v[1]
			local weight = v[2]/totalWeight
			local height = (frameHeight-gaps)*weight
			LunaTargetTargetTargetFrame.bars[bar]:ClearAllPoints()
			LunaTargetTargetTargetFrame.bars[bar]:SetHeight(height)
			LunaTargetTargetTargetFrame.bars[bar]:SetWidth(frameWidth)
			LunaTargetTargetTargetFrame.bars[bar].rank = k
			LunaTargetTargetTargetFrame.bars[bar].weight = v[2]
			if not firstbar and LunaTargetTargetTargetFrame.bars[bar]:IsShown() then
				LunaTargetTargetTargetFrame.bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3], 0, -1)
				anchor = {"TOPLEFT", LunaTargetTargetTargetFrame.bars[bar], "BOTTOMLEFT"}
			elseif LunaTargetTargetTargetFrame.bars[bar]:IsShown() then
				LunaTargetTargetTargetFrame.bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3])
				firstbar = nil
				anchor = {"TOPLEFT", LunaTargetTargetTargetFrame.bars[bar], "BOTTOMLEFT"}
			end			
		end
		local healthheight = (LunaTargetTargetTargetFrame.bars["Healthbar"]:GetHeight()/23.4)*11
		if healthheight > 0 then
			LunaTargetTargetTargetFrame.bars["Healthbar"].hpp:SetFont(LunaOptions.font, healthheight)
			LunaTargetTargetTargetFrame.name:SetFont(LunaOptions.font, healthheight)
		end
		if healthheight < 6 then
			LunaTargetTargetTargetFrame.bars["Healthbar"].hpp:Hide()
			LunaTargetTargetTargetFrame.name:Hide()
		else
			LunaTargetTargetTargetFrame.bars["Healthbar"].hpp:Show()
			LunaTargetTargetTargetFrame.name:Show()
		end
		local powerheight = (LunaTargetTargetTargetFrame.bars["Powerbar"]:GetHeight()/23.4)*11
		if powerheight > 0 then
			LunaTargetTargetTargetFrame.bars["Powerbar"].ppp:SetFont(LunaOptions.font, powerheight)
			LunaTargetTargetTargetFrame.Lvl:SetFont(LunaOptions.font, powerheight)
			LunaTargetTargetTargetFrame.class:SetFont(LunaOptions.font, powerheight)
		end
		if powerheight < 6 then
			LunaTargetTargetTargetFrame.bars["Powerbar"].ppp:Hide()
			LunaTargetTargetTargetFrame.Lvl:Hide()
			LunaTargetTargetTargetFrame.class:Hide()
		else
			LunaTargetTargetTargetFrame.bars["Powerbar"].ppp:Show()
			LunaTargetTargetTargetFrame.Lvl:Show()
			LunaTargetTargetTargetFrame.class:Show()
		end
	end
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
		if v[2] == 0 then
			LunaTargetTargetTargetFrame.bars[v[1]]:Hide()
		end
	end
	LunaTargetTargetTargetFrame.AdjustBars()
		
end

function LunaUnitFrames:UpdateTargetTargetTargetFrame()
	if LunaOptions.frames["LunaTargetTargetTargetFrame"].enabled == 1 and UnitExists("targettargettarget") then
		LunaTargetTargetTargetFrame:Show()
	else
		LunaTargetTargetTargetFrame:Hide()
		return
	end
	local _,class = UnitClass("targettargettarget")
	if UnitIsPlayer("targettargettarget") then
		local color = LunaOptions.ClassColors[class]
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
		LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
	elseif UnitIsTapped("targettargettarget") and not UnitIsTappedByPlayer("targettargettarget") then
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.5, 0.5, 0.5)
		LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.5, 0.5, 0.5, 0.25)
	else
		reaction = UnitReaction("targettargettarget", "player")
		if reaction and reaction < 4 then
			LunaTargetTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.9, 0, 0)
			LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.9, 0, 0, 0.25)
		elseif reaction and reaction > 4 then
			LunaTargetTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(0, 0.8, 0)
			LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0, 0.8, 0, 0.25)
		else
			LunaTargetTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.93, 0.93, 0)
			LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.93, 0.93, 0, 0.25)
		end
	end
	if not UnitIsConnected(LunaTargetTargetTargetFrame.unit) then
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetValue(0)
		LunaTargetTargetTargetFrame.bars["Healthbar"].hpp:SetText("OFFLINE")
			
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetValue(0)
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaTargetTargetTargetFrame.unit))
	elseif UnitHealth(LunaTargetTargetTargetFrame.unit) < 1 then
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetValue(0)
		LunaTargetTargetTargetFrame.bars["Healthbar"].hpp:SetText("DEAD")
			
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetValue(0)
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaTargetTargetTargetFrame.unit))
	else
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetValue(UnitHealth(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Healthbar"].hpp:SetText(LunaUnitFrames:GetHealthString("targettargettarget"))
			
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetValue(UnitMana(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaTargetTargetTargetFrame.unit))
	end
	local targetpower = UnitPowerType("targettargettarget")
	
	if UnitManaMax("targettargettarget") == 0 then
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(0, 0, 0, .25)
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(0, 0, 0, .25)
	elseif targetpower == 1 then
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
	elseif targetpower == 2 then
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3])
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Focus"][1],LunaOptions.PowerColors["Focus"][2],LunaOptions.PowerColors["Focus"][3], 0.25)
	elseif targetpower == 3 then
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
	elseif not UnitIsDeadOrGhost("targettargettarget") then
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
	else
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(0, 0, 0, .25)
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(0, 0, 0, .25)
	end
	
	if UnitIsPlayer("targettargettarget") then
		LunaTargetTargetTargetFrame.class:SetText(UnitClass("targettargettarget"))
	elseif UnitClassification("targettargettarget") == "normal" then
		LunaTargetTargetTargetFrame.class:SetText(UnitCreatureType("targettargettarget"))
	else
		LunaTargetTargetTargetFrame.class:SetText(UnitClassification("targettargettarget").." "..UnitCreatureType("targettargettarget"))
	end
	if UnitLevel("targettargettarget") > 0 then
		LunaTargetTargetTargetFrame.Lvl:SetText(UnitLevel("targettargettarget"))
	else
		LunaTargetTargetTargetFrame.Lvl:SetText("??")
	end
	LunaTargetTargetTargetFrame.name:SetText(UnitName("targettargettarget"))
	local index = GetRaidTargetIndex("targettargettarget")
	if (index) then
		SetRaidTargetIconTexture(LunaTargetTargetTargetFrame.RaidIcon, index)
		LunaTargetTargetTargetFrame.RaidIcon:Show()
	else
		LunaTargetTargetTargetFrame.RaidIcon:Hide()
	end
end