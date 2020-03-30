local Empty = {}
LunaUF:RegisterModule(Empty, "emptyBar", LunaUF.L["Empty bar"], true)

function Empty:OnEnable(frame)
	frame.emptyBar = frame.emptyBar or LunaUF.Units:CreateBar(frame)
	frame.emptyBar:SetMinMaxValues(0, 1)
end

function Empty:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Empty:OnLayoutApplied(frame)
	if( frame.visibility.emptyBar ) then
		frame:RegisterUnitEvent("UNIT_FACTION", self, "UpdateColor")
		frame:RegisterUpdateFunc(self, "UpdateColor")
	end
end

function Empty:UpdateColor(frame)
	local color
	local reactionType = LunaUF.db.profile.units[frame.unitType].emptyBar.reactionType

	if( ( reactionType == "npc" or reactionType == "both" ) and not UnitPlayerControlled(frame.unit) and UnitIsTapDenied(frame.unit) and UnitCanAttack("player", frame.unit) ) then
		color = LunaUF.db.profile.colors.tapped
	elseif ( reactionType == "player" or reactionType == "both" and UnitIsPlayer(frame.unit) ) or ( ( reactionType == "npc" or reactionType == "both" ) and not UnitIsPlayer(frame.unit) ) or (reactionType == "NPC/hostile player" and not UnitIsFriend(frame.unit, "player") and UnitIsPlayer(frame.unit)) then
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
	elseif( LunaUF.db.profile.units[frame.unitType].emptyBar.class and UnitIsPlayer(frame.unit) ) then
		local class = UnitCreatureFamily(frame.unit) or frame:UnitClassToken()
		color = class and LunaUF.db.profile.colors[class]
	end
	if not color then
		frame.emptyBar:SetValue(0)
		return
	else
		frame.emptyBar:SetValue(1)
	end
	frame:SetBarColor("emptyBar",color.r, color.g, color.b)
end

