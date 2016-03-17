LunaUF = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "AceHook-2.1","FuBarPlugin-2.0")
LunaUF:RegisterDB("LunaDB")

-- Assets ----------------------------------------------------------------------------------
LunaUF.Version = 2002
LunaUF.BS = AceLibrary("Babble-Spell-2.2")
LunaUF.Banzai = AceLibrary("Banzai-1.0")
LunaUF.HealComm = AceLibrary("HealComm-1.0")
LunaUF.AceEvent = AceLibrary("AceEvent-2.0")
LunaUF.DruidManaLib = AceLibrary("DruidManaLib-1.0")
LunaUF.unitList = {"player", "pet", "target", "targettarget", "targettargettarget", "party", "partytarget", "partypet", "raid"}
LunaUF.ScanTip = CreateFrame("GameTooltip", "LunaScanTip", nil, "GameTooltipTemplate")
LunaUF.ScanTip:SetOwner(WorldFrame, "ANCHOR_NONE")
LunaUF.modules = {}
_, LunaUF.playerRace = UnitRace("player")
local Alliance = {
	["Dwarf"] = true,
	["Human"] = true,
	["Gnome"] = true,
	["NightElf"] = true,
}

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

SLASH_LUFMO1, SLASH_LUFMO2 = "/lunamo", "/lunamouseover"
function SlashCmdList.LUFMO(msg, editbox)
	local func = loadstring(msg)
	if LunaUF.db.profile.mouseover and UnitExists("mouseover") then
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
			LunaUF.Units.pauseUpdates = true
			TargetUnit(GetMouseFocus().unit)
			if func then
				func()
			else
				CastSpellByName(msg)
			end
			TargetLastTarget()
			LunaUF.Units.pauseUpdates = nil
		end
	else 
		if func then
			func()
		else
			CastSpellByName(msg)
		end
	end
end

function lufmo(msg)
	SlashCmdList.LUFMO(msg)
end

StaticPopupDialogs["RESET_LUNA"] = {
	text = "Do you really want to reset to default for your current profile?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		LunaUF:ResetDB("profile")
		--Need To Reset the options Window here if its open
		LunaUF:OnProfileEnable()
		LunaUF:SystemMessage(LunaUF.L["Current profile has been reset."])
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

--------------------------------------------------------------------------------------------

-- Localization Stuff ----------------------------------------------------------------------
LunaUF.L = AceLibrary("AceLocale-2.2"):new("LunaUnitFrames")
local L = LunaUF.L
--------------------------------------------------------------------------------------------

-- FUBAR Stuff -----------------------------------------------------------------------------
LunaUF.name = "FuBar - LunaUnitFrames"
LunaUF.hasNoColor = true
LunaUF.hasIcon = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\icon"
LunaUF.defaultMinimapPosition = 180
LunaUF.independentProfile = true
LunaUF.cannotDetachTooltip = true

function LunaUF:OnClick()
	if IsControlKeyDown() then
		if LunaUF.db.profile.locked then
			LunaUF:SystemMessage(L["LunaUF: Entering config mode."])
			LunaUF.db.profile.locked = false
		else
			LunaUF:SystemMessage(L["LunaUF: Exiting config mode."])
			LunaUF.db.profile.locked = true
		end
		LunaUF:LoadUnits()
	else
		if LunaOptionsFrame:IsShown() then
			LunaOptionsFrame:Hide()
		else
			LunaOptionsFrame:Show()
		end
	end
end
--------------------------------------------------------------------------------------------

-- Default Settings ------------------------------------------------------------------------
LunaUF.defaults = {
	profile = {
		blizzard = {
			castbar = false,
			buffs = true,
			weaponbuffs = true,
			player = false,
			pet = false,
			target = false,
			party = false,
		},
		locked = true,
		font = "Luna",
		texture = "Luna",
		auraborderType = "dark",
		tooltipCombat = false,
		bars = { alpha = 1, backgroundAlpha = 0.20 },
		classColors = {
			HUNTER = {r = 0.67, g = 0.83, b = 0.45},
			WARLOCK = {r = 0.58, g = 0.51, b = 0.79},
			PRIEST = {r = 1.0, g = 1.0, b = 1.0},
			PALADIN = {r = 0.96, g = 0.55, b = 0.73},
			MAGE = {r = 0.41, g = 0.8, b = 0.94},
			ROGUE = {r = 1.0, g = 0.96, b = 0.41},
			DRUID = {r = 1.0, g = 0.49, b = 0.04},
			SHAMAN = {r = 0.14, g = 0.35, b = 1.0},
			WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
			PET = {r = 0.20, g = 0.90, b = 0.20},
		},
		healthColors = {
			tapped = {r = 0.5, g = 0.5, b = 0.5},
			red = {r = 0.90, g = 0.0, b = 0.0},
			green = {r = 0.20, g = 0.90, b = 0.20},
			static = {r = 0.70, g = 0.20, b = 0.90},
			yellow = {r = 0.93, g = 0.93, b = 0.0},
			inc = {r = 0, g = 1, b = 0},
			enemyUnattack = {r = 0.60, g = 0.20, b = 0.20},
			hostile = {r = 0.90, g = 0.0, b = 0.0},
			friendly = {r = 0.20, g = 0.90, b = 0.20},
			neutral = {r = 0.93, g = 0.93, b = 0.0},
			offline = {r = 0.50, g = 0.50, b = 0.50}
		},
		powerColors = {
			MANA = {r = 0.30, g = 0.50, b = 0.85}, 
			RAGE = {r = 0.90, g = 0.20, b = 0.30},
			FOCUS = {r = 1.0, g = 0.85, b = 0}, 
			ENERGY = {r = 1.0, g = 0.85, b = 0.10}, 
			HAPPINESS = {r = 0.50, g = 0.90, b = 0.70},
		},
		castColors = {
			channel = {r = 0.25, g = 0.25, b = 1.0},
			cast = {r = 1.0, g = 0.70, b = 0.30},
		},
		xpColors = {
			normal = {r = 0.58, g = 0.0, b = 0.55},
			rested = {r = 0.0, g = 0.39, b = 0.88},
		},
		magicColors = {
			["Magic"] = {0.2, 0.6, 1},
			["Curse"] = {0.6, 0, 1},
			["Disease"] = {0.6, 0.4, 0},
			["Poison"] = {0, 0.6, 0},
		},
		clickcasting = {
			onlyFrames = true,
			bindings = {
				["LeftButton"] = "target",
				["RightButton"] = "menu",
			},
		
		},
		units = {
			player = {
				enabled = true,
				healthBar = { enabled = true, colorType = "class", reactionType="npc", size = 6, invert = false, vertical = false },
				powerBar = { enabled = true, size = 4, invert = false },
				totemBar = { enabled = true, size = 2, hide=true },
				druidBar = { enabled = true, size = 2 },
				portrait = { enabled = true, type = "3D", side = "left", size = 6 },
				auras = { enabled = false, AurasPerRow = 12, position = "BOTTOM", weaponbuffs = true },
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							["left"] = "[name]",
							["right"] = "[smarthealth]",
						},
						powerBar = {
							size = 10,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[pp]/[maxpp]",
						},
						druidBar = {
							size = 10,
							["center"] = "[druid:pp]/[druid:maxpp]",
						},
						castBar = {
							size = 10,
						},
					},
				},
				combatText = { enabled = true, xoffset = -100, yoffset = 0, size = 2 },
				incheal = { enabled = true, cap = 0.2 },
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						class = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 0, y = 0 },
						masterLoot = { enabled = true, anchorPoint = "TOPLEFT", size = 12, x = 16, y = 0 },
						leader = { enabled = true, anchorPoint = "TOPLEFT", size = 14, x = 2, y = 0 },
						pvp = { enabled = true, anchorPoint = "TOPRIGHT", size = 30, x = 5, y = -25 },
						ready = { enabled = true, anchorPoint = "LEFT", size = 24, x = 20, y = 0 },
						status = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 20, y = -2 },
						rezz = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
					},
				},
				castBar = { enabled = true, size = 3, hide = true },
				xpBar = { enabled = true, size = 2 },
				scale = 1, 
				position = {
					x = 10,
					y = -15,
				},
				size = {
					x = 240,
					y = 40,
				},
			},
			pet = {
				enabled = true,
				healthBar = {enabled = true, colorType = "none", reactionType = "happiness", size = 6 },
				powerBar = { enabled = true, size = 4 },
				portrait = { enabled = true, type = "3D", side = "left", size = 6 },
				auras = { enabled = false, AurasPerRow = 12, position = "BOTTOM" },
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							["left"] = "[name]",
							["right"] = "[smarthealth]",
						},
						powerBar = {
							size = 10,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[pp]/[maxpp]",
						},
						castBar = {
							size = 8,
						},
					},
				},
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				incheal = { enabled = false, cap = 0.2 },
				indicators = {
					enabled = true,
					icons = {
						happiness = {enabled = true, anchorPoint = "BOTTOMRIGHT", size = 14, x = 0, y = 0},
					},
				},
				castBar = { enabled = false, size = 3, hide = true },
				xpBar = { enabled = true, size = 1 },
				scale = 1,
				position = {
					x = 10,
					y = -50,
				},
				size = {
					x = 240,
					y = 30,
				},
			},
			target = {
				enabled = true,
				healthBar = { enabled = true, colorType = "class", reactionType="npc", size = 6 },
				powerBar = { enabled = true, size = 4 },
				comboPoints = { enabled = true, size = 2, growth = "LEFT" },
				portrait = { enabled = true, type = "3D", side = "right", size = 6 },
				auras = { enabled = true, AurasPerRow = 12, position = "BOTTOM"},
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							["left"] = "[name]",
							["right"] = "[smarthealth]",
						},
						powerBar = {
							size = 10,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[pp]/[maxpp]",
						},
						castBar = {
							size = 10,
						},
					},
				},
				range = { enabled = false, alpha = 0.5 },
				combatText = { enabled = true, xoffset = 100, yoffset = 0, size = 2 },
				incheal = { enabled = true, cap = 0.2 },
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						class = { enabled = true, anchorPoint = "BOTTOMRIGHT", size = 16, x = 0, y = 0 },
						masterLoot = { enabled = true, anchorPoint = "TOPRIGHT", size = 12, x = -16, y = 0 },
						leader = { enabled = true, anchorPoint = "TOPRIGHT", size = 14, x = -2, y = 0 },
						pvp = { enabled = true, anchorPoint = "TOPLEFT", size = 30, x = 5, y = -25 },
						status = { enabled = true, anchorPoint = "BOTTOMRIGHT", size = 16, x = -20, y = -2 },
						rezz = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
					},
				},
				castBar = { enabled = true, size = 3, hide = true },
				scale = 1,
				position = {
					x = 190,
					y = -15,
				},
				size = {
					x = 240,
					y = 40,
				},
			},
			targettarget = {
				enabled = true,
				healthBar = { enabled = true, colorType = "class", reactionType="npc", size = 6 },
				powerBar = { enabled = true, size = 4 },
				portrait = { enabled = true, type = "3D", side = "left", size = 6 },
				auras = { enabled = false, AurasPerRow = 8, position = "BOTTOM" },
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1 },
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							["left"] = "[name]",
							["right"] = "[smarthealth]",
						},
						powerBar = {
							size = 10,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[pp]/[maxpp]",
						},
						castBar = {
							size = 10,
						},
					},
				},
				incheal = { enabled = false, cap = 0.2 },
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						class = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 0, y = 0 },
						masterLoot = { enabled = true, anchorPoint = "TOPLEFT", size = 12, x = 16, y = 0 },
						leader = { enabled = true, anchorPoint = "TOPLEFT", size = 14, x = 2, y = 0 },
						pvp = { enabled = true, anchorPoint = "TOPRIGHT", size = 30, x = 5, y = -25 },
						status = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 20, y = -2 },
						rezz = { enabled = false, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
					},
				},
				castBar = { enabled = true, size = 3, hide = true },
				scale = 1,
				position = {
					x = 360,
					y = -15,
				},
				size = {
					x = 150,
					y = 40,
				},
			},
			targettargettarget = {
				enabled = true,
				healthBar = { enabled = true, colorType = "class", reactionType="npc", size = 6 },
				powerBar = { enabled = true, size = 4 },
				portrait = { enabled = true, type = "3D", side = "left", size = 6 },
				auras = { enabled = false, AurasPerRow = 8, position = "BOTTOM" },
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1 },
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							["left"] = "[name]",
							["right"] = "[smarthealth]",
						},
						powerBar = {
							size = 10,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[pp]/[maxpp]",
						},
						castBar = {
							size = 10,
						},
					},
				},
				incheal = { enabled = false, cap = 0.2 },
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						class = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 0, y = 0 },
						masterLoot = { enabled = true, anchorPoint = "TOPLEFT", size = 12, x = 16, y = 0 },
						leader = { enabled = true, anchorPoint = "TOPLEFT", size = 14, x = 2, y = 0 },
						pvp = { enabled = true, anchorPoint = "TOPRIGHT", size = 30, x = 5, y = -25 },
						status = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 20, y = -2 },
						rezz = { enabled = false, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
					},
				},
				castBar = { enabled = true, size = 3, hide = true },
				scale = 1,
				position = {
					x = 470,
					y = -15,
				},
				size = {
					x = 150,
					y = 40,
				},
			},
			party = {
				enabled = true,
				padding = 40,
				sortby = "NAME",
				order = "ASC",
				growth = "DOWN",
				player = false,
				inraid = true,
				healthBar = { enabled = true, colorType = "class", reactionType="npc", size = 6 },
				powerBar = { enabled = true, size = 4 },
				portrait = { enabled = true, type = "3D", side = "left", size = 6 },
				auras = { enabled = true, AurasPerRow = 11, position = "BOTTOM" },
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							["left"] = "[name]",
							["right"] = "[smarthealth]",
						},
						powerBar = {
							size = 10,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[pp]/[maxpp]",
						},
						castBar = {
							size = 10,
						},
					},
				},
				incheal = { enabled = true, cap = 0.2 },
				combatText = { enabled = true, xoffset = 0, yoffset = 0, size = 2 },
				range = { enabled = true, alpha = 0.5 },
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						class = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 0, y = 0 },
						masterLoot = { enabled = true, anchorPoint = "TOPLEFT", size = 12, x = 16, y = 0 },
						leader = { enabled = true, anchorPoint = "TOPLEFT", size = 14, x = 2, y = 0 },
						pvp = { enabled = true, anchorPoint = "TOPRIGHT", size = 30, x = 5, y = -25 },
						ready = { enabled = true, anchorPoint = "LEFT", size = 24, x = 20, y = 0 },
						status = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 20, y = -2 },
						rezz = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
					},
				},
				castBar = { enabled = true, size = 3, hide = true },
				scale = 1,
				position = {
					x = 120,
					y = -180,
				},
				size = {
					x = 200,
					y = 40,
				},
			},
			partypet = {
				enabled = true,
				padding = 60,
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
					},
				},
				portrait = { enabled = false, type = "3D", side = "left", size = 6 },
				healthBar = { enabled = true, colorType = "class", reactionType="npc", size = 6, },
				powerBar = { enabled = false, size = 4 },
				castBar = { enabled = false, size = 3, hide = true },
				incheal = { enabled = false, cap = 0.2 },
				auras = { enabled = false, AurasPerRow = 8, position = "BOTTOM" },
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1 },
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							["left"] = "[name]",
							["right"] = "[smarthealth]",
						},
						powerBar = {
							size = 10,
							["left"] = "",
							["right"] = "",
						},
						castBar = {
							size = 10,
						},
					},
				},
				scale = 1,
				position = {
					x = 280,
					y = -201,
				},
				size = {
					x = 110,
					y = 19,
				},
			},
			partytarget = {
				enabled = false,
				padding = 60,
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						rezz = { enabled = false, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
					},
				},
				portrait = { enabled = false, type = "3D", side = "left", size = 6 },
				healthBar = { enabled = true, colorType = "class", reactionType="npc", size = 6 },
				powerBar = { enabled = false, size = 4 },
				castBar = { enabled = false, size = 3, hide = true },
				incheal = { enabled = false, cap = 0.2 },
				auras = { enabled = false, AurasPerRow = 8, position = "BOTTOM" },
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1 },
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							["left"] = "[name]",
							["right"] = "[smarthealth]",
						},
						powerBar = {
							size = 10,
							["left"] = "",
							["right"] = "",
						},
						castBar = {
							size = 10,
						},
					},
				},
				scale = 1,
				position = {
					x = 280,
					y = -180,
				},
				size = {
					x = 110,
					y = 19,
				},
			},
			raid = {
				padding = 4,
				sortby = "NAME",
				order = "ASC",
				growth = "DOWN",
				mode = "GROUP",
				enabled = true,
				showparty = false,
				showalways = false,
				interlock = false,
				interlockgrowth = "RIGHT",
				petgrp = false,
				healthBar = { enabled = true, colorType = "class", reactionType="npc", size = 10, vertical = true },
				powerBar = { enabled = true, vertical = true, size = 1 },
				portrait = { enabled = false, type = "3D", side = "left", size = 6 },
				auras = { enabled = false, AurasPerRow = 6, position = "RIGHT" },
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							["center"] = "[name][br][healerhealth]",
						},
						powerBar = {
							size = 10,
							["center"] = "",
						},
						castBar = {
							size = 8,
						},
					},
				},
				range = { enabled = true, alpha = 0.5 },
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				incheal = { enabled = true, cap = 0 },
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = false, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						class = { enabled = false, anchorPoint = "BOTTOMLEFT", size = 16, x = 0, y = 0 },
						masterLoot = { enabled = false, anchorPoint = "TOPLEFT", size = 12, x = 16, y = -10 },
						leader = { enabled = false, anchorPoint = "TOPLEFT", size = 14, x = 2, y = -12 },
						pvp = { enabled = false, anchorPoint = "TOPRIGHT", size = 22, x = 11, y = -21 },
						status = { enabled = false, anchorPoint = "BOTTOMLEFT", size = 16, x = 12, y = -2 },
						ready = { enabled = false, anchorPoint = "LEFT", size = 24, x = 35, y = 0 },
						rezz = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
					},
				},
				castBar = { enabled = false, size = 3, hide = true },
				squares = {
					enabled = true,
					outersize = 10,
					innersize = 20,
					enabledebuffs = true,
					dispellabledebuffs = false,
					aggro = true,
					aggrocolor = {r=1,g=0,b=0},
					hottracker = true,
					colors = false,
					buffs = {
						names = {
							[1] = "",
							[2] = "",
							[3] = "",
						},
						colors = {
							[1] = {r=1,g=0,b=0},
							[2] = {r=0,g=1,b=0},
							[3] = {r=0,g=0,b=1},
						},
					},
					debuffs = {
						names = {
							[1] = "",
							[2] = "",
							[3] = "",
						},
						colors = {
							[1] = {r=1,g=0,b=0},
							[2] = {r=0,g=1,b=0},
							[3] = {r=0,g=0,b=1},
						},
					},
				},
				scale = 1,
				[1] = {
					position = {
						x = 300,
						y = -400,
					},
					enabled = true,
				},
				[2] = {
					position = {
						x = 400,
						y = -400,
					},
					enabled = true,
				},
				[3] = {
					position = {
						x = 500,
						y = -400,
					},
					enabled = true,
				},
				[4] = {
					position = {
						x = 600,
						y = -400,
					},
					enabled = true,
				},
				[5] = {
					position = {
						x = 700,
						y = -400,
					},
					enabled = true,
				},
				[6] = {
					position = {
						x = 800,
						y = -400,
					},
					enabled = true,
				},
				[7] = {
					position = {
						x = 900,
						y = -400,
					},
					enabled = true,
				},
				[8] = {
					position = {
						x = 1000,
						y = -400,
					},
					enabled = true,
				},
				[9] = {
					position = {
						x = 1100,
						y = -400,
					},
					enabled = true,
				},
				size = {
					x = 60,
					y = 30,
				},
			},
		},
	},
}
--------------------------------------------------------------------------------------------

--Constant Values --------------------------------------------------------------------------
LunaUF.constants = {
	backdrop = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tile = true,
		tileSize = 16,
		insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5},
	},
	icon = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\icon",
	AnchorPoint = {
	["UP"] = "BOTTOM",
	["DOWN"] = "TOP",
	["RIGHT"] = "LEFT",
	["LEFT"] = "RIGHT",
	},
	RaidClassMapping = {
		[1] = "WARRIOR",
		[2] = "DRUID",
		[3] = Alliance[LunaUF.playerRace] and "PALADIN" or "SHAMAN",
		[4] = "WARLOCK",
		[5] = "PRIEST",
		[6] = "MAGE",
		[7] = "ROGUE",
		[8] = "HUNTER",
		[9] = "PET",
	},
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
	},
	barorder = {
		horizontal = {
			[1] = "portrait",
			[2] = "healthBar",
			[3] = "powerBar",
			[4] = "castBar",
		},
		vertical = {
		},
	},
	specialbarorder = {
		["player"] = {
			horizontal = {
				[1] = "portrait",
				[2] = "healthBar",
				[3] = "powerBar",
				[4] = "castBar",
				[5] = "druidBar",
				[6] = "totemBar",
				[7] = "xpBar",
			},
			vertical = {
			},
		},
		["pet"] = {
			horizontal = {
				[1] = "portrait",
				[2] = "healthBar",
				[3] = "powerBar",
				[4] = "castBar",
				[5] = "xpBar",
			},
			vertical = {
			},
		},
		["target"] = {
			horizontal = {
				[1] = "portrait",
				[2] = "healthBar",
				[3] = "powerBar",
				[4] = "castBar",
				[5] = "comboPoints",
			},
			vertical = {
			},
		},
		["raid"] = {
			horizontal = {
				[1] = "portrait",
				[2] = "castBar",
			},
			vertical = {
				[1] = "healthBar",
				[2] = "powerBar",
			},
		},
	},
}
--------------------------------------------------------------------------------------------

--Upon Loading
function LunaUF:OnInitialize()

	-- Slash Commands ----------------------------------------------------------------------
	LunaUF.cmdtable = {type = "group", handler = LunaUF, args = {
		[L["reset"]] = {
			type = "execute",
			name = L["reset"],
			desc = L["Resets your current settings."],
			func = function ()
					StaticPopup_Show ("RESET_LUNA")
				end,
		},
		[L["config"]] = {
			type = "execute",
			name = L["config"],
			desc = L["Toggle config mode on and off."],
			func = function ()
					if LunaUF.db.profile.locked then
						ChatFrame1:AddMessage(L["LunaUF: Entering Config Mode."])
						LunaUF.db.profile.locked = false
					else
						ChatFrame1:AddMessage(L["LunaUF: Exiting Config Mode."])
						LunaUF.db.profile.locked = true
					end
					LunaUF:LoadUnits()
				end,
		},
		[L["menu"]] = {
			type = "execute",
			name = L["menu"],
			desc = L["Show/hide the options menu."],
			func = function ()
					if LunaOptionsFrame:IsShown() then
						LunaOptionsFrame:Hide()
					else
						LunaOptionsFrame:Show()
					end
				end,
		},
	}}
	LunaUF:RegisterChatCommand({"/luna", "/luf", "/lunauf", "/lunaunitframes"}, LunaUF.cmdtable)
	----------------------------------------------------------------------------------------
	
	self:RegisterDefaults("profile", self.defaults.profile)
	self:InitBarorder()
	self:HideBlizzard()
	self:LoadUnits()
	self:CreateOptionsMenu()
	self:LoadOptions()
	LunaUF:SystemMessage(L["Loaded. The ride never ends!"])
	if not MobHealth3 and MobHealthFrame then
		LunaUF:SystemMessage(L["Mobhealth2/Mobinfo2 found. Please consider MobHealth3 for a better experience."])
	end
end

--System Message Output --------------------------------------------------------------------
function LunaUF:SystemMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF2150C2LunaUnitFrames|cFFFFFFFF: "..msg)
end
--------------------------------------------------------------------------------------------

--On Profile changed------------------------------------------------------------------------
function LunaUF:OnProfileEnable()
	self:InitBarorder()
	self:HideBlizzard()
	self:LoadUnits()
	self:LoadOptions()
end
--------------------------------------------------------------------------------------------

--Register Module --------------------------------------------------------------------------
function LunaUF:RegisterModule(module, key, name, isBar, class)
	self.modules[key] = module

	module.moduleKey = key
	module.moduleHasBar = isBar
	module.moduleName = name
	module.moduleClass = class
	
end
--------------------------------------------------------------------------------------------

--Hiding the Blizzard stuff ----------------------------------------------------------------
function LunaUF:HideBlizzard()
	-- Castbar
	local CastingBarFrame = getglobal("CastingBarFrame")
	if self.db.profile.blizzard.castbar then
		CastingBarFrame:RegisterEvent("SPELLCAST_START")
		CastingBarFrame:RegisterEvent("SPELLCAST_STOP")
		CastingBarFrame:RegisterEvent("SPELLCAST_FAILED")
		CastingBarFrame:RegisterEvent("SPELLCAST_INTERRUPTED")
		CastingBarFrame:RegisterEvent("SPELLCAST_DELAYED")
		CastingBarFrame:RegisterEvent("SPELLCAST_CHANNEL_START")
		CastingBarFrame:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
		CastingBarFrame:RegisterEvent("SPELLCAST_CHANNEL_STOP")
	else
		CastingBarFrame:UnregisterEvent("SPELLCAST_START")
		CastingBarFrame:UnregisterEvent("SPELLCAST_STOP")
		CastingBarFrame:UnregisterEvent("SPELLCAST_FAILED")
		CastingBarFrame:UnregisterEvent("SPELLCAST_INTERRUPTED")
		CastingBarFrame:UnregisterEvent("SPELLCAST_DELAYED")
		CastingBarFrame:UnregisterEvent("SPELLCAST_CHANNEL_START")
		CastingBarFrame:UnregisterEvent("SPELLCAST_CHANNEL_UPDATE")
		CastingBarFrame:UnregisterEvent("SPELLCAST_CHANNEL_STOP")
	end
	--Buffs
	if self.db.profile.blizzard.buffs then
		BuffFrame:Show()
	else
		BuffFrame:Hide()
	end
	--Weapon Enchants
	if self.db.profile.blizzard.weaponbuffs then
		TemporaryEnchantFrame:Show()
	else
		TemporaryEnchantFrame:Hide()
	end
	--Player
	if self.db.profile.blizzard.player then
		PlayerFrame:RegisterEvent("UNIT_LEVEL")
		PlayerFrame:RegisterEvent("UNIT_COMBAT")
		PlayerFrame:RegisterEvent("UNIT_FACTION")
		PlayerFrame:RegisterEvent("UNIT_MAXMANA")
		PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		PlayerFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
		PlayerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
		PlayerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
		PlayerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		PlayerFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
		PlayerFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		PlayerFrame:RegisterEvent("PARTY_LEADER_CHANGED")
		PlayerFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
		PlayerFrame:RegisterEvent("RAID_ROSTER_UPDATE")
		PlayerFrame:RegisterEvent("PLAYTIME_CHANGED")
		PlayerFrame:Show()
--		PlayerFrame_Update()
		UnitFrameHealthBar_Update(PlayerFrame.healthhar, "player")
		UnitFrameManaBar_Update(PlayerFrame.manabar, "player")
	else
		PlayerFrame:UnregisterAllEvents()
		PlayerFrame:Hide()
	end
	--Pet
	if self.db.profile.blizzard.pet then
		PetFrame:RegisterEvent("UNIT_PET");
		PetFrame:RegisterEvent("UNIT_COMBAT");
		PetFrame:RegisterEvent("UNIT_AURA");
		PetFrame:RegisterEvent("PET_ATTACK_START");
		PetFrame:RegisterEvent("PET_ATTACK_STOP");
		PetFrame:RegisterEvent("UNIT_HAPPINESS");
--		PetFrame_Update()
	else
		PetFrame:UnregisterAllEvents()
		PetFrame:Hide()
	end
	--Target
	ClearTarget()
	if self.db.profile.blizzard.target then
		TargetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		TargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		TargetFrame:RegisterEvent("UNIT_HEALTH")
		TargetFrame:RegisterEvent("UNIT_LEVEL")
		TargetFrame:RegisterEvent("UNIT_FACTION")
		TargetFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
		TargetFrame:RegisterEvent("UNIT_AURA")
		TargetFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
		TargetFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		TargetFrame:RegisterEvent("RAID_TARGET_UPDATE")
		ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		ComboFrame:RegisterEvent("PLAYER_COMBO_POINTS")
		ComboPointsFrame_OnEvent()
	else
		TargetFrame:UnregisterAllEvents()
		TargetFrame:Hide()
		ComboFrame:UnregisterAllEvents()
		ComboFrame:Hide()
	end
	--Party
	if self.db.profile.blizzard.party then
		if self.RaidOptionsFrame_UpdatePartyFrames then
			RaidOptionsFrame_UpdatePartyFrames = self.RaidOptionsFrame_UpdatePartyFrames
		end
		for i=1,4 do
			local frame = getglobal("PartyMemberFrame"..i)
			frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
			frame:RegisterEvent("PARTY_LEADER_CHANGED")
			frame:RegisterEvent("PARTY_MEMBER_ENABLE")
			frame:RegisterEvent("PARTY_MEMBER_DISABLE")
			frame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
			frame:RegisterEvent("UNIT_PVP_UPDATE")
			frame:RegisterEvent("UNIT_AURA")
			frame:RegisterEvent("UNIT_PET")
			frame:RegisterEvent("VARIABLES_LOADED")
			frame:RegisterEvent("UNIT_NAME_UPDATE")
			frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
			frame:RegisterEvent("UNIT_DISPLAYPOWER")
		end
		UnitFrame_OnEvent("PARTY_MEMBERS_CHANGED")
		ShowPartyFrame()
	else
		self.RaidOptionsFrame_UpdatePartyFrames = RaidOptionsFrame_UpdatePartyFrames
		RaidOptionsFrame_UpdatePartyFrames = function () end
		for i=1,4 do
			local frame = getglobal("PartyMemberFrame"..i)
			frame:UnregisterAllEvents()
			frame:Hide()
		end
	end
end

--------------------------------------------------------------------------------------------

function LunaUF:InitBarorder()
	for key,unitGroup in pairs(LunaUF.db.profile.units) do
		if not unitGroup.barorder then
			if LunaUF.constants.specialbarorder[key] then
				unitGroup.barorder = deepcopy(LunaUF.constants.specialbarorder[key])
			else
				unitGroup.barorder = deepcopy(LunaUF.constants.barorder)
			end
		end
	end
end

--------------------------------------------------------------------------------------------

function LunaUF:LoadUnits()
	for _, type in pairs(self.unitList) do
		self.Units:InitializeFrame(type)
	end
end
