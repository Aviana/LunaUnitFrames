local Empty = {}
local fallbackColor
LunaUF:RegisterModule(Empty, "emptyBar", LunaUF.L["Empty bar"], true)

function Empty:OnEnable(frame)
	frame.emptyBar = frame.emptyBar or LunaUF.Units:CreateBar(frame)
	frame.emptyBar:SetMinMaxValues(0, 1)
	frame.emptyBar:SetValue(0)

	fallbackColor = fallbackColor or {r = 0, g = 0, b = 0}
end

function Empty:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Empty:OnLayoutApplied(frame)
	if( frame.visibility.emptyBar ) then
		local color = frame.emptyBar.background.overrideColor or fallbackColor
		frame.emptyBar.background:SetVertexColor(color.r, color.g, color.b, LunaUF.db.profile.units[frame.unitType].emptyBar.alpha)

		if( LunaUF.db.profile.units[frame.unitType].emptyBar.reactionType ~= "none" or LunaUF.db.profile.units[frame.unitType].emptyBar.class ) then
			frame:RegisterUnitEvent("UNIT_FACTION", self, "UpdateColor")
			frame:RegisterUpdateFunc(self, "UpdateColor")
		else
			self:OnDisable(frame)
		end
	end
end

function Empty:UpdateColor(frame)
	local color
	local reactionType = LunaUF.db.profile.units[frame.unitType].emptyBar.reactionType

	if( ( reactionType == "npc" or reactionType == "both" ) and not UnitPlayerControlled(frame.unit) and UnitIsTapDenied(frame.unit) and UnitCanAttack("player", frame.unit) ) then
		color = LunaUF.db.profile.colors.tapped
	elseif( not UnitPlayerOrPetInRaid(frame.unit) and not UnitPlayerOrPetInParty(frame.unit) and ( ( ( reactionType == "player" or reactionType == "both" ) and UnitIsPlayer(frame.unit) and not UnitIsFriend(frame.unit, "player") ) or ( ( reactionType == "npc" or reactionType == "both" ) and not UnitIsPlayer(frame.unit) ) ) ) then
		if( not UnitIsFriend(frame.unit, "player") and UnitPlayerControlled(frame.unit) ) then
			if( UnitCanAttack("player", frame.unit) ) then
				color = LunaUF.db.profile.colors.hostile
			else
				color = LunaUF.db.profile.colors.enemyUnattack
			end
		elseif( UnitReaction(frame.unit, "player") ) then
			local reaction = UnitReaction(frame.unit, "player")
			if( reaction > 4 ) then
				color = LunaUF.db.profile.colors.friendly
			elseif( reaction == 4 ) then
				color = LunaUF.db.profile.colors.neutral
			elseif( reaction < 4 ) then
				color = LunaUF.db.profile.colors.hostile
			end
		end
	elseif( LunaUF.db.profile.units[frame.unitType].emptyBar.class and ( UnitIsPlayer(frame.unit) or UnitCreatureFamily(frame.unit) ) ) then
		local class = UnitCreatureFamily(frame.unit) or frame:UnitClassToken()
		color = class and LunaUF.db.profile.colors[class]
	end
	
	color = color or frame.emptyBar.background.overrideColor or fallbackColor
	frame.emptyBar.background:SetVertexColor(color.r, color.g, color.b, LunaUF.db.profile.units[frame.unitType].emptyBar.alpha)
end

