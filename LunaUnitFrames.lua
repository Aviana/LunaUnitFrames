LunaUnitFrames = CreateFrame("Frame")
LunaUnitFrames.frames = {}
LunaUnitFrames.proximity = ProximityLib:GetInstance("1")
LunaUnitFrames:RegisterEvent("ADDON_LOADED")
LunaUnitFrames:RegisterEvent("PARTY_MEMBERS_CHANGED")
LunaUnitFrames:RegisterEvent("RAID_ROSTER_UPDATE")
LunaUnitFrames:RegisterEvent("PLAYER_ENTERING_WORLD")

local validUnits = {
					["target"] = true,
					["targettarget"] = true,
					["targettargettarget"] = true
				}

function LunaUnitFrames:GetHealthString(unit)
	local result
	local Health, maxHealth
	if MobHealth3 and validUnits[unit] then
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
	
function Luna_OnClick()
	local button, modifier
	if arg1 == "LeftButton" then
		button = 1
	elseif arg1 == "RightButton" then
		button = 2
	elseif arg1 == "MiddleButton" then
		button = 3
	elseif arg1 == "Button4" then
		button = 4
	else
		button = 5
	end
	if IsShiftKeyDown() then
		modifier = 2
	elseif IsAltKeyDown() then
		modifier = 3
	elseif IsControlKeyDown() then
		modifier = 4
	else
		modifier = 1
	end
	local func = loadstring(LunaOptions.clickcast[modifier][button])
	if LunaOptions.clickcast[modifier][button] == "target" then
		if (SpellIsTargeting()) then
			SpellTargetUnit(this.unit)
		elseif (CursorHasItem()) then
			DropItemOnUnit(this.unit)
		else
			TargetUnit(this.unit)
		end
		return
	elseif LunaOptions.clickcast[modifier][button] == "menu" then
		if (SpellIsTargeting()) then
			SpellStopTargeting()
			return;
		else
			ToggleDropDownMenu(1, nil, this.dropdown, "cursor", 0, 0)
			if UnitIsUnit("player", this.unit) then
				if UnitIsPartyLeader("player") then
					UIDropDownMenu_AddButton({text = "Reset Instances", func = ResetInstances, notCheckable = 1}, 1)
				end
			end
		end
	elseif UnitIsUnit("target", this.unit) then
		if func then
			func()
		else
			CastSpellByName(LunaOptions.clickcast[modifier][button])
		end
	else
		TargetUnit(this.unit)
		if func then
			func()
		else
			CastSpellByName(LunaOptions.clickcast[modifier][button])
		end
		TargetLastTarget()
	end
end

function LunaUnitFrames:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "LunaUnitFrames" then
		-- Compatibility Code (to be removed several versions later)
		if table.getn(LunaOptions.frames["LunaPlayerFrame"].bars) < 4 then
			LunaOptions.frames["LunaPlayerFrame"].bars[4] = {"Druidbar", 0}
		end
		if table.getn(LunaOptions.frames["LunaPlayerFrame"].bars) < 5 then
			LunaOptions.frames["LunaPlayerFrame"].bars[5] = {"Totembar", 0}
		end
		if not LunaOptions.clickcast[4][5] then
			LunaOptions.clickcast = {
									{"target","menu","","",""},
									{"","","","",""},
									{"","","","",""},
									{"","","","",""}
									}
		end
		if not LunaOptions.frames["LunaPartyTargetFrames"] then
			LunaOptions.frames["LunaPartyTargetFrames"] = {position = {x = 0, y = 0}, size = {x = 110, y = 20}, scale = 1, enabled = 1, bars = {{"Healthbar", 6}, {"Powerbar", 4}}}
		end
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
		LunaUnitFrames:CreatePartyTargetFrames()
		LunaUnitFrames:CreatePartyPetFrames()
		LunaUnitFrames:CreateRaidFrames()
		LunaUnitFrames:CreateXPBar()
		LunaOptionsModule:CreateMenu()
		if LunaOptions.BlizzBuffs then
			BuffFrame:Hide()
		end
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
	local func = loadstring(msg)
	if GetMouseFocus().unit then
		if UnitIsUnit("target", GetMouseFocus().unit) then
			if func then
				func()
			else
				CastSpellByName(msg)
			end
		else
			TargetUnit(GetMouseFocus().unit)
			if func then
				func()
			else
				CastSpellByName(msg)
			end
			TargetLastTarget()
		end
	else 
		if func then
			func()
		else
			CastSpellByName(msg)
		end
	end
end