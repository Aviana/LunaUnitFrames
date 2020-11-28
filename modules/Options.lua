local Addon,LUF = ...

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local SML = SML or LibStub:GetLibrary("LibSharedMedia-3.0")
local ACR = LibStub("AceConfigRegistry-3.0", true)
local L = LUF.L
local resolutionselectvalue,groupselectvalue, profiledb = GetCurrentResolution(), "SOLO", {}

local InfoTags = {
	["numtargeting"] = true,
	["cnumtargeting"] = true,
	["br"] = true,
	["name"] = true,
	["nameafk"] = true,
	["afktime"] = true,
	["afk"] = true,
	["shortname:x"] = true,
	["abbrev:name"] = true,
	["guild"] = true,
	["guildrank"] = true,
	["level"] = true,
	["smartlevel"] = true,
	["class"] = true,
	["smartclass"] = true,
	["rare"] = true,
	["elite"] = true,
	["classification"] = true,
	["shortclassification"] = true,
	["race"] = true,
	["smartrace"] = true,
	["creature"] = true,
	["sex"] = true,
	["druidform"] = true,
	["civilian"] = true,
	["pvp"] = true,
	["rank"] = true,
	["numrank"] = true,
	["faction"] = true,
	["ignore"] = true,
	["server"] = true,
	["status"] = true,
	["happiness"] = true,
	["group"] = true,
	["combat"] = true,
	["loyalty"] = true,
	["buffcount"] = true,
	["range"] = true,
	["castname"] = true,
	["casttime"] = true,
	["xp"] = true,
	["xppet"] = true,
	["percxp"] = true,
	["percxppet"] = true,
	["rep"] = true,
}
local HealthnPowerTags = {
	["namehealerhealth"] = true,
	["healerhealth"] = true,
	["smart:healmishp"] = true,
	["cpoints"] = true,
	["smarthealth"] = true,
	["smarthealthp"] = true,
	["ssmarthealth"] = true,
	["ssmarthealthp"] = true,
	["healhp"] = true,
	["hp"] = true,
	["shp"] = true,
	["sshp"] = true,
	["maxhp"] = true,
	["smaxhp"] = true,
	["missinghp"] = true,
	["healmishp"] = true,
	["perhp"] = true,
	["pp"] = true,
	["spp"] = true,
	["maxpp"] = true,
	["smaxpp"] = true,
	["missingpp"] = true,
	["perpp"] = true,
	["druid:pp"] = true,
	["druid:maxpp"] = true,
	["druid:missingpp"] = true,
	["druid:perpp"] = true,
	["incheal"] = true,
	["numheals"] = true,
	["incownheal"] = true,
	["incpreheal"] = true,
	["incafterheal"] = true,
	["hotheal"] = true,
}
local ColorTags = {
	["combatcolor"] = true,
	["pvpcolor"] = true,
	["reactcolor"] = true,
	["levelcolor"] = true,
	["aggrocolor"] = true,
	["classcolor"] = true,
	["healthcolor"] = true,
	["color:xxxxxx"] = true,
	["nocolor"] = true,
}

local UnitToFrame = {
	["none"] = "UIParent",
	["player"] = "LUFUnitplayer",
	["pet"] = "LUFUnitpet",
	["pettarget"] = "LUFUnitpettarget",
	["pettargettarget"] = "LUFUnitpettargettarget",
	["target"] = "LUFUnittarget",
	["targettarget"] = "LUFUnittargettarget",
	["targettargettarget"] = "LUFUnittargettargettarget",
	["party"] = "LUFHeaderparty",
	["partytarget"] = "LUFHeaderpartytarget",
	["partypet"] = "LUFHeaderpartypet",
	["raid1"] = "LUFHeaderraid1",
	["raid2"] = "LUFHeaderraid2",
	["raid3"] = "LUFHeaderraid3",
	["raid4"] = "LUFHeaderraid4",
	["raid5"] = "LUFHeaderraid5",
	["raid6"] = "LUFHeaderraid6",
	["raid7"] = "LUFHeaderraid7",
	["raid8"] = "LUFHeaderraid8",
	["raidpet"] = "LUFHeaderraidpet",
	["maintank"] = "LUFHeadermaintank",
	["maintanktarget"] = "LUFHeadermaintanktarget",
	["maintanktargettarget"] = "LUFHeadermaintanktargettarget",
	["mainassist"] = "LUFHeadermainassist",
	["mainassisttarget"] = "LUFHeadermainassisttarget",
	["mainassisttargettarget"] = "LUFHeadermainassisttargettarget",
}

function LUF:CreateConfig()

	local function set(info, value)
		local db = LUF.db.profile.units
		for i=1, #info-1 do
			if info[i] ~= "GeneralOptions" then
				db = db[info[i]]
			end
		end
		db[info[#info]] = value
		LUF:Reload(info[1])
	end

	local function get(info)
		local db = LUF.db.profile.units
		for i=1, #info do
			if info[i] ~= "GeneralOptions" then
				db = db[info[i]]
			end
		end
		return db
	end

	local function setHeader(info, value)
		local db = LUF.db.profile.units
		for i=1, #info-1 do
			if info[i] ~= "GeneralOptions" then
				db = db[info[i]]
			end
		end
		db[info[#info]] = value
		
		LUF:SetupHeader(info[1])
	end

	local function getPos(info)
		local db = LUF.db.profile.units
		for i=1, #info do
			if info[i] ~= "GeneralOptions" then
				db = db[info[i]]
			end
		end
		return tostring(db)
	end

	local function setPos(info, value)
		local db = LUF.db.profile.units
		for i=1, #info-1 do
			if info[i] ~= "GeneralOptions" then
				db = db[info[i]]
			end
		end
		db[info[#info]] = value
		
		LUF:PlaceFrame(LUF.frameIndex[info[1]])
	end

	local function nbrValidate(info, value)
		if strmatch(value, "^%-?%d*%.?%d*$") then
			return true
		else
			return L["Not a valid number."]
		end
	end

	local function setGeneral(info, value)
		LUF.db.profile[info[#info]] = value
	end

	local function getGeneral(info)
		return LUF.db.profile[info[#info]]
	end

	local function setEnableUnit(info, value)
		set(info, value)
		local unit = info[#info-1]
		if self.HeaderFrames[unit] then
			LUF:SetupHeader(unit)
		end
		if strmatch(unit, "^party.*$") then
			LUF.stateMonitor:SetAttribute(unit.."Enabled", value)
		end
		LUF:Reload(unit)
		LUF:UpdateMovers()
		if not value then
			if unit == "raid" then
				for unit,tbl in pairs(LUF.db.profile.units) do
					if unit ~= "raid" then
						if strsub(tbl.anchorTo,1,13) == "LUFHeaderraid" then
							tbl.anchorTo = "UIParent"
							LUF:CorrectPosition(_G[UnitToFrame[unit]])
						end
					end
				end
			else
				for unit,tbl in pairs(LUF.db.profile.units) do
					if unit == "raid" then
						for i,opt in pairs(tbl.positions) do
							if opt.anchorTo == UnitToFrame[unit] then
								opt.anchorTo = "UIParent"
								LUF:CorrectPosition(_G[UnitToFrame["raid"..i]])
							end
						end
					else
						if tbl.anchorTo == UnitToFrame[unit] then
							tbl.anchorTo = "UIParent"
							if _G[UnitToFrame[unit]] then
								LUF:CorrectPosition(_G[UnitToFrame[unit]])
							else
								tbl.point = "TOPRIGHT"
								tbl.relativePoint = "BOTTOMLEFT"
								tbl.x = UIParent:GetWidth()/2*UIParent:GetScale()
								tbl.y = UIParent:GetHeight()/2*UIParent:GetScale()
							end
						end
					end
				end
			end
		end
	end

	local function setColor(info, r, g, b)
		local db = LUF.db.profile.colors[info[#info]]
		db.r = r
		db.g = g
		db.b = b
		LUF:LoadoUFSettings()
		LUF:ReloadAll()
	end

	local function setBGColor(info, r, g, b, a)
		local db = LUF.db.profile.colors[info[#info]]
		db.r = r
		db.g = g
		db.b = b
		db.a = a
		LUF:LoadoUFSettings()
		LUF:ReloadAll()
	end

	local function getColor(info)
		local db = LUF.db.profile.colors[info[#info]]
		return db.r, db.g ,db.b, db.a
	end

	local MediaList = {}
	local function getMediaData(info)
		local mediaType = info[#(info)]

		MediaList[mediaType] = MediaList[mediaType] or {}

		for k in pairs(MediaList[mediaType]) do MediaList[mediaType][k] = nil end
		for _, name in pairs(SML:List(mediaType)) do
			MediaList[mediaType][name] = name
		end

		return MediaList[mediaType]
	end

	local function wipeTextures()
		for unit,tbl in pairs(LUF.db.profile.units) do
			for barname,bartbl in pairs(tbl) do
				if type(bartbl) == "table" and bartbl.statusbar then
					bartbl.statusbar = nil
				end
			end
		end
	end

	local function wipeFonts()
		for unit,tbl in pairs(LUF.db.profile.units) do
			for bar,bartbl in pairs(tbl.tags) do
				bartbl.font = nil
			end
			tbl.combatText.font = nil
		end
		LUF.db.profile.units.raid.font = nil
	end

	local function setGrowthDir(info, value)
		local unit = info[#info-2]
		local db = LUF.db.profile.units[unit]
		local alreadySet = {}

		db.attribPoint = value
		if unit == "party" then
			LUF.db.profile.units.partytarget.attribPoint = value
			LUF.db.profile.units.partypet.attribPoint = value
		elseif unit == "raid" then
			LUF.db.profile.units.partypet.attribPoint = value
		end

		-- Simply re-set all frames is easier than making a complicated selection algorithm
		for unitName, name in pairs(UnitToFrame) do
			if unitName ~= "None" and name ~= "UIParent" and _G[name] then
				LUF:CorrectPosition(_G[name])
			end
		end
		LUF:SetupHeader(unit)
		if unit == "party" then
			LUF:SetupHeader("partytarget")
			LUF:SetupHeader("partypet")
		elseif unit == "raid" then
			LUF:SetupHeader("raidpet")
		end
		
	end

	local function setHideRaid(info, value)
		LUF.db.profile.units.party.hideraid = value
		LUF.stateMonitor:SetAttribute("hideraid", value)
		LUF:SetupHeader("party")
		LUF:SetupHeader("partypet")
		LUF:SetupHeader("partytarget")
	end

	local function setSortMethod(info, value)
		local unit = info[#info-2]
		LUF.db.profile.units[unit].sortMethod = value
		LUF:SetupHeader(unit)
		if unit == "party" then
			LUF.db.profile.units["partytarget"].sortMethod = value
			LUF:SetupHeader("partytarget")
			LUF.db.profile.units["partypet"].sortMethod = value
			LUF:SetupHeader("partypet")
		end
	end

	local function setSortOrder(info, value)
		local unit = info[#info-2]
		LUF.db.profile.units[unit].sortOrder = value
		LUF:SetupHeader(unit)
		if unit == "party" then
			LUF.db.profile.units["partytarget"].sortOrder = value
			LUF:SetupHeader("partytarget")
			LUF.db.profile.units["partypet"].sortOrder = value
			LUF:SetupHeader("partypet")
		end
	end

	local function getShowWhen(info)
		local db = LUF.db.profile.units.raid
		if db.showPlayer and db.showSolo then
			return "ALWAYS"
		elseif db.showParty then
			return "PARTY"
		else
			return "RAID"
		end
	end

	local function setShowWhen(info, value)
		if value == "ALWAYS" then
			LUF.db.profile.units.raid.showSolo = true
			LUF.db.profile.units.raid.showPlayer = true
			LUF.db.profile.units.raid.showParty = true
			LUF.db.profile.units.raidpet.showSolo = true
			LUF.db.profile.units.raidpet.showPlayer = true
			LUF.db.profile.units.raidpet.showParty = true
		elseif value == "PARTY" then
			LUF.db.profile.units.raid.showSolo = nil
			LUF.db.profile.units.raid.showPlayer = true
			LUF.db.profile.units.raid.showParty = true
			LUF.db.profile.units.raidpet.showSolo = nil
			LUF.db.profile.units.raidpet.showPlayer = true
			LUF.db.profile.units.raidpet.showParty = true
		else
			LUF.db.profile.units.raid.showSolo = nil
			LUF.db.profile.units.raid.showPlayer = nil
			LUF.db.profile.units.raid.showParty = nil
			LUF.db.profile.units.raidpet.showSolo = nil
			LUF.db.profile.units.raidpet.showPlayer = nil
			LUF.db.profile.units.raidpet.showParty = nil
		end
		LUF:SetupHeader("raid")
		LUF:SetupHeader("raidpet")
	end

	local function Lockdown() return LUF.InCombatLockdown end

	local function deepAnchorCheck(tbl)
		local inserted
		for frame in pairs(tbl) do
			for key,value in pairs(LUF.db.profile.units) do
				if key == "raid" then
					for k,v in pairs(LUF.db.profile.units.raid.positions) do
						if v.anchorTo == frame and not tbl[UnitToFrame["raid"..k]] then
							tbl[UnitToFrame["raid"..k]] = true
							inserted = true
						end
					end
				else
					if value.anchorTo == frame and not tbl[UnitToFrame[key]] then
						tbl[UnitToFrame[key]] = true
						inserted = true
					end
				end
			end
		end
		if inserted then
			return deepAnchorCheck(tbl)
		else
			return tbl
		end
	end

	local function getAnchors(info)
		local unit = info[#info-2]
		if unit == "raid" then
			unit = info[#info]
		end
		local tbl = {
				["UIParent"]=NONE,
				["LUFUnitplayer"]=PLAYER,
				["LUFUnitpet"]=PET,
				["LUFUnitpettarget"]=L["pettarget"],
				["LUFUnitpettargettarget"]=L["pettargettarget"],
				["LUFUnittarget"]=TARGET,
				["LUFUnittargettarget"]=L["targettarget"],
				["LUFUnittargettargettarget"]=L["targettargettarget"],
				["LUFHeaderparty"]=PARTY,
				["LUFHeaderpartytarget"]=L["partytarget"],
				["LUFHeaderpartypet"]=L["partypet"],
				["LUFHeaderraid1"]=(RAID.."1"),
				["LUFHeaderraid2"]=(RAID.."2"),
				["LUFHeaderraid3"]=(RAID.."3"),
				["LUFHeaderraid4"]=(RAID.."4"),
				["LUFHeaderraid5"]=(RAID.."5"),
				["LUFHeaderraid6"]=(RAID.."6"),
				["LUFHeaderraid7"]=(RAID.."7"),
				["LUFHeaderraid8"]=(RAID.."8"),
				["LUFHeaderraidpet"]=L["raidpet"],
				["LUFHeadermaintank"]=MAINTANK,
				["LUFHeadermaintanktarget"]=L["maintanktarget"],
				["LUFHeadermaintanktargettarget"]=L["maintanktargettarget"],
				["LUFHeadermainassist"]=MAIN_ASSIST,
				["LUFHeadermainassisttarget"]=L["mainassisttarget"],
				["LUFHeadermainassisttargettarget"]=L["mainassisttargettarget"],
			}
		for key in pairs(deepAnchorCheck({[UnitToFrame[unit]]=true})) do
			tbl[key] = nil
		end
		for frameName, unitName in pairs(tbl) do
			if frameName ~= "UIParent" and _G[frameName] then
		--		if not LUF.db.profile.units[_G[frameName].unitType].enabled then
		--			tbl[frameName] = nil
		--		end
			elseif not _G[frameName] then
				tbl[frameName] = nil
			end
		end
		return tbl
	end

	local function SetAnchorTo(info, value)
		local frame
		if info[#info-2] == "raid" then
			local nbr = strmatch(info[#info], "%d")
			LUF.db.profile.units.raid.positions[tonumber(nbr)].anchorTo = value
			frame = LUF.Units.headerFrames["raid"..nbr]
		else
			LUF.db.profile.units[info[#info-2]].anchorTo = value
			frame = _G[UnitToFrame[info[#info-2]]]
		end
		LUF:CorrectPosition(frame)
		-- Notify the configuration it can update itself now
		if( ACR ) then
			ACR:NotifyChange("LunaUnitFrames")
		end
	end

	local moduleBlacklist = {
		["range"] = {
			["player"] = true,
		},
		["castBar"] = {
			["pet"] = true,
			["pettarget"] = true,
			["pettargettarget"] = true,
			["targettarget"] = true,
			["targettargettarget"] = true,
			["partytarget"] = true,
			["partypet"] = true,
			["raidpet"] = true,
			["maintanktarget"] = true,
			["maintanktargettarget"] = true,
			["mainassisttarget"] = true,
			["mainassisttargettarget"] = true,
		},
		["fader"] = {
			["target"] = true,
			["targettarget"] = true,
			["targettargettarget"] = true,
		}
	}

	local function validateMissingBuffInput(info, value)
		local spellGroups = {strsplit(";",value)}
		local j
		for j,spellGroup in ipairs(spellGroups) do
			local localSpells = {strsplit("/",spellGroup)}
			local k
			for k,spell in ipairs(localSpells) do
				spell = spell:gsub("%[mana%]", "")
				if spell ~="" and not tonumber(spell) and not GetSpellInfo(spell) then
					return L["You can only use Spellnames for Spells your Character knows otherwise please use Spell IDs"]
				end
			end
		end
		return true
	end

	local moduleOptions = {
		healthBar = {
			name = L["Health bar"],
			type = "group",
			order = 3,
			--inline = true,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."], L["Health bar"]),
					type = "toggle",
					order = 1,
				},
				background = {
					name = BACKGROUND,
					desc = string.format(L["Enable or disable the %s."], BACKGROUND),
					type = "toggle",
					order = 2,
				},
				backgroundAlpha = {
					name = L["Background alpha"],
					desc = L["Set the background alpha."],
					type = "range",
					order = 3,
					min = 0,
					max = 1,
					step = 0.01,
				},
				colorType = {
					name = L["Color by type"],
					--desc = L["Color by type"],
					type = "select",
					order = 4,
					values = function(info) if info[1] ~= "pet" then return {["class"] = CLASS, ["static"] = L["Static"], ["percent"] = L["Health percent"]} else return {["happiness"] = HAPPINESS, ["static"] = L["Static"], ["percent"] = L["Health percent"]} end end,
				},
				reactionType = {
					name = L["Color by reaction"],
					--desc = L["Color by reaction"],
					type = "select",
					order = 5,
					values = {["none"] = L["Never (Disabled)"], ["player"] = L["Players only"], ["npc"] = L["NPCs only"], ["both"] = STATUS_TEXT_BOTH},
				},
				height = {
					name = L["Height"],
					desc = L["Set the height."],
					type = "range",
					order = 6,
					min = 1,
					max = 10,
					step = 0.1,
				},
				order = {
					name = L["Order"],
					desc = L["Set the order priority."],
					type = "range",
					order = 7,
					min = 0,
					max = 100,
					step = 5,
				},
				statusbar = {
					order = 8,
					type = "select",
					name = L["Bar texture"],
					dialogControl = "LSM30_Statusbar",
					values = getMediaData,
					get = function(info) return get(info) or LUF.db.profile.statusbar or SML.DefaultMedia.statusbar end,
				},
				vertical = {
					name = L["Vertical"],
					desc = L["Set the bar vertical."],
					type = "toggle",
					order = 9,
				},
				invert = {
					name = L["Invert"],
					desc = L["Kind of inverts the color scheme."],
					type = "toggle",
					order = 10,
				},
			},
		},
		["powerBar"] = {
			name = L["Power bar"],
			type = "group",
			order = 4,
			--inline = true,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."], L["Power bar"]),
					type = "toggle",
					order = 1,
				},
				ticker = {
					name = L["Ticker"],
					desc = L["Since mana/energy regenerate in ticks, show a timer for it"],
					type = "toggle",
					order = 2,
					hidden = function(info) return info[1] ~= "player" or select(2, UnitClass("player")) == "WARRIOR" end
				},
				hideticker = {
					name = L["Autohide ticker"],
					desc = L["Hide the ticker when it's not needed"],
					type = "toggle",
					order = 3,
					hidden = function(info) return info[1] ~= "player" or select(2, UnitClass("player")) == "WARRIOR" end
				},
				fivesecond = {
					name = L["Five second rule"],
					desc = L["Show a timer for the five second rule"],
					type = "toggle",
					order = 4,
					hidden = function(info) return info[1] ~= "player" or select(2, UnitClass("player")) == "WARRIOR" end
				},
				background = {
					name = BACKGROUND,
					desc = string.format(L["Enable or disable the %s."], BACKGROUND),
					type = "toggle",
					order = 5,
				},
				backgroundAlpha = {
					name = L["Background alpha"],
					desc = L["Set the background alpha."],
					type = "range",
					order = 6,
					min = 0,
					max = 1,
					step = 0.01,
				},
				colorType = {
					name = L["Color by type"],
					--desc = L["Color by type"],
					type = "select",
					order = 7,
					values = {["class"] = CLASS, ["type"] = L["Power Type"]},
				},
				height = {
					name = L["Height"],
					desc = L["Set the height."],
					type = "range",
					order = 8,
					min = 1,
					max = 10,
					step = 0.1,
				},
				order = {
					name = L["Order"],
					desc = L["Set the order priority."],
					type = "range",
					order = 9,
					min = 0,
					max = 100,
					step = 5,
				},
				statusbar = {
					order = 10,
					type = "select",
					name = L["Bar texture"],
					dialogControl = "LSM30_Statusbar",
					values = getMediaData,
					get = function(info) return get(info) or LUF.db.profile.statusbar or SML.DefaultMedia.statusbar end,
				},
				vertical = {
					name = L["Vertical"],
					desc = L["Set the bar vertical."],
					type = "toggle",
					order = 11,
				},
			},
		},
		["manaPrediction"] = {
			name = L["Mana Prediction"],
			type = "group",
			order = 5,
			--inline = true,
			hidden = function(info) return not (info[1] == "player") end,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."],L["Mana Prediction"]),
					type = "toggle",
					order = 1,
				},
				color = {
					name = COLOR,
					type = "color",
					order = 2,
					width = "half",
					hasAlpha = true,
					get = function(info) local db = LUF.db.profile.units.player.manaPrediction.color return db.r, db.g ,db.b, db.a end,
					set = function(info, r, g, b, a) local db = LUF.db.profile.units.player.manaPrediction.color db.r = r db.g = g db.b = b db.a = a LUF:Reload(info[1]) end,
				},
			},
		},
		["castBar"] = {
			name = SHOW_ARENA_ENEMY_CASTBAR_TEXT,
			type = "group",
			order = 6,
			--inline = true,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."],SHOW_ARENA_ENEMY_CASTBAR_TEXT),
					type = "toggle",
					order = 1,
				},
				autoHide = {
					name = L["Auto hide"],
					desc = string.format(L["Hide when inactive"]),
					type = "toggle",
					order = 2,
				},
				icon = {
					name = L["Cast icon"],
					desc = L["Set the behaviour of the cast icon"],
					type = "select",
					order = 3,
					values = {["HIDE"] = HIDE, ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"]},
				},
				height = {
					name = L["Height"],
					desc = L["Set the height."],
					type = "range",
					order = 6,
					min = 1,
					max = 10,
					step = 0.1,
				},
				order = {
					name = L["Order"],
					desc = L["Set the order priority."],
					type = "range",
					order = 7,
					min = 0,
					max = 100,
					step = 5,
				},
				statusbar = {
					order = 8,
					type = "select",
					name = L["Bar texture"],
					dialogControl = "LSM30_Statusbar",
					values = getMediaData,
					get = function(info) return get(info) or LUF.db.profile.statusbar or SML.DefaultMedia.statusbar end,
				},
			},
		},
		["emptyBar"] = {
			name = L["Empty bar"],
			type = "group",
			order = 7,
			--inline = true,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."], L["Empty bar"]),
					type = "toggle",
					order = 1,
				},
				alpha = {
					name = OPACITY,
					desc = L["Set the alpha."],
					type = "range",
					order = 2,
					min = 0,
					max = 1,
					step = 0.01,
				},
				reactionType = {
					name = L["Color by reaction"],
					--desc = L["Color by reaction"],
					type = "select",
					order = 3,
					values = {["none"] = L["Never (Disabled)"], ["player"] = L["Players only"], ["NPC/hostile player"] = L["NPCs and Hostile players"], ["npc"] = L["NPCs only"], ["both"] = STATUS_TEXT_BOTH},
				},
				class = {
					name = UNIT_COLORS,
					desc = L["Color by class."],
					type = "toggle",
					order = 4,
				},
				height = {
					name = L["Height"],
					desc = L["Set the height."],
					type = "range",
					order = 5,
					min = 1,
					max = 10,
					step = 0.1,
				},
				order = {
					name = L["Order"],
					desc = L["Set the order priority."],
					type = "range",
					order = 6,
					min = 0,
					max = 100,
					step = 5,
				},
				statusbar = {
					order = 7,
					type = "select",
					name = L["Bar texture"],
					dialogControl = "LSM30_Statusbar",
					values = getMediaData,
					get = function(info) return get(info) or LUF.db.profile.statusbar or SML.DefaultMedia.statusbar end,
				},
				vertical = {
					name = L["Vertical"],
					desc = L["Set the bar vertical."],
					type = "toggle",
					order = 8,
				},
			},
		},
		["range"] = {
			name = L["Range"],
			type = "group",
			order = 8,
			--inline = true,
			hidden = function(info) if info[1] == "player" then return true end end,
			args = {
				enabled = {
					name = ENABLE,
					desc = L["Enable or disable range checking."],
					type = "toggle",
					order = 1,
				},
			},
		},
		["portrait"] = {
			name = L["Portrait"],
			type = "group",
			order = 9,
			--inline = true,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."],L["Portrait"]),
					type = "toggle",
					order = 1,
				},
				showStatus = {
					name = L["Show Status"],
					desc = L["Show unit status on the portrait with a cooldown animation."],
					type = "toggle",
					order = 2,
				},
				verboseStatus = {
					name = L["Verbose Status"],
					desc = L["Show more unit statuses on the portrait."],
					type = "toggle",
					order = 3,
				},
				type = {
					name = L["Type"],
					desc = L["Portrait type"],
					type = "select",
					order = 4,
					values = {["3D"] = L["3D"], ["2D"] = L["2D"], ["class"] = CLASS, ["2dclass"] = L["2D Class"]},
				},
				alignment = {
					name = L["Alignment"],
					desc = L["Portrait alignment"],
					type = "select",
					order = 5,
					values = {["LEFT"] = L["Left"], ["RIGHT"] = L["Right"], ["CENTER"] = L["Center"]},
				},
				width = {
					name = L["Width"],
					desc = L["Set the width of the portrait."],
					type = "range",
					order = 6,
					min = 0,
					max = 1,
					step = 0.01,
				},
				height = {
					name = L["Height"],
					desc = L["Set the height when in bar mode."],
					type = "range",
					order = 7,
					min = 1,
					max = 10,
					step = 0.1,
				},
				order = {
					name = L["Order"],
					desc = L["Set the order priority."],
					type = "range",
					order = 8,
					min = 0,
					max = 100,
					step = 5,
				},
				fullBefore = {
					name = L["full Before"],
					desc = L["Bars with lower order priority than this will be above."],
					type = "range",
					order = 9,
					min = 0,
					max = 100,
					step = 5,
				},
				fullAfter = {
					name = L["full After"],
					desc = L["Bars with higher order priority than this will be below."],
					type = "range",
					order = 10,
					min = 0,
					max = 100,
					step = 5,
				},
			},
		},
		["incHeal"] = {
			name = L["Incoming heals"],
			type = "group",
			order = 10,
			--inline = true,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."],L["Incoming heals"]),
					type = "toggle",
					order = 1,
				},
				cap = {
					name = L["Inc Heal Cap"],
					desc = L["Let the prediction overgrow the bar."],
					type = "range",
					order = 2,
					min = 1,
					max = 1.3,
					step = 0.01,
				},
				alpha = {
					name = OPACITY,
					desc = L["Set the alpha."],
					type = "range",
					order = 3,
					min = 0,
					max = 1,
					step = 0.01,
				},
			},
		},
		["auras"] = {
			name = L["Auras"],
			type = "group",
			order = 11,
			--inline = true,
			disabled = Lockdown,
			args = {
				generalheader = {
					name = GENERAL,
					type = "header",
					order = 1,
				},
				weaponbuffs = {
					name = L["Weaponbuffs"],
					desc = string.format(L["Enable or disable the %s."],L["Weaponbuffs"]),
					type = "toggle",
					order = 2,
					hidden = function(info) return info[1] ~= "player" end
				},
				bordercolor = {
					name = L["Bordercolor"],
					desc = string.format(L["Enable or disable the %s."],L["Bordercolor"]),
					type = "toggle",
					order = 3,
				},
				padding = {
					name = L["Padding"],
					desc = L["Distance between aura icons."],
					type = "range",
					order = 4,
					min = 0,
					max = 10,
					step = 1,
				},
				timer = {
					name = L["Timers"],
					desc = L["Limit timers to..."],
					type = "select",
					order = 5,
					values = {["all"] = ACHIEVEMENTFRAME_FILTER_ALL, ["self"] = L["Own"], ["none"] = NONE},
				},
				buffheader = {
					name = L["Buffs"],
					type = "header",
					order = 6,
				},
				buffs = {
					name = L["Buffs"],
					desc = string.format(L["Enable or disable the %s."],L["Buffs"]),
					type = "toggle",
					order = 7,
				},
				filterbuffs = {
					name = string.format(L["Filter %s"],L["Buffs"]),
					desc = L["Show only buffs that you or everyone of your class can apply"],
					type = "select",
					order = 8,
					values = {[1] = OFF, [2] = L["Your own"], [3] = CLASS},
				},
				buffsize = {
					name = L["Size"],
					desc = L["Set the buffsize."],
					type = "range",
					order = 9,
					min = 4,
					max = 50,
					step = 1,
				},
				enlargedbuffsize = {
					name = L["Bigger buffs"],
					desc = EMPHASIZE_MY_SPELLS_TEXT,
					type = "range",
					order = 10,
					min = 0,
					max = 20,
					step = 1,
					hidden = function(info) return (LUF.db.profile.units[info[1]].auras.buffpos == "INFRAME" or LUF.db.profile.units[info[1]].auras.buffpos == "INFRAMECENTER") end
				},
				buffpos = {
					name = L["Position"],
					desc = string.format(L["Position of the %s."],L["Buffs"]),
					type = "select",
					order = 11,
					values = {["LEFT"] = L["Left"], ["RIGHT"] = L["Right"], ["TOP"] = L["Top"], ["BOTTOM"] = L["Bottom"], ["INFRAME"] = L["Inside"], ["INFRAMECENTER"] = L["Inside Center"]},
				},
				wrapbuffside = {
					name = L["Horizontal Limit Side"],
					desc = L["Side on which to cut shorter than the frame"],
					type = "select",
					order = 12,
					values = {["LEFT"] = L["Left"], ["RIGHT"] = L["Right"]},
					hidden = function(info) return (LUF.db.profile.units[info[1]].auras.buffpos ~= "TOP" and LUF.db.profile.units[info[1]].auras.buffpos ~= "BOTTOM") end,
				},
				wrapbuff = {
					name = L["Horizontal Limit"],
					desc = L["Limit to a percentage of the frame"],
					type = "range",
					order = 13,
					min = 0.2,
					max = 1.5,
					step = 0.01,
					width = "double",
					isPercent = true,
					hidden = function(info) return (LUF.db.profile.units[info[1]].auras.buffpos ~= "TOP" and LUF.db.profile.units[info[1]].auras.buffpos ~= "BOTTOM") end,
				},
				debuffheader = {
					name = L["Debuffs"],
					type = "header",
					order = 14,
				},
				debuffs = {
					name = L["Debuffs"],
					desc = string.format(L["Enable or disable the %s."],L["Debuffs"]),
					type = "toggle",
					order = 15,
				},
				filterdebuffs = {
					name = string.format(L["Filter %s"],L["Debuffs"]),
					desc = L["Show only debuffs that you can dispel or cast"],
					type = "select",
					order = 16,
					values = {[1] = OFF, [2] = L["Your own"], [3] = DISPELS},
				},
				debuffsize = {
					name = L["Size"],
					desc = L["Set the debuffsize."],
					type = "range",
					order = 17,
					min = 4,
					max = 50,
					step = 1,
				},
				enlargeddebuffsize = {
					name = L["Bigger debuffs"],
					desc = EMPHASIZE_MY_SPELLS_TEXT,
					type = "range",
					order = 18,
					min = 0,
					max = 20,
					step = 1,
					hidden = function(info) return (LUF.db.profile.units[info[1]].auras.debuffpos == "INFRAME" or LUF.db.profile.units[info[1]].auras.debuffpos == "INFRAMECENTER") end,
				},
				debuffpos = {
					name = L["Position"],
					desc = string.format(L["Position of the %s."],L["Debuffs"]),
					type = "select",
					order = 19,
					values = {["LEFT"] = L["Left"], ["RIGHT"] = L["Right"], ["TOP"] = L["Top"], ["BOTTOM"] = L["Bottom"], ["INFRAME"] = L["Inside"], ["INFRAMECENTER"] = L["Inside Center"]},
				},
				wrapdebuffside = {
					name = L["Horizontal Limit Side"],
					desc = L["Side on which to cut shorter than the frame"],
					type = "select",
					order = 20,
					hidden = function(info) return (LUF.db.profile.units[info[1]].auras.debuffpos ~= "TOP" and LUF.db.profile.units[info[1]].auras.debuffpos ~= "BOTTOM") end,
					values = {["LEFT"] = L["Left"], ["RIGHT"] = L["Right"]},
				},
				wrapdebuff = {
					name = L["Horizontal Limit"],
					desc = L["Limit to a percentage of the frame."],
					type = "range",
					order = 21,
					min = 0.2,
					max = 1.5,
					step = 0.01,
					width = "double",
					isPercent = true,
					hidden = function(info) return (LUF.db.profile.units[info[1]].auras.debuffpos ~= "TOP" and LUF.db.profile.units[info[1]].auras.debuffpos ~= "BOTTOM") end,
				},
			},
		},
		["borders"] = {
			name = L["Borders"],
			type = "group",
			order = 12,
			--inline = true,
			args = {
				target = {
					name = L["On target"],
					desc = string.format(L["Highlight the frames borders when the unit is targeted"]),
					type = "toggle",
					hidden = function(info) return info[1] == "target" end,
					order = 1,
				},
				mouseover = {
					name = L["On mouseover"],
					desc = string.format(L["Highlight the frames borders when the unit is moused over"]),
					type = "toggle",
					order = 2,
				},
				aggro = {
					name = L["On aggro"],
					desc = string.format(L["Highlight the frames borders when the unit has aggro"]),
					type = "toggle",
					order = 3,
				},
				debuff = {
					name = L["On debuff"],
					desc = string.format(L["Highlight the frames borders when the unit has a debuff you or someone can remove"]),
					type = "select",
					order = 4,
					values = {[1] = OFF, [2] = L["Your own"], [3] = ACHIEVEMENTFRAME_FILTER_ALL},
				},
				size = {
					name = L["Size"],
					desc = L["Set the size."],
					type = "range",
					order = 5,
					min = 1,
					max = 10,
					step = 1,
				},
			},
		},
		["highlight"] = {
			name = L["Highlight"],
			type = "group",
			order = 13,
			--inline = true,
			args = {
				target = {
					name = L["On target"],
					desc = string.format(BINDING_NAME_INTERACTTARGET),
					type = "toggle",
					hidden = function(info) return info[1] == "target" end,
					order = 1,
				},
				mouseover = {
					name = L["On mouseover"],
					desc = string.format(BINDING_NAME_INTERACTMOUSEOVER),
					type = "toggle",
					order = 2,
				},
				aggro = {
					name = L["On aggro"],
					desc = string.format(L["Highlight the frame when the unit has aggro"]),
					type = "toggle",
					order = 3,
				},
				debuff = {
					name = L["On debuff"],
					desc = string.format(L["Highlight the frame when the unit has a debuff you or someone can remove"]),
					type = "select",
					order = 4,
					values = {[1] = OFF, [2] = L["Your own"], [3] = ACHIEVEMENTFRAME_FILTER_ALL},
				},
			},
		},
		["fader"] = {
			name = L["Combat fader"],
			type = "group",
			order = 14,
			--inline = true,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."],L["Combat fader"]),
					type = "toggle",
					order = 1,
				},
				combatAlpha = {
					name = L["Combat alpha"],
					desc = L["Set the alpha."],
					type = "range",
					order = 2,
					min = 0,
					max = 1,
					step = 0.01,
				},
				inactiveAlpha = {
					name = L["Inactive alpha"],
					desc = L["Set the alpha."],
					type = "range",
					order = 3,
					min = 0,
					max = 1,
					step = 0.01,
				},
				speedyFade = {
					name = L["Speedy fade"],
					desc = string.format(L["Enable or disable the %s."],L["Speedy fade"]),
					type = "toggle",
					order = 4,
				},
			},
		},
		["tags"] = {
			name = L["Tags"],
			type = "group",
			order = 15,
			--inline = true,
			args = {
				top = {
					name = L["Top"],
					type = "group",
					order = 1,
					inline = true,
					args = {
						left = {
							name = L["Left"],
							type = "group",
							order = 1,
							inline = true,
							args = {
								tagline = {
									name = L["Left"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						center = {
							name = L["Center"],
							type = "group",
							order = 2,
							inline = true,
							args = {
								tagline = {
									name = L["Center"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						right = {
							name = L["Right"],
							type = "group",
							order = 3,
							inline = true,
							args = {
								tagline = {
									name = L["Right"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						size = {
							name = FONT_SIZE,
							desc = L["Set the font size."],
							type = "range",
							order = 4,
							width = "double",
							min = 5,
							max = 24,
							step = 1,
						},
						font = {
							order = 5,
							type = "select",
							name = L["Font"],
							dialogControl = "LSM30_Font",
							values = getMediaData,
							get = function(info) return get(info) or LUF.db.profile.font or SML.DefaultMedia.font end,
						},
					},
				},
				healthBar = {
					name = L["Health bar"],
					type = "group",
					order = 2,
					inline = true,
					args = {
						left = {
							name = L["Left"],
							type = "group",
							order = 1,
							inline = true,
							args = {
								tagline = {
									name = L["Left"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						center = {
							name = L["Center"],
							type = "group",
							order = 2,
							inline = true,
							args = {
								tagline = {
									name = L["Center"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						right = {
							name = L["Right"],
							type = "group",
							order = 3,
							inline = true,
							args = {
								tagline = {
									name = L["Right"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						size = {
							name = FONT_SIZE,
							desc = L["Set the font size."],
							type = "range",
							order = 4,
							width = "double",
							min = 5,
							max = 24,
							step = 1,
						},
						font = {
							order = 5,
							type = "select",
							name = L["Font"],
							dialogControl = "LSM30_Font",
							values = getMediaData,
							get = function(info) return get(info) or LUF.db.profile.font or SML.DefaultMedia.font end,
						},
					},
				},
				powerBar = {
					name = L["Power bar"],
					type = "group",
					order = 3,
					inline = true,
					args = {
						left = {
							name = L["Left"],
							type = "group",
							order = 1,
							inline = true,
							args = {
								tagline = {
									name = L["Left"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						center = {
							name = L["Center"],
							type = "group",
							order = 2,
							inline = true,
							args = {
								tagline = {
									name = L["Center"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						right = {
							name = L["Right"],
							type = "group",
							order = 3,
							inline = true,
							args = {
								tagline = {
									name = L["Right"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						size = {
							name = FONT_SIZE,
							desc = L["Set the font size."],
							type = "range",
							order = 4,
							width = "double",
							min = 5,
							max = 24,
							step = 1,
						},
						font = {
							order = 5,
							type = "select",
							name = L["Font"],
							dialogControl = "LSM30_Font",
							values = getMediaData,
							get = function(info) return get(info) or LUF.db.profile.font or SML.DefaultMedia.font end,
						},
					},
				},
				castBar = {
					name = SHOW_ARENA_ENEMY_CASTBAR_TEXT,
					type = "group",
					order = 4,
					inline = true,
					hidden = function(info) return moduleBlacklist.castBar[info[#info-2]] end,
					args = {
						left = {
							name = L["Left"],
							type = "group",
							order = 1,
							inline = true,
							args = {
								tagline = {
									name = L["Left"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						center = {
							name = L["Center"],
							type = "group",
							order = 2,
							inline = true,
							args = {
								tagline = {
									name = L["Center"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						right = {
							name = L["Right"],
							type = "group",
							order = 3,
							inline = true,
							args = {
								tagline = {
									name = L["Right"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						size = {
							name = FONT_SIZE,
							desc = L["Set the font size."],
							type = "range",
							order = 4,
							width = "double",
							min = 5,
							max = 24,
							step = 1,
						},
						font = {
							order = 5,
							type = "select",
							name = L["Font"],
							dialogControl = "LSM30_Font",
							values = getMediaData,
							get = function(info) return get(info) or LUF.db.profile.font or SML.DefaultMedia.font end,
						},
					},
				},
				emptyBar = {
					name = L["Empty bar"],
					type = "group",
					order = 5,
					inline = true,
					args = {
						left = {
							name = L["Left"],
							type = "group",
							order = 1,
							inline = true,
							args = {
								tagline = {
									name = L["Left"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						center = {
							name = L["Center"],
							type = "group",
							order = 2,
							inline = true,
							args = {
								tagline = {
									name = L["Center"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						right = {
							name = L["Right"],
							type = "group",
							order = 3,
							inline = true,
							args = {
								tagline = {
									name = L["Right"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						size = {
							name = FONT_SIZE,
							desc = L["Set the font size."],
							type = "range",
							order = 4,
							width = "double",
							min = 5,
							max = 24,
							step = 1,
						},
						font = {
							order = 5,
							type = "select",
							name = L["Font"],
							dialogControl = "LSM30_Font",
							values = getMediaData,
							get = function(info) return get(info) or LUF.db.profile.font or SML.DefaultMedia.font end,
						},
					},
				},
				druidBar = {
					name = L["Druid bar"],
					type = "group",
					order = 6,
					inline = true,
					hidden = function(info) return info[1] ~= "player" or select(2,UnitClass("player")) ~= "DRUID" end,
					args = {
						left = {
							name = L["Left"],
							type = "group",
							order = 1,
							inline = true,
							args = {
								tagline = {
									name = L["Left"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						center = {
							name = L["Center"],
							type = "group",
							order = 2,
							inline = true,
							args = {
								tagline = {
									name = L["Center"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						right = {
							name = L["Right"],
							type = "group",
							order = 3,
							inline = true,
							args = {
								tagline = {
									name = L["Right"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						size = {
							name = FONT_SIZE,
							desc = L["Set the font size."],
							type = "range",
							order = 4,
							width = "double",
							min = 5,
							max = 24,
							step = 1,
						},
						font = {
							order = 5,
							type = "select",
							name = L["Font"],
							dialogControl = "LSM30_Font",
							values = getMediaData,
							get = function(info) return get(info) or LUF.db.profile.font or SML.DefaultMedia.font end,
						},
					},
				},
				xpBar = {
					name = L["Xp bar"],
					type = "group",
					order = 7,
					inline = true,
					hidden = function(info) return info[1] ~= "player" and info[1] ~= "pet" end,
					args = {
						left = {
							name = L["Left"],
							type = "group",
							order = 1,
							inline = true,
							args = {
								tagline = {
									name = L["Left"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						center = {
							name = L["Center"],
							type = "group",
							order = 2,
							inline = true,
							args = {
								tagline = {
									name = L["Center"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						right = {
							name = L["Right"],
							type = "group",
							order = 3,
							inline = true,
							args = {
								tagline = {
									name = L["Right"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						size = {
							name = FONT_SIZE,
							desc = L["Set the font size."],
							type = "range",
							order = 4,
							width = "double",
							min = 5,
							max = 24,
							step = 1,
						},
						font = {
							order = 5,
							type = "select",
							name = L["Font"],
							dialogControl = "LSM30_Font",
							values = getMediaData,
							get = function(info) return get(info) or LUF.db.profile.font or SML.DefaultMedia.font end,
						},
					},
				},
				bottom = {
					name = L["Bottom"],
					type = "group",
					order = 8,
					inline = true,
					args = {
						left = {
							name = L["Left"],
							type = "group",
							order = 1,
							inline = true,
							args = {
								tagline = {
									name = L["Left"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						center = {
							name = L["Center"],
							type = "group",
							order = 2,
							inline = true,
							args = {
								tagline = {
									name = L["Center"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						right = {
							name = L["Right"],
							type = "group",
							order = 3,
							inline = true,
							args = {
								tagline = {
									name = L["Right"],
									desc = L["Set the tags."],
									type = "input",
									order = 1,
								},
								size = {
									name = L["Limit"],
									desc = L["Set after which percentage of the bar to cut off."],
									type = "range",
									order = 2,
									min = 1,
									max = 100,
									step = 1,
								},
								offset = {
									name = L["Offset"],
									desc = L["Set the height."],
									type = "range",
									order = 3,
									min = -20,
									max = 20,
									step = 1,
								},
							},
						},
						size = {
							name = FONT_SIZE,
							desc = L["Set the font size."],
							type = "range",
							order = 4,
							width = "double",
							min = 5,
							max = 24,
							step = 1,
						},
						font = {
							order = 5,
							type = "select",
							name = L["Font"],
							dialogControl = "LSM30_Font",
							values = getMediaData,
							get = function(info) return get(info) or LUF.db.profile.font or SML.DefaultMedia.font end,
						},
					},
				},
			},
		},
		["indicators"] = {
			name = L["Indicators"],
			type = "group",
			order = 16,
			--inline = true,
			args = {
				raidTarget = {
					name = RAID_TARGET_ICON,
					type = "group",
					order = 1,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],RAID_TARGET_ICON),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 5,
							max = 40,
							step = 1,
						},
						anchorPoint = {
							name = L["Point"],
							desc = L["Anchor point"],
							type = "select",
							order = 3,
							values = {["TOPLEFT"] = L["Top left"], ["LEFT"] = L["Left"], ["BOTTOMLEFT"] = L["Bottom left"], ["TOP"] = L["Top"], ["CENTER"] = L["Center"], ["BOTTOM"] = L["Bottom"], ["TOPRIGHT"] = L["Top right"], ["RIGHT"] = L["Right"], ["BOTTOMRIGHT"] = L["Bottom right"]},
						},
						x = {
							name = L["X Position"],
							desc = L["Set the X coordinate."],
							type = "range",
							order = 4,
							min = -50,
							max = 50,
							step = 1,
						},
						y = {
							name = L["Y Position"],
							desc = L["Set the Y coordinate."],
							type = "range",
							order = 5,
							min = -100,
							max = 100,
							step = 1,
						},
					},
				},
				class = {
					name = CLASS,
					type = "group",
					order = 2,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],CLASS),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 5,
							max = 40,
							step = 1,
						},
						anchorPoint = {
							name = L["Point"],
							desc = L["Anchor point"],
							type = "select",
							order = 3,
							values = {["TOPLEFT"] = L["Top left"], ["LEFT"] = L["Left"], ["BOTTOMLEFT"] = L["Bottom left"], ["TOP"] = L["Top"], ["CENTER"] = L["Center"], ["BOTTOM"] = L["Bottom"], ["TOPRIGHT"] = L["Top right"], ["RIGHT"] = L["Right"], ["BOTTOMRIGHT"] = L["Bottom right"]},
						},
						x = {
							name = L["X Position"],
							desc = L["Set the X coordinate."],
							type = "range",
							order = 4,
							min = -50,
							max = 50,
							step = 1,
						},
						y = {
							name = L["Y Position"],
							desc = L["Set the Y coordinate."],
							type = "range",
							order = 5,
							min = -100,
							max = 100,
							step = 1,
						},
					},
				},
				masterLoot = {
					name = MASTER_LOOTER,
					type = "group",
					order = 3,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],MASTER_LOOTER),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 5,
							max = 40,
							step = 1,
						},
						anchorPoint = {
							name = L["Point"],
							desc = L["Anchor point"],
							type = "select",
							order = 3,
							values = {["TOPLEFT"] = L["Top left"], ["LEFT"] = L["Left"], ["BOTTOMLEFT"] = L["Bottom left"], ["TOP"] = L["Top"], ["CENTER"] = L["Center"], ["BOTTOM"] = L["Bottom"], ["TOPRIGHT"] = L["Top right"], ["RIGHT"] = L["Right"], ["BOTTOMRIGHT"] = L["Bottom right"]},
						},
						x = {
							name = L["X Position"],
							desc = L["Set the X coordinate."],
							type = "range",
							order = 4,
							min = -50,
							max = 50,
							step = 1,
						},
						y = {
							name = L["Y Position"],
							desc = L["Set the Y coordinate."],
							type = "range",
							order = 5,
							min = -100,
							max = 100,
							step = 1,
						},
					},
				},
				leader = {
					name = LEADER,
					type = "group",
					order = 4,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],LEADER),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 5,
							max = 40,
							step = 1,
						},
						anchorPoint = {
							name = L["Point"],
							desc = L["Anchor point"],
							type = "select",
							order = 3,
							values = {["TOPLEFT"] = L["Top left"], ["LEFT"] = L["Left"], ["BOTTOMLEFT"] = L["Bottom left"], ["TOP"] = L["Top"], ["CENTER"] = L["Center"], ["BOTTOM"] = L["Bottom"], ["TOPRIGHT"] = L["Top right"], ["RIGHT"] = L["Right"], ["BOTTOMRIGHT"] = L["Bottom right"]},
						},
						x = {
							name = L["X Position"],
							desc = L["Set the X coordinate."],
							type = "range",
							order = 4,
							min = -50,
							max = 50,
							step = 1,
						},
						y = {
							name = L["Y Position"],
							desc = L["Set the Y coordinate."],
							type = "range",
							order = 5,
							min = -100,
							max = 100,
							step = 1,
						},
					},
				},
				pvp = {
					name = PVP_FLAG,
					type = "group",
					order = 5,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],PVP_FLAG),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 5,
							max = 40,
							step = 1,
						},
						anchorPoint = {
							name = L["Point"],
							desc = L["Anchor point"],
							type = "select",
							order = 3,
							values = {["TOPLEFT"] = L["Top left"], ["LEFT"] = L["Left"], ["BOTTOMLEFT"] = L["Bottom left"], ["TOP"] = L["Top"], ["CENTER"] = L["Center"], ["BOTTOM"] = L["Bottom"], ["TOPRIGHT"] = L["Top right"], ["RIGHT"] = L["Right"], ["BOTTOMRIGHT"] = L["Bottom right"]},
						},
						x = {
							name = L["X Position"],
							desc = L["Set the X coordinate."],
							type = "range",
							order = 4,
							min = -50,
							max = 50,
							step = 1,
						},
						y = {
							name = L["Y Position"],
							desc = L["Set the Y coordinate."],
							type = "range",
							order = 5,
							min = -100,
							max = 100,
							step = 1,
						},
					},
				},
				pvprank = {
					name = RANK,
					type = "group",
					order = 6,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],RANK),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 5,
							max = 40,
							step = 1,
						},
						anchorPoint = {
							name = L["Point"],
							desc = L["Anchor point"],
							type = "select",
							order = 3,
							values = {["TOPLEFT"] = L["Top left"], ["LEFT"] = L["Left"], ["BOTTOMLEFT"] = L["Bottom left"], ["TOP"] = L["Top"], ["CENTER"] = L["Center"], ["BOTTOM"] = L["Bottom"], ["TOPRIGHT"] = L["Top right"], ["RIGHT"] = L["Right"], ["BOTTOMRIGHT"] = L["Bottom right"]},
						},
						x = {
							name = L["X Position"],
							desc = L["Set the X coordinate."],
							type = "range",
							order = 4,
							min = -50,
							max = 50,
							step = 1,
						},
						y = {
							name = L["Y Position"],
							desc = L["Set the Y coordinate."],
							type = "range",
							order = 5,
							min = -100,
							max = 100,
							step = 1,
						},
					},
				},
				ready = {
					name = READY_CHECK,
					type = "group",
					order = 7,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],READY_CHECK),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 5,
							max = 40,
							step = 1,
						},
						anchorPoint = {
							name = L["Point"],
							desc = L["Anchor point"],
							type = "select",
							order = 3,
							values = {["TOPLEFT"] = L["Top left"], ["LEFT"] = L["Left"], ["BOTTOMLEFT"] = L["Bottom left"], ["TOP"] = L["Top"], ["CENTER"] = L["Center"], ["BOTTOM"] = L["Bottom"], ["TOPRIGHT"] = L["Top right"], ["RIGHT"] = L["Right"], ["BOTTOMRIGHT"] = L["Bottom right"]},
						},
						x = {
							name = L["X Position"],
							desc = L["Set the X coordinate."],
							type = "range",
							order = 4,
							min = -50,
							max = 50,
							step = 1,
						},
						y = {
							name = L["Y Position"],
							desc = L["Set the Y coordinate."],
							type = "range",
							order = 5,
							min = -100,
							max = 100,
							step = 1,
						},
					},
				},
				status = {
					name = PLAYER_STATUS,
					type = "group",
					order = 8,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],PLAYER_STATUS),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 5,
							max = 40,
							step = 1,
						},
						anchorPoint = {
							name = L["Point"],
							desc = L["Anchor point"],
							type = "select",
							order = 3,
							values = {["TOPLEFT"] = L["Top left"], ["LEFT"] = L["Left"], ["BOTTOMLEFT"] = L["Bottom left"], ["TOP"] = L["Top"], ["CENTER"] = L["Center"], ["BOTTOM"] = L["Bottom"], ["TOPRIGHT"] = L["Top right"], ["RIGHT"] = L["Right"], ["BOTTOMRIGHT"] = L["Bottom right"]},
						},
						x = {
							name = L["X Position"],
							desc = L["Set the X coordinate."],
							type = "range",
							order = 4,
							min = -50,
							max = 50,
							step = 1,
						},
						y = {
							name = L["Y Position"],
							desc = L["Set the Y coordinate."],
							type = "range",
							order = 5,
							min = -100,
							max = 100,
							step = 1,
						},
					},
				},
				rezz = {
					name = RESURRECT,
					type = "group",
					order = 9,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],RESURRECT),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 5,
							max = 40,
							step = 1,
						},
						anchorPoint = {
							name = L["Point"],
							desc = L["Anchor point"],
							type = "select",
							order = 3,
							values = {["TOPLEFT"] = L["Top left"], ["LEFT"] = L["Left"], ["BOTTOMLEFT"] = L["Bottom left"], ["TOP"] = L["Top"], ["CENTER"] = L["Center"], ["BOTTOM"] = L["Bottom"], ["TOPRIGHT"] = L["Top right"], ["RIGHT"] = L["Right"], ["BOTTOMRIGHT"] = L["Bottom right"]},
						},
						x = {
							name = L["X Position"],
							desc = L["Set the X coordinate."],
							type = "range",
							order = 4,
							min = -50,
							max = 50,
							step = 1,
						},
						y = {
							name = L["Y Position"],
							desc = L["Set the Y coordinate."],
							type = "range",
							order = 5,
							min = -100,
							max = 100,
							step = 1,
						},
					},
				},
				happiness = {
					name = HAPPINESS,
					type = "group",
					order = 10,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],HAPPINESS),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 5,
							max = 40,
							step = 1,
						},
						anchorPoint = {
							name = L["Point"],
							desc = L["Anchor point"],
							type = "select",
							order = 3,
							values = {["TOPLEFT"] = L["Top left"], ["LEFT"] = L["Left"], ["BOTTOMLEFT"] = L["Bottom left"], ["TOP"] = L["Top"], ["CENTER"] = L["Center"], ["BOTTOM"] = L["Bottom"], ["TOPRIGHT"] = L["Top right"], ["RIGHT"] = L["Right"], ["BOTTOMRIGHT"] = L["Bottom right"]},
						},
						x = {
							name = L["X Position"],
							desc = L["Set the X coordinate."],
							type = "range",
							order = 4,
							min = -50,
							max = 50,
							step = 1,
						},
						y = {
							name = L["Y Position"],
							desc = L["Set the Y coordinate."],
							type = "range",
							order = 5,
							min = -100,
							max = 100,
							step = 1,
						},
					},
				},
				elite = {
					name = L["elite"],
					type = "group",
					order = 11,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],L["elite"]),
							type = "toggle",
							order = 1,
							set = function(info, value)
								set(info, value)
								if info[1] == "player" then
									LUF.oUF.LUF_fakePlayerClassification = LUF.db.profile.units.player.indicators.elite.enabled and LUF.db.profile.units.player.indicators.elite.type or nil
								elseif info[1] == "pet" then
									LUF.oUF.LUF_fakePetClassification = LUF.db.profile.units.pet.indicators.elite.enabled and LUF.db.profile.units.pet.indicators.elite.type or nil
								else
									return
								end
								LUF:ReloadAll()
							end,
						},
						side = {
							name = L["Side"],
							desc = L["Elite indicator alignment"],
							type = "select",
							order = 2,
							values = {["LEFT"] = L["Left"], ["RIGHT"] = L["Right"]},
						},
						type = {
							name = L["Type"],
							desc = L["Type"],
							type = "select",
							order = 3,
							hidden = function(info) return (info[1] ~= "player" and info[1] ~= "pet") end,
							values = {["elite"] = L["elite"], ["rare"] = L["rare"]},
							set = function(info, value)
								set(info, value)
								if info[1] == "player" then
									LUF.oUF.LUF_fakePlayerClassification = LUF.db.profile.units.player.indicators.elite.enabled and LUF.db.profile.units.player.indicators.elite.type or nil
								elseif info[1] == "pet" then
									LUF.oUF.LUF_fakePetClassification = LUF.db.profile.units.pet.indicators.elite.enabled and LUF.db.profile.units.pet.indicators.elite.type or nil
								else
									return
								end
								LUF:ReloadAll()
							end,
						},
					},
				},
				role = {
					name = ROLE,
					type = "group",
					order = 12,
					inline = true,
					hidden = function(info) return not LUF.db.profile.units[info[1]].indicators[info[3]] end,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],ROLE),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 5,
							max = 40,
							step = 1,
						},
						anchorPoint = {
							name = L["Point"],
							desc = L["Anchor point"],
							type = "select",
							order = 3,
							values = {["TOPLEFT"] = L["Top left"], ["LEFT"] = L["Left"], ["BOTTOMLEFT"] = L["Bottom left"], ["TOP"] = L["Top"], ["CENTER"] = L["Center"], ["BOTTOM"] = L["Bottom"], ["TOPRIGHT"] = L["Top right"], ["RIGHT"] = L["Right"], ["BOTTOMRIGHT"] = L["Bottom right"]},
						},
						x = {
							name = L["X Position"],
							desc = L["Set the X coordinate."],
							type = "range",
							order = 4,
							min = -50,
							max = 50,
							step = 1,
						},
						y = {
							name = L["Y Position"],
							desc = L["Set the Y coordinate."],
							type = "range",
							order = 5,
							min = -100,
							max = 100,
							step = 1,
						},
					},
				},
			},
		},
		["combatText"] = {
			name = L["Combat text"],
			type = "group",
			order = 17,
			hidden = function(info) return LUF.fakeUnits[info[1]] end,
			--inline = true,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."],L["Combat text"]),
					type = "toggle",
					order = 1,
				},
				font = {
					name = L["Font"],
					desc = L["Set the font"],
					type = "select",
					order = 2,
					dialogControl = "LSM30_Font",
					values = getMediaData,
					get = function(info) return get(info) or LUF.db.profile.font or SML.DefaultMedia.font end,
				},
				size = {
					name = FONT_SIZE,
					desc = L["Set the font size."],
					type = "range",
					order = 3,
					min = 5,
					max = 40,
					step = 1,
				},
			},
		},
		["squares"] = {
			name = L["Squares"],
			type = "group",
			order = 18,
			--inline = true,
			args = {
				topleft = {
					name = L["Top left"],
					type = "group",
					order = 1,
					inline = true,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],L["Top left"]),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 4,
							max = 40,
							step = 1,
						},
						type = {
							name = L["Type"],
							desc = L["What the indicator should display."],
							type = "select",
							order = 3,
							values = { ["aggro"] = L["Aggro"], ["legacythreat"] = L["Aggro"].." ("..L["targettarget"]..")", ["aura"] = L["Buff/Debuff"], ["ownaura"] = L["Own buff/debuff"], ["dispel"] = DISPELS, ["missing"] = L["Missing Buff"] },
							set = function(info, value) set(info,value) ACR:NotifyChange("LunaUnitFrames") end,
						},
						value = {
							name = L["Name (exact) or ID"],
							desc = L["Name (exact) or ID of the effect to track. Use ; as a logical AND and / as logical OR. Also supports [mana] to only check on mana classes. Example: Arcane Intellect[mana]/Arcane Brilliance[mana];Dampen Magic"],
							type = "input",
							order = 4,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "dispel" end,
							validate = validateMissingBuffInput,
						},
						timer = {
							name = L["Timer"],
							desc = string.format(L["Enable or disable the %s."],L["Timer"]),
							type = "toggle",
							order = 5,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "missing" end,
						},
						texture = {
							name = L["Texture"],
							desc = L["Show the spell texture instead of its type color."],
							type = "toggle",
							order = 6,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" end,
						},
					},
				},
				top = {
					name = L["Top"],
					type = "group",
					order = 2,
					inline = true,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],L["Bottom right"]),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 4,
							max = 40,
							step = 1,
						},
						type = {
							name = L["Type"],
							desc = L["What the indicator should display."],
							type = "select",
							order = 3,
							values = { ["aggro"] = L["Aggro"], ["legacythreat"] = L["Aggro"].." ("..L["targettarget"]..")", ["aura"] = L["Buff/Debuff"], ["ownaura"] = L["Own buff/debuff"], ["dispel"] = DISPELS, ["missing"] = L["Missing Buff"] },
							set = function(info, value) set(info,value) ACR:NotifyChange("LunaUnitFrames") end,
						},
						value = {
							name = L["Name (exact) or ID"],
							desc = L["Name (exact) or ID of the effect to track. Use ; as a logical AND and / as logical OR. Also supports [mana] to only check on mana classes. Example: Arcane Intellect[mana]/Arcane Brilliance[mana];Dampen Magic"],
							type = "input",
							order = 4,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "dispel" end,
							validate = validateMissingBuffInput,
						},
						timer = {
							name = L["Timer"],
							desc = string.format(L["Enable or disable the %s."],L["Timer"]),
							type = "toggle",
							order = 5,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "missing" end,
						},
						texture = {
							name = L["Texture"],
							desc = L["Show the spell texture instead of its type color."],
							type = "toggle",
							order = 6,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" end,
						},
					},
				},
				topright = {
					name = L["Top right"],
					type = "group",
					order = 3,
					inline = true,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],L["Top right"]),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 4,
							max = 40,
							step = 1,
						},
						type = {
							name = L["Type"],
							desc = L["What the indicator should display."],
							type = "select",
							order = 3,
							values = { ["aggro"] = L["Aggro"], ["legacythreat"] = L["Aggro"].." ("..L["targettarget"]..")", ["aura"] = L["Buff/Debuff"], ["ownaura"] = L["Own buff/debuff"], ["dispel"] = DISPELS, ["missing"] = L["Missing Buff"] },
							set = function(info, value) set(info,value) ACR:NotifyChange("LunaUnitFrames") end,
						},
						value = {
							name = L["Name (exact) or ID"],
							desc = L["Name (exact) or ID of the effect to track. Use ; as a logical AND and / as logical OR. Also supports [mana] to only check on mana classes. Example: Arcane Intellect[mana]/Arcane Brilliance[mana];Dampen Magic"],
							type = "input",
							order = 4,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "dispel" end,
							validate = validateMissingBuffInput,
						},
						timer = {
							name = L["Timer"],
							desc = string.format(L["Enable or disable the %s."],L["Timer"]),
							type = "toggle",
							order = 5,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "missing" end,
						},
						texture = {
							name = L["Texture"],
							desc = L["Show the spell texture instead of its type color."],
							type = "toggle",
							order = 6,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" end,
						},
					},
				},
				leftcenter = {
					name = L["Left Center"],
					type = "group",
					order = 4,
					inline = true,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],L["Left Center"]),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 4,
							max = 40,
							step = 1,
						},
						type = {
							name = L["Type"],
							desc = L["What the indicator should display."],
							type = "select",
							order = 3,
							values = { ["aggro"] = L["Aggro"], ["legacythreat"] = L["Aggro"].." ("..L["targettarget"]..")", ["aura"] = L["Buff/Debuff"], ["ownaura"] = L["Own buff/debuff"], ["dispel"] = DISPELS, ["missing"] = L["Missing Buff"] },
							set = function(info, value) set(info,value) ACR:NotifyChange("LunaUnitFrames") end,
						},
						value = {
							name = L["Name (exact) or ID"],
							desc = L["Name (exact) or ID of the effect to track. Use ; as a logical AND and / as logical OR. Also supports [mana] to only check on mana classes. Example: Arcane Intellect[mana]/Arcane Brilliance[mana];Dampen Magic"],
							type = "input",
							order = 4,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "dispel" end,
							validate = validateMissingBuffInput,
						},
						timer = {
							name = L["Timer"],
							desc = string.format(L["Enable or disable the %s."],L["Timer"]),
							type = "toggle",
							order = 5,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "missing" end,
						},
						texture = {
							name = L["Texture"],
							desc = L["Show the spell texture instead of its type color."],
							type = "toggle",
							order = 6,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" end,
						},
					},
				},
				center = {
					name = L["Center"],
					type = "group",
					order = 5,
					inline = true,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],L["Center"]),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 4,
							max = 40,
							step = 1,
						},
						type = {
							name = L["Type"],
							desc = L["What the indicator should display."],
							type = "select",
							order = 3,
							values = { ["aggro"] = L["Aggro"], ["legacythreat"] = L["Aggro"].." ("..L["targettarget"]..")", ["aura"] = L["Buff/Debuff"], ["ownaura"] = L["Own buff/debuff"], ["dispel"] = DISPELS, ["missing"] = L["Missing Buff"] },
							set = function(info, value) set(info,value) ACR:NotifyChange("LunaUnitFrames") end,
						},
						value = {
							name = L["Name (exact) or ID"],
							desc = L["Name (exact) or ID of the effect to track. Use ; as a logical AND and / as logical OR. Also supports [mana] to only check on mana classes. Example: Arcane Intellect[mana]/Arcane Brilliance[mana];Dampen Magic"],
							type = "input",
							order = 4,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "dispel" end,
							validate = validateMissingBuffInput,
						},
						timer = {
							name = L["Timer"],
							desc = string.format(L["Enable or disable the %s."],L["Timer"]),
							type = "toggle",
							order = 5,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "missing" end,
						},
						texture = {
							name = L["Texture"],
							desc = L["Show the spell texture instead of its type color."],
							type = "toggle",
							order = 6,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" end,
						},
					},
				},
				rightcenter = {
					name = L["Right Center"],
					type = "group",
					order = 6,
					inline = true,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],L["Right Center"]),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 4,
							max = 40,
							step = 1,
						},
						type = {
							name = L["Type"],
							desc = L["What the indicator should display."],
							type = "select",
							order = 3,
							values = { ["aggro"] = L["Aggro"], ["legacythreat"] = L["Aggro"].." ("..L["targettarget"]..")", ["aura"] = L["Buff/Debuff"], ["ownaura"] = L["Own buff/debuff"], ["dispel"] = DISPELS, ["missing"] = L["Missing Buff"] },
							set = function(info, value) set(info,value) ACR:NotifyChange("LunaUnitFrames") end,
						},
						value = {
							name = L["Name (exact) or ID"],
							desc = L["Name (exact) or ID of the effect to track. Use ; as a logical AND and / as logical OR. Also supports [mana] to only check on mana classes. Example: Arcane Intellect[mana]/Arcane Brilliance[mana];Dampen Magic"],
							type = "input",
							order = 4,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "dispel" end,
							validate = validateMissingBuffInput,
						},
						timer = {
							name = L["Timer"],
							desc = string.format(L["Enable or disable the %s."],L["Timer"]),
							type = "toggle",
							order = 5,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "missing" end,
						},
						texture = {
							name = L["Texture"],
							desc = L["Show the spell texture instead of its type color."],
							type = "toggle",
							order = 6,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" end,
						},
					},
				},
				bottomleft = {
					name = L["Bottom left"],
					type = "group",
					order = 7,
					inline = true,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],L["Bottom left"]),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 4,
							max = 40,
							step = 1,
						},
						type = {
							name = L["Type"],
							desc = L["What the indicator should display."],
							type = "select",
							order = 3,
							values = { ["aggro"] = L["Aggro"], ["legacythreat"] = L["Aggro"].." ("..L["targettarget"]..")", ["aura"] = L["Buff/Debuff"], ["ownaura"] = L["Own buff/debuff"], ["dispel"] = DISPELS, ["missing"] = L["Missing Buff"] },
							set = function(info, value) set(info,value) ACR:NotifyChange("LunaUnitFrames") end,
						},
						value = {
							name = L["Name (exact) or ID"],
							desc = L["Name (exact) or ID of the effect to track. Use ; as a logical AND and / as logical OR. Also supports [mana] to only check on mana classes. Example: Arcane Intellect[mana]/Arcane Brilliance[mana];Dampen Magic"],
							type = "input",
							order = 4,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "dispel" end,
							validate = validateMissingBuffInput,
						},
						timer = {
							name = L["Timer"],
							desc = string.format(L["Enable or disable the %s."],L["Timer"]),
							type = "toggle",
							order = 5,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "missing" end,
						},
						texture = {
							name = L["Texture"],
							desc = L["Show the spell texture instead of its type color."],
							type = "toggle",
							order = 6,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" end,
						},
					},
				},
				bottom = {
					name = L["Bottom"],
					type = "group",
					order = 8,
					inline = true,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],L["Bottom right"]),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 4,
							max = 40,
							step = 1,
						},
						type = {
							name = L["Type"],
							desc = L["What the indicator should display."],
							type = "select",
							order = 3,
							values = { ["aggro"] = L["Aggro"], ["legacythreat"] = L["Aggro"].." ("..L["targettarget"]..")", ["aura"] = L["Buff/Debuff"], ["ownaura"] = L["Own buff/debuff"], ["dispel"] = DISPELS, ["missing"] = L["Missing Buff"] },
							set = function(info, value) set(info,value) ACR:NotifyChange("LunaUnitFrames") end,
						},
						value = {
							name = L["Name (exact) or ID"],
							desc = L["Name (exact) or ID of the effect to track. Use ; as a logical AND and / as logical OR. Also supports [mana] to only check on mana classes. Example: Arcane Intellect[mana]/Arcane Brilliance[mana];Dampen Magic"],
							type = "input",
							order = 4,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "dispel" end,
							validate = validateMissingBuffInput,
						},
						timer = {
							name = L["Timer"],
							desc = string.format(L["Enable or disable the %s."],L["Timer"]),
							type = "toggle",
							order = 5,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "missing" end,
						},
						texture = {
							name = L["Texture"],
							desc = L["Show the spell texture instead of its type color."],
							type = "toggle",
							order = 6,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" end,
						},
					},
				},
				bottomright = {
					name = L["Bottom right"],
					type = "group",
					order = 9,
					inline = true,
					args = {
						enabled = {
							name = ENABLE,
							desc = string.format(L["Enable or disable the %s."],L["Bottom right"]),
							type = "toggle",
							order = 1,
						},
						size = {
							name = L["Size"],
							desc = L["Set the size."],
							type = "range",
							order = 2,
							min = 4,
							max = 40,
							step = 1,
						},
						type = {
							name = L["Type"],
							desc = L["What the indicator should display."],
							type = "select",
							order = 3,
							values = { ["aggro"] = L["Aggro"], ["legacythreat"] = L["Aggro"].." ("..L["targettarget"]..")", ["aura"] = L["Buff/Debuff"], ["ownaura"] = L["Own buff/debuff"], ["dispel"] = DISPELS, ["missing"] = L["Missing Buff"] },
							set = function(info, value) set(info,value) ACR:NotifyChange("LunaUnitFrames") end,
						},
						value = {
							name = L["Name (exact) or ID"],
							desc = L["Name (exact) or ID of the effect to track. Use ; as a logical AND and / as logical OR. Also supports [mana] to only check on mana classes. Example: Arcane Intellect[mana]/Arcane Brilliance[mana];Dampen Magic"],
							type = "input",
							order = 4,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "dispel" end,
							validate = validateMissingBuffInput,
						},
						timer = {
							name = L["Timer"],
							desc = string.format(L["Enable or disable the %s."],L["Timer"]),
							type = "toggle",
							order = 5,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "missing" end,
						},
						texture = {
							name = L["Texture"],
							desc = L["Show the spell texture instead of its type color."],
							type = "toggle",
							order = 6,
							hidden = function(info) return LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "aggro" or LUF.db.profile.units[info[#info-3]].squares[info[#info-1]].type == "legacythreat" end,
						},
					},
				},
			},
		},
		["xpBar"] = {
			name = L["Xp bar"],
			type = "group",
			order = -5,
			--inline = true,
			hidden = function(info) return not (info[1] == "player" or info[1] == "pet") end,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."],L["Xp bar"]),
					type = "toggle",
					order = 1,
				},
				background = {
					name = BACKGROUND,
					desc = string.format(L["Enable or disable the %s."], BACKGROUND),
					type = "toggle",
					order = 2,
				},
				backgroundAlpha = {
					name = L["Background alpha"],
					desc = L["Set the background alpha."],
					type = "range",
					order = 3,
					min = 0,
					max = 1,
					step = 0.01,
				},
				height = {
					name = L["Height"],
					desc = L["Set the height."],
					type = "range",
					order = 4,
					min = 1,
					max = 10,
					step = 0.1,
				},
				order = {
					name = L["Order"],
					desc = L["Set the order priority."],
					type = "range",
					order = 5,
					min = 0,
					max = 100,
					step = 5,
				},
				alpha = {
					name = OPACITY,
					desc = L["Set the alpha."],
					type = "range",
					order = 6,
					min = 0,
					max = 1,
					step = 0.01,
				},
				mouse = {
					name = L["Mouse interaction"],
					desc = L["This enables xp tooltips but disables clicks or vice versa"],
					type = "toggle",
					disabled = Lockdown,
					order = 7,
				},
				statusbar = {
					order = 8,
					type = "select",
					name = L["Bar texture"],
					dialogControl = "LSM30_Statusbar",
					values = getMediaData,
					get = function(info) return get(info) or LUF.db.profile.statusbar or SML.DefaultMedia.statusbar end,
				},
			},
		},
		["druidBar"] = {
			name = L["Druid bar"],
			type = "group",
			order = -4,
			--inline = true,
			hidden = function(info) return info[1] ~= "player" or select(2,UnitClass("player")) ~= "DRUID" end,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."],L["Druid bar"]),
					type = "toggle",
					order = 1,
				},
				autoHide = {
					name = L["Auto hide"],
					desc = string.format(L["Hide when inactive"]),
					type = "toggle",
					order = 2,
				},
				ticker = {
					name = L["Ticker"],
					desc = L["Since mana/energy regenerate in ticks, show a timer for it"],
					type = "toggle",
					order = 3,
				},
				hideticker = {
					name = L["Autohide ticker"],
					desc = L["Hide the ticker when it's not needed"],
					type = "toggle",
					order = 4,
				},
				fivesecond = {
					name = L["Five second rule"],
					desc = L["Show a timer for the five second rule"],
					type = "toggle",
					order = 5,
				},
				background = {
					name = BACKGROUND,
					desc = string.format(L["Enable or disable the %s."], BACKGROUND),
					type = "toggle",
					order = 6,
				},
				backgroundAlpha = {
					name = L["Background alpha"],
					desc = L["Set the background alpha."],
					type = "range",
					order = 7,
					min = 0,
					max = 1,
					step = 0.01,
				},
				height = {
					name = L["Height"],
					desc = L["Set the height."],
					type = "range",
					order = 8,
					min = 1,
					max = 10,
					step = 0.1,
				},
				order = {
					name = L["Order"],
					desc = L["Set the order priority."],
					type = "range",
					order = 9,
					min = 0,
					max = 100,
					step = 5,
				},
				statusbar = {
					order = 10,
					type = "select",
					name = L["Bar texture"],
					dialogControl = "LSM30_Statusbar",
					values = getMediaData,
					get = function(info) return get(info) or LUF.db.profile.statusbar or SML.DefaultMedia.statusbar end,
				},
				vertical = {
					name = L["Vertical"],
					desc = L["Set the bar vertical."],
					type = "toggle",
					order = 11,
				},
			},
		},
		["reckStacks"] = {
			name = L["Reckoning stacks"],
			type = "group",
			order = -3,
			--inline = true,
			hidden = function(info) return info[1] ~= "player" or select(2,UnitClass("player")) ~= "PALADIN" end,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."],L["Reckoning stacks"]),
					type = "toggle",
					order = 1,
				},
				autoHide = {
					name = L["Auto hide"],
					desc = string.format(L["Hide when inactive"]),
					type = "toggle",
					order = 3,
				},
				background = {
					name = BACKGROUND,
					desc = string.format(L["Enable or disable the %s."], BACKGROUND),
					type = "toggle",
					order = 4,
				},
				backgroundAlpha = {
					name = L["Background alpha"],
					desc = L["Set the background alpha."],
					type = "range",
					order = 5,
					min = 0,
					max = 1,
					step = 0.01,
				},
				height = {
					name = L["Height"],
					desc = L["Set the height."],
					type = "range",
					order = 6,
					min = 1,
					max = 10,
					step = 0.1,
				},
				order = {
					name = L["Order"],
					desc = L["Set the order priority."],
					type = "range",
					order = 7,
					min = 0,
					max = 100,
					step = 5,
				},
				growth = {
					name = L["Growth direction"],
					desc = L["Growth direction"],
					type = "select",
					order = 8,
					values = {["LEFT"] = L["Left"], ["RIGHT"] = L["Right"]},
				},
				statusbar = {
					order = 9,
					type = "select",
					name = L["Bar texture"],
					dialogControl = "LSM30_Statusbar",
					values = getMediaData,
					get = function(info) return get(info) or LUF.db.profile.statusbar or SML.DefaultMedia.statusbar end,
				},
			},
		},
		["totemBar"] = {
			name = L["Totem bar"],
			type = "group",
			order = -2,
			--inline = true,
			hidden = function(info) return info[1] ~= "player" or select(2,UnitClass("player")) ~= "SHAMAN" end,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."],L["Totem bar"]),
					type = "toggle",
					order = 1,
				},
				autoHide = {
					name = L["Auto hide"],
					desc = string.format(L["Hide when inactive"]),
					type = "toggle",
					order = 2,
				},
				background = {
					name = BACKGROUND,
					desc = string.format(L["Enable or disable the %s."], BACKGROUND),
					type = "toggle",
					order = 3,
				},
				backgroundAlpha = {
					name = L["Background alpha"],
					desc = L["Set the background alpha."],
					type = "range",
					order = 4,
					min = 0,
					max = 1,
					step = 0.01,
				},
				height = {
					name = L["Height"],
					desc = L["Set the height."],
					type = "range",
					order = 5,
					min = 1,
					max = 10,
					step = 0.1,
				},
				order = {
					name = L["Order"],
					desc = L["Set the order priority."],
					type = "range",
					order = 6,
					min = 0,
					max = 100,
					step = 5,
				},
				statusbar = {
					order = 7,
					type = "select",
					name = L["Bar texture"],
					dialogControl = "LSM30_Statusbar",
					values = getMediaData,
					get = function(info) return get(info) or LUF.db.profile.statusbar or SML.DefaultMedia.statusbar end,
				},
			},
		},
		["comboPoints"] = {
			name = COMBO_POINTS,
			type = "group",
			order = -1,
			--inline = true,
			hidden = function(info) return (info[1] ~= "target" and info[1] ~= "player") or (select(2,UnitClass("player")) ~= "ROGUE" and select(2,UnitClass("player")) ~= "DRUID") end,
			args = {
				enabled = {
					name = ENABLE,
					desc = string.format(L["Enable or disable the %s."],COMBO_POINTS),
					type = "toggle",
					order = 1,
				},
				autoHide = {
					name = L["Auto hide"],
					desc = L["Hide when inactive"],
					type = "toggle",
					order = 2,
				},
				growth = {
					name = L["Growth direction"],
					desc = L["Growth direction"],
					type = "select",
					order = 3,
					values = {["LEFT"] = L["Left"], ["RIGHT"] = L["Right"]},
				},
				background = {
					name = BACKGROUND,
					desc = string.format(L["Enable or disable the %s."], BACKGROUND),
					type = "toggle",
					order = 4,
				},
				backgroundAlpha = {
					name = L["Background alpha"],
					desc = L["Set the background alpha."],
					type = "range",
					order = 5,
					min = 0,
					max = 1,
					step = 0.01,
				},
				height = {
					name = L["Height"],
					desc = L["Set the height."],
					type = "range",
					order = 6,
					min = 1,
					max = 10,
					step = 0.1,
				},
				order = {
					name = L["Order"],
					desc = L["Set the order priority."],
					type = "range",
					order = 7,
					min = 0,
					max = 100,
					step = 5,
				},
				statusbar = {
					order = 8,
					type = "select",
					name = L["Bar texture"],
					dialogControl = "LSM30_Statusbar",
					values = getMediaData,
					get = function(info) return get(info) or LUF.db.profile.statusbar or SML.DefaultMedia.statusbar end,
				},
			},
		},
	}

	local aceoptions = {
		name = "Luna Unit Frames",
		type = "group",
		get = get,
		set = set,
		icon = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\icon",
		args = {
			general = {
				name = GENERAL,
				type = "group",
				order = 1,
				get = getGeneral,
				set = setGeneral,
				args = {
					description = {
						name = "",
						type = "description",
						image = "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\icon",
						imageWidth = 64,
						imageHeight = 64,
						width = "half",
						order = 1,
					},
					descriptiontext = {
						name = "Luna Unit Frames by Aviana\nDonate: paypal.me/LunaUnitFrames\n".."Version: "..LUF.version,
						type = "description",
						width = "full",
						order = 2,
					},
					header = {
						name = L["Global Settings"],
						type = "header",
						width = "double",
						order = 3,
					},
					locked = {
						name = L["Lock"],
						desc = LOCK_FOCUS_FRAME,
						type = "toggle",
						order = 4,
						disabled = Lockdown,
						set = function(info, value) setGeneral(info, value) LUF:UpdateMovers() end,
					},
					previewauras = {
						name = L["Preview Auras"],
						desc = L["Show the maximum Auras in preview mode"],
						type = "toggle",
						order = 5,
						disabled = Lockdown,
						set = function(info, value) setGeneral(info, value) LUF:ReloadAll() end
					},
					tooltipCombat = {
						name = L["Tooltip in Combat"],
						desc = L["Show unitframe tooltips in combat"],
						type = "toggle",
						order = 6,
					},
					headerGlobalSettings = {
						name = L["Global Unit Settings"],
						type = "header",
						order = 7,
					},
					statusbar = {
						order = 8,
						type = "select",
						name = L["Bar texture"],
						dialogControl = "LSM30_Statusbar",
						values = getMediaData,
						confirm = function(info) return L["WARNING! This will set ALL bars to this texture."] end,
						set = function(info, value) wipeTextures() setGeneral(info, value) LUF:ReloadAll() end,
						get = function(info) return LUF.db.profile.statusbar or SML.DefaultMedia.statusbar end,
					},
					font = {
						order = 9,
						type = "select",
						name = L["Font"],
						dialogControl = "LSM30_Font",
						values = getMediaData,
						confirm = function(info) return L["WARNING! This will set ALL texts to this font."] end,
						set = function(info, value) wipeFonts() setGeneral(info, value) LUF:ReloadAll() end,
						get = function(info) return LUF.db.profile.font or SML.DefaultMedia.font end,
					},
					auraborderType = {
						order = 10,
						type = "select",
						name = L["Aura border"],
						values = {["none"] = NONE, ["blizzard"] = "Blizzard", ["light"] = L["Light"], ["dark"] = L["Dark"], ["black"] = L["Black"], ["light-thin"] = L["Light thin"], ["dark-thin"] = L["Dark thin"], ["black-thin"] = L["Black thin"]},
						set = function(info, value) setGeneral(info, value) LUF:ReloadAll() end,
					},
					inchealTime = {
						name = L["Heal prediction timeframe"],
						desc = L["Set how long into the future heals are predicted."],
						type = "range",
						order = 11,
						min = 3,
						max = 21,
						step = 0.5,
						set = function(info, value) setGeneral(info, value) LUF:LoadoUFSettings() LUF:ReloadAll() end,
					},
					disablehots = {
						name = L["Disable hots"],
						desc = L["Disable hots in heal prediction"],
						type = "toggle",
						order = 12,
						set = function(info, value) setGeneral(info, value) LUF:LoadoUFSettings() LUF:ReloadAll() end,
					},
					omnicc = {
						name = L["Disable OmniCC"],
						desc = L["Prevent OmniCC from putting numbers on cooldown animations (Requires UI reload)"],
						type = "toggle",
						order = 13,
						disabled = Lockdown,
						set = function(info, value) setGeneral(info, value) LUF:ReloadAll() end,
					},
					blizzardcc = {
						name = L["Disable Blizzard cooldown count"],
						desc = L["Prevent the default UI from putting numbers on cooldown animations"],
						type = "toggle",
						order = 14,
						disabled = Lockdown,
						set = function(info, value) setGeneral(info, value) LUF:ReloadAll() end,
					},
					headerRange = {
						name = L["Range"],
						type = "header",
						order = 15,
					},
					range = {
						name = L["Distance"],
						desc = L["Distance to measure"],
						type = "select",
						order = 16,
						values = {[10] = L["Inspect distance"], [30] = L["Follow distance"], [40] = L["Spell based"], [100] = L["Is Visible"], },
						get = function(info) return LUF.db.profile.range.dist end,
						set = function(info, value) LUF.db.profile.range.dist = value LUF:ReloadAll() end,
					},
					alpha = {
						name = OPACITY,
						desc = L["Set the alpha."],
						type = "range",
						order = 17,
						min = 0,
						max = 1,
						step = 0.01,
						get = function(info) return LUF.db.profile.range.alpha end,
						set = function(info, value) LUF.db.profile.range.alpha = value LUF:ReloadAll() end,
					},
				},
			},
			colors = {
				name = COLORS,
				type = "group",
				order = 2,
				get = getColor,
				set = setColor,
				childGroups = "tab",
				args = {
					ResetColors = {
						name = L["Reset Colors"],
						type = "execute",
						func = function(info) LUF:ResetColors() end,
						confirm = function(info) return L["WARNING! This will set ALL colors back to default."] end,
						order = 1,
					},
					ClassColors = {
						name = CLASS_COLORS,
						type = "group",
						order = 2,
						args = {
							HUNTER = {
								name = LOCALIZED_CLASS_NAMES_MALE["HUNTER"],
								type = "color",
								order = 1,
							},
							WARLOCK = {
								name = LOCALIZED_CLASS_NAMES_MALE["WARLOCK"],
								type = "color",
								order = 2,
							},
							PRIEST = {
								name = LOCALIZED_CLASS_NAMES_MALE["PRIEST"],
								type = "color",
								order = 3,
							},
							PALADIN = {
								name = LOCALIZED_CLASS_NAMES_MALE["PALADIN"],
								type = "color",
								order = 4,
							},
							MAGE = {
								name = LOCALIZED_CLASS_NAMES_MALE["MAGE"],
								type = "color",
								order = 5,
							},
							ROGUE = {
								name = LOCALIZED_CLASS_NAMES_MALE["ROGUE"],
								type = "color",
								order = 6,
							},
							DRUID = {
								name = LOCALIZED_CLASS_NAMES_MALE["DRUID"],
								type = "color",
								order = 7,
							},
							SHAMAN = {
								name = LOCALIZED_CLASS_NAMES_MALE["SHAMAN"],
								type = "color",
								order = 8,
							},
							WARRIOR = {
								name = LOCALIZED_CLASS_NAMES_MALE["WARRIOR"],
								type = "color",
								order = 9,
							},
						},
					},
					PowerColors = {
						name = L["Power Type"],
						type = "group",
						order = 2,
						args = {
							MANA = {
								name = MANA,
								type = "color",
								order = 1,
							},
							RAGE = {
								name = RAGE,
								type = "color",
								order = 2,
							},
							FOCUS = {
								name = FOCUS,
								type = "color",
								order = 3,
							},
							ENERGY = {
								name = ENERGY,
								type = "color",
								order = 4,
							},
							COMBOPOINTS = {
								name = COMBO_POINTS,
								type = "color",
								order = 5,
							},
						},
					},
					GradientColors = {
						name = L["Gradient Colors"],
						type = "group",
						order = 3,
						args = {
							red = {
								name = L["Red"],
								type = "color",
								order = 1,
							},
							yellow = {
								name = L["Yellow"],
								type = "color",
								order = 2,
							},
							green = {
								name = L["Green"],
								type = "color",
								order = 3,
							},
						},
					},
					HappinessColors = {
						name = HAPPINESS,
						type = "group",
						order = 4,
						args = {
							unhappy = {
								name = PET_HAPPINESS1,
								type = "color",
								order = 1,
							},
							content = {
								name = PET_HAPPINESS2,
								type = "color",
								order = 2,
							},
							happy = {
								name = PET_HAPPINESS3,
								type = "color",
								order = 3,
							},
						},
					},
					ReactionColors = {
						name = L["Reaction Colors"],
						type = "group",
						order = 5,
						args = {
							hated = {
								name = FACTION_STANDING_LABEL1,
								type = "color",
								order = 1,
							},
							hostile = {
								name = FACTION_STANDING_LABEL2,
								type = "color",
								order = 2,
							},
							unfriendly = {
								name = FACTION_STANDING_LABEL3,
								type = "color",
								order = 3,
							},
							neutral = {
								name = FACTION_STANDING_LABEL4,
								type = "color",
								order = 4,
							},
							friendly = {
								name = FACTION_STANDING_LABEL5,
								type = "color",
								order = 5,
							},
							honored = {
								name = FACTION_STANDING_LABEL6,
								type = "color",
								order = 6,
							},
							revered = {
								name = FACTION_STANDING_LABEL7,
								type = "color",
								order = 7,
							},
							exalted = {
								name = FACTION_STANDING_LABEL8,
								type = "color",
								order = 8,
							},
						},
					},
					StatusColors = {
						name = L["Status Colors"],
						type = "group",
						order = 6,
						args = {
							static = {
								name = L["Static"],
								type = "color",
								order = 1,
							},
							enemyCivilian = {
								name = L["Enemy civilian"],
								type = "color",
								order = 2,
							},
							tapped = {
								name = L["Tapped"],
								type = "color",
								order = 3,
							},
							offline = {
								name = FRIENDS_LIST_OFFLINE,
								type = "color",
								order = 4,
							},
						},
					},
					HealColors = {
						name = L["Incoming heals"],
						type = "group",
						order = 7,
						args = {
							incheal = {
								name = L["Incoming heals"],
								type = "color",
								order = 1,
							},
							incownheal = {
								name = L["Inc Own Heal"],
								type = "color",
								order = 2,
							},
							inchots = {
								name = L["Inc Hots"],
								type = "color",
								order = 3,
							},
						},
					},
					CastColors = {
						name = SPELL_CASTING ,
						type = "group",
						order = 8,
						args = {
							channel = {
								name = CHANNELING,
								type = "color",
								order = 1,
							},
							cast = {
								name = SPELL_CASTING,
								type = "color",
								order = 2,
							},
						},
					},
					XPColors = {
						name = L["XP Colors"],
						type = "group",
						order = 9,
						args = {
							normal = {
								name = VOICE_CHAT_NORMAL,
								type = "color",
								order = 1,
							},
							rested = {
								name = TUTORIAL_TITLE26,
								type = "color",
								order = 2,
							},
						},
					},
					miscColors = {
						name = L["Misc Colors"],
						type = "group",
						order = 10,
						args = {
							background = {
								name = BACKGROUND,
								type = "color",
								order = 1,
								hasAlpha = true,
								set = setBGColor,
							},
							mouseover = {
								name = L["Mouseover"],
								type = "color",
								order = 2,
							},
							target = {
								name = TARGET,
								type = "color",
								order = 3,
							},
						},
					},
				},
			},
			player = {
				name = PLAYER,
				type = "group",
				order = 3,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], PLAYER),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						set = function(info, value) set(info, value) LUF:PlaceFrame(_G["LUFUnitplayer"]) end,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.4,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.5,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
						},
					},
				},
			},
			pet = {
				name = PET,
				type = "group",
				order = 4,
				arg = LUF.db.profile.units.pet,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], PET),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						set = function(info, value) set(info, value) LUF:PlaceFrame(_G["LUFUnitpet"]) end,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.4,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.5,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
						},
					},
				},
			},
			pettarget = {
				name = L["pettarget"],
				type = "group",
				order = 5,
				arg = LUF.db.profile.units.pettarget,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], L["pettarget"]),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						set = function(info, value) set(info, value) LUF:PlaceFrame(_G["LUFUnitpettarget"]) end,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.4,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.5,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
						},
					},
				},
			},
			pettargettarget = {
				name = L["pettargettarget"],
				type = "group",
				order = 5,
				arg = LUF.db.profile.units.pettargettarget,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], L["pettargettarget"]),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						set = function(info, value) set(info, value) LUF:PlaceFrame(_G["LUFUnitpettargettarget"]) end,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.4,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.5,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
						},
					},
				},
			},
			target = {
				name = TARGET,
				type = "group",
				order = 7,
				arg = LUF.db.profile.units.target,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], TARGET),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						set = function(info, value) set(info, value) LUF:PlaceFrame(_G["LUFUnittarget"]) end,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.4,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.5,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							sound = {
								name = L["Targeting sound"],
								desc = L["Enable the sound when switching target"],
								type = "toggle",
								order = 2.7,
							},
						},
					},
				},
			},
			targettarget = {
				name = L["targettarget"],
				type = "group",
				order = 8,
				arg = LUF.db.profile.units.targettarget,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], L["targettarget"]),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						set = function(info, value) set(info, value) LUF:PlaceFrame(_G["LUFUnittargettarget"]) end,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.4,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.5,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
						},
					},
				},
			},
			targettargettarget = {
				name = L["targettargettarget"],
				type = "group",
				order = 9,
				arg = LUF.db.profile.units.targettargettarget,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], L["targettargettarget"]),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						set = function(info, value) set(info, value) LUF:PlaceFrame(_G["LUFUnittargettargettarget"]) end,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.4,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.5,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
						},
					},
				},
			},
			party = {
				name = PARTY,
				type = "group",
				order = 10,
				arg = LUF.db.profile.units.party,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], PARTY),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
								set = setHeader,
							},
							offset = {
								name = L["Offset"],
								desc = L["Set the space between units."],
								type = "range",
								order = 2.4,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.5,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.7,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							attribPoint = {
								name = L["Growth direction"],
								desc = L["The direction in which new frames are added."],
								type = "select",
								order = 2.8,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								set = setGrowthDir,
								disabled = Lockdown,
							},
							hideraid = {
								name = L["Hide in raid"],
								desc = L["Hide while in a raid group."],
								type = "select",
								order = 2.9,
								values = {["never"] = L["Never"],["5man"] = L["Raid > 5 man"],["always"] = L["Any Raid"]},
								set = setHideRaid,
								disabled = Lockdown,
							},
							sortMethod = {
								name = L["Sort by"],
								desc = L["Sort by name or index"],
								type = "select",
								order = 2.91,
								values = {["INDEX"] = L["Index"],["NAME"] = NAME},
								set = setSortMethod,
								disabled = Lockdown,
							},
							sortOrder = {
								name = L["Sort order"],
								desc = L["Sort ascending or descending"],
								type = "select",
								order = 2.92,
								values = {["ASC"] = L["Ascending"],["DESC"] = L["Descending"]},
								set = setSortOrder,
								disabled = Lockdown,
							},
							showPlayer = {
								name = L["Show player"],
								desc = L["Show player in the party frame."],
								type = "toggle",
								order = 2.93,
								disabled = function(info) return Lockdown() or LUF.db.profile.units.party.showSolo end,
								get = function(info) return LUF.db.profile.units.party.showSolo or get(info) end,
								set = function(info, value)
									LUF.db.profile.units.party.showPlayer = value
									LUF.db.profile.units.partytarget.showPlayer = value
									LUF.db.profile.units.partypet.showPlayer = value
									LUF:SetupHeader("party")
									LUF:SetupHeader("partytarget")
									LUF:SetupHeader("partypet")
								end,
							},
							showSolo = {
								name = L["Show solo"],
								desc = L["Show player in the party frame when solo."],
								type = "toggle",
								order = 2.94,
								disabled = Lockdown,
								set = function(info, value)
									LUF.db.profile.units.party.showSolo = value
									LUF.db.profile.units.partytarget.showSolo = value
									LUF.db.profile.units.partypet.showSolo = value
									LUF:SetupHeader("party")
									LUF:SetupHeader("partytarget")
									LUF:SetupHeader("partypet")
									ACR:NotifyChange("LunaUnitFrames")
								end,
							},
						},
					},
				},
			},
			partytarget = {
				name = L["partytarget"],
				type = "group",
				order = 11,
				arg = LUF.db.profile.units.partytarget,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], L["partytarget"]),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
								set = setHeader,
							},
							offset = {
								name = L["Offset"],
								desc = L["Set the space between units."],
								type = "range",
								order = 2.4,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.5,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.7,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							attribPoint = {
								name = L["Growth direction"],
								desc = string.format(L["This is set through %s options."],PARTY),
								type = "select",
								order = 2.8,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								get = function(info) return LUF.db.profile.units["party"].attribPoint end,
								disabled = true,
							},
							hideraid = {
								name = L["Hide in raid"],
								desc = string.format(L["This is set through %s options."],PARTY),
								type = "select",
								order = 2.9,
								values = {["never"] = L["Never"],["5man"] = L["Raid > 5 man"],["always"] = L["Any Raid"]},
								get = function() return LUF.db.profile.units.party.hideraid end,
								set = setHideRaid,
								disabled = true,
							},
							sortMethod = {
								name = L["Sort by"],
								desc = string.format(L["This is set through %s options."],PARTY),
								type = "select",
								order = 2.91,
								values = {["INDEX"] = L["Index"],["NAME"] = NAME},
								set = setSortMethod,
								disabled = true,
							},
							sortOrder = {
								name = L["Sort order"],
								desc = string.format(L["This is set through %s options."],PARTY),
								type = "select",
								order = 2.92,
								values = {["ASC"] = L["Ascending"],["DESC"] = L["Descending"]},
								set = setSortOrder,
								disabled = true,
							},
						},
					},
				},
			},
			partypet = {
				name = L["partypet"],
				type = "group",
				order = 12,
				arg = LUF.db.profile.units.partypet,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], L["partypet"]),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
								set = setHeader,
							},
							offset = {
								name = L["Offset"],
								desc = L["Set the space between units."],
								type = "range",
								order = 2.4,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.5,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.7,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							attribPoint = {
								name = L["Growth direction"],
								desc = string.format(L["This is set through %s options."],PARTY),
								type = "select",
								order = 2.8,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								get = function(info) return LUF.db.profile.units["party"].attribPoint end,
								disabled = true,
							},
							hideraid = {
								name = L["Hide in raid"],
								desc = string.format(L["This is set through %s options."],PARTY),
								type = "select",
								order = 2.9,
								values = {["never"] = L["Never"],["5man"] = L["Raid > 5 man"],["always"] = L["Any Raid"]},
								get = function() return LUF.db.profile.units.party.hideraid end,
								set = setHideRaid,
								disabled = true,
							},
							sortMethod = {
								name = L["Sort by"],
								desc = string.format(L["This is set through %s options."],PARTY),
								type = "select",
								order = 2.91,
								values = {["INDEX"] = L["Index"],["NAME"] = NAME},
								set = setSortMethod,
								disabled = true,
							},
							sortOrder = {
								name = L["Sort order"],
								desc = string.format(L["This is set through %s options."],PARTY),
								type = "select",
								order = 2.92,
								values = {["ASC"] = L["Ascending"],["DESC"] = L["Descending"]},
								set = setSortOrder,
								disabled = true,
							},
						},
					},
				},
			},
			raid = {
				name = RAID,
				type = "group",
				order = 13,
				arg = LUF.db.profile.units.raid,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], RAID),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
								set = setHeader,
							},
							offset = {
								name = L["Offset"],
								desc = L["Set the space between units."],
								type = "range",
								order = 2.31,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
							attribPoint = {
								name = L["Growth direction"],
								desc = L["The direction in which new frames are added."],
								type = "select",
								order = 2.32,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								set = setGrowthDir,
								disabled = Lockdown,
							},
							groupBy = {
								name = L["Group by"],
								desc = L["Group by class or group"],
								type = "select",
								order = 2.33,
								values = {["GROUP"] = GROUP,["CLASS"] = CLASS},
								disabled = Lockdown,
								set = setHeader,
							},
							sortMethod = {
								name = L["Sort by"],
								desc = L["Sort by name or index"],
								type = "select",
								order = 2.331,
								values = {["INDEX"] = L["Index"],["NAME"] = NAME},
								set = setSortMethod,
								disabled = Lockdown,
							},
							sortOrder = {
								name = L["Sort order"],
								desc = L["Sort ascending or descending"],
								type = "select",
								order = 2.332,
								values = {["ASC"] = L["Ascending"],["DESC"] = L["Descending"]},
								set = setSortOrder,
								disabled = Lockdown,
							},
							showWhen = {
								name = L["Show when"],
								desc = L["Show even smaller groups than a raid in the raidframe"],
								type = "select",
								order = 2.34,
								values = {["ALWAYS"] = ALWAYS,["PARTY"] = PARTY, ["RAID"] = RAID},
								get = getShowWhen,
								set = setShowWhen,
								disabled = Lockdown,
							},
							groupnumbers = {
								name = L["Groupnumbers"],
								desc = L["Show Groupnumbers next to the group"],
								type = "toggle",
								order = 2.36,
								disabled = Lockdown,
								set = function(info, value) set(info,value) LUF:SetupHeader("raid") LUF:SetupHeader("raidpet") end,
							},
							fontsize = {
								name = FONT_SIZE,
								desc = L["Set the size of the group number."],
								type = "range",
								order = 2.37,
								min = 1,
								max = 20,
								step = 1,
								disabled = Lockdown,
								set = function(info, value) set(info,value) LUF:SetupHeader("raid") LUF:SetupHeader("raidpet") end,
							},
							font = {
								order = 2.38,
								type = "select",
								name = L["Groupnumberfont"],
								dialogControl = "LSM30_Font",
								values = getMediaData,
								get = function(info) return get(info) or LUF.db.profile.font or SML.DefaultMedia.font end,
								set = function(info, value) set(info,value) LUF:SetupHeader("raid") LUF:SetupHeader("raidpet") end,
							},
							headerraid1 = {
								name = RAID.."1",
								type = "header",
								order = 2.41,
							},
							enabled1 = {
								name = ENABLE,
								desc = L["Enable this group"],
								type = "toggle",
								order = 2.411,
								width = "half",
								disabled = Lockdown,
								set = function(info, value) LUF.db.profile.units.raid.filters[1] = value LUF:SetupHeader("raid1") LUF:UpdateMovers() end,
								get = function(info, value) return LUF.db.profile.units.raid.filters[1] end,
							},
							raid1 = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.412,
								values = getAnchors,
								get = function() return LUF.db.profile.units.raid.positions[1].anchorTo end,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x1 = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.413,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[1].x) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[1].x = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid1"]) end,
								disabled = Lockdown,
							},
							y1 = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.414,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[1].y) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[1].y = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid1"]) end,
								disabled = Lockdown,
							},
							headerraid2 = {
								name = RAID.."2",
								type = "header",
								order = 2.42,
							},
							enabled2 = {
								name = ENABLE,
								desc = L["Enable this group"],
								type = "toggle",
								order = 2.421,
								width = "half",
								disabled = Lockdown,
								set = function(info, value) LUF.db.profile.units.raid.filters[2] = value LUF:SetupHeader("raid2") LUF:UpdateMovers() end,
								get = function(info, value) return LUF.db.profile.units.raid.filters[2] end,
							},
							raid2 = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.422,
								values = getAnchors,
								get = function() return LUF.db.profile.units.raid.positions[2].anchorTo end,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x2 = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.423,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[2].x) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[2].x = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid2"]) end,
								disabled = Lockdown,
							},
							y2 = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.424,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[2].y) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[2].y = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid2"]) end,
								disabled = Lockdown,
							},
							headerraid3 = {
								name = RAID.."3",
								type = "header",
								order = 2.43,
							},
							enabled3 = {
								name = ENABLE,
								desc = L["Enable this group"],
								type = "toggle",
								order = 2.431,
								width = "half",
								disabled = Lockdown,
								set = function(info, value) LUF.db.profile.units.raid.filters[3] = value LUF:SetupHeader("raid3") LUF:UpdateMovers() end,
								get = function(info, value) return LUF.db.profile.units.raid.filters[3] end,
							},
							raid3 = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.432,
								values = getAnchors,
								get = function() return LUF.db.profile.units.raid.positions[3].anchorTo end,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x3 = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.433,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[3].x) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[3].x = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid3"]) end,
								disabled = Lockdown,
							},
							y3 = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.434,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[3].y) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[3].y = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid3"]) end,
								disabled = Lockdown,
							},
							headerraid4 = {
								name = RAID.."4",
								type = "header",
								order = 2.44,
							},
							enabled4 = {
								name = ENABLE,
								desc = L["Enable this group"],
								type = "toggle",
								order = 2.441,
								width = "half",
								disabled = Lockdown,
								set = function(info, value) LUF.db.profile.units.raid.filters[4] = value LUF:SetupHeader("raid4") LUF:UpdateMovers() end,
								get = function(info, value) return LUF.db.profile.units.raid.filters[4] end,
							},
							raid4 = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.442,
								values = getAnchors,
								get = function() return LUF.db.profile.units.raid.positions[4].anchorTo end,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x4 = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.443,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[4].x) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[4].x = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid4"]) end,
								disabled = Lockdown,
							},
							y4 = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.444,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[4].y) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[4].y = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid4"]) end,
								disabled = Lockdown,
							},
							headerraid5 = {
								name = RAID.."5",
								type = "header",
								order = 2.45,
							},
							enabled5 = {
								name = ENABLE,
								desc = L["Enable this group"],
								type = "toggle",
								order = 2.451,
								width = "half",
								disabled = Lockdown,
								set = function(info, value) LUF.db.profile.units.raid.filters[5] = value LUF:SetupHeader("raid5") LUF:UpdateMovers() end,
								get = function(info, value) return LUF.db.profile.units.raid.filters[5] end,
							},
							raid5 = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.452,
								values = getAnchors,
								get = function() return LUF.db.profile.units.raid.positions[5].anchorTo end,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x5 = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.453,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[5].x) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[5].x = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid5"]) end,
								disabled = Lockdown,
							},
							y5 = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.454,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[5].y) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[5].y = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid5"]) end,
								disabled = Lockdown,
							},
							headerraid6 = {
								name = RAID.."6",
								type = "header",
								order = 2.46,
							},
							enabled6 = {
								name = ENABLE,
								desc = L["Enable this group"],
								type = "toggle",
								order = 2.461,
								width = "half",
								disabled = Lockdown,
								set = function(info, value) LUF.db.profile.units.raid.filters[6] = value LUF:SetupHeader("raid6") LUF:UpdateMovers() end,
								get = function(info, value) return LUF.db.profile.units.raid.filters[6] end,
							},
							raid6 = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.462,
								values = getAnchors,
								get = function() return LUF.db.profile.units.raid.positions[6].anchorTo end,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x6 = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.463,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[6].x) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[6].x = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid6"]) end,
								disabled = Lockdown,
							},
							y6 = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.464,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[6].y) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[6].y = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid6"]) end,
								disabled = Lockdown,
							},
							headerraid7 = {
								name = RAID.."7",
								type = "header",
								order = 2.47,
							},
							enabled7 = {
								name = ENABLE,
								desc = L["Enable this group"],
								type = "toggle",
								order = 2.471,
								width = "half",
								disabled = Lockdown,
								set = function(info, value) LUF.db.profile.units.raid.filters[7] = value LUF:SetupHeader("raid7") LUF:UpdateMovers() end,
								get = function(info, value) return LUF.db.profile.units.raid.filters[7] end,
							},
							raid7 = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.472,
								values = getAnchors,
								get = function() return LUF.db.profile.units.raid.positions[7].anchorTo end,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x7 = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.473,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[7].x) end,
								set =  function(info, value) LUF.db.profile.units.raid.positions[7].x = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid7"]) end,
								disabled = Lockdown,
							},
							y7 = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.474,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[7].y) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[7].y = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid7"]) end,
								disabled = Lockdown,
							},
							headerraid8 = {
								name = RAID.."8",
								type = "header",
								order = 2.48,
							},
							enabled8 = {
								name = ENABLE,
								desc = L["Enable this group"],
								type = "toggle",
								order = 2.481,
								width = "half",
								disabled = Lockdown,
								set = function(info, value) LUF.db.profile.units.raid.filters[8] = value LUF:SetupHeader("raid8") LUF:UpdateMovers() end,
								get = function(info, value) return LUF.db.profile.units.raid.filters[8] end,
							},
							raid8 = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.482,
								values = getAnchors,
								get = function() return LUF.db.profile.units.raid.positions[8].anchorTo end,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x8 = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.483,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[8].x) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[8].x = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid8"]) end,
								disabled = Lockdown,
							},
							y8 = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.484,
								width = 0.8,
								validate = nbrValidate,
								get = function() return tostring(LUF.db.profile.units.raid.positions[8].y) end,
								set = function(info, value) LUF.db.profile.units.raid.positions[8].y = tonumber(value) LUF:PlaceFrame(LUF.frameIndex["raid8"]) end,
								disabled = Lockdown,
							},
						},
					},
				},
			},
			raidpet = {
				name = L["raidpet"],
				type = "group",
				order = 14,
				arg = LUF.db.profile.units.raidpet,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], L["raidpet"]),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 2.1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2.2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 2.3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
								set = setHeader,
							},
							offset = {
								name = L["Offset"],
								desc = L["Set the space between units."],
								type = "range",
								order = 2.4,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 2.5,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 2.7,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							attribPoint = {
								name = L["Growth direction"],
								desc = string.format(L["This is set through %s options."],RAID),
								type = "select",
								order = 2.8,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								get = function(info) return LUF.db.profile.units["raid"].attribPoint end,
								set = setGrowthDir,
								disabled = true,
							},
							sortMethod = {
								name = L["Sort by"],
								desc = L["Sort by name or index"],
								type = "select",
								order = 2.9,
								values = {["INDEX"] = L["Index"],["NAME"] = NAME},
								set = setSortMethod,
								disabled = Lockdown,
							},
							sortOrder = {
								name = L["Sort order"],
								desc = L["Sort ascending or descending"],
								type = "select",
								order = 2.91,
								values = {["ASC"] = L["Ascending"],["DESC"] = L["Descending"]},
								set = setSortOrder,
								disabled = Lockdown,
							},
							showWhen = {
								name = L["Show when"],
								desc = string.format(L["This is set through %s options."],RAID),
								type = "select",
								order = 2.92,
								values = {["ALWAYS"] = ALWAYS,["PARTY"] = PARTY, ["RAID"] = RAID},
								get = getShowWhen,
								set = function(info,value) end,
								disabled = true,
							},
							unitsPerColumn = {
								name = L["Units per column"],
								desc = L["The amount of units until a new column is started"],
								type = "range",
								order = 2.93,
								min = 1,
								max = 40,
								step = 1,
								disabled = Lockdown,
								set = function(info, value) set(info,value) LUF:SetupHeader("raidpet") end,
							},
							maxColumns = {
								name = L["Max columns"],
								desc = L["The maximum amount of columns"],
								type = "range",
								order = 2.94,
								min = 1,
								max = 40,
								step = 1,
								disabled = Lockdown,
								set = function(info, value) set(info,value) LUF:SetupHeader("raidpet") end,
							},
							columnSpacing = {
								name = L["Column spacing"],
								desc = L["The space between each column"],
								type = "range",
								order = 2.95,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = function(info, value) set(info,value) LUF:SetupHeader("raidpet") end,
							},
							attribAnchorPoint = {
								name = L["Column Growth direction"],
								desc = L["Where a new column is started"],
								type = "select",
								order = 2.96,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								get = function(info) return LUF.db.profile.units["raidpet"].attribAnchorPoint end,
								set = function(info, value) LUF.db.profile.units["raidpet"].attribAnchorPoint = value LUF:SetupHeader("raidpet") end,
								disabled = Lockdown,
							},
						},
					},
				},
			},
			maintank = {
				name = MAINTANK,
				type = "group",
				order = 15,
				arg = LUF.db.profile.units.maintank,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], MAINTANK),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
								set = setHeader,
							},
							offset = {
								name = L["Offset"],
								desc = L["Set the space between units."],
								type = "range",
								order = 4,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 5,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 7,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							attribPoint = {
								name = L["Growth direction"],
								desc = L["The direction in which new frames are added."],
								type = "select",
								order = 8,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								set = setGrowthDir,
								disabled = Lockdown,
							},
							sortMethod = {
								name = L["Sort by"],
								desc = L["Sort by name or index"],
								type = "select",
								order = 9,
								values = {["INDEX"] = L["Index"],["NAME"] = NAME},
								set = setSortMethod,
								disabled = Lockdown,
							},
							sortOrder = {
								name = L["Sort order"],
								desc = L["Sort ascending or descending"],
								type = "select",
								order = 10,
								values = {["ASC"] = L["Ascending"],["DESC"] = L["Descending"]},
								set = setSortOrder,
								disabled = Lockdown,
							},
							unitsPerColumn = {
								name = L["Limit"],
								desc = L["The maximum amount to show"],
								type = "range",
								order = 11,
								min = 1,
								max = 40,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
						},
					},
				},
			},
			maintanktarget = {
				name = L["maintanktarget"],
				type = "group",
				order = 16,
				arg = LUF.db.profile.units.maintanktarget,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], L["maintanktarget"]),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
								set = setHeader,
							},
							offset = {
								name = L["Offset"],
								desc = L["Set the space between units."],
								type = "range",
								order = 4,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 5,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 7,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							attribPoint = {
								name = L["Growth direction"],
								desc = L["The direction in which new frames are added."],
								type = "select",
								order = 8,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								set = setGrowthDir,
								disabled = Lockdown,
							},
							sortMethod = {
								name = L["Sort by"],
								desc = L["Sort by name or index"],
								type = "select",
								order = 9,
								values = {["INDEX"] = L["Index"],["NAME"] = NAME},
								set = setSortMethod,
								disabled = Lockdown,
							},
							sortOrder = {
								name = L["Sort order"],
								desc = L["Sort ascending or descending"],
								type = "select",
								order = 10,
								values = {["ASC"] = L["Ascending"],["DESC"] = L["Descending"]},
								set = setSortOrder,
								disabled = Lockdown,
							},
							unitsPerColumn = {
								name = L["Limit"],
								desc = string.format(L["This is set through %s options."],MAINTANK),
								type = "range",
								order = 11,
								min = 1,
								max = 40,
								step = 1,
								disabled = function() return true end,
								get = function() return LUF.db.profile.units.maintank.unitsPerColumn end,
								set = setHeader,
							},
						},
					},
				},
			},
			maintanktargettarget = {
				name = L["maintanktargettarget"],
				type = "group",
				order = 17,
				arg = LUF.db.profile.units.maintanktargettarget,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], L["maintanktargettarget"]),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
								set = setHeader,
							},
							offset = {
								name = L["Offset"],
								desc = L["Set the space between units."],
								type = "range",
								order = 4,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 5,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 7,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							attribPoint = {
								name = L["Growth direction"],
								desc = L["The direction in which new frames are added."],
								type = "select",
								order = 8,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								set = setGrowthDir,
								disabled = Lockdown,
							},
							sortMethod = {
								name = L["Sort by"],
								desc = L["Sort by name or index"],
								type = "select",
								order = 9,
								values = {["INDEX"] = L["Index"],["NAME"] = NAME},
								set = setSortMethod,
								disabled = Lockdown,
							},
							sortOrder = {
								name = L["Sort order"],
								desc = L["Sort ascending or descending"],
								type = "select",
								order = 10,
								values = {["ASC"] = L["Ascending"],["DESC"] = L["Descending"]},
								set = setSortOrder,
								disabled = Lockdown,
							},
							unitsPerColumn = {
								name = L["Limit"],
								desc = string.format(L["This is set through %s options."],MAINTANK),
								type = "range",
								order = 11,
								min = 1,
								max = 40,
								step = 1,
								disabled = function() return true end,
								get = function() return LUF.db.profile.units.maintank.unitsPerColumn end,
								set = setHeader,
							},
						},
					},
				},
			},
			mainassist = {
				name = MAIN_ASSIST,
				type = "group",
				order = 18,
				arg = LUF.db.profile.units.mainassist,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], MAIN_ASSIST),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
								set = setHeader,
							},
							offset = {
								name = L["Offset"],
								desc = L["Set the space between units."],
								type = "range",
								order = 4,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 5,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 7,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							attribPoint = {
								name = L["Growth direction"],
								desc = L["The direction in which new frames are added."],
								type = "select",
								order = 8,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								set = setGrowthDir,
								disabled = Lockdown,
							},
							sortMethod = {
								name = L["Sort by"],
								desc = L["Sort by name or index"],
								type = "select",
								order = 9,
								values = {["INDEX"] = L["Index"],["NAME"] = NAME},
								set = setSortMethod,
								disabled = Lockdown,
							},
							sortOrder = {
								name = L["Sort order"],
								desc = L["Sort ascending or descending"],
								type = "select",
								order = 10,
								values = {["ASC"] = L["Ascending"],["DESC"] = L["Descending"]},
								set = setSortOrder,
								disabled = Lockdown,
							},
							unitsPerColumn = {
								name = L["Limit"],
								desc = L["The maximum amount to show"],
								type = "range",
								order = 11,
								min = 1,
								max = 40,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
						},
					},
				},
			},
			mainassisttarget = {
				name = L["mainassisttarget"],
				type = "group",
				order = 19,
				arg = LUF.db.profile.units.mainassisttarget,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], L["mainassisttarget"]),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
								set = setHeader,
							},
							offset = {
								name = L["Offset"],
								desc = L["Set the space between units."],
								type = "range",
								order = 4,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 5,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 7,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							attribPoint = {
								name = L["Growth direction"],
								desc = L["The direction in which new frames are added."],
								type = "select",
								order = 8,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								set = setGrowthDir,
								disabled = Lockdown,
							},
							sortMethod = {
								name = L["Sort by"],
								desc = L["Sort by name or index"],
								type = "select",
								order = 9,
								values = {["INDEX"] = L["Index"],["NAME"] = NAME},
								set = setSortMethod,
								disabled = Lockdown,
							},
							sortOrder = {
								name = L["Sort order"],
								desc = L["Sort ascending or descending"],
								type = "select",
								order = 10,
								values = {["ASC"] = L["Ascending"],["DESC"] = L["Descending"]},
								set = setSortOrder,
								disabled = Lockdown,
							},
							unitsPerColumn = {
								name = L["Limit"],
								desc = string.format(L["This is set through %s options."],MAIN_ASSIST),
								type = "range",
								order = 11,
								min = 1,
								max = 40,
								step = 1,
								disabled = function() return true end,
								get = function() return LUF.db.profile.units.mainassist.unitsPerColumn end,
								set = setHeader,
							},
						},
					},
				},
			},
			mainassisttargettarget = {
				name = L["mainassisttargettarget"],
				type = "group",
				order = 20,
				arg = LUF.db.profile.units.mainassisttargettarget,
				childGroups = "tab",
				args = {
					enabled = {
						name = ENABLE,
						desc = string.format(L["Enable the %s frame(s)"], L["mainassisttargettarget"]),
						type = "toggle",
						order = 1,
						disabled = Lockdown,
						set = setEnableUnit,
					},
					GeneralOptions = {
						name = GENERAL,
						type = "group",
						order = 2,
						args = {
							height = {
								name = L["Height"],
								desc = L["Set the height of the frame."],
								type = "range",
								order = 1,
								min = 10,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							width = {
								name = L["Width"],
								desc = L["Set the width of the frame."],
								type = "range",
								order = 2,
								min = 20,
								max = 600,
								step = 1,
								width = "full",
								disabled = Lockdown,
								set = setHeader,
							},
							scale = {
								name = L["Scale"],
								desc = L["Set the scale of the frame."],
								type = "range",
								order = 3,
								min = 0.5,
								max = 3,
								step = 0.01,
								isPercent = true,
								width = "double",
								disabled = Lockdown,
								set = setHeader,
							},
							offset = {
								name = L["Offset"],
								desc = L["Set the space between units."],
								type = "range",
								order = 4,
								min = 0,
								max = 200,
								step = 1,
								disabled = Lockdown,
								set = setHeader,
							},
							anchorTo = {
								name = L["Anchor To"],
								desc = L["Anchor to another frame."],
								type = "select",
								order = 5,
								values = getAnchors,
								set = SetAnchorTo,
								disabled = Lockdown,
							},
							x = {
								name = L["X Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 6,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							y = {
								name = L["Y Position"],
								desc = L["Set the position of the frame."],
								type = "input",
								order = 7,
								validate = nbrValidate,
								get = getPos,
								set = setPos,
								disabled = Lockdown,
							},
							attribPoint = {
								name = L["Growth direction"],
								desc = L["The direction in which new frames are added."],
								type = "select",
								order = 8,
								values = {["RIGHT"] = L["Left"],["LEFT"] = L["Right"],["BOTTOM"] = L["Up"],["TOP"] = L["Down"]},
								set = setGrowthDir,
								disabled = Lockdown,
							},
							sortMethod = {
								name = L["Sort by"],
								desc = L["Sort by name or index"],
								type = "select",
								order = 9,
								values = {["INDEX"] = L["Index"],["NAME"] = NAME},
								set = setSortMethod,
								disabled = Lockdown,
							},
							sortOrder = {
								name = L["Sort order"],
								desc = L["Sort ascending or descending"],
								type = "select",
								order = 10,
								values = {["ASC"] = L["Ascending"],["DESC"] = L["Descending"]},
								set = setSortOrder,
								disabled = Lockdown,
							},
							unitsPerColumn = {
								name = L["Limit"],
								desc = string.format(L["This is set through %s options."],MAIN_ASSIST),
								type = "range",
								order = 11,
								min = 1,
								max = 40,
								step = 1,
								disabled = function() return true end,
								get = function() return LUF.db.profile.units.mainassist.unitsPerColumn end,
								set = setHeader,
							},
						},
					},
				},
			},
			hidden = {
				name = L["Hide Blizzard"],
				type = "group",
				order = 21,
				get = function(info) return LUF.db.profile.hidden[info[#info]] end,
				set = function(info, value) LUF.db.profile.hidden[info[#info]] = value LUF:HideBlizzardFrames() end,
				disabled = Lockdown,
				args = {
					ReloadUI = {
						name = RELOADUI,
						type = "execute",
						func = function(info) ReloadUI() end,
						order = 1,
						disabled = function() end,
					},
					help = {
						order = 2,
						type = "group",
						name = L["Hint"],
						inline = true,
						args = {
							description = {
								type = "description",
								name = L["You will need to do a /console reloadui before a hidden frame becomes visible again."],
								width = "full",
							},
						},
					},
					player = {
						name = PLAYER,
						desc = string.format(L["Hides the default %s frame"], PLAYER),
						type = "toggle",
						order = 3,
					},
					pet = {
						name = PET,
						desc = string.format(L["Hides the default %s frame"], PET),
						type = "toggle",
						order = 4,
					},
					cast = {
						name = SHOW_ARENA_ENEMY_CASTBAR_TEXT,
						desc = string.format(L["Hides the default %s frame"], SHOW_ARENA_ENEMY_CASTBAR_TEXT),
						type = "toggle",
						order = 5,
					},
					buffs = {
						name = L["Buffs"],
						desc = string.format(L["Hides the default %s frame"], L["Buffs"]),
						type = "toggle",
						order = 6,
					},
					target = {
						name = TARGET,
						desc = string.format(L["Hides the default %s frame"], TARGET),
						type = "toggle",
						order = 7,
					},
					party = {
						name = PARTY,
						desc = string.format(L["Hides the default %s frame"], PARTY),
						type = "toggle",
						order = 8,
					},
					raid = {
						name = RAID,
						desc = string.format(L["Hides the default %s frame"], RAID),
						type = "toggle",
						order = 9,
					},
				},
			},
			help = {
				name = L["Tag Help"],
				type = "group",
				order = 22,
				args = {
					help = {
						order = 1,
						type = "group",
						name = L["Tags - Help"],
						inline = true,
						args = {
							description = {
								type = "description",
								name = L["You can use tags to change the text information displayed on each frame. Just go to the tag section of the frame you want to change and put in some tags."],
								width = "full",
							},
						},
					},
					infoheader = {
						name = L["Info tags"],
						type = "header",
						order = 2,
					},
				},
			},
			autoprofiles = {
				name = L["Auto Profiles"],
				type = "group",
				order = 23,
				args = {
					help = {
						order = 1,
						type = "group",
						name = L["Auto Profiles - Help"],
						inline = true,
						args = {
							description = {
								type = "description",
								name = L["You can set up here which profiles should be automatically loaded on certain conditions."],
								width = "full",
							},
						},
					},
					switchtype = {
						name = L["Switch by"],
						desc = L["Type of event to switch to"],
						type = "select",
						order = 2,
						values = {["DISABLED"] = ADDON_DISABLED, ["RESOLUTION"] = L["Screen Resolution"],["GROUP"] = L["Size of Group"]},
						get = function(info) return LUF.db.char.switchtype end,
						set = function(info, value) LUF.db.char.switchtype = value LUF:AutoswitchProfileSetup() end,
					},
					resolutionselect = {
						name = L["Screen Resolution"],
						desc = L["Resolution to assign a profile to"],
						type = "select",
						order = 3,
						hidden = function() return LUF.db.char.switchtype ~= "RESOLUTION" end,
						values = {GetScreenResolutions()},
						get = function(info) return resolutionselectvalue end,
						set = function(info, value) resolutionselectvalue = value end,
					},
					groupselect = {
						name = L["Size of Group"],
						desc = L["Size of group to assign a profile to"],
						type = "select",
						order = 4,
						hidden = function() return LUF.db.char.switchtype ~= "GROUP" end,
						values = {["RAID40"]=L["Raid40"],["RAID20"]=L["Raid20"],["RAID15"]=L["Raid15"],["RAID10"]=L["Raid10"],["RAID5"]=L["Raid5"],["PARTY"]=PARTY,["SOLO"]=L["Solo"],},
						get = function(info) return groupselectvalue end,
						set = function(info, value) groupselectvalue = value end,
					},
					profileselect = {
						name = L["Profile"],
						desc = L["Name of the profile which to switch to"],
						type = "select",
						order = 5,
						values = function() LUF.db:GetProfiles(profiledb) profiledb["NIL"] = NONE return profiledb end,
						hidden = function() return LUF.db.char.switchtype == "DISABLED" end,
						get = function(info)
							LUF.db:GetProfiles(profiledb)
							profiledb["NIL"] = NONE
							if LUF.db.char.switchtype == "RESOLUTION" then
								local resolutions = {GetScreenResolutions()}
								for k,v in pairs(resolutions) do
									if k == resolutionselectvalue then
										for i,j in pairs(profiledb) do
											if LUF.db.char.resdb[v] == j then
												return i
											end
										end
									end
								end
								return "NIL"
							else
								for k,v in pairs(profiledb) do
									if v == LUF.db.char.grpdb[groupselectvalue] then
										return k
									end
								end
								return "NIL"
							end
						end,
						set = function(info, value)
							LUF.db:GetProfiles(profiledb)
							profiledb["NIL"] = NONE
							if LUF.db.char.switchtype == "RESOLUTION" then
								local resolutions = {GetScreenResolutions()}
								for k,v in pairs(resolutions) do
									if k == resolutionselectvalue then
										LUF.db.char.resdb[v] = value ~= "NIL" and profiledb[value] or nil
										return
									end
								end
							else
								LUF.db.char.grpdb[groupselectvalue] = value ~= "NIL" and profiledb[value] or nil
							end
						end,
					},
				},
			},
		},
	}
	for mod, tbl in pairs(moduleOptions) do
		for _,unit in ipairs(LUF.unitList) do
			if not (moduleBlacklist[mod] and moduleBlacklist[mod][unit]) then
				aceoptions.args[unit].args[mod] = tbl
			end
		end
	end
	local i = 3
	for k in pairs(InfoTags) do
		aceoptions.args.help.args[k] = {
			order = i,
			type = "description",
			name = "["..k.."] = "..(L[k.."desc"] or L[k]),
			width = "full",
		}
		i = i + 1
	end
	aceoptions.args.help.args["healthnpowerheader"] = {
		order = i,
		type = "header",
		name = L["Health and power tags"],
	}
	i = i + 1
	for k in pairs(HealthnPowerTags) do
		aceoptions.args.help.args[k] = {
			order = i,
			type = "description",
			name = "["..k.."] = "..L[k],
			width = "full",
		}
		i = i + 1
	end
	aceoptions.args.help.args["colorheader"] = {
		order = i,
		type = "header",
		name = L["Color tags"],
	}
	i = i + 1
	for k in pairs(ColorTags) do
		aceoptions.args.help.args[k] = {
			order = i,
			type = "description",
			name = "["..k.."] = "..L[k],
			width = "full",
		}
		i = i + 1
	end
	ACR:RegisterOptionsTable(Addon, aceoptions, true)
	aceoptions.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)


	AceConfigDialog:AddToBlizOptions(Addon, nil, nil, "general")
	AceConfigDialog:AddToBlizOptions(Addon, COLORS, Addon, "colors")
	for _,unit in ipairs(LUF.unitList) do
		AceConfigDialog:AddToBlizOptions(Addon, L[unit], Addon, unit)
	end
	AceConfigDialog:AddToBlizOptions(Addon, L["Hide Blizzard"], Addon, "hidden")
	AceConfigDialog:AddToBlizOptions(Addon, L["Tag Help"], Addon, "help")
	AceConfigDialog:AddToBlizOptions(Addon, L["Auto Profiles"], Addon, "autoprofiles")
	AceConfigDialog:AddToBlizOptions(Addon, L["Profiles"], Addon, "profile")

	AceConfigDialog:SetDefaultSize(Addon, 895, 570)
end

SLASH_LUNAUF1 = "/luf"
SLASH_LUNAUF2 = "/luna"
SLASH_LUNAUF3 = "/lunauf"
SLASH_LUNAUF4 = "/lunaunitframes"
SlashCmdList["LUNAUF"] = function(msg)
	msg = msg and string.lower(msg)
	if( msg and string.match(msg, "^profile (.+)") ) then
		local profile = string.match(msg, "^profile (.+)")
		
		for id, name in pairs(LUF.db:GetProfiles()) do
			if( string.lower(name) == profile ) then
				LUF.db:SetProfile(name)
				LUF:Print(string.format(L["Changed profile to %s."], name))
				return
			end
		end
		LUF:Print(string.format(L["Cannot find any profiles named \"%s\"."], profile))
		return
	end
	
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")
	AceConfigDialog:Open("LunaUnitFrames")
end