local Health = {}
LunaUF:RegisterModule(Health, "healthBar", LunaUF.L["Health bar"], true)

local function getGradientColor(unit)
	local maxHealth = UnitHealthMax(unit)
	local percent = maxHealth > 0 and UnitHealth(unit) / maxHealth or 0
	if( percent >= 1 ) then return LunaUF.db.profile.colors.green.r, LunaUF.db.profile.colors.green.g, LunaUF.db.profile.colors.green.b end
	if( percent == 0 ) then return LunaUF.db.profile.colors.red.r, LunaUF.db.profile.colors.red.g, LunaUF.db.profile.colors.red.b end
	
	local sR, sG, sB, eR, eG, eB = 0, 0, 0, 0, 0, 0
	local modifier, inverseModifier = percent * 2, 0
	if( percent > 0.50 ) then
		sR, sG, sB = LunaUF.db.profile.colors.green.r, LunaUF.db.profile.colors.green.g, LunaUF.db.profile.colors.green.b
		eR, eG, eB = LunaUF.db.profile.colors.yellow.r, LunaUF.db.profile.colors.yellow.g, LunaUF.db.profile.colors.yellow.b

		modifier = modifier - 1
	else
		sR, sG, sB = LunaUF.db.profile.colors.yellow.r, LunaUF.db.profile.colors.yellow.g, LunaUF.db.profile.colors.yellow.b
		eR, eG, eB = LunaUF.db.profile.colors.red.r, LunaUF.db.profile.colors.red.g, LunaUF.db.profile.colors.red.b
	end
	
	inverseModifier = 1 - modifier
	return eR * inverseModifier + sR * modifier, eG * inverseModifier + sG * modifier, eB * inverseModifier + sB * modifier
end

function Health:OnEnable(frame)
	if( not frame.healthBar ) then
		frame.healthBar = LunaUF.Units:CreateBar(frame)
	end

	frame:RegisterUnitEvent("UNIT_HEALTH", self, "Update")
	frame:RegisterUnitEvent("UNIT_MAXHEALTH", self, "Update")
	frame:RegisterUnitEvent("UNIT_CONNECTION", self, "Update")
	frame:RegisterUnitEvent("UNIT_FACTION", self, "UpdateColor")
	frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", self, "Update")
	frame:RegisterUnitEvent("UNIT_TARGETABLE_CHANGED", self, "UpdateColor")

	if( frame.unit == "pet" ) then
		frame:RegisterUnitEvent("UNIT_HAPPINESS", self, "UpdateColor")
	end

--	if ( LunaUF.db.profile.units[frame.unitType].healthBar.colorDispel ) then
--		frame:RegisterUnitEvent("UNIT_AURA", self, "UpdateAura")
--		frame:RegisterUpdateFunc(self, "UpdateAura")
--	end

	frame:RegisterUpdateFunc(self, "UpdateColor")
	frame:RegisterUpdateFunc(self, "Update")
end

function Health:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Health:UpdateColor(frame)
	frame.healthBar.hasReaction = nil
	frame.healthBar.hasPercent = nil
	frame.healthBar.wasOffline = nil
	
	local color
	local unit = frame.unit
	local reactionType = LunaUF.db.profile.units[frame.unitType].healthBar.reactionType
	if( not UnitIsConnected(unit) ) then
		frame.healthBar.wasOffline = true
		frame:SetBarColor("healthBar", LunaUF.db.profile.colors.offline.r, LunaUF.db.profile.colors.offline.g, LunaUF.db.profile.colors.offline.b)
		return
	elseif( LunaUF.db.profile.units[frame.unitType].healthBar.colorDispel and frame.healthBar.hasDebuff ) then
		color = DebuffTypeColor[frame.healthBar.hasDebuff]
--	elseif( LunaUF.db.profile.units[frame.unitType].healthBar.colorAggro and UnitThreatSituation(frame.unit) == 3 ) then
--		frame:SetBarColor("healthBar", LunaUF.db.profile.colors.aggro.r, LunaUF.db.profile.colors.aggro.g, LunaUF.db.profile.colors.aggro.b)
--		return
	elseif( not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) and UnitCanAttack("player", unit) ) then
		color = LunaUF.db.profile.colors.tapped
	elseif( not UnitPlayerOrPetInRaid(unit) and not UnitPlayerOrPetInParty(unit) and ( ( ( reactionType == "player" or reactionType == "both" ) and UnitIsPlayer(unit) and not UnitIsFriend(unit, "player") ) or ( ( reactionType == "npc" or reactionType == "both" )  and not UnitIsPlayer(unit) and not UnitIsUnit("pet", unit) ) ) ) then
		if( not UnitIsFriend(unit, "player") and UnitPlayerControlled(unit) ) then
			if( UnitCanAttack("player", unit) ) then
				color = LunaUF.db.profile.colors.hostile
			else
				color = LunaUF.db.profile.colors.enemyUnattack
			end
		elseif( UnitReaction(unit, "player") ) then
			local reaction = UnitReaction(unit, "player")
			if( reaction > 4 ) then
				color = LunaUF.db.profile.colors.friendly
			elseif( reaction == 4 ) then
				color = LunaUF.db.profile.colors.neutral
			elseif( reaction < 4 ) then
				if( UnitIsCivilian(unit) ) then
					color = LunaUF.db.profile.colors.enemyCivilian
				else
					color = LunaUF.db.profile.colors.hostile
				end
			end
		end
	elseif( LunaUF.db.profile.units[frame.unitType].healthBar.colorType == "class" and UnitIsPlayer(unit) ) then
		local class = frame:UnitClassToken()
		color = class and LunaUF.db.profile.colors[class]
	elseif unit == "pet" and LunaUF.db.profile.units[frame.unitType].healthBar.colorType == "happiness" then
		local happiness = GetPetHappiness()
		if happiness == 3 then
			color = LunaUF.db.profile.colors.friendly
		elseif happiness == 2 then
			color = LunaUF.db.profile.colors.neutral
		elseif happiness == 1 then
			color = LunaUF.db.profile.colors.hostile
		else
			color = LunaUF.db.profile.colors["PET"]
		end
	elseif( LunaUF.db.profile.units[frame.unitType].healthBar.colorType == "static" ) then
		color = LunaUF.db.profile.colors.static
	end
	
	if( color ) then
		frame:SetBarColor("healthBar", color.r, color.g, color.b)
	else
		frame.healthBar.hasPercent = true
		frame:SetBarColor("healthBar", getGradientColor(unit))
	end
end

function Health:Update(frame)
	local isOffline = not UnitIsConnected(frame.unit)
	frame.isDead = UnitIsDeadOrGhost(frame.unit)
	frame.healthBar.currentHealth = UnitHealth(frame.unit)
	frame.healthBar:SetMinMaxValues(0, UnitHealthMax(frame.unit))
	frame.healthBar:SetValue(isOffline and UnitHealthMax(frame.unit) or frame.isDead and 0 or frame.healthBar.currentHealth)
	
	-- Unit is offline, fill bar up + grey it
	if( isOffline ) then
		frame.healthBar.wasOffline = true
		frame.unitIsOnline = nil
		frame:SetBarColor("healthBar", LunaUF.db.profile.colors.offline.r, LunaUF.db.profile.colors.offline.g, LunaUF.db.profile.colors.offline.b)
	-- The unit was offline, but they no longer are so we need to do a forced color update
	elseif( frame.healthBar.wasOffline ) then
		frame.healthBar.wasOffline = nil
		self:UpdateColor(frame)
	-- Color health by percentage
	elseif( frame.healthBar.hasPercent ) then
		frame:SetBarColor("healthBar", getGradientColor(frame.unit))
	end
end