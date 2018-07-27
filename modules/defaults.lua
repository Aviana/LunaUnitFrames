local L = LunaUF.L

LunaUF.defaultFont = "Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\"..L["DEFAULT_FONT"]..".ttf"

StaticPopupDialogs["RESET_LUNA_PROFILE"] = {
	text = L["Do you really want to reset to default for your current profile?"],
	button1 = L["OK"],
	button2 = L["Cancel"],
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

StaticPopupDialogs["DELETE_LUNA_PROFILE"] = {
	text = L["Do you really want to delete your current profile?"],
	button1 = L["OK"],
	button2 = L["Cancel"],
	OnAccept = function()
		local profile = UIDropDownMenu_GetSelectedValue(LunaOptionsFrame.pages[14].ProfileSelect)
		UIDropDownMenu_SetSelectedValue(LunaOptionsFrame.pages[14].ProfileSelect, "Default")
		UIDropDownMenu_SetText("Default", LunaOptionsFrame.pages[14].ProfileSelect)
		LunaUF:SetProfile("Default")
		LunaDB.profiles[profile] = nil
		LunaOptionsFrame.pages[14].delete:Disable()
		LunaUF:SystemMessage(LunaUF.L["The profile has been deleted and the default profile has been selected."])
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["RESET_LUNA_COLORS"] = {
	text = L["Do you really want to reset all colors?"],
	button1 = L["OK"],
	button2 = L["Cancel"],
	OnAccept = function()
		LunaUF.db.profile.classColors	= LunaUF:deepcopy(LunaUF.defaults.profile.classColors)
		LunaUF.db.profile.healthColors	= LunaUF:deepcopy(LunaUF.defaults.profile.healthColors)
		LunaUF.db.profile.powerColors	= LunaUF:deepcopy(LunaUF.defaults.profile.powerColors)
		LunaUF.db.profile.castColors	= LunaUF:deepcopy(LunaUF.defaults.profile.castColors)
		LunaUF.db.profile.xpColors		= LunaUF:deepcopy(LunaUF.defaults.profile.xpColors)
		LunaUF:OnProfileEnable()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

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
		showOptions = false,
		font = L["DEFAULT_FONT"],
		texture = "Luna",
		stretchtex = true,
		auraborderType = "dark",
		tooltips = true,
		tooltipCombat = false,
		bars = { alpha = 1, backgroundAlpha = 0.20 },
		bgcolor = {r = 0, g = 0, b = 0},
		bgalpha = 1,
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
			enemyCivilian = {r = 1, g = 0.90, b = 0.90},
			hostile = {r = 0.90, g = 0.0, b = 0.0},
			friendly = {r = 0.20, g = 0.90, b = 0.20},
			neutral = {r = 0.93, g = 0.93, b = 0.0},
			offline = {r = 0.50, g = 0.50, b = 0.50}
		},
		powerColors = {
			MANAUSAGE = {r = 0.50, g = 0.70, b = 1.00},
			MANA = {r = 0.30, g = 0.50, b = 0.85},
			RAGE = {r = 0.90, g = 0.20, b = 0.30},
			FOCUS = {r = 1.0, g = 0.50, b = 0.25},
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
			mouseDownClicks = false,
			bindings = {
				[L["LeftButton"]] = L["target"],
				[L["RightButton"]] = L["menu"],
			},

		},
		units = {
			player = {
				enabled = true,
				healthBar = { enabled = true, classGradient = false, colorType = "class", reactionType="npc", size = 6, invert = false, vertical = false },
				powerBar = { enabled = true, size = 4, invert = false, manaUsage = false },
				totemBar = { enabled = true, size = 2, hide=true },
				druidBar = { enabled = true, size = 2 },
				reckStacks = { enabled = true, size = 1, growth = "RIGHT", hide = true },
				emptyBar = { enabled = false, size = 3 },
				portrait = { enabled = true, type = "3D", side = "left", size = 6 },
				auras = {
					enabled = false,
					buffs = false,
					debuffs = false,
					buffsize = 18,
					debuffsize = 18,
					enlargedbuffsize = 6,
					enlargeddebuffsize = 6,
					buffpos = "BOTTOM",
					debuffpos = "BOTTOM",
					bordercolor = false,
					weaponbuffs = true,
					timertextenabled = true,
					timertextbigsize = 18,
					timertextsmallsize = 12,
					timerspinenabled = true,
					padding = 2,
					emphasizeAuras = {
						buffs = {
						},
						debuffs = {
						},
					},
				},
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false, alpha = 0.6 },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1, speedyFade = false },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[name]",
							["right"] = "[smarthealth]",
						},
						powerBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[pp]/[maxpp]",
						},
						druidBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["center"] = "[druid:pp]/[druid:maxpp]",
						},
						castBar = {
							size = 10,
						},
						emptyBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
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
						pvprank = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 8, x = 0, y = 0 },
						ready = { enabled = true, anchorPoint = "LEFT", size = 24, x = 20, y = 0 },
						status = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 20, y = -2 },
						rezz = { enabled = true, anchorPoint = "LEFT", size = 20, x = 20, y = 0 },
					},
				},
				borders = {
					enabled = false,
					mode = "dispel",
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
				healthBar = {enabled = true, classGradient = false, colorType = "none", reactionType = "happiness", size = 6 },
				powerBar = { enabled = true, size = 4 },
				emptyBar = { enabled = false, size = 3 },
				portrait = { enabled = true, type = "3D", side = "left", size = 6 },
				auras = {
					enabled = true,
					buffs = false,
					debuffs = false,
					buffsize = 18,
					debuffsize = 18,
					enlargedbuffsize = 6,
					enlargeddebuffsize = 6,
					buffpos = "BOTTOM",
					debuffpos = "BOTTOM",
					bordercolor = false,
					padding = 2,
					emphasizeAuras = {
						buffs = {
						},
						debuffs = {
						},
					},
				},
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false, alpha = 0.6 },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1, speedyFade = false },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[name]",
							["right"] = "[ssmarthealth]",
						},
						powerBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[spp]/[smaxpp]",
						},
						castBar = {
							size = 8,
						},
						emptyBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
						},
					},
				},
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				incheal = { enabled = false, cap = 0.2 },
				indicators = {
					enabled = true,
					icons = {
						happiness = {enabled = true, anchorPoint = "BOTTOMRIGHT", size = 14, x = 0, y = 0},
						status = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 20, y = -2 },
					},
				},
				borders = {
					enabled = false,
					mode = "dispel",
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
			pettarget = {
				enabled = false,
				healthBar = { enabled = true, classGradient = false, colorType = "class", reactionType="npc", size = 6 },
				powerBar = { enabled = true, size = 4 },
				emptyBar = { enabled = false, size = 3 },
				portrait = { enabled = false, type = "3D", side = "left", size = 6 },
				auras = {
					enabled = true,
					buffs = false,
					debuffs = false,
					buffsize = 18,
					debuffsize = 18,
					enlargedbuffsize = 6,
					enlargeddebuffsize = 6,
					buffpos = "BOTTOM",
					debuffpos = "BOTTOM",
					bordercolor = false,
					padding = 2,
					emphasizeAuras = {
						buffs = {
						},
						debuffs = {
						},
					},
				},
				highlight = { enabled = false, ontarget = false, ondebuff = true, onmouse = false, alpha = 0.6 },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1, speedyFade = false },
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[abbrev:name]",
							["right"] = "[ssmarthealth]",
						},
						powerBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[spp]/[smaxpp]",
						},
						castBar = {
							size = 10,
						},
						emptyBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
						},
					},
				},
				incheal = { enabled = false, cap = 0.2 },
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						class = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 0, y = 0 },
						elite = { enabled = false, anchorPoint = "LEFT", size = 74, x = 14, y = 0 },
						pvp = { enabled = false, anchorPoint = "TOPRIGHT", size = 30, x = 5, y = -25 },
						pvprank = { enabled = false, anchorPoint = "BOTTOMLEFT", size = 8, x = 0, y = 0 },
						status = { enabled = false, anchorPoint = "BOTTOMLEFT", size = 16, x = 20, y = -2 },
					},
				},
				borders = {
					enabled = false,
					mode = "dispel",
				},
				castBar = { enabled = true, size = 3, hide = true },
				scale = 1,
				position = {
					x = 190,
					y = -50,
				},
				size = {
					x = 100,
					y = 30,
				},
			},
			target = {
				enabled = true,
				healthBar = { enabled = true, classGradient = false, colorType = "class", reactionType="npc", size = 6 },
				powerBar = { enabled = true, size = 4 },
				comboPoints = { enabled = true, size = 1, growth = "LEFT", hide = true },
				emptyBar = { enabled = false, size = 3 },
				portrait = { enabled = true, type = "3D", side = "right", size = 6 },
				auras = {
					enabled = true,
					buffs = true,
					debuffs = true,
					buffsize = 18,
					debuffsize = 18,
					enlargedbuffsize = 6,
					enlargeddebuffsize = 6,
					buffpos = "BOTTOM",
					debuffpos = "BOTTOM",
					bordercolor = false,
					padding = 2,
					emphasizeAuras = {
						buffs = {
						},
						debuffs = {
						},
					},
				},
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false, alpha = 0.6 },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1, speedyFade = false },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[name]",
							["right"] = "[perhp]%[br][ssmarthealth]",
						},
						powerBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[spp]/[smaxpp]",
						},
						castBar = {
							size = 10,
						},
						emptyBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
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
						elite = { enabled = false, kos = false, anchorPoint = "RIGHT", size = 74, x = -14, y = 0 },
						class = { enabled = true, anchorPoint = "BOTTOMRIGHT", size = 16, x = 0, y = 0 },
						masterLoot = { enabled = true, anchorPoint = "TOPRIGHT", size = 12, x = -16, y = 0 },
						leader = { enabled = true, anchorPoint = "TOPRIGHT", size = 14, x = -2, y = 0 },
						pvp = { enabled = true, anchorPoint = "TOPLEFT", size = 30, x = 5, y = -25 },
						pvprank = { enabled = true, anchorPoint = "BOTTOMRIGHT", size = 8, x = 0, y = 0 },
						status = { enabled = true, anchorPoint = "BOTTOMRIGHT", size = 16, x = -20, y = -2 },
						rezz = { enabled = true, anchorPoint = "RIGHT", size = 20, x = -20, y = 0 },
					},
				},
				borders = {
					enabled = false,
					mode = "dispel",
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
				healthBar = { enabled = true, classGradient = false, colorType = "class", reactionType="npc", size = 6 },
				powerBar = { enabled = true, size = 4 },
				emptyBar = { enabled = false, size = 3 },
				portrait = { enabled = true, type = "3D", side = "left", size = 6 },
				auras = {
					enabled = true,
					buffs = false,
					debuffs = false,
					buffsize = 18,
					debuffsize = 18,
					enlargedbuffsize = 6,
					enlargeddebuffsize = 6,
					buffpos = "BOTTOM",
					debuffpos = "BOTTOM",
					bordercolor = false,
					padding = 2,
					emphasizeAuras = {
						buffs = {
						},
						debuffs = {
						},
					},
				},
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false, alpha = 0.6 },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1, speedyFade = false },
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[name]",
							["right"] = "[ssmarthealth]",
						},
						powerBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[spp]/[smaxpp]",
						},
						castBar = {
							size = 10,
						},
						emptyBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
						},
					},
				},
				incheal = { enabled = false, cap = 0.2 },
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						class = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 0, y = 0 },
						elite = { enabled = false, anchorPoint = "LEFT", size = 74, x = 14, y = 0 },
						masterLoot = { enabled = true, anchorPoint = "TOPLEFT", size = 12, x = 16, y = 0 },
						leader = { enabled = true, anchorPoint = "TOPLEFT", size = 14, x = 2, y = 0 },
						pvp = { enabled = true, anchorPoint = "TOPRIGHT", size = 30, x = 5, y = -25 },
						pvprank = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 8, x = 0, y = 0 },
						status = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 20, y = -2 },
						rezz = { enabled = false, anchorPoint = "LEFT", size = 20, x = 20, y = 0 },
					},
				},
				borders = {
					enabled = false,
					mode = "dispel",
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
				healthBar = { enabled = true, classGradient = false, colorType = "class", reactionType="npc", size = 6 },
				powerBar = { enabled = true, size = 4 },
				emptyBar = { enabled = false, size = 3 },
				portrait = { enabled = true, type = "3D", side = "left", size = 6 },
				auras = {
					enabled = true,
					buffs = false,
					debuffs = false,
					buffsize = 18,
					debuffsize = 18,
					enlargedbuffsize = 6,
					enlargeddebuffsize = 6,
					buffpos = "BOTTOM",
					debuffpos = "BOTTOM",
					bordercolor = false,
					padding = 2,
					emphasizeAuras = {
						buffs = {
						},
						debuffs = {
						},
					},
				},
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false, alpha = 0.6 },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1, speedyFade = false },
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[name]",
							["right"] = "[ssmarthealth]",
						},
						powerBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[spp]/[smaxpp]",
						},
						castBar = {
							size = 10,
						},
						emptyBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
						},
					},
				},
				incheal = { enabled = false, cap = 0.2 },
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						class = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 0, y = 0 },
						elite = { enabled = false, anchorPoint = "LEFT", size = 74, x = 14, y = 0 },
						masterLoot = { enabled = true, anchorPoint = "TOPLEFT", size = 12, x = 16, y = 0 },
						leader = { enabled = true, anchorPoint = "TOPLEFT", size = 14, x = 2, y = 0 },
						pvp = { enabled = true, anchorPoint = "TOPRIGHT", size = 30, x = 5, y = -25 },
						pvprank = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 8, x = 0, y = 0 },
						status = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 20, y = -2 },
						rezz = { enabled = false, anchorPoint = "LEFT", size = 20, x = 20, y = 0 },
					},
				},
				borders = {
					enabled = false,
					mode = "dispel",
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
				healthBar = { enabled = true, classGradient = false, colorType = "class", reactionType="npc", size = 6 },
				powerBar = { enabled = true, size = 4 },
				emptyBar = { enabled = false, size = 3 },
				portrait = { enabled = true, type = "3D", side = "left", size = 6 },
				auras = {
					enabled = true,
					buffs = false,
					debuffs = false,
					buffsize = 18,
					debuffsize = 18,
					enlargedbuffsize = 6,
					enlargeddebuffsize = 6,
					buffpos = "BOTTOM",
					debuffpos = "BOTTOM",
					bordercolor = false,
					padding = 2,
					emphasizeAuras = {
						buffs = {
						},
						debuffs = {
						},
					},
				},
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false, alpha = 0.6 },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1, speedyFade = false },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[name]",
							["right"] = "[smarthealth]",
						},
						powerBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[levelcolor][level][shortclassification] [classcolor][smartclass]",
							["right"] = "[pp]/[maxpp]",
						},
						castBar = {
							size = 10,
						},
						emptyBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
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
						pvprank = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 8, x = 0, y = 0 },
						ready = { enabled = true, anchorPoint = "LEFT", size = 24, x = 20, y = 0 },
						status = { enabled = true, anchorPoint = "BOTTOMLEFT", size = 16, x = 20, y = -2 },
						rezz = { enabled = true, anchorPoint = "LEFT", size = 20, x = 20, y = 0 },
					},
				},
				borders = {
					enabled = false,
					mode = "dispel",
				},
				castBar = { enabled = true, size = 3, hide = true },
				squares = {
					enabled = false,
				},
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
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
					},
				},
				borders = {
					enabled = false,
					mode = "dispel",
				},
				portrait = { enabled = false, type = "3D", side = "left", size = 6 },
				healthBar = { enabled = true, classGradient = false, colorType = "class", reactionType="npc", size = 6, },
				powerBar = { enabled = false, size = 4 },
				emptyBar = { enabled = false, size = 3 },
				castBar = { enabled = false, size = 3, hide = true },
				incheal = { enabled = false, cap = 0.2 },
				auras = {
					enabled = true,
					buffs = false,
					debuffs = false,
					buffsize = 18,
					debuffsize = 18,
					enlargedbuffsize = 6,
					enlargeddebuffsize = 6,
					buffpos = "BOTTOM",
					debuffpos = "BOTTOM",
					bordercolor = false,
					padding = 2,
					emphasizeAuras = {
						buffs = {
						},
						debuffs = {
						},
					},
				},
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false, alpha = 0.6 },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1, speedyFade = false },
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[name]",
							["right"] = "[ssmarthealth]",
						},
						powerBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "",
							["right"] = "",
						},
						castBar = {
							size = 10,
						},
						emptyBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
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
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = true, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						rezz = { enabled = false, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						pvprank = { enabled = false, anchorPoint = "BOTTOMLEFT", size = 8, x = 0, y = 0 },
					},
				},
				borders = {
					enabled = false,
					mode = "dispel",
				},
				portrait = { enabled = false, type = "3D", side = "left", size = 6 },
				healthBar = { enabled = true, classGradient = false, colorType = "class", reactionType="npc", size = 6 },
				powerBar = { enabled = false, size = 4 },
				castBar = { enabled = false, size = 3, hide = true },
				emptyBar = { enabled = false, size = 3 },
				incheal = { enabled = false, cap = 0.2 },
				auras = {
					enabled = true,
					buffs = false,
					debuffs = false,
					buffsize = 18,
					debuffsize = 18,
					enlargedbuffsize = 6,
					enlargeddebuffsize = 6,
					buffpos = "BOTTOM",
					debuffpos = "BOTTOM",
					bordercolor = false,
					padding = 2,
					emphasizeAuras = {
						buffs = {
						},
						debuffs = {
						},
					},
				},
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false, alpha = 0.6 },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1, speedyFade = false },
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "[name]",
							["right"] = "[ssmarthealth]",
						},
						powerBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["left"] = "",
							["right"] = "",
						},
						castBar = {
							size = 10,
						},
						emptyBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
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
				healthBar = { enabled = true, classGradient = false, colorType = "class", reactionType="npc", size = 10, vertical = true },
				powerBar = { enabled = true, vertical = true, size = 1 },
				emptyBar = { enabled = false, size = 3 },
				portrait = { enabled = false, type = "3D", side = "left", size = 6 },
				auras = {
					enabled = false,
					buffs = false,
					debuffs = false,
					buffsize = 18,
					debuffsize = 18,
					enlargedbuffsize = 6,
					enlargeddebuffsize = 6,
					buffpos = "BOTTOM",
					debuffpos = "BOTTOM",
					bordercolor = false,
					padding = 2,
					emphasizeAuras = {
						buffs = {
						},
						debuffs = {
						},
					},
				},
				highlight = { enabled = true, ontarget = false, ondebuff = true, onmouse = false, alpha = 0.6 },
				fader = { enabled = false, inactiveAlpha = 0.2, combatAlpha = 1, speedyFade = false },
				tags = {
					enabled = true,
					bartags = {
						healthBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["center"] = "[name][br][healerhealth]",
						},
						powerBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
							["center"] = "",
						},
						castBar = {
							size = 8,
						},
						emptyBar = {
							size = 10,
							leftsize = 100,
							rightsize = 100,
							middlesize = 100,
						},
					},
				},
				range = { enabled = true, alpha = 0.5 },
				healththreshold = {	enabled = false,	threshold = 0.8, inRangeAboveAlpha = 0.8, outOfRangeBelowAlpha = 0.4, inRangeBelowAlpha = 1	},
				combatText = { enabled = false, xoffset = 0, yoffset = 0, size = 2 },
				incheal = { enabled = true, cap = 0 },
				indicators = {
					enabled = true,
					icons = {
						raidTarget = { enabled = false, anchorPoint = "CENTER", size = 20, x = 0, y = 0 },
						class = { enabled = false, anchorPoint = "BOTTOMLEFT", size = 12, x = 3, y = 3 },
						masterLoot = { enabled = false, anchorPoint = "TOPLEFT", size = 12, x = 1, y = -14 },
						leader = { enabled = false, anchorPoint = "TOPLEFT", size = 14, x = 2, y = -3 },
						pvp = { enabled = false, anchorPoint = "RIGHT", size = 22, x = 4, y = -2 },
						pvprank = { enabled = false, anchorPoint = "BOTTOMRIGHT", size = 8, x = 0, y = 1 },
						status = { enabled = false, anchorPoint = "BOTTOM", size = 16, x = 0, y = 1 },
						ready = { enabled = false, anchorPoint = "LEFT", size = 24, x = 35, y = 0 },
						rezz = { enabled = true, anchorPoint = "TOPRIGHT", size = 20, x = -8, y = -9 },
					},
				},
				borders = {
					enabled = false,
					mode = "dispel",
				},
				castBar = { enabled = false, size = 3, hide = true },
				squares = {
					enabled = true,
					outersize = 10,
					innersize = 20,
					enabledebuffs = true,
					dispellabledebuffs = false,
					owndispdebuffs = false,
					aggro = true,
					aggrocolor = {r=1,g=0,b=0},
					hottracker = true,
					buffcolors = false,
					debuffcolors = false,
					invertfirstbuff = false,
					invertsecondbuff = false,
					invertthirdbuff = false,
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
