local Druid = {}
LunaUF:RegisterModule(Druid, "druidBar", LunaUF.L["Druid bar"], true, "DRUID")

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
	local Position, Position2
	local config = LunaUF.db.profile.units.player.druidBar

	if config.fivesecond then
		if self.startTimeFive then
			if (time - self.startTimeFive) >= 5 then
				self.startTimeFive = nil
			else
				Position2 = ((time - self.startTimeFive) / 5)
			end
		end
	end

	if (time - self.startTimeTicks) >= 2 then 		--Ticks happen every 2 sec
		self.startTimeTicks = GetTime()
	end
	if config.ticker then
		Position = ((time - self.startTimeTicks) / 2)
	end
	if (Position or Position2) and ( not config.hideticker or UnitPower("player", Enum.PowerType.Mana) < UnitPowerMax("player", Enum.PowerType.Mana) ) then
		self.texture:Show()
		self:SetBackdropColor(0,0,0,1)
		frame.ticker2:Show()
	else
		self.texture:Hide()
		self:SetBackdropColor(0,0,0,0)
		frame.ticker2:Hide()
	end
	if (Position or Position2) then
		self:SetPoint("BOTTOM", frame, "LEFT", (Position or Position2) * frame:GetWidth(), 0)
		frame.ticker2:SetPoint("TOP", frame, "LEFT", (Position2 or Position) * frame:GetWidth(), 0)
	end
end

function Druid:OnEnable(frame)
	frame.druidBar = frame.druidBar or LunaUF.Units:CreateBar(frame)
	
	if not frame.druidBar.ticker and frame.unitType == "player" then
		frame.druidBar.ticker = CreateFrame("Frame", nil, frame.druidBar)
		frame.druidBar.ticker:SetBackdrop(backdrop)
		frame.druidBar.ticker:SetBackdropColor(0,0,0)
		frame.druidBar.ticker.texture = frame.druidBar.ticker:CreateTexture(nil, "OVERLAY")
		frame.druidBar.ticker.texture:SetAllPoints(frame.druidBar.ticker)
		frame.druidBar.ticker.texture:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\indicator")
		frame.druidBar.ticker.texture:SetVertexColor(1,1,1,1)
		frame.druidBar.ticker:SetPoint("BOTTOM", frame.druidBar, "CENTER")
		frame.druidBar.ticker.startTimeTicks = GetTime()
		frame.druidBar.ticker:SetFrameLevel(6)
		frame.druidBar.ticker.combat = UnitAffectingCombat("player")
		frame.druidBar.ticker:SetWidth(1)
		
		frame.druidBar.ticker2 = CreateFrame("Frame", nil, frame.druidBar)
		frame.druidBar.ticker2:SetBackdrop(backdrop)
		frame.druidBar.ticker2:SetBackdropColor(0,0,0)
		frame.druidBar.ticker2.texture = frame.druidBar.ticker2:CreateTexture(nil, "OVERLAY")
		frame.druidBar.ticker2.texture:SetAllPoints(frame.druidBar.ticker2)
		frame.druidBar.ticker2.texture:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\indicator")
		frame.druidBar.ticker2.texture:SetVertexColor(1,1,1,1)
		frame.druidBar.ticker2:SetPoint("TOP", frame.druidBar, "CENTER")
		frame.druidBar.ticker2:SetFrameLevel(6)
		frame.druidBar.ticker2:SetWidth(1)
		
		frame:RegisterNormalEvent("COMBAT_LOG_EVENT_UNFILTERED", self, "UpdatePowerStateIgnore")
		
		frame.druidBar.ticker:SetScript("OnUpdate", PowerUpdate)
	end
	
	frame.druidBar.currentPower = UnitPower(frame.unit, Enum.PowerType.Mana)
	
	frame:RegisterUnitEvent("UNIT_POWER_UPDATE", self, "Update")
	frame:RegisterUnitEvent("UNIT_MAXPOWER", self, "Update")
	frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", self, "UpdateState")
	frame:RegisterUnitEvent("UNIT_MANA", self, "Update")

	frame:RegisterUpdateFunc(self, "UpdateState")
	frame:RegisterUpdateFunc(self, "Update")
end

function Druid:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Druid:OnLayoutApplied(frame)
	if frame.unitType == "player" and frame.druidBar then
		frame.druidBar.ticker:SetHeight(frame.druidBar:GetHeight()/2)
		frame.druidBar.ticker2:SetHeight(frame.druidBar:GetHeight()/2)
	end
end

local events = {
	["SPELL_ENERGIZE"] = true,
	["SPELL_PERIODIC_ENERGIZE"] = true,
}
function Druid:UpdatePowerStateIgnore(frame)
	local _, event, _, _, _, _, _, targetID = CombatLogGetCurrentEventInfo()
	if events[event] and targetID == UnitGUID("player") then
		frame.druidBar.ignorePowerChange = true
	end
end

function Druid:UpdateState(frame)
	local _, currentType = UnitPowerType(frame.unit)
	local color = LunaUF.db.profile.colors["MANA"]

	LunaUF.Layout:SetBarVisibility(frame, "druidBar", currentType ~= "MANA" or not LunaUF.db.profile.units.player.druidBar.autoHide)

	frame:SetBarColor("druidBar", color.r, color.g, color.b)

	self:Update(frame)
end

function Druid:Update(frame, event, unit, powerType)
	if powerType and powerType ~= "MANA" then return end
	
	if not event then
		local _, currentType = UnitPowerType(frame.unit)
		LunaUF.Layout:SetBarVisibility(frame, "druidBar", currentType ~= "MANA" or not LunaUF.db.profile.units.player.druidBar.autoHide)
	end
	
	frame.druidBar.background:SetAlpha(LunaUF.db.profile.units[frame.unitType].druidBar.backgroundAlpha)

	if frame.unitType == "player" then
		if frame.druidBar.ignorePowerChange then
			frame.druidBar.ignorePowerChange = nil
		elseif frame.druidBar.currentPower < UnitPower(frame.unit, Enum.PowerType.Mana) then
			frame.druidBar.ticker.startTimeTicks = GetTime()
		elseif frame.druidBar.currentPower > UnitPower(frame.unit, Enum.PowerType.Mana) and not (UnitPowerMax(frame.unit, Enum.PowerType.Mana) == UnitPower(frame.unit, Enum.PowerType.Mana)) then
			frame.druidBar.ticker.startTimeFive = GetTime()
			frame.druidBar.ticker.texture:Show()
			frame.druidBar.ticker:SetBackdropColor(0,0,0,1)
		end
	end
	
	frame.druidBar.currentPower = UnitPower(frame.unit, Enum.PowerType.Mana)
	frame.druidBar:SetMinMaxValues(0, UnitPowerMax(frame.unit, Enum.PowerType.Mana))
	frame.druidBar:SetValue(UnitPower(frame.unit, Enum.PowerType.Mana))
end
