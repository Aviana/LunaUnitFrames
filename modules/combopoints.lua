local Combo = {}
LunaUF:RegisterModule(Combo, "comboPoints", LunaUF.L["Combo points"], true)

local SML = LibStub:GetLibrary("LibSharedMedia-3.0")

local function createBlocks(pointsFrame)
	local pointsConfig = pointsFrame.cpConfig

	-- Position bars, the 5 accounts for borders
	local blockWidth = (pointsFrame:GetWidth() - 4) / 5
	local texPath = LunaUF.Layout:LoadMedia(SML.MediaType.STATUSBAR, LunaUF.db.profile.units.target.comboPoints.statusbar)
	local color = LunaUF.db.profile.colors["COMBOPOINTS"]
	for id=1, 5 do
		pointsFrame.blocks[id] = pointsFrame.blocks[id] or pointsFrame:CreateTexture(nil, "OVERLAY")
		local texture = pointsFrame.blocks[id]
		texture:SetVertexColor(color.r, color.g, color.b, color.a)
		texture:SetHorizTile(false)
		texture:SetHeight(pointsFrame:GetHeight())
		texture:SetWidth(blockWidth)
		texture:ClearAllPoints()
		texture:SetTexture(texPath)
		
		if not texture.background and pointsConfig.background then
			texture.background = pointsFrame:CreateTexture(nil, "BORDER")
			texture.background:SetAllPoints(texture)
			texture.background:SetHorizTile(false)
			texture.background:SetVertexColor(color.r, color.g, color.b, 0.20)
			texture.background:SetTexture(texPath)
		end

		if texture.background then
			texture.background:SetShown(pointsConfig.background)
		end

		if( pointsConfig.growth == "LEFT" ) then
			if( id > 1 ) then
				texture:SetPoint("TOPRIGHT", pointsFrame.blocks[id - 1], "TOPLEFT", -1, 0)
			else
				texture:SetPoint("TOPRIGHT", pointsFrame, "TOPRIGHT", 0, 0)
			end
		else
			if( id > 1 ) then
				texture:SetPoint("TOPLEFT", pointsFrame.blocks[id - 1], "TOPRIGHT", 1, 0)
			else
				texture:SetPoint("TOPLEFT", pointsFrame, "TOPLEFT", 0, 0)
			end
		end
	end
end

function Combo:OnEnable(frame)
	if frame.unitType ~= "target" then return end
	frame.comboPoints = frame.comboPoints or CreateFrame("Frame", nil, frame)
	frame.comboPoints.cpConfig = LunaUF.db.profile.units[frame.unitType].comboPoints

	frame.comboPoints.blocks = frame.comboPoints.blocks or {}

	createBlocks(frame.comboPoints)

	frame:RegisterNormalEvent("UNIT_POWER_FREQUENT", self, "Update", "player")
	

	frame:RegisterUpdateFunc(self, "Update")
end

function Combo:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Combo:Update(frame)
	local points = GetComboPoints("player", "target")

	LunaUF.Layout:SetBarVisibility(frame, "comboPoints", not LunaUF.db.profile.units[frame.unitType].comboPoints.autoHide or (points and points > 0))
	
	for id, block in pairs(frame.comboPoints.blocks) do
		if( id <= points ) then
			block:Show()
		else
			block:Hide()
		end
	end
end

function Combo:OnLayoutApplied(frame)
	local pointsFrame = frame.comboPoints
	if( not pointsFrame ) then return end

	pointsFrame:SetFrameLevel(frame.topFrameLevel + 1)

	if( not frame.visibility.comboPoints ) then return end

	createBlocks(pointsFrame)
end

function Combo:OnLayoutWidgets(frame)
	local comboPoints = frame.comboPoints
	if( not frame.visibility.comboPoints or not comboPoints.blocks) then return end

	local height = comboPoints:GetHeight()
	for _, block in pairs(comboPoints.blocks) do
		block:SetHeight(height)
	end
end