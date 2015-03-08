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

function Luna_TargetTarget_Events:PLAYER_TARGET_CHANGED()
	LunaUnitFrames:UpdateTargetTargetFrame()
	LunaUnitFrames:UpdateTargetTargetTargetFrame()
end

function LunaUnitFrames:UpdateTargetTargetFrame()
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
		LunaTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetFrame.bars["Healthbar"]:SetValue(0)
		LunaTargetTargetFrame.bars["Healthbar"].hpp:SetText("OFFLINE")
			
		LunaTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Powerbar"]:SetValue(0)
		LunaTargetTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaTargetTargetFrame.unit))
	elseif Health < 1 then
		LunaTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetFrame.bars["Healthbar"]:SetValue(0)
		LunaTargetTargetFrame.bars["Healthbar"].hpp:SetText("DEAD")
			
		LunaTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetFrame.unit))
		LunaTargetTargetFrame.bars["Powerbar"]:SetValue(0)
		LunaTargetTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaTargetTargetFrame.unit))
	else
		LunaTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetFrame.bars["Healthbar"]:SetValue(Health)
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

function LunaUnitFrames:UpdateTargetTargetTargetFrame()
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
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetValue(0)
		LunaTargetTargetTargetFrame.bars["Healthbar"].hpp:SetText("OFFLINE")
			
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetValue(0)
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaTargetTargetTargetFrame.unit))
	elseif Health < 1 then
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetValue(0)
		LunaTargetTargetTargetFrame.bars["Healthbar"].hpp:SetText("DEAD")
			
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax(LunaTargetTargetTargetFrame.unit))
		LunaTargetTargetTargetFrame.bars["Powerbar"]:SetValue(0)
		LunaTargetTargetTargetFrame.bars["Powerbar"].ppp:SetText(LunaUnitFrames:GetPowerString(LunaTargetTargetTargetFrame.unit))
	else
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetMinMaxValues(0, maxHealth)
		LunaTargetTargetTargetFrame.bars["Healthbar"]:SetValue(Health)
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
end