LunaUnitFrames = CreateFrame("Frame")
LunaUnitFrames.version = 1070
LunaUnitFrames.frames = {}
LunaUnitFrames.proximity = ProximityLib:GetInstance("1")
LunaUnitFrames:RegisterEvent("ADDON_LOADED")
LunaUnitFrames:RegisterEvent("PARTY_MEMBERS_CHANGED")
LunaUnitFrames:RegisterEvent("RAID_ROSTER_UPDATE")
LunaUnitFrames:RegisterEvent("PLAYER_ENTERING_WORLD")
LunaUnitFrames:RegisterEvent("CHAT_MSG_ADDON")
local playername = UnitName("player")

local validUnits = {
					["target"] = true,
					["targettarget"] = true,
					["targettargettarget"] = true
				}

CLASS_ICON_TCOORDS = {
    ["WARRIOR"]     = {0.0234375, 0.2265625, 0.0234375, 0.2265625},
    ["MAGE"]        = {0.2734375, 0.4765625, 0.0234375, 0.2265625},
    ["ROGUE"]       = {0.5234375, 0.7265625, 0.0234375, 0.2265625},
    ["DRUID"]       = {0.7734375, 0.97265625, 0.0234375, 0.2265625},
    ["HUNTER"]      = {0.0234375, 0.2265625, 0.2734375, 0.4765625},
    ["SHAMAN"]      = {0.2734375, 0.4765625, 0.2734375, 0.4765625},
    ["PRIEST"]      = {0.5234375, 0.7265625, 0.2734375, 0.4765625},
    ["WARLOCK"]     = {0.7734375, 0.97265625, 0.2734375, 0.4765625},
    ["PALADIN"]     = {0.0234375, 0.2265625, 0.5234375, 0.7265625}
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

function LunaUnitFrames:GetHealthColor(unit)
	local percHp = UnitHealth(unit)/UnitHealthMax(unit)
	return {0.2+((0.7)*(1-percHp)),0.9*percHp,0.2*percHp}
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
	local func = loadstring(LunaOptions.clickcast[playername][modifier][button])
	if LunaOptions.clickcast[playername][modifier][button] == "menu" then
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
	elseif LunaOptions.clickcast[playername][modifier][button] == "target" or SpellIsTargeting() then
		if (SpellIsTargeting()) then
			SpellTargetUnit(this.unit)
		elseif (CursorHasItem()) then
			DropItemOnUnit(this.unit)
		else
			TargetUnit(this.unit)
		end
		return
	elseif UnitIsUnit("target", this.unit) then
		if func then
			func()
		else
			CastSpellByName(LunaOptions.clickcast[playername][modifier][button])
		end
	else
		TargetUnit(this.unit)
		if func then
			func()
		else
			CastSpellByName(LunaOptions.clickcast[playername][modifier][button])
		end
		TargetLastTarget()
	end
end

function LunaUnitFrames:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "LunaUnitFrames" then
		-- Compatibility Code (to be removed several versions later)
		if not LunaOptions.version or LunaOptions.version < LunaUnitFrames.version then
			LunaOptions.version = LunaUnitFrames.version
		end
		
		if table.getn(LunaOptions.frames["LunaPlayerFrame"].bars) < 4 then
			LunaOptions.frames["LunaPlayerFrame"].bars[4] = {"Druidbar", 0}
		end
		if table.getn(LunaOptions.frames["LunaPlayerFrame"].bars) < 5 then
			LunaOptions.frames["LunaPlayerFrame"].bars[5] = {"Totembar", 0}
		end
		local playerName = UnitName("player")
		if not LunaOptions.clickcast[playerName] then
			LunaOptions.clickcast[playerName] = {
									{"target","menu","","",""},
									{"","","","",""},
									{"","","","",""},
									{"","","","",""}
									}
		end
		if not LunaOptions.frames["LunaPartyTargetFrames"] then
			LunaOptions.frames["LunaPartyTargetFrames"] = {position = {x = 0, y = 0}, size = {x = 110, y = 20}, scale = 1, enabled = 1, bars = {{"Healthbar", 6}, {"Powerbar", 4}}}
		end
		if not LunaOptions.frames["LunaRaidFrames"]["positions"][9] then
			LunaOptions.frames["LunaRaidFrames"]["positions"][9] = {}
			LunaOptions.frames["LunaRaidFrames"]["positions"][9].x = 400
			LunaOptions.frames["LunaRaidFrames"]["positions"][9].y = -400
		end
		if not LunaOptions.textscale then
			LunaOptions.textscale = 0.45
		end
		if not LunaOptions.defaultTags then
			LunaOptions.defaultTags = {
				["Healthbar"] = {
					[1] = "[name]",
					[2] = "[smarthealth]"
				},
				["Powerbar"] = {
					[1] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
					[2] = "[pp]/[maxpp]"
				},
				["Castbar"] = {
					[1] = "[spellname]",
					[2] = "[casttime]"
				},
				["Combo Bar"] = {
					[1] = "",
					[2] = ""
				},
				["Druidbar"] = {
					[1] = "[druidform]",
					[2] = "[druid:pp]/[druid:maxpp]"
				},
				["Totembar"] = {
					[1] = "",
					[2] = ""
				}
			}
		end
		if not LunaOptions.defaultTags["Combo Bar"] then
			LunaOptions.defaultTags["Combo Bar"] = {
											[1] = "",
											[2] = ""
											}
		end
		if not LunaOptions.defaultTags["Portrait"] then
			LunaOptions.defaultTags["Portrait"] = {
												[1] = "",
												[2] = ""
											}
		end
		if not LunaOptions.ClassColors then
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
		end
		if type(LunaOptions.frames["LunaPartyPetFrames"].position) == "table" then
			LunaOptions.frames["LunaPartyPetFrames"].position = "RIGHT"
			LunaOptions.frames["LunaPartyTargetFrames"].position = "RIGHT"
		end
		if not LunaOptions.frames["LunaRaidFrames"].grpmode then
			LunaOptions.frames["LunaRaidFrames"].grpmode = "GROUP"
		end
		if not LunaOptions.frames["LunaRaidFrames"].growthdir then
			LunaOptions.frames["LunaRaidFrames"].growthdir = "UP"
		end
		if not LunaOptions.frames["LunaRaidFrames"].toptext then
			LunaOptions.frames["LunaRaidFrames"].toptext = "[name]"
			LunaOptions.frames["LunaRaidFrames"].bottomtext = "[healerhealth]"
		end
		
		if not LunaOptions.frames["LunaRaidFrames"].maxDebuffs then
			LunaOptions.frames["LunaRaidFrames"].maxDebuffs = 3
		end
		
		if not LunaOptions.Raidbuff then
			LunaOptions.Raidbuff = ""
		end
		
		if not LunaOptions.Raidbuff2 then
			LunaOptions.Raidbuff2 = ""
		end
		
		if not LunaOptions.Raidbuff3 then
			LunaOptions.Raidbuff3 = ""
		end
		
		if not LunaOptions.BarTexture then
			LunaOptions.BarTexture = 1
		end
		
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
		LunaUnitFrames:CreateRepBar()
		LunaUnitFrames:CreateXPBar()
		LunaUnitFrames:UpdateBarTextures()
		LunaOptionsModule:CreateMenu()
		if LunaOptions.BlizzBuffs then
			BuffFrame:Hide()
		end
	elseif event == "RAID_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" or event == "PARTY_MEMBERS_CHANGED" then
		LunaUnitFrames:UpdateRaidRoster()
		if event == "PLAYER_ENTERING_WORLD" then
			SendAddonMessage("LUF", LunaUnitFrames.version, "GUILD")
		else
			SendAddonMessage("LUF", LunaUnitFrames.version, "RAID")
		end
	elseif event == "CHAT_MSG_ADDON" and arg1 == "LUF" and arg4 ~= UnitName("player") then
		if tonumber(arg2) > tonumber(LunaOptions.version) then
			LunaOptions.version = tonumber(arg2)
		end
		if LunaOptions.version > LunaUnitFrames.version then
			LunaOptionsFrame.version:SetTextColor(1,0,0)
			LunaOptionsFrame.version:SetText("V."..LunaUnitFrames.version.."(Outdated)")
		end
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
	if LunaOptions.mouseover and UnitExists("mouseover") then
		if UnitIsUnit("target", "mouseover") then
			if func then
				func()
			else
				CastSpellByName(msg)
			end
			return
		else
			TargetUnit("mouseover")
			if func then
				func()
			else
				CastSpellByName(msg)
			end
			TargetLastTarget()
			return
		end
	end
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