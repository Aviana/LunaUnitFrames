local HealComm = AceLibrary("HealComm-1.0")
local AceEvent = AceLibrary("AceEvent-2.0")
local Luna_Player_Events = {}

local totemcolors = {
					{1,0,0},
					{0,0,1},
					{0.78,0.61,0.43},
					{0.41,0.80,0.94}
				}

local function buffcancel()
	CancelPlayerBuff(GetPlayerBuff(this.id-1,"HELPFUL"))
end

local function Luna_HideBlizz(frame)
	frame:UnregisterAllEvents()
	frame:Hide()
end

local function Luna_Player_SetBuffTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	if (this.id > 16) then
		GameTooltip:SetPlayerBuff(GetPlayerBuff(this.id-17,"HARMFUL"))
	else
		GameTooltip:SetPlayerBuff(GetPlayerBuff(this.id-1,"HELPFUL"))
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
		LunaOptionsFrame.Button8:SetText("Unlock Frames")
	else
		LunaPlayerFrame:SetScript("OnDragStart", StartMoving)
		LunaPlayerFrame:SetMovable(1)
		
		LunaOptionsFrame.Button8:SetText("Lock Frames")
	end
end
			
local function Luna_Player_OnUpdate()
	local sign
	local castbar = LunaPlayerFrame.bars.Castbar
	local current_time = castbar.maxValue - GetTime()
	if (castbar.channeling) then
		current_time = castbar.endTime - GetTime()
	end
	local text = string.sub(math.max(current_time,0)+0.001,1,4)
	if (castbar.delaySum ~= 0) then
		local delay = string.sub(math.max(castbar.delaySum/1000, 0)+0.001,1,4)
		if (castbar.channeling == 1) then
			sign = "-"
		else
			sign = "+"
		end
		text = "|cffcc0000"..sign..delay.."|r "..text
	end
	castbar.Time:SetText(text)
	
	if (castbar.casting) then
		local status = GetTime()
		if (status > castbar.maxValue) then
			status = castbar.maxValue
		end
		castbar:SetValue(status)
	elseif (castbar.channeling) then
		local time = GetTime()
		if (time > castbar.endTime) then
			time = castbar.endTime
		end
		if (time == castbar.endTime) then
			castbar.channeling = nil
			LunaPlayerFrame.AdjustBars()
			return
		end
		local barValue = castbar.startTime + (castbar.endTime - time)
		castbar:SetValue(barValue)
	end
end

local function Luna_Player_BuffTimer()
	if not LunaOptions.BTimers or LunaOptions.BTimers == 0 then
		return
	end
	local curtime = GetTime()
	for i=1, 16 do
		local buff = LunaPlayerFrame.Buffs[i]
		local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(i-1,"HELPFUL"))
		if timeleft == 0 then
			buff.endtime = 0
			CooldownFrame_SetTimer(buff.cd,curtime,timeleft,1)
		elseif not buff.endtime or buff.endtime == 0 then
			buff.endtime = curtime + timeleft
			CooldownFrame_SetTimer(buff.cd,curtime,timeleft,1)
		elseif (buff.endtime + 0.1) < (curtime + timeleft) or (buff.endtime - 0.1) > (curtime + timeleft) then
			buff.endtime = curtime + timeleft
			CooldownFrame_SetTimer(buff.cd,curtime,timeleft,1)
		end
	end
	for i=1, 16 do
		local debuff = LunaPlayerFrame.Debuffs[i]
		local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(i-1,"HARMFUL"))
		if timeleft == 0 then
			debuff.endtime = 0
			CooldownFrame_SetTimer(debuff.cd,curtime,timeleft,1)
		elseif not debuff.endtime or debuff.endtime == 0 then
			debuff.endtime = curtime + timeleft
			CooldownFrame_SetTimer(debuff.cd,curtime,timeleft,1)
		elseif (debuff.endtime + 0.1) < (curtime + timeleft) or (debuff.endtime - 0.1) > (curtime + timeleft) then
			debuff.endtime = curtime + timeleft
			CooldownFrame_SetTimer(debuff.cd,curtime,timeleft,1)
		end
	end
end

local function Luna_Player_TotemOnUpdate()
	for i=1, 4 do
		local totem = LunaPlayerFrame.totems[i]
		if totem.active then
			if totem.maxValue >= GetTime() then
				totem:SetValue(totem.maxValue-GetTime())
			else
				totem:SetValue(0)
				totem.active = nil
				LunaPlayerFrame.AdjustBars()
			end
		end
	end
end

local function SetIconPositions()
	if LunaOptions.frames["LunaPlayerFrame"].portrait == 1 then
		LunaPlayerFrame.RaidIcon:ClearAllPoints()
		LunaPlayerFrame.RaidIcon:SetPoint("CENTER", LunaPlayerFrame, "TOP")
		LunaPlayerFrame.PVPRank:ClearAllPoints()
		LunaPlayerFrame.PVPRank:SetPoint("CENTER", LunaPlayerFrame, "BOTTOMLEFT", -2, 2)
		LunaPlayerFrame.Leader:ClearAllPoints()
		LunaPlayerFrame.Leader:SetPoint("CENTER", LunaPlayerFrame, "TOPLEFT", -1, -2)
		LunaPlayerFrame.Loot:ClearAllPoints()
		LunaPlayerFrame.Loot:SetPoint("CENTER", LunaPlayerFrame, "TOPLEFT", -2, -12)
		LunaPlayerFrame.Combat:ClearAllPoints()
		LunaPlayerFrame.Combat:SetPoint("CENTER", LunaPlayerFrame, "BOTTOMRIGHT", 2, 2)
		LunaPlayerFrame.feedbackText:ClearAllPoints()
		LunaPlayerFrame.feedbackText:SetPoint("CENTER", LunaPlayerFrame, "CENTER", 0, 0)
	else
		LunaPlayerFrame.RaidIcon:ClearAllPoints()
		LunaPlayerFrame.RaidIcon:SetPoint("CENTER", LunaPlayerFrame.bars["Portrait"], "TOPRIGHT")
		LunaPlayerFrame.PVPRank:ClearAllPoints()
		LunaPlayerFrame.PVPRank:SetPoint("CENTER", LunaPlayerFrame.bars["Portrait"], "BOTTOMLEFT", 2, 2)
		LunaPlayerFrame.Leader:ClearAllPoints()
		LunaPlayerFrame.Leader:SetPoint("CENTER", LunaPlayerFrame.bars["Portrait"], "TOPLEFT", 2, -2)
		LunaPlayerFrame.Loot:ClearAllPoints()
		LunaPlayerFrame.Loot:SetPoint("CENTER", LunaPlayerFrame.bars["Portrait"], "TOPLEFT", 2, -12)
		LunaPlayerFrame.Combat:ClearAllPoints()
		LunaPlayerFrame.Combat:SetPoint("CENTER", LunaPlayerFrame.bars["Portrait"], "BOTTOMRIGHT", -2, 2)
		LunaPlayerFrame.feedbackText:ClearAllPoints()
		LunaPlayerFrame.feedbackText:SetPoint("CENTER", LunaPlayerFrame.bars["Portrait"], "CENTER", 0, 0)
	end
end

function LunaUnitFrames:CreatePlayerFrame()
	LunaPlayerFrame = CreateFrame("Button", "LunaPlayerFrame", UIParent)
	local frameoptions = LunaOptions.frames.LunaPlayerFrame

	LunaPlayerFrame:SetHeight(frameoptions.size.y)
	LunaPlayerFrame:SetWidth(frameoptions.size.x)
	LunaPlayerFrame:SetScale(frameoptions.scale)
	LunaPlayerFrame:SetBackdrop(LunaOptions.backdrop)
	LunaPlayerFrame:SetBackdropColor(0,0,0,1)
	LunaPlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", frameoptions.position.x, frameoptions.position.y)
	LunaPlayerFrame:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
	LunaPlayerFrame.unit = "player"
	LunaPlayerFrame:SetScript("OnEnter", UnitFrame_OnEnter)
	LunaPlayerFrame:SetScript("OnLeave", UnitFrame_OnLeave)
	LunaPlayerFrame:SetMovable(0)
	LunaPlayerFrame:RegisterForDrag("LeftButton")
	LunaPlayerFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaPlayerFrame:SetClampedToScreen(1)
	LunaPlayerFrame:SetFrameStrata("BACKGROUND")

	LunaPlayerFrame.bars = {}
	
	LunaPlayerFrame.bars["Portrait"] = CreateFrame("PlayerModel", nil, LunaPlayerFrame)
	LunaPlayerFrame.bars["Portrait"]:SetScript("OnShow",function() this:SetCamera(0) end)
	LunaPlayerFrame.bars["Portrait"].type = "3D"
	LunaPlayerFrame.bars["Portrait"].side = "left"

	LunaPlayerFrame.AuraAnchor = CreateFrame("Frame", nil, LunaPlayerFrame)
	LunaPlayerFrame.AuraAnchor:SetScript("OnUpdate", Luna_Player_BuffTimer)
	
	
	LunaPlayerFrame.Buffs = {}

	LunaPlayerFrame.Buffs[1] = CreateFrame("Button", "LunaPlayerFrameBuff1", LunaPlayerFrame.AuraAnchor)
	LunaPlayerFrame.Buffs[1].texturepath = UnitBuff("player",1)
	LunaPlayerFrame.Buffs[1].id = 1
	LunaPlayerFrame.Buffs[1]:SetNormalTexture(LunaPlayerFrame.Buffs[1].texturepath)
	LunaPlayerFrame.Buffs[1]:SetScript("OnEnter", Luna_Player_SetBuffTooltip)
	LunaPlayerFrame.Buffs[1]:SetScript("OnLeave", Luna_Player_SetBuffTooltipLeave)
	LunaPlayerFrame.Buffs[1]:SetScript("OnClick", buffcancel)
	LunaPlayerFrame.Buffs[1]:RegisterForClicks("RightButtonUp")

	
	LunaPlayerFrame.Buffs[1].cd = CreateFrame("Model", nil, LunaPlayerFrame.Buffs[1], "CooldownFrameTemplate")
	LunaPlayerFrame.Buffs[1].cd:ClearAllPoints()
	LunaPlayerFrame.Buffs[1].cd:SetPoint("TOPLEFT", LunaPlayerFrame.Buffs[1], "TOPLEFT")
	LunaPlayerFrame.Buffs[1].cd:SetHeight(36)
	LunaPlayerFrame.Buffs[1].cd:SetWidth(36)

	LunaPlayerFrame.Buffs[1].stacks = LunaPlayerFrame.Buffs[1]:CreateFontString(nil, "OVERLAY", LunaPlayerFrame.Buffs[1])
	LunaPlayerFrame.Buffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaPlayerFrame.Buffs[1], 0, 0)
	LunaPlayerFrame.Buffs[1].stacks:SetJustifyH("LEFT")
	LunaPlayerFrame.Buffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaPlayerFrame.Buffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaPlayerFrame.Buffs[1].stacks:SetTextColor(1,1,1)
	
	for i=2, 16 do
		LunaPlayerFrame.Buffs[i] = CreateFrame("Button", "LunaPlayerFrameBuff"..i, LunaPlayerFrame.AuraAnchor)
		LunaPlayerFrame.Buffs[i].texturepath = UnitBuff("player",i)
		LunaPlayerFrame.Buffs[i].id = i
		LunaPlayerFrame.Buffs[i]:SetNormalTexture(LunaPlayerFrame.Buffs[i].texturepath)
		LunaPlayerFrame.Buffs[i]:SetScript("OnEnter", Luna_Player_SetBuffTooltip)
		LunaPlayerFrame.Buffs[i]:SetScript("OnLeave", Luna_Player_SetBuffTooltipLeave)
		LunaPlayerFrame.Buffs[i]:SetScript("OnClick", buffcancel)
		LunaPlayerFrame.Buffs[i]:RegisterForClicks("RightButtonUp")
		
		LunaPlayerFrame.Buffs[i].cd = CreateFrame("Model", nil, LunaPlayerFrame.Buffs[i], "CooldownFrameTemplate")
		LunaPlayerFrame.Buffs[i].cd:ClearAllPoints()
		LunaPlayerFrame.Buffs[i].cd:SetPoint("TOPLEFT", LunaPlayerFrame.Buffs[i], "TOPLEFT")
		LunaPlayerFrame.Buffs[i].cd:SetHeight(36)
		LunaPlayerFrame.Buffs[i].cd:SetWidth(36)
		
		LunaPlayerFrame.Buffs[i].stacks = LunaPlayerFrame.Buffs[i]:CreateFontString(nil, "OVERLAY", LunaPlayerFrame.Buffs[i])
		LunaPlayerFrame.Buffs[i].stacks:SetPoint("BOTTOMRIGHT", LunaPlayerFrame.Buffs[i], 0, 0)
		LunaPlayerFrame.Buffs[i].stacks:SetJustifyH("LEFT")
		LunaPlayerFrame.Buffs[i].stacks:SetShadowColor(0, 0, 0)
		LunaPlayerFrame.Buffs[i].stacks:SetShadowOffset(0.8, -0.8)
		LunaPlayerFrame.Buffs[i].stacks:SetTextColor(1,1,1)
	end

	LunaPlayerFrame.Debuffs = {}

	LunaPlayerFrame.Debuffs[1] = CreateFrame("Button", "LunaPlayerFrameDebuff1", LunaPlayerFrame.AuraAnchor)
	LunaPlayerFrame.Debuffs[1].texturepath = UnitDebuff("player",1)
	LunaPlayerFrame.Debuffs[1].id = 17
	LunaPlayerFrame.Debuffs[1]:SetNormalTexture(LunaPlayerFrame.Debuffs[1].texturepath)
	LunaPlayerFrame.Debuffs[1]:SetScript("OnEnter", Luna_Player_SetBuffTooltip)
	LunaPlayerFrame.Debuffs[1]:SetScript("OnLeave", Luna_Player_SetBuffTooltipLeave)
	
	LunaPlayerFrame.Debuffs[1].cd = CreateFrame("Model", nil, LunaPlayerFrame.Debuffs[1], "CooldownFrameTemplate")
	LunaPlayerFrame.Debuffs[1].cd:ClearAllPoints()
	LunaPlayerFrame.Debuffs[1].cd:SetPoint("TOPLEFT", LunaPlayerFrame.Debuffs[1], "TOPLEFT")
	LunaPlayerFrame.Debuffs[1].cd:SetHeight(36)
	LunaPlayerFrame.Debuffs[1].cd:SetWidth(36)

	LunaPlayerFrame.Debuffs[1].stacks = LunaPlayerFrame.Debuffs[1]:CreateFontString(nil, "OVERLAY", LunaPlayerFrame.Debuffs[1])
	LunaPlayerFrame.Debuffs[1].stacks:SetPoint("BOTTOMRIGHT", LunaPlayerFrame.Debuffs[1], 0, 0)
	LunaPlayerFrame.Debuffs[1].stacks:SetJustifyH("LEFT")
	LunaPlayerFrame.Debuffs[1].stacks:SetShadowColor(0, 0, 0)
	LunaPlayerFrame.Debuffs[1].stacks:SetShadowOffset(0.8, -0.8)
	LunaPlayerFrame.Debuffs[1].stacks:SetTextColor(1,1,1)

	for i=2, 16 do
		LunaPlayerFrame.Debuffs[i] = CreateFrame("Button", "LunaPlayerFrameDebuff"..i, LunaPlayerFrame.AuraAnchor)
		LunaPlayerFrame.Debuffs[i].texturepath = UnitDebuff("player",i)
		LunaPlayerFrame.Debuffs[i].id = i+16
		LunaPlayerFrame.Debuffs[i]:SetNormalTexture(LunaPlayerFrame.Debuffs[i].texturepath)
		LunaPlayerFrame.Debuffs[i]:SetScript("OnEnter", Luna_Player_SetBuffTooltip)
		LunaPlayerFrame.Debuffs[i]:SetScript("OnLeave", Luna_Player_SetBuffTooltipLeave)
		
		LunaPlayerFrame.Debuffs[i].cd = CreateFrame("Model", nil, LunaPlayerFrame.Debuffs[i], "CooldownFrameTemplate")
		LunaPlayerFrame.Debuffs[i].cd:ClearAllPoints()
		LunaPlayerFrame.Debuffs[i].cd:SetPoint("TOPLEFT", LunaPlayerFrame.Debuffs[i], "TOPLEFT")
		LunaPlayerFrame.Debuffs[i].cd:SetHeight(36)
		LunaPlayerFrame.Debuffs[i].cd:SetWidth(36)
		
		LunaPlayerFrame.Debuffs[i].stacks = LunaPlayerFrame.Debuffs[i]:CreateFontString(nil, "OVERLAY", LunaPlayerFrame.Debuffs[i])
		LunaPlayerFrame.Debuffs[i].stacks:SetPoint("BOTTOMRIGHT", LunaPlayerFrame.Debuffs[i], 0, 0)
		LunaPlayerFrame.Debuffs[i].stacks:SetJustifyH("LEFT")
		LunaPlayerFrame.Debuffs[i].stacks:SetShadowColor(0, 0, 0)
		LunaPlayerFrame.Debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
		LunaPlayerFrame.Debuffs[i].stacks:SetTextColor(1,1,1)
	end
	
	
	-- Healthbar
	local healthbar = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	healthbar:SetStatusBarTexture(LunaOptions.statusbartexture)
	healthbar:SetFrameStrata("MEDIUM")
	LunaPlayerFrame.bars["Healthbar"] = healthbar
	
	local incHeal = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	incHeal:SetStatusBarTexture(LunaOptions.statusbartexture)
	incHeal:SetMinMaxValues(0, 1)
	incHeal:SetValue(1)
	incHeal:SetStatusBarColor(0, 1, 0, 0.6)
	LunaPlayerFrame.incHeal = incHeal

	-- Healthbar background
	local hpbg = LunaPlayerFrame:CreateTexture(nil, "BACKGROUND")
	hpbg:SetAllPoints(healthbar)
	hpbg:SetTexture(.25,.25,.25,.25)
	LunaPlayerFrame.bars["Healthbar"].hpbg = hpbg

	-- Healthbar text
	local hpp = healthbar:CreateFontString(nil, "OVERLAY", healthbar)
	hpp:SetPoint("RIGHT", -2, 0)
	hpp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	hpp:SetShadowColor(0, 0, 0)
	hpp:SetShadowOffset(0.8, -0.8)
	hpp:SetTextColor(1,1,1)
	hpp:SetJustifyH("RIGHT")
	hpp:SetJustifyV("MIDDLE")
	LunaPlayerFrame.bars["Healthbar"].hpp = hpp

	local name = healthbar:CreateFontString(nil, "OVERLAY", healthbar)
	name:SetPoint("LEFT", 2, 0)
	name:SetJustifyH("LEFT")
	name:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	name:SetShadowColor(0, 0, 0)
	name:SetShadowOffset(0.8, -0.8)
	name:SetTextColor(1,1,1)
	name:SetText(UnitName("player"))
	LunaPlayerFrame.name = name

	-- Manabar
	local powerbar = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	powerbar:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaPlayerFrame.bars["Powerbar"] = powerbar
	
	powerbar.EnergyUpdate = function()
		local time = GetTime()
		local fsPosition, energyPosition
		if (time - powerbar.Ticker.startTime) >= 2 then 		--Ticks happen every 2 sec
			powerbar.Ticker.startTime = GetTime()
		end
		if powerbar.Ticker.fsstart then
			if (time - powerbar.Ticker.fsstart) >= 5 then
				powerbar.Ticker.fsstart = nil
				if UnitPowerType("player") == 0 then
					powerbar.Ticker:Hide()
				end
			else
				fsPosition = (((time - powerbar.Ticker.fsstart) / 5)* powerbar:GetWidth())
			end
		end
		energyPosition = (((time - powerbar.Ticker.startTime) / 2)* powerbar:GetWidth())
		if UnitPowerType("player") == 0 and fsPosition then
			powerbar.Ticker:SetPoint("CENTER", powerbar, "LEFT", fsPosition, 0)
		else
			powerbar.Ticker:SetPoint("CENTER", powerbar, "LEFT", energyPosition, 0)
		end
	end
	
	-- Manabar background
	local ppbg = powerbar:CreateTexture(nil, "BORDER")
	ppbg:SetAllPoints(powerbar)
	ppbg:SetTexture(.25,.25,.25,.25)
	powerbar.ppbg = ppbg

	local ppp = powerbar:CreateFontString(nil, "OVERLAY", powerbar)
	ppp:SetPoint("RIGHT", -2, 0)
	ppp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	ppp:SetShadowColor(0, 0, 0)
	ppp:SetShadowOffset(0.8, -0.8)
	ppp:SetTextColor(1,1,1)
	ppp:SetJustifyH("RIGHT")
	powerbar.ppp = ppp

	powerbar.Ticker = powerbar:CreateTexture(nil, "OVERLAY")
	powerbar.Ticker:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	powerbar.Ticker:SetVertexColor(1, 1, 1, 1)
	powerbar.Ticker:SetBlendMode("ADD")
	powerbar.Ticker:SetWidth(3)
	powerbar.oldMana = 0
	powerbar.Ticker.startTime = nil
	
	local lvl
	lvl = powerbar:CreateFontString(nil, "OVERLAY")
	lvl:SetPoint("LEFT", powerbar, "LEFT", 2, 0)
	lvl:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	lvl:SetShadowColor(0, 0, 0)
	lvl:SetShadowOffset(0.8, -0.8)
	lvl:SetText(UnitLevel("player"))
	LunaPlayerFrame.Lvl = lvl
	local color = GetDifficultyColor(UnitLevel("player"))
	LunaPlayerFrame.Lvl:SetVertexColor(color.r, color.g, color.b)

	local class = powerbar:CreateFontString(nil, "OVERLAY")
	class:SetPoint("LEFT", lvl, "RIGHT",  1, 0)
	class:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	class:SetShadowColor(0, 0, 0)
	class:SetShadowOffset(0.8, -0.8)
	class:SetText(UnitClass("player"))
	LunaPlayerFrame.Class = class
	local _,class = UnitClass("player")
	LunaPlayerFrame.Class:SetVertexColor(unpack(LunaOptions.ClassColors[class]))

	-- Castbar
	local Castbar = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	Castbar:SetStatusBarTexture(LunaOptions.statusbartexture)
	Castbar:SetStatusBarColor(1, 0.7, 0.3)
	Castbar.maxValue = 0
	Castbar.delaySum = 0
	Castbar.holdTime = 0
	Castbar:Hide()
	LunaPlayerFrame.bars.Castbar = Castbar

	-- Add a background
	local Background = Castbar:CreateTexture(nil, 'BACKGROUND')
	Background:SetAllPoints(Castbar)
	Background:SetTexture(0, 0, 1, 0.20)
	Castbar.bg = Background

	-- Add a timer
	local Time = Castbar:CreateFontString(nil, "OVERLAY", castbar)
	Time:SetFont(LunaOptions.font, 10)
	Time:SetTextColor(1, 0.82, 0, 1)
	Time:SetShadowColor(0, 0, 0)
	Time:SetShadowOffset(0.8, -0.8)
	Time:SetPoint("RIGHT", Castbar)
	Castbar.Time = Time

	-- Add spell text
	local Text = Castbar:CreateFontString(nil, "OVERLAY", castbar)
	Text:SetFont(LunaOptions.font, 10)
	Text:SetTextColor(1, 0.82, 0, 1)
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(0.8, -0.8)
	Text:SetPoint("LEFT", Castbar)
	Castbar.Text = Text

	LunaPlayerFrame.iconholder = CreateFrame("Frame", nil, LunaPlayerFrame)
	LunaPlayerFrame.iconholder:SetFrameStrata("MEDIUM")
	
	LunaPlayerFrame.feedbackText = LunaPlayerFrame.iconholder:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
	LunaPlayerFrame.feedbackText:SetTextColor(1,1,1)
	LunaPlayerFrame.feedbackFontHeight = 20
	LunaPlayerFrame.feedbackStartTime = 0
	
	LunaPlayerFrame.RaidIcon = LunaPlayerFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaPlayerFrame.RaidIcon:SetHeight(20)
	LunaPlayerFrame.RaidIcon:SetWidth(20)
	LunaPlayerFrame.RaidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

	LunaPlayerFrame.PVPRank = LunaPlayerFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaPlayerFrame.PVPRank:SetHeight(10)
	LunaPlayerFrame.PVPRank:SetWidth(10)

	LunaPlayerFrame.Leader = LunaPlayerFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaPlayerFrame.Leader:SetHeight(10)
	LunaPlayerFrame.Leader:SetWidth(10)
	LunaPlayerFrame.Leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")

	LunaPlayerFrame.Loot = LunaPlayerFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaPlayerFrame.Loot:SetHeight(10)
	LunaPlayerFrame.Loot:SetWidth(10)
	LunaPlayerFrame.Loot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")

	LunaPlayerFrame.Combat = LunaPlayerFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaPlayerFrame.Combat:SetHeight(14)
	LunaPlayerFrame.Combat:SetWidth(14)
	LunaPlayerFrame.Combat:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	LunaPlayerFrame.Combat:SetTexCoord(0.57, 0.90, 0.08, 0.41)
		
	-- Druidbar
	local druidbar = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	druidbar:SetStatusBarTexture(LunaOptions.statusbartexture)
	LunaPlayerFrame.bars["Druidbar"] = druidbar
	druidbar:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
	
	-- Druidbar background
	local dbbg = druidbar:CreateTexture(nil, "BORDER")
	dbbg:SetAllPoints(druidbar)
	dbbg:SetTexture(.25,.25,.25,.25)
	druidbar.dbbg = dbbg
	druidbar.dbbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)

	local dbp = druidbar:CreateFontString(nil, "OVERLAY", druidbar)
	dbp:SetPoint("CENTER", druidbar)
	dbp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	dbp:SetShadowColor(0, 0, 0)
	dbp:SetShadowOffset(0.8, -0.8)
	dbp:SetTextColor(1,1,1)
	dbp:SetJustifyH("CENTER")
	druidbar.dbp = dbp
	
	-- Totembar
	
	LunaPlayerFrame.totems = {}
	LunaPlayerFrame.bars["Totembar"] = CreateFrame("Frame", nil, LunaPlayerFrame)
	for i=1,4 do
		LunaPlayerFrame.totems[i] = CreateFrame("StatusBar", nil, LunaPlayerFrame.bars["Totembar"])
		LunaPlayerFrame.totems[i]:SetStatusBarTexture(LunaOptions.statusbartexture)
		LunaPlayerFrame.totems[i]:Hide()
		LunaPlayerFrame.totems[i]:SetStatusBarColor(unpack(totemcolors[i]))
		LunaPlayerFrame.totems[i]:SetMinMaxValues(0,1)
		LunaPlayerFrame.totems[i]:SetValue(0)
	end
	LunaPlayerFrame.totems[1]:SetPoint("TOPLEFT", LunaPlayerFrame.bars["Totembar"], "TOPLEFT")
	for i=2,4 do
		LunaPlayerFrame.totems[i]:SetPoint("TOPLEFT", LunaPlayerFrame.totems[i-1], "TOPRIGHT",  1, 0)
	end
		
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
	LunaPlayerFrame:RegisterEvent("PLAYER_AURAS_CHANGED")
	LunaPlayerFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
	
	if not LunaOptions.BlizzPlayer then
		Luna_HideBlizz(PlayerFrame)
	end
	
	for k,v in pairs(frameoptions.bars) do
		if v[1] == "Castbar" and v[2] > 0 then
			LunaPlayerFrame:RegisterEvent("SPELLCAST_CHANNEL_START")
			LunaPlayerFrame:RegisterEvent("SPELLCAST_CHANNEL_STOP")
			LunaPlayerFrame:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
			LunaPlayerFrame:RegisterEvent("SPELLCAST_DELAYED")
			LunaPlayerFrame:RegisterEvent("SPELLCAST_FAILED")
			LunaPlayerFrame:RegisterEvent("SPELLCAST_INTERRUPTED")
			LunaPlayerFrame:RegisterEvent("SPELLCAST_START")
			LunaPlayerFrame:RegisterEvent("SPELLCAST_STOP")
		end
	end
	
	LunaPlayerFrame:SetScript("OnClick", Luna_OnClick)
	LunaPlayerFrame:SetScript("OnEvent", Luna_Player_OnEvent)
	LunaPlayerFrame.bars["Castbar"]:SetScript("OnUpdate", Luna_Player_OnUpdate)
	LunaPlayerFrame.bars["Totembar"]:SetScript("OnUpdate", Luna_Player_TotemOnUpdate)
	powerbar:SetScript("OnUpdate", LunaPlayerFrame.bars["Powerbar"].EnergyUpdate)
	
	if LunaOptions.hideBlizzCastbar == 1 then
		Luna_HideBlizz(CastingBarFrame)
	end
	
	LunaPlayerFrame:SetScript("OnUpdate", CombatFeedback_OnUpdate)
	
	LunaPlayerFrame.dropdown = CreateFrame("Frame", "LunaUnitDropDownMenu", UIParent, "UIDropDownMenuTemplate")
	LunaPlayerFrame.initialize = function() if LunaPlayerFrame.dropdown then 
												UnitPopup_ShowMenu(LunaPlayerFrame.dropdown, "SELF", LunaPlayerFrame.unit)
											end
								end
	UIDropDownMenu_Initialize(LunaPlayerFrame.dropdown, LunaPlayerFrame.initialize, "MENU")
	
	function LunaPlayerFrame.AdjustBars()
		local frameHeight = LunaPlayerFrame:GetHeight()
		local frameWidth
		local anchor
		local totalWeight = 0
		local gaps = -1
		local _, class = UnitClass("player")
		local CastBarHeightWeight
		for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
			if v[1] == "Castbar" then
				CastBarHeightWeight = v[2]
				break
			end
		end
		local castbar = LunaPlayerFrame.bars.Castbar
		if (castbar.casting or castbar.channeling) and CastBarHeightWeight > 0 then
			castbar:Show()
		else
			castbar:Hide()
		end
		if class == "DRUID" and UnitPowerType("player") ~= 0 and LunaOptions.DruidBar == 1 then
			LunaPlayerFrame.bars["Druidbar"]:Show()
		else
			LunaPlayerFrame.bars["Druidbar"]:Hide()
		end
		if class == "SHAMAN" and LunaOptions.TotemBar == 1 and (LunaPlayerFrame.totems[1].active or LunaPlayerFrame.totems[2].active or LunaPlayerFrame.totems[3].active or LunaPlayerFrame.totems[4].active) then
			LunaPlayerFrame.bars["Totembar"]:Show()
		else
			LunaPlayerFrame.bars["Totembar"]:Hide()
		end
		if LunaOptions.frames["LunaPlayerFrame"].portrait > 1 then    -- We have a square portrait
			frameWidth = (LunaPlayerFrame:GetWidth()-frameHeight)
			LunaPlayerFrame.bars["Portrait"]:SetPoint("TOPLEFT", LunaPlayerFrame, "TOPLEFT")
			LunaPlayerFrame.bars["Portrait"]:SetHeight(frameHeight+1)
			LunaPlayerFrame.bars["Portrait"]:SetWidth(frameHeight)
			anchor = {"TOPLEFT", LunaPlayerFrame.bars["Portrait"], "TOPRIGHT"}
		else
			frameWidth = LunaPlayerFrame:GetWidth()  -- We have a Bar-Portrait or no portrait
			anchor = {"TOPLEFT", LunaPlayerFrame, "TOPLEFT"}
		end
		for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
			if LunaPlayerFrame.bars[v[1]]:IsShown() then
				totalWeight = totalWeight + v[2]
				gaps = gaps + 1
			end
		end
		local firstbar = 1
		for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
			local bar = LunaPlayerFrame.bars[v[1]]
			local weight = v[2]/totalWeight
			local height = (frameHeight-gaps)*weight
			bar:ClearAllPoints()
			bar:SetHeight(height)
			bar:SetWidth(frameWidth)
			bar.rank = k
			bar.weight = v[2]
			
			if not firstbar and bar:IsShown() then
				bar:SetPoint(anchor[1], anchor[2], anchor[3], 0, -1)
				anchor = {"TOPLEFT", bar, "BOTTOMLEFT"}
			elseif bar:IsShown() then
				bar:SetPoint(anchor[1], anchor[2], anchor[3])
				firstbar = nil
				anchor = {"TOPLEFT", bar, "BOTTOMLEFT"}
			end			
		end

		LunaUnitFrames.PlayerUpdateHeal(UnitName("player"))
		local healthbar = LunaPlayerFrame.bars.Healthbar
		local healthheight = (healthbar:GetHeight()*LunaOptions.textscale)
		if healthheight > 0 then
			healthbar.hpp:SetFont(LunaOptions.font, healthheight)
			healthbar.hpp:SetHeight(healthbar:GetHeight())
			healthbar.hpp:SetWidth(healthbar:GetWidth()*0.35)
			LunaPlayerFrame.name:SetFont(LunaOptions.font, healthheight)
			LunaPlayerFrame.name:SetWidth(healthbar:GetWidth()*0.65)
		end
		if healthbar:GetHeight() < 6 then
			healthbar.hpp:Hide()
			LunaPlayerFrame.name:Hide()
		else
			healthbar.hpp:Show()
			LunaPlayerFrame.name:Show()
		end

		local powerbar = LunaPlayerFrame.bars.Powerbar
		local powerheight = (powerbar:GetHeight()*LunaOptions.textscale)
		if powerheight > 0 then
			powerbar.ppp:SetFont(LunaOptions.font, powerheight)
			LunaPlayerFrame.Lvl:SetFont(LunaOptions.font, powerheight)
			LunaPlayerFrame.Class:SetFont(LunaOptions.font, powerheight)
		end
		if powerbar:GetHeight() < 6 then
			powerbar.ppp:Hide()
			LunaPlayerFrame.Lvl:Hide()
			LunaPlayerFrame.Class:Hide()
		else
			powerbar.ppp:Show()
			LunaPlayerFrame.Lvl:Show()
			LunaPlayerFrame.Class:Show()
		end

		local castheight = (castbar:GetHeight())
		if castheight > 5 then
			castbar.Text:SetFont(LunaOptions.font, castheight)
			castbar.Time:SetFont(LunaOptions.font, castheight)
		end
		if castbar:GetHeight() < 6 then
			castbar.Text:Hide()
			castbar.Time:Hide()
		else
			castbar.Text:Show()
			castbar.Time:Show()
		end

		local druidbar = LunaPlayerFrame.bars.Druidbar
		local dbheight = (druidbar:GetHeight())
		if druidbar:GetHeight() < 6 then
			druidbar.dbp:Hide()
		else
			druidbar.dbp:SetFont(LunaOptions.font, dbheight)
			druidbar.dbp:Show()
		end
--		LunaPlayerFrame.bars["Totembar"]:SetHeight(LunaPlayerFrame.bars["Totembar"]:GetHeight()+1)
		for i=1, 4 do
			if 1 then
				LunaPlayerFrame.totems[i]:Show()
			else
				LunaPlayerFrame.totems[i]:Hide()
			end
			LunaPlayerFrame.totems[i]:SetHeight(LunaPlayerFrame.bars["Totembar"]:GetHeight())
			LunaPlayerFrame.totems[i]:SetWidth((frameWidth-3)/4)
		end
		powerbar.Ticker:SetHeight(powerbar:GetHeight())
	end
	
	function LunaPlayerFrame.UpdateBuffSize()
		local frameoptions = LunaOptions.frames.LunaPlayerFrame
		local buffcount = frameoptions.BuffInRow or 16
		if frameoptions.ShowBuffs == 1 then
			for i=1, 16 do
				LunaPlayerFrame.Buffs[i]:Hide()
				LunaPlayerFrame.Debuffs[i]:Hide()
			end
		elseif frameoptions.ShowBuffs == 2 then
			local buffsize = ((LunaPlayerFrame:GetWidth()-(buffcount-1))/buffcount)
			LunaPlayerFrame.AuraAnchor:ClearAllPoints()
			LunaPlayerFrame.AuraAnchor:SetPoint("BOTTOMLEFT", LunaPlayerFrame, "TOPLEFT", -1, 3)
			LunaPlayerFrame.AuraAnchor:SetWidth(LunaPlayerFrame:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaPlayerFrame.Buffs[buffid]:ClearAllPoints()
					LunaPlayerFrame.Buffs[buffid]:SetPoint("BOTTOMLEFT", LunaPlayerFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaPlayerFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaPlayerFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaPlayerFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPlayerFrame.Debuffs[buffid]:ClearAllPoints()
					LunaPlayerFrame.Debuffs[buffid]:SetPoint("BOTTOMLEFT", LunaPlayerFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row)
					LunaPlayerFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaPlayerFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaPlayerFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			Luna_Player_Events:PLAYER_AURAS_CHANGED()
		elseif frameoptions.ShowBuffs == 3 then
			local buffsize = ((LunaPlayerFrame:GetWidth()-(buffcount-1))/buffcount)
			LunaPlayerFrame.AuraAnchor:ClearAllPoints()
			LunaPlayerFrame.AuraAnchor:SetWidth(LunaPlayerFrame:GetWidth())
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaPlayerFrame.Buffs[buffid]:ClearAllPoints()
					LunaPlayerFrame.Buffs[buffid]:SetPoint("TOPLEFT", LunaPlayerFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPlayerFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaPlayerFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaPlayerFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPlayerFrame.Debuffs[buffid]:ClearAllPoints()
					LunaPlayerFrame.Debuffs[buffid]:SetPoint("TOPLEFT", LunaPlayerFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPlayerFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaPlayerFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaPlayerFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			if LunaUnitFrames.frames.ExperienceBar and LunaUnitFrames.frames.ExperienceBar:IsShown() then
				LunaPlayerFrame.AuraAnchor:SetPoint("TOPLEFT", LunaPlayerFrame, "BOTTOMLEFT", -1, -15)
			else
				LunaPlayerFrame.AuraAnchor:SetPoint("TOPLEFT", LunaPlayerFrame, "BOTTOMLEFT", -1, -3)
			end
			Luna_Player_Events:PLAYER_AURAS_CHANGED()
		elseif frameoptions.ShowBuffs == 4 then
			local buffsize = (((LunaPlayerFrame:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaPlayerFrame.AuraAnchor:ClearAllPoints()
			LunaPlayerFrame.AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					LunaPlayerFrame.Buffs[buffid]:ClearAllPoints()
					LunaPlayerFrame.Buffs[buffid]:SetPoint("TOPRIGHT", LunaPlayerFrame.AuraAnchor, "TOPRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaPlayerFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaPlayerFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaPlayerFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPlayerFrame.Debuffs[buffid]:ClearAllPoints()
					LunaPlayerFrame.Debuffs[buffid]:SetPoint("TOPRIGHT", LunaPlayerFrame.AuraAnchor, "BOTTOMRIGHT", ((z-1)*(buffsize+1))*(-1), (buffsize+1)*row*(-1))
					LunaPlayerFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaPlayerFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaPlayerFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaPlayerFrame.AuraAnchor:SetPoint("TOPRIGHT", LunaPlayerFrame, "TOPLEFT", -3, 0)
			Luna_Player_Events:PLAYER_AURAS_CHANGED()
		else
			local buffsize = (((LunaPlayerFrame:GetHeight()/2)-(math.ceil(16/buffcount)-1))/math.ceil(16/buffcount))
			LunaPlayerFrame.AuraAnchor:ClearAllPoints()
			LunaPlayerFrame.AuraAnchor:SetWidth((buffsize*buffcount)+(buffcount-1))
			local buffid = 1
			local row = 0
			while buffid < 17 do
				for z=1, buffcount do
					local buff = LunaPlayerFrame.Buffs[buffid]
					LunaPlayerFrame.Buffs[buffid]:ClearAllPoints()
					LunaPlayerFrame.Buffs[buffid]:SetPoint("TOPLEFT", LunaPlayerFrame.AuraAnchor, "TOPLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPlayerFrame.Buffs[buffid]:SetHeight(buffsize)
					LunaPlayerFrame.Buffs[buffid]:SetWidth(buffsize)
					LunaPlayerFrame.Buffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					LunaPlayerFrame.Debuffs[buffid]:ClearAllPoints()
					LunaPlayerFrame.Debuffs[buffid]:SetPoint("TOPLEFT", LunaPlayerFrame.AuraAnchor, "BOTTOMLEFT", ((z-1)*(buffsize+1)), (buffsize+1)*row*(-1))
					LunaPlayerFrame.Debuffs[buffid]:SetHeight(buffsize)
					LunaPlayerFrame.Debuffs[buffid]:SetWidth(buffsize)
					LunaPlayerFrame.Debuffs[buffid].stacks:SetFont(LunaOptions.font, buffsize*0.75)
					
					buffid = buffid + 1
					if buffid == 17 then
						break
					end
				end
				row = row + 1
			end
			LunaPlayerFrame.AuraAnchor:SetPoint("TOPLEFT", LunaPlayerFrame, "TOPRIGHT", 3, 0)
			Luna_Player_Events:PLAYER_AURAS_CHANGED()
		end
		local scale = LunaPlayerFrame.Buffs[1]:GetHeight()/36
		for i=1, 16 do
			LunaPlayerFrame.Buffs[i].cd:SetScale(scale)
			LunaPlayerFrame.Debuffs[i].cd:SetScale(scale)
		end
	end
	SetIconPositions()
	LunaPlayerFrame.AdjustBars()
	LunaPlayerFrame.UpdateBuffSize()
	LunaUnitFrames:UpdatePlayerFrame()
	AceEvent:RegisterEvent("HealComm_Healupdate", LunaUnitFrames.PlayerUpdateHeal)
	AceEvent:RegisterEvent("DruidManaLib_Manaupdate", LunaUnitFrames.DruidBarUpdate)
	AceEvent:RegisterEvent("fiveSec", LunaUnitFrames.fiveSec)
end

function LunaUnitFrames.PlayerUpdateHeal(target)
	if target ~= UnitName("player") then
		return
	end
	local healed = HealComm:getHeal(target)
	local health, maxHealth = UnitHealth(LunaPlayerFrame.unit), UnitHealthMax(LunaPlayerFrame.unit)
	if( healed > 0 and (health < maxHealth or (LunaOptions.overheal or 20) > 0 )) then
		LunaPlayerFrame.incHeal:Show()
		local healthbar = LunaPlayerFrame.bars.Healthbar
		local healthWidth = healthbar:GetWidth() * (health / maxHealth)
		local incWidth = healthbar:GetWidth() * (healed / maxHealth)
		if (healthWidth + incWidth) > (healthbar:GetWidth() * (1+((LunaOptions.overheal or 20)/100)) ) then
			incWidth = healthbar:GetWidth() * (1+((LunaOptions.overheal or 20)/100)) - healthWidth
		end
		LunaPlayerFrame.incHeal:SetWidth(incWidth)
		LunaPlayerFrame.incHeal:SetHeight(healthbar:GetHeight())
		LunaPlayerFrame.incHeal:ClearAllPoints()
		LunaPlayerFrame.incHeal:SetPoint("TOPLEFT", LunaPlayerFrame.bars["Healthbar"], "TOPLEFT", healthWidth, 0)
	else
		LunaPlayerFrame.incHeal:Hide()
	end
end

function LunaUnitFrames.DruidBarUpdate()
	local mana, maxmana = DruidManaLib:GetMana()
	LunaPlayerFrame.bars["Druidbar"]:SetMinMaxValues(0, maxmana)
	LunaPlayerFrame.bars["Druidbar"]:SetValue(mana)
	LunaPlayerFrame.bars["Druidbar"].dbp:SetText(mana.."/"..maxmana)
end

function LunaUnitFrames.SetTotemTimer(totemtype, timeleft)
	LunaPlayerFrame.totems[totemtype].maxValue = GetTime()+timeleft
	LunaPlayerFrame.totems[totemtype]:SetMinMaxValues(0,timeleft)
	LunaPlayerFrame.totems[totemtype]:SetValue(0)
	LunaPlayerFrame.totems[totemtype].active = 1
	LunaPlayerFrame.AdjustBars()
end

function LunaUnitFrames.fiveSec()
	LunaPlayerFrame.bars["Powerbar"].Ticker.fsstart = GetTime()
	if LunaOptions.fsTicker then
		LunaPlayerFrame.bars["Powerbar"].Ticker:Show()
	end
end

function LunaUnitFrames:ConvertPlayerPortrait()
	if LunaOptions.frames["LunaPlayerFrame"].portrait == 1 then
		table.insert(LunaOptions.frames["LunaPlayerFrame"].bars, 1, {"Portrait", 4})
	else
		for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
			if v[1] == "Portrait" then
				table.remove(LunaOptions.frames["LunaPlayerFrame"].bars, k)
			end
		end
	end
	UIDropDownMenu_SetText("Healthbar", LunaOptionsFrame.pages[1].BarSelect)
	LunaOptionsFrame.pages[1].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames["LunaPlayerFrame"].bars))
	for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
		if v[1] == UIDropDownMenu_GetText(LunaOptionsFrame.pages[1].BarSelect) then
			LunaOptionsFrame.pages[1].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[1].barorder:SetValue(k)
			break
		end
	end
	SetIconPositions()
	LunaPlayerFrame.AdjustBars()
end

function LunaUnitFrames:UpdatePlayerFrame()
	if LunaOptions.frames["LunaPlayerFrame"].enabled == 0 then
		LunaPlayerFrame:Hide()
		return
	else
		LunaPlayerFrame:Show()
	end
	local _,class = UnitClass("player")
	
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
	
	if LunaOptions.colornames then
		LunaPlayerFrame.name:SetTextColor(unpack(LunaOptions.ClassColors[class]))
	else
		LunaPlayerFrame.name:SetTextColor(1,1,1)
	end
	
	local color
	if LunaOptions.hbarcolor then
		color = LunaOptions.ClassColors[class]
	else
		color = LunaUnitFrames:GetHealthColor("player")
	end
	LunaPlayerFrame.bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
	LunaPlayerFrame.bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)

	Luna_Player_Events.UNIT_HEALTH()
	Luna_Player_Events.UNIT_MANA()
	Luna_Player_Events.PARTY_LEADER_CHANGED()
	Luna_Player_Events.RAID_TARGET_UPDATE()
	Luna_Player_Events.UNIT_DISPLAYPOWER()
	-- Luna_Player_Events.UNIT_PORTRAIT_UPDATE()
	Luna_Player_Events.UNIT_LEVEL()
	Luna_Player_Events.PARTY_LOOT_METHOD_CHANGED()
	Luna_Player_Events.PLAYER_UPDATE_RESTING()
end

function Luna_Player_Events:SPELLCAST_CHANNEL_START()
	local castbar = LunaPlayerFrame.bars.Castbar
	castbar.maxValue = 1
	castbar.startTime = GetTime()
	castbar.endTime = castbar.startTime + (arg1 / 1000)
	castbar.duration = arg1 / 1000
	castbar:SetMinMaxValues(castbar.startTime, castbar.endTime)
	castbar:SetValue(castbar.endTime)
	castbar.holdTime = 0
	castbar.casting = nil
	castbar.channeling = 1
	castbar.delaySum = 0
	castbar.Text:SetText("Channeling")
	LunaPlayerFrame.AdjustBars()
end

function Luna_Player_Events:SPELLCAST_CHANNEL_UPDATE()
	local castbar = LunaPlayerFrame.bars.Castbar
	if (arg1 == 0) then
		castbar.channeling = nil
		castbar.delaySum = 0
		LunaPlayerFrame.AdjustBars()
	elseif (castbar:IsShown()) then
		local origDuration = castbar.endTime - castbar.startTime
		local elapsedTime = GetTime() - castbar.startTime;
		local losttime = origDuration*1000 - elapsedTime*1000 - arg1;
		castbar.delaySum = castbar.delaySum + losttime;
		castbar.startTime = castbar.endTime - origDuration;
		castbar.endTime = GetTime() + (arg1 / 1000);
		castbar:SetMinMaxValues(castbar.startTime, castbar.endTime);
	end
end

function Luna_Player_Events:SPELLCAST_DELAYED()
	local castbar = LunaPlayerFrame.bars.Castbar
	if (arg1) and castbar.startTime then
		castbar.startTime = castbar.startTime + (arg1 / 1000);
		castbar.maxValue = castbar.maxValue + (arg1 / 1000);
		castbar.delaySum = castbar.delaySum + arg1;
		castbar:SetMinMaxValues(castbar.startTime, castbar.maxValue);
	end
end

function Luna_Player_Events:SPELLCAST_START()
	local castbar = LunaPlayerFrame.bars.Castbar
	castbar.startTime = GetTime()
	castbar.maxValue = castbar.startTime + (arg2 / 1000)
	castbar.holdTime = 0
	castbar.casting = 1
	castbar.delaySum = 0
	castbar.Text:SetText(arg1)
	castbar:SetMinMaxValues(castbar.startTime, castbar.maxValue)
	castbar:SetValue(castbar.startTime)
	LunaPlayerFrame.AdjustBars()
end

function Luna_Player_Events:SPELLCAST_STOP()
	local castbar = LunaPlayerFrame.bars.Castbar
	if castbar.casting == 1 or event == "SPELLCAST_CHANNEL_STOP" then
		castbar.casting = nil
		castbar.channeling = nil
		LunaPlayerFrame.AdjustBars()
	end
end
Luna_Player_Events.SPELLCAST_INTERRUPTED = Luna_Player_Events.SPELLCAST_STOP
Luna_Player_Events.SPELLCAST_FAILED = Luna_Player_Events.SPELLCAST_STOP
Luna_Player_Events.SPELLCAST_CHANNEL_STOP = Luna_Player_Events.SPELLCAST_STOP

function Luna_Player_Events:PLAYER_ALIVE()
	LunaUnitFrames:UpdatePlayerFrame()
end

function Luna_Player_Events:PLAYER_AURAS_CHANGED()
	local found, dtype
	local pos
	for i=1, 16 do
		_,_,dtype = UnitDebuff("player", i, 1)
		if dtype and LunaOptions.HighlightDebuffs then
			LunaPlayerFrame:SetBackdropColor(unpack(LunaOptions.DebuffTypeColor[dtype],1))
			found = true
		end
	end
	if not found then
		LunaPlayerFrame:SetBackdropColor(0,0,0,1)
	end
	if LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 1 then
		return
	end
	for i=1, 16 do
		local path = GetPlayerBuffTexture(GetPlayerBuff(i-1,"HELPFUL"))
		local stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HELPFUL"))
		local buff = LunaPlayerFrame.Buffs[i]
		buff.texturepath = path
		if buff.texturepath then
			buff:EnableMouse(1)
			buff:Show()
			if stacks > 1 then
				buff.stacks:SetText(stacks)
				buff.stacks:Show()
			else
				buff.stacks:Hide()
			end
		else
			buff:EnableMouse(0)
			buff:Hide()
			if not pos then
				pos = i
			end
		end
		buff:SetNormalTexture(buff.texturepath)
	end
	if not pos then
		pos = 17
	end
	LunaPlayerFrame.AuraAnchor:SetHeight((LunaPlayerFrame.Buffs[1]:GetHeight()*math.ceil((pos-1)/(LunaOptions.frames["LunaPlayerFrame"].BuffInRow or 16)))+(math.ceil((pos-1)/(LunaOptions.frames["LunaPlayerFrame"].BuffInRow or 16))-1)+1.1)
	for i=1, 16 do
		local path = GetPlayerBuffTexture(GetPlayerBuff(i-1,"HARMFUL"))
		local stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HARMFUL"))
		local debuff = LunaPlayerFrame.Debuffs[i]
		debuff.texturepath = path
		if debuff.texturepath then
			debuff:EnableMouse(1)
			debuff:Show()
			if stacks > 1 then
				debuff.stacks:SetText(stacks)
				debuff.stacks:Show()
			else
				debuff.stacks:Hide()
			end
		else
			debuff:EnableMouse(0)
			debuff:Hide()
		end
		debuff:SetNormalTexture(debuff.texturepath)
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
	LunaUnitFrames.PlayerUpdateHeal(UnitName("player"))
	local healthbar = LunaPlayerFrame.bars.Healthbar
	healthbar:SetMinMaxValues(0, UnitHealthMax("player"))
	if (UnitIsDead("player") or UnitIsGhost("player")) then
		healthbar.hpp:SetText("DEAD")
		healthbar:SetValue(0)
	else
		healthbar.hpp:SetText(LunaUnitFrames:GetHealthString("player"))
		healthbar:SetValue(UnitHealth("player"))
		if not LunaOptions.hbarcolor then
			local color = LunaUnitFrames:GetHealthColor("player")
			healthbar:SetStatusBarColor(color[1],color[2],color[3])
			healthbar.hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
		end
	end
end
Luna_Player_Events.UNIT_MAXHEALTH = Luna_Player_Events.UNIT_HEALTH;

function Luna_Player_Events:UNIT_MANA()
	local powerbar = LunaPlayerFrame.bars.Powerbar
	if not powerbar.Ticker.startTime or UnitMana("player") > powerbar.oldMana then
		powerbar.Ticker.startTime = GetTime()
	end
	powerbar.oldMana = UnitMana("player")
	powerbar:SetMinMaxValues(0, UnitManaMax("player"))
	if (UnitIsDead("player") or UnitIsGhost("player")) then
		powerbar:SetValue(0)
	else
		powerbar:SetValue(UnitMana("player"))
	end
	powerbar.ppp:SetText(LunaUnitFrames:GetPowerString("player"))
end
Luna_Player_Events.UNIT_MAXMANA = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_ENERGY = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_MAXENERGY = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_RAGE = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_MAXRAGE = Luna_Player_Events.UNIT_MANA;

function Luna_Player_Events:UNIT_DISPLAYPOWER()
	local playerpower = UnitPowerType("player")
	local powerbar = LunaPlayerFrame.bars.Powerbar
	
	local type = "Mana"
	if playerpower == 1 then
		type = "Rage"
		powerbar.Ticker:Hide()
	elseif playerpower == 3 then
		type = "Energy"
		if LunaOptions.EnergyTicker == 1 then
			powerbar.Ticker:Show()
		else
			powerbar.Ticker:Hide()
		end
	else
		if powerbar.Ticker.fsstart and LunaOptions.fsTicker then
			powerbar.Ticker:Show()
		else
			powerbar.Ticker:Hide()
		end
	end
	local color = LunaOptions.PowerColors[type]
	powerbar:SetStatusBarColor(color[1], color[2], color[3])
	powerbar.ppbg:SetVertexColor(color[1], color[2], color[3], .25)
	LunaPlayerFrame.AdjustBars()
	Luna_Player_Events.UNIT_MANA()
end

function Luna_Player_Events:UNIT_PORTRAIT_UPDATE()
	local portrait = LunaPlayerFrame.bars.Portrait
	if(portrait.type == "3D") then
		if(not UnitExists("player") or not UnitIsConnected("player") or not UnitIsVisible("player")) then
			portrait:SetModelScale(4.25)
			portrait:SetPosition(0, 0, -1)
			portrait:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
		else
			portrait:SetUnit("player")
			portrait:SetCamera(0)
		end
	else
		SetPortraitTexture(portrait, "player")
	end
end
Luna_Player_Events.UNIT_MODEL_CHANGED = Luna_Player_Events.UNIT_PORTRAIT_UPDATE

function Luna_Player_Events:UNIT_LEVEL()
	LunaPlayerFrame.Lvl:SetText(UnitLevel("player"))
	local color = GetDifficultyColor(UnitLevel("player"))
	LunaPlayerFrame.Lvl:SetVertexColor(color.r, color.g, color.b)
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

function Luna_Player_Events:CHAT_MSG_SPELL_SELF_BUFF()
	if string.find(arg1, "You gain %d+ Mana from Illumination.") then
		LunaPlayerFrame.bars["Powerbar"].Ticker.fsstart = GetTime()
		if LunaOptions.fsTicker then
			LunaPlayerFrame.bars["Powerbar"].Ticker:Show()
		end
	end
end