local ManaPrediction = {}
LunaUF:RegisterModule(ManaPrediction, "manaPrediction", LunaUF.L["Mana Prediction"])
local manaCost = 0

function ManaPrediction:OnEnable(frame)
	frame.manaPrediction = frame.manaPrediction or frame:CreateTexture(nil, "OVERLAY")
	frame.manaPrediction:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	
	frame:RegisterUnitEvent("UNIT_POWER_UPDATE", self, "Update")
	frame:RegisterUnitEvent("UNIT_MAXPOWER", self, "Update")
	frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", self, "Update")
	frame:RegisterUnitEvent("UNIT_SPELLCAST_START", self, "CastStart")
	frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self, "CastStop")
	frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self, "CastStop")
	frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self, "CastStop")

	frame:RegisterUpdateFunc(self, "Update")
end

function ManaPrediction:OnDisable(frame)
	frame:UnregisterAll(self)
	frame.manaPrediction:Hide()
end

function ManaPrediction:OnLayoutWidgets(frame)
	if( not frame.visibility.manaPrediction or not frame.visibility.powerBar ) then return end

	local bar, pred = frame.powerBar, frame.manaPrediction
	
	pred:SetParent(bar)
	if bar:GetOrientation() == "HORIZONTAL" then
		pred:SetHeight(bar:GetHeight())
	else
		pred:SetWidth(bar:GetWidth())
	end
end

function ManaPrediction:CastStart(frame)
	local results = GetSpellPowerCost(select(9,CastingInfo()))
	for _,result in ipairs(results) do
		if result.name == "MANA" and result.cost > 0 then
			manaCost = result.cost
			self:Update(frame)
			return
		end
	end
end

function ManaPrediction:CastStop(frame)
	if manaCost > 0 then
		manaCost = 0
		self:Update(frame)
	end
end

function ManaPrediction:Update(frame)
	if( not frame.visibility.manaPrediction or not frame.visibility.powerBar ) then return end
	
	local mana, maxMana = UnitPower(frame.unit), UnitPowerMax(frame.unit)
	local pred, bar, color = frame.manaPrediction, frame.powerBar, LunaUF.db.profile.units.player.manaPrediction.color
	
	if manaCost == 0 or UnitPowerType(frame.unit) ~= 0 then
		frame.manaPrediction:Hide()
		return
	else
		frame.manaPrediction:Show()
	end
	
	pred:SetVertexColor(color.r, color.g, color.b, color.a)
	if bar:GetOrientation() == "HORIZONTAL" then
		local chunkSize = bar:GetWidth() / maxMana
		pred:ClearAllPoints()
		pred:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", mana*chunkSize, 0)
		pred:SetWidth(chunkSize * manaCost)
	else
		local chunkSize = bar:GetHeight() / maxMana
		pred:ClearAllPoints()
		pred:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, mana*chunkSize)
		pred:SetHeight(chunkSize * manaCost)
	end
end