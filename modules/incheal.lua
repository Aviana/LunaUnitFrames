local IncHeal = {}
LunaUF:RegisterModule(IncHeal, "incHeal", LunaUF.L["Incoming heals"])
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")
local HealComm = LibStub("LibHealComm-4.0", true)
local frames = {}



function IncHeal:OnEnable(frame)
	frame.incHeal = frame.incHeal or CreateFrame("Frame", nil, frame)
	frames[frame] = true
	frame.incHeal.bars = frame.incHeal.bars or {}
	for i=1, 4 do
		frame.incHeal.bars[i] = frame.incHeal.bars[i] or frame.incHeal:CreateTexture(nil, "OVERLAY")
		frame.incHeal.bars[i]:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	end
	frame:RegisterUnitEvent("UNIT_MAXHEALTH", self, "PositionBar")
	frame:RegisterUnitEvent("UNIT_HEALTH", self, "PositionBar")
	frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", self, "PositionBar")

	frame:RegisterUpdateFunc(self, "Update")
end

function IncHeal:OnDisable(frame)
	frames[frame] = nil
	frame:UnregisterAll(self)
	frame.incHeal:Hide()
end

function IncHeal:OnLayoutWidgets(frame)
	if( not frame.visibility.incHeal or not frame.visibility.healthBar ) then return end

	local bars = frame.incHeal.bars

	if frame.healthBar:GetOrientation() == "HORIZONTAL" then
		for i=1,4 do
			bars[i]:SetHeight(frame.healthBar:GetHeight())
		end
	else
		for i=1,4 do
			bars[i]:SetWidth(frame.healthBar:GetWidth())
		end
	end
end

function IncHeal:OnLayoutApplied(frame)
	if( not frame.visibility.incHeal or not frame.visibility.healthBar ) then return end

	local bars = frame.incHeal.bars

	if frame.healthBar:GetOrientation() == "HORIZONTAL" then
		for i=2,4 do
			bars[i]:ClearAllPoints()
			bars[i]:SetPoint("BOTTOMLEFT", bars[i-1], "BOTTOMRIGHT")
		end
	else
		for i=2,4 do
			bars[i]:ClearAllPoints()
			bars[i]:SetPoint("BOTTOMLEFT", bars[i-1], "TOPLEFT")
		end
	end
end

function IncHeal:PositionBar(frame)
	local mod = frame.healValues.mod
	local totalHeal, preHeal, ownHeal, afterHeal, hotHeal = frame.healValues.totalHeal, frame.healValues.preHeal * mod, frame.healValues.ownHeal * mod, frame.healValues.afterHeal * mod, frame.healValues.Hots * mod
	local bars = frame.incHeal.bars
	local health, maxHealth = UnitHealth(frame.unit), UnitHealthMax(frame.unit)
	local cap = LunaUF.db.profile.units[frame.unitType].incHeal.cap or 1.30
	local currBar = 1

	if( totalHeal <= 0 or UnitIsDeadOrGhost(frame.unit) or maxHealth <= 0 or (health == maxHealth and cap == 1)) then
		frame.incHeal:Hide()
		return
	else
		frame.incHeal:Show()
	end

	if frame.healthBar:GetOrientation() == "HORIZONTAL" then
		local maxSize = maxHealth * cap
		local chunkSize = frame.healthBar:GetWidth() / maxHealth
		local currWidth = health
		bars[currBar]:ClearAllPoints()
		bars[currBar]:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", health/maxHealth*frame.healthBar:GetWidth(), 0)
		if preHeal > 0 then
			bars[currBar]:Show()
			if (health + preHeal) > maxSize then
				bars[currBar]:SetWidth((maxSize - health) * chunkSize)
				currWidth = maxSize
			else
				bars[currBar]:SetWidth(preHeal * chunkSize)
				currWidth = currWidth + preHeal
			end
			bars[currBar]:SetVertexColor(LunaUF.db.profile.colors.incheal.r, LunaUF.db.profile.colors.incheal.g, LunaUF.db.profile.colors.incheal.b, LunaUF.db.profile.units[frame.unitType].incHeal.alpha)
			currBar = currBar + 1
		end
		if ownHeal > 0 then
			bars[currBar]:Show()
			if currWidth == maxSize then
				bars[currBar]:SetWidth(1)
			elseif (currWidth + ownHeal) > maxSize then
				bars[currBar]:SetWidth((maxSize - currWidth) * chunkSize)
				currWidth = maxSize
			else
				bars[currBar]:SetWidth(ownHeal * chunkSize)
				currWidth = currWidth + ownHeal
			end
			bars[currBar]:SetVertexColor(LunaUF.db.profile.colors.incownheal.r, LunaUF.db.profile.colors.incownheal.g, LunaUF.db.profile.colors.incownheal.b, LunaUF.db.profile.units[frame.unitType].incHeal.alpha)
			currBar = currBar + 1
		end
		if afterHeal > 0 then
			bars[currBar]:Show()
			if currWidth == maxSize then
				bars[currBar]:SetWidth(1)
			elseif (currWidth + afterHeal) > maxSize then
				bars[currBar]:SetWidth((maxSize - currWidth) * chunkSize)
				currWidth = maxSize
			else
				bars[currBar]:SetWidth(afterHeal * chunkSize)
				currWidth = currWidth + afterHeal
			end
			bars[currBar]:SetVertexColor(LunaUF.db.profile.colors.incheal.r, LunaUF.db.profile.colors.incheal.g, LunaUF.db.profile.colors.incheal.b, LunaUF.db.profile.units[frame.unitType].incHeal.alpha)
			currBar = currBar + 1
		end
		if hotHeal > 0 then
			bars[currBar]:Show()
			if currWidth == maxSize then
				bars[currBar]:SetWidth(1)
			elseif (currWidth + hotHeal) > maxSize then
				bars[currBar]:SetWidth((maxSize - currWidth) * chunkSize)
				currWidth = maxSize
			else
				bars[currBar]:SetWidth(hotHeal * chunkSize)
				currWidth = currWidth + hotHeal
			end
			bars[currBar]:SetVertexColor(LunaUF.db.profile.colors.inchots.r, LunaUF.db.profile.colors.inchots.g, LunaUF.db.profile.colors.inchots.b, LunaUF.db.profile.units[frame.unitType].incHeal.alpha)
			currBar = currBar + 1
		end
	else
		local maxSize = maxHealth * cap
		local chunkSize = frame.healthBar:GetHeight() / maxHealth
		local currHeight = health
		bars[currBar]:ClearAllPoints()
		bars[currBar]:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, health/maxHealth*frame.healthBar:GetHeight())
		if preHeal > 0 then
			bars[currBar]:Show()
			if (health + preHeal) > maxSize then
				bars[currBar]:SetHeight((maxSize - health) * chunkSize)
				currHeight = maxSize
			else
				bars[currBar]:SetHeight(preHeal * chunkSize)
				currHeight = currHeight + preHeal
			end
			bars[currBar]:SetVertexColor(LunaUF.db.profile.colors.incheal.r, LunaUF.db.profile.colors.incheal.g, LunaUF.db.profile.colors.incheal.b, LunaUF.db.profile.units[frame.unitType].incHeal.alpha)
			currBar = currBar + 1
		end
		if ownHeal > 0 then
			bars[currBar]:Show()
			if currHeight == maxSize then
				bars[currBar]:SetHeight(1)
			elseif (currHeight + ownHeal) > maxSize then
				bars[currBar]:SetHeight((maxSize - currHeight) * chunkSize)
				currHeight = maxSize
			else
				bars[currBar]:SetHeight(ownHeal * chunkSize)
				currHeight = currHeight + ownHeal
			end
			bars[currBar]:SetVertexColor(LunaUF.db.profile.colors.incownheal.r, LunaUF.db.profile.colors.incownheal.g, LunaUF.db.profile.colors.incownheal.b, LunaUF.db.profile.units[frame.unitType].incHeal.alpha)
			currBar = currBar + 1
		end
		if afterHeal > 0 then
			bars[currBar]:Show()
			if currHeight == maxSize then
				bars[currBar]:SetHeight(1)
			elseif (currHeight + afterHeal) > maxSize then
				bars[currBar]:SetHeight((maxSize - currHeight) * chunkSize)
				currHeight = maxSize
			else
				bars[currBar]:SetHeight(afterHeal * chunkSize)
				currHeight = currHeight + afterHeal
			end
			bars[currBar]:SetVertexColor(LunaUF.db.profile.colors.incheal.r, LunaUF.db.profile.colors.incheal.g, LunaUF.db.profile.colors.incheal.b, LunaUF.db.profile.units[frame.unitType].incHeal.alpha)
			currBar = currBar + 1
		end
		if hotHeal > 0 then
			bars[currBar]:Show()
			if currHeight == maxSize then
				bars[currBar]:SetHeight(1)
			elseif (currHeight + hotHeal) > maxSize then
				bars[currBar]:SetHeight((maxSize - currHeight) * chunkSize)
				currHeight = maxSize
			else
				bars[currBar]:SetHeight(hotHeal * chunkSize)
				currHeight = currHeight + hotHeal
			end
			bars[currBar]:SetVertexColor(LunaUF.db.profile.colors.inchots.r, LunaUF.db.profile.colors.inchots.g, LunaUF.db.profile.colors.inchots.b, LunaUF.db.profile.units[frame.unitType].incHeal.alpha)
			currBar = currBar + 1
		end
	end
	-- Hide left over bars
	for i=currBar, 4 do
		bars[currBar]:Hide()
	end
end

function IncHeal:Update(frame)
	local timeframe, flags = GetTime() + LunaUF.db.profile.inchealTime, LunaUF.db.profile.disablehots and HealComm.CASTED_HEALS or HealComm.ALL_HEALS
	
	frame.healValues.mod = HealComm:GetHealModifier(frame.unitGUID) or 1
	frame.healValues.totalHeal = HealComm:GetHealAmount(frame.unitGUID, flags, timeframe) or 0
	frame.healValues.preHeal = 0
	frame.healValues.ownHeal = HealComm:GetHealAmount(frame.unitGUID, HealComm.DIRECT_HEALS, timeframe, UnitGUID("player")) or 0
	if LunaUF.db.profile.disablehots then
		frame.healValues.Hots = 0
	else
		frame.healValues.Hots = HealComm:GetHealAmount(frame.unitGUID, bit.bor(HealComm.HOT_HEALS, HealComm.CHANNEL_HEALS), timeframe) or 0
	end
	frame.healValues.numHeals = HealComm:GetNumHeals(frame.unitGUID)
	
	-- We can only scout up to 2 direct heals that would land before ours but thats good enough for most cases
	local healTime, healFrom, healAmount = HealComm:GetNextHealAmount(frame.unitGUID, HealComm.CASTED_HEALS, timeframe)
	if healFrom and healFrom ~= UnitGUID("player") and frame.healValues.ownHeal > 0 then
		frame.healValues.preHeal = healAmount
		healTime, healFrom, healAmount = HealComm:GetNextHealAmount(frame.unitGUID, HealComm.CASTED_HEALS, timeframe, healFrom)
		if healFrom and healFrom ~= UnitGUID("player") then
			frame.healValues.preHeal = frame.healValues.preHeal + healAmount
		end
	end
	
	frame.healValues.afterHeal = frame.healValues.totalHeal - frame.healValues.Hots - frame.healValues.ownHeal - frame.healValues.preHeal
	
	if( not frame.visibility.incHeal or not frame.visibility.healthBar ) then return end
	self:PositionBar(frame)
end

function IncHeal:UpdateMod(frame)
	frame.healValues.mod = HealComm:GetHealModifier(frame.unitGUID) or 1
	
	if( not frame.visibility.incHeal or not frame.visibility.healthBar ) then return end
	self:PositionBar(frame)
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

function IncHeal:UpdateModifier(guid)
	for frame in pairs(frames) do
		if( guid == frame.unitGUID ) and (UnitPlayerOrPetInParty(frame.unit) or UnitPlayerOrPetInRaid(frame.unit) or UnitIsUnit("player",frame.unit) or UnitIsUnit("pet",frame.unit)) then
			self:UpdateMod(frame)
			break
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