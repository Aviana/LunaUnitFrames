local Highlight = {}

local canCure = LunaUF.Units.canCure
LunaUF:RegisterModule(Highlight, "highlight", LunaUF.L["Highlight"])

local function OnEnter(frame)
	if( LunaUF.db.profile.units[frame.unitType].highlight.mouseover ) then
		frame.highlight.hasMouseover = true
		Highlight:Update(frame)
	end
end

local function OnLeave(frame)
	if( LunaUF.db.profile.units[frame.unitType].highlight.mouseover ) then
		frame.highlight.hasMouseover = nil
		Highlight:Update(frame)
	end
end

function Highlight:OnEnable(frame)
	if( not frame.highlight ) then
		frame.highlight = CreateFrame("Frame", nil, frame)
		frame.highlight:SetFrameLevel(frame.topFrameLevel)
		frame.highlight:SetAllPoints(frame)
		
		frame.highlight.texture = frame.highlight:CreateTexture(nil, "OVERLAY")
		frame.highlight.texture:SetBlendMode("ADD")
		frame.highlight.texture:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\highlight")
		frame.highlight.texture:SetPoint("CENTER", frame, "CENTER")
		frame.highlight.texture:SetHorizTile(false)
		frame.highlight.texture:SetAllPoints(frame)
		frame.highlight:Hide()
	end
	
	frame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", self, "UpdateThreat")
	frame:RegisterUpdateFunc(self, "UpdateThreat")
	
	if( frame.unitType ~= "target" ) then
		frame:RegisterNormalEvent("PLAYER_TARGET_CHANGED", self, "UpdateAttention")
		frame:RegisterUpdateFunc(self, "UpdateAttention")
	end

	frame:RegisterUnitEvent("UNIT_AURA", self, "UpdateAura")
	frame:RegisterUpdateFunc(self, "UpdateAura")

	frame.highlight.OnEnter = OnEnter
	frame.highlight.OnLeave = OnLeave

end

function Highlight:OnLayoutApplied(frame)
	if( frame.visibility.highlight ) then
--		self:OnDisable(frame)
--		self:OnEnable(frame)
	end
end

function Highlight:OnDisable(frame)
	frame:UnregisterAll(self)
	
	frame.highlight.hasDebuff = nil
	frame.highlight.hasThreat = nil
	frame.highlight.hasAttention = nil
	frame.highlight.hasMouseover = nil

	frame.highlight:Hide()

	frame.highlight.OnEnter = nil
	frame.highlight.OnLeave = nil

end

function Highlight:Update(frame)
	local color
	if( frame.highlight.hasDebuff ) then
		color = DebuffTypeColor[frame.highlight.hasDebuff] or DebuffTypeColor[""]
	elseif( frame.highlight.hasThreat ) then
		color = LunaUF.db.profile.colors.hostile
	elseif( frame.highlight.hasAttention ) then
		color = LunaUF.db.profile.colors.target
	elseif( frame.highlight.hasMouseover ) then
		color = LunaUF.db.profile.colors.mouseover
	end

	if( color ) then
		frame.highlight.texture:SetVertexColor(color.r, color.g, color.b, 1)
		frame.highlight:Show()
	else
		frame.highlight:Hide()
	end
end

function Highlight:UpdateThreat(frame)
	frame.highlight.hasThreat = LunaUF.db.profile.units[frame.unitType].highlight.aggro and (UnitThreatSituation(frame.unit) or 0) > 1
	self:Update(frame)
end

function Highlight:UpdateAttention(frame)
	frame.highlight.hasAttention = LunaUF.db.profile.units[frame.unitType].highlight.target and UnitIsUnit(frame.unit, "target") or nil
	self:Update(frame)
end

function Highlight:UpdateAura(frame)
	frame.highlight.hasDebuff = nil
	local showOwn = LunaUF.db.profile.units[frame.unitType].highlight.debuff == 2
	local showAll = LunaUF.db.profile.units[frame.unitType].highlight.debuff == 3
	if( UnitIsFriend(frame.unit, "player") and LunaUF.db.profile.units[frame.unitType].highlight.debuff ~= 1 ) then
		for id=1, 32 do
			local name, _, _, auraType = UnitDebuff(frame.unit, id)
			if( not name ) then break end
			
			if( showOwn and canCure[auraType] and UnitCanAssist("player", frame.unit) or (showAll and auraType) ) then
				frame.highlight.hasDebuff = auraType
				break
			end
		end
	end

	self:Update(frame)
end
