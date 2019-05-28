local ReckStacks = {}
LunaUF:RegisterModule(ReckStacks, "reckStacks", LunaUF.L["Reckoning Stacks"], true)
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")
local currStacks = 0
local talentRank = 0

function ReckStacks:OnEnable(frame)
	if (select(2, UnitClass("player")) ~= "PALADIN") or frame.unitType ~= "player" then return end
	frame.reckStacks = frame.reckStacks or CreateFrame("Frame", nil, frame)
	frame.reckStacks.blocks = frame.reckStacks.blocks or {}

	local config = LunaUF.db.profile.units[frame.unitType].reckStacks
	local texPath = LunaUF.Layout:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar)
	local color = LunaUF.db.profile.colors["COMBOPOINTS"]
	for id=1, 4 do
		frame.reckStacks.blocks[id] = frame.reckStacks.blocks[id] or frame.reckStacks:CreateTexture(nil, "OVERLAY")
		local texture = frame.reckStacks.blocks[id]
		texture:SetTexture(texPath)
		texture:SetVertexColor(color.r, color.g, color.b, color.a)
		texture:SetHorizTile(false)
		
		if not texture.background and config.background then
			texture.background = frame.reckStacks:CreateTexture(nil, "BORDER")
			texture.background:SetAllPoints(texture)
			texture.background:SetHorizTile(false)
			texture.background:SetVertexColor(color.r, color.g, color.b, config.backgroundAlpha)
			texture.background:SetTexture(texPath)
		end

		if texture.background then
			texture.background:SetShown(config.background)
		end
	end
	


	frame:RegisterNormalEvent("CHARACTER_POINTS_CHANGED", self, "CheckTalents")
	frame:RegisterNormalEvent("SPELLS_CHANGED", self, "CheckTalents")

	frame:RegisterUpdateFunc(self, "Update")
	self:CheckTalents(frame)
end

function ReckStacks:OnDisable(frame)
	frame:UnregisterAll(self)
end

function ReckStacks:OnLayoutApplied(frame)
	local reckStacks = frame.reckStacks
	if not reckStacks then return end
	if( not frame.visibility.reckStacks ) then return end
	
	for id=1, 4 do
		local texture = reckStacks.blocks[id]
		texture:ClearAllPoints()
		if( LunaUF.db.profile.units[frame.unitType].reckStacks.growth == "LEFT" ) then
			if( id > 1 ) then
				texture:SetPoint("TOPRIGHT", reckStacks.blocks[id - 1], "TOPLEFT", -1, 0)
			else
				texture:SetPoint("TOPRIGHT", reckStacks, "TOPRIGHT", 0, 0)
			end
		else
			if( id > 1 ) then
				texture:SetPoint("TOPLEFT", reckStacks.blocks[id - 1], "TOPRIGHT", 1, 0)
			else
				texture:SetPoint("TOPLEFT", reckStacks, "TOPLEFT", 0, 0)
			end
		end
	end
end

function ReckStacks:OnLayoutWidgets(frame)
	local reckStacks = frame.reckStacks
	if not reckStacks then return end

	local blockWidth = (reckStacks:GetWidth() - 3) / 4
	for id=1, 4 do
		local texture = reckStacks.blocks[id]
		texture:SetHeight(reckStacks:GetHeight())
		texture:SetWidth(blockWidth)
	end
end

function ReckStacks:CheckTalents(frame)
	
	-- Crazy Check here :D
	reckoningRank = select(5, GetTalentInfo(2,13)) or 0
	redoubtRank = select(5, GetTalentInfo(2,2)) or 0
	
	if reckoningRank == 5 and redoubtRank >= 1 then
		frame:RegisterNormalEvent("COMBAT_LOG_EVENT_UNFILTERED", self, "OnCombatlog")
	else
		frame:UnregisterSingleEvent("COMBAT_LOG_EVENT_UNFILTERED", self)
	end
end

function ReckStacks:OnCombatlog(frame, event)
	local _, type, _, sourceGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
	if type == "SWING_DAMAGE" and sourceGUID == UnitGUID("player") then
		if currStacks > 0 then
			currStacks = 0
			self:Update(frame)
		else
			return
		end
	elseif (type == "SPELL_AURA_APPLIED" or type == "SPELL_AURA_REFRESH") and GetSpellInfo(20128) == select(13, CombatLogGetCurrentEventInfo()) and destGUID == UnitGUID("player") and currStacks < 4 then
		currStacks = currStacks + 1
		self:Update(frame)
	end
end

function ReckStacks:Update(frame)
	LunaUF.Layout:SetBarVisibility(frame, "reckStacks", LunaUF.db.profile.units[frame.unitType].reckStacks.showAlways or currStacks > 0)

	for id,block in ipairs(frame.reckStacks.blocks) do
		if id <= currStacks then
			block:Show()
		else
			block:Hide()
		end
	end
end