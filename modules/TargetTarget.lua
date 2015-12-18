local Luna_TargetTarget_Events = {}

local tot = CreateFrame("Frame")
tot.time = 0

local validunits = {
					["party1"] = true,
					["party2"] = true,
					["party3"] = true,
					["party4"] = true,
					["partypet1"] = true,
					["partypet2"] = true,
					["partypet3"] = true,
					["partypet4"] = true,
					["player"] = true,
					["pet"] = true,
					["target"] = true
				}
					
for i=1, 40 do
	validunits["raid"..i] = true
	validunits["raidpet"..i] = true
end

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
		UnitPopup_ShowMenu(LunaTargetTargetFrame.dropdown, menu, LunaTargetTargetFrame.unit, name);
	end
end

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
		UnitPopup_ShowMenu(LunaTargetTargetTargetFrame.dropdown, menu, LunaTargetTargetTargetFrame.unit, name);
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

local function Luna_TargetTarget_SetBuffTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	if (this.id > 16) then
		GameTooltip:SetUnitDebuff("targettarget", this.id-16)
	else
		GameTooltip:SetUnitBuff("targettarget", this.id)
	end
end

local function Luna_TargetTarget_SetBuffTooltipLeave()
	GameTooltip:Hide()
end

local function Luna_TargetTargetTarget_SetBuffTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	if (this.id > 16) then
		GameTooltip:SetUnitDebuff("targettargettarget", this.id-16)
	else
		GameTooltip:SetUnitBuff("targettargettarget", this.id)
	end
end

local function Luna_TargetTargetTarget_SetBuffTooltipLeave()
	GameTooltip:Hide()
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
	LunaTargetTargetFrame:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
	LunaTargetTargetFrame.unit = "targettarget"
	LunaTargetTargetFrame:SetScript("OnEnter", UnitFrame_OnEnter)
	LunaTargetTargetFrame:SetScript("OnLeave", UnitFrame_OnLeave)
	LunaTargetTargetFrame:SetMovable(0)
	LunaTargetTargetFrame:RegisterForDrag("LeftButton")
	LunaTargetTargetFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaTargetTargetFrame:SetClampedToScreen(1)
	LunaTargetTargetFrame:SetFrameStrata("BACKGROUND")

	LunaTargetTargetFrame.borders = {}
	
	LunaTargetTargetFrame.borders["TOP"] = LunaTargetTargetFrame:CreateTexture("PlayerTopBorder", "ARTWORK")
	LunaTargetTargetFrame.borders["TOP"]:SetPoint("BOTTOMLEFT", LunaTargetTargetFrame, "TOPLEFT")
	LunaTargetTargetFrame.borders["TOP"]:SetHeight(1)
	
	LunaTargetTargetFrame.borders["BOTTOM"] = LunaTargetTargetFrame:CreateTexture("PlayerBottomBorder", "ARTWORK")
	LunaTargetTargetFrame.borders["BOTTOM"]:SetPoint("TOPLEFT", LunaTargetTargetFrame, "BOTTOMLEFT")
	LunaTargetTargetFrame.borders["BOTTOM"]:SetHeight(1)
	
	LunaTargetTargetFrame.borders["LEFT"] = LunaTargetTargetFrame:CreateTexture("PlayerLeftBorder", "ARTWORK")
	LunaTargetTargetFrame.borders["LEFT"]:SetPoint("TOPRIGHT", LunaTargetTargetFrame, "TOPLEFT", 0, 1)
	LunaTargetTargetFrame.borders["LEFT"]:SetWidth(1)
	
	LunaTargetTargetFrame.borders["RIGHT"] = LunaTargetTargetFrame:CreateTexture("PlayerBottomBorder", "ARTWORK")
	LunaTargetTargetFrame.borders["RIGHT"]:SetPoint("TOPLEFT", LunaTargetTargetFrame, "TOPRIGHT", 0, 1)
	LunaTargetTargetFrame.borders["RIGHT"]:SetWidth(1)
	
	LunaTargetTargetFrame.SetBorder = function(r,g,b,a)
									if not r or not g or not b then
										LunaTargetTargetFrame.borders["TOP"]:SetTexture(0,0,0,0)
										LunaTargetTargetFrame.borders["BOTTOM"]:SetTexture(0,0,0,0)
										LunaTargetTargetFrame.borders["LEFT"]:SetTexture(0,0,0,0)
										LunaTargetTargetFrame.borders["RIGHT"]:SetTexture(0,0,0,0)
									else
										LunaTargetTargetFrame.borders["TOP"]:SetTexture(r,g,b,a)
										LunaTargetTargetFrame.borders["BOTTOM"]:SetTexture(r,g,b,a)
										LunaTargetTargetFrame.borders["LEFT"]:SetTexture(r,g,b,a)
										LunaTargetTargetFrame.borders["RIGHT"]:SetTexture(r,g,b,a)
									end
								end
	
	local barsettings = {}
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
		barsettings[v[1]] = {}
		barsettings[v[1]][1] = v[4]
		barsettings[v[1]][2] = v[5]
	end
	
	LunaTargetTargetFrame.bars = {}

	-- Portrait
	LunaTargetTargetFrame.bars["Portrait"] = CreateFrame("Frame", nil, LunaTargetTargetFrame)
	LunaTargetTargetFrame.bars["Portrait"].texture = LunaTargetTargetFrame.bars["Portrait"]:CreateTexture("TargetTargetPortrait", "ARTWORK")
	LunaTargetTargetFrame.bars["Portrait"].texture:SetAllPoints(LunaTargetTargetFrame.bars["Portrait"])
	LunaTargetTargetFrame.bars["Portrait"].model = CreateFrame("PlayerModel", nil, LunaTargetTargetFrame)
	LunaTargetTargetFrame.bars["Portrait"].model:SetPoint("TOPLEFT", LunaTargetTargetFrame.bars["Portrait"], "TOPLEFT")
	LunaTargetTargetFrame.bars["Portrait"].model:SetScript("OnShow",function() this:SetCamera(0) end)
	
	-- Healthbar
	local hp = CreateFrame("StatusBar", nil, LunaTargetTargetFrame)
	LunaTargetTargetFrame.bars["Healthbar"] = hp

	-- Healthbar background
	local hpbg = LunaTargetTargetFrame.bars["Healthbar"]:CreateTexture(nil, "BORDER")
	hpbg:SetAllPoints(LunaTargetTargetFrame.bars["Healthbar"])
	hpbg:SetTexture(.25,.25,.25,.25)
	LunaTargetTargetFrame.bars["Healthbar"].hpbg = hpbg

	-- Healthbar text
	LunaTargetTargetFrame.bars["Healthbar"].righttext = LunaTargetTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetFrame.bars["Healthbar"])
	LunaTargetTargetFrame.bars["Healthbar"].righttext:SetPoint("RIGHT", -2, 0)
	LunaTargetTargetFrame.bars["Healthbar"].righttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetTargetFrame.bars["Healthbar"].righttext:SetShadowColor(0, 0, 0)
	LunaTargetTargetFrame.bars["Healthbar"].righttext:SetShadowOffset(0.8, -0.8)
	LunaTargetTargetFrame.bars["Healthbar"].righttext:SetJustifyH("RIGHT")
	LunaTargetTargetFrame.bars["Healthbar"].righttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaTargetTargetFrame.bars["Healthbar"].righttext, "targettarget", barsettings["Healthbar"][2] or LunaOptions.defaultTags["Healthbar"][2])

	LunaTargetTargetFrame.bars["Healthbar"].lefttext = LunaTargetTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetFrame.bars["Healthbar"])
	LunaTargetTargetFrame.bars["Healthbar"].lefttext:SetPoint("LEFT", 2, 0)
	LunaTargetTargetFrame.bars["Healthbar"].lefttext:SetJustifyH("LEFT")
	LunaTargetTargetFrame.bars["Healthbar"].lefttext:SetJustifyV("MIDDLE")
	LunaTargetTargetFrame.bars["Healthbar"].lefttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetTargetFrame.bars["Healthbar"].lefttext:SetShadowColor(0, 0, 0)
	LunaTargetTargetFrame.bars["Healthbar"].lefttext:SetShadowOffset(0.8, -0.8)
	LunaUnitFrames:RegisterFontstring(LunaTargetTargetFrame.bars["Healthbar"].lefttext, "targettarget", barsettings["Healthbar"][1] or LunaOptions.defaultTags["Healthbar"][1])

	local icon = LunaTargetTargetFrame.bars["Healthbar"]:CreateTexture(nil, "OVERLAY")
	icon:SetHeight(20)
	icon:SetWidth(20)
	icon:SetPoint("CENTER", LunaTargetTargetFrame.bars["Healthbar"], "TOP", 0, 0)
	icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	LunaTargetTargetFrame.RaidIcon = icon
	
		-- Manabar
	local pp = CreateFrame("StatusBar", nil, LunaTargetTargetFrame)
	LunaTargetTargetFrame.bars["Powerbar"] = pp
	
	-- Manabar background
	local ppbg = LunaTargetTargetFrame.bars["Powerbar"]:CreateTexture(nil, "BORDER")
	ppbg:SetAllPoints(LunaTargetTargetFrame.bars["Powerbar"])
	ppbg:SetTexture(.25,.25,.25,.25)
	LunaTargetTargetFrame.bars["Powerbar"].ppbg = ppbg

	LunaTargetTargetFrame.AuraAnchor = CreateFrame("Frame", nil, LunaTargetTargetFrame)
	
	LunaTargetTargetFrame.Buffs = {}

	LunaTargetTargetFrame.Buffs[1] = CreateFrame("Button", nil, LunaTargetTargetFrame.AuraAnchor)
	LunaTargetTargetFrame.Buffs[1].texturepath = UnitBuff("targettarget",1)
	LunaTargetTargetFrame.Buffs[1].id = 1
	LunaTargetTargetFrame.Buffs[1]:SetNormalTexture(LunaTargetTargetFrame.Buffs[1].texturepath)
	LunaTargetTargetFrame.Buffs[1]:SetScript("OnEnter", Luna_TargetTarget_SetBuffTooltip)
	LunaTargetTargetFrame.Buffs[1]:SetScript("OnLeave", Luna_TargetTarget_SetBuffTooltipLeave)

	LunaTargetTargetFrame.Buffs[1].stacks = LunaTargetTargetFrame.Buffs[1]:CreateFontString(nil, "OVERLAY", LunaTargetTargetFrame.Buffs[1])
	LunaTargetTargetFrame.Buffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaTargetTargetFrame.Buffs[1], 0, 0)
	LunaTargetTargetFrame.Buffs[1].stacks:SetJustifyH("LEFT")
	LunaTargetTargetFrame.Buffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaTargetTargetFrame.Buffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaTargetTargetFrame.Buffs[1].stacks:SetTextColor(1,1,1)
	
	for i=2, 16 do
		LunaTargetTargetFrame.Buffs[i] = CreateFrame("Button", nil, LunaTargetTargetFrame.AuraAnchor)
		LunaTargetTargetFrame.Buffs[i].texturepath = UnitBuff("targettarget",i)
		LunaTargetTargetFrame.Buffs[i].id = i
		LunaTargetTargetFrame.Buffs[i]:SetNormalTexture(LunaTargetTargetFrame.Buffs[i].texturepath)
		LunaTargetTargetFrame.Buffs[i]:SetScript("OnEnter", Luna_TargetTarget_SetBuffTooltip)
		LunaTargetTargetFrame.Buffs[i]:SetScript("OnLeave", Luna_TargetTarget_SetBuffTooltipLeave)
		
		LunaTargetTargetFrame.Buffs[i].stacks = LunaTargetTargetFrame.Buffs[i]:CreateFontString(nil, "OVERLAY", LunaTargetTargetFrame.Buffs[i])
		LunaTargetTargetFrame.Buffs[i].stacks:SetPoint("BOTTOMRIGHT", LunaTargetTargetFrame.Buffs[i], 0, 0)
		LunaTargetTargetFrame.Buffs[i].stacks:SetJustifyH("LEFT")
		LunaTargetTargetFrame.Buffs[i].stacks:SetShadowColor(0, 0, 0)
		LunaTargetTargetFrame.Buffs[i].stacks:SetShadowOffset(0.8, -0.8)
		LunaTargetTargetFrame.Buffs[i].stacks:SetTextColor(1,1,1)
	end

	LunaTargetTargetFrame.Debuffs = {}

	LunaTargetTargetFrame.Debuffs[1] = CreateFrame("Button", nil, LunaTargetTargetFrame.AuraAnchor)
	LunaTargetTargetFrame.Debuffs[1].texturepath = UnitDebuff("targettarget",1)
	LunaTargetTargetFrame.Debuffs[1].id = 17
	LunaTargetTargetFrame.Debuffs[1]:SetNormalTexture(LunaTargetTargetFrame.Debuffs[1].texturepath)
	LunaTargetTargetFrame.Debuffs[1]:SetScript("OnEnter", Luna_TargetTarget_SetBuffTooltip)
	LunaTargetTargetFrame.Debuffs[1]:SetScript("OnLeave", Luna_TargetTarget_SetBuffTooltipLeave)

	LunaTargetTargetFrame.Debuffs[1].stacks = LunaTargetTargetFrame.Debuffs[1]:CreateFontString(nil, "OVERLAY", LunaTargetTargetFrame.Debuffs[1])
	LunaTargetTargetFrame.Debuffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaTargetTargetFrame.Debuffs[1], 0, 0)
	LunaTargetTargetFrame.Debuffs[1].stacks:SetJustifyH("LEFT")
	LunaTargetTargetFrame.Debuffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaTargetTargetFrame.Debuffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaTargetTargetFrame.Debuffs[1].stacks:SetTextColor(1,1,1)

	for i=2, 16 do
		LunaTargetTargetFrame.Debuffs[i] = CreateFrame("Button", nil, LunaTargetTargetFrame.AuraAnchor)
		LunaTargetTargetFrame.Debuffs[i].texturepath = UnitDebuff("targettarget",i)
		LunaTargetTargetFrame.Debuffs[i].id = i+16
		LunaTargetTargetFrame.Debuffs[i]:SetNormalTexture(LunaTargetTargetFrame.Debuffs[i].texturepath)
		LunaTargetTargetFrame.Debuffs[i]:SetScript("OnEnter", Luna_TargetTarget_SetBuffTooltip)
		LunaTargetTargetFrame.Debuffs[i]:SetScript("OnLeave", Luna_TargetTarget_SetBuffTooltipLeave)
		
		LunaTargetTargetFrame.Debuffs[i].stacks = LunaTargetTargetFrame.Debuffs[i]:CreateFontString(nil, "OVERLAY", LunaTargetTargetFrame.Debuffs[i])
		LunaTargetTargetFrame.Debuffs[i].stacks:SetPoint("BOTTOMRIGHT", LunaTargetTargetFrame.Debuffs[i], 0, 0)
		LunaTargetTargetFrame.Debuffs[i].stacks:SetJustifyH("LEFT")
		LunaTargetTargetFrame.Debuffs[i].stacks:SetShadowColor(0, 0, 0)
		LunaTargetTargetFrame.Debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
		LunaTargetTargetFrame.Debuffs[i].stacks:SetTextColor(1,1,1)
	end
	
	LunaTargetTargetFrame.bars["Powerbar"].righttext = LunaTargetTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetFrame.bars["Powerbar"])
	LunaTargetTargetFrame.bars["Powerbar"].righttext:SetPoint("RIGHT", -2, 0)
	LunaTargetTargetFrame.bars["Powerbar"].righttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetTargetFrame.bars["Powerbar"].righttext:SetShadowColor(0, 0, 0)
	LunaTargetTargetFrame.bars["Powerbar"].righttext:SetShadowOffset(0.8, -0.8)
	LunaTargetTargetFrame.bars["Powerbar"].righttext:SetJustifyH("RIGHT")
	LunaTargetTargetFrame.bars["Powerbar"].righttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaTargetTargetFrame.bars["Powerbar"].righttext, "targettarget", barsettings["Powerbar"][2] or LunaOptions.defaultTags["Powerbar"][2])
	
	LunaTargetTargetFrame.bars["Powerbar"].lefttext = LunaTargetTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetFrame.bars["Powerbar"])
	LunaTargetTargetFrame.bars["Powerbar"].lefttext:SetPoint("LEFT", 2, 0)
	LunaTargetTargetFrame.bars["Powerbar"].lefttext:SetJustifyH("LEFT")
	LunaTargetTargetFrame.bars["Powerbar"].lefttext:SetJustifyV("MIDDLE")
	LunaTargetTargetFrame.bars["Powerbar"].lefttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetTargetFrame.bars["Powerbar"].lefttext:SetShadowColor(0, 0, 0)
	LunaTargetTargetFrame.bars["Powerbar"].lefttext:SetShadowOffset(0.8, -0.8)
	LunaUnitFrames:RegisterFontstring(LunaTargetTargetFrame.bars["Powerbar"].lefttext, "targettarget", barsettings["Powerbar"][1] or LunaOptions.defaultTags["Powerbar"][1])
	
	LunaTargetTargetFrame:Hide()
	
	LunaTargetTargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	LunaTargetTargetFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	
	LunaTargetTargetFrame:SetScript("OnClick", Luna_OnClick)
	LunaTargetTargetFrame:SetScript("OnEvent", Luna_TargetTarget_OnEvent)
	tot:SetScript("OnUpdate", Luna_TargetTarget_OnUpdate)
	
	LunaTargetTargetFrame.dropdown = CreateFrame("Frame", "LunaUnitDropDownMenuTargetTarget", UIParent, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(LunaTargetTargetFrame.dropdown, Luna_TargetTargetDropDown_Initialize, "MENU")
	
	LunaTargetTargetFrame.AdjustBars = function()
		local frameHeight = LunaTargetTargetFrame:GetHeight()
		local frameWidth = LunaTargetTargetFrame:GetWidth()
		local anchor
		local totalWeight = 0
		local gaps = -1
		local textheights = {}
		local textbalance = {}
		anchor = {"TOPLEFT", LunaTargetTargetFrame, "TOPLEFT"}
		if LunaOptions.frames["LunaTargetTargetFrame"].portrait > 1 then    -- We have a square portrait
			frameWidth = (LunaTargetTargetFrame:GetWidth()-frameHeight)
			LunaTargetTargetFrame.bars["Portrait"]:ClearAllPoints()
			LunaTargetTargetFrame.bars["Portrait"]:SetHeight(frameHeight)
			LunaTargetTargetFrame.bars["Portrait"]:SetWidth(frameHeight)
			if LunaOptions.fliptargettarget then
				LunaTargetTargetFrame.bars["Portrait"]:SetPoint("TOPRIGHT", LunaTargetTargetFrame, "TOPRIGHT")
				anchor = {"TOPRIGHT", LunaTargetTargetFrame.bars["Portrait"], "TOPLEFT"}
			else
				LunaTargetTargetFrame.bars["Portrait"]:SetPoint("TOPLEFT", LunaTargetTargetFrame, "TOPLEFT")
				anchor = {"TOPLEFT", LunaTargetTargetFrame.bars["Portrait"], "TOPRIGHT"}
			end
		else
			frameWidth = LunaTargetTargetFrame:GetWidth()  -- We have a Bar-Portrait or no portrait
			anchor = {"TOPLEFT", LunaTargetTargetFrame, "TOPLEFT"}
		end
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
			textheights[v[1]] = v[3] or 0.45
			textbalance[v[1]] = v[6] or 0.5
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
		LunaTargetTargetFrame.bars["Portrait"].model:SetHeight(LunaTargetTargetFrame.bars["Portrait"]:GetHeight()+1)
		LunaTargetTargetFrame.bars["Portrait"].model:SetWidth(LunaTargetTargetFrame.bars["Portrait"]:GetWidth())
		local healthheight = (LunaTargetTargetFrame.bars["Healthbar"]:GetHeight()*textheights["Healthbar"])
		LunaTargetTargetFrame.bars["Healthbar"].righttext:SetFont(LunaOptions.font, healthheight)
		LunaTargetTargetFrame.bars["Healthbar"].righttext:SetHeight(LunaTargetTargetFrame.bars["Healthbar"]:GetHeight())
		LunaTargetTargetFrame.bars["Healthbar"].righttext:SetWidth(LunaTargetTargetFrame.bars["Healthbar"]:GetWidth()*(1-textbalance["Healthbar"]))
		LunaTargetTargetFrame.bars["Healthbar"].lefttext:SetFont(LunaOptions.font, healthheight)
		LunaTargetTargetFrame.bars["Healthbar"].lefttext:SetHeight(LunaTargetTargetFrame.bars["Healthbar"]:GetHeight())
		LunaTargetTargetFrame.bars["Healthbar"].lefttext:SetWidth(LunaTargetTargetFrame.bars["Healthbar"]:GetWidth()*textbalance["Healthbar"])

		local powerheight = (LunaTargetTargetFrame.bars["Powerbar"]:GetHeight()*textheights["Powerbar"])
		LunaTargetTargetFrame.bars["Powerbar"].righttext:SetFont(LunaOptions.font, powerheight)
		LunaTargetTargetFrame.bars["Powerbar"].righttext:SetHeight(LunaTargetTargetFrame.bars["Powerbar"]:GetHeight())
		LunaTargetTargetFrame.bars["Powerbar"].righttext:SetWidth(LunaTargetTargetFrame.bars["Powerbar"]:GetWidth()*(1-textbalance["Powerbar"]))
		LunaTargetTargetFrame.bars["Powerbar"].lefttext:SetFont(LunaOptions.font, powerheight)
		LunaTargetTargetFrame.bars["Powerbar"].lefttext:SetHeight(LunaTargetTargetFrame.bars["Powerbar"]:GetHeight())
		LunaTargetTargetFrame.bars["Powerbar"].lefttext:SetWidth(LunaTargetTargetFrame.bars["Powerbar"]:GetWidth()*textbalance["Powerbar"])
	end
	LunaTargetTargetFrame.UpdateBuffSize = function ()
		local buffcount = LunaOptions.frames["LunaTargetTargetFrame"].BuffInRow or 16
		if LunaOptions.frames["LunaTargetTargetFrame"].ShowBuffs == 1 then
			for i=1, 16 do
				LunaTargetTargetFrame.Buffs[i]:Hide()
				LunaTargetTargetFrame.Debuffs[i]:Hide()
			end
		elseif LunaOptions.frames["LunaTargetTargetFrame"].ShowBuffs == 2 then
			local buffsize = ((LunaTargetTargetFrame:GetWidth()-(buffcount-1))/buffcount)
			LunaTargetTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetTargetFrame.AuraAnchor:SetPoint("BOTTOMLEFT", LunaTargetTargetFrame, "TOPLEFT", -1, 3)
			LunaTargetTargetFrame.AuraAnchor:SetWidth(LunaTargetTargetFrame:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetTargetFrame.Buffs[buffid]:SetPoint("BOTTOMLEFT", LunaTargetTargetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaTargetTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetTargetFrame.Debuffs[buffid]:SetPoint("BOTTOMLEFT", LunaTargetTargetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaTargetTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
		elseif LunaOptions.frames["LunaTargetTargetFrame"].ShowBuffs == 3 then
			local buffsize = ((LunaTargetTargetFrame:GetWidth()-(buffcount-1))/buffcount)
			LunaTargetTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetTargetFrame.AuraAnchor:SetWidth(LunaTargetTargetFrame:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetTargetFrame.Buffs[buffid]:SetPoint("TOPLEFT", LunaTargetTargetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetTargetFrame.Debuffs[buffid]:SetPoint("TOPLEFT", LunaTargetTargetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaTargetTargetFrame.AuraAnchor:SetPoint("TOPLEFT", LunaTargetTargetFrame, "BOTTOMLEFT", -1, -3)
		elseif LunaOptions.frames["LunaTargetTargetFrame"].ShowBuffs == 4 then
			local buffsize = (((LunaTargetTargetFrame:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaTargetTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetTargetFrame.AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetTargetFrame.Buffs[buffid]:SetPoint("TOPRIGHT", LunaTargetTargetFrame.AuraAnchor, "TOPRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaTargetTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetTargetFrame.Debuffs[buffid]:SetPoint("TOPRIGHT", LunaTargetTargetFrame.AuraAnchor, "BOTTOMRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaTargetTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaTargetTargetFrame.AuraAnchor:SetPoint("TOPRIGHT", LunaTargetTargetFrame, "TOPLEFT", -3, 0)
		else
			local buffsize = (((LunaTargetTargetFrame:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaTargetTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetTargetFrame.AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetTargetFrame.Buffs[buffid]:SetPoint("TOPLEFT", LunaTargetTargetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetTargetFrame.Debuffs[buffid]:SetPoint("TOPLEFT", LunaTargetTargetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaTargetTargetFrame.AuraAnchor:SetPoint("TOPLEFT", LunaTargetTargetFrame, "TOPRIGHT", 3, 0)
		end
	end
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
		if v[2] == 0 then
			LunaTargetTargetFrame.bars[v[1]]:Hide()
		end
	end
	LunaTargetTargetFrame.UpdateBuffSize()
	LunaTargetTargetFrame.AdjustBars()	
end

function LunaUnitFrames:ConvertTargetTargetPortrait()
	if LunaOptions.frames["LunaTargetTargetFrame"].portrait == 1 then
		table.insert(LunaOptions.frames["LunaTargetTargetFrame"].bars, 1, {"Portrait", 4})
	else
		for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
			if v[1] == "Portrait" then
				table.remove(LunaOptions.frames["LunaTargetTargetFrame"].bars, k)
			end
		end
	end
	UIDropDownMenu_SetText("Healthbar", LunaOptionsFrame.pages[4].BarSelect)
	LunaOptionsFrame.pages[4].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaTargetTargetFrame"].bars))
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
		if v[1] == "Healthbar" then
			LunaOptionsFrame.pages[4].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[4].barorder:SetValue(k)
			LunaOptionsFrame.pages[4].lefttext:SetText(v[4] or LunaOptions.defaultTags["Healthbar"][1])
			LunaOptionsFrame.pages[4].righttext:SetText(v[5] or LunaOptions.defaultTags["Healthbar"][2])
			LunaOptionsFrame.pages[4].textsize:SetValue(v[3] or 0.45)
			break
		end
	end
	LunaTargetTargetFrame.AdjustBars()
	LunaUnitFrames:UpdateTargetTargetFrame()
end

local function TargetTargetPortraitUpdate(unit)
	if (not validunits[arg1] or not UnitIsUnit(arg1,"targettarget")) and not unit then
		return
	end
	local portrait = LunaTargetTargetFrame.bars["Portrait"]
	if LunaOptions.PortraitMode == 3 and UnitIsPlayer("targettarget") then
		local _,class = UnitClass("targettarget")
		portrait.model:Hide()
		portrait.texture:Show()
		portrait.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		portrait.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
	elseif LunaOptions.PortraitMode == 2 or (LunaOptions.PortraitMode == 3 and (LunaOptions.PortraitFallback == 3 or LunaOptions.PortraitFallback == 2)) then
		if LunaOptions.frames["LunaTargetTargetFrame"].portrait > 1 then
			portrait.model:Hide()
			portrait.texture:Show()
			SetPortraitTexture(portrait.texture, "targettarget")
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
		if(not UnitExists("targettarget") or not UnitIsConnected("targettarget") or not UnitIsVisible("targettarget")) then
			if LunaOptions.PortraitFallback == 3 and UnitIsPlayer("targettarget") then
				portrait.model:Hide()
				portrait.texture:Show()
				local _,class = UnitClass("targettarget")
				portrait.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
				portrait.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
			elseif LunaOptions.PortraitFallback == 2 or LunaOptions.PortraitFallback == 3 then
				if LunaOptions.frames["LunaTargetTargetFrame"].portrait > 1 then
					portrait.model:Hide()
					portrait.texture:Show()
					SetPortraitTexture(portrait.texture, "targettarget")
					portrait.texture:SetTexCoord(.1, .90, .1, .90)
				else
					portrait.model:Hide()
					portrait.texture:Show()
					SetPortraitTexture(portrait.texture, "targettarget")
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
			portrait.model:SetUnit("targettarget")
			portrait.model:SetCamera(0)
		end
	end
end

function Luna_TargetTarget_Events:PLAYER_TARGET_CHANGED()
	LunaUnitFrames:UpdateTargetTargetFrame()
	LunaUnitFrames:UpdateTargetTargetTargetFrame()
end

function LunaUnitFrames:UpdateTargetTargetFrame()
	if UnitName(LunaTargetTargetFrame.unit) ~= LunaTargetTargetFrame.name or LunaTargetTargetFrame.isPlayer ~= UnitIsPlayer(LunaTargetTargetFrame.unit) then
		LunaTargetTargetFrame.name = UnitName(LunaTargetTargetFrame.unit)
		LunaTargetTargetFrame.isPlayer = UnitIsPlayer(LunaTargetTargetFrame.unit)
		TargetTargetPortraitUpdate("targettarget")
	end
	local Health, maxHealth
	if MobHealth3 then
		Health, maxHealth = MobHealth3:GetUnitHealth(LunaTargetTargetFrame.unit)
	else
		Health = UnitHealth(LunaTargetTargetFrame.unit)
		maxHealth = UnitHealthMax(LunaTargetTargetFrame.unit)
	end
	if LunaOptions.frames["LunaTargetTargetFrame"].enabled == 1 and UnitExists("targettarget") then
		LunaTargetTargetFrame:Show()
	else
		LunaTargetTargetFrame:Hide()
		return
	end
	local _,class = UnitClass("targettarget")
	if UnitIsPlayer("targettarget") then
		local color
		if LunaOptions.hbarcolor then
			color = LunaOptions.ClassColors[class]
		elseif UnitIsEnemy("player","targettarget") then
			color = LunaOptions.MiscColors["hostile"]
		else
			color = LunaUnitFrames:GetHealthColor("targettarget")
		end
		LunaTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
		LunaTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
	elseif UnitIsTapped("targettarget") and not UnitIsTappedByPlayer("targettarget") then
		LunaTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.5, 0.5, 0.5)
		LunaTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.5, 0.5, 0.5, 0.25)
	else
		reaction = UnitReaction("targettarget", "player")
		if reaction and reaction < 4 then
			LunaTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(unpack(LunaOptions.MiscColors["hostile"]))
			LunaTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(unpack(LunaOptions.MiscColors["hostile"]), 0.25)
		elseif reaction and reaction > 4 then
			LunaTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(unpack(LunaOptions.MiscColors["friendly"]))
			LunaTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(unpack(LunaOptions.MiscColors["friendly"]), 0.25)
		else
			LunaTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(unpack(LunaOptions.MiscColors["neutral"]))
			LunaTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(unpack(LunaOptions.MiscColors["neutral"]), 0.25)
		end
	end
	if not UnitIsConnected(LunaTargetTargetFrame.unit) then
		LunaTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetFrame.bars["Healthbar"]:SetValue(0)
			
		LunaTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Powerbar"]:SetValue(0)
	elseif Health < 1 then
		LunaTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetFrame.bars["Healthbar"]:SetValue(0)
			
		LunaTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Powerbar"]:SetValue(0)
	else
		LunaTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetFrame.bars["Healthbar"]:SetValue(Health)
			
		LunaTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Powerbar"]:SetValue(UnitMana(LunaTargetTargetFrame.unit))
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
	else
		LunaTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		LunaTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
	end
	local index = GetRaidTargetIndex("targettarget")
	if (index) then
		SetRaidTargetIconTexture(LunaTargetTargetFrame.RaidIcon, index)
		LunaTargetTargetFrame.RaidIcon:Show()
	else
		LunaTargetTargetFrame.RaidIcon:Hide()
	end
	local _,_,dtype = UnitDebuff("targettarget", 1, 1)
	if dtype and LunaOptions.HighlightDebuffs and UnitCanAssist("player", "targettarget") then
		LunaTargetTargetFrame:SetBackdropColor(unpack(LunaOptions.DebuffTypeColor[dtype],1))
	else
		LunaTargetTargetFrame:SetBackdropColor(0,0,0,1)
	end
	if LunaOptions.frames["LunaTargetTargetFrame"].ShowBuffs ~= 1 then
		local pos
		for i=1, 16 do
			local path, stacks = UnitBuff("targettarget",i)
			LunaTargetTargetFrame.Buffs[i].texturepath = path
			if LunaTargetTargetFrame.Buffs[i].texturepath then
				LunaTargetTargetFrame.Buffs[i]:EnableMouse(1)
				LunaTargetTargetFrame.Buffs[i]:Show()
				if stacks > 1 then
					LunaTargetTargetFrame.Buffs[i].stacks:SetText(stacks)
					LunaTargetTargetFrame.Buffs[i].stacks:Show()
				else
					LunaTargetTargetFrame.Buffs[i].stacks:Hide()
				end
			else
				LunaTargetTargetFrame.Buffs[i]:EnableMouse(0)
				LunaTargetTargetFrame.Buffs[i]:Hide()
				if not pos then
					pos = i
				end
			end
			LunaTargetTargetFrame.Buffs[i]:SetNormalTexture(LunaTargetTargetFrame.Buffs[i].texturepath)
		end
		if not pos then
			pos = 17
		end
		LunaTargetTargetFrame.AuraAnchor:SetHeight((LunaTargetTargetFrame.Buffs[1]:GetHeight()*math.ceil((pos-1)/(LunaOptions.frames["LunaTargetTargetFrame"].BuffInRow or 16)))+(math.ceil((pos-1)/(LunaOptions.frames["LunaTargetTargetFrame"].BuffInRow or 16))-1)+1.1)
		for i=1, 16 do
			local path, stacks = UnitDebuff("targettarget",i)
			LunaTargetTargetFrame.Debuffs[i].texturepath = path
			if LunaTargetTargetFrame.Debuffs[i].texturepath then
				LunaTargetTargetFrame.Debuffs[i]:EnableMouse(1)
				LunaTargetTargetFrame.Debuffs[i]:Show()
				if stacks > 1 then
					LunaTargetTargetFrame.Debuffs[i].stacks:SetText(stacks)
					LunaTargetTargetFrame.Debuffs[i].stacks:Show()
				else
					LunaTargetTargetFrame.Debuffs[i].stacks:Hide()
				end
			else
				LunaTargetTargetFrame.Debuffs[i]:EnableMouse(0)
				LunaTargetTargetFrame.Debuffs[i]:Hide()
			end
			LunaTargetTargetFrame.Debuffs[i]:SetNormalTexture(LunaTargetTargetFrame.Debuffs[i].texturepath)
		end
	end
	LunaUnitFrames:UpdateTags("targettarget")
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
	LunaTargetTargetTargetFrame:SetFrameStrata("BACKGROUND")

	LunaTargetTargetTargetFrame.borders = {}
	
	LunaTargetTargetTargetFrame.borders["TOP"] = LunaTargetTargetTargetFrame:CreateTexture("PlayerTopBorder", "ARTWORK")
	LunaTargetTargetTargetFrame.borders["TOP"]:SetPoint("BOTTOMLEFT", LunaTargetTargetTargetFrame, "TOPLEFT")
	LunaTargetTargetTargetFrame.borders["TOP"]:SetHeight(1)
	
	LunaTargetTargetTargetFrame.borders["BOTTOM"] = LunaTargetTargetTargetFrame:CreateTexture("PlayerBottomBorder", "ARTWORK")
	LunaTargetTargetTargetFrame.borders["BOTTOM"]:SetPoint("TOPLEFT", LunaTargetTargetTargetFrame, "BOTTOMLEFT")
	LunaTargetTargetTargetFrame.borders["BOTTOM"]:SetHeight(1)
	
	LunaTargetTargetTargetFrame.borders["LEFT"] = LunaTargetTargetTargetFrame:CreateTexture("PlayerLeftBorder", "ARTWORK")
	LunaTargetTargetTargetFrame.borders["LEFT"]:SetPoint("TOPRIGHT", LunaTargetTargetTargetFrame, "TOPLEFT", 0, 1)
	LunaTargetTargetTargetFrame.borders["LEFT"]:SetWidth(1)
	
	LunaTargetTargetTargetFrame.borders["RIGHT"] = LunaTargetTargetTargetFrame:CreateTexture("PlayerBottomBorder", "ARTWORK")
	LunaTargetTargetTargetFrame.borders["RIGHT"]:SetPoint("TOPLEFT", LunaTargetTargetTargetFrame, "TOPRIGHT", 0, 1)
	LunaTargetTargetTargetFrame.borders["RIGHT"]:SetWidth(1)
	
	LunaTargetTargetTargetFrame.SetBorder = function(r,g,b,a)
									if not r or not g or not b then
										LunaTargetTargetTargetFrame.borders["TOP"]:SetTexture(0,0,0,0)
										LunaTargetTargetTargetFrame.borders["BOTTOM"]:SetTexture(0,0,0,0)
										LunaTargetTargetTargetFrame.borders["LEFT"]:SetTexture(0,0,0,0)
										LunaTargetTargetTargetFrame.borders["RIGHT"]:SetTexture(0,0,0,0)
									else
										LunaTargetTargetTargetFrame.borders["TOP"]:SetTexture(r,g,b,a)
										LunaTargetTargetTargetFrame.borders["BOTTOM"]:SetTexture(r,g,b,a)
										LunaTargetTargetTargetFrame.borders["LEFT"]:SetTexture(r,g,b,a)
										LunaTargetTargetTargetFrame.borders["RIGHT"]:SetTexture(r,g,b,a)
									end
								end
	
	local barsettings = {}
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
		barsettings[v[1]] = {}
		barsettings[v[1]][1] = v[4]
		barsettings[v[1]][2] = v[5]
	end
	
	LunaTargetTargetTargetFrame.bars = {}
	
	-- Portrait
	LunaTargetTargetTargetFrame.bars["Portrait"] = CreateFrame("Frame", nil, LunaTargetTargetTargetFrame)
	LunaTargetTargetTargetFrame.bars["Portrait"].texture = LunaTargetTargetTargetFrame.bars["Portrait"]:CreateTexture("TargetTargetPortrait", "ARTWORK")
	LunaTargetTargetTargetFrame.bars["Portrait"].texture:SetAllPoints(LunaTargetTargetTargetFrame.bars["Portrait"])
	LunaTargetTargetTargetFrame.bars["Portrait"].model = CreateFrame("PlayerModel", nil, LunaTargetTargetTargetFrame)
	LunaTargetTargetTargetFrame.bars["Portrait"].model:SetPoint("TOPLEFT", LunaTargetTargetTargetFrame.bars["Portrait"], "TOPLEFT")
	LunaTargetTargetTargetFrame.bars["Portrait"].model:SetScript("OnShow",function() this:SetCamera(0) end)
	
	-- Healthbar
	local hp = CreateFrame("StatusBar", nil, LunaTargetTargetTargetFrame)
	LunaTargetTargetTargetFrame.bars["Healthbar"] = hp

	-- Healthbar background
	local hpbg = LunaTargetTargetTargetFrame.bars["Healthbar"]:CreateTexture(nil, "BORDER")
	hpbg:SetAllPoints(LunaTargetTargetTargetFrame.bars["Healthbar"])
	hpbg:SetTexture(.25,.25,.25,.25)
	LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg = hpbg

	-- Healthbar text
	LunaTargetTargetTargetFrame.bars["Healthbar"].righttext = LunaTargetTargetTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetTargetFrame.bars["Healthbar"])
	LunaTargetTargetTargetFrame.bars["Healthbar"].righttext:SetPoint("RIGHT", -2, 0)
	LunaTargetTargetTargetFrame.bars["Healthbar"].righttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetTargetTargetFrame.bars["Healthbar"].righttext:SetShadowColor(0, 0, 0)
	LunaTargetTargetTargetFrame.bars["Healthbar"].righttext:SetShadowOffset(0.8, -0.8)
	LunaTargetTargetTargetFrame.bars["Healthbar"].righttext:SetJustifyH("RIGHT")
	LunaTargetTargetTargetFrame.bars["Healthbar"].righttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaTargetTargetTargetFrame.bars["Healthbar"].righttext, "targettargettarget", barsettings["Healthbar"][2] or LunaOptions.defaultTags["Healthbar"][2])

	LunaTargetTargetTargetFrame.bars["Healthbar"].lefttext = LunaTargetTargetTargetFrame.bars["Healthbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetTargetFrame.bars["Healthbar"])
	LunaTargetTargetTargetFrame.bars["Healthbar"].lefttext:SetPoint("LEFT", 2, 0)
	LunaTargetTargetTargetFrame.bars["Healthbar"].lefttext:SetJustifyH("LEFT")
	LunaTargetTargetTargetFrame.bars["Healthbar"].lefttext:SetJustifyV("MIDDLE")
	LunaTargetTargetTargetFrame.bars["Healthbar"].lefttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetTargetTargetFrame.bars["Healthbar"].lefttext:SetShadowColor(0, 0, 0)
	LunaTargetTargetTargetFrame.bars["Healthbar"].lefttext:SetShadowOffset(0.8, -0.8)
	LunaUnitFrames:RegisterFontstring(LunaTargetTargetTargetFrame.bars["Healthbar"].lefttext, "targettargettarget", barsettings["Healthbar"][1] or LunaOptions.defaultTags["Healthbar"][1])

	local icon = LunaTargetTargetTargetFrame.bars["Healthbar"]:CreateTexture(nil, "OVERLAY")
	icon:SetHeight(20)
	icon:SetWidth(20)
	icon:SetPoint("CENTER", LunaTargetTargetTargetFrame.bars["Healthbar"], "TOP", 0, 0)
	icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	LunaTargetTargetTargetFrame.RaidIcon = icon
	
		-- Manabar
	local pp = CreateFrame("StatusBar", nil, LunaTargetTargetTargetFrame)
	LunaTargetTargetTargetFrame.bars["Powerbar"] = pp
	
	-- Manabar background
	local ppbg = LunaTargetTargetTargetFrame.bars["Powerbar"]:CreateTexture(nil, "BORDER")
	ppbg:SetAllPoints(LunaTargetTargetTargetFrame.bars["Powerbar"])
	ppbg:SetTexture(.25,.25,.25,.25)
	LunaTargetTargetTargetFrame.bars["Powerbar"].ppbg = ppbg

	LunaTargetTargetTargetFrame.AuraAnchor = CreateFrame("Frame", nil, LunaTargetTargetTargetFrame)
	
	LunaTargetTargetTargetFrame.Buffs = {}

	LunaTargetTargetTargetFrame.Buffs[1] = CreateFrame("Button", nil, LunaTargetTargetTargetFrame.AuraAnchor)
	LunaTargetTargetTargetFrame.Buffs[1].texturepath = UnitBuff("targettargettarget",1)
	LunaTargetTargetTargetFrame.Buffs[1].id = 1
	LunaTargetTargetTargetFrame.Buffs[1]:SetNormalTexture(LunaTargetTargetTargetFrame.Buffs[1].texturepath)
	LunaTargetTargetTargetFrame.Buffs[1]:SetScript("OnEnter", Luna_TargetTargetTarget_SetBuffTooltip)
	LunaTargetTargetTargetFrame.Buffs[1]:SetScript("OnLeave", Luna_TargetTargetTarget_SetBuffTooltipLeave)

	LunaTargetTargetTargetFrame.Buffs[1].stacks = LunaTargetTargetTargetFrame.Buffs[1]:CreateFontString(nil, "OVERLAY", LunaTargetTargetTargetFrame.Buffs[1])
	LunaTargetTargetTargetFrame.Buffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaTargetTargetTargetFrame.Buffs[1], 0, 0)
	LunaTargetTargetTargetFrame.Buffs[1].stacks:SetJustifyH("LEFT")
	LunaTargetTargetTargetFrame.Buffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaTargetTargetTargetFrame.Buffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaTargetTargetTargetFrame.Buffs[1].stacks:SetTextColor(1,1,1)
	
	for i=2, 16 do
		LunaTargetTargetTargetFrame.Buffs[i] = CreateFrame("Button", nil, LunaTargetTargetTargetFrame.AuraAnchor)
		LunaTargetTargetTargetFrame.Buffs[i].texturepath = UnitBuff("targettargettarget",i)
		LunaTargetTargetTargetFrame.Buffs[i].id = i
		LunaTargetTargetTargetFrame.Buffs[i]:SetNormalTexture(LunaTargetTargetTargetFrame.Buffs[i].texturepath)
		LunaTargetTargetTargetFrame.Buffs[i]:SetScript("OnEnter", Luna_TargetTargetTarget_SetBuffTooltip)
		LunaTargetTargetTargetFrame.Buffs[i]:SetScript("OnLeave", Luna_TargetTargetTarget_SetBuffTooltipLeave)
		
		LunaTargetTargetTargetFrame.Buffs[i].stacks = LunaTargetTargetTargetFrame.Buffs[i]:CreateFontString(nil, "OVERLAY", LunaTargetTargetTargetFrame.Buffs[i])
		LunaTargetTargetTargetFrame.Buffs[i].stacks:SetPoint("BOTTOMRIGHT", LunaTargetTargetTargetFrame.Buffs[i], 0, 0)
		LunaTargetTargetTargetFrame.Buffs[i].stacks:SetJustifyH("LEFT")
		LunaTargetTargetTargetFrame.Buffs[i].stacks:SetShadowColor(0, 0, 0)
		LunaTargetTargetTargetFrame.Buffs[i].stacks:SetShadowOffset(0.8, -0.8)
		LunaTargetTargetTargetFrame.Buffs[i].stacks:SetTextColor(1,1,1)
	end

	LunaTargetTargetTargetFrame.Debuffs = {}

	LunaTargetTargetTargetFrame.Debuffs[1] = CreateFrame("Button", nil, LunaTargetTargetTargetFrame.AuraAnchor)
	LunaTargetTargetTargetFrame.Debuffs[1].texturepath = UnitDebuff("targettargettarget",1)
	LunaTargetTargetTargetFrame.Debuffs[1].id = 17
	LunaTargetTargetTargetFrame.Debuffs[1]:SetNormalTexture(LunaTargetTargetTargetFrame.Debuffs[1].texturepath)
	LunaTargetTargetTargetFrame.Debuffs[1]:SetScript("OnEnter", Luna_TargetTargetTarget_SetBuffTooltip)
	LunaTargetTargetTargetFrame.Debuffs[1]:SetScript("OnLeave", Luna_TargetTargetTarget_SetBuffTooltipLeave)

	LunaTargetTargetTargetFrame.Debuffs[1].stacks = LunaTargetTargetTargetFrame.Debuffs[1]:CreateFontString(nil, "OVERLAY", LunaTargetTargetTargetFrame.Debuffs[1])
	LunaTargetTargetTargetFrame.Debuffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaTargetTargetTargetFrame.Debuffs[1], 0, 0)
	LunaTargetTargetTargetFrame.Debuffs[1].stacks:SetJustifyH("LEFT")
	LunaTargetTargetTargetFrame.Debuffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaTargetTargetTargetFrame.Debuffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaTargetTargetTargetFrame.Debuffs[1].stacks:SetTextColor(1,1,1)

	for i=2, 16 do
		LunaTargetTargetTargetFrame.Debuffs[i] = CreateFrame("Button", nil, LunaTargetTargetTargetFrame.AuraAnchor)
		LunaTargetTargetTargetFrame.Debuffs[i].texturepath = UnitDebuff("targettargettarget",i)
		LunaTargetTargetTargetFrame.Debuffs[i].id = i+16
		LunaTargetTargetTargetFrame.Debuffs[i]:SetNormalTexture(LunaTargetTargetTargetFrame.Debuffs[i].texturepath)
		LunaTargetTargetTargetFrame.Debuffs[i]:SetScript("OnEnter", Luna_TargetTargetTarget_SetBuffTooltip)
		LunaTargetTargetTargetFrame.Debuffs[i]:SetScript("OnLeave", Luna_TargetTargetTarget_SetBuffTooltipLeave)
		
		LunaTargetTargetTargetFrame.Debuffs[i].stacks = LunaTargetTargetTargetFrame.Debuffs[i]:CreateFontString(nil, "OVERLAY", LunaTargetTargetTargetFrame.Debuffs[i])
		LunaTargetTargetTargetFrame.Debuffs[i].stacks:SetPoint("BOTTOMRIGHT", LunaTargetTargetTargetFrame.Debuffs[i], 0, 0)
		LunaTargetTargetTargetFrame.Debuffs[i].stacks:SetJustifyH("LEFT")
		LunaTargetTargetTargetFrame.Debuffs[i].stacks:SetShadowColor(0, 0, 0)
		LunaTargetTargetTargetFrame.Debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
		LunaTargetTargetTargetFrame.Debuffs[i].stacks:SetTextColor(1,1,1)
	end	
	
	LunaTargetTargetTargetFrame.bars["Powerbar"].righttext = LunaTargetTargetTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetTargetFrame.bars["Powerbar"])
	LunaTargetTargetTargetFrame.bars["Powerbar"].righttext:SetPoint("RIGHT", -2, 0)
	LunaTargetTargetTargetFrame.bars["Powerbar"].righttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetTargetTargetFrame.bars["Powerbar"].righttext:SetShadowColor(0, 0, 0)
	LunaTargetTargetTargetFrame.bars["Powerbar"].righttext:SetShadowOffset(0.8, -0.8)
	LunaTargetTargetTargetFrame.bars["Powerbar"].righttext:SetJustifyH("RIGHT")
	LunaTargetTargetTargetFrame.bars["Powerbar"].righttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaTargetTargetTargetFrame.bars["Powerbar"].righttext, "targettargettarget", barsettings["Powerbar"][2] or LunaOptions.defaultTags["Powerbar"][2])
	
	LunaTargetTargetTargetFrame.bars["Powerbar"].lefttext = LunaTargetTargetTargetFrame.bars["Powerbar"]:CreateFontString(nil, "OVERLAY", LunaTargetTargetTargetFrame.bars["Powerbar"])
	LunaTargetTargetTargetFrame.bars["Powerbar"].lefttext:SetPoint("LEFT", 2, 0)
	LunaTargetTargetTargetFrame.bars["Powerbar"].lefttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaTargetTargetTargetFrame.bars["Powerbar"].lefttext:SetShadowColor(0, 0, 0)
	LunaTargetTargetTargetFrame.bars["Powerbar"].lefttext:SetShadowOffset(0.8, -0.8)
	LunaTargetTargetTargetFrame.bars["Powerbar"].lefttext:SetJustifyH("LEFT")
	LunaTargetTargetTargetFrame.bars["Powerbar"].lefttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaTargetTargetTargetFrame.bars["Powerbar"].lefttext, "targettargettarget", barsettings["Powerbar"][1] or LunaOptions.defaultTags["Powerbar"][1])
	
	LunaTargetTargetTargetFrame:Hide()
		
	LunaTargetTargetTargetFrame:SetScript("OnClick", Luna_OnClick)
	LunaTargetTargetTargetFrame:SetScript("OnEvent", Luna_TargetTarget_OnEvent)
	tot:SetScript("OnUpdate", Luna_TargetTarget_OnUpdate)
	
	LunaTargetTargetTargetFrame.dropdown = CreateFrame("Frame", "LunaUnitDropDownMenuTargetTargetTarget", UIParent, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(LunaTargetTargetTargetFrame.dropdown, Luna_TargetTargetTargetDropDown_Initialize, "MENU")
	
	LunaTargetTargetTargetFrame.AdjustBars = function()
		local frameHeight = LunaTargetTargetTargetFrame:GetHeight()
		local frameWidth = LunaTargetTargetTargetFrame:GetWidth()
		local anchor
		local totalWeight = 0
		local gaps = -1
		local textheights = {}
		local textbalance = {}
		anchor = {"TOPLEFT", LunaTargetTargetTargetFrame, "TOPLEFT"}
		if LunaOptions.frames["LunaTargetTargetTargetFrame"].portrait > 1 then    -- We have a square portrait
			frameWidth = (LunaTargetTargetTargetFrame:GetWidth()-frameHeight)
			LunaTargetTargetTargetFrame.bars["Portrait"]:ClearAllPoints()
			LunaTargetTargetTargetFrame.bars["Portrait"]:SetHeight(frameHeight)
			LunaTargetTargetTargetFrame.bars["Portrait"]:SetWidth(frameHeight)
			if LunaOptions.fliptargettargettarget then
				LunaTargetTargetTargetFrame.bars["Portrait"]:SetPoint("TOPRIGHT", LunaTargetTargetTargetFrame, "TOPRIGHT")
				anchor = {"TOPRIGHT", LunaTargetTargetTargetFrame.bars["Portrait"], "TOPLEFT"}
			else
				LunaTargetTargetTargetFrame.bars["Portrait"]:SetPoint("TOPLEFT", LunaTargetTargetTargetFrame, "TOPLEFT")
				anchor = {"TOPLEFT", LunaTargetTargetTargetFrame.bars["Portrait"], "TOPRIGHT"}
			end
		else
			frameWidth = LunaTargetTargetTargetFrame:GetWidth()  -- We have a Bar-Portrait or no portrait
			anchor = {"TOPLEFT", LunaTargetTargetTargetFrame, "TOPLEFT"}
		end
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
			textheights[v[1]] = v[3] or 0.45
			textbalance[v[1]] = v[6] or 0.5
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
		LunaTargetTargetTargetFrame.bars["Portrait"].model:SetHeight(LunaTargetTargetTargetFrame.bars["Portrait"]:GetHeight()+1)
		LunaTargetTargetTargetFrame.bars["Portrait"].model:SetWidth(LunaTargetTargetTargetFrame.bars["Portrait"]:GetWidth())
		local healthheight = (LunaTargetTargetTargetFrame.bars["Healthbar"]:GetHeight()*textheights["Healthbar"])
		LunaTargetTargetTargetFrame.bars["Healthbar"].righttext:SetFont(LunaOptions.font, healthheight)
		LunaTargetTargetTargetFrame.bars["Healthbar"].righttext:SetHeight(LunaTargetTargetTargetFrame.bars["Healthbar"]:GetHeight())
		LunaTargetTargetTargetFrame.bars["Healthbar"].righttext:SetWidth(LunaTargetTargetTargetFrame.bars["Healthbar"]:GetWidth()*(1-textbalance["Healthbar"]))
		LunaTargetTargetTargetFrame.bars["Healthbar"].lefttext:SetFont(LunaOptions.font, healthheight)
		LunaTargetTargetTargetFrame.bars["Healthbar"].lefttext:SetHeight(LunaTargetTargetTargetFrame.bars["Healthbar"]:GetHeight())
		LunaTargetTargetTargetFrame.bars["Healthbar"].lefttext:SetWidth(LunaTargetTargetTargetFrame.bars["Healthbar"]:GetWidth()*textbalance["Healthbar"])

		local powerheight = (LunaTargetTargetTargetFrame.bars["Powerbar"]:GetHeight()*textheights["Powerbar"])
		LunaTargetTargetTargetFrame.bars["Powerbar"].righttext:SetFont(LunaOptions.font, powerheight)
		LunaTargetTargetTargetFrame.bars["Powerbar"].righttext:SetHeight(LunaTargetTargetTargetFrame.bars["Powerbar"]:GetHeight())
		LunaTargetTargetTargetFrame.bars["Powerbar"].righttext:SetWidth(LunaTargetTargetTargetFrame.bars["Powerbar"]:GetWidth()*(1-textbalance["Powerbar"]))
		LunaTargetTargetTargetFrame.bars["Powerbar"].lefttext:SetFont(LunaOptions.font, powerheight)
		LunaTargetTargetTargetFrame.bars["Powerbar"].lefttext:SetHeight(LunaTargetTargetTargetFrame.bars["Powerbar"]:GetHeight())
		LunaTargetTargetTargetFrame.bars["Powerbar"].lefttext:SetWidth(LunaTargetTargetTargetFrame.bars["Powerbar"]:GetWidth()*textbalance["Powerbar"])
	end
	LunaTargetTargetTargetFrame.UpdateBuffSize = function ()
		local buffcount = LunaOptions.frames["LunaTargetTargetTargetFrame"].BuffInRow or 16
		if LunaOptions.frames["LunaTargetTargetTargetFrame"].ShowBuffs == 1 then
			for i=1, 16 do
				LunaTargetTargetTargetFrame.Buffs[i]:Hide()
				LunaTargetTargetTargetFrame.Debuffs[i]:Hide()
			end
		elseif LunaOptions.frames["LunaTargetTargetTargetFrame"].ShowBuffs == 2 then
			local buffsize = ((LunaTargetTargetTargetFrame:GetWidth()-(buffcount-1))/buffcount)
			LunaTargetTargetTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetTargetTargetFrame.AuraAnchor:SetPoint("BOTTOMLEFT", LunaTargetTargetTargetFrame, "TOPLEFT", -1, 3)
			LunaTargetTargetTargetFrame.AuraAnchor:SetWidth(LunaTargetTargetTargetFrame:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetTargetTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetPoint("BOTTOMLEFT", LunaTargetTargetTargetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetTargetTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetPoint("BOTTOMLEFT", LunaTargetTargetTargetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
		elseif LunaOptions.frames["LunaTargetTargetTargetFrame"].ShowBuffs == 3 then
			local buffsize = ((LunaTargetTargetTargetFrame:GetWidth()-(buffcount-1))/buffcount)
			LunaTargetTargetTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetTargetTargetFrame.AuraAnchor:SetWidth(LunaTargetTargetTargetFrame:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetTargetTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetPoint("TOPLEFT", LunaTargetTargetTargetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetTargetTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetPoint("TOPLEFT", LunaTargetTargetTargetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaTargetTargetTargetFrame.AuraAnchor:SetPoint("TOPLEFT", LunaTargetTargetTargetFrame, "BOTTOMLEFT", -1, -3)
		elseif LunaOptions.frames["LunaTargetTargetTargetFrame"].ShowBuffs == 4 then
			local buffsize = (((LunaTargetTargetTargetFrame:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaTargetTargetTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetTargetTargetFrame.AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetTargetTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetPoint("TOPRIGHT", LunaTargetTargetTargetFrame.AuraAnchor, "TOPRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetTargetTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetPoint("TOPRIGHT", LunaTargetTargetTargetFrame.AuraAnchor, "BOTTOMRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaTargetTargetTargetFrame.AuraAnchor:SetPoint("TOPRIGHT", LunaTargetTargetTargetFrame, "TOPLEFT", -3, 0)
		else
			local buffsize = (((LunaTargetTargetTargetFrame:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaTargetTargetTargetFrame.AuraAnchor:ClearAllPoints()
			LunaTargetTargetTargetFrame.AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaTargetTargetTargetFrame.Buffs[buffid]:ClearAllPoints()
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetPoint("TOPLEFT", LunaTargetTargetTargetFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetTargetFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetTargetFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaTargetTargetTargetFrame.Debuffs[buffid]:ClearAllPoints()
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetPoint("TOPLEFT", LunaTargetTargetTargetFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaTargetTargetTargetFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaTargetTargetTargetFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaTargetTargetTargetFrame.AuraAnchor:SetPoint("TOPLEFT", LunaTargetTargetTargetFrame, "TOPRIGHT", 3, 0)
		end
	end
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
		if v[2] == 0 then
			LunaTargetTargetTargetFrame.bars[v[1]]:Hide()
		end
	end
	LunaTargetTargetTargetFrame.AdjustBars()
	LunaTargetTargetTargetFrame.UpdateBuffSize()
end

local function TargetTargetTargetPortraitUpdate(unit)
	if (not validunits[arg1] or not UnitIsUnit(arg1,"targettargettarget")) and not unit then
		return
	end
	local portrait = LunaTargetTargetTargetFrame.bars["Portrait"]
	if LunaOptions.PortraitMode == 3 and UnitIsPlayer("targettargettarget") then
		local _,class = UnitClass("targettargettarget")
		portrait.model:Hide()
		portrait.texture:Show()
		portrait.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		portrait.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
	elseif LunaOptions.PortraitMode == 2 or (LunaOptions.PortraitMode == 3 and (LunaOptions.PortraitFallback == 3 or LunaOptions.PortraitFallback == 2)) then
		if LunaOptions.frames["LunaTargetTargetTargetFrame"].portrait > 1 then
			portrait.model:Hide()
			portrait.texture:Show()
			SetPortraitTexture(portrait.texture, "targettargettarget")
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
		if(not UnitExists("targettargettarget") or not UnitIsConnected("targettargettarget") or not UnitIsVisible("targettargettarget")) then
			if LunaOptions.PortraitFallback == 3 and UnitIsPlayer("targettargettarget") then
				portrait.model:Hide()
				portrait.texture:Show()
				local _,class = UnitClass("targettargettarget")
				portrait.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
				portrait.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
			elseif LunaOptions.PortraitFallback == 2 or LunaOptions.PortraitFallback == 3 then
				if LunaOptions.frames["LunaTargetTargetTargetFrame"].portrait > 1 then
					portrait.model:Hide()
					portrait.texture:Show()
					SetPortraitTexture(portrait.texture, "targettargettarget")
					portrait.texture:SetTexCoord(.1, .90, .1, .90)
				else
					portrait.model:Hide()
					portrait.texture:Show()
					SetPortraitTexture(portrait.texture, "targettargettarget")
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
			portrait.model:SetUnit("targettargettarget")
			portrait.model:SetCamera(0)
		end
	end
end

function LunaUnitFrames:UpdateTargetTargetTargetFrame()
	if UnitName(LunaTargetTargetTargetFrame.unit) ~= LunaTargetTargetTargetFrame.name or LunaTargetTargetTargetFrame.isPlayer ~= UnitIsPlayer(LunaTargetTargetTargetFrame.unit) then
		LunaTargetTargetTargetFrame.name = UnitName(LunaTargetTargetTargetFrame.unit)
		LunaTargetTargetTargetFrame.isPlayer = UnitIsPlayer(LunaTargetTargetTargetFrame.unit)
		TargetTargetTargetPortraitUpdate("targettargettarget")
	end
	if LunaOptions.frames["LunaTargetTargetTargetFrame"].enabled == 1 and UnitExists("targettargettarget") then
		LunaTargetTargetTargetFrame:Show()
	else
		LunaTargetTargetTargetFrame:Hide()
		return
	end
	local Health, maxHealth
	if MobHealth3 then
		Health, maxHealth = MobHealth3:GetUnitHealth(LunaTargetTargetTargetFrame.unit)
	else
		Health = UnitHealth(LunaTargetTargetTargetFrame.unit)
		maxHealth = UnitHealthMax(LunaTargetTargetTargetFrame.unit)
	end
	local _,class = UnitClass("targettargettarget")
	if UnitIsPlayer("targettargettarget") then
		local color
		if LunaOptions.hbarcolor then
			color = LunaOptions.ClassColors[class]
		elseif UnitIsEnemy("player","targettargettarget") then
			color = LunaOptions.MiscColors["hostile"]
		else
			color = LunaUnitFrames:GetHealthColor("targettargettarget")
		end
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
		LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
	elseif UnitIsTapped("targettargettarget") and not UnitIsTappedByPlayer("targettargettarget") then
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(0.5, 0.5, 0.5)
		LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(0.5, 0.5, 0.5, 0.25)
	else
		reaction = UnitReaction("targettargettarget", "player")
		if reaction and reaction < 4 then
			LunaTargetTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(unpack(LunaOptions.MiscColors["hostile"]))
			LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(unpack(LunaOptions.MiscColors["hostile"]), 0.25)
		elseif reaction and reaction > 4 then
			LunaTargetTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(unpack(LunaOptions.MiscColors["friendly"]))
			LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(unpack(LunaOptions.MiscColors["friendly"]), 0.25)
		else
			LunaTargetTargetTargetFrame.bars["Healthbar"]:SetStatusBarColor(unpack(LunaOptions.MiscColors["neutral"]))
			LunaTargetTargetTargetFrame.bars["Healthbar"].hpbg:SetVertexColor(unpack(LunaOptions.MiscColors["neutral"]), 0.25)
		end
	end
	if not UnitIsConnected(LunaTargetTargetTargetFrame.unit) then
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetValue(0)
			
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetValue(0)
	elseif Health < 1 then
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetValue(0)
			
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetValue(0)
	else
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetValue(Health)
			
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetValue(UnitMana(LunaTargetTargetTargetFrame.unit))
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
	else
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
	end
	local index = GetRaidTargetIndex("targettargettarget")
	if (index) then
		SetRaidTargetIconTexture(LunaTargetTargetTargetFrame.RaidIcon, index)
		LunaTargetTargetTargetFrame.RaidIcon:Show()
	else
		LunaTargetTargetTargetFrame.RaidIcon:Hide()
	end
	local _,_,dtype = UnitDebuff("targettargettarget", 1, 1)
	if dtype and LunaOptions.HighlightDebuffs and UnitCanAssist("player", "targettargettarget") then
		LunaTargetTargetTargetFrame:SetBackdropColor(unpack(LunaOptions.DebuffTypeColor[dtype],1))
	else
		LunaTargetTargetTargetFrame:SetBackdropColor(0,0,0,1)
	end
	if LunaOptions.frames["LunaTargetTargetTargetFrame"].ShowBuffs ~= 1 then
		local pos
		for i=1, 16 do
			local path, stacks = UnitBuff("targettargettarget",i)
			LunaTargetTargetTargetFrame.Buffs[i].texturepath = path
			if LunaTargetTargetTargetFrame.Buffs[i].texturepath then
				LunaTargetTargetTargetFrame.Buffs[i]:EnableMouse(1)
				LunaTargetTargetTargetFrame.Buffs[i]:Show()
				if stacks > 1 then
					LunaTargetTargetTargetFrame.Buffs[i].stacks:SetText(stacks)
					LunaTargetTargetTargetFrame.Buffs[i].stacks:Show()
				else
					LunaTargetTargetTargetFrame.Buffs[i].stacks:Hide()
				end
			else
				LunaTargetTargetTargetFrame.Buffs[i]:EnableMouse(0)
				LunaTargetTargetTargetFrame.Buffs[i]:Hide()
				if not pos then
					pos = i
				end
			end
			LunaTargetTargetTargetFrame.Buffs[i]:SetNormalTexture(LunaTargetTargetTargetFrame.Buffs[i].texturepath)
		end
		if not pos then
			pos = 17
		end
		LunaTargetTargetTargetFrame.AuraAnchor:SetHeight((LunaTargetTargetTargetFrame.Buffs[1]:GetHeight()*math.ceil((pos-1)/(LunaOptions.frames["LunaTargetTargetTargetFrame"].BuffInRow or 16)))+(math.ceil((pos-1)/(LunaOptions.frames["LunaTargetTargetTargetFrame"].BuffInRow or 16))-1)+1.1)
		for i=1, 16 do
			local path, stacks = UnitDebuff("targettargettarget",i)
			LunaTargetTargetTargetFrame.Debuffs[i].texturepath = path
			if LunaTargetTargetTargetFrame.Debuffs[i].texturepath then
				LunaTargetTargetTargetFrame.Debuffs[i]:EnableMouse(1)
				LunaTargetTargetTargetFrame.Debuffs[i]:Show()
				if stacks > 1 then
					LunaTargetTargetTargetFrame.Debuffs[i].stacks:SetText(stacks)
					LunaTargetTargetTargetFrame.Debuffs[i].stacks:Show()
				else
					LunaTargetTargetTargetFrame.Debuffs[i].stacks:Hide()
				end
			else
				LunaTargetTargetTargetFrame.Debuffs[i]:EnableMouse(0)
				LunaTargetTargetTargetFrame.Debuffs[i]:Hide()
			end
			LunaTargetTargetTargetFrame.Debuffs[i]:SetNormalTexture(LunaTargetTargetTargetFrame.Debuffs[i].texturepath)
		end
	end
	LunaUnitFrames:UpdateTags("targettargettarget")
end

function LunaUnitFrames:ConvertTargetTargetTargetPortrait()
	if LunaOptions.frames["LunaTargetTargetTargetFrame"].portrait == 1 then
		table.insert(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars, 1, {"Portrait", 4})
	else
		for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
			if v[1] == "Portrait" then
				table.remove(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars, k)
			end
		end
	end
	UIDropDownMenu_SetText("Healthbar", LunaOptionsFrame.pages[5].BarSelect)
	LunaOptionsFrame.pages[5].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars))
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
		if v[1] == "Healthbar" then
			LunaOptionsFrame.pages[5].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[5].barorder:SetValue(k)
			LunaOptionsFrame.pages[5].lefttext:SetText(v[4] or LunaOptions.defaultTags["Healthbar"][1])
			LunaOptionsFrame.pages[5].righttext:SetText(v[5] or LunaOptions.defaultTags["Healthbar"][2])
			LunaOptionsFrame.pages[5].textsize:SetValue(v[3] or 0.45)
			break
		end
	end
	LunaTargetTargetTargetFrame.AdjustBars()
	LunaUnitFrames:UpdateTargetTargetTargetFrame()
end

function Luna_TargetTarget_Events.UNIT_PORTRAIT_UPDATE()
	TargetTargetPortraitUpdate()
	TargetTargetTargetPortraitUpdate()
end