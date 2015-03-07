LunaUnitFrames = CreateFrame("Frame")
LunaUnitFrames.frames = {}
LunaUnitFrames.proximity = ProximityLib:GetInstance("1")
LunaUnitFrames:RegisterEvent("ADDON_LOADED")
LunaUnitFrames:RegisterEvent("PARTY_MEMBERS_CHANGED")
LunaUnitFrames:RegisterEvent("RAID_ROSTER_UPDATE")
LunaUnitFrames:RegisterEvent("PLAYER_ENTERING_WORLD")

function LunaUnitFrames:GetHealthString(unit)
	local result
	local Health, maxHealth
	if MobHealth3 and (unit == "target" or unit == "targettarget" or unit == "targettargettarget") then
		Health, maxHealth = MobHealth3:GetUnitHealth(unit)
	else
		Health = UnitHealth(unit)
		maxHealth = UnitHealthMax(unit)
	end
	if LunaOptions.HealerModeHealth and UnitIsFriend("player",unit) then
		result = (maxHealth - Health)*(-1)
		if result == 0 then
			result = ""
		end
	else
		result = Health.."/"..maxHealth
	end
	if LunaOptions.Percentages then
		result = math.floor(((Health / maxHealth) * 100)+0.5).."%\n"..result
	end
	return result
end

function LunaUnitFrames:GetPowerString(unit)
	local result
	if UnitManaMax(unit) == 0 then
		return ""
	end
	if (UnitIsDead(unit) or UnitIsGhost(unit)) then
		result = "0/"..UnitManaMax(unit)
	else
		result = UnitMana(unit).."/"..UnitManaMax(unit)
	end
	if LunaOptions.Percentages then
		result = math.floor(((UnitMana(unit) / UnitManaMax(unit)) * 100)+0.5).."%\n"..result
	end
	return result
end
	

function LunaUnitFrames:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "LunaUnitFrames" then
		-- Compatibility Code (to be removed several versions later)
		LunaOptions.ClassColors = {	WARRIOR = {0.78, 0.61, 0.43},
						MAGE = {0.41, 0.8, 0.94},
						ROGUE = {1, 0.96, 0.41},
						DRUID = {1, 0.49, 0.04},
						HUNTER = {0.67, 0.83, 0.45},
						SHAMAN = {0.14, 0.35, 1.0},
						PRIEST = {1, 1, 1},
						WARLOCK = {0.58, 0.51, 0.79},
						PALADIN = {0.96, 0.55, 0.73}
						}
		-----------------------------------------------------------
		--Load the Addon here
		ChatFrame1:AddMessage("Luna Unit Frames loaded. Enjoy the ride!")
		LunaUnitFrames:CreatePlayerFrame()
		LunaUnitFrames:CreatePetFrame()
		LunaUnitFrames:CreateTargetFrame()
		LunaUnitFrames:CreateTargetTargetFrame()
		LunaUnitFrames:CreateTargetTargetTargetFrame()
		LunaUnitFrames:CreatePartyFrames()
		LunaUnitFrames:CreatePartyPetFrames()
		LunaUnitFrames:CreateRaidFrames()
		LunaUnitFrames:CreateXPBar()
		LunaOptionsModule:CreateMenu()
	elseif event == "RAID_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" or event == "PARTY_MEMBERS_CHANGED" then
		LunaUnitFrames:UpdateRaidRoster()
	end
end
LunaUnitFrames:SetScript("OnEvent", LunaUnitFrames.OnEvent)

SLASH_LUF1, SLASH_LUF2, SLASH_LUF3 = "/luf", "/luna", "/lunaunitframes"
function SlashCmdList.LUF(msg, editbox)
	LunaOptionsFrame:Show()
end

SLASH_LUFMO1, SLASH_LUFMO2 = "/lunamo", "/lunamouseover"
function SlashCmdList.LUFMO(msg, editbox)
	if GetMouseFocus().unit then
		if UnitIsUnit("target", GetMouseFocus().unit) then
			CastSpellByName(msg)
		else
			TargetUnit(GetMouseFocus().unit)
			CastSpellByName(msg)
			TargetLastTarget()
		end
	else 
		CastSpellByName(msg)
	end
end