local IncHeal = {}
LunaUF:RegisterModule(IncHeal, "incHeal", LunaUF.L["Incoming heals"])
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")
local HealComm = LibStub("LibClassicHealComm-1.0", true)
local frames = {}



function IncHeal:OnEnable(frame)
	frame.incHeal = frame.incHeal or LunaUF.Units:CreateBar(frame)
	frames[frame] = true
	frame.incHeal.incAmount = 0
	frame:RegisterUnitEvent("UNIT_MAXHEALTH", self, "Update")
	frame:RegisterUnitEvent("UNIT_HEALTH", self, "Update")
	frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", self, "Update")

	frame:RegisterUpdateFunc(self, "Update")
end

function IncHeal:OnDisable(frame)
	frames[frame] = nil
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
	local health = UnitHealth(frame.unit)
	local maxHealth = UnitHealthMax(frame.unit)

	if( incAmount <= 0 or UnitIsDeadOrGhost(frame.unit) or maxHealth <= 0 ) then
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

		if incSize <= 0 then
			bar.total = nil
			bar:Hide()
			return
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
	local amount = (HealComm:GetHealAmount(frame.unitGUID, HealComm.ALL_HEALS) or 0) * (HealComm:GetHealModifier(frame.unitGUID) or 1)
	frame.incomingHeal = amount
	if( not frame.visibility.incHeal or not frame.visibility.healthBar ) then return end
	self:PositionBar(frame, amount)
end

function IncHeal:UpdateIncoming(...)
	for frame in pairs(frames) do
		for i=1, select("#", ...) do
			if( select(i, ...) == frame.unitGUID ) and (UnitPlayerOrPetInParty(frame.unit) or UnitPlayerOrPetInRaid(frame.unit) or UnitIsUnit("player",frame.unit) or UnitIsUnit("pet",frame.unit)) then
				self:Update(frame)
				break
			end
		end
	end
end

-- Handle callbacks from HealComm
function IncHeal:HealComm_HealUpdated(event, casterGUID, spellID, healType, endTime, ...)
	IncHeal:UpdateIncoming(...)
end

function IncHeal:HealComm_HealStopped(event, casterGUID, spellID, healType, interrupted, ...)
	IncHeal:UpdateIncoming(...)
end

function IncHeal:HealComm_ModifierChanged(event, guid)
	IncHeal:UpdateIncoming(guid)
end

function IncHeal:HealComm_GUIDDisappeared(event, guid)
	IncHeal:UpdateIncoming(guid)
end

HealComm.RegisterCallback(IncHeal, "HealComm_HealStarted", "HealComm_HealUpdated")
HealComm.RegisterCallback(IncHeal, "HealComm_HealStopped")
HealComm.RegisterCallback(IncHeal, "HealComm_HealDelayed", "HealComm_HealUpdated")
HealComm.RegisterCallback(IncHeal, "HealComm_HealUpdated")
HealComm.RegisterCallback(IncHeal, "HealComm_ModifierChanged")
HealComm.RegisterCallback(IncHeal, "HealComm_GUIDDisappeared")