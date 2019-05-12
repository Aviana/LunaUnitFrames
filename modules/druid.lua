local Druid = {}
LunaUF:RegisterModule(Druid, "druidBar", LunaUF.L["Druid bar"], true, "DRUID")

function Druid:OnEnable(frame)
	frame.druidBar = frame.druidBar or LunaUF.Units:CreateBar(frame)
	
	frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", self, "Update")
	frame:RegisterUnitEvent("UNIT_MAXPOWER", self, "Update")
	frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", self, "UpdateState")
	frame:RegisterUnitEvent("UNIT_MANA", self, "Update")

	frame:RegisterUpdateFunc(self, "UpdateState")
	frame:RegisterUpdateFunc(self, "Update")
end

function Druid:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Druid:UpdateState(frame)
	local _, currentType = UnitPowerType(frame.unit)
	local color = LunaUF.db.profile.colors["MANA"]

	LunaUF.Layout:SetBarVisibility(frame, "druidBar", currentType ~= "MANA")

	frame:SetBarColor("druidBar", color.r, color.g, color.b)

	self:Update(frame)
end

function Druid:Update(frame, event, unit, powerType)
	frame.druidBar:SetMinMaxValues(0, UnitPowerMax(frame.unit, Enum.PowerType.Mana))
	frame.druidBar:SetValue(UnitPower(frame.unit, Enum.PowerType.Mana))
end
