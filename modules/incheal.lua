local IncHeal = {}
LunaUF:RegisterModule(IncHeal, "incHeal", LunaUF.L["Incoming heals"])
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")

function IncHeal:OnEnable(frame)
	frame.incHeal = frame.incHeal or LunaUF.Units:CreateBar(frame)

	frame:RegisterUnitEvent("UNIT_MAXHEALTH", self, "Update")
	frame:RegisterUnitEvent("UNIT_HEALTH", self, "Update")
	frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", self, "Update")
--	frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", self, "Update")

	frame:RegisterUpdateFunc(self, "Update")
end

function IncHeal:OnDisable(frame)
	frame:UnregisterAll(self)
	frame.incHeal:Hide()
end

function IncHeal:OnLayoutApplied(frame)
	local bar = frame.incHeal
	if( not frame.visibility.incHeal or not frame.visibility.healthBar ) then return end

	-- Since we're hiding, reset state
	bar.total = nil

	bar:SetSize(frame.healthBar:GetSize())
	bar:SetStatusBarTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	bar:SetStatusBarColor(LunaUF.db.profile.colors.incheal.r, LunaUF.db.profile.colors.incheal.g, LunaUF.db.profile.colors.incheal.b, LunaUF.db.profile.units[frame.unitType].incHeal.alpha)
	bar:GetStatusBarTexture():SetHorizTile(false)
	bar:SetOrientation(frame.healthBar:GetOrientation())
	bar:SetReverseFill(frame.healthBar:GetReverseFill())
	bar:Hide()
	
	local cap = LunaUF.db.profile.units[frame.unitType].incHeal.cap or 1.30

	if( ( LunaUF.db.profile.units[frame.unitType].healthBar.invert and LunaUF.db.profile.units[frame.unitType].healthBar.backgroundAlpha == 0 ) or ( not LunaUF.db.profile.units[frame.unitType].healthBar.invert and LunaUF.db.profile.units[frame.unitType].healthBar.backgroundAlpha == 1 ) ) then
		bar.simple = true
		bar:SetFrameLevel(frame.topFrameLevel - 2)

		if( bar:GetOrientation() == "HORIZONTAL" ) then
			bar:SetWidth(frame.healthBar:GetWidth() * cap)
		else
			bar:SetHeight(frame.healthBar:GetHeight() * cap)
		end

		bar:ClearAllPoints()
		
		local point = bar:GetReverseFill() and "RIGHT" or "LEFT"
		bar:SetPoint("TOP" .. point, frame.healthBar)
		bar:SetPoint("BOTTOM" .. point, frame.healthBar)
	else
		bar.simple = nil
		bar:SetFrameLevel(frame.topFrameLevel + 1)
		bar:SetWidth(1)
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(1)
		bar:ClearAllPoints()

		bar.orientation = bar:GetOrientation()
		bar.reverseFill = bar:GetReverseFill()

		if( bar.orientation == "HORIZONTAL" ) then
			bar.healthSize = frame.healthBar:GetWidth() or 1
			bar.positionPoint = bar.reverseFill and "TOPRIGHT" or "TOPLEFT"
			bar.positionRelative = bar.reverseFill and "BOTTOMRIGHT" or "BOTTOMLEFT"
		else
			bar.healthSize = frame.healthBar:GetHeight() or 1
			bar.positionPoint = bar.reverseFill and "TOPLEFT" or "BOTTOMLEFT"
			bar.positionRelative = bar.reverseFill and "TOPRIGHT" or "BOTTOMRIGHT"
		end

		bar.positionMod = bar.reverseFill and -1 or 1
		bar.maxSize = bar.healthSize * cap
	end
end

function IncHeal:PositionBar(frame, incAmount)
	local bar = frame.incHeal

	if( incAmount <= 0 ) then
		bar.total = nil
		bar:Hide()
		return
	end

	local health = UnitHealth(frame.unit)
	if( health <= 0 ) then
		bar.total = nil
		bar:Hide()
		return
	end

	local maxHealth = UnitHealthMax(frame.unit)
	if( maxHealth <= 0 ) then
		bar.total = nil
		bar:Hide()
		return
	end

	if( not bar.total ) then bar:Show() end
	bar.total = incAmount

	if( bar.simple ) then
		bar.total = health + incAmount
		bar:SetMinMaxValues(0, maxHealth * (LunaUF.db.profile.units[frame.unitType].incHeal.cap or 1.30))
		bar:SetValue(bar.total)
	else
		local healthSize = bar.healthSize * (health / maxHealth)
		local incSize = bar.healthSize * (incAmount / maxHealth)

		if( (healthSize + incSize) > bar.maxSize ) then
			incSize = bar.maxSize - healthSize
		end

		if( bar.orientation == "HORIZONTAL" ) then
			bar:SetWidth(incSize)
			bar:SetPoint(bar.positionPoint, frame.healthBar, bar.positionMod * healthSize, 0)
			bar:SetPoint(bar.positionRelative, frame.healthBar, bar.positionMod * healthSize, 0)
		else
			bar:SetHeight(incSize)
			bar:SetPoint(bar.positionPoint, frame.healthBar, 0, bar.positionMod * healthSize)
			bar:SetPoint(bar.positionRelative, frame.healthBar, 0, bar.positionMod * healthSize)
		end
	end
end

function IncHeal:Update(frame)
	if( not frame.visibility.incHeal or not frame.visibility.healthBar ) then return end
	
	local amount = 0 --UnitGetIncomingHeals(frame.unit) or 0
	if( amount > 0 ) then
		amount = amount + (UnitGetTotalHealAbsorbs(frame.unit) or 0)
	end

	self:PositionBar(frame, amount)
end