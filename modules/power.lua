local Power = {}
local POWERMATCH = {
		[0] = "MANA",
		[1] = "RAGE",
		[2] = "FOCUS",
		[3] = "ENERGY"
		}
local timestamp
local playerFrame
local AceEvent = LunaUF.AceEvent
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
	local Position
	if powerType == 0 then
		if timestamp then
			if (time - timestamp) >= 5 then
				timestamp = nil
				this:Hide()
			else
				Position = (((time - timestamp) / 5)* frame:GetWidth())
			end
		end
	elseif powerType == 3 then
		if (time - this.startTime) >= 2 then 		--Ticks happen every 2 sec
			this.startTime = GetTime()
		end
		Position = (((time - this.startTime) / 2)* frame:GetWidth())
	else
		this:Hide()
		return
	end
	this:SetPoint("CENTER", frame, "LEFT", Position, 0)
end

local function OnEvent()
	if arg1 ~= this:GetParent().unit then return end
	if event == "UNIT_DISPLAYPOWER" then
		Power:UpdateColor(this:GetParent())
		Power:Update(this:GetParent())
	else
		if this.ticker and (not this.ticker.startTime or UnitMana("player") > this.currentPower) then
			this.ticker.startTime = GetTime()
		end
		Power:Update(this:GetParent())
	end
end

local function updatePower()
	local currentPower = UnitMana(this.parent.unit)
	if( currentPower == this.currentPower ) then return end
	if this.ticker and (not this.ticker.startTime or UnitMana("player") > this.currentPower) then
		this.ticker.startTime = GetTime()
	end
	this.currentPower = currentPower
	this:SetValue(currentPower)
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
			fontstring:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", 14)
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
			frame.powerBar.ticker:SetWidth(1)
			frame.powerBar.ticker:SetPoint("CENTER", frame.powerBar, "CENTER")
			frame.powerBar.ticker.startTime = GetTime()
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
		if not AceEvent:IsEventRegistered("fiveSec") then
			AceEvent:RegisterEvent("fiveSec", reset)
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
end

function Power:Update(frame)
	frame.powerBar.currentPower = UnitMana(frame.unit)
	frame.powerBar:SetMinMaxValues(0, UnitManaMax(frame.unit))
	frame.powerBar:SetValue(UnitIsDeadOrGhost(frame.unit) and 0 or not UnitIsConnected(frame.unit) and 0 or frame.powerBar.currentPower)
end

function Power:FullUpdate(frame)
	if LunaUF.db.profile.units[frame.unitGroup].powerBar.vertical then
		frame.powerBar:SetOrientation("VERTICAL")
	else
		frame.powerBar:SetOrientation("HORIZONTAL")
	end
	for align,fontstring in pairs(frame.fontstrings["powerBar"]) do
		fontstring:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\"..LunaUF.db.profile.font..".ttf", LunaUF.db.profile.units[frame.unitGroup].tags.bartags["powerBar"].size)
		fontstring:ClearAllPoints()
		fontstring:SetHeight(frame.powerBar:GetHeight())
		if align == "left" then
			fontstring:SetPoint("TOPLEFT", frame.powerBar, "TOPLEFT", 2, 0)
			fontstring:SetWidth(frame.powerBar:GetWidth()-4)
		elseif align == "center" then
			fontstring:SetAllPoints(frame.powerBar)
			fontstring:SetWidth(frame.powerBar:GetWidth())
		else
			fontstring:SetPoint("TOPRIGHT", frame.powerBar, "TOPRIGHT", -2 , 0)
			fontstring:SetWidth(frame.powerBar:GetWidth()-4)
		end
	end
	if frame.powerBar.ticker then
		frame.powerBar.ticker:SetHeight(frame.powerBar:GetHeight()-3)
	end
	Power:Update(frame)
	Power:UpdateColor(frame)
end

function Power:SetBarTexture(frame,texture)
	if frame.powerBar then
		frame.powerBar:SetStatusBarTexture(texture)
		frame.powerBar.background:SetTexture(texture)
	end
end