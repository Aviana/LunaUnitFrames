local Power = {}
LunaUF:RegisterModule(Power, "powerBar", LunaUF.L["Power bar"], true)

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	tile = true,
	tileSize = 16,
	insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5},
}

local PowerUpdate = function(self)
	local powerType = UnitPowerType("player")
	local frame = self:GetParent()
	local time = GetTime()
	local Position = 0
	if powerType == Enum.PowerType.Mana then
		if self.startTime then
			if (time - self.startTime) >= 5 then
				self.startTime = nil
				self:Hide()
			else
				Position = ((time - self.startTime) / 5)
			end
		end
	elseif powerType == Enum.PowerType.Energy then
		if (time - self.startTime) >= 2 then 		--Ticks happen every 2 sec
			self.startTime = GetTime()
		end
		Position = ((time - self.startTime) / 2)
	else
		self:Hide()
		return
	end
	self:SetPoint("CENTER", frame, "LEFT", Position * frame:GetWidth(), 0)
end

function Power:OnEnable(frame)
	frame.powerBar = frame.powerBar or LunaUF.Units:CreateBar(frame)
	
	if frame.unitType ~= "player" then
		frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", self, "Update")
	end
	frame:RegisterUnitEvent("UNIT_POWER_UPDATE", self, "Update")
	frame:RegisterUnitEvent("UNIT_MAXPOWER", self, "Update")
	frame:RegisterUnitEvent("UNIT_CONNECTION", self, "Update")
	frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", self, "UpdateColor")
	frame:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", self, "UpdateClassification")
	

	-- run an update after returning to life
	if ( frame.unit == "player" ) then
		frame:RegisterNormalEvent("PLAYER_UNGHOST", self, "Update")
	end
	if not frame.powerBar.ticker and frame.unitType == "player" then
		frame.powerBar.ticker = CreateFrame("Frame", nil, frame.powerBar)
		frame.powerBar.ticker:SetBackdrop(backdrop)
		frame.powerBar.ticker:SetBackdropColor(0,0,0)
		frame.powerBar.ticker.texture = frame.powerBar.ticker:CreateTexture(nil, "OVERLAY")
		frame.powerBar.ticker.texture:SetAllPoints(frame.powerBar.ticker)
		frame.powerBar.ticker.texture:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\indicator")
		frame.powerBar.ticker.texture:SetVertexColor(1,1,1,1)
		frame.powerBar.ticker:SetPoint("CENTER", frame.powerBar, "CENTER")
		frame.powerBar.ticker.startTime = GetTime()
		frame.powerBar.ticker:SetFrameLevel(6)
		
		frame:RegisterNormalEvent("COMBAT_LOG_EVENT_UNFILTERED", self, "UpdatePowerStateIgnore")
		frame.powerBar.ticker:SetScript("OnUpdate", PowerUpdate)
	end

	frame.powerBar.currentPower = UnitPower(frame.unit)

	-- UNIT_MANA fires after repopping at a spirit healer, make sure to update powers then
	frame:RegisterUnitEvent("UNIT_MANA", self, "Update")

	frame:RegisterUpdateFunc(self, "UpdateClassification")
	frame:RegisterUpdateFunc(self, "UpdateColor")
	frame:RegisterUpdateFunc(self, "Update")
end

function Power:OnDisable(frame)
	frame:UnregisterAll(self)
end

local events = {
	["SPELL_ENERGIZE"] = true,
	["SPELL_DRAIN"] = true,
	["SPELL_LEECH"] = true,
	["SPELL_PERIODIC_ENERGIZE"] = true,
	["SPELL_PERIODIC_DRAIN"] = true,
	["SPELL_PERIODIC_LEECH"] = true,
}
function Power:UpdatePowerStateIgnore(frame)
	local _, event, _, _, _, _, _, targetID = CombatLogGetCurrentEventInfo()
	if events[event] and targetID == UnitGUID("player") then
		frame.powerBar.ignorePowerChange = true
	end
end

local altColor = {}
function Power:UpdateColor(frame)
	local powerID, currentType, altR, altG, altB = UnitPowerType(frame.unit)
	frame.powerBar.currentType = currentType

	if( LunaUF.db.profile.units[frame.unitType].powerBar.onlyMana ) then
		LunaUF.Layout:SetBarVisibility(frame, "powerBar", currentType == "MANA")
		if( currentType ~= "MANA" ) then return end
	end


	local color
	if( frame.powerBar.minusMob ) then
		color = ShadowUF.db.profile.colors.offline
	elseif( LunaUF.db.profile.units[frame.unitType].powerBar.colorType == "class" and UnitIsPlayer(frame.unit) ) then
		local class = frame:UnitClassToken()
		color = class and LunaUF.db.profile.colors[class]
	end
	
	if( not color ) then
		color = LunaUF.db.profile.colors[frame.powerBar.currentType]
		if( not color ) then
			if( altR ) then
				altColor.r, altColor.g, altColor.b = altR, altG, altB
				color = altColor
			else
				color = LunaUF.db.profile.colors.MANA
			end
		end
	end

	if frame.unitType == "player" then
		if not LunaUF.db.profile.units.player.powerBar.ticker or UnitPowerType("player") ~= Enum.PowerType.Energy then
			frame.powerBar.ticker:Hide()
		elseif LunaUF.db.profile.units.player.powerBar.ticker and UnitPowerType("player") == Enum.PowerType.Energy then
			frame.powerBar.ticker:Show()
		end
	end

	frame:SetBarColor("powerBar", color.r, color.g, color.b)

	self:Update(frame)
end

function Power:OnLayoutApplied(frame)
	if frame.unitType == "player" then
		frame.powerBar.ticker:SetHeight(frame.powerBar:GetHeight())
		frame.powerBar.ticker:SetWidth(1)
	end
end


function Power:UpdateClassification(frame, event, unit)
	local classif = UnitClassification(frame.unit)
	local minus = nil
	if( classif == "minus" ) then
		minus = true

		frame.powerBar:SetMinMaxValues(0, 1)
		frame.powerBar:SetValue(0)
	end

	if( minus ~= frame.powerBar.minusMob ) then
		frame.powerBar.minusMob = minus

		-- Only need to force an update if it was event driven, otherwise the update func will hit color/etc next
		if( event ) then
			self:UpdateColor(frame)
		end
	end
end

function Power:Update(frame, event, unit, powerType)
	if( event and powerType and powerType ~= frame.powerBar.currentType ) then return end
	if( frame.powerBar.minusMob ) then return end

	if frame.unitType == "player" and LunaUF.db.profile.units.player.powerBar.ticker then
		if frame.powerBar.ignorePowerChange then
			frame.powerBar.ignorePowerChange = nil
		elseif frame.powerBar.currentPower < UnitPower(frame.unit) and UnitPowerType("player") == Enum.PowerType.Energy then
			frame.powerBar.ticker.startTime = GetTime()
		elseif frame.powerBar.currentPower > UnitPower(frame.unit) and not (UnitPowerMax(frame.unit) == UnitPower(frame.unit)) and UnitPowerType("player") == Enum.PowerType.Mana then
			frame.powerBar.ticker.startTime = GetTime()
			frame.powerBar.ticker:Show()
		end
	end
	frame.powerBar.currentPower = UnitPower(frame.unit)
	frame.powerBar:SetMinMaxValues(0, UnitPowerMax(frame.unit))
	frame.powerBar:SetValue(UnitIsDeadOrGhost(frame.unit) and 0 or not UnitIsConnected(frame.unit) and 0 or frame.powerBar.currentPower)
end
