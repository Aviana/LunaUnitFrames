local LunaUF = LunaUF
local Power = {}
local POWERMATCH = {
		[0] = "MANA",
		[1] = "RAGE",
		[2] = "FOCUS",
		[3] = "ENERGY"
		}
local timestamp
local playerFrame
local CL = LunaUF.CL
LunaUF:RegisterModule(Power, "powerBar", LunaUF.L["Power bar"], true)

local function reset()
	if LunaUF.db.profile.units.player.powerBar.ticker then
		timestamp = GetTime()
		if playerFrame and playerFrame.powerBar and playerFrame.powerBar.ticker then
			playerFrame.powerBar.ticker:Show()
		end
	end
end

local EnergyUpdate = function()
	local powerType = UnitPowerType("player")
	local frame = this:GetParent()
	local time = GetTime()
	local Position = 0
	if powerType == 0 then
		if timestamp then
			if (time - timestamp) >= 5 then
				timestamp = nil
				this:Hide()
			else
				Position = ((time - timestamp) / 5)
			end
		end
	elseif powerType == 3 then
		if (time - this.startTime) >= 2 then 		--Ticks happen every 2 sec
			this.startTime = GetTime()
		end
		Position = ((time - this.startTime) / 2)
	else
		this:Hide()
		return
	end
	if LunaUF.db.profile.units[frame:GetParent().unitGroup].powerBar.vertical then
		this:SetPoint("CENTER", frame, "BOTTOM", 0, Position * frame:GetHeight())
	else
		this:SetPoint("CENTER", frame, "LEFT", Position * frame:GetWidth(), 0)
	end
end

local function OnEvent()
	if arg1 ~= this:GetParent().unit then return end
	if event == "UNIT_DISPLAYPOWER" then
		Power:UpdateColor(this:GetParent())
	else
		if this.ticker and (not this.ticker.startTime or UnitMana("player") > (this.currentPower or 0)) then
			this.ticker.startTime = GetTime()
		end
	end
	Power:Update(this:GetParent())
end

local function UpdateManaUsage()
	if not playerFrame or not playerFrame.powerBar.manaUsage then return end
	local manavalue = CL:GetManaUse() or 0
	local manaUsagebar = playerFrame.powerBar.manaUsage.bar
	
	if not LunaUF.db.profile.units.player.powerBar.manaUsage or manavalue == 0 then
		manaUsagebar:Hide()
		return
	end
	
	local currMana, maxMana = UnitMana("player"), UnitManaMax("player")
	local barHeight, barWidth = playerFrame.powerBar:GetHeight(), playerFrame.powerBar:GetWidth()
	local manaHeight = barHeight * (currMana / maxMana)
	local manaWidth = barWidth * (currMana / maxMana)
	
	manaUsagebar:Show()
	manaUsagebar:ClearAllPoints()
	
	if LunaUF.db.profile.units.player.powerBar.vertical then
	
		local useHeight = barHeight * (manavalue / maxMana)
		manaUsagebar:SetHeight(useHeight)
		manaUsagebar:SetWidth(barWidth)
		manaUsagebar:SetPoint("BOTTOMLEFT", playerFrame.powerBar, "BOTTOMLEFT", 0, manaHeight - useHeight)
		
	else
	
		local useWidth = barWidth * (manavalue / maxMana)
		manaUsagebar:SetWidth(useWidth)
		manaUsagebar:SetHeight(barHeight)
		manaUsagebar:SetPoint("TOPLEFT", playerFrame.powerBar, "TOPLEFT", manaWidth - useWidth, 0)
		
	end
end

local function updatePower()
	local currentPower = UnitMana(this.parent.unit)
	local prevPower = this.currentPower or 0
	if( currentPower == prevPower ) then return end
	if this.ticker and (not this.ticker.startTime or UnitMana("player") > prevPower) then
		this.ticker.startTime = GetTime()
	end
	this.currentPower = currentPower
	this:SetValue(currentPower)
	
	if this.parent.unit == "player" then
		UpdateManaUsage()
	end
end

function Power:OnEnable(frame)
	if( not frame.powerBar ) then
		frame.powerBar = LunaUF.Units:CreateBar(frame)
		frame.fontstrings["powerBar"] = {
			["left"] = frame.powerBar:CreateFontString(nil, "ARTWORK"),
			["center"] = frame.powerBar:CreateFontString(nil, "ARTWORK"),
			["right"] = frame.powerBar:CreateFontString(nil, "ARTWORK"),
		}
		for align,fontstring in pairs(frame.fontstrings["powerBar"]) do
			fontstring:SetFont(LunaUF.defaultFont, 14)
			fontstring:SetShadowColor(0, 0, 0, 1.0)
			fontstring:SetShadowOffset(0.80, -0.80)
			fontstring:SetJustifyH(string.upper(align))
			fontstring:SetAllPoints(frame.powerBar)
		end
		if frame.unitGroup == "player" then
			frame.powerBar.ticker = CreateFrame("Frame", nil, frame.powerBar)
			frame.powerBar.ticker:SetBackdrop(LunaUF.constants.backdrop)
			frame.powerBar.ticker:SetBackdropColor(0,0,0)
			frame.powerBar.ticker.texture = frame.powerBar.ticker:CreateTexture(nil, "OVERLAY")
			frame.powerBar.ticker.texture:SetAllPoints(frame.powerBar.ticker)
			frame.powerBar.ticker.texture:SetTexture(1, 1, 1)
			frame.powerBar.ticker:SetPoint("CENTER", frame.powerBar, "CENTER")
			frame.powerBar.ticker.startTime = GetTime()
			frame.powerBar.ticker:SetFrameLevel(7)
			
			frame.powerBar.manaUsage = CreateFrame("Frame", nil, frame.powerBar)
			frame.powerBar.manaUsage.bar = CreateFrame("StatusBar", nil, frame.powerBar)
			frame.powerBar.manaUsage.bar:SetMinMaxValues(0,1)
			frame.powerBar.manaUsage.bar:SetValue(1)
			for _,fontstring in pairs(frame.fontstrings["powerBar"]) do
				fontstring:SetParent(frame.powerBar.manaUsage)
			end

			playerFrame = frame
		end
	else
		frame.powerBar:Show()
	end
	frame.powerBar:RegisterEvent("UNIT_MANA")
	frame.powerBar:RegisterEvent("UNIT_RAGE")
	frame.powerBar:RegisterEvent("UNIT_ENERGY")
	frame.powerBar:RegisterEvent("UNIT_FOCUS")
	frame.powerBar:RegisterEvent("UNIT_MAXMANA")
	frame.powerBar:RegisterEvent("UNIT_MAXRAGE")
	frame.powerBar:RegisterEvent("UNIT_MAXENERGY")
	frame.powerBar:RegisterEvent("UNIT_MAXFOCUS")
	frame.powerBar:RegisterEvent("UNIT_DISPLAYPOWER")

	frame.powerBar:SetScript("OnEvent", OnEvent)
	frame.powerBar:SetScript("OnUpdate", updatePower)
	if frame.powerBar.ticker then
		frame.powerBar.ticker:SetScript("OnUpdate", EnergyUpdate)
		if not LunaUF:IsEventRegistered("fiveSec") then
			LunaUF:RegisterEvent("fiveSec", reset)
		end
	end	
	if frame.powerBar.manaUsage then
		if not LunaUF:IsEventRegistered("CASTLIB_MANAUSAGE") then
			LunaUF:RegisterEvent("CASTLIB_MANAUSAGE", UpdateManaUsage)
		end
	end
end

function Power:OnDisable(frame)
	if frame.powerBar then
		frame.powerBar:UnregisterAllEvents()
		frame.powerBar:SetScript("OnEvent", nil)
		frame.powerBar:SetScript("OnUpdate", nil)
		frame.powerBar:Hide()
		if frame.powerBar.ticker then
			frame.powerBar.ticker:SetScript("OnUpdate", nil)
		end
	end
end

function Power:UpdateColor(frame)
	local powertype = POWERMATCH[UnitPowerType(frame.unit)]
	local color = LunaUF.db.profile.powerColors[powertype] or LunaUF.db.profile.powerColors.MANA
	
	if( not LunaUF.db.profile.units[frame.unitGroup].powerBar.invert ) then
		frame.powerBar:SetStatusBarColor(color.r, color.g, color.b, LunaUF.db.profile.bars.alpha)
		if( not frame.powerBar.background.overrideColor ) then
			frame.powerBar.background:SetVertexColor(color.r, color.g, color.b, LunaUF.db.profile.bars.backgroundAlpha)
		end
	else
		frame.powerBar.background:SetVertexColor(color.r, color.g, color.b, LunaUF.db.profile.bars.alpha)

		color = frame.powerBar.background.overrideColor
		if( not color ) then
			frame.powerBar:SetStatusBarColor(0, 0, 0, 1 - LunaUF.db.profile.bars.backgroundAlpha)
		else
			frame.powerBar:SetStatusBarColor(color.r, color.g, color.b, LunaUF.db.profile.bars.backgroundAlpha)
		end
	end
	if frame.powerBar.ticker then
		if LunaUF.db.profile.units[frame.unitGroup].powerBar.ticker and (UnitPowerType("player") == 3 or UnitPowerType("player") == 0 and timestamp) then
			frame.powerBar.ticker:Show()
		else
			frame.powerBar.ticker:Hide()
		end
	end
	if frame.powerBar.manaUsage then
		frame.powerBar.manaUsage.bar:SetStatusBarColor(LunaUF.db.profile.powerColors.MANAUSAGE.r, LunaUF.db.profile.powerColors.MANAUSAGE.g, LunaUF.db.profile.powerColors.MANAUSAGE.b, 0.9)
	end
end

function Power:Update(frame)
	if UnitPowerType(frame.unit) > 0 then
		if LunaUF.db.profile.units[frame.unitGroup].powerBar.hide and not frame.powerBar.hidden then
			frame.powerBar.hidden = true
			LunaUF.Units:PositionWidgets(frame)
		elseif not LunaUF.db.profile.units[frame.unitGroup].powerBar.hide and frame.powerBar.hidden then
			frame.powerBar.hidden = nil
			LunaUF.Units:PositionWidgets(frame)
		end
	elseif frame.powerBar.hidden then
		frame.powerBar.hidden = nil
		LunaUF.Units:PositionWidgets(frame)
	end
	if frame.unit == "player" then
		UpdateManaUsage()
	end
	
	frame.powerBar.currentPower = UnitMana(frame.unit)
	frame.powerBar:SetMinMaxValues(0, UnitManaMax(frame.unit))
--	frame.powerBar:SetValue(UnitIsDeadOrGhost(frame.unit) and 0 or not UnitIsConnected(frame.unit) and 0 or frame.powerBar.currentPower)
	frame.powerBar:SetValue(UnitIsDeadOrGhost(frame.unit) and 0 or not UnitIsConnected(frame.unit) and 0 or UnitMana(frame.unit))
end

function Power:FullUpdate(frame)
	local tags = LunaUF.db.profile.units[frame.unitGroup].tags.bartags.powerBar
	if LunaUF.db.profile.units[frame.unitGroup].powerBar.vertical then
		frame.powerBar:SetOrientation("VERTICAL")
	else
		frame.powerBar:SetOrientation("HORIZONTAL")
	end
	frame.powerBar:SetReverse(LunaUF.db.profile.units[frame.unitGroup].powerBar.reverse)
	for align,fontstring in pairs(frame.fontstrings["powerBar"]) do
		fontstring:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\"..LunaUF.db.profile.font..".ttf", tags.size)
		fontstring:ClearAllPoints()
		fontstring:SetHeight(frame.powerBar:GetHeight())
		if align == "left" then
			fontstring:SetPoint("LEFT", frame.powerBar, "LEFT", 2, 0)
			fontstring:SetWidth((frame.powerBar:GetWidth()-4)*(tags.leftsize/100))
		elseif align == "center" then
			fontstring:SetPoint("CENTER", frame.powerBar, "CENTER")
			fontstring:SetWidth(frame.powerBar:GetWidth()*(tags.middlesize/100))
		else
			fontstring:SetPoint("RIGHT", frame.powerBar, "RIGHT", -2 , 0)
			fontstring:SetWidth((frame.powerBar:GetWidth()-4)*(tags.rightsize/100))
		end
	end
	if frame.powerBar.ticker then
		if LunaUF.db.profile.units[frame.unitGroup].powerBar.vertical then
			frame.powerBar.ticker:SetWidth(frame.powerBar:GetWidth()-3)
			frame.powerBar.ticker:SetHeight(1)
		else
			frame.powerBar.ticker:SetHeight(frame.powerBar:GetHeight()-3)
			frame.powerBar.ticker:SetWidth(1)
		end
	end
	Power:Update(frame)
	Power:UpdateColor(frame)
end

function Power:SetBarTexture(frame,texture)
	if frame.powerBar then
		frame.powerBar:SetStatusBarTexture(texture)
		frame.powerBar:SetStretchTexture(LunaUF.db.profile.stretchtex)
		frame.powerBar.background:SetTexture(texture)
		if frame.powerBar.manaUsage then
			frame.powerBar.manaUsage.bar:SetStatusBarTexture("Interface\\Tooltips\\UI-Tooltip-Background")
		end
	end
end