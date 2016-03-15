local Range = {}
LunaUF:RegisterModule(Range, "range", LunaUF.L["Range"])
local proximity = ProximityLib:GetInstance("1")

local function OnUpdate()
	Range:FullUpdate(this:GetParent())
end

function Range:OnEnable(frame)
	if not frame.range then
		frame.range = CreateFrame("Frame", nil, frame)
	end
	frame.range:SetScript("OnUpdate", OnUpdate)
end

function Range:OnDisable(frame)
	if frame.range then
		frame.range:SetScript("OnUpdate", nil)
	end
end

function Range:FullUpdate(frame)
	if frame.DisableRangeAlpha then return end
	local range,lastseen = proximity:GetUnitRange(frame.unit)
	if range and ((GetTime()-lastseen) < 3 ) then
		frame:SetAlpha(1)
	else
		frame:SetAlpha(LunaUF.db.profile.units[frame.unitGroup].range.alpha)
	end
end