local HealComm = AceLibrary("HealComm-1.0")
local AceEvent = AceLibrary("AceEvent-2.0")
local Luna_Player_Events = {}
local bufftimers = {}
local debufftimers = {}
local berserkValue = 0.3
local enableCastbar

local PlayerScanTip = CreateFrame("GameTooltip", "PlayerScanTip", nil, "GameTooltipTemplate")
PlayerScanTip:SetOwner(WorldFrame, "ANCHOR_NONE")


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
		LunaOptionsFrame.Button10:SetText("Unlock Frames")
	else
		LunaPlayerFrame:SetScript("OnDragStart", StartMoving)
		LunaPlayerFrame:SetMovable(1)
		
		LunaOptionsFrame.Button10:SetText("Lock Frames")
	end
end
			
local function Luna_Player_OnUpdate()
	local sign
	local current_time = LunaPlayerFrame.bars["Castbar"].maxValue - GetTime()
	if (LunaPlayerFrame.bars["Castbar"].channeling) then
		current_time = LunaPlayerFrame.bars["Castbar"].endTime - GetTime()
	end
	local text = string.sub(math.max(current_time,0)+0.001,1,4)
	if (LunaPlayerFrame.bars["Castbar"].delaySum ~= 0) then
		local delay = string.sub(math.max(LunaPlayerFrame.bars["Castbar"].delaySum/1000, 0)+0.001,1,4)
		if (LunaPlayerFrame.bars["Castbar"].channeling == 1) then
			sign = "-"
		else
			sign = "+"
		end
		text = "|cffcc0000"..sign..delay.."|r "..text
	end
	if LunaPlayerFrame.bars["Castbar"].casting or LunaPlayerFrame.bars["Castbar"].channeling then
		LunaPlayerFrame.bars["Castbar"].Time:SetText(text)
	else
		LunaPlayerFrame.bars["Castbar"].Time:SetText("")
	end
	
	if (LunaPlayerFrame.bars["Castbar"].casting) then
		local status = GetTime()
		if (status > LunaPlayerFrame.bars["Castbar"].maxValue) then
			status = LunaPlayerFrame.bars["Castbar"].maxValue
		end
		LunaPlayerFrame.bars["Castbar"]:SetValue(status)
	elseif (LunaPlayerFrame.bars["Castbar"].channeling) then
		local time = GetTime()
		if (time > LunaPlayerFrame.bars["Castbar"].endTime) then
			time = LunaPlayerFrame.bars["Castbar"].endTime
		end
		if (time == LunaPlayerFrame.bars["Castbar"].endTime) then
			LunaPlayerFrame.bars["Castbar"].channeling = nil
			LunaPlayerFrame.AdjustBars()
			return
		end
		local barValue = LunaPlayerFrame.bars["Castbar"].startTime + (LunaPlayerFrame.bars["Castbar"].endTime - time)
		LunaPlayerFrame.bars["Castbar"]:SetValue(barValue)
	end
end

local function Luna_Player_BuffTimer()
	for i=1, 16 do
		local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(i-1,"HELPFUL"))
		PlayerScanTip:ClearLines()
		PlayerScanTip:SetPlayerBuff(GetPlayerBuff(i-1,"HELPFUL"))
		local buffName = PlayerScanTipTextLeft1:GetText()
		if LunaBuffDB[buffName] then
			if timeleft > LunaBuffDB[buffName] then
				LunaBuffDB[buffName] = timeleft
			end
		elseif timeleft > 0 and buffName then
			LunaBuffDB[buffName] = timeleft
		end
		if timeleft > 0 and LunaOptions.BTimers == 1 then
			CooldownFrame_SetTimer(LunaPlayerFrame.Buffs[i].cd,(GetTime()-(LunaBuffDB[buffName]-timeleft)),LunaBuffDB[buffName],1,1)
		else
			CooldownFrame_SetTimer(LunaPlayerFrame.Buffs[i].cd,0,timeleft,0,1)
		end
	end
	for i=1, 16 do
		local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(i-1,"HARMFUL"))
		PlayerScanTip:ClearLines()
		PlayerScanTip:SetPlayerBuff(GetPlayerBuff(i-1,"HARMFUL"))
		local buffName = PlayerScanTipTextLeft1:GetText()
		if LunaBuffDB[buffName] then
			if timeleft > LunaBuffDB[buffName] then
				LunaBuffDB[buffName] = timeleft
			end
		elseif timeleft > 0 and buffName then
			LunaBuffDB[buffName] = timeleft
		end
		if timeleft > 0 and LunaOptions.BTimers == 1 then
			CooldownFrame_SetTimer(LunaPlayerFrame.Debuffs[i].cd,(GetTime()-(LunaBuffDB[buffName]-timeleft)),LunaBuffDB[buffName],1,1)
		else
			CooldownFrame_SetTimer(LunaPlayerFrame.Debuffs[i].cd,0,timeleft,0,1)
		end
	end
end

local function Luna_Player_BuffCheck()
	local changed
	for i=1, 16 do
		local bufftimeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(i-1,"HELPFUL"))
		if bufftimers[i] and bufftimeleft > bufftimers[i] then
			changed = 1
		end
		bufftimers[i] = bufftimeleft
		local debufftimeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(i-1,"HARMFUL"))
		if debufftimers[i] and debufftimeleft > debufftimers[i] then
			changed = 1
		end
		debufftimers[i] = debufftimeleft
	end
	if changed then
		Luna_Player_BuffTimer()
	end
end

local function Luna_Player_TotemOnUpdate()
	for i=1, 4 do
		if LunaPlayerFrame.totems[i].active then
			if LunaPlayerFrame.totems[i].maxValue >= GetTime() then
				LunaPlayerFrame.totems[i]:SetValue(LunaPlayerFrame.totems[i].maxValue-GetTime())
			else
				LunaPlayerFrame.totems[i]:SetValue(0)
				LunaPlayerFrame.totems[i].active = nil
				LunaPlayerFrame.AdjustBars()
			end
		end
	end
end

local function SetIconPositions()
	LunaPlayerFrame.PVPRank:SetHeight(10 * (LunaOptions.frames["LunaPlayerFrame"].iconscale or 1))
	LunaPlayerFrame.PVPRank:SetWidth(10 * (LunaOptions.frames["LunaPlayerFrame"].iconscale or 1))
	LunaPlayerFrame.Leader:SetHeight(8 * (LunaOptions.frames["LunaPlayerFrame"].iconscale or 1))
	LunaPlayerFrame.Leader:SetWidth(8 * (LunaOptions.frames["LunaPlayerFrame"].iconscale or 1))
	LunaPlayerFrame.Loot:SetHeight(8 * (LunaOptions.frames["LunaPlayerFrame"].iconscale or 1))
	LunaPlayerFrame.Loot:SetWidth(8 * (LunaOptions.frames["LunaPlayerFrame"].iconscale or 1))
	LunaPlayerFrame.Combat:SetHeight(10 * (LunaOptions.frames["LunaPlayerFrame"].iconscale or 1))
	LunaPlayerFrame.Combat:SetWidth(10 * (LunaOptions.frames["LunaPlayerFrame"].iconscale or 1))
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

	LunaPlayerFrame:SetHeight(LunaOptions.frames["LunaPlayerFrame"].size.y)
	LunaPlayerFrame:SetWidth(LunaOptions.frames["LunaPlayerFrame"].size.x)
	LunaPlayerFrame:SetScale(LunaOptions.frames["LunaPlayerFrame"].scale)
	LunaPlayerFrame:SetBackdrop(LunaOptions.backdrop)
	LunaPlayerFrame:SetBackdropColor(0,0,0,1)
	LunaPlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", LunaOptions.frames["LunaPlayerFrame"].position.x, LunaOptions.frames["LunaPlayerFrame"].position.y)
	LunaPlayerFrame:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
	LunaPlayerFrame.unit = "player"
	LunaPlayerFrame:SetScript("OnEnter", UnitFrame_OnEnter)
	LunaPlayerFrame:SetScript("OnLeave", UnitFrame_OnLeave)
	LunaPlayerFrame:SetMovable(0)
	LunaPlayerFrame:RegisterForDrag("LeftButton")
	LunaPlayerFrame:SetScript("OnDragStop", StopMovingOrSizing)
	LunaPlayerFrame:SetClampedToScreen(1)
	LunaPlayerFrame:SetFrameStrata("BACKGROUND")

	
	local barsettings = {}
	for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
		barsettings[v[1]] = {}
		barsettings[v[1]][1] = v[4]
		barsettings[v[1]][2] = v[5]
	end
	LunaPlayerFrame.bars = {}
	
	LunaPlayerFrame.bars["Portrait"] = CreateFrame("Frame", nil, LunaPlayerFrame)
	
	LunaPlayerFrame.bars["Portrait"].texture = LunaPlayerFrame.bars["Portrait"]:CreateTexture("PlayerPortrait", "ARTWORK")
	LunaPlayerFrame.bars["Portrait"].texture:SetAllPoints(LunaPlayerFrame.bars["Portrait"])
	
	LunaPlayerFrame.bars["Portrait"].model = CreateFrame("PlayerModel", nil, LunaPlayerFrame)
	LunaPlayerFrame.bars["Portrait"].model:SetPoint("TOPLEFT", LunaPlayerFrame.bars["Portrait"], "TOPLEFT")
	LunaPlayerFrame.bars["Portrait"].model:SetScript("OnShow",function() this:SetCamera(0) end)

	LunaPlayerFrame.AuraAnchor = CreateFrame("Frame", nil, LunaPlayerFrame)
	LunaPlayerFrame.AuraAnchor:SetScript("OnUpdate", Luna_Player_BuffCheck)
	
	
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
	local hp = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	LunaPlayerFrame.bars["Healthbar"] = hp
	
	local incHeal = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	incHeal:SetMinMaxValues(0, 1)
	incHeal:SetValue(1)
	LunaPlayerFrame.incHeal = incHeal

	-- Healthbar background
	local hpbg = LunaPlayerFrame:CreateTexture(nil, "BACKGROUND")
	hpbg:SetAllPoints(hp)
	hpbg:SetTexture(.25,.25,.25,.25)
	LunaPlayerFrame.bars["Healthbar"].hpbg = hpbg

	-- Healthbar text
	LunaPlayerFrame.bars["Healthbar"].righttext = hp:CreateFontString(nil, "OVERLAY", hp)
	LunaPlayerFrame.bars["Healthbar"].righttext:SetPoint("RIGHT", -2, 0)
	LunaPlayerFrame.bars["Healthbar"].righttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPlayerFrame.bars["Healthbar"].righttext:SetShadowColor(0, 0, 0)
	LunaPlayerFrame.bars["Healthbar"].righttext:SetShadowOffset(0.8, -0.8)
	LunaPlayerFrame.bars["Healthbar"].righttext:SetTextColor(1,1,1)
	LunaPlayerFrame.bars["Healthbar"].righttext:SetJustifyH("RIGHT")
	LunaPlayerFrame.bars["Healthbar"].righttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaPlayerFrame.bars["Healthbar"].righttext, "player", barsettings["Healthbar"][2] or LunaOptions.defaultTags["Healthbar"][2])

	LunaPlayerFrame.bars["Healthbar"].lefttext = hp:CreateFontString(nil, "OVERLAY", hp)
	LunaPlayerFrame.bars["Healthbar"].lefttext:SetPoint("LEFT", 2, 0)
	LunaPlayerFrame.bars["Healthbar"].lefttext:SetJustifyH("LEFT")
	LunaPlayerFrame.bars["Healthbar"].lefttext:SetJustifyV("MIDDLE")
	LunaPlayerFrame.bars["Healthbar"].lefttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPlayerFrame.bars["Healthbar"].lefttext:SetShadowColor(0, 0, 0)
	LunaPlayerFrame.bars["Healthbar"].lefttext:SetShadowOffset(0.8, -0.8)
	LunaPlayerFrame.bars["Healthbar"].lefttext:SetTextColor(1,1,1)
	LunaUnitFrames:RegisterFontstring(LunaPlayerFrame.bars["Healthbar"].lefttext, "player", barsettings["Healthbar"][1] or LunaOptions.defaultTags["Healthbar"][1])

	-- Manabar
	local pp = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	LunaPlayerFrame.bars["Powerbar"] = pp
	
	LunaPlayerFrame.bars["Powerbar"].EnergyUpdate = function()
		local time = GetTime()
		local fsPosition, energyPosition
		if (time - LunaPlayerFrame.bars["Powerbar"].Ticker.startTime) >= 2 then 		--Ticks happen every 2 sec
			LunaPlayerFrame.bars["Powerbar"].Ticker.startTime = GetTime()
		end
		if LunaPlayerFrame.bars["Powerbar"].Ticker.fsstart then
			if (time - LunaPlayerFrame.bars["Powerbar"].Ticker.fsstart) >= 5 then
				LunaPlayerFrame.bars["Powerbar"].Ticker.fsstart = nil
				if UnitPowerType("player") == 0 then
					LunaPlayerFrame.bars["Powerbar"].Ticker:Hide()
				end
			else
				fsPosition = (((time - LunaPlayerFrame.bars["Powerbar"].Ticker.fsstart) / 5)* LunaPlayerFrame.bars["Powerbar"]:GetWidth())
			end
		end
		energyPosition = (((time - LunaPlayerFrame.bars["Powerbar"].Ticker.startTime) / 2)* LunaPlayerFrame.bars["Powerbar"]:GetWidth())
		if UnitPowerType("player") == 0 and fsPosition then
			LunaPlayerFrame.bars["Powerbar"].Ticker:SetPoint("CENTER", LunaPlayerFrame.bars["Powerbar"], "LEFT", fsPosition, 0)
		else
			LunaPlayerFrame.bars["Powerbar"].Ticker:SetPoint("CENTER", LunaPlayerFrame.bars["Powerbar"], "LEFT", energyPosition, 0)
		end
	end
	
	-- Manabar background
	local ppbg = pp:CreateTexture(nil, "BORDER")
	ppbg:SetAllPoints(pp)
	ppbg:SetTexture(.25,.25,.25,.25)
	LunaPlayerFrame.bars["Powerbar"].ppbg = ppbg

	LunaPlayerFrame.bars["Powerbar"].righttext = pp:CreateFontString(nil, "OVERLAY", pp)
	LunaPlayerFrame.bars["Powerbar"].righttext:SetPoint("RIGHT", -2, 0)
	LunaPlayerFrame.bars["Powerbar"].righttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPlayerFrame.bars["Powerbar"].righttext:SetShadowColor(0, 0, 0)
	LunaPlayerFrame.bars["Powerbar"].righttext:SetShadowOffset(0.8, -0.8)
	LunaPlayerFrame.bars["Powerbar"].righttext:SetJustifyH("RIGHT")
	LunaPlayerFrame.bars["Powerbar"].righttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaPlayerFrame.bars["Powerbar"].righttext, "player", barsettings["Powerbar"][2] or LunaOptions.defaultTags["Powerbar"][2])

	LunaPlayerFrame.bars["Powerbar"].Ticker = LunaPlayerFrame.bars["Powerbar"]:CreateTexture(nil, "OVERLAY")
	LunaPlayerFrame.bars["Powerbar"].Ticker:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	LunaPlayerFrame.bars["Powerbar"].Ticker:SetVertexColor(1, 1, 1, 1)
	LunaPlayerFrame.bars["Powerbar"].Ticker:SetBlendMode("ADD")
	LunaPlayerFrame.bars["Powerbar"].Ticker:SetWidth(3)
	LunaPlayerFrame.bars["Powerbar"].oldMana = 0
	LunaPlayerFrame.bars["Powerbar"].Ticker.startTime = nil
	
	LunaPlayerFrame.bars["Powerbar"].lefttext = pp:CreateFontString(nil, "OVERLAY", pp)
	LunaPlayerFrame.bars["Powerbar"].lefttext:SetPoint("LEFT", 2, 0)
	LunaPlayerFrame.bars["Powerbar"].lefttext:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	LunaPlayerFrame.bars["Powerbar"].lefttext:SetShadowColor(0, 0, 0)
	LunaPlayerFrame.bars["Powerbar"].lefttext:SetShadowOffset(0.8, -0.8)
	LunaPlayerFrame.bars["Powerbar"].lefttext:SetJustifyH("LEFT")
	LunaPlayerFrame.bars["Powerbar"].lefttext:SetJustifyV("MIDDLE")
	LunaUnitFrames:RegisterFontstring(LunaPlayerFrame.bars["Powerbar"].lefttext, "player", barsettings["Powerbar"][1] or LunaOptions.defaultTags["Powerbar"][1])

	-- Castbar
	local Castbar = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	LunaPlayerFrame.bars["Castbar"] = Castbar
	LunaPlayerFrame.bars["Castbar"].maxValue = 0
	LunaPlayerFrame.bars["Castbar"].delaySum = 0
	LunaPlayerFrame.bars["Castbar"].holdTime = 0
	LunaPlayerFrame.bars["Castbar"]:SetMinMaxValues(0,1)
	LunaPlayerFrame.bars["Castbar"]:SetValue(0)

	-- Add a background
	local Background = Castbar:CreateTexture(nil, 'BACKGROUND')
	Background:SetAllPoints(Castbar)
	Background:SetTexture(0, 0, 1, 0.20)
	LunaPlayerFrame.bars["Castbar"].bg = Background

	-- Add a timer
	local Time = Castbar:CreateFontString(nil, "OVERLAY", castbar)
	Time:SetFont(LunaOptions.font, 10)
	Time:SetTextColor(1, 0.82, 0, 1)
	Time:SetShadowColor(0, 0, 0)
	Time:SetShadowOffset(0.8, -0.8)
	Time:SetPoint("RIGHT", Castbar)
	Time:SetJustifyH("RIGHT")
	Time:SetJustifyV("MIDDLE")
	LunaPlayerFrame.bars["Castbar"].Time = Time

	-- Add spell text
	local Text = Castbar:CreateFontString(nil, "OVERLAY", castbar)
	Text:SetFont(LunaOptions.font, 10)
	Text:SetTextColor(1, 0.82, 0, 1)
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(0.8, -0.8)
	Text:SetPoint("LEFT", Castbar)
	Text:SetJustifyH("LEFT")
	Text:SetJustifyV("MIDDLE")
	LunaPlayerFrame.bars["Castbar"].Text = Text

	LunaPlayerFrame.iconholder = CreateFrame("Frame", nil, LunaPlayerFrame)
	
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
	LunaPlayerFrame.Leader:SetHeight(8)
	LunaPlayerFrame.Leader:SetWidth(8)
	LunaPlayerFrame.Leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")

	LunaPlayerFrame.Loot = LunaPlayerFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaPlayerFrame.Loot:SetHeight(8)
	LunaPlayerFrame.Loot:SetWidth(8)
	LunaPlayerFrame.Loot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")

	LunaPlayerFrame.Combat = LunaPlayerFrame.iconholder:CreateTexture(nil, "OVERLAY")
	LunaPlayerFrame.Combat:SetHeight(14)
	LunaPlayerFrame.Combat:SetWidth(14)
	LunaPlayerFrame.Combat:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	LunaPlayerFrame.Combat:SetTexCoord(0.57, 0.90, 0.08, 0.41)
		
	-- Druidbar
	local db = CreateFrame("StatusBar", nil, LunaPlayerFrame)
	LunaPlayerFrame.bars["Druidbar"] = db
	
	
	-- Druidbar background
	local dbbg = db:CreateTexture(nil, "BORDER")
	dbbg:SetAllPoints(db)
	dbbg:SetTexture(.25,.25,.25,.25)
	LunaPlayerFrame.bars["Druidbar"].dbbg = dbbg
	LunaPlayerFrame.bars["Druidbar"].dbbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)

	local dbp = db:CreateFontString(nil, "OVERLAY", db)
	dbp:SetPoint("CENTER", db)
	dbp:SetFont(LunaOptions.font, LunaOptions.fontHeight)
	dbp:SetShadowColor(0, 0, 0)
	dbp:SetShadowOffset(0.8, -0.8)
	dbp:SetTextColor(1,1,1)
	dbp:SetJustifyH("CENTER")
	LunaPlayerFrame.bars["Druidbar"].dbp = dbp
	
	-- Totembar
	
	LunaPlayerFrame.totems = {}
	LunaPlayerFrame.bars["Totembar"] = CreateFrame("Frame", nil, LunaPlayerFrame)
	for i=1,4 do
		LunaPlayerFrame.totems[i] = CreateFrame("StatusBar", nil, LunaPlayerFrame.bars["Totembar"])
		LunaPlayerFrame.totems[i]:Hide()
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
	
	for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
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
	LunaPlayerFrame.bars["Powerbar"]:SetScript("OnUpdate", LunaPlayerFrame.bars["Powerbar"].EnergyUpdate)
	
	if LunaOptions.hideBlizzCastbar == 1 then
		Luna_HideBlizz(CastingBarFrame)
	end
	
	LunaPlayerFrame:SetScript("OnUpdate", CombatFeedback_OnUpdate)
	
	LunaPlayerFrame.dropdown = getglobal("PlayerFrameDropDown")
	LunaPlayerFrame.initialize = function() if LunaPlayerFrame.dropdown then
												if not (UnitInRaid("player") or GetNumPartyMembers() > 0) then
													UIDropDownMenu_AddButton({text = "Reset Instances", func = ResetInstances, notCheckable = 1}, 1)
												end
												UnitPopup_ShowMenu(LunaPlayerFrame.dropdown, "SELF", LunaPlayerFrame.unit)
											end
								end
	UIDropDownMenu_Initialize(LunaPlayerFrame.dropdown, LunaPlayerFrame.initialize, "MENU")
	
	LunaPlayerFrame.AdjustBars = function()
		local frameHeight = LunaPlayerFrame:GetHeight()
		local frameWidth
		local anchor
		local totalWeight = 0
		local gaps = -1
		local _, class = UnitClass("player")
		local CastBarHeightWeight
		local textheights = {}
		local textbalance = {}
		for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
			if v[1] == "Castbar" then
				CastBarHeightWeight = v[2]
				if CastBarHeightWeight == 0 then
					enableCastbar = nil
				else
					enableCastbar = true
				end
			end
			textheights[v[1]] = v[3] or 0.45
			textbalance[v[1]] = v[6] or 0.5
		end
		
		if ((LunaPlayerFrame.bars["Castbar"].casting or LunaPlayerFrame.bars["Castbar"].channeling) and CastBarHeightWeight > 0) then
			LunaPlayerFrame.bars["Castbar"]:Show()
		elseif LunaOptions.staticplayercastbar then
			LunaPlayerFrame.bars["Castbar"]:Show()
			LunaPlayerFrame.bars["Castbar"].Time:SetText("")
			LunaPlayerFrame.bars["Castbar"].Text:SetText("")
			LunaPlayerFrame.bars["Castbar"]:SetValue(0)
		else
			LunaPlayerFrame.bars["Castbar"]:Hide()
		end
		if class == "DRUID" and UnitPowerType("player") ~= 0 and LunaOptions.DruidBar == 1 then
			LunaPlayerFrame.bars["Druidbar"]:Show()
		else
			LunaPlayerFrame.bars["Druidbar"]:Hide()
		end
		if class == "SHAMAN" and LunaOptions.TotemBar == 1 and (LunaPlayerFrame.totems[1].active or LunaPlayerFrame.totems[2].active or LunaPlayerFrame.totems[3].active or LunaPlayerFrame.totems[4].active) or LunaOptions.statictotembar then
			LunaPlayerFrame.bars["Totembar"]:Show()
		else
			LunaPlayerFrame.bars["Totembar"]:Hide()
		end
		if LunaOptions.frames["LunaPlayerFrame"].portrait > 1 then    -- We have a square portrait
			frameWidth = (LunaPlayerFrame:GetWidth()-frameHeight)
			LunaPlayerFrame.bars["Portrait"]:SetPoint("TOPLEFT", LunaPlayerFrame, "TOPLEFT")
			LunaPlayerFrame.bars["Portrait"]:SetHeight(frameHeight)
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
			local bar = v[1]
			local weight = v[2]/totalWeight
			local height = (frameHeight-gaps)*weight
			LunaPlayerFrame.bars[bar]:ClearAllPoints()
			LunaPlayerFrame.bars[bar]:SetHeight(height)
			LunaPlayerFrame.bars[bar]:SetWidth(frameWidth)
			LunaPlayerFrame.bars[bar].rank = k
			LunaPlayerFrame.bars[bar].weight = v[2]
			
			if not firstbar and LunaPlayerFrame.bars[bar]:IsShown() then
				LunaPlayerFrame.bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3], 0, -1)
				anchor = {"TOPLEFT", LunaPlayerFrame.bars[bar], "BOTTOMLEFT"}
			elseif LunaPlayerFrame.bars[bar]:IsShown() then
				LunaPlayerFrame.bars[bar]:SetPoint(anchor[1], anchor[2], anchor[3])
				firstbar = nil
				anchor = {"TOPLEFT", LunaPlayerFrame.bars[bar], "BOTTOMLEFT"}
			end			
		end
		LunaPlayerFrame.bars["Portrait"].model:SetHeight(LunaPlayerFrame.bars["Portrait"]:GetHeight()+1)
		LunaPlayerFrame.bars["Portrait"].model:SetWidth(LunaPlayerFrame.bars["Portrait"]:GetWidth())
		LunaUnitFrames.PlayerUpdateHeal(UnitName("player"))
		
		local healthheight = (LunaPlayerFrame.bars["Healthbar"]:GetHeight()*textheights["Healthbar"])
		LunaPlayerFrame.bars["Healthbar"].righttext:SetHeight(LunaPlayerFrame.bars["Healthbar"]:GetHeight())
		LunaPlayerFrame.bars["Healthbar"].righttext:SetWidth(LunaPlayerFrame.bars["Healthbar"]:GetWidth()*(1-textbalance["Healthbar"]))
		LunaPlayerFrame.bars["Healthbar"].righttext:SetFont(LunaOptions.font, healthheight)
		LunaPlayerFrame.bars["Healthbar"].lefttext:SetHeight(LunaPlayerFrame.bars["Healthbar"]:GetHeight())
		LunaPlayerFrame.bars["Healthbar"].lefttext:SetWidth(LunaPlayerFrame.bars["Healthbar"]:GetWidth()*textbalance["Healthbar"])
		LunaPlayerFrame.bars["Healthbar"].lefttext:SetFont(LunaOptions.font, healthheight)
		
		local powerheight = (LunaPlayerFrame.bars["Powerbar"]:GetHeight()*textheights["Powerbar"])
		LunaPlayerFrame.bars["Powerbar"].righttext:SetHeight(LunaPlayerFrame.bars["Powerbar"]:GetHeight())
		LunaPlayerFrame.bars["Powerbar"].righttext:SetWidth(LunaPlayerFrame.bars["Powerbar"]:GetWidth()*(1-textbalance["Powerbar"]))
		LunaPlayerFrame.bars["Powerbar"].righttext:SetFont(LunaOptions.font, powerheight)
		LunaPlayerFrame.bars["Powerbar"].lefttext:SetHeight(LunaPlayerFrame.bars["Powerbar"]:GetHeight())
		LunaPlayerFrame.bars["Powerbar"].lefttext:SetWidth(LunaPlayerFrame.bars["Powerbar"]:GetWidth()*textbalance["Powerbar"])
		LunaPlayerFrame.bars["Powerbar"].lefttext:SetFont(LunaOptions.font, powerheight)
		
		local castheight = (LunaPlayerFrame.bars["Castbar"]:GetHeight()*textheights["Castbar"])
		LunaPlayerFrame.bars["Castbar"].Text:SetHeight(LunaPlayerFrame.bars["Castbar"]:GetHeight())
		LunaPlayerFrame.bars["Castbar"].Text:SetWidth(LunaPlayerFrame.bars["Castbar"]:GetWidth()*(1-textbalance["Castbar"]))
		LunaPlayerFrame.bars["Castbar"].Text:SetFont(LunaOptions.font, castheight)
		LunaPlayerFrame.bars["Castbar"].Time:SetHeight(LunaPlayerFrame.bars["Castbar"]:GetHeight())
		LunaPlayerFrame.bars["Castbar"].Time:SetWidth(LunaPlayerFrame.bars["Castbar"]:GetWidth()*textbalance["Castbar"])
		LunaPlayerFrame.bars["Castbar"].Time:SetFont(LunaOptions.font, castheight)
		
		local dbheight = (LunaPlayerFrame.bars["Druidbar"]:GetHeight()*textheights["Druidbar"])
		if LunaPlayerFrame.bars["Druidbar"]:GetHeight() < 6 then
			LunaPlayerFrame.bars["Druidbar"].dbp:Hide()
		else
			LunaPlayerFrame.bars["Druidbar"].dbp:SetFont(LunaOptions.font, dbheight)
			LunaPlayerFrame.bars["Druidbar"].dbp:Show()
		end
		
		for i=1, 4 do
			if 1 then
				LunaPlayerFrame.totems[i]:Show()
			else
				LunaPlayerFrame.totems[i]:Hide()
			end
			LunaPlayerFrame.totems[i]:SetHeight(LunaPlayerFrame.bars["Totembar"]:GetHeight())
			LunaPlayerFrame.totems[i]:SetWidth((frameWidth-3)/4)
		end
		LunaPlayerFrame.bars["Powerbar"].Ticker:SetHeight(LunaPlayerFrame.bars["Powerbar"]:GetHeight())
		if not (LunaOptions.frames["LunaPlayerFrame"].portrait > 1) and not LunaPlayerFrame.bars["Portrait"].model:IsShown() then
			Luna_Player_Events.UNIT_PORTRAIT_UPDATE("player")
		end
	end
	LunaPlayerFrame.UpdateBuffSize = function ()
		local buffcount = LunaOptions.frames["LunaPlayerFrame"].BuffInRow or 16
		if LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 1 then
			for i=1, 16 do
				LunaPlayerFrame.Buffs[i]:Hide()
				LunaPlayerFrame.Debuffs[i]:Hide()
			end
		elseif LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 2 then
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
		elseif LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 3 then
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
			local offset = -3
			if LunaUnitFrames.frames.ExperienceBar and LunaUnitFrames.frames.ExperienceBar:IsShown() then
				offset = offset + (-12)
			end
			if LunaUnitFrames.frames.ReputationBar and LunaUnitFrames.frames.ReputationBar:IsShown() then
				offset = offset + (-12)
			end
			LunaPlayerFrame.AuraAnchor:SetPoint("TOPLEFT", LunaPlayerFrame, "BOTTOMLEFT", -1, offset)
			Luna_Player_Events:PLAYER_AURAS_CHANGED()
		elseif LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 4 then
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
	AceEvent:RegisterEvent("CASTLIB_STARTCAST", LunaUnitFrames.CastAimedShot)
	AceEvent:RegisterEvent("HealComm_Healupdate", LunaUnitFrames.PlayerUpdateHeal)
	AceEvent:RegisterEvent("DruidManaLib_Manaupdate", LunaUnitFrames.DruidBarUpdate)
	AceEvent:RegisterEvent("fiveSec", LunaUnitFrames.fiveSec)
end

function LunaUnitFrames.CastAimedShot(Spell)
	if Spell == "Aimed Shot" and enableCastbar and not LunaPlayerFrame.bars["Castbar"].casting then
		local _,_, latency = GetNetStats()
		local casttime = 3
		for i=1,32 do
			if UnitBuff("player",i) == "Interface\\Icons\\Ability_Warrior_InnerRage" then
				casttime = casttime/1.3
			end
			if UnitBuff("player",i) == "Interface\\Icons\\Ability_Hunter_RunningShot" then
				casttime = casttime/1.4
			end
			if UnitBuff("player",i) == "Interface\\Icons\\Racial_Troll_Berserk" then
				casttime = casttime/ (1 + berserkValue)
			end
			if UnitBuff("player",i) == "Interface\\Icons\\Inv_Trinket_Naxxramas04" then
				casttime = casttime/1.2
			end
			if UnitDebuff("player",i) == "Interface\\Icons\\Spell_Shadow_CurseOfTounges" then
				casttime = casttime/0.5
			end
		end
		LunaPlayerFrame.bars["Castbar"].startTime = GetTime()
		LunaPlayerFrame.bars["Castbar"].maxValue = LunaPlayerFrame.bars["Castbar"].startTime + casttime + (latency/1000)
		LunaPlayerFrame.bars["Castbar"].holdTime = 0
		LunaPlayerFrame.bars["Castbar"].casting = 1
		LunaPlayerFrame.bars["Castbar"].delaySum = 0
		LunaPlayerFrame.bars["Castbar"].Text:SetText("Aimed Shot")
		LunaPlayerFrame.bars["Castbar"]:SetMinMaxValues(LunaPlayerFrame.bars["Castbar"].startTime, LunaPlayerFrame.bars["Castbar"].maxValue)
		LunaPlayerFrame.bars["Castbar"]:SetValue(LunaPlayerFrame.bars["Castbar"].startTime)
		LunaPlayerFrame.AdjustBars()
	end
end

function LunaUnitFrames.PlayerUpdateHeal(target)
	if target ~= UnitName("player") then
		return
	end
	local healed = HealComm:getHeal(target)
	local health, maxHealth = UnitHealth(LunaPlayerFrame.unit), UnitHealthMax(LunaPlayerFrame.unit)
	if( healed > 0 and (health < maxHealth or (LunaOptions.overheal or 20) > 0 )) then
		LunaPlayerFrame.incHeal:Show()
		local healthWidth = LunaPlayerFrame.bars["Healthbar"]:GetWidth() * (health / maxHealth)
		local incWidth = LunaPlayerFrame.bars["Healthbar"]:GetWidth() * (healed / maxHealth)
		if (healthWidth + incWidth) > (LunaPlayerFrame.bars["Healthbar"]:GetWidth() * (1+((LunaOptions.overheal or 20)/100)) ) then
			incWidth = LunaPlayerFrame.bars["Healthbar"]:GetWidth() * (1+((LunaOptions.overheal or 20)/100)) - healthWidth
		end
		LunaPlayerFrame.incHeal:SetWidth(incWidth)
		LunaPlayerFrame.incHeal:SetHeight(LunaPlayerFrame.bars["Healthbar"]:GetHeight())
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
		if v[1] == "Healthbar" then
			LunaOptionsFrame.pages[1].barheight:SetValue(v[2])
			LunaOptionsFrame.pages[1].barorder:SetValue(k)
			LunaOptionsFrame.pages[1].lefttext:SetText(v[4] or LunaOptions.defaultTags["Healthbar"][1])
			LunaOptionsFrame.pages[1].righttext:SetText(v[5] or LunaOptions.defaultTags["Healthbar"][2])
			LunaOptionsFrame.pages[1].textsize:SetValue(v[3] or 0.45)
			break
		end
	end
	SetIconPositions()
	LunaPlayerFrame.AdjustBars()
	Luna_Player_Events.UNIT_PORTRAIT_UPDATE("player")
end

function LunaUnitFrames:UpdatePlayerFrame()
	if LunaOptions.frames["LunaPlayerFrame"].enabled == 0 then
		LunaPlayerFrame:Hide()
		return
	else
		LunaPlayerFrame:Show()
	end
	local _,class = UnitClass("player")
	
	local rankNumber = UnitPVPRank("player")
	if (rankNumber == 0) or not LunaOptions.frames["LunaPlayerFrame"].pvprankicon then
		LunaPlayerFrame.PVPRank:Hide()
	elseif (rankNumber < 14) then
		rankNumber = rankNumber - 4
		LunaPlayerFrame.PVPRank:SetTexture("Interface\\PvPRankBadges\\PvPRank0"..rankNumber)
		LunaPlayerFrame.PVPRank:Show()
	else
		rankNumber = rankNumber - 4
		LunaPlayerFrame.PVPRank:SetTexture("Interface\\PvPRankBadges\\PvPRank"..rankNumber)
		LunaPlayerFrame.PVPRank:Show()
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
	Luna_Player_Events.UNIT_PORTRAIT_UPDATE("player")
	Luna_Player_Events.PARTY_LOOT_METHOD_CHANGED()
	Luna_Player_Events.PLAYER_UPDATE_RESTING()
	SetIconPositions()
end

function Luna_Player_Events:SPELLCAST_CHANNEL_START()
	LunaPlayerFrame.bars["Castbar"].maxValue = 1
	LunaPlayerFrame.bars["Castbar"].startTime = GetTime()
	LunaPlayerFrame.bars["Castbar"].endTime = LunaPlayerFrame.bars["Castbar"].startTime + (arg1 / 1000)
	LunaPlayerFrame.bars["Castbar"].duration = arg1 / 1000
	LunaPlayerFrame.bars["Castbar"]:SetMinMaxValues(LunaPlayerFrame.bars["Castbar"].startTime, LunaPlayerFrame.bars["Castbar"].endTime)
	LunaPlayerFrame.bars["Castbar"]:SetValue(LunaPlayerFrame.bars["Castbar"].endTime)
	LunaPlayerFrame.bars["Castbar"].holdTime = 0
	LunaPlayerFrame.bars["Castbar"].casting = nil
	LunaPlayerFrame.bars["Castbar"].channeling = 1
	LunaPlayerFrame.bars["Castbar"].delaySum = 0
	LunaPlayerFrame.bars["Castbar"].Text:SetText("Channeling")
	LunaPlayerFrame.AdjustBars()
end

function Luna_Player_Events:SPELLCAST_CHANNEL_UPDATE()
	if (arg1 == 0) then
		LunaPlayerFrame.bars["Castbar"].channeling = nil
		LunaPlayerFrame.bars["Castbar"].delaySum = 0
		LunaPlayerFrame.AdjustBars()
	elseif (LunaPlayerFrame.bars["Castbar"]:IsShown()) then
		local origDuration = LunaPlayerFrame.bars["Castbar"].endTime - LunaPlayerFrame.bars["Castbar"].startTime
		local elapsedTime = GetTime() - LunaPlayerFrame.bars["Castbar"].startTime;
		local losttime = origDuration*1000 - elapsedTime*1000 - arg1;
		LunaPlayerFrame.bars["Castbar"].delaySum = LunaPlayerFrame.bars["Castbar"].delaySum + losttime;
		LunaPlayerFrame.bars["Castbar"].startTime = LunaPlayerFrame.bars["Castbar"].endTime - origDuration;
		LunaPlayerFrame.bars["Castbar"].endTime = GetTime() + (arg1 / 1000);
		LunaPlayerFrame.bars["Castbar"]:SetMinMaxValues(LunaPlayerFrame.bars["Castbar"].startTime, LunaPlayerFrame.bars["Castbar"].endTime);
	end
end

function Luna_Player_Events:SPELLCAST_DELAYED()
	if (arg1) and LunaPlayerFrame.bars["Castbar"].startTime then
		LunaPlayerFrame.bars["Castbar"].startTime = LunaPlayerFrame.bars["Castbar"].startTime + (arg1 / 1000);
		LunaPlayerFrame.bars["Castbar"].maxValue = LunaPlayerFrame.bars["Castbar"].maxValue + (arg1 / 1000);
		LunaPlayerFrame.bars["Castbar"].delaySum = LunaPlayerFrame.bars["Castbar"].delaySum + arg1;
		LunaPlayerFrame.bars["Castbar"]:SetMinMaxValues(LunaPlayerFrame.bars["Castbar"].startTime, LunaPlayerFrame.bars["Castbar"].maxValue);
	end
end

function Luna_Player_Events:SPELLCAST_START()
	LunaPlayerFrame.bars["Castbar"].startTime = GetTime()
	LunaPlayerFrame.bars["Castbar"].maxValue = LunaPlayerFrame.bars["Castbar"].startTime + (arg2 / 1000)
	LunaPlayerFrame.bars["Castbar"].holdTime = 0
	LunaPlayerFrame.bars["Castbar"].casting = 1
	LunaPlayerFrame.bars["Castbar"].delaySum = 0	
	LunaPlayerFrame.bars["Castbar"].Text:SetText(arg1)
	LunaPlayerFrame.bars["Castbar"]:SetMinMaxValues(LunaPlayerFrame.bars["Castbar"].startTime, LunaPlayerFrame.bars["Castbar"].maxValue)
	LunaPlayerFrame.bars["Castbar"]:SetValue(LunaPlayerFrame.bars["Castbar"].startTime)
	LunaPlayerFrame.AdjustBars()
end

function Luna_Player_Events:SPELLCAST_STOP()
	if LunaPlayerFrame.bars["Castbar"].casting == 1 or event == "SPELLCAST_CHANNEL_STOP" then
		LunaPlayerFrame.bars["Castbar"].casting = nil
		LunaPlayerFrame.bars["Castbar"].channeling = nil
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
	local pos
	local _,_,dtype = UnitDebuff("player", 1, 1)
	if dtype and LunaOptions.HighlightDebuffs then
		LunaPlayerFrame:SetBackdropColor(unpack(LunaOptions.DebuffTypeColor[dtype],1))
	else
		LunaPlayerFrame:SetBackdropColor(0,0,0,1)
	end
	if LunaOptions.frames["LunaPlayerFrame"].ShowBuffs == 1 then
		return
	end
	for i=1, 16 do
		local path = GetPlayerBuffTexture(GetPlayerBuff(i-1,"HELPFUL"))
		local stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HELPFUL"))
		LunaPlayerFrame.Buffs[i].texturepath = path
		if LunaPlayerFrame.Buffs[i].texturepath then
				if LunaPlayerFrame.Buffs[i].texturepath == "Interface\\Icons\\Racial_Troll_Berserk" then
					if((UnitHealth("player")/UnitHealthMax("player")) >= 0.40) then
						berserkValue = (1.30 - (UnitHealth("player")/UnitHealthMax("player")))/3
					else
						berserkValue = 0.30
					end
				end
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
			if not pos then
				pos = i
			end
		end
		LunaPlayerFrame.Buffs[i]:SetNormalTexture(LunaPlayerFrame.Buffs[i].texturepath)
	end
	if not pos then
		pos = 17
	end
	LunaPlayerFrame.AuraAnchor:SetHeight((LunaPlayerFrame.Buffs[1]:GetHeight()*math.ceil((pos-1)/(LunaOptions.frames["LunaPlayerFrame"].BuffInRow or 16)))+(math.ceil((pos-1)/(LunaOptions.frames["LunaPlayerFrame"].BuffInRow or 16))-1)+1.1)
	for i=1, 16 do
		local path = GetPlayerBuffTexture(GetPlayerBuff(i-1,"HARMFUL"))
		local stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HARMFUL"))
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
	Luna_Player_BuffTimer()
end

function Luna_Player_Events:PLAYER_UPDATE_RESTING()
	local InCombat = UnitAffectingCombat("player")
	if not LunaOptions.frames["LunaPlayerFrame"].combaticon or (not InCombat and not IsResting()) then
		LunaPlayerFrame.Combat:Hide()
		return
	end
	if InCombat then
		LunaPlayerFrame.Combat:SetTexCoord(0.5, 1.0, 0.0, 0.48)
		LunaPlayerFrame.Combat:Show()
	else
		LunaPlayerFrame.Combat:SetTexCoord(0, 0.5, 0.0, 0.48)
		LunaPlayerFrame.Combat:Show()
	end
end
Luna_Player_Events.PLAYER_REGEN_DISABLED = Luna_Player_Events.PLAYER_UPDATE_RESTING;
Luna_Player_Events.PLAYER_REGEN_ENABLED = Luna_Player_Events.PLAYER_UPDATE_RESTING;

function Luna_Player_Events:PARTY_LOOT_METHOD_CHANGED()
	local lootmaster;
	_, lootmaster = GetLootMethod()
	if lootmaster == 0 and LunaOptions.frames["LunaPlayerFrame"].looticon then
		LunaPlayerFrame.Loot:Show()
	else
		LunaPlayerFrame.Loot:Hide()
	end
end

function Luna_Player_Events:PARTY_LEADER_CHANGED()
	if UnitIsPartyLeader("player") and (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) and LunaOptions.frames["LunaPlayerFrame"].leadericon then
		LunaPlayerFrame.Leader:Show()
	else
		LunaPlayerFrame.Leader:Hide()
	end
end
Luna_Player_Events.PARTY_MEMBERS_CHANGED = Luna_Player_Events.PARTY_LEADER_CHANGED

function Luna_Player_Events:RAID_TARGET_UPDATE()
	local index = GetRaidTargetIndex("player")
	if index and LunaOptions.raidmarks then
		SetRaidTargetIconTexture(LunaPlayerFrame.RaidIcon, index)
		LunaPlayerFrame.RaidIcon:Show()
	else
		LunaPlayerFrame.RaidIcon:Hide()
	end
end

function Luna_Player_Events:UNIT_HEALTH()
	LunaUnitFrames.PlayerUpdateHeal(UnitName("player"))
	LunaPlayerFrame.bars["Healthbar"]:SetMinMaxValues(0, UnitHealthMax("player"))
	if (UnitIsDead("player") or UnitIsGhost("player")) then
		LunaPlayerFrame.bars["Healthbar"]:SetValue(0)
	else
		LunaPlayerFrame.bars["Healthbar"]:SetValue(UnitHealth("player"))
		if not LunaOptions.hbarcolor then
			local color = LunaUnitFrames:GetHealthColor("player")
			LunaPlayerFrame.bars["Healthbar"]:SetStatusBarColor(color[1],color[2],color[3])
			LunaPlayerFrame.bars["Healthbar"].hpbg:SetVertexColor(color[1],color[2],color[3], 0.25)
		end
	end
end
Luna_Player_Events.UNIT_MAXHEALTH = Luna_Player_Events.UNIT_HEALTH;

function Luna_Player_Events:UNIT_MANA()
	if not LunaPlayerFrame.bars["Powerbar"].Ticker.startTime or UnitMana("player") > LunaPlayerFrame.bars["Powerbar"].oldMana then
		LunaPlayerFrame.bars["Powerbar"].Ticker.startTime = GetTime()
	end
	LunaPlayerFrame.bars["Powerbar"].oldMana = UnitMana("player")
	LunaPlayerFrame.bars["Powerbar"]:SetMinMaxValues(0, UnitManaMax("player"))
	if (UnitIsDead("player") or UnitIsGhost("player")) then
		LunaPlayerFrame.bars["Powerbar"]:SetValue(0)
	else
		LunaPlayerFrame.bars["Powerbar"]:SetValue(UnitMana("player"))
	end
end
Luna_Player_Events.UNIT_MAXMANA = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_ENERGY = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_MAXENERGY = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_RAGE = Luna_Player_Events.UNIT_MANA;
Luna_Player_Events.UNIT_MAXRAGE = Luna_Player_Events.UNIT_MANA;

function Luna_Player_Events:UNIT_DISPLAYPOWER()
	local playerpower = UnitPowerType("player")
	
	if playerpower == 1 then
		LunaPlayerFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3])
		LunaPlayerFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Rage"][1], LunaOptions.PowerColors["Rage"][2], LunaOptions.PowerColors["Rage"][3], .25)
		LunaPlayerFrame.bars["Powerbar"].Ticker:Hide()
	elseif playerpower == 3 then
		LunaPlayerFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3])
		LunaPlayerFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Energy"][1], LunaOptions.PowerColors["Energy"][2], LunaOptions.PowerColors["Energy"][3], .25)
		if LunaOptions.EnergyTicker == 1 then
			LunaPlayerFrame.bars["Powerbar"].Ticker:Show()
		else
			LunaPlayerFrame.bars["Powerbar"].Ticker:Hide()
		end
	else
		LunaPlayerFrame.bars["Powerbar"]:SetStatusBarColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3])
		LunaPlayerFrame.bars["Powerbar"].ppbg:SetVertexColor(LunaOptions.PowerColors["Mana"][1], LunaOptions.PowerColors["Mana"][2], LunaOptions.PowerColors["Mana"][3], .25)
		if LunaPlayerFrame.bars["Powerbar"].Ticker.fsstart and LunaOptions.fsTicker then
			LunaPlayerFrame.bars["Powerbar"].Ticker:Show()
		else
			LunaPlayerFrame.bars["Powerbar"].Ticker:Hide()
		end
	end
	LunaPlayerFrame.AdjustBars()
	Luna_Player_Events.UNIT_MANA()
end

function Luna_Player_Events.UNIT_PORTRAIT_UPDATE(unit)
	if arg1 ~= "player" and not unit then
		return
	end
	local portrait = LunaPlayerFrame.bars["Portrait"]
	if(LunaOptions.PortraitMode == 3) then
		local _,class = UnitClass("player")
		portrait.model:Hide()
		portrait.texture:Show()
		portrait.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		portrait.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
	elseif(LunaOptions.PortraitMode == 2) then
		if LunaOptions.frames["LunaPlayerFrame"].portrait > 1 then
			portrait.model:Hide()
			portrait.texture:Show()
			SetPortraitTexture(portrait.texture, "player")
			portrait.texture:SetTexCoord(.1, .90, .1, .90)
		else
			portrait.model:Hide()
			portrait.texture:Show()
			SetPortraitTexture(portrait.texture, "player")
			local aspect = portrait:GetHeight()/portrait:GetWidth()
			portrait.texture:SetTexCoord(0, 1, (0.5-0.5*aspect), 1-(0.5-0.5*aspect))
		end
	else
		if(not UnitExists("player") or not UnitIsConnected("player") or not UnitIsVisible("player")) then
			if LunaOptions.PortraitFallback == 3 then
				portrait.model:Hide()
				portrait.texture:Show()
				local _,class = UnitClass("player")
				portrait.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
				portrait.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
			elseif LunaOptions.PortraitFallback == 2 then
				if LunaOptions.frames["LunaPlayerFrame"].portrait > 1 then
					portrait.model:Hide()
					portrait.texture:Show()
					SetPortraitTexture(portrait.texture, "player")
					portrait.texture:SetTexCoord(.1, .90, .1, .90)
				else
					portrait.model:Hide()
					portrait.texture:Show()
					SetPortraitTexture(portrait.texture, "player")
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
			portrait.model:SetUnit("player")
			portrait.model:SetCamera(0)
		end
	end
end
Luna_Player_Events.UNIT_MODEL_CHANGED = Luna_Player_Events.UNIT_PORTRAIT_UPDATE

function Luna_Player_Events:UNIT_COMBAT()
	if arg1 == "player" and LunaOptions.frames["LunaPlayerFrame"].combattext then
		CombatFeedback_OnCombatEvent(arg2, arg3, arg4, arg5)
	end
end

function Luna_Player_Events:UNIT_SPELLMISS()
	if arg1 == "player" and LunaOptions.frames["LunaPlayerFrame"].combattext then
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