local Combo = {}
LunaUF:RegisterModule(Combo, "comboPoints", LunaUF.L["Combo points"])
local _,playerclass = UnitClass("player")

local function OnEvent()
	Combo:Update(this:GetParent())
end

function Combo:OnEnable(frame)
	if (playerclass ~= "ROGUE" and playerclass ~= "DRUID") or frame.unitGroup ~= "target" then return end
	if not frame.comboPoints then
		frame.comboPoints = CreateFrame("Frame", nil, frame)
		frame.comboPoints.blocks = {}
		for id=1, MAX_COMBO_POINTS do
			frame.comboPoints.blocks[id] = frame.comboPoints.blocks[id] or frame.comboPoints:CreateTexture(nil, "OVERLAY")
		end
	end
	frame.comboPoints:RegisterEvent("PLAYER_COMBO_POINTS")
	frame.comboPoints:SetScript("OnEvent", OnEvent)
end

function Combo:OnDisable(frame)
	if frame.comboPoints then
		frame.comboPoints:UnregisterAllEvents()
		frame.comboPoints:SetScript("OnEvent", nil)
	end
end

function Combo:Update(frame)
	local points = GetComboPoints()
	if points == 0 and UnitExists("target") then
		if LunaUF.db.profile.units[frame.unitGroup].comboPoints.hide and not frame.comboPoints.hidden then
			frame.comboPoints.hidden = true
			LunaUF.Units:PositionWidgets(frame)
		elseif not LunaUF.db.profile.units[frame.unitGroup].comboPoints.hide and frame.comboPoints.hidden then
			frame.comboPoints.hidden = nil
			LunaUF.Units:PositionWidgets(frame)
		end
	else
		if frame.comboPoints.hidden then
			frame.comboPoints.hidden = false
			LunaUF.Units:PositionWidgets(frame)
		end
	end
	for id,block in ipairs(frame.comboPoints.blocks) do
		if id <= points then
			block:Show()
		else
			block:Hide()
		end
	end
end

function Combo:FullUpdate(frame)
	local blockWidth = (frame.comboPoints:GetWidth() - (MAX_COMBO_POINTS-1)) / MAX_COMBO_POINTS
	for id=1, MAX_COMBO_POINTS do
		local texture = frame.comboPoints.blocks[id]
		texture:SetHeight(frame.comboPoints:GetHeight())
		texture:SetWidth(blockWidth)
		texture:ClearAllPoints()
		if( LunaUF.db.profile.units[frame.unitGroup].comboPoints.growth == "LEFT" ) then
			if( id > 1 ) then
				texture:SetPoint("TOPRIGHT", frame.comboPoints.blocks[id - 1], "TOPLEFT", -1, 0)
			else
				texture:SetPoint("TOPRIGHT", frame.comboPoints, "TOPRIGHT", 0, 0)
			end
		else
			if( id > 1 ) then
				texture:SetPoint("TOPLEFT", frame.comboPoints.blocks[id - 1], "TOPRIGHT", 1, 0)
			else
				texture:SetPoint("TOPLEFT", frame.comboPoints, "TOPLEFT", 0, 0)
			end
		end
	end
	Combo:Update(frame)
end

function Combo:SetBarTexture(frame,texture)
	if frame.comboPoints then
		for _,block in pairs(frame.comboPoints.blocks) do
			block:SetTexture(texture)
			block:SetVertexColor(1, 0.80, 0)
		end
	end
end