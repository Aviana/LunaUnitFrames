local Incheal = {}
LunaUF:RegisterModule(Incheal, "incheal", LunaUF.L["Incheal"])
local HealComm = LunaUF.HealComm
local AceEvent = LunaUF.AceEvent

local function OnHeal()
	for _,frame in pairs(LunaUF.Units.frameList) do
		if frame.incheal and LunaUF.db.profile.units[frame.unitGroup].incheal.enabled then
			Incheal:FullUpdate(frame)
		end
	end
end

function Incheal:OnEnable(frame)
	if not frame.incheal then
		frame.incheal = CreateFrame("Frame", nil, frame)
		frame.incheal.healBar = CreateFrame("StatusBar", nil, frame)
		frame.incheal.healBar:SetMinMaxValues(0,1)
		frame.incheal.healBar:SetValue(1)
	end
	if not AceEvent:IsEventRegistered("HealComm_Healupdate") then
		AceEvent:RegisterEvent("HealComm_Healupdate", OnHeal)
	end
end

function Incheal:OnDisable(frame)
	if frame.incheal then
		frame.incheal:UnregisterEvent("HealComm_Healupdate")
		frame.incheal.healBar:Hide()
	end
end

function Incheal:FullUpdate(frame)
	if not frame.unit then return end
	local healvalue = HealComm:getHeal(UnitName(frame.unit))
	local healBar = frame.incheal.healBar
	local health, maxHealth = UnitHealth(frame.unit), UnitHealthMax(frame.unit)
	if healvalue == 0 then
		healBar:Hide()
		return
	end
	local frameHeight, frameWidth = frame.healthBar:GetHeight(), frame.healthBar:GetWidth()
	local healthHeight = frameHeight * (health / maxHealth)
	local healthWidth = frameWidth * (health / maxHealth)
	healBar:Show()
	healBar:ClearAllPoints()
	if LunaUF.db.profile.units[frame.unitGroup].healthBar.vertical then
		local incHeight = frameHeight * (healvalue / maxHealth)
		if (healthHeight + incHeight) > (frameHeight * (LunaUF.db.profile.units[frame.unitGroup].incheal.cap + 1)) then
			incHeight = (frameHeight * (LunaUF.db.profile.units[frame.unitGroup].incheal.cap + 1)) - healthHeight
		end
		if incHeight == 0 then
			healBar:Hide()
			return
		end
		healBar:SetHeight(incHeight)
		healBar:SetWidth(frameWidth)
		healBar:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT", 0, healthHeight)
	else
		local incWidth = frameWidth * (healvalue / maxHealth)
		if (healthWidth + incWidth) > (frameWidth * (LunaUF.db.profile.units[frame.unitGroup].incheal.cap + 1)) then
			incWidth = (frameWidth * (LunaUF.db.profile.units[frame.unitGroup].incheal.cap + 1)) - healthWidth
		end
		if incWidth == 0 then
			healBar:Hide()
			return
		end
		healBar:SetWidth(incWidth)
		healBar:SetHeight(frameHeight)
		healBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", healthWidth, 0)
	end
end

function Incheal:SetBarTexture(frame,texture)
	frame.incheal.healBar:SetStatusBarTexture(texture)
	frame.incheal.healBar:SetStatusBarColor(LunaUF.db.profile.healthColors.inc.r, LunaUF.db.profile.healthColors.inc.g, LunaUF.db.profile.healthColors.inc.b, 0.75)
end