local Highlight = {}
local goldColor, mouseColor = {r = 0.75, g = 0.75, b = 0.35}, {r = 0.75, g = 0.75, b = 0.50}

local canCure = LunaUF.Units.canCure
LunaUF:RegisterModule(Highlight, "highlight", LunaUF.L["Highlight"])

local vex = LibStub("LibVexation-1.0", true)

local function HighlightCallback(aggro, GUID, ...)
	for _,frame in pairs(LunaUF.Units.unitFrames) do
		if frame.unitGUID and frame.unitGUID == GUID then
			Highlight:UpdateThreat(frame)
		end
	end
end
vex:RegisterCallback(HighlightCallback)

local function OnEnter(frame)
	if( LunaUF.db.profile.units[frame.unitType].highlight.mouseover ) then
		frame.highlight.hasMouseover = true
		Highlight:Update(frame)
	end
		
	frame.highlight.OnEnter(frame)
end

local function OnLeave(frame)
	if( LunaUF.db.profile.units[frame.unitType].highlight.mouseover ) then
		frame.highlight.hasMouseover = nil
		Highlight:Update(frame)
	end
		
	frame.highlight.OnLeave(frame)
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
		frame.highlight:Hide()
	end
	
	if( LunaUF.db.profile.units[frame.unitType].highlight.aggro ) then
		frame:RegisterUpdateFunc(self, "UpdateThreat")
	end
	
	if( LunaUF.db.profile.units[frame.unitType].highlight.target and frame.unitType ~= "target" ) then
		frame:RegisterNormalEvent("PLAYER_TARGET_CHANGED", self, "UpdateAttention")
		frame:RegisterUpdateFunc(self, "UpdateAttention")
	end

	if( LunaUF.db.profile.units[frame.unitType].highlight.debuff ~= false ) then
		frame:RegisterUnitEvent("UNIT_AURA", self, "UpdateAura")
		frame:RegisterUpdateFunc(self, "UpdateAura")
	end

	if( LunaUF.db.profile.units[frame.unitType].highlight.mouseover and not frame.highlight.OnEnter ) then
		frame.highlight.OnEnter = frame.OnEnter
		frame.highlight.OnLeave = frame.OnLeave
		
		frame.OnEnter = OnEnter
		frame.OnLeave = OnLeave
	end

	if( LunaUF.db.profile.units[frame.unitType].highlight.rareMob or LunaUF.db.profile.units[frame.unitType].highlight.eliteMob ) then
		frame:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", self, "UpdateClassification")
		frame:RegisterUpdateFunc(self, "UpdateClassification")
	end
end

function Highlight:OnLayoutApplied(frame)
	if( frame.visibility.highlight ) then
		self:OnDisable(frame)
		self:OnEnable(frame)
		frame.highlight.texture:SetHeight(frame:GetHeight()-10)
		frame.highlight.texture:SetWidth(frame:GetWidth())
	end
end

function Highlight:OnDisable(frame)
	frame:UnregisterAll(self)
	
	frame.highlight.hasDebuff = nil
	frame.highlight.hasThreat = nil
	frame.highlight.hasAttention = nil
	frame.highlight.hasMouseover = nil

	frame.highlight:Hide()

	if( frame.highlight.OnEnter ) then
		frame.OnEnter = frame.highlight.OnEnter
		frame.OnLeave = frame.highlight.OnLeave

		frame.highlight.OnEnter = nil
		frame.highlight.OnLeave = nil
	end
end

function Highlight:Update(frame)
	local color
	if( frame.highlight.hasDebuff ) then
		color = DebuffTypeColor[frame.highlight.hasDebuff] or DebuffTypeColor[""]
	elseif( frame.highlight.hasThreat ) then
		color = LunaUF.db.profile.colors.hostile
	elseif( frame.highlight.hasAttention ) then
		color = goldColor
	elseif( frame.highlight.hasMouseover ) then
		color = mouseColor
	end

	if( color ) then
		frame.highlight.texture:SetVertexColor(color.r, color.g, color.b, 1)
		frame.highlight:Show()
	else
		frame.highlight:Hide()
	end
end

function Highlight:UpdateThreat(frame)
	frame.highlight.hasThreat = LunaUF.db.profile.units[frame.unitType].highlight.aggro and vex:GetUnitAggroByUnitGUID(frame.unitGUID)
	self:Update(frame)
end

function Highlight:UpdateAttention(frame)
	frame.highlight.hasAttention = UnitIsUnit(frame.unit, "target") or nil
	self:Update(frame)
end

function Highlight:UpdateClassification(frame)
	frame.highlight.hasClassification = UnitClassification(frame.unit)
	self:Update(frame)
end

function Highlight:UpdateAura(frame)
	frame.highlight.hasDebuff = nil
	local showAll = LunaUF.db.profile.units[frame.unitType].highlight.debuff == true
	if( UnitIsFriend(frame.unit, "player") ) then
		local id = 0
		while( true ) do
			id = id + 1
			local name, _, _, auraType = UnitDebuff(frame.unit, id)
			if( not name ) then break end
			
			if( canCure[auraType] or (showAll and auraType) ) then
				frame.highlight.hasDebuff = auraType
				break
			end
		end
	end

	self:Update(frame)
end
