LunaOptionsModule = {}

local OptionsPageNames = {{title = "Player Frame", frame = "LunaPlayerFrame"},
						{title = "Pet Frame", frame = "LunaPetFrame"},
						{title = "Target Frame", frame = "LunaTargetFrame"},
						{title = "Target of Target Frame", frame = "LunaTargetTargetFrame"},
						{title = "Target of Target of Target Frame", frame = "LunaTargetTargetTargetFrame"},
						{title = "Party Frames", frame = "LunaPartyFrames"},
						{title = "Party Pets Frame", frame = "LunaPartyPetFrames"},
						{title = "Party Targets Frame", frame = "LunaPartyTargetFrames"},
						{title = "Raid Frames", frame = "LunaUnitFrames.frames.headers"},
						{title = "General", frame = "LunaUnitFrames"}
						}
						
local barselectorfunc = {}
local buffposselectfunc = {}

local TagDesc = {
	["combat"]				= "(c) when in combat",
	["color:combat"]		= "Red when in combat",
	["race"]				= "Race if available",
	["rank"]				= "PvP title",
	["numrank"]				= "Numeric PvP rank",
	["creature"]			= "Creature type (Bat, Wolf , etc..)",
	["faction"]				= "Horde or Alliance",
	["sex"]					= "Gender",
	["nocolor"]				= "Resets the color to white",
	["druidform"]			= "Current druid form of friendly unit",
	["guild"]				= "Guildname",
	["incheal"]				= "Value of incoming heal",
	["pvp"]					= "Displays \"PvP\" if flagged for it",
	["smarthealth"]			= "The classic hp display (hp/maxhp and \"Dead\" if dead etc)",
	["healhp"]				= "Current hp and heal in one number (green when heal is incoming)",
	["hp"]            	    = "Current hp",
	["maxhp"]				= "Current maximum hp",
	["missinghp"]           = "Current missing hp",
	["healmishp"]			= "Missing hp after incoming heal (green when heal is incoming)",
	["perhp"]               = "HP percent",
	["pp"]            	    = "Current mana/rage/energy etc",
	["maxpp"]				= "Maximum mana/rage/energy etc",
	["missingpp"]           = "Missing mana/rage/energy",
	["perpp"]               = "Mana/rage/energy percent",
	["druid:pp"]			= "Returns current mana even in druid form",
	["druid:maxpp"]			= "Returns current maximum mana even in druid form",
	["druid:missingpp"]		= "Returns missing mana even in druid form",
	["druid:perpp"]			= "Returns mana percentage even in druid form",
	["level"]               = "Current level, returns ?? for bosses and players too high",
	["smartlevel"]          = "Returns \"Boss\" for bosses and Level+10+ for players too high",
	["levelcolor"]			= "Colors based on your level vs the level of the unit. (grey,green,yellow and red)",
	["name"]                = "Returns plain name of the unit",
	["ignore"]				= "Returns (i) if the player is on your ignore list",
	["abbrev:name"]			= "Returns shortened names (Marshall Williams = M. Williams)",
	["server"]				= "Server name",
	["status"]              = "\"Dead\", \"Ghost\" or \"Offline\"",
	["cpoints"]             = "Combo Points",
	["rare"]                = "\"rare\" if the creature is rare or rareelite",
	["elite"]     			= "\"elite\" if the creature is elite or rareelite",
	["shortclassification"] = "\"E\", \"R\", \"RE\" for the respective classification",
	["classification"]		= "Shows elite, rare, boss, etc...",
	["group"]				= "Current subgroup of the raid",
	["color:aggro"]			= "Red if the unit is targeted by an enemy",
	["classcolor"]			= "Classcolor of the unit",
	["class"]				= "Class of the unit",
	["smartclass"]			= "Returns Class for players and Creaturetype for NPCs",
	["reactcolor"]			= "Red for enemies, yellow for neutrals, and green for friendlies",
	["pvpcolor"]			= "White for unflagged units, green for flagged friendlies and red for flagged enemies",
	["smart:healmishp"]		= "Returns missing hp with healing factored in. Shows status when needed (\"Dead\", \"Offline\", \"Ghost\")",
	["smartrace"]			= "Shows race when if player, creaturetype when npc",
	["civilian"]			= "Returns (civ) when civilian",
	["healerhealth"]		= "Returns the same as \"smart:healmishp\" on friendly units and hp/maxhp on enemies",
}

local BarTextures = {
	"Luna",
	"Perl_1",
	"Perl_2",
	"Perl_3",
	"Perl_4",
	"Perl_5",
	"Perl_6",
	"XPerl_1",
	"XPerl_2",
	"XPerl_3"
}
local BarTexturesPath = "Interface\\AddOns\\LunaUnitFrames\\media\\statusbar\\"

local function ResetSettings()
	LunaOptions = {}
	LunaOptions.PowerColors = {
		["Mana"] = { 48/255, 113/255, 191/255}, -- Mana
		["Rage"] = { 226/255, 45/255, 75/255}, -- Rage
		["Focus"] = { 255/255, 178/255, 0}, -- Focus
		["Energy"] = { 1, 1, 34/255}, -- Energy
		["Happiness"] = { 0, 1, 1} -- Happiness
	}
	LunaOptions.DebuffTypeColor = {
		["Magic"]    = {0.2, 0.6, 1},
		["Curse"]    = {0.6, 0, 1},
		["Disease"]  = {0.6, 0.4, 0},
		["Poison"]   = {0, 0.6, 0}
	}
	LunaOptions.MiscColors = {
		["tapped"] = {0.5, 0.5, 0.5},
		["red"] = {0.90, 0.0, 0.0},
		["green"] = {0.20, 0.90, 0.20},
		["static"] = {0.70, 0.20, 0.90},
		["yellow"] = {0.93, 0.93, 0.0},
		["inc"] = {0, 0.35, 0.23},
		["enemyUnattack"] = {0.60, 0.20, 0.20},
		["hostile"] = {0.90, 0.0, 0.0},
		["friendly"] = {0.20, 0.90, b = 0.20},
		["neutral"] = {0.93, 0.93, b = 0.0},
		["offline"] = {0.50, 0.50, b = 0.50}
	}
	LunaOptions.backdrop = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		insets = {left = -1.5, right = -1.5, top = -1.5, bottom = -1.5},
	}
	LunaOptions.fontHeight = 11
	LunaOptions.font = "Interface\\AddOns\\LunaUnitFrames\\media\\barframes.ttf"
	LunaOptions.bordertexture = "Interface\\AddOns\\LunaUnitFrames\\media\\border"
	LunaOptions.icontexture = "Interface\\AddOns\\LunaUnitFrames\\media\\icon"
	LunaOptions.resIcon = "Interface\\AddOns\\LunaUnitFrames\\media\\Raid-Icon-Rez"
	LunaOptions.indicator = "Interface\\AddOns\\LunaUnitFrames\\media\\indicator"
	
	LunaOptions.BarTexture = 1
		
	LunaOptions.frames = {	["LunaPlayerFrame"] = {position = {x = 10, y = -20}, size = {x = 240, y = 40}, scale = 1, enabled = 1, ShowBuffs = 1, portrait = 2, bars = {{"Healthbar", 6}, {"Powerbar", 4}, {"Castbar", 3}, {"Druidbar", 0}, {"Totembar", 0}}},
							["LunaTargetFrame"] = {position = {x = 280, y = -20}, size = {x = 240, y = 40}, scale = 1, enabled = 1, ShowBuffs = 3, portrait = 2, bars = {{"Healthbar", 6}, {"Powerbar", 4}, {"Castbar", 3}, {"Combo Bar", 2}}},
							["LunaTargetTargetFrame"] = {position = {x = 550, y = -20}, size = {x = 150, y = 40}, scale = 1, enabled = 1, ShowBuffs = 1, bars = {{"Healthbar", 6}, {"Powerbar", 4}}},
							["LunaTargetTargetTargetFrame"] = {position = {x = 730, y = -20}, size = {x = 150, y = 40}, scale = 1, enabled = 1, ShowBuffs = 1, bars = {{"Healthbar", 6}, {"Powerbar", 4}}},
							["LunaPartyFrames"] = {position = {x = 10, y = -140}, size = {x = 200, y = 40}, scale = 1, enabled = 1, ShowBuffs = 3, portrait = 2, bars = {{"Healthbar", 6}, {"Powerbar", 4}}},
							["LunaPartyPetFrames"] = {position = "RIGHT", size = {x = 110, y = 19}, scale = 1, enabled = 1, bars = {{"Healthbar", 6}, {"Powerbar", 4}}},
							["LunaPartyTargetFrames"] = {position = "RIGHT", size = {x = 110, y = 19}, scale = 1, enabled = 1, bars = {{"Healthbar", 6}, {"Powerbar", 4}}},
							["LunaPetFrame"] = {position = {x = 10, y = -70}, size = {x = 240, y = 30}, scale = 1, enabled = 1, ShowBuffs = 3, portrait = 2, bars = {{"Healthbar", 6}, {"Powerbar", 4}}},
							["LunaRaidFrames"] = {
								["pBars"] = 1,
								["scale"] = 1,
								["padding"] = 4,
								["height"] = 35,
								["width"] = 80,
								["positions"] = {
									[1] = {
										["x"] = 400,
										["y"] = -400,
									},
									[2] = {
										["x"] = 400,
										["y"] = -400,
									},
									[3] = {
										["x"] = 400,
										["y"] = -400,
									},
									[4] = {
										["x"] = 400,
										["y"] = -400,
									},
									[5] = {
										["x"] = 400,
										["y"] = -400,
									},
									[6] = {
										["x"] = 400,
										["y"] = -400,
									},
									[7] = {
										["x"] = 400,
										["y"] = -400,
									},
									[8] = {
										["x"] = 400,
										["y"] = -400,
									},
								},
							},
						}
	LunaOptions.clickcast = {
							{"target","menu","","",""},
							{"","","","",""},
							{"","","","",""},
							{"","","","",""}
							}
	LunaOptions.enableRaid = 1
	LunaOptions.PartyinRaids = 0
	LunaOptions.Rangefreq = 0.2
	LunaOptions.Raidlayout = "GRID"
	LunaOptions.EnergyTicker = 1
	LunaOptions.hideBlizzCastbar = 1
	LunaOptions.PartyRange = 1
	LunaOptions.RaidRange = 1
	LunaOptions.XPBar = 1
	LunaOptions.PartySpace = 40
	LunaOptions.VerticalParty = 1
	LunaOptions.Raidbuff = ""
	LunaOptions.DruidBar = nil
	LunaOptions.TotemBar = nil
	LunaOptions.BTimers = 0
end

if LunaOptions == nil then
	ResetSettings()
end

if not LunaBuffDB then
	LunaBuffDB = {}
end

if not LunaOptions.frames["LunaRaidFrames"] then
	LunaOptions.frames["LunaRaidFrames"] = {}
end

local OptionFunctions = {}

function OptionFunctions.StartMoving()
	this:StartMoving()
end

function OptionFunctions.StopMovingOrSizing()
	this:StopMovingOrSizing()
end

function OptionFunctions.ToggleFrame()
	for i, frame in pairs(LunaOptionsFrame.ScrollFrames) do
		if (i-1) == this.id then
			frame:Show()
		else
			frame:Hide()
		end
	end
end

function OptionFunctions.OpenCCC()
	if cccpopup:IsShown() then
		cccpopup:Hide()
	else
		cccpopup:Show()
	end
end

function OptionFunctions.RaidHeightAdjust()
	if LunaUnitFrames.frames.headers[1] then
		LunaOptions.frames["LunaRaidFrames"].height = this:GetValue()
		getglobal("RaidHeightSliderText"):SetText("Height: "..LunaOptions.frames["LunaRaidFrames"].height)
		LunaUnitFrames:SetRaidFrameSize()
	end
end

function OptionFunctions.RaidWidthAdjust()
	if LunaUnitFrames.frames.headers[1] then
		LunaOptions.frames["LunaRaidFrames"].width = this:GetValue()
		getglobal("RaidWidthSliderText"):SetText("Width: "..LunaOptions.frames["LunaRaidFrames"].width)
		LunaUnitFrames:SetRaidFrameSize()
	end
end

function OptionFunctions.RaidScaleAdjust()
	if LunaUnitFrames.frames.headers[1] then
		LunaOptions.frames["LunaRaidFrames"].scale = math.floor((this:GetValue()+0.05)*10)/10
		getglobal("RaidScaleSliderText"):SetText("Scale: "..LunaOptions.frames["LunaRaidFrames"].scale)
		LunaUnitFrames:SetRaidFrameSize()
	end
end

function OptionFunctions.RaidPaddingAdjust()
	if LunaUnitFrames.frames.headers[1] then
		LunaOptions.frames["LunaRaidFrames"].padding = this:GetValue()
		getglobal("RaidPaddingSliderText"):SetText("Padding: "..LunaOptions.frames["LunaRaidFrames"].padding)
		LunaUnitFrames:UpdateRaidLayout()
	end
end	

function OptionFunctions.ToggleRaidGroupNames()
	if this:GetChecked() == 1 then
		LunaOptions.frames["LunaRaidFrames"].ShowRaidGroupTitles = 1
	else
		LunaOptions.frames["LunaRaidFrames"].ShowRaidGroupTitles = 0
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.ToggleDispelableDebuffs()
	if not LunaOptions.showdispelable then
		LunaOptions.showdispelable = 1
	else
		LunaOptions.showdispelable = nil
	end
	LunaUnitFrames.Raid_Update()
end

function OptionFunctions.ToggleTexDebuffs()
	if not LunaOptions.frames["LunaRaidFrames"].texturedebuff then
		LunaOptions.frames["LunaRaidFrames"].texturedebuff = 1
	else
		LunaOptions.frames["LunaRaidFrames"].texturedebuff = nil
	end
	LunaUnitFrames.Raid_Update()
end

function OptionFunctions.ToggleTexBuffs()
	if not LunaOptions.frames["LunaRaidFrames"].texturebuff then
		LunaOptions.frames["LunaRaidFrames"].texturebuff = 1
	else
		LunaOptions.frames["LunaRaidFrames"].texturebuff = nil
	end
	LunaUnitFrames.Raid_Update()
end

function OptionFunctions.ToggleAggro()
	if not LunaOptions.aggro then
		LunaOptions.aggro = 1
	else
		LunaOptions.aggro = nil
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.ToggleInterlock()
	if not LunaOptions.raidinterlock then
		LunaOptions.raidinterlock = 1
	else
		LunaOptions.raidinterlock = nil
	end
	LunaUnitFrames:UpdateRaidLayout()
end

function OptionFunctions.ScaleAdjust()
	local amount = (math.floor(this:GetValue()*10 + 0.5)/10)
	frame = getglobal(this:GetParent().frame)
	if frame then
		if this:GetParent().frame == "LunaPartyFrames" then
			for i=1,4 do
				frame[i]:SetScale(amount)
			end
		elseif this:GetParent().frame == "LunaPartyPetFrames" then
			for i=1,4 do
				frame[i]:SetScale(amount)
			end
		elseif this:GetParent().frame == "LunaPartyTargetFrames" then
			for i=1,4 do
				frame[i]:SetScale(amount)
			end
		else
			frame:SetScale(amount)
			LunaUnitFrames:ResizeXPBar()
			LunaUnitFrames:ResizeRepBar()
		end
		LunaOptions.frames[this:GetParent().frame].scale = amount
		getglobal(this:GetParent().frame.."ScaleSliderText"):SetText("Scale: "..amount)
	end
end

function OptionFunctions.HeightAdjust()
	local frame = getglobal(this:GetParent().frame)
	local amount = this:GetValue()
	if frame then
		if this:GetParent().frame == "LunaPartyFrames" then
			for i=1,4 do
				frame[i]:SetHeight(amount)
			end
			LunaUnitFrames:UpdatePartyUnitFrameSize()
			LunaUnitFrames:UpdatePartyBuffSize()
		elseif this:GetParent().frame == "LunaPartyPetFrames" then
			for i=1,4 do
				frame[i]:SetHeight(amount)
			end
		elseif this:GetParent().frame == "LunaPartyTargetFrames" then
			for i=1,4 do
				frame[i]:SetHeight(amount)
			end
		else
			frame:SetHeight(amount)
			frame:AdjustBars()
			if frame.UpdateBuffSize then
				frame:UpdateBuffSize()
			end
		end
		LunaOptions.frames[this:GetParent().frame].size.y = amount
		getglobal(this:GetParent().frame.."HeightSliderText"):SetText("Height: "..amount)
	end
end

function OptionFunctions.WidthAdjust()
	local frame = getglobal(this:GetParent().frame)
	local amount = this:GetValue()
	if frame then
		if this:GetParent().frame == "LunaPartyFrames" then
			for i=1,4 do
				frame[i]:SetWidth(amount)
			end
			LunaUnitFrames:UpdatePartyUnitFrameSize()
			LunaUnitFrames:UpdatePartyBuffSize()
		elseif this:GetParent().frame == "LunaPartyPetFrames" then
			for i=1,4 do
				frame[i]:SetWidth(amount)
			end
		elseif this:GetParent().frame == "LunaPartyTargetFrames" then
			for i=1,4 do
				frame[i]:SetWidth(amount)
			end
		elseif this:GetParent().frame == "LunaPlayerFrame" and LunaUnitFrames.frames.ExperienceBar and LunaUnitFrames.frames.ExperienceBar:IsShown() then
			frame:SetWidth(amount)
			frame:AdjustBars()
			frame:UpdateBuffSize()
			LunaUnitFrames:ResizeXPBar()
			LunaUnitFrames:ResizeRepBar()
		else
			frame:SetWidth(amount)
			frame:AdjustBars()
			if frame.UpdateBuffSize then
				frame:UpdateBuffSize()
			end
		end
		LunaOptions.frames[this:GetParent().frame].size.x = amount
		getglobal(this:GetParent().frame.."WidthSliderText"):SetText("Width: "..amount)
	end
end

function OptionFunctions.RegisterCastbar(frame)
	getglobal(frame):RegisterEvent("SPELLCAST_START")
	getglobal(frame):RegisterEvent("SPELLCAST_STOP")
	getglobal(frame):RegisterEvent("SPELLCAST_FAILED")
	getglobal(frame):RegisterEvent("SPELLCAST_INTERRUPTED")
	getglobal(frame):RegisterEvent("SPELLCAST_DELAYED")
	getglobal(frame):RegisterEvent("SPELLCAST_CHANNEL_START")
	getglobal(frame):RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
	getglobal(frame):RegisterEvent("SPELLCAST_CHANNEL_STOP")
end

function OptionFunctions.UnRegisterCastbar(frame)
	getglobal(frame):UnregisterEvent("SPELLCAST_START")
	getglobal(frame):UnregisterEvent("SPELLCAST_STOP")
	getglobal(frame):UnregisterEvent("SPELLCAST_FAILED")
	getglobal(frame):UnregisterEvent("SPELLCAST_INTERRUPTED")
	getglobal(frame):UnregisterEvent("SPELLCAST_DELAYED")
	getglobal(frame):UnregisterEvent("SPELLCAST_CHANNEL_START")
	getglobal(frame):UnregisterEvent("SPELLCAST_CHANNEL_UPDATE")
	getglobal(frame):UnregisterEvent("SPELLCAST_CHANNEL_STOP")
end

function OptionFunctions.HideBlizzardCastbarToggle()
	if LunaOptionsFrame.pages[10].HideBlizzCast:GetChecked() == 1 then
		OptionFunctions.UnRegisterCastbar("CastingBarFrame")
		CastingBarFrame:Hide()
		LunaOptions.hideBlizzCastbar = 1
	else
		OptionFunctions.RegisterCastbar("CastingBarFrame")
		LunaOptions.hideBlizzCastbar = 0
	end
end

function OptionFunctions.PortraitmodeToggle()
	if this:GetChecked() == 1 then
		LunaOptions.frames[this:GetParent().frame].portrait = 1
	else
		LunaOptions.frames[this:GetParent().frame].portrait = 2
		if this:GetParent().frame == "LunaPartyFrames" then
			for i=1,4 do
				LunaPartyFrames[i].bars["Portrait"]:Show()
			end
		else
			getglobal(this:GetParent().frame).bars["Portrait"]:Show()
		end
	end
	if this:GetParent().frame == "LunaPlayerFrame" then
		LunaUnitFrames:ConvertPlayerPortrait()
	elseif this:GetParent().frame == "LunaPetFrame" then
		LunaUnitFrames:ConvertPetPortrait()
	elseif this:GetParent().frame == "LunaTargetFrame" then
		LunaUnitFrames:ConvertTargetPortrait()
	elseif this:GetParent().frame == "LunaPartyFrames" then
		LunaUnitFrames:ConvertPartyPortraits()
	end
end

function OptionFunctions.XPBarToggle()
	if LunaOptionsFrame.pages[1].XPBar:GetChecked() == 1 then
		LunaOptions.XPBar = 1
	else
		LunaOptions.XPBar = 0
	end
	LunaUnitFrames:UpdateXPBar()
end

function OptionFunctions.RepBarToggle()
	if LunaOptionsFrame.pages[1].RepBar:GetChecked() == 1 then
		LunaOptions.RepBar = 1
	else
		LunaOptions.RepBar = nil
	end
	LunaUnitFrames:UpdateRepBar()
end

function OptionFunctions.BTimerToggle()
	if LunaOptionsFrame.pages[1].bufftimer:GetChecked() == 1 then
		LunaOptions.BTimers = 1
	else
		LunaOptions.BTimers = 0
	end
	LunaPlayerFrame.UpdateBuffSize()
end

function OptionFunctions.PlayerCombatTextToggle()
	if LunaOptions.frames["LunaPlayerFrame"].combattext then
		LunaOptions.frames["LunaPlayerFrame"].combattext = nil
	else
		LunaOptions.frames["LunaPlayerFrame"].combattext = 1
	end
end

function OptionFunctions.PlayerCombatIconToggle()
	if LunaOptions.frames["LunaPlayerFrame"].combaticon then
		LunaOptions.frames["LunaPlayerFrame"].combaticon = nil
	else
		LunaOptions.frames["LunaPlayerFrame"].combaticon = 1
	end
	LunaUnitFrames:UpdatePlayerFrame()
end

function OptionFunctions.PlayerLeaderIconToggle()
	if LunaOptions.frames["LunaPlayerFrame"].leadericon then
		LunaOptions.frames["LunaPlayerFrame"].leadericon = nil
	else
		LunaOptions.frames["LunaPlayerFrame"].leadericon = 1
	end
	LunaUnitFrames:UpdatePlayerFrame()
end

function OptionFunctions.PlayerLootIconToggle()
	if LunaOptions.frames["LunaPlayerFrame"].looticon then
		LunaOptions.frames["LunaPlayerFrame"].looticon = nil
	else
		LunaOptions.frames["LunaPlayerFrame"].looticon = 1
	end
	LunaUnitFrames:UpdatePlayerFrame()
end

function OptionFunctions.PlayerPvPRankIconToggle()
	if LunaOptions.frames["LunaPlayerFrame"].pvprankicon then
		LunaOptions.frames["LunaPlayerFrame"].pvprankicon = nil
	else
		LunaOptions.frames["LunaPlayerFrame"].pvprankicon = 1
	end
	LunaUnitFrames:UpdatePlayerFrame()
end

function OptionFunctions.TargetCombatTextToggle()
	if LunaOptions.frames["LunaTargetFrame"].combattext then
		LunaOptions.frames["LunaTargetFrame"].combattext = nil
	else
		LunaOptions.frames["LunaTargetFrame"].combattext = 1
	end
end

function OptionFunctions.TargetLeaderIconToggle()
	if LunaOptions.frames["LunaTargetFrame"].leadericon then
		LunaOptions.frames["LunaTargetFrame"].leadericon = nil
	else
		LunaOptions.frames["LunaTargetFrame"].leadericon = 1
	end
	LunaUnitFrames:UpdateTargetFrame()
end

function OptionFunctions.TargetLootIconToggle()
	if LunaOptions.frames["LunaTargetFrame"].looticon then
		LunaOptions.frames["LunaTargetFrame"].looticon = nil
	else
		LunaOptions.frames["LunaTargetFrame"].looticon = 1
	end
	LunaUnitFrames:UpdateTargetFrame()
end

function OptionFunctions.TargetPvPRankIconToggle()
	if LunaOptions.frames["LunaTargetFrame"].pvprankicon then
		LunaOptions.frames["LunaTargetFrame"].pvprankicon = nil
	else
		LunaOptions.frames["LunaTargetFrame"].pvprankicon = 1
	end
	LunaUnitFrames:UpdateTargetFrame()
end

function OptionFunctions.PartyLeaderIconToggle()
	if LunaOptions.frames["LunaPartyFrames"].leadericon then
		LunaOptions.frames["LunaPartyFrames"].leadericon = nil
	else
		LunaOptions.frames["LunaPartyFrames"].leadericon = 1
	end
	LunaUnitFrames:UpdatePartyFrames()
end

function OptionFunctions.PartyLootIconToggle()
	if LunaOptions.frames["LunaPartyFrames"].looticon then
		LunaOptions.frames["LunaPartyFrames"].looticon = nil
	else
		LunaOptions.frames["LunaPartyFrames"].looticon = 1
	end
	LunaUnitFrames:UpdatePartyFrames()
end

function OptionFunctions.PartyPvPRankIconToggle()
	if LunaOptions.frames["LunaPartyFrames"].pvprankicon then
		LunaOptions.frames["LunaPartyFrames"].pvprankicon = nil
	else
		LunaOptions.frames["LunaPartyFrames"].pvprankicon = 1
	end
	LunaUnitFrames:UpdatePartyFrames()
end

function OptionFunctions.PlayerIconSizeAdjust()
	LunaOptions.frames["LunaPlayerFrame"].iconscale = math.floor(this:GetValue()*100)/100
	getglobal("PlayerIconSizeSliderText"):SetText("Status Icon Size:"..(LunaOptions.frames["LunaPlayerFrame"].iconscale or 1))
	LunaUnitFrames:UpdatePlayerFrame()
end

function OptionFunctions.TargetIconSizeAdjust()
	LunaOptions.frames["LunaTargetFrame"].iconscale = math.floor(this:GetValue()*100)/100
	getglobal("TargetIconSizeSliderText"):SetText("Status Icon Size: "..(LunaOptions.frames["LunaTargetFrame"].iconscale or 1))
	LunaUnitFrames:UpdateTargetFrame()
end

function OptionFunctions.PartyIconSizeAdjust()
	LunaOptions.frames["LunaPartyFrames"].iconscale = math.floor(this:GetValue()*100)/100
	getglobal("PartyIconSizeSliderText"):SetText("Status Icon Size: "..(LunaOptions.frames["LunaPartyFrames"].iconscale or 1))
	LunaUnitFrames:UpdatePartyFrames()
end

function OptionFunctions.CenterIconSizeAdjust()
	LunaOptions.frames["LunaRaidFrames"].centericonscale = math.floor(this:GetValue()*100)/100
	getglobal("CenterIconSizeSliderText"):SetText("Center Icon Size: "..(LunaOptions.frames["LunaRaidFrames"].centericonscale or 1))
	LunaUnitFrames:SetRaidFrameSize()
end

function OptionFunctions.CornerIconSizeAdjust()
	LunaOptions.frames["LunaRaidFrames"].cornericonscale = math.floor(this:GetValue()*100)/100
	getglobal("CornerIconSizeSliderText"):SetText("Corner Icon Size: "..(LunaOptions.frames["LunaRaidFrames"].cornericonscale or 1))
	LunaUnitFrames:SetRaidFrameSize()
end


function OptionFunctions.PlayerBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[1].BuffPosition, this:GetID())
	LunaOptions.frames["LunaPlayerFrame"].ShowBuffs = this:GetID()
	LunaPlayerFrame.UpdateBuffSize()
end

function OptionFunctions.PlayerBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.PlayerBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

buffposselectfunc[1] = OptionFunctions.PlayerBuffPosSelect

function OptionFunctions.PlayerBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[1].BarSelect, this:GetID())
					local selection = UIDropDownMenu_GetText(LunaOptionsFrame.pages[1].BarSelect)
					for k,v in pairs(LunaOptions.frames["LunaPlayerFrame"].bars) do
						if v[1] == selection then
							LunaOptionsFrame.pages[1].barorder:SetValue(k)
							LunaOptionsFrame.pages[1].barheight:SetValue(v[2])
							if selection == "Healthbar" or selection == "Powerbar" then
								LunaOptionsFrame.pages[1].lefttext:EnableMouse(1)
								LunaOptionsFrame.pages[1].righttext:EnableMouse(1)
							else
								LunaOptionsFrame.pages[1].lefttext:EnableMouse(nil)
								LunaOptionsFrame.pages[1].righttext:EnableMouse(nil)
								LunaOptionsFrame.pages[1].lefttext:ClearFocus()
								LunaOptionsFrame.pages[1].righttext:ClearFocus()
							end
							LunaOptionsFrame.pages[1].lefttext:SetText(v[4] or LunaOptions.defaultTags[selection][1])
							LunaOptionsFrame.pages[1].righttext:SetText(v[5] or LunaOptions.defaultTags[selection][2])
							LunaOptionsFrame.pages[1].textsize:SetValue(v[3] or 0.45)
							LunaOptionsFrame.pages[1].textbalance:SetValue(v[6] or 0.5)
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

barselectorfunc[1] = OptionFunctions.PlayerBarSelectorInit

function OptionFunctions.BuffInRow()
	local frame = getglobal(this:GetParent().frame)
	amount = this:GetValue()
	if frame then
		LunaOptions.frames[this:GetParent().frame].BuffInRow = amount
		if this:GetParent().frame == "LunaPartyFrames" then
			LunaUnitFrames:UpdatePartyBuffSize()
		else
			frame.UpdateBuffSize()
		end
		getglobal(this:GetParent().frame.."BuffInRowText"):SetText("Auras per row: "..amount)
	end	
end

function OptionFunctions.PetBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaPetFrame"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[2].BarSelect, this:GetID())
					local selection = UIDropDownMenu_GetText(LunaOptionsFrame.pages[2].BarSelect)
					for k,v in pairs(LunaOptions.frames["LunaPetFrame"].bars) do
						if v[1] == selection then
							LunaOptionsFrame.pages[2].barorder:SetValue(k)
							LunaOptionsFrame.pages[2].barheight:SetValue(v[2])
							if selection == "Healthbar" or selection == "Powerbar" then
								LunaOptionsFrame.pages[2].lefttext:EnableMouse(1)
								LunaOptionsFrame.pages[2].righttext:EnableMouse(1)
							else
								LunaOptionsFrame.pages[2].lefttext:EnableMouse(nil)
								LunaOptionsFrame.pages[2].righttext:EnableMouse(nil)
								LunaOptionsFrame.pages[2].lefttext:ClearFocus()
								LunaOptionsFrame.pages[2].righttext:ClearFocus()
							end
							LunaOptionsFrame.pages[2].lefttext:SetText(v[4] or LunaOptions.defaultTags[selection][1])
							LunaOptionsFrame.pages[2].righttext:SetText(v[5] or LunaOptions.defaultTags[selection][2])
							LunaOptionsFrame.pages[2].textsize:SetValue(v[3] or 0.45)
							LunaOptionsFrame.pages[2].textbalance:SetValue(v[6] or 0.5)
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

barselectorfunc[2] = OptionFunctions.PetBarSelectorInit

function OptionFunctions.TargetBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[3].BarSelect, this:GetID())
					local selection = UIDropDownMenu_GetText(LunaOptionsFrame.pages[3].BarSelect)
					for k,v in pairs(LunaOptions.frames["LunaTargetFrame"].bars) do
						if v[1] == selection then
							LunaOptionsFrame.pages[3].barorder:SetValue(k)
							LunaOptionsFrame.pages[3].barheight:SetValue(v[2])
							if selection == "Healthbar" or selection == "Powerbar" then
								LunaOptionsFrame.pages[3].lefttext:EnableMouse(1)
								LunaOptionsFrame.pages[3].righttext:EnableMouse(1)
							else
								LunaOptionsFrame.pages[3].lefttext:EnableMouse(nil)
								LunaOptionsFrame.pages[3].righttext:EnableMouse(nil)
								LunaOptionsFrame.pages[3].lefttext:ClearFocus()
								LunaOptionsFrame.pages[3].righttext:ClearFocus()
							end
							LunaOptionsFrame.pages[3].lefttext:SetText(v[4] or LunaOptions.defaultTags[selection][1])
							LunaOptionsFrame.pages[3].righttext:SetText(v[5] or LunaOptions.defaultTags[selection][2])
							LunaOptionsFrame.pages[3].textsize:SetValue(v[3] or 0.45)
							LunaOptionsFrame.pages[3].textbalance:SetValue(v[6] or 0.5)
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

barselectorfunc[3] = OptionFunctions.TargetBarSelectorInit

function OptionFunctions.TargetTargetBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[4].BarSelect, this:GetID())
					local selection = UIDropDownMenu_GetText(LunaOptionsFrame.pages[4].BarSelect)
					for k,v in pairs(LunaOptions.frames["LunaTargetTargetFrame"].bars) do
						if v[1] == selection then
							LunaOptionsFrame.pages[4].barorder:SetValue(k)
							LunaOptionsFrame.pages[4].barheight:SetValue(v[2])
							if selection == "Healthbar" or selection == "Powerbar" then
								LunaOptionsFrame.pages[4].lefttext:EnableMouse(1)
								LunaOptionsFrame.pages[4].righttext:EnableMouse(1)
							else
								LunaOptionsFrame.pages[4].lefttext:EnableMouse(nil)
								LunaOptionsFrame.pages[4].righttext:EnableMouse(nil)
								LunaOptionsFrame.pages[4].lefttext:ClearFocus()
								LunaOptionsFrame.pages[4].righttext:ClearFocus()
							end
							LunaOptionsFrame.pages[4].lefttext:SetText(v[4] or LunaOptions.defaultTags[selection][1])
							LunaOptionsFrame.pages[4].righttext:SetText(v[5] or LunaOptions.defaultTags[selection][2])
							LunaOptionsFrame.pages[4].textsize:SetValue(v[3] or 0.45)
							LunaOptionsFrame.pages[4].textbalance:SetValue(v[6] or 0.5)
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

barselectorfunc[4] = OptionFunctions.TargetTargetBarSelectorInit

function OptionFunctions.TargetTargetTargetBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[5].BarSelect, this:GetID())
					local selection = UIDropDownMenu_GetText(LunaOptionsFrame.pages[5].BarSelect)
					for k,v in pairs(LunaOptions.frames["LunaTargetTargetTargetFrame"].bars) do
						if v[1] == selection then
							LunaOptionsFrame.pages[5].barorder:SetValue(k)
							LunaOptionsFrame.pages[5].barheight:SetValue(v[2])
							if selection == "Healthbar" or selection == "Powerbar" then
								LunaOptionsFrame.pages[5].lefttext:EnableMouse(1)
								LunaOptionsFrame.pages[5].righttext:EnableMouse(1)
							else
								LunaOptionsFrame.pages[5].lefttext:EnableMouse(nil)
								LunaOptionsFrame.pages[5].righttext:EnableMouse(nil)
								LunaOptionsFrame.pages[5].lefttext:ClearFocus()
								LunaOptionsFrame.pages[5].righttext:ClearFocus()
							end
							LunaOptionsFrame.pages[5].lefttext:SetText(v[4] or LunaOptions.defaultTags[selection][1])
							LunaOptionsFrame.pages[5].righttext:SetText(v[5] or LunaOptions.defaultTags[selection][2])
							LunaOptionsFrame.pages[5].textsize:SetValue(v[3] or 0.45)
							LunaOptionsFrame.pages[5].textbalance:SetValue(v[6] or 0.5)
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

barselectorfunc[5] = OptionFunctions.TargetTargetTargetBarSelectorInit

function OptionFunctions.PartyBarSelectorInit()
	local info={}
	for k,v in pairs(LunaOptions.frames["LunaPartyFrames"].bars) do
		info.text=v[1]
		info.value=k
		info.func= function () UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[6].BarSelect, this:GetID())
					local selection = UIDropDownMenu_GetText(LunaOptionsFrame.pages[6].BarSelect)
					for k,v in pairs(LunaOptions.frames["LunaPartyFrames"].bars) do
						if v[1] == selection then
							LunaOptionsFrame.pages[6].barorder:SetValue(k)
							LunaOptionsFrame.pages[6].barheight:SetValue(v[2])
							if selection == "Healthbar" or selection == "Powerbar" then
								LunaOptionsFrame.pages[6].lefttext:EnableMouse(1)
								LunaOptionsFrame.pages[6].righttext:EnableMouse(1)
							else
								LunaOptionsFrame.pages[6].lefttext:EnableMouse(nil)
								LunaOptionsFrame.pages[6].righttext:EnableMouse(nil)
								LunaOptionsFrame.pages[6].lefttext:ClearFocus()
								LunaOptionsFrame.pages[6].righttext:ClearFocus()
							end
							LunaOptionsFrame.pages[6].lefttext:SetText(v[4] or LunaOptions.defaultTags[selection][1])
							LunaOptionsFrame.pages[6].righttext:SetText(v[5] or LunaOptions.defaultTags[selection][2])
							LunaOptionsFrame.pages[6].textsize:SetValue(v[3] or 0.45)
							LunaOptionsFrame.pages[6].textbalance:SetValue(v[6] or 0.5)
							break
						end
					end
		end
		info.checked = nil
		info.checkable = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

barselectorfunc[6] = OptionFunctions.PartyBarSelectorInit

function OptionFunctions.OnOrderSlider()
	local place = this:GetValue()
	local bar = UIDropDownMenu_GetText(this:GetParent().BarSelect)
	local framename = this:GetParent().frame
	for k,v in pairs(LunaOptions.frames[framename].bars) do
		if v[1] == bar then
			table.remove(LunaOptions.frames[framename].bars, k)
			table.insert(LunaOptions.frames[framename].bars, place, v)
			break
		end
	end
	getglobal(this:GetName().."Text"):SetText("Bar Position: "..place)
	if framename == "LunaPartyFrames" then
		LunaUnitFrames:UpdatePartyUnitFrameSize()
	else
		getglobal(framename).AdjustBars()
	end
end

function OptionFunctions.OnTextSlider()
	local value = this:GetValue()
	value = math.floor((value+0.0005)*1000)/1000
	local bar = UIDropDownMenu_GetText(this:GetParent().BarSelect)
	for k,v in pairs(LunaOptions.frames[this:GetParent().frame].bars) do
		if v[1] == bar then
			v[3] = value
			break
		end
	end
	getglobal(this:GetName().."Text"):SetText("Text Size: "..value)
	if this:GetParent().frame == "LunaPartyFrames" then
		LunaUnitFrames:UpdatePartyUnitFrameSize()
	else
		getglobal(this:GetParent().frame).AdjustBars()
	end
end

function OptionFunctions.OnTextBalanceSlider()
	local value = this:GetValue()
	value = math.floor((value+0.0005)*1000)/1000
	local bar = UIDropDownMenu_GetText(this:GetParent().BarSelect)
	for k,v in pairs(LunaOptions.frames[this:GetParent().frame].bars) do
		if v[1] == bar then
			v[6] = value
			break
		end
	end
	if this:GetParent().frame == "LunaPartyFrames" then
		LunaUnitFrames:UpdatePartyUnitFrameSize()
	else
		getglobal(this:GetParent().frame).AdjustBars()
	end
end

function OnBarHeight()
	local weight = this:GetValue()
	if this:GetParent().frame == "LunaPartyFrames" then
		for i=1,4 do
			if weight == 0 then
				LunaPartyFrames[i].bars[UIDropDownMenu_GetText(this:GetParent().BarSelect)]:Hide()
				getglobal(this:GetName().."Text"):SetText("Bar height weight: BAR OFF")
			else
				LunaPartyFrames[i].bars[UIDropDownMenu_GetText(this:GetParent().BarSelect)]:Show()
				getglobal(this:GetName().."Text"):SetText("Bar height weight: "..weight)
			end
		end
		for k,v in pairs(LunaOptions.frames[this:GetParent().frame].bars) do
			if v[1] == UIDropDownMenu_GetText(this:GetParent().BarSelect) then
				v[2] = weight
				break
			end
		end
		LunaUnitFrames:UpdatePartyUnitFrameSize()
	else
		if weight == 0 then
			getglobal(this:GetParent().frame).bars[UIDropDownMenu_GetText(this:GetParent().BarSelect)]:Hide()
			getglobal(this:GetName().."Text"):SetText("Bar height weight: BAR OFF")
			if UIDropDownMenu_GetText(this:GetParent().BarSelect) == "Castbar" and this:GetParent().frame == "LunaPlayerFrame" then
				OptionFunctions.UnRegisterCastbar("LunaPlayerFrame")
				LunaPlayerFrame.bars["Castbar"].casting = nil
				LunaPlayerFrame.bars["Castbar"].channeling = nil
			end
		else
			getglobal(this:GetParent().frame).bars[UIDropDownMenu_GetText(this:GetParent().BarSelect)]:Show()
			getglobal(this:GetName().."Text"):SetText("Bar height weight: "..weight)
			if UIDropDownMenu_GetText(this:GetParent().BarSelect) == "Castbar" and this:GetParent().frame == "LunaPlayerFrame" then
				OptionFunctions.RegisterCastbar("LunaPlayerFrame")
			end
		end
		for k,v in pairs(LunaOptions.frames[this:GetParent().frame].bars) do
			if v[1] == UIDropDownMenu_GetText(this:GetParent().BarSelect) then
				v[2] = weight
				if v[1] == "Druidbar" then
					if weight == 0 then
						LunaOptions.DruidBar = nil
					else
						LunaOptions.DruidBar = 1
					end
				elseif v[1] == "Totembar" then
					if weight == 0 then
						LunaOptions.TotemBar = nil
					else
						LunaOptions.TotemBar = 1
					end
				end
				break
			end
		end
		getglobal(this:GetParent().frame).AdjustBars()
	end
end

function OptionFunctions.PetBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[2].BuffPosition, this:GetID())
	LunaOptions.frames["LunaPetFrame"].ShowBuffs = this:GetID()
	LunaPetFrame.UpdateBuffSize()
end

function OptionFunctions.PetBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.PetBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

buffposselectfunc[2] = OptionFunctions.PetBuffPosSelect

function OptionFunctions.TargetBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[3].BuffPosition, this:GetID())
	LunaOptions.frames["LunaTargetFrame"].ShowBuffs = this:GetID()
	LunaTargetFrame.UpdateBuffSize()
end

function OptionFunctions.TargetBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.TargetBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

buffposselectfunc[3] = OptionFunctions.TargetBuffPosSelect

function OptionFunctions.TargetTargetBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[4].BuffPosition, this:GetID())
	LunaOptions.frames["LunaTargetTargetFrame"].ShowBuffs = this:GetID()
	LunaTargetTargetFrame.UpdateBuffSize()
end

function OptionFunctions.TargetTargetBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.TargetTargetBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

buffposselectfunc[4] = OptionFunctions.TargetTargetBuffPosSelect

function OptionFunctions.TargetTargetTargetBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[5].BuffPosition, this:GetID())
	LunaOptions.frames["LunaTargetTargetTargetFrame"].ShowBuffs = this:GetID()
	LunaTargetTargetTargetFrame.UpdateBuffSize()
end

function OptionFunctions.TargetTargetTargetBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.TargetTargetTargetBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

buffposselectfunc[5] = OptionFunctions.TargetTargetTargetBuffPosSelect

function OptionFunctions.PartyBuffPosSelectChoice()
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[6].BuffPosition, this:GetID())
	LunaOptions.frames["LunaPartyFrames"].ShowBuffs = this:GetID()
	LunaUnitFrames:UpdatePartyBuffSize()
end

function OptionFunctions.PartyBuffPosSelect()
	local info={}
	for k,v in ipairs({"Hide","Top","Bottom","Left","Right"}) do
		info.text=v
		info.value=k
		info.func= OptionFunctions.PartyBuffPosSelectChoice
		info.checked = nil
		UIDropDownMenu_AddButton(info, 1)
	end
end

buffposselectfunc[6] = OptionFunctions.PartyBuffPosSelect

function OptionFunctions.fsTickerToggle()
	if LunaOptions.fsTicker == 1 then
		LunaOptions.fsTicker = nil
	else
		LunaOptions.fsTicker = 1
	end
	LunaUnitFrames:UpdatePlayerFrame()
end

function OptionFunctions.EnergyTickerToggle()
	if LunaOptions.EnergyTicker == 1 then
		LunaOptions.EnergyTicker = 0
	else
		LunaOptions.EnergyTicker = 1
	end
	LunaUnitFrames:UpdatePlayerFrame()
end

function OptionFunctions.ToggleFlipTarget()
	if LunaOptions.fliptarget then
		LunaOptions.fliptarget = nil
	else
		LunaOptions.fliptarget = 1
	end
	LunaTargetFrame.AdjustBars()
end

function OptionFunctions.ToggleHideHealing()
	if LunaOptions.HideHealing then
		LunaOptions.HideHealing = nil
	else
		LunaOptions.HideHealing = 1
	end
	LunaTargetFrame.AdjustBars()
end

function OptionFunctions.PartyGrowthToggle()
	if LunaOptions.VerticalParty == 1 then
		LunaOptions.VerticalParty = 0
	else
		LunaOptions.VerticalParty = 1
	end
	LunaUnitFrames:UpdatePartyPosition()
end

function OptionFunctions.PartySpaceAdjust()
	LunaOptions.PartySpace = this:GetValue()
	getglobal("SpaceSliderText"):SetText("Party Space between units: "..LunaOptions.PartySpace)
	LunaUnitFrames:UpdatePartyPosition()
end

function OptionFunctions.PartyRangeToggle()
	if LunaOptions.PartyRange == 1 then
		LunaOptions.PartyRange = 0
		for i=1, 4 do
			LunaPartyFrames[i]:SetAlpha(1)
		end
	else
		LunaOptions.PartyRange = 1
	end
end

function OptionFunctions.PartyinRaidToggle()
	if LunaOptions.PartyinRaid == 1 then
		LunaOptions.PartyinRaid = 0
	else
		LunaOptions.PartyinRaid = 1
	end
	LunaUnitFrames:UpdatePartyFrames()
end

function OptionFunctions.PartyInRaidFrame()
	if LunaOptions.partyraidframe == 1 then
		LunaOptions.partyraidframe = nil
	else
		LunaOptions.partyraidframe = 1
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.LockFrames()
	LunaUnitFrames:TogglePlayerLock()
	LunaUnitFrames:ToggleTargetLock()
	LunaUnitFrames:ToggleTargetTargetLock()
	LunaUnitFrames:TogglePetLock()
	LunaUnitFrames:TogglePartyLock()
	LunaUnitFrames:ToggleRaidFrameLock()
end

function OptionFunctions.UpdateAll()
	LunaUnitFrames:UpdatePlayerFrame()
	LunaUnitFrames:UpdatePetFrame()
	LunaUnitFrames:UpdateTargetFrame()
	LunaUnitFrames:UpdateTargetTargetFrame()
	LunaUnitFrames:UpdateTargetTargetTargetFrame()
	LunaUnitFrames:UpdatePartyFrames()
	LunaUnitFrames:UpdatePartyTargetFrames()
	LunaUnitFrames:UpdatePartyPetFrames()
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.ToggleBlizzPlayer()
	if not LunaOptions.BlizzPlayer then
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
		PlayerFrame_Update()
		UnitFrameHealthBar_Update(PlayerFrame.healthhar, "player")
		UnitFrameManaBar_Update(PlayerFrame.manabar, "player")
		LunaOptions.BlizzPlayer = 1
	else
		PlayerFrame:UnregisterAllEvents()
		PlayerFrame:Hide()
		LunaOptions.BlizzPlayer = nil
	end
end

function OptionFunctions.ToggleBlizzTarget()
	ClearTarget()
	if not LunaOptions.BlizzTarget then
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
		LunaOptions.BlizzTarget = 1
	else
		TargetFrame:UnregisterAllEvents()
		TargetFrame:Hide()
		ComboFrame:UnregisterAllEvents()
		ComboFrame:Hide()
		LunaOptions.BlizzTarget = nil
	end
end

function OptionFunctions.ToggleBlizzParty()
	if not LunaOptions.BlizzParty then
		RaidOptionsFrame_UpdatePartyFrames = LunaUnitFrames.RaidOptionsFrame_UpdatePartyFrames
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

			UnitFrame_OnEvent("PARTY_MEMBERS_CHANGED")
			ShowPartyFrame()
		end
		LunaOptions.BlizzParty = 1
	else
		LunaUnitFrames.RaidOptionsFrame_UpdatePartyFrames = RaidOptionsFrame_UpdatePartyFrames
		RaidOptionsFrame_UpdatePartyFrames = function () end
		for i=1,4 do
			local frame = getglobal("PartyMemberFrame"..i)
			frame:UnregisterAllEvents()
			frame:Hide()
		end
		LunaOptions.BlizzParty = nil
	end
end

function OptionFunctions.ToggleBlizzBuffs()
	if not LunaOptions.BlizzBuffs then
		BuffFrame:Hide()
		LunaOptions.BlizzBuffs = 1
	else
		LunaOptions.BlizzBuffs = nil
		BuffFrame:Show()
	end
end

function OptionFunctions.ToggleHighlightBuffs()
	if not LunaOptions.HighlightDebuffs then
		LunaOptions.HighlightDebuffs = 1
	else
		LunaOptions.HighlightDebuffs = nil
	end
end

function OptionFunctions.Mouseover()
	if not LunaOptions.mouseover then
		LunaOptions.mouseover = 1
	else
		LunaOptions.mouseover = nil
	end
end

function OptionFunctions.enableFrame()
	if LunaOptions.frames[this:GetParent().frame].enabled == 1 then
		LunaOptions.frames[this:GetParent().frame].enabled = 0
	else
		LunaOptions.frames[this:GetParent().frame].enabled = 1
	end
	OptionFunctions.UpdateAll()
end

function OptionFunctions.enableRaid()
	if LunaOptions.enableRaid == 1 then
		LunaOptions.enableRaid = 0
	else
		LunaOptions.enableRaid = 1
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.ToggleVertRaidHealthBars()
	if not LunaOptions.frames["LunaRaidFrames"].verticalHealth then
		LunaOptions.frames["LunaRaidFrames"].verticalHealth = 1
	else
		LunaOptions.frames["LunaRaidFrames"].verticalHealth = nil
	end
	LunaUnitFrames:UpdateRaidLayout()
end
	
function OptionFunctions.ToggleRaidPowerBars()
	if not LunaOptions.frames["LunaRaidFrames"].pBars then
		LunaOptions.frames["LunaRaidFrames"].pBars = 1
		LunaOptionsFrame.pages[9].pBarvertswitch:Enable()
		LunaOptionsFrame.pages[9].pBarvertswitch:SetChecked(nil)
	else
		LunaOptions.frames["LunaRaidFrames"].pBars = nil
		LunaOptionsFrame.pages[9].pBarvertswitch:Disable()
	end
	LunaUnitFrames:UpdateRaidLayout()
end

function OptionFunctions.ToggleVertRaidPowerBars()
	if not (LunaOptions.frames["LunaRaidFrames"].pBars == 2) then
		LunaOptions.frames["LunaRaidFrames"].pBars = 2
	else
		LunaOptions.frames["LunaRaidFrames"].pBars = 1
	end
	LunaUnitFrames:UpdateRaidLayout()
end

function OptionFunctions.ToggleCenterIcon()
	if not LunaOptions.frames["LunaRaidFrames"].centerIcon then
		LunaOptions.frames["LunaRaidFrames"].centerIcon = 1
	else
		LunaOptions.frames["LunaRaidFrames"].centerIcon = nil
	end
	LunaUnitFrames:UpdateRaidLayout()
end

function OptionFunctions.ToggleAlwaysRaid()
	if not LunaOptions.AlwaysRaid then
		LunaOptions.AlwaysRaid = 1
	else
		LunaOptions.AlwaysRaid = nil
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.ToggleHotTracker()
	if not LunaOptions.frames["LunaRaidFrames"].hottracker then
		LunaOptions.frames["LunaRaidFrames"].hottracker = 1
	else
		LunaOptions.frames["LunaRaidFrames"].hottracker = nil
	end
	LunaUnitFrames:UpdateRaidLayout()
end

function OptionFunctions.ToggleWSoul()
	if not LunaOptions.frames["LunaRaidFrames"].wsoul then
		LunaOptions.frames["LunaRaidFrames"].wsoul = 1
	else
		LunaOptions.frames["LunaRaidFrames"].wsoul = nil
	end
	LunaUnitFrames.Raid_Update()
end

function OptionFunctions.ToggleHBarColor()
	if not LunaOptions.hbarcolor then
		LunaOptions.hbarcolor = 1
	else
		LunaOptions.hbarcolor = nil
	end
	OptionFunctions.UpdateAll()
end

function OptionFunctions.OverhealAdjust()
	LunaOptions.overheal = this:GetValue()
	getglobal(this:GetName().."Text"):SetText("Overlap percent of healbar: "..LunaOptions.overheal)
	LunaUnitFrames:UpdatePlayerFrame()
	LunaUnitFrames:UpdateTargetFrame()
	LunaUnitFrames:UpdatePartyFrames()
end

function OptionFunctions.ToggleColorNames()
	if not LunaOptions.colornames then
		LunaOptions.colornames = 1
	else
		LunaOptions.colornames = nil
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.ToggleInvertHealthBars()
	if not LunaOptions.frames["LunaRaidFrames"].inverthealth then
		LunaOptions.frames["LunaRaidFrames"].inverthealth = 1
	else
		LunaOptions.frames["LunaRaidFrames"].inverthealth = nil
	end
	LunaUnitFrames:UpdateRaidRoster()
end

function OptionFunctions.ToggleInvertGrowth()
	if not LunaOptions.frames["LunaRaidFrames"].invertgrowth then
		LunaOptions.frames["LunaRaidFrames"].invertgrowth = 1
	else
		LunaOptions.frames["LunaRaidFrames"].invertgrowth = nil
	end
	LunaUnitFrames:UpdateRaidLayout()
end

function OptionFunctions.TogglePetGroup()
	if not LunaOptions.frames["LunaRaidFrames"].petgroup then
		LunaOptions.frames["LunaRaidFrames"].petgroup = 1
	else
		LunaOptions.frames["LunaRaidFrames"].petgroup = nil
	end
	LunaUnitFrames:UpdatePetRoster()
end

function OptionFunctions.StaticPlayerCastbar()
	if not LunaOptions.staticplayercastbar then
		LunaOptions.staticplayercastbar = 1
	else
		LunaOptions.staticplayercastbar = nil
	end
	LunaPlayerFrame.AdjustBars()
end

function OptionFunctions.StaticTotembar()
	if not LunaOptions.statictotembar then
		LunaOptions.statictotembar = 1
	else
		LunaOptions.statictotembar = nil
	end
	LunaPlayerFrame.AdjustBars()
end

function OptionFunctions.StaticTargetCastbar()
	if not LunaOptions.statictargetcastbar then
		LunaOptions.statictargetcastbar = 1
	else
		LunaOptions.statictargetcastbar = nil
	end
	LunaTargetFrame.AdjustBars()
end

function LunaOptionsModule:CreateMenu()
	LunaOptionsFrame = CreateFrame("Frame", "LunaOptionsMenu", UIParent)
	LunaOptionsFrame:SetHeight(400)
	LunaOptionsFrame:SetWidth(700)
	LunaOptionsFrame:SetBackdrop(LunaOptions.backdrop)
	LunaOptionsFrame:SetBackdropColor(0.18,0.27,0.5)
	LunaOptionsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	LunaOptionsFrame:SetFrameStrata("DIALOG")
	LunaOptionsFrame:EnableMouse(1)
	LunaOptionsFrame:SetMovable(1)
	LunaOptionsFrame:RegisterForDrag("LeftButton")
	LunaOptionsFrame:SetScript("OnDragStart", OptionFunctions.StartMoving)
	LunaOptionsFrame:SetScript("OnDragStop", OptionFunctions.StopMovingOrSizing)
	LunaOptionsFrame:Hide()

	LunaOptionsFrame.CloseButton = CreateFrame("Button", "LunaOptionsCloseButton", LunaOptionsFrame,"UIPanelCloseButton")
	LunaOptionsFrame.CloseButton:SetPoint("TOPRIGHT", LunaOptionsFrame, "TOPRIGHT", 0, 0)

	LunaOptionsFrame.icon = LunaOptionsFrame:CreateTexture(nil, "ARTWORK", LunaOptionsFrame)
	LunaOptionsFrame.icon:SetTexture(LunaOptions.icontexture)
	LunaOptionsFrame.icon:SetHeight(64)
	LunaOptionsFrame.icon:SetWidth(64)
	LunaOptionsFrame.icon:SetPoint("TOPLEFT", LunaOptionsFrame, "TOPLEFT", 0, 0)

	LunaOptionsFrame.name = LunaOptionsFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
	LunaOptionsFrame.name:SetPoint("TOP", LunaOptionsFrame, "TOP", 0, -10)
	LunaOptionsFrame.name:SetShadowColor(0, 0, 0)
	LunaOptionsFrame.name:SetShadowOffset(0.8, -0.8)
	LunaOptionsFrame.name:SetTextColor(1,1,1)
	LunaOptionsFrame.name:SetText("LUNA UNIT FRAMES")
	
	LunaOptionsFrame.version = LunaOptionsFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	LunaOptionsFrame.version:SetPoint("BOTTOMLEFT", LunaOptionsFrame.name, "BOTTOMRIGHT", 10, 5)
	LunaOptionsFrame.version:SetShadowColor(0, 0, 0)
	LunaOptionsFrame.version:SetShadowOffset(0.8, -0.8)
	if tonumber(LunaOptions.version) > tonumber(LunaUnitFrames.version) then
		LunaOptionsFrame.version:SetTextColor(1,0,0)
		LunaOptionsFrame.version:SetText("V."..LunaUnitFrames.version.."(Outdated)")
	else
		LunaOptionsFrame.version:SetTextColor(0,1,1)
		LunaOptionsFrame.version:SetText("V."..LunaUnitFrames.version)
	end
	
	LunaOptionsFrame.help = CreateFrame("Button", nil, LunaOptionsFrame)
	LunaOptionsFrame.help:SetHeight(14)
	LunaOptionsFrame.help:SetWidth(14)
	LunaOptionsFrame.help:SetPoint("RIGHT", LunaOptionsFrame.CloseButton, "LEFT", -5, 0)
	LunaOptionsFrame.help:SetScript("OnEnter", function() LunaOptionsFrame.helpframe:Show() end)
	LunaOptionsFrame.help:SetScript("OnLeave", function() LunaOptionsFrame.helpframe:Hide() end)
	
	LunaOptionsFrame.help.text = LunaOptionsFrame.help:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	LunaOptionsFrame.help.text:SetPoint("CENTER", LunaOptionsFrame.help, "CENTER")
	LunaOptionsFrame.help.text:SetTextColor(1,1,1)
	LunaOptionsFrame.help.text:SetText("[?]")
	LunaOptionsFrame.help.text:SetJustifyH("CENTER")
	LunaOptionsFrame.help.text:SetJustifyV("MIDDLE")

	LunaOptionsFrame.pages = {}
	LunaOptionsFrame.ScrollFrames = {}
	LunaOptionsFrame.Sliders = {}

	for i, v in pairs(OptionsPageNames) do
		LunaOptionsFrame.ScrollFrames[i] = CreateFrame("ScrollFrame", nil, LunaOptionsFrame)
		LunaOptionsFrame.ScrollFrames[i]:SetHeight(350)
		LunaOptionsFrame.ScrollFrames[i]:SetWidth(500)
		
		LunaOptionsFrame.ScrollFrames[i]:SetPoint("BOTTOMRIGHT", LunaOptionsFrame, "BOTTOMRIGHT", -30, 10)
		LunaOptionsFrame.ScrollFrames[i]:Hide()
		LunaOptionsFrame.ScrollFrames[i]:EnableMouseWheel(true)
		LunaOptionsFrame.ScrollFrames[i].id = i
		LunaOptionsFrame.ScrollFrames[i]:SetBackdrop(LunaOptions.backdrop)
		LunaOptionsFrame.ScrollFrames[i]:SetBackdropColor(0,0,0,1)
		LunaOptionsFrame.ScrollFrames[i]:SetScript("OnMouseWheel", function()
																		local maxScroll = this:GetVerticalScrollRange()
																		local Scroll = this:GetVerticalScroll()
																		local toScroll = (Scroll - (20*arg1))
																		if toScroll < 0 then
																			this:SetVerticalScroll(0)
																		elseif toScroll > maxScroll then
																			this:SetVerticalScroll(maxScroll)
																		else
																			this:SetVerticalScroll(toScroll)
																		end
																		local script = LunaOptionsFrame.Sliders[this.id]:GetScript("OnValueChanged")
																		LunaOptionsFrame.Sliders[this.id]:SetScript("OnValueChanged", nil)
																		LunaOptionsFrame.Sliders[this.id]:SetValue(toScroll/maxScroll)
																		LunaOptionsFrame.Sliders[this.id]:SetScript("OnValueChanged", script)
																	end)
		
		LunaOptionsFrame.Sliders[i] = CreateFrame("Slider", nil, LunaOptionsFrame.ScrollFrames[i])
		LunaOptionsFrame.Sliders[i]:SetOrientation("VERTICAL")
		LunaOptionsFrame.Sliders[i]:SetPoint("TOPLEFT", LunaOptionsFrame.ScrollFrames[i], "TOPRIGHT", 5, 0)
		LunaOptionsFrame.Sliders[i]:SetBackdrop(LunaOptions.backdrop)
		LunaOptionsFrame.Sliders[i]:SetBackdropColor(0,0,0,0.5)
		LunaOptionsFrame.Sliders[i].thumbtexture = LunaOptionsFrame.Sliders[i]:CreateTexture()
		LunaOptionsFrame.Sliders[i].thumbtexture:SetTexture(0.18,0.27,0.5,1)
		LunaOptionsFrame.Sliders[i]:SetThumbTexture(LunaOptionsFrame.Sliders[i].thumbtexture)
		LunaOptionsFrame.Sliders[i]:SetMinMaxValues(0,1)
		LunaOptionsFrame.Sliders[i]:SetHeight(348)
		LunaOptionsFrame.Sliders[i]:SetWidth(15)
		LunaOptionsFrame.Sliders[i]:SetValue(0)
		LunaOptionsFrame.Sliders[i].ScrollFrame = LunaOptionsFrame.ScrollFrames[i]
		LunaOptionsFrame.Sliders[i]:SetScript("OnValueChanged", function() this.ScrollFrame:SetVerticalScroll(this.ScrollFrame:GetVerticalScrollRange()*this:GetValue()) end  )
	
		LunaOptionsFrame.pages[i] = CreateFrame("Frame", v.title.." Page", LunaOptionsFrame.ScrollFrames[i])
		LunaOptionsFrame.pages[i]:SetHeight(1)
		LunaOptionsFrame.pages[i]:SetWidth(500)
		
		LunaOptionsFrame.pages[i].name = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[i])
		LunaOptionsFrame.pages[i].name:SetPoint("TOP", LunaOptionsFrame.pages[i], "TOP", 0, -10)
		LunaOptionsFrame.pages[i].name:SetFont(LunaOptions.font, 15)
		LunaOptionsFrame.pages[i].name:SetShadowColor(0, 0, 0)
		LunaOptionsFrame.pages[i].name:SetShadowOffset(0.8, -0.8)
		LunaOptionsFrame.pages[i].name:SetTextColor(1,1,1)
		LunaOptionsFrame.pages[i].name:SetText(v.title.." Configuration")
		
		LunaOptionsFrame.pages[i].frame = v.frame
		LunaOptionsFrame.ScrollFrames[i]:SetScrollChild(LunaOptionsFrame.pages[i])
				
		if i < 9 then
			LunaOptionsFrame.pages[i].enablebutton = CreateFrame("CheckButton", v.title.."EnableButton", LunaOptionsFrame.pages[i], "UICheckButtonTemplate")
			LunaOptionsFrame.pages[i].enablebutton:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i], "TOPLEFT", 10, -10)
			LunaOptionsFrame.pages[i].enablebutton:SetHeight(20)
			LunaOptionsFrame.pages[i].enablebutton:SetWidth(20)
			LunaOptionsFrame.pages[i].enablebutton:SetScript("OnClick", OptionFunctions.enableFrame)
			LunaOptionsFrame.pages[i].enablebutton:SetChecked(LunaOptions.frames[v.frame].enabled)
			getglobal(v.title.."EnableButtonText"):SetText("Enable")
			
			LunaOptionsFrame.pages[i].heightslider = CreateFrame("Slider", v.frame.."HeightSlider", LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
			LunaOptionsFrame.pages[i].heightslider:SetMinMaxValues(15,110)
			LunaOptionsFrame.pages[i].heightslider:SetValueStep(1)
			LunaOptionsFrame.pages[i].heightslider:SetScript("OnValueChanged", OptionFunctions.HeightAdjust)
			LunaOptionsFrame.pages[i].heightslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i], "TOPLEFT", 20, -40)
			LunaOptionsFrame.pages[i].heightslider:SetValue(LunaOptions.frames[v.frame].size.y)
			LunaOptionsFrame.pages[i].heightslider:SetWidth(460)
			getglobal(v.frame.."HeightSliderText"):SetText("Height: "..LunaOptions.frames[v.frame].size.y)

			LunaOptionsFrame.pages[i].widthslider = CreateFrame("Slider", v.frame.."WidthSlider", LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
			LunaOptionsFrame.pages[i].widthslider:SetMinMaxValues(50,400)
			LunaOptionsFrame.pages[i].widthslider:SetValueStep(1)
			LunaOptionsFrame.pages[i].widthslider:SetScript("OnValueChanged", OptionFunctions.WidthAdjust)
			LunaOptionsFrame.pages[i].widthslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].heightslider, "TOPLEFT", 0, -40)
			LunaOptionsFrame.pages[i].widthslider:SetValue(LunaOptions.frames[v.frame].size.x)
			LunaOptionsFrame.pages[i].widthslider:SetWidth(460)
			getglobal(v.frame.."WidthSliderText"):SetText("Width: "..LunaOptions.frames[v.frame].size.x)
			
			LunaOptionsFrame.pages[i].scaleslider = CreateFrame("Slider", v.frame.."ScaleSlider", LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
			LunaOptionsFrame.pages[i].scaleslider:SetMinMaxValues(0.5,2)
			LunaOptionsFrame.pages[i].scaleslider:SetValueStep(0.1)
			LunaOptionsFrame.pages[i].scaleslider:SetScript("OnValueChanged", OptionFunctions.ScaleAdjust)
			LunaOptionsFrame.pages[i].scaleslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].widthslider, "TOPLEFT", 0, -40)
			LunaOptionsFrame.pages[i].scaleslider:SetValue(LunaOptions.frames[v.frame].scale)
			LunaOptionsFrame.pages[i].scaleslider:SetWidth(460)
			getglobal(v.frame.."ScaleSliderText"):SetText("Scale: "..LunaOptions.frames[v.frame].scale)
		end
	end	
	LunaOptionsFrame.ScrollFrames[1]:Show()
		
	LunaOptionsFrame.Button0 = CreateFrame("Button", "LunaPlayerFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button0:SetPoint("TOPLEFT", LunaOptionsFrame, "TOPLEFT", 30, -70)
	LunaOptionsFrame.Button0:SetHeight(20)
	LunaOptionsFrame.Button0:SetWidth(140)
	LunaOptionsFrame.Button0:SetText("Player Frame")
	LunaOptionsFrame.Button0:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button0.id = 0
	
	LunaOptionsFrame.Button1 = CreateFrame("Button", "LunaPlayerFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button1:SetPoint("TOPLEFT", LunaOptionsFrame.Button0, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button1:SetHeight(20)
	LunaOptionsFrame.Button1:SetWidth(140)
	LunaOptionsFrame.Button1:SetText("Pet Frame")
	LunaOptionsFrame.Button1:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button1.id = 1

	LunaOptionsFrame.Button2 = CreateFrame("Button", "LunaTargetFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button2:SetPoint("TOPLEFT", LunaOptionsFrame.Button1, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button2:SetHeight(20)
	LunaOptionsFrame.Button2:SetWidth(140)
	LunaOptionsFrame.Button2:SetText("Target Frame")
	LunaOptionsFrame.Button2:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button2.id = 2

	LunaOptionsFrame.Button3 = CreateFrame("Button", "LunaTargetTargetFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button3:SetPoint("TOPLEFT", LunaOptionsFrame.Button2, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button3:SetHeight(20)
	LunaOptionsFrame.Button3:SetWidth(140)
	LunaOptionsFrame.Button3:SetText("ToT Frame")
	LunaOptionsFrame.Button3:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button3.id = 3

	LunaOptionsFrame.Button4 = CreateFrame("Button", "LunaTargetTargetTargetFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button4:SetPoint("TOPLEFT", LunaOptionsFrame.Button3, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button4:SetHeight(20)
	LunaOptionsFrame.Button4:SetWidth(140)
	LunaOptionsFrame.Button4:SetText("ToToT Frame")
	LunaOptionsFrame.Button4:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button4.id = 4
	
	LunaOptionsFrame.Button5 = CreateFrame("Button", "LunaPartyFramesButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button5:SetPoint("TOPLEFT", LunaOptionsFrame.Button4, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button5:SetHeight(20)
	LunaOptionsFrame.Button5:SetWidth(140)
	LunaOptionsFrame.Button5:SetText("Party Frames")
	LunaOptionsFrame.Button5:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button5.id = 5

	LunaOptionsFrame.Button6 = CreateFrame("Button", "LunaPartyPetsFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button6:SetPoint("TOPLEFT", LunaOptionsFrame.Button5, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button6:SetHeight(20)
	LunaOptionsFrame.Button6:SetWidth(140)
	LunaOptionsFrame.Button6:SetText("Party Pets")
	LunaOptionsFrame.Button6:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button6.id = 6
	
	LunaOptionsFrame.Button7 = CreateFrame("Button", "LunaPartyTargetsFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button7:SetPoint("TOPLEFT", LunaOptionsFrame.Button6, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button7:SetHeight(20)
	LunaOptionsFrame.Button7:SetWidth(140)
	LunaOptionsFrame.Button7:SetText("Party Targets")
	LunaOptionsFrame.Button7:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button7.id = 7
	
	LunaOptionsFrame.Button8 = CreateFrame("Button", "LunaRaidFrameButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button8:SetPoint("TOPLEFT", LunaOptionsFrame.Button7, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button8:SetHeight(20)
	LunaOptionsFrame.Button8:SetWidth(140)
	LunaOptionsFrame.Button8:SetText("Raid Frames")
	LunaOptionsFrame.Button8:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button8.id = 8
	
	LunaOptionsFrame.Button9 = CreateFrame("Button", "LunaGeneralButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button9:SetPoint("TOPLEFT", LunaOptionsFrame.Button8, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button9:SetHeight(20)
	LunaOptionsFrame.Button9:SetWidth(140)
	LunaOptionsFrame.Button9:SetText("General Settings")
	LunaOptionsFrame.Button9:SetScript("OnClick", OptionFunctions.ToggleFrame)
	LunaOptionsFrame.Button9.id = 9	

	LunaOptionsFrame.Button10 = CreateFrame("Button", "LunaLockFramesButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button10:SetPoint("TOPLEFT", LunaOptionsFrame.Button9, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.Button10:SetHeight(20)
	LunaOptionsFrame.Button10:SetWidth(140)
	LunaOptionsFrame.Button10:SetText("Unlock Frames")
	LunaOptionsFrame.Button10:SetScript("OnClick", OptionFunctions.LockFrames)
	LunaOptionsFrame.Button10.id = 10	
	
	LunaOptionsFrame.Button11 = CreateFrame("Button", "LunaCCCButton", LunaOptionsFrame, "UIPanelButtonTemplate")
	LunaOptionsFrame.Button11:SetPoint("TOPLEFT", LunaOptionsFrame.Button10, "BOTTOMLEFT", 0, -5)
	LunaOptionsFrame.Button11:SetHeight(20)
	LunaOptionsFrame.Button11:SetWidth(140)
	LunaOptionsFrame.Button11:SetText("Click casting...")
	LunaOptionsFrame.Button11:SetScript("OnClick", OptionFunctions.OpenCCC)
	LunaOptionsFrame.Button11.id = 11

	for i=1, 6 do
		LunaOptionsFrame.pages[i].BuffPosition = CreateFrame("Button", "BuffSwitch"..i, LunaOptionsFrame.pages[i], "UIDropDownMenuTemplate")
		LunaOptionsFrame.pages[i].BuffPosition:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].scaleslider, "BOTTOMLEFT", -20 , -10)
		UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[i].BuffPosition)
		UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[i].BuffPosition)
		
		UIDropDownMenu_Initialize(LunaOptionsFrame.pages[i].BuffPosition, buffposselectfunc[i])
		UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[i].BuffPosition, LunaOptions.frames[OptionsPageNames[i].frame].ShowBuffs)
		
		LunaOptionsFrame.pages[i].BuffSwitchDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[i])
		LunaOptionsFrame.pages[i].BuffSwitchDesc:SetPoint("LEFT", LunaOptionsFrame.pages[i].BuffPosition, "RIGHT", -10, 0)
		LunaOptionsFrame.pages[i].BuffSwitchDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
		LunaOptionsFrame.pages[i].BuffSwitchDesc:SetTextColor(1,0.82,0)
		LunaOptionsFrame.pages[i].BuffSwitchDesc:SetText("Aura Position")
		
		LunaOptionsFrame.pages[i].BarSelect = CreateFrame("Button", "BarSelector"..i, LunaOptionsFrame.pages[i], "UIDropDownMenuTemplate")
		LunaOptionsFrame.pages[i].BarSelect:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[i].scaleslider, "BOTTOMRIGHT", -150 , -10)
		UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[i].BarSelect)
		UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[i].BarSelect)

		UIDropDownMenu_Initialize(LunaOptionsFrame.pages[i].BarSelect, barselectorfunc[i])
		UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[i].BarSelect, 1)
		
		LunaOptionsFrame.pages[i].BuffInRowslider = CreateFrame("Slider", OptionsPageNames[i].frame.."BuffInRow", LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].BuffInRowslider:SetMinMaxValues(1,16)
		LunaOptionsFrame.pages[i].BuffInRowslider:SetValueStep(1)
		LunaOptionsFrame.pages[i].BuffInRowslider:SetScript("OnValueChanged", OptionFunctions.BuffInRow)
		LunaOptionsFrame.pages[i].BuffInRowslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].BuffPosition, "BOTTOMLEFT", 20, -6)
		LunaOptionsFrame.pages[i].BuffInRowslider:SetValue(LunaOptions.frames[OptionsPageNames[i].frame].BuffInRow or 16)
		LunaOptionsFrame.pages[i].BuffInRowslider:SetWidth(180)
		getglobal(OptionsPageNames[i].frame.."BuffInRowText"):SetText("Auras per row: "..(LunaOptions.frames[OptionsPageNames[i].frame].BuffInRow or 16))
		
		LunaOptionsFrame.pages[i].barheight = CreateFrame("Slider", "BarSizer"..i, LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].barheight:SetMinMaxValues(0,10)
		LunaOptionsFrame.pages[i].barheight:SetValueStep(1)
		LunaOptionsFrame.pages[i].barheight:SetScript("OnValueChanged", OnBarHeight)
		LunaOptionsFrame.pages[i].barheight:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].BarSelect, "BOTTOMLEFT", 10, -5)
		LunaOptionsFrame.pages[i].barheight:SetWidth(270)
		getglobal("BarSizer"..i.."Text"):SetText("Bar height weight: "..LunaOptionsFrame.pages[i].barheight:GetValue())
		
		LunaOptionsFrame.pages[i].barorder = CreateFrame("Slider", "BarOrderSlider"..i, LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].barorder:SetMinMaxValues(1,table.getn(LunaOptions.frames[OptionsPageNames[i].frame].bars))
		LunaOptionsFrame.pages[i].barorder:SetValueStep(1)
		LunaOptionsFrame.pages[i].barorder:SetScript("OnValueChanged", OptionFunctions.OnOrderSlider)
		LunaOptionsFrame.pages[i].barorder:SetPoint("TOP", LunaOptionsFrame.pages[i].barheight, "BOTTOM", 0, -10)
		LunaOptionsFrame.pages[i].barorder:SetWidth(270)
		getglobal("BarOrderSlider"..i.."Text"):SetText("Bar Position: "..LunaOptionsFrame.pages[i].barorder:GetValue())
		
		LunaOptionsFrame.pages[i].lefttext = CreateFrame("Editbox", "LeftTextInput"..i, LunaOptionsFrame.pages[i], "InputBoxTemplate")
		LunaOptionsFrame.pages[i].lefttext:SetHeight(20)
		LunaOptionsFrame.pages[i].lefttext:SetWidth(125)
		LunaOptionsFrame.pages[i].lefttext:SetAutoFocus(nil)
		LunaOptionsFrame.pages[i].lefttext:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].barorder, "BOTTOMLEFT", 5, -30)
		LunaOptionsFrame.pages[i].lefttext:SetScript("OnEnterPressed", function()
																			this:ClearFocus()
																			local fontstring = this:GetText()
																			local selection = UIDropDownMenu_GetText(this:GetParent().BarSelect)
																			local framename = this:GetParent().frame
																			local textsize = this:GetParent().textsize:GetValue()
																			local bars = LunaOptions.frames[framename].bars
																			local frame = getglobal(framename)
																			local otherfontstring = this:GetParent().righttext:GetText()
																			for k,v in pairs(LunaOptions.frames[framename].bars) do
																				if v[1] == selection then
																					v[3] = textsize
																					v[4] = fontstring
																					v[5] = otherfontstring
																					break
																				end
																			end
																			if framename == "LunaPartyFrames" then
																				for i=1,4 do
																					LunaUnitFrames:RegisterFontstring(LunaPartyFrames[i].bars[selection].lefttext, "party"..i, fontstring)
																				end
																			else
																				LunaUnitFrames:RegisterFontstring(frame.bars[selection].lefttext, frame.unit, fontstring)
																			end
																		end)

		LunaOptionsFrame.pages[i].leftDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[i])
		LunaOptionsFrame.pages[i].leftDesc:SetPoint("BOTTOMLEFT", LunaOptionsFrame.pages[i].lefttext, "TOPLEFT", 0, 5)
		LunaOptionsFrame.pages[i].leftDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
		LunaOptionsFrame.pages[i].leftDesc:SetTextColor(1,0.82,0)
		LunaOptionsFrame.pages[i].leftDesc:SetText("Left Text")

		LunaOptionsFrame.pages[i].righttext = CreateFrame("Editbox", "RightTextInput"..i, LunaOptionsFrame.pages[i], "InputBoxTemplate")
		LunaOptionsFrame.pages[i].righttext:SetHeight(20)
		LunaOptionsFrame.pages[i].righttext:SetWidth(125)
		LunaOptionsFrame.pages[i].righttext:SetAutoFocus(nil)
		LunaOptionsFrame.pages[i].righttext:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[i].barorder, "BOTTOMRIGHT", 0, -30)
		LunaOptionsFrame.pages[i].righttext:SetScript("OnEnterPressed", function()
																			this:ClearFocus()
																			local fontstring = this:GetText()
																			local selection = UIDropDownMenu_GetText(this:GetParent().BarSelect)
																			local framename = this:GetParent().frame
																			local textsize = this:GetParent().textsize:GetValue()
																			local bars = LunaOptions.frames[framename].bars
																			local frame = getglobal(framename)
																			local otherfontstring = this:GetParent().lefttext:GetText()
																			for k,v in pairs(LunaOptions.frames[framename].bars) do
																				if v[1] == selection then
																					v[3] = textsize
																					v[4] = otherfontstring
																					v[5] = fontstring
																					break
																				end
																			end
																			if framename == "LunaPartyFrames" then
																				for i=1,4 do
																					LunaUnitFrames:RegisterFontstring(LunaPartyFrames[i].bars[selection].righttext, "party"..i, fontstring)
																				end
																			else
																				LunaUnitFrames:RegisterFontstring(frame.bars[selection].righttext, frame.unit, fontstring)
																			end
																		end)
																		

		LunaOptionsFrame.pages[i].rightDesc = LunaOptionsFrame.pages[i]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[i])
		LunaOptionsFrame.pages[i].rightDesc:SetPoint("BOTTOMRIGHT", LunaOptionsFrame.pages[i].righttext, "TOPRIGHT", 0, 5)
		LunaOptionsFrame.pages[i].rightDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
		LunaOptionsFrame.pages[i].rightDesc:SetTextColor(1,0.82,0)
		LunaOptionsFrame.pages[i].rightDesc:SetText("Right Text")

		LunaOptionsFrame.pages[i].textsize = CreateFrame("Slider", "TextSizeSlider"..i, LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].textsize:SetMinMaxValues(0.05,1)
		LunaOptionsFrame.pages[i].textsize:SetValueStep(0.01)
		LunaOptionsFrame.pages[i].textsize:SetScript("OnValueChanged", OptionFunctions.OnTextSlider)
		LunaOptionsFrame.pages[i].textsize:SetPoint("TOPLEFT", LunaOptionsFrame.pages[i].lefttext, "BOTTOMLEFT", -5, -10)
		LunaOptionsFrame.pages[i].textsize:SetWidth(270)
		getglobal("TextSizeSlider"..i.."Text"):SetText("Text Size: "..LunaOptionsFrame.pages[i].textsize:GetValue())
		
		LunaOptionsFrame.pages[i].textbalance = CreateFrame("Slider", "TextBalanceSlider"..i, LunaOptionsFrame.pages[i], "OptionsSliderTemplate")
		LunaOptionsFrame.pages[i].textbalance:SetMinMaxValues(0.1,0.9)
		LunaOptionsFrame.pages[i].textbalance:SetValueStep(0.01)
		LunaOptionsFrame.pages[i].textbalance:SetScript("OnValueChanged", OptionFunctions.OnTextBalanceSlider)
		LunaOptionsFrame.pages[i].textbalance:SetPoint("TOP", LunaOptionsFrame.pages[i].textsize, "BOTTOM", 0, -10)
		LunaOptionsFrame.pages[i].textbalance:SetWidth(270)
		getglobal("TextBalanceSlider"..i.."Text"):SetText("Text Balance")
		
		local selection = UIDropDownMenu_GetText(LunaOptionsFrame.pages[i].BarSelect)
		for k,v in pairs(LunaOptions.frames[OptionsPageNames[i].frame].bars) do
			if v[1] == selection then
				LunaOptionsFrame.pages[i].barheight:SetValue(v[2])
				LunaOptionsFrame.pages[i].barorder:SetValue(k)
				if selection == "Healthbar" or selection == "Powerbar" then
					LunaOptionsFrame.pages[i].lefttext:EnableMouse(1)
					LunaOptionsFrame.pages[i].righttext:EnableMouse(1)
				else
					LunaOptionsFrame.pages[i].lefttext:EnableMouse(nil)
					LunaOptionsFrame.pages[i].righttext:EnableMouse(nil)
				end
				LunaOptionsFrame.pages[i].lefttext:SetText(v[4] or LunaOptions.defaultTags[selection][1])
				LunaOptionsFrame.pages[i].righttext:SetText(v[5] or LunaOptions.defaultTags[selection][2])
				LunaOptionsFrame.pages[i].textsize:SetValue(v[3] or 0.45)
				LunaOptionsFrame.pages[i].textbalance:SetValue(v[6] or 0.5)
				break
			end
		end
	end
	
	LunaOptionsFrame.pages[1].staticcbar = CreateFrame("CheckButton", "StaticCBarSwitch", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].staticcbar:SetHeight(20)
	LunaOptionsFrame.pages[1].staticcbar:SetWidth(20)
	LunaOptionsFrame.pages[1].staticcbar:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1].BuffInRowslider, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[1].staticcbar:SetScript("OnClick", OptionFunctions.StaticPlayerCastbar)
	LunaOptionsFrame.pages[1].staticcbar:SetChecked(LunaOptions.staticplayercastbar)
	getglobal("StaticCBarSwitchText"):SetText("Don\'t hide the castbar.")
	
	LunaOptionsFrame.pages[1].statictbar = CreateFrame("CheckButton", "StaticTBarSwitch", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].statictbar:SetHeight(20)
	LunaOptionsFrame.pages[1].statictbar:SetWidth(20)
	LunaOptionsFrame.pages[1].statictbar:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1].staticcbar, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[1].statictbar:SetScript("OnClick", OptionFunctions.StaticTotembar)
	LunaOptionsFrame.pages[1].statictbar:SetChecked(LunaOptions.statictotembar)
	getglobal("StaticTBarSwitchText"):SetText("Don\'t hide the totembar.")

	LunaOptionsFrame.pages[1].Portraitmode = CreateFrame("CheckButton", "PortraitmodePlayer", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].Portraitmode:SetHeight(20)
	LunaOptionsFrame.pages[1].Portraitmode:SetWidth(20)
	LunaOptionsFrame.pages[1].Portraitmode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1].statictbar, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[1].Portraitmode:SetScript("OnClick", OptionFunctions.PortraitmodeToggle)
	LunaOptionsFrame.pages[1].Portraitmode:SetChecked((LunaOptions.frames["LunaPlayerFrame"].portrait == 1))
	getglobal("PortraitmodePlayerText"):SetText("Display Portrait as Bar")
	
	LunaOptionsFrame.pages[1].EnergyTicker = CreateFrame("CheckButton", "EnergyTicker", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].EnergyTicker:SetHeight(20)
	LunaOptionsFrame.pages[1].EnergyTicker:SetWidth(20)
	LunaOptionsFrame.pages[1].EnergyTicker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1].Portraitmode, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[1].EnergyTicker:SetScript("OnClick", OptionFunctions.EnergyTickerToggle)
	LunaOptionsFrame.pages[1].EnergyTicker:SetChecked(LunaOptions.EnergyTicker)
	getglobal("EnergyTickerText"):SetText("Enable Energy Ticker")
	
	LunaOptionsFrame.pages[1].fsTicker = CreateFrame("CheckButton", "fsTicker", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].fsTicker:SetHeight(20)
	LunaOptionsFrame.pages[1].fsTicker:SetWidth(20)
	LunaOptionsFrame.pages[1].fsTicker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1].EnergyTicker, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[1].fsTicker:SetScript("OnClick", OptionFunctions.fsTickerToggle)
	LunaOptionsFrame.pages[1].fsTicker:SetChecked(LunaOptions.fsTicker)
	getglobal("fsTickerText"):SetText("Enable 5sec Rule")
	
	LunaOptionsFrame.pages[1].XPBar = CreateFrame("CheckButton", "XPBarSwitch", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].XPBar:SetHeight(20)
	LunaOptionsFrame.pages[1].XPBar:SetWidth(20)
	LunaOptionsFrame.pages[1].XPBar:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[1].fsTicker, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[1].XPBar:SetScript("OnClick", OptionFunctions.XPBarToggle)
	LunaOptionsFrame.pages[1].XPBar:SetChecked(LunaOptions.XPBar)
	getglobal("XPBarSwitchText"):SetText("Enable XP Bar")
	
	LunaOptionsFrame.pages[1].RepBar = CreateFrame("CheckButton", "RepBarSwitch", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].RepBar:SetHeight(20)
	LunaOptionsFrame.pages[1].RepBar:SetWidth(20)
	LunaOptionsFrame.pages[1].RepBar:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[1].XPBar, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[1].RepBar:SetScript("OnClick", OptionFunctions.RepBarToggle)
	LunaOptionsFrame.pages[1].RepBar:SetChecked(LunaOptions.RepBar)
	getglobal("RepBarSwitchText"):SetText("Enable Reputation Bar")
	
	LunaOptionsFrame.pages[1].bufftimer = CreateFrame("CheckButton", "BTimerSwitch", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].bufftimer:SetHeight(20)
	LunaOptionsFrame.pages[1].bufftimer:SetWidth(20)
	LunaOptionsFrame.pages[1].bufftimer:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[1].RepBar, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[1].bufftimer:SetScript("OnClick", OptionFunctions.BTimerToggle)
	LunaOptionsFrame.pages[1].bufftimer:SetChecked(LunaOptions.BTimers or 0)
	getglobal("BTimerSwitchText"):SetText("Enable radial buff timers")
	
	LunaOptionsFrame.pages[1].combattext = CreateFrame("CheckButton", "PlayerCombatTextSwitch", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].combattext:SetHeight(20)
	LunaOptionsFrame.pages[1].combattext:SetWidth(20)
	LunaOptionsFrame.pages[1].combattext:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[1].bufftimer, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[1].combattext:SetScript("OnClick", OptionFunctions.PlayerCombatTextToggle)
	LunaOptionsFrame.pages[1].combattext:SetChecked(LunaOptions.frames["LunaPlayerFrame"].combattext or 0)
	getglobal("PlayerCombatTextSwitchText"):SetText("Enable Combat Text on Portrait")
	
	LunaOptionsFrame.pages[1].combaticon = CreateFrame("CheckButton", "CombatIconSwitch", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].combaticon:SetHeight(20)
	LunaOptionsFrame.pages[1].combaticon:SetWidth(20)
	LunaOptionsFrame.pages[1].combaticon:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[1].combattext, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[1].combaticon:SetScript("OnClick", OptionFunctions.PlayerCombatIconToggle)
	LunaOptionsFrame.pages[1].combaticon:SetChecked(LunaOptions.frames["LunaPlayerFrame"].combaticon or 0)
	getglobal("CombatIconSwitchText"):SetText("Enable Combat/Resting Icon")

	LunaOptionsFrame.pages[1].pvprankicon = CreateFrame("CheckButton", "PvPRankIconSwitch", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].pvprankicon:SetHeight(20)
	LunaOptionsFrame.pages[1].pvprankicon:SetWidth(20)
	LunaOptionsFrame.pages[1].pvprankicon:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[1].combaticon, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[1].pvprankicon:SetScript("OnClick", OptionFunctions.PlayerPvPRankIconToggle)
	LunaOptionsFrame.pages[1].pvprankicon:SetChecked(LunaOptions.frames["LunaPlayerFrame"].pvprankicon or 0)
	getglobal("PvPRankIconSwitchText"):SetText("Enable PvP Rank Icon")
	
	LunaOptionsFrame.pages[1].leadericon = CreateFrame("CheckButton", "LeaderIconSwitch", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].leadericon:SetHeight(20)
	LunaOptionsFrame.pages[1].leadericon:SetWidth(20)
	LunaOptionsFrame.pages[1].leadericon:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[1].pvprankicon, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[1].leadericon:SetScript("OnClick", OptionFunctions.PlayerLeaderIconToggle)
	LunaOptionsFrame.pages[1].leadericon:SetChecked(LunaOptions.frames["LunaPlayerFrame"].leadericon or 0)
	getglobal("LeaderIconSwitchText"):SetText("Enable Leader Icon")
	
	LunaOptionsFrame.pages[1].looticon = CreateFrame("CheckButton", "LootIconSwitch", LunaOptionsFrame.pages[1], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[1].looticon:SetHeight(20)
	LunaOptionsFrame.pages[1].looticon:SetWidth(20)
	LunaOptionsFrame.pages[1].looticon:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[1].leadericon, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[1].looticon:SetScript("OnClick", OptionFunctions.PlayerLootIconToggle)
	LunaOptionsFrame.pages[1].looticon:SetChecked(LunaOptions.frames["LunaPlayerFrame"].looticon or 0)
	getglobal("LootIconSwitchText"):SetText("Enable Loot Icon")
	
	LunaOptionsFrame.pages[1].iconsize = CreateFrame("Slider", "PlayerIconSizeSlider", LunaOptionsFrame.pages[1], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[1].iconsize:SetMinMaxValues(0.01,2)
	LunaOptionsFrame.pages[1].iconsize:SetValueStep(0.01)
	LunaOptionsFrame.pages[1].iconsize:SetScript("OnValueChanged", OptionFunctions.PlayerIconSizeAdjust)
	LunaOptionsFrame.pages[1].iconsize:SetPoint("TOPLEFT", LunaOptionsFrame.pages[1].looticon, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[1].iconsize:SetValue(LunaOptions.frames["LunaPlayerFrame"].iconscale or 1)
	LunaOptionsFrame.pages[1].iconsize:SetWidth(180)
	getglobal("PlayerIconSizeSliderText"):SetText("Status Icon Size: "..(LunaOptions.frames["LunaPlayerFrame"].iconscale or 1))
	
	LunaOptionsFrame.pages[2].Portraitmode = CreateFrame("CheckButton", "PortraitmodePet", LunaOptionsFrame.pages[2], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[2].Portraitmode:SetHeight(20)
	LunaOptionsFrame.pages[2].Portraitmode:SetWidth(20)
	LunaOptionsFrame.pages[2].Portraitmode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[2].BuffInRowslider, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[2].Portraitmode:SetScript("OnClick", OptionFunctions.PortraitmodeToggle)
	LunaOptionsFrame.pages[2].Portraitmode:SetChecked((LunaOptions.frames["LunaPetFrame"].portrait == 1))
	getglobal("PortraitmodePetText"):SetText("Display Portrait as Bar")

	LunaOptionsFrame.pages[3].staticcbar = CreateFrame("CheckButton", "StaticCBar2Switch", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].staticcbar:SetHeight(20)
	LunaOptionsFrame.pages[3].staticcbar:SetWidth(20)
	LunaOptionsFrame.pages[3].staticcbar:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].BuffInRowslider, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[3].staticcbar:SetScript("OnClick", OptionFunctions.StaticTargetCastbar)
	LunaOptionsFrame.pages[3].staticcbar:SetChecked(LunaOptions.statictargetcastbar)
	getglobal("StaticCBar2SwitchText"):SetText("Don\'t hide the castbar.")
	
	LunaOptionsFrame.pages[3].Portraitmode = CreateFrame("CheckButton", "PortraitmodeTarget", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].Portraitmode:SetHeight(20)
	LunaOptionsFrame.pages[3].Portraitmode:SetWidth(20)
	LunaOptionsFrame.pages[3].Portraitmode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].staticcbar, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[3].Portraitmode:SetScript("OnClick", OptionFunctions.PortraitmodeToggle)
	LunaOptionsFrame.pages[3].Portraitmode:SetChecked((LunaOptions.frames["LunaTargetFrame"].portrait == 1))
	getglobal("PortraitmodeTargetText"):SetText("Display Portrait as Bar")
	
	LunaOptionsFrame.pages[3].fliptarget = CreateFrame("CheckButton", "FlipTarget", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].fliptarget:SetHeight(20)
	LunaOptionsFrame.pages[3].fliptarget:SetWidth(20)
	LunaOptionsFrame.pages[3].fliptarget:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].Portraitmode, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[3].fliptarget:SetScript("OnClick", OptionFunctions.ToggleFlipTarget)
	LunaOptionsFrame.pages[3].fliptarget:SetChecked(LunaOptions.fliptarget)
	getglobal("FlipTargetText"):SetText("Flip Target Layout")

	LunaOptionsFrame.pages[3].HideHealing = CreateFrame("CheckButton", "HideHealing", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].HideHealing:SetHeight(20)
	LunaOptionsFrame.pages[3].HideHealing:SetWidth(20)
	LunaOptionsFrame.pages[3].HideHealing:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].fliptarget, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[3].HideHealing:SetScript("OnClick", OptionFunctions.ToggleHideHealing)
	LunaOptionsFrame.pages[3].HideHealing:SetChecked(LunaOptions.HideHealing or 0)
	getglobal("HideHealingText"):SetText("Hide Incoming Heals")
	
	LunaOptionsFrame.pages[3].combattext = CreateFrame("CheckButton", "TargetCombatTextSwitch", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].combattext:SetHeight(20)
	LunaOptionsFrame.pages[3].combattext:SetWidth(20)
	LunaOptionsFrame.pages[3].combattext:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[3].HideHealing, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[3].combattext:SetScript("OnClick", OptionFunctions.TargetCombatTextToggle)
	LunaOptionsFrame.pages[3].combattext:SetChecked(LunaOptions.frames["LunaTargetFrame"].combattext or 0)
	getglobal("TargetCombatTextSwitchText"):SetText("Enable Combat Text on Portrait")
	
	LunaOptionsFrame.pages[3].pvprankicon = CreateFrame("CheckButton", "PvPRankTargetIconSwitch", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].pvprankicon:SetHeight(20)
	LunaOptionsFrame.pages[3].pvprankicon:SetWidth(20)
	LunaOptionsFrame.pages[3].pvprankicon:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[3].combattext, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[3].pvprankicon:SetScript("OnClick", OptionFunctions.TargetPvPRankIconToggle)
	LunaOptionsFrame.pages[3].pvprankicon:SetChecked(LunaOptions.frames["LunaTargetFrame"].pvprankicon or 0)
	getglobal("PvPRankTargetIconSwitchText"):SetText("Enable PvP Rank Icon")
	
	LunaOptionsFrame.pages[3].leadericon = CreateFrame("CheckButton", "LeaderTargetIconSwitch", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].leadericon:SetHeight(20)
	LunaOptionsFrame.pages[3].leadericon:SetWidth(20)
	LunaOptionsFrame.pages[3].leadericon:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[3].pvprankicon, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[3].leadericon:SetScript("OnClick", OptionFunctions.TargetLeaderIconToggle)
	LunaOptionsFrame.pages[3].leadericon:SetChecked(LunaOptions.frames["LunaTargetFrame"].leadericon or 0)
	getglobal("LeaderTargetIconSwitchText"):SetText("Enable Leader Icon")
	
	LunaOptionsFrame.pages[3].looticon = CreateFrame("CheckButton", "LootTargetIconSwitch", LunaOptionsFrame.pages[3], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[3].looticon:SetHeight(20)
	LunaOptionsFrame.pages[3].looticon:SetWidth(20)
	LunaOptionsFrame.pages[3].looticon:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[3].leadericon, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[3].looticon:SetScript("OnClick", OptionFunctions.TargetLootIconToggle)
	LunaOptionsFrame.pages[3].looticon:SetChecked(LunaOptions.frames["LunaTargetFrame"].looticon or 0)
	getglobal("LootTargetIconSwitchText"):SetText("Enable Loot Icon")
	
	LunaOptionsFrame.pages[3].iconsize = CreateFrame("Slider", "TargetIconSizeSlider", LunaOptionsFrame.pages[3], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[3].iconsize:SetMinMaxValues(0.01,2)
	LunaOptionsFrame.pages[3].iconsize:SetValueStep(0.01)
	LunaOptionsFrame.pages[3].iconsize:SetScript("OnValueChanged", OptionFunctions.TargetIconSizeAdjust)
	LunaOptionsFrame.pages[3].iconsize:SetPoint("TOPLEFT", LunaOptionsFrame.pages[3].looticon, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.pages[3].iconsize:SetValue(LunaOptions.frames["LunaTargetFrame"].iconscale or 1)
	LunaOptionsFrame.pages[3].iconsize:SetWidth(180)
	getglobal("TargetIconSizeSliderText"):SetText("Status Icon Size: "..(LunaOptions.frames["LunaTargetFrame"].iconscale or 1))
	
	LunaOptionsFrame.pages[6].spaceslider = CreateFrame("Slider", "SpaceSlider", LunaOptionsFrame.pages[6], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[6].spaceslider:SetMinMaxValues(0,150)
	LunaOptionsFrame.pages[6].spaceslider:SetValueStep(1)
	LunaOptionsFrame.pages[6].spaceslider:SetScript("OnValueChanged", OptionFunctions.PartySpaceAdjust)
	LunaOptionsFrame.pages[6].spaceslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[6].BuffInRowslider, "TOPLEFT", 0, -35)
	LunaOptionsFrame.pages[6].spaceslider:SetValue(LunaOptions.PartySpace)
	LunaOptionsFrame.pages[6].spaceslider:SetWidth(180)
	getglobal("SpaceSliderText"):SetText("Space between units: "..LunaOptions.PartySpace)
	
	LunaOptionsFrame.pages[6].RangeCheck = CreateFrame("CheckButton", "RangeCheck", LunaOptionsFrame.pages[6], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[6].RangeCheck:SetHeight(20)
	LunaOptionsFrame.pages[6].RangeCheck:SetWidth(20)
	LunaOptionsFrame.pages[6].RangeCheck:SetPoint("TOPLEFT", LunaOptionsFrame.pages[6].spaceslider, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[6].RangeCheck:SetScript("OnClick", OptionFunctions.PartyRangeToggle)
	LunaOptionsFrame.pages[6].RangeCheck:SetChecked(LunaOptions.PartyRange)
	getglobal("RangeCheckText"):SetText("Enable Range Check")
	
	LunaOptionsFrame.pages[6].PartyinRaid = CreateFrame("CheckButton", "PartyinRaid", LunaOptionsFrame.pages[6], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[6].PartyinRaid:SetHeight(20)
	LunaOptionsFrame.pages[6].PartyinRaid:SetWidth(20)
	LunaOptionsFrame.pages[6].PartyinRaid:SetPoint("TOPLEFT", LunaOptionsFrame.pages[6].RangeCheck, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[6].PartyinRaid:SetScript("OnClick", OptionFunctions.PartyinRaidToggle)
	LunaOptionsFrame.pages[6].PartyinRaid:SetChecked(LunaOptions.PartyinRaid)
	getglobal("PartyinRaidText"):SetText("Show Party while in Raid")
	
	LunaOptionsFrame.pages[6].PartyGrowth = CreateFrame("CheckButton", "PartyGrowth", LunaOptionsFrame.pages[6], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[6].PartyGrowth:SetHeight(20)
	LunaOptionsFrame.pages[6].PartyGrowth:SetWidth(20)
	LunaOptionsFrame.pages[6].PartyGrowth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[6].PartyinRaid, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[6].PartyGrowth:SetScript("OnClick", OptionFunctions.PartyGrowthToggle)
	LunaOptionsFrame.pages[6].PartyGrowth:SetChecked(LunaOptions.VerticalParty)
	getglobal("PartyGrowthText"):SetText("Grow Party Frames vertically")
	
	LunaOptionsFrame.pages[6].Portraitmode = CreateFrame("CheckButton", "PortraitmodeParty", LunaOptionsFrame.pages[6], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[6].Portraitmode:SetHeight(20)
	LunaOptionsFrame.pages[6].Portraitmode:SetWidth(20)
	LunaOptionsFrame.pages[6].Portraitmode:SetPoint("TOPLEFT", LunaOptionsFrame.pages[6].PartyGrowth, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[6].Portraitmode:SetScript("OnClick", OptionFunctions.PortraitmodeToggle)
	LunaOptionsFrame.pages[6].Portraitmode:SetChecked((LunaOptions.frames["LunaPartyFrames"].portrait == 1))
	getglobal("PortraitmodePartyText"):SetText("Display Portrait as Bar")
	
	LunaOptionsFrame.pages[6].inraidframe = CreateFrame("CheckButton", "PartyInRaidFrame", LunaOptionsFrame.pages[6], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[6].inraidframe:SetHeight(20)
	LunaOptionsFrame.pages[6].inraidframe:SetWidth(20)
	LunaOptionsFrame.pages[6].inraidframe:SetPoint("TOPLEFT", LunaOptionsFrame.pages[6].Portraitmode, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[6].inraidframe:SetScript("OnClick", OptionFunctions.PartyInRaidFrame)
	LunaOptionsFrame.pages[6].inraidframe:SetChecked(LunaOptions.partyraidframe)
	getglobal("PartyInRaidFrameText"):SetText("Display Party in Raidframe")
	
	LunaOptionsFrame.pages[6].pvprankicon = CreateFrame("CheckButton", "PvPRankPartyIconSwitch", LunaOptionsFrame.pages[6], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[6].pvprankicon:SetHeight(20)
	LunaOptionsFrame.pages[6].pvprankicon:SetWidth(20)
	LunaOptionsFrame.pages[6].pvprankicon:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[6].inraidframe, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[6].pvprankicon:SetScript("OnClick", OptionFunctions.PartyPvPRankIconToggle)
	LunaOptionsFrame.pages[6].pvprankicon:SetChecked(LunaOptions.frames["LunaPartyFrames"].pvprankicon or 0)
	getglobal("PvPRankPartyIconSwitchText"):SetText("Enable PvP Rank Icon")
	
	LunaOptionsFrame.pages[6].leadericon = CreateFrame("CheckButton", "LeaderPartyIconSwitch", LunaOptionsFrame.pages[6], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[6].leadericon:SetHeight(20)
	LunaOptionsFrame.pages[6].leadericon:SetWidth(20)
	LunaOptionsFrame.pages[6].leadericon:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[6].pvprankicon, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[6].leadericon:SetScript("OnClick", OptionFunctions.PartyLeaderIconToggle)
	LunaOptionsFrame.pages[6].leadericon:SetChecked(LunaOptions.frames["LunaPartyFrames"].leadericon or 0)
	getglobal("LeaderPartyIconSwitchText"):SetText("Enable Leader Icon")
	
	LunaOptionsFrame.pages[6].looticon = CreateFrame("CheckButton", "LootPartyIconSwitch", LunaOptionsFrame.pages[6], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[6].looticon:SetHeight(20)
	LunaOptionsFrame.pages[6].looticon:SetWidth(20)
	LunaOptionsFrame.pages[6].looticon:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[6].leadericon, "TOPRIGHT", 0, -20)
	LunaOptionsFrame.pages[6].looticon:SetScript("OnClick", OptionFunctions.PartyLootIconToggle)
	LunaOptionsFrame.pages[6].looticon:SetChecked(LunaOptions.frames["LunaPartyFrames"].looticon or 0)
	getglobal("LootPartyIconSwitchText"):SetText("Enable Loot Icon")
	
	LunaOptionsFrame.pages[6].iconsize = CreateFrame("Slider", "PartyIconSizeSlider", LunaOptionsFrame.pages[6], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[6].iconsize:SetMinMaxValues(0.01,2)
	LunaOptionsFrame.pages[6].iconsize:SetValueStep(0.01)
	LunaOptionsFrame.pages[6].iconsize:SetScript("OnValueChanged", OptionFunctions.PartyIconSizeAdjust)
	LunaOptionsFrame.pages[6].iconsize:SetPoint("TOPLEFT", LunaOptionsFrame.pages[6].looticon, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.pages[6].iconsize:SetValue(LunaOptions.frames["LunaPartyFrames"].iconscale or 1)
	LunaOptionsFrame.pages[6].iconsize:SetWidth(180)
	getglobal("PartyIconSizeSliderText"):SetText("Status Icon Size: "..(LunaOptions.frames["LunaPartyFrames"].iconscale or 1))
	
	LunaOptionsFrame.pages[7].PosSelect = CreateFrame("Button", "PartyPetPosSelector", LunaOptionsFrame.pages[7], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[7].PosSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[7].scaleslider, "BOTTOMLEFT", -20 , -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[7].PosSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[7].PosSelect)

	local positions = {"TOP", "BOTTOM", "RIGHT", "LEFT"}
	
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[7].PosSelect, function()
	local info={}
		for k,v in ipairs(positions) do
			info.text=v
			info.value=k
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[7].PosSelect, this:GetID())
				LunaOptions.frames["LunaPartyPetFrames"].position = UIDropDownMenu_GetText(LunaOptionsFrame.pages[7].PosSelect)
				LunaUnitFrames:PartyPetFramesPosition()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end	
	end)
	
	for k,v in ipairs(positions) do
		if v == LunaOptions.frames["LunaPartyPetFrames"].position then
			UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[7].PosSelect, k)
		end
	end
	
	LunaOptionsFrame.pages[7].Desc = LunaOptionsFrame.pages[7]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[7])
	LunaOptionsFrame.pages[7].Desc:SetPoint("LEFT", LunaOptionsFrame.pages[7].PosSelect, "RIGHT", -10, 0)
	LunaOptionsFrame.pages[7].Desc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[7].Desc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[7].Desc:SetText("Position")
	
	LunaOptionsFrame.pages[8].PosSelect = CreateFrame("Button", "PartyTargetPosSelector", LunaOptionsFrame.pages[8], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[8].PosSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[8].scaleslider, "BOTTOMLEFT", -20 , -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[8].PosSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[8].PosSelect)
	
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[8].PosSelect, function()
	local info={}
		for k,v in ipairs(positions) do
			info.text=v
			info.value=k
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[8].PosSelect, this:GetID())
				LunaOptions.frames["LunaPartyTargetFrames"].position = UIDropDownMenu_GetText(LunaOptionsFrame.pages[8].PosSelect)
				LunaUnitFrames:PartyTargetFramesPosition()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end	
	end)
	
	for k,v in ipairs(positions) do
		if v == LunaOptions.frames["LunaPartyTargetFrames"].position then
			UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[8].PosSelect, k)
		end
	end
	
	LunaOptionsFrame.pages[8].Desc = LunaOptionsFrame.pages[8]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[8])
	LunaOptionsFrame.pages[8].Desc:SetPoint("LEFT", LunaOptionsFrame.pages[8].PosSelect, "RIGHT", -10, 0)
	LunaOptionsFrame.pages[8].Desc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[8].Desc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[8].Desc:SetText("Position")
	
	LunaOptionsFrame.pages[9].enable = CreateFrame("CheckButton", "LunaRaidEnableButton", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].enable:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9], "TOPLEFT", 10, -10)
	LunaOptionsFrame.pages[9].enable:SetHeight(20)
	LunaOptionsFrame.pages[9].enable:SetWidth(20)
	LunaOptionsFrame.pages[9].enable:SetScript("OnClick", OptionFunctions.enableRaid)
	LunaOptionsFrame.pages[9].enable:SetChecked(LunaOptions.enableRaid)
	getglobal("LunaRaidEnableButtonText"):SetText("Enable")
	
	LunaOptionsFrame.pages[9].heightslider = CreateFrame("Slider", "RaidHeightSlider", LunaOptionsFrame.pages[9], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[9].heightslider:SetMinMaxValues(20,150)
	LunaOptionsFrame.pages[9].heightslider:SetValueStep(1)
	LunaOptionsFrame.pages[9].heightslider:SetScript("OnValueChanged", OptionFunctions.RaidHeightAdjust)
	LunaOptionsFrame.pages[9].heightslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9], "TOPLEFT", 20, -60)
	LunaOptionsFrame.pages[9].heightslider:SetValue(LunaOptions.frames["LunaRaidFrames"].height or 30)
	LunaOptionsFrame.pages[9].heightslider:SetWidth(460)
	getglobal("RaidHeightSliderText"):SetText("Height: "..(LunaOptions.frames["LunaRaidFrames"].height or 30))
	
	LunaOptionsFrame.pages[9].widthslider = CreateFrame("Slider", "RaidWidthSlider", LunaOptionsFrame.pages[9], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[9].widthslider:SetMinMaxValues(20,150)
	LunaOptionsFrame.pages[9].widthslider:SetValueStep(1)
	LunaOptionsFrame.pages[9].widthslider:SetScript("OnValueChanged", OptionFunctions.RaidWidthAdjust)
	LunaOptionsFrame.pages[9].widthslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].heightslider, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.pages[9].widthslider:SetValue(LunaOptions.frames["LunaRaidFrames"].width or 60)
	LunaOptionsFrame.pages[9].widthslider:SetWidth(460)
	getglobal("RaidWidthSliderText"):SetText("Width: "..LunaOptions.frames["LunaRaidFrames"].width or 60)
	
	LunaOptionsFrame.pages[9].scaleslider = CreateFrame("Slider", "RaidScaleSlider", LunaOptionsFrame.pages[9], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[9].scaleslider:SetMinMaxValues(0.5,2)
	LunaOptionsFrame.pages[9].scaleslider:SetValueStep(0.1)
	LunaOptionsFrame.pages[9].scaleslider:SetScript("OnValueChanged", OptionFunctions.RaidScaleAdjust)
	LunaOptionsFrame.pages[9].scaleslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].widthslider, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.pages[9].scaleslider:SetValue(LunaOptions.frames["LunaRaidFrames"].scale or 1)
	LunaOptionsFrame.pages[9].scaleslider:SetWidth(460)
	getglobal("RaidScaleSliderText"):SetText("Scale: "..(LunaOptions.frames["LunaRaidFrames"].scale or 1))
	
	LunaOptionsFrame.pages[9].paddingslider = CreateFrame("Slider", "RaidPaddingSlider", LunaOptionsFrame.pages[9], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[9].paddingslider:SetMinMaxValues(0,20)
	LunaOptionsFrame.pages[9].paddingslider:SetValueStep(1)
	LunaOptionsFrame.pages[9].paddingslider:SetScript("OnValueChanged", OptionFunctions.RaidPaddingAdjust)
	LunaOptionsFrame.pages[9].paddingslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].scaleslider, "BOTTOMLEFT", 0, -15)
	LunaOptionsFrame.pages[9].paddingslider:SetValue(LunaOptions.frames["LunaRaidFrames"].padding or 4)
	LunaOptionsFrame.pages[9].paddingslider:SetWidth(215)
	getglobal("RaidPaddingSliderText"):SetText("Padding: "..(LunaOptions.frames["LunaRaidFrames"].padding or 4))
	
	LunaOptionsFrame.pages[9].BuffwatchDesc = LunaOptionsFrame.pages[9]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[9])
	LunaOptionsFrame.pages[9].BuffwatchDesc:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].paddingslider, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[9].BuffwatchDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[9].BuffwatchDesc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[9].BuffwatchDesc:SetText("Track Buffs (Can be part of name):")
	
	LunaOptionsFrame.pages[9].Buffwatch = CreateFrame("Editbox", "BuffwatchInput", LunaOptionsFrame.pages[9], "InputBoxTemplate")
	LunaOptionsFrame.pages[9].Buffwatch:SetHeight(20)
	LunaOptionsFrame.pages[9].Buffwatch:SetWidth(205)
	LunaOptionsFrame.pages[9].Buffwatch:SetAutoFocus(nil)
	LunaOptionsFrame.pages[9].Buffwatch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].BuffwatchDesc, "TOPLEFT", 8, -12)
	LunaOptionsFrame.pages[9].Buffwatch:SetText(LunaOptions.Raidbuff or "")
	LunaOptionsFrame.pages[9].Buffwatch:SetScript("OnEnterPressed", function()
																		this:ClearFocus();
																		LunaOptions.Raidbuff = this:GetText()
																		LunaUnitFrames.Raid_Update()
																	end)
																	
	LunaOptionsFrame.pages[9].Buffwatch2 = CreateFrame("Editbox", "BuffwatchInput2", LunaOptionsFrame.pages[9], "InputBoxTemplate")
	LunaOptionsFrame.pages[9].Buffwatch2:SetHeight(20)
	LunaOptionsFrame.pages[9].Buffwatch2:SetWidth(205)
	LunaOptionsFrame.pages[9].Buffwatch2:SetAutoFocus(nil)
	LunaOptionsFrame.pages[9].Buffwatch2:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].Buffwatch, "BOTTOMLEFT", 0, 0)
	LunaOptionsFrame.pages[9].Buffwatch2:SetText(LunaOptions.Raidbuff2 or "")
	LunaOptionsFrame.pages[9].Buffwatch2:SetScript("OnEnterPressed", function()
																		this:ClearFocus();
																		LunaOptions.Raidbuff2 = this:GetText()
																		LunaUnitFrames.Raid_Update()
																	end)

	LunaOptionsFrame.pages[9].Buffwatch3 = CreateFrame("Editbox", "BuffwatchInput3", LunaOptionsFrame.pages[9], "InputBoxTemplate")
	LunaOptionsFrame.pages[9].Buffwatch3:SetHeight(20)
	LunaOptionsFrame.pages[9].Buffwatch3:SetWidth(205)
	LunaOptionsFrame.pages[9].Buffwatch3:SetAutoFocus(nil)
	LunaOptionsFrame.pages[9].Buffwatch3:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].Buffwatch2, "BOTTOMLEFT", 0, 0)
	LunaOptionsFrame.pages[9].Buffwatch3:SetText(LunaOptions.Raidbuff3 or "")
	LunaOptionsFrame.pages[9].Buffwatch3:SetScript("OnEnterPressed", function()
																		this:ClearFocus();
																		LunaOptions.Raidbuff3 = this:GetText()
																		LunaUnitFrames.Raid_Update()
																	end)
	
	LunaOptionsFrame.pages[9].RaidGrpNameswitch = CreateFrame("CheckButton", "RaidGroupNamesSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].RaidGrpNameswitch:SetHeight(20)
	LunaOptionsFrame.pages[9].RaidGrpNameswitch:SetWidth(20)
	LunaOptionsFrame.pages[9].RaidGrpNameswitch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].Buffwatch3, "BOTTOMLEFT", 0, 0)
	LunaOptionsFrame.pages[9].RaidGrpNameswitch:SetScript("OnClick", OptionFunctions.ToggleRaidGroupNames)
	LunaOptionsFrame.pages[9].RaidGrpNameswitch:SetChecked(LunaOptions.frames["LunaRaidFrames"].ShowRaidGroupTitles)
	getglobal("RaidGroupNamesSwitchText"):SetText("Show Group Names")
	
	LunaOptionsFrame.pages[9].RaidGrpHealthVertswitch = CreateFrame("CheckButton", "RaidGroupHealthVertSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].RaidGrpHealthVertswitch:SetHeight(20)
	LunaOptionsFrame.pages[9].RaidGrpHealthVertswitch:SetWidth(20)
	LunaOptionsFrame.pages[9].RaidGrpHealthVertswitch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].RaidGrpNameswitch, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[9].RaidGrpHealthVertswitch:SetScript("OnClick", OptionFunctions.ToggleVertRaidHealthBars)
	LunaOptionsFrame.pages[9].RaidGrpHealthVertswitch:SetChecked(LunaOptions.frames["LunaRaidFrames"].verticalHealth)
	getglobal("RaidGroupHealthVertSwitchText"):SetText("Vertical Health Bars")
	
	LunaOptionsFrame.pages[9].pBarswitch = CreateFrame("CheckButton", "RaidGroupPowerSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].pBarswitch:SetHeight(20)
	LunaOptionsFrame.pages[9].pBarswitch:SetWidth(20)
	LunaOptionsFrame.pages[9].pBarswitch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].RaidGrpHealthVertswitch, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[9].pBarswitch:SetScript("OnClick", OptionFunctions.ToggleRaidPowerBars)
	LunaOptionsFrame.pages[9].pBarswitch:SetChecked(LunaOptions.frames["LunaRaidFrames"].pBars)
	getglobal("RaidGroupPowerSwitchText"):SetText("Show Power Bars")
	
	LunaOptionsFrame.pages[9].pBarvertswitch = CreateFrame("CheckButton", "RaidGroupPowerVertSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].pBarvertswitch:SetHeight(20)
	LunaOptionsFrame.pages[9].pBarvertswitch:SetWidth(20)
	LunaOptionsFrame.pages[9].pBarvertswitch:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].pBarswitch, "TOPLEFT", 10, -20)
	LunaOptionsFrame.pages[9].pBarvertswitch:SetScript("OnClick", OptionFunctions.ToggleVertRaidPowerBars)
	LunaOptionsFrame.pages[9].pBarvertswitch:SetChecked(LunaOptions.frames["LunaRaidFrames"].pBars == 2)
	getglobal("RaidGroupPowerVertSwitchText"):SetText("Vertical Power Bars")
	
	LunaOptionsFrame.pages[9].inverthealth = CreateFrame("CheckButton", "RaidGroupInvertHealthSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].inverthealth:SetHeight(20)
	LunaOptionsFrame.pages[9].inverthealth:SetWidth(20)
	LunaOptionsFrame.pages[9].inverthealth:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].pBarvertswitch, "TOPLEFT", -10, -20)
	LunaOptionsFrame.pages[9].inverthealth:SetScript("OnClick", OptionFunctions.ToggleInvertHealthBars)
	LunaOptionsFrame.pages[9].inverthealth:SetChecked(LunaOptions.frames["LunaRaidFrames"].inverthealth)
	getglobal("RaidGroupInvertHealthSwitchText"):SetText("Invert Health Bars")
	
	LunaOptionsFrame.pages[9].petgroup = CreateFrame("CheckButton", "PetGroupSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].petgroup:SetHeight(20)
	LunaOptionsFrame.pages[9].petgroup:SetWidth(20)
	LunaOptionsFrame.pages[9].petgroup:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].inverthealth, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[9].petgroup:SetScript("OnClick", OptionFunctions.TogglePetGroup)
	LunaOptionsFrame.pages[9].petgroup:SetChecked(LunaOptions.frames["LunaRaidFrames"].petgroup)
	getglobal("PetGroupSwitchText"):SetText("Show the Pet Group")
	
	LunaOptionsFrame.pages[9].dispdebuffs = CreateFrame("CheckButton", "DispDebuffSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].dispdebuffs:SetHeight(20)
	LunaOptionsFrame.pages[9].dispdebuffs:SetWidth(20)
	LunaOptionsFrame.pages[9].dispdebuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].petgroup, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[9].dispdebuffs:SetScript("OnClick", OptionFunctions.ToggleDispelableDebuffs)
	LunaOptionsFrame.pages[9].dispdebuffs:SetChecked(LunaOptions.showdispelable)
	getglobal("DispDebuffSwitchText"):SetText("Show only dispelable Debuffs")
	
	LunaOptionsFrame.pages[9].textdebuff = CreateFrame("CheckButton", "TextDebuffSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].textdebuff:SetHeight(20)
	LunaOptionsFrame.pages[9].textdebuff:SetWidth(20)
	LunaOptionsFrame.pages[9].textdebuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].dispdebuffs, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[9].textdebuff:SetScript("OnClick", OptionFunctions.ToggleTexDebuffs)
	LunaOptionsFrame.pages[9].textdebuff:SetChecked(LunaOptions.frames["LunaRaidFrames"].texturedebuff)
	getglobal("TextDebuffSwitchText"):SetText("Show pictures on Debuffs")
	
	LunaOptionsFrame.pages[9].textbuff = CreateFrame("CheckButton", "TextBuffSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].textbuff:SetHeight(20)
	LunaOptionsFrame.pages[9].textbuff:SetWidth(20)
	LunaOptionsFrame.pages[9].textbuff:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].textdebuff, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[9].textbuff:SetScript("OnClick", OptionFunctions.ToggleTexBuffs)
	LunaOptionsFrame.pages[9].textbuff:SetChecked(LunaOptions.frames["LunaRaidFrames"].texturebuff)
	getglobal("TextBuffSwitchText"):SetText("Show pictures on Buffs")
	
	LunaOptionsFrame.pages[9].cornericonsize = CreateFrame("Slider", "CornerIconSizeSlider", LunaOptionsFrame.pages[9], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[9].cornericonsize:SetMinMaxValues(0.01,2)
	LunaOptionsFrame.pages[9].cornericonsize:SetValueStep(0.01)
	LunaOptionsFrame.pages[9].cornericonsize:SetScript("OnValueChanged", OptionFunctions.CornerIconSizeAdjust)
	LunaOptionsFrame.pages[9].cornericonsize:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].textbuff, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[9].cornericonsize:SetValue(LunaOptions.frames["LunaRaidFrames"].cornericonscale or 1)
	LunaOptionsFrame.pages[9].cornericonsize:SetWidth(180)
	getglobal("CornerIconSizeSliderText"):SetText("Corner Icon Size")	
	
	LunaOptionsFrame.pages[9].centericon = CreateFrame("CheckButton", "CenterIconSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].centericon:SetHeight(20)
	LunaOptionsFrame.pages[9].centericon:SetWidth(20)
	LunaOptionsFrame.pages[9].centericon:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].cornericonsize, "TOPLEFT", 0, -25)
	LunaOptionsFrame.pages[9].centericon:SetScript("OnClick", OptionFunctions.ToggleCenterIcon)
	LunaOptionsFrame.pages[9].centericon:SetChecked(LunaOptions.frames["LunaRaidFrames"].centerIcon)
	getglobal("CenterIconSwitchText"):SetText("Display Debuffs as a Center Icon")
	
	LunaOptionsFrame.pages[9].centericonsize = CreateFrame("Slider", "CenterIconSizeSlider", LunaOptionsFrame.pages[9], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[9].centericonsize:SetMinMaxValues(0.01,2)
	LunaOptionsFrame.pages[9].centericonsize:SetValueStep(0.01)
	LunaOptionsFrame.pages[9].centericonsize:SetScript("OnValueChanged", OptionFunctions.CenterIconSizeAdjust)
	LunaOptionsFrame.pages[9].centericonsize:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].centericon, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[9].centericonsize:SetValue(LunaOptions.frames["LunaRaidFrames"].centericonscale or 1)
	LunaOptionsFrame.pages[9].centericonsize:SetWidth(180)
	getglobal("CenterIconSizeSliderText"):SetText("Center Icon Size")

	LunaOptionsFrame.pages[9].aggro = CreateFrame("CheckButton", "AggroSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].aggro:SetHeight(20)
	LunaOptionsFrame.pages[9].aggro:SetWidth(20)
	LunaOptionsFrame.pages[9].aggro:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].centericonsize, "TOPLEFT", 0, -25)
	LunaOptionsFrame.pages[9].aggro:SetScript("OnClick", OptionFunctions.ToggleAggro)
	LunaOptionsFrame.pages[9].aggro:SetChecked(LunaOptions.aggro)
	getglobal("AggroSwitchText"):SetText("Show aggro warning")
	
	LunaOptionsFrame.pages[9].interlock = CreateFrame("CheckButton", "InterlockSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].interlock:SetHeight(20)
	LunaOptionsFrame.pages[9].interlock:SetWidth(20)
	LunaOptionsFrame.pages[9].interlock:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].aggro, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[9].interlock:SetScript("OnClick", OptionFunctions.ToggleInterlock)
	LunaOptionsFrame.pages[9].interlock:SetChecked(LunaOptions.raidinterlock)
	getglobal("InterlockSwitchText"):SetText("Interlock Raid Frames")
	
	LunaOptionsFrame.pages[9].alwaysraid = CreateFrame("CheckButton", "AlwaysRaidSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].alwaysraid:SetHeight(20)
	LunaOptionsFrame.pages[9].alwaysraid:SetWidth(20)
	LunaOptionsFrame.pages[9].alwaysraid:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].interlock, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[9].alwaysraid:SetScript("OnClick", OptionFunctions.ToggleAlwaysRaid)
	LunaOptionsFrame.pages[9].alwaysraid:SetChecked(LunaOptions.AlwaysRaid)
	getglobal("AlwaysRaidSwitchText"):SetText("Always display the Raid Frame")
	
	LunaOptionsFrame.pages[9].hottracker = CreateFrame("CheckButton", "HotTrackerSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].hottracker:SetHeight(20)
	LunaOptionsFrame.pages[9].hottracker:SetWidth(20)
	LunaOptionsFrame.pages[9].hottracker:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].alwaysraid, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[9].hottracker:SetScript("OnClick", OptionFunctions.ToggleHotTracker)
	LunaOptionsFrame.pages[9].hottracker:SetChecked(LunaOptions.frames["LunaRaidFrames"].hottracker)
	getglobal("HotTrackerSwitchText"):SetText("Enable Hottracker (Priest/Druid only)")
	
	LunaOptionsFrame.pages[9].wsoul = CreateFrame("CheckButton", "WSoulSwitch", LunaOptionsFrame.pages[9], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[9].wsoul:SetHeight(20)
	LunaOptionsFrame.pages[9].wsoul:SetWidth(20)
	LunaOptionsFrame.pages[9].wsoul:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].hottracker, "TOPLEFT", 0, -20)
	LunaOptionsFrame.pages[9].wsoul:SetScript("OnClick", OptionFunctions.ToggleWSoul)
	LunaOptionsFrame.pages[9].wsoul:SetChecked(LunaOptions.frames["LunaRaidFrames"].wsoul)
	getglobal("WSoulSwitchText"):SetText("Track Weakened Soul (Priest only)")
	
	LunaOptionsFrame.pages[9].ResetButton = CreateFrame("Button", "RaidPosReset", LunaOptionsFrame.pages[9], "UIPanelButtonTemplate")
	LunaOptionsFrame.pages[9].ResetButton:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[9], "TOPRIGHT")
	LunaOptionsFrame.pages[9].ResetButton:SetHeight(20)
	LunaOptionsFrame.pages[9].ResetButton:SetWidth(140)
	LunaOptionsFrame.pages[9].ResetButton:SetText("Reset Positions")
	LunaOptionsFrame.pages[9].ResetButton:SetScript("OnClick", LunaUnitFrames.Raid_Pos_Reset)
	
	LunaOptionsFrame.pages[9].GroupModeSelect = CreateFrame("Button", "RaidGroupModeSelector", LunaOptionsFrame.pages[9], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[9].GroupModeSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].paddingslider, "TOPRIGHT", 10 , 0)
	UIDropDownMenu_SetWidth(100, LunaOptionsFrame.pages[9].GroupModeSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[9].GroupModeSelect)

	local modes = {"GROUP", "CLASS"}
	
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[9].GroupModeSelect, function()
	local info={}
		for k,v in ipairs(modes) do
			info.text=v
			info.value=k
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[9].GroupModeSelect, this:GetID())
				LunaOptions.frames["LunaRaidFrames"].grpmode = UIDropDownMenu_GetText(LunaOptionsFrame.pages[9].GroupModeSelect)
				LunaUnitFrames:UpdateRaidRoster()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	for k,v in ipairs(modes) do
		if v == LunaOptions.frames["LunaRaidFrames"].grpmode then
			UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[9].GroupModeSelect, k)
		end
	end
	
	LunaOptionsFrame.pages[9].ModeDesc = LunaOptionsFrame.pages[9]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[9])
	LunaOptionsFrame.pages[9].ModeDesc:SetPoint("LEFT", LunaOptionsFrame.pages[9].GroupModeSelect, "RIGHT", -10, 0)
	LunaOptionsFrame.pages[9].ModeDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[9].ModeDesc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[9].ModeDesc:SetText("Group Mode")
	
	LunaOptionsFrame.pages[9].GrowthSelect = CreateFrame("Button", "RaidGroupGrowthSelector", LunaOptionsFrame.pages[9], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[9].GrowthSelect:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].GroupModeSelect, "BOTTOMLEFT", 0 , 0)
	UIDropDownMenu_SetWidth(100, LunaOptionsFrame.pages[9].GrowthSelect)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[9].GrowthSelect)

	local directions = {"UP", "DOWN", "RIGHT", "LEFT"}
	
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[9].GrowthSelect, function()
	local info={}
		for k,v in ipairs(directions) do
			info.text=v
			info.value=k
			info.func= function ()
				UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[9].GrowthSelect, this:GetID())
				LunaOptions.frames["LunaRaidFrames"].growthdir = UIDropDownMenu_GetText(LunaOptionsFrame.pages[9].GrowthSelect)
				LunaUnitFrames:UpdateRaidLayout()
			end
			info.checked = nil
			info.checkable = nil
			UIDropDownMenu_AddButton(info, 1)
		end
	end)
	
	for k,v in ipairs(directions) do
		if v == LunaOptions.frames["LunaRaidFrames"].growthdir then
			UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[9].GrowthSelect, k)
		end
	end
	
	LunaOptionsFrame.pages[9].GrowthDesc = LunaOptionsFrame.pages[9]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[9])
	LunaOptionsFrame.pages[9].GrowthDesc:SetPoint("LEFT", LunaOptionsFrame.pages[9].GrowthSelect, "RIGHT", -10, 0)
	LunaOptionsFrame.pages[9].GrowthDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[9].GrowthDesc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[9].GrowthDesc:SetText("Growth direction")
	
	LunaOptionsFrame.pages[9].toptext = CreateFrame("Editbox", "TopTextInput", LunaOptionsFrame.pages[9], "InputBoxTemplate")
	LunaOptionsFrame.pages[9].toptext:SetHeight(20)
	LunaOptionsFrame.pages[9].toptext:SetWidth(205)
	LunaOptionsFrame.pages[9].toptext:SetAutoFocus(nil)
	LunaOptionsFrame.pages[9].toptext:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].GrowthSelect, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[9].toptext:SetText(LunaOptions.frames["LunaRaidFrames"].toptext or "")
	LunaOptionsFrame.pages[9].toptext:SetScript("OnEnterPressed", function()
																		this:ClearFocus();
																		LunaOptions.frames["LunaRaidFrames"].toptext = this:GetText()
																		LunaUnitFrames:UpdateRaidRoster()
																	end)
																	
	LunaOptionsFrame.pages[9].toptextDesc = LunaOptionsFrame.pages[9]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[9])
	LunaOptionsFrame.pages[9].toptextDesc:SetPoint("BOTTOMLEFT", LunaOptionsFrame.pages[9].toptext, "TOPLEFT", 0, 0)
	LunaOptionsFrame.pages[9].toptextDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[9].toptextDesc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[9].toptextDesc:SetText("Top Text")
																	
	LunaOptionsFrame.pages[9].bottomtext = CreateFrame("Editbox", "BottomTextInput", LunaOptionsFrame.pages[9], "InputBoxTemplate")
	LunaOptionsFrame.pages[9].bottomtext:SetHeight(20)
	LunaOptionsFrame.pages[9].bottomtext:SetWidth(205)
	LunaOptionsFrame.pages[9].bottomtext:SetAutoFocus(nil)
	LunaOptionsFrame.pages[9].bottomtext:SetPoint("TOPLEFT", LunaOptionsFrame.pages[9].toptext, "BOTTOMLEFT", 0, -10)
	LunaOptionsFrame.pages[9].bottomtext:SetText(LunaOptions.frames["LunaRaidFrames"].bottomtext or "")
	LunaOptionsFrame.pages[9].bottomtext:SetScript("OnEnterPressed", function()
																		this:ClearFocus();
																		LunaOptions.frames["LunaRaidFrames"].bottomtext = this:GetText()
																		LunaUnitFrames:UpdateRaidRoster()
																	end)
																	
	LunaOptionsFrame.pages[9].bottomtextDesc = LunaOptionsFrame.pages[9]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[9])
	LunaOptionsFrame.pages[9].bottomtextDesc:SetPoint("BOTTOMLEFT", LunaOptionsFrame.pages[9].bottomtext, "TOPLEFT", 0, 0)
	LunaOptionsFrame.pages[9].bottomtextDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[9].bottomtextDesc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[9].bottomtextDesc:SetText("Bottom Text")
																	
	LunaOptionsFrame.pages[10].hbarcolor = CreateFrame("CheckButton", "HBarColorSwitch", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].hbarcolor:SetHeight(20)
	LunaOptionsFrame.pages[10].hbarcolor:SetWidth(20)
	LunaOptionsFrame.pages[10].hbarcolor:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10], "TOPLEFT", 20, -60)
	LunaOptionsFrame.pages[10].hbarcolor:SetScript("OnClick", OptionFunctions.ToggleHBarColor)
	LunaOptionsFrame.pages[10].hbarcolor:SetChecked(LunaOptions.hbarcolor or 0)
	getglobal("HBarColorSwitchText"):SetText("Class colors on healthbars")
	
	LunaOptionsFrame.pages[10].blizzplayer = CreateFrame("CheckButton", "BlizzPlayerSwitch", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].blizzplayer:SetHeight(20)
	LunaOptionsFrame.pages[10].blizzplayer:SetWidth(20)
	LunaOptionsFrame.pages[10].blizzplayer:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].hbarcolor, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[10].blizzplayer:SetScript("OnClick", OptionFunctions.ToggleBlizzPlayer)
	LunaOptionsFrame.pages[10].blizzplayer:SetChecked(LunaOptions.BlizzPlayer)
	getglobal("BlizzPlayerSwitchText"):SetText("Display Blizzard Player Frame")
	
	LunaOptionsFrame.pages[10].blizztarget = CreateFrame("CheckButton", "BlizzTargetSwitch", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].blizztarget:SetHeight(20)
	LunaOptionsFrame.pages[10].blizztarget:SetWidth(20)
	LunaOptionsFrame.pages[10].blizztarget:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].blizzplayer, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[10].blizztarget:SetScript("OnClick", OptionFunctions.ToggleBlizzTarget)
	LunaOptionsFrame.pages[10].blizztarget:SetChecked(LunaOptions.BlizzTarget)
	getglobal("BlizzTargetSwitchText"):SetText("Display Blizzard Target Frame")
	
	LunaOptionsFrame.pages[10].blizzparty = CreateFrame("CheckButton", "BlizzPartySwitch", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].blizzparty:SetHeight(20)
	LunaOptionsFrame.pages[10].blizzparty:SetWidth(20)
	LunaOptionsFrame.pages[10].blizzparty:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].blizztarget, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[10].blizzparty:SetScript("OnClick", OptionFunctions.ToggleBlizzParty)
	LunaOptionsFrame.pages[10].blizzparty:SetChecked(LunaOptions.BlizzParty)
	getglobal("BlizzPartySwitchText"):SetText("Display Blizzard Party Frames")
	
	LunaOptionsFrame.pages[10].blizzbuffs = CreateFrame("CheckButton", "BlizzBuffSwitch", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].blizzbuffs:SetHeight(20)
	LunaOptionsFrame.pages[10].blizzbuffs:SetWidth(20)
	LunaOptionsFrame.pages[10].blizzbuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].blizzparty, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[10].blizzbuffs:SetScript("OnClick", OptionFunctions.ToggleBlizzBuffs)
	LunaOptionsFrame.pages[10].blizzbuffs:SetChecked(LunaOptions.BlizzBuffs)
	getglobal("BlizzBuffSwitchText"):SetText("Hide Blizzard Buff Frames")
	
	LunaOptionsFrame.pages[10].hbuffs = CreateFrame("CheckButton", "HighlightDebuffsSwitch", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].hbuffs:SetHeight(20)
	LunaOptionsFrame.pages[10].hbuffs:SetWidth(20)
	LunaOptionsFrame.pages[10].hbuffs:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].blizzbuffs, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[10].hbuffs:SetScript("OnClick", OptionFunctions.ToggleHighlightBuffs)
	LunaOptionsFrame.pages[10].hbuffs:SetChecked(LunaOptions.HighlightDebuffs)
	getglobal("HighlightDebuffsSwitchText"):SetText("Highlight debuffed units you can dispel")
	
	LunaOptionsFrame.pages[10].mouseover = CreateFrame("CheckButton", "MouseoverSwitch", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].mouseover:SetHeight(20)
	LunaOptionsFrame.pages[10].mouseover:SetWidth(20)
	LunaOptionsFrame.pages[10].mouseover:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].hbuffs, "TOPLEFT", 0, -30)
	LunaOptionsFrame.pages[10].mouseover:SetScript("OnClick", OptionFunctions.Mouseover)
	LunaOptionsFrame.pages[10].mouseover:SetChecked(LunaOptions.mouseover)
	getglobal("MouseoverSwitchText"):SetText("Allow mouseover in the 3D world.")	
	
	LunaOptionsFrame.pages[10].overhealslider = CreateFrame("Slider", "OverhealSlider", LunaOptionsFrame.pages[10], "OptionsSliderTemplate")
	LunaOptionsFrame.pages[10].overhealslider:SetMinMaxValues(0,20)
	LunaOptionsFrame.pages[10].overhealslider:SetValueStep(1)
	LunaOptionsFrame.pages[10].overhealslider:SetScript("OnValueChanged", OptionFunctions.OverhealAdjust)
	LunaOptionsFrame.pages[10].overhealslider:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].mouseover, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.pages[10].overhealslider:SetValue(LunaOptions.overheal or 20)
	LunaOptionsFrame.pages[10].overhealslider:SetWidth(215)
	getglobal("OverhealSliderText"):SetText("Overlap percent of healbar: "..(LunaOptions.overheal or 20))
	
	LunaOptionsFrame.pages[10].PortraitMode = CreateFrame("Button", "PortraitMode", LunaOptionsFrame.pages[10], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[10].PortraitMode:SetPoint("TOPRIGHT", LunaOptionsFrame.pages[10], "TOPRIGHT", -110, -60)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[10].PortraitMode)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[10].PortraitMode)
		
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[10].PortraitMode, function()
																			local info={}
																			for k,v in ipairs({"3D","2D","Classicon"}) do
																				info.text=v
																				info.value=k
																				info.func= function()
																						UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[10].PortraitMode, this:GetID())
																						LunaOptions.PortraitMode = this:GetID()
																						LunaUnitFrames:UpdatePartyFrames()
																						LunaUnitFrames:UpdatePlayerFrame()
																						LunaUnitFrames:UpdatePetFrame()
																						LunaUnitFrames:UpdateTargetFrame()
																						end
																				info.checked = nil
																				UIDropDownMenu_AddButton(info, 1)
																			end
																		end)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[10].PortraitMode, LunaOptions.PortraitMode or 1)
	
	LunaOptionsFrame.pages[10].PortraitModeDesc = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[10])
	LunaOptionsFrame.pages[10].PortraitModeDesc:SetPoint("LEFT", LunaOptionsFrame.pages[10].PortraitMode, "RIGHT", -5, 0)
	LunaOptionsFrame.pages[10].PortraitModeDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[10].PortraitModeDesc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[10].PortraitModeDesc:SetText("Portrait Mode")
	
	LunaOptionsFrame.pages[10].PortraitFallback = CreateFrame("Button", "PortraitFallback", LunaOptionsFrame.pages[10], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[10].PortraitFallback:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].PortraitMode, "BOTTOMLEFT", 0, -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[10].PortraitFallback)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[10].PortraitFallback)
		
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[10].PortraitFallback, function()
																			local info={}
																			for k,v in ipairs({"3D","2D","Classicon"}) do
																				info.text=v
																				info.value=k
																				info.func= function()
																						UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[10].PortraitFallback, this:GetID())
																						LunaOptions.PortraitFallback = this:GetID()
																						LunaUnitFrames:UpdatePartyFrames()
																						LunaUnitFrames:UpdatePlayerFrame()
																						LunaUnitFrames:UpdatePetFrame()
																						LunaUnitFrames:UpdateTargetFrame()
																						end
																				info.checked = nil
																				UIDropDownMenu_AddButton(info, 1)
																			end
																		end)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[10].PortraitFallback, LunaOptions.PortraitFallback or 1)
	
	LunaOptionsFrame.pages[10].PortraitFallbackDesc = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[10])
	LunaOptionsFrame.pages[10].PortraitFallbackDesc:SetPoint("LEFT", LunaOptionsFrame.pages[10].PortraitFallback, "RIGHT", -5, 0)
	LunaOptionsFrame.pages[10].PortraitFallbackDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[10].PortraitFallbackDesc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[10].PortraitFallbackDesc:SetText("Portrait Fallback")
	
	LunaOptionsFrame.pages[10].BarTexture = CreateFrame("Button", "BarTexture", LunaOptionsFrame.pages[10], "UIDropDownMenuTemplate")
	LunaOptionsFrame.pages[10].BarTexture:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].PortraitFallback, "BOTTOMLEFT", 0, -10)
	UIDropDownMenu_SetWidth(80, LunaOptionsFrame.pages[10].BarTexture)
	UIDropDownMenu_JustifyText("LEFT", LunaOptionsFrame.pages[10].BarTexture)
		
	UIDropDownMenu_Initialize(LunaOptionsFrame.pages[10].BarTexture, function()
																			local info={}
																			for k,v in BarTextures do
																				info.text=v
																				info.value=k
																				info.func= function()
																						UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[10].BarTexture, this:GetID())
																						LunaOptions.BarTexture = this:GetID()
																						LunaUnitFrames:UpdateBarTextures()
																						end
																				info.checked = nil
																				UIDropDownMenu_AddButton(info, 1)
																			end
																		end)
	UIDropDownMenu_SetSelectedID(LunaOptionsFrame.pages[10].BarTexture, LunaOptions.BarTexture or 1)
	
	LunaOptionsFrame.pages[10].BarTextureDesc = LunaOptionsFrame.pages[10]:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.pages[10])
	LunaOptionsFrame.pages[10].BarTextureDesc:SetPoint("LEFT", LunaOptionsFrame.pages[10].BarTexture, "RIGHT", -5, 0)
	LunaOptionsFrame.pages[10].BarTextureDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	LunaOptionsFrame.pages[10].BarTextureDesc:SetTextColor(1,0.82,0)
	LunaOptionsFrame.pages[10].BarTextureDesc:SetText("Bar Texture")
	
	LunaOptionsFrame.pages[10].HideBlizzCast = CreateFrame("CheckButton", "HideBlizzCast", LunaOptionsFrame.pages[10], "UICheckButtonTemplate")
	LunaOptionsFrame.pages[10].HideBlizzCast:SetHeight(20)
	LunaOptionsFrame.pages[10].HideBlizzCast:SetWidth(20)
	LunaOptionsFrame.pages[10].HideBlizzCast:SetPoint("TOPLEFT", LunaOptionsFrame.pages[10].BarTexture, "BOTTOMLEFT", 0, -20)
	LunaOptionsFrame.pages[10].HideBlizzCast:SetScript("OnClick", OptionFunctions.HideBlizzardCastbarToggle)
	LunaOptionsFrame.pages[10].HideBlizzCast:SetChecked(LunaOptions.hideBlizzCastbar)
	getglobal("HideBlizzCastText"):SetText("Hide original Blizzard Castbar")
	
	LunaOptionsFrame:SetScale(1.3)
	
	-- CCC pop-up
	
	cccpopup = CreateFrame("Frame", "LunaCCCMenu", LunaOptionsFrame)
	cccpopup:SetHeight(390)
	cccpopup:SetWidth(640)
	cccpopup:SetBackdrop(LunaOptions.backdrop)
	cccpopup:SetBackdropColor(0.18,0.27,0.5)
	cccpopup:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	cccpopup:SetFrameStrata("FULLSCREEN")
	cccpopup:EnableMouse(1)
	cccpopup:SetMovable(1)
	cccpopup:RegisterForDrag("LeftButton")
	cccpopup:SetScript("OnDragStart", OptionFunctions.StartMoving)
	cccpopup:SetScript("OnDragStop", OptionFunctions.StopMovingOrSizing)
	cccpopup:Hide()
	
	local playerName = UnitName("player")

	cccpopup.CloseButton = CreateFrame("Button", "LunaOptionsCloseButton", cccpopup,"UIPanelCloseButton")
	cccpopup.CloseButton:SetPoint("TOPRIGHT", cccpopup, "TOPRIGHT", 0, 0)

	cccpopup.icon = cccpopup:CreateTexture(nil, "ARTWORK", cccpopup)
	cccpopup.icon:SetTexture(LunaOptions.icontexture)
	cccpopup.icon:SetHeight(32)
	cccpopup.icon:SetWidth(32)
	cccpopup.icon:SetPoint("TOPLEFT", cccpopup, "TOPLEFT", 0, 0)

	cccpopup.name = cccpopup:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	cccpopup.name:SetPoint("TOP", cccpopup, "TOP", 0, -10)
	cccpopup.name:SetShadowColor(0, 0, 0)
	cccpopup.name:SetShadowOffset(0.8, -0.8)
	cccpopup.name:SetTextColor(1,1,1)
	cccpopup.name:SetText("Luna Click Casting Configuration")
	
	cccpopup.page = CreateFrame("Frame", nil, cccpopup)
	cccpopup.page:SetHeight(340)
	cccpopup.page:SetWidth(620)
	cccpopup.page:SetBackdrop(LunaOptions.backdrop)
	cccpopup.page:SetBackdropColor(0,0,0,1)
	cccpopup.page:SetPoint("BOTTOMRIGHT", cccpopup, "BOTTOMRIGHT", -10, 10)

	cccpopup.page.leftbuttontext = cccpopup.page:CreateFontString(nil, "OVERLAY", cccpopup.page)
	cccpopup.page.leftbuttontext:SetPoint("TOPLEFT", cccpopup.page, "TOPLEFT", 10, -40)
	cccpopup.page.leftbuttontext:SetFont("Fonts\\FRIZQT__.TTF", 10)
	cccpopup.page.leftbuttontext:SetTextColor(1,0.82,0)
	cccpopup.page.leftbuttontext:SetText("Left Button")
	
	cccpopup.page.rightbuttontext = cccpopup.page:CreateFontString(nil, "OVERLAY", cccpopup.page)
	cccpopup.page.rightbuttontext:SetPoint("TOP", cccpopup.page.leftbuttontext, "BOTTOM", 0, -20)
	cccpopup.page.rightbuttontext:SetFont("Fonts\\FRIZQT__.TTF", 10)
	cccpopup.page.rightbuttontext:SetTextColor(1,0.82,0)
	cccpopup.page.rightbuttontext:SetText("Right Button")
	
	cccpopup.page.middlebuttontext = cccpopup.page:CreateFontString(nil, "OVERLAY", cccpopup.page)
	cccpopup.page.middlebuttontext:SetPoint("TOP", cccpopup.page.rightbuttontext, "BOTTOM", 0, -20)
	cccpopup.page.middlebuttontext:SetFont("Fonts\\FRIZQT__.TTF", 10)
	cccpopup.page.middlebuttontext:SetTextColor(1,0.82,0)
	cccpopup.page.middlebuttontext:SetText("Middle Button")
	
	cccpopup.page.fourbuttontext = cccpopup.page:CreateFontString(nil, "OVERLAY", cccpopup.page)
	cccpopup.page.fourbuttontext:SetPoint("TOP", cccpopup.page.middlebuttontext, "BOTTOM", 0, -20)
	cccpopup.page.fourbuttontext:SetFont("Fonts\\FRIZQT__.TTF", 10)
	cccpopup.page.fourbuttontext:SetTextColor(1,0.82,0)
	cccpopup.page.fourbuttontext:SetText("Button 4")

	cccpopup.page.fivebuttontext = cccpopup.page:CreateFontString(nil, "OVERLAY", cccpopup.page)
	cccpopup.page.fivebuttontext:SetPoint("TOP", cccpopup.page.fourbuttontext, "BOTTOM", 0, -20)
	cccpopup.page.fivebuttontext:SetFont("Fonts\\FRIZQT__.TTF", 10)
	cccpopup.page.fivebuttontext:SetTextColor(1,0.82,0)
	cccpopup.page.fivebuttontext:SetText("Button 5")
	
	cccpopup.page.nonetext = cccpopup.page:CreateFontString(nil, "OVERLAY", cccpopup.page)
	cccpopup.page.nonetext:SetPoint("TOPLEFT", cccpopup.page, "TOPLEFT", 130, -15)
	cccpopup.page.nonetext:SetFont("Fonts\\FRIZQT__.TTF", 10)
	cccpopup.page.nonetext:SetTextColor(1,0.82,0)
	cccpopup.page.nonetext:SetText("NONE")
	
	cccpopup.page.noneleft = CreateFrame("Editbox", "leftEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.noneleft:SetHeight(20)
	cccpopup.page.noneleft:SetWidth(120)
	cccpopup.page.noneleft:SetAutoFocus(nil)
	cccpopup.page.noneleft:SetPoint("TOP", cccpopup.page.nonetext, "BOTTOM", 0, -10)
	cccpopup.page.noneleft:SetText(LunaOptions.clickcast[playerName][1][1] or "target")
	cccpopup.page.noneleft:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.noneleft:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.noneleft:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][1][1] = this:GetText() end)
																	
	cccpopup.page.noneright = CreateFrame("Editbox", "rightEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.noneright:SetHeight(20)
	cccpopup.page.noneright:SetWidth(120)
	cccpopup.page.noneright:SetAutoFocus(nil)
	cccpopup.page.noneright:SetPoint("TOP", cccpopup.page.noneleft, "BOTTOM", 0, -10)
	cccpopup.page.noneright:SetText(LunaOptions.clickcast[playerName][1][2] or "menu")
	cccpopup.page.noneright:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.noneright:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.noneright:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][1][2] = this:GetText() end)
	
	cccpopup.page.nonemiddle = CreateFrame("Editbox", "middleEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.nonemiddle:SetHeight(20)
	cccpopup.page.nonemiddle:SetWidth(120)
	cccpopup.page.nonemiddle:SetAutoFocus(nil)
	cccpopup.page.nonemiddle:SetPoint("TOP", cccpopup.page.noneright, "BOTTOM", 0, -10)
	cccpopup.page.nonemiddle:SetText(LunaOptions.clickcast[playerName][1][3] or "")
	cccpopup.page.nonemiddle:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.nonemiddle:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.nonemiddle:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][1][3] = this:GetText() end)
	
	cccpopup.page.none4 = CreateFrame("Editbox", "4EditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.none4:SetHeight(20)
	cccpopup.page.none4:SetWidth(120)
	cccpopup.page.none4:SetAutoFocus(nil)
	cccpopup.page.none4:SetPoint("TOP", cccpopup.page.nonemiddle, "BOTTOM", 0, -10)
	cccpopup.page.none4:SetText(LunaOptions.clickcast[playerName][1][4] or "")
	cccpopup.page.none4:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.none4:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.none4:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][1][4] = this:GetText() end)
	
	cccpopup.page.none5 = CreateFrame("Editbox", "5EditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.none5:SetHeight(20)
	cccpopup.page.none5:SetWidth(120)
	cccpopup.page.none5:SetAutoFocus(nil)
	cccpopup.page.none5:SetPoint("TOP", cccpopup.page.none4, "BOTTOM", 0, -10)
	cccpopup.page.none5:SetText(LunaOptions.clickcast[playerName][1][5] or "")
	cccpopup.page.none5:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.none5:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.none5:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][1][5] = this:GetText() end)
	
	cccpopup.page.shifttext = cccpopup.page:CreateFontString(nil, "OVERLAY", cccpopup.page)
	cccpopup.page.shifttext:SetPoint("CENTER", cccpopup.page.nonetext, "CENTER", 135, 0)
	cccpopup.page.shifttext:SetFont("Fonts\\FRIZQT__.TTF", 10)
	cccpopup.page.shifttext:SetTextColor(1,0.82,0)
	cccpopup.page.shifttext:SetText("SHIFT")
	
	cccpopup.page.shiftleft = CreateFrame("Editbox", "leftshiftEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.shiftleft:SetHeight(20)
	cccpopup.page.shiftleft:SetWidth(120)
	cccpopup.page.shiftleft:SetAutoFocus(nil)
	cccpopup.page.shiftleft:SetPoint("TOP", cccpopup.page.shifttext, "BOTTOM", 0, -10)
	cccpopup.page.shiftleft:SetText(LunaOptions.clickcast[playerName][2][1] or "")
	cccpopup.page.shiftleft:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.shiftleft:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.shiftleft:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][2][1] = this:GetText() end)
																	
	cccpopup.page.shiftright = CreateFrame("Editbox", "rightshiftEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.shiftright:SetHeight(20)
	cccpopup.page.shiftright:SetWidth(120)
	cccpopup.page.shiftright:SetAutoFocus(nil)
	cccpopup.page.shiftright:SetPoint("TOP", cccpopup.page.shiftleft, "BOTTOM", 0, -10)
	cccpopup.page.shiftright:SetText(LunaOptions.clickcast[playerName][2][2] or "")
	cccpopup.page.shiftright:SetScript("OnEnterPressed", function()	this:ClearFocus() end)
	cccpopup.page.shiftright:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.shiftright:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][2][2] = this:GetText() end)
	
	cccpopup.page.shiftmiddle = CreateFrame("Editbox", "middleshiftEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.shiftmiddle:SetHeight(20)
	cccpopup.page.shiftmiddle:SetWidth(120)
	cccpopup.page.shiftmiddle:SetAutoFocus(nil)
	cccpopup.page.shiftmiddle:SetPoint("TOP", cccpopup.page.shiftright, "BOTTOM", 0, -10)
	cccpopup.page.shiftmiddle:SetText(LunaOptions.clickcast[playerName][2][3] or "")
	cccpopup.page.shiftmiddle:SetScript("OnEnterPressed", function()	this:ClearFocus() end)
	cccpopup.page.shiftmiddle:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.shiftmiddle:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][2][3] = this:GetText() end)

	cccpopup.page.shiftfour = CreateFrame("Editbox", "fourshiftEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.shiftfour:SetHeight(20)
	cccpopup.page.shiftfour:SetWidth(120)
	cccpopup.page.shiftfour:SetAutoFocus(nil)
	cccpopup.page.shiftfour:SetPoint("TOP", cccpopup.page.shiftmiddle, "BOTTOM", 0, -10)
	cccpopup.page.shiftfour:SetText(LunaOptions.clickcast[playerName][2][4] or "")
	cccpopup.page.shiftfour:SetScript("OnEnterPressed", function()	this:ClearFocus() end)
	cccpopup.page.shiftfour:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.shiftfour:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][2][4] = this:GetText() end)
	
	cccpopup.page.shiftfive = CreateFrame("Editbox", "fiveshiftEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.shiftfive:SetHeight(20)
	cccpopup.page.shiftfive:SetWidth(120)
	cccpopup.page.shiftfive:SetAutoFocus(nil)
	cccpopup.page.shiftfive:SetPoint("TOP", cccpopup.page.shiftfour, "BOTTOM", 0, -10)
	cccpopup.page.shiftfive:SetText(LunaOptions.clickcast[playerName][2][5] or "")
	cccpopup.page.shiftfive:SetScript("OnEnterPressed", function()	this:ClearFocus() end)
	cccpopup.page.shiftfive:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.shiftfive:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][2][5] = this:GetText() end)
	
	cccpopup.page.alttext = cccpopup.page:CreateFontString(nil, "OVERLAY", cccpopup.page)
	cccpopup.page.alttext:SetPoint("CENTER", cccpopup.page.shifttext, "CENTER", 135, 0)
	cccpopup.page.alttext:SetFont("Fonts\\FRIZQT__.TTF", 10)
	cccpopup.page.alttext:SetTextColor(1,0.82,0)
	cccpopup.page.alttext:SetText("ALT")
	
	cccpopup.page.altleft = CreateFrame("Editbox", "leftaltEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.altleft:SetHeight(20)
	cccpopup.page.altleft:SetWidth(120)
	cccpopup.page.altleft:SetAutoFocus(nil)
	cccpopup.page.altleft:SetPoint("TOP", cccpopup.page.alttext, "BOTTOM", 0, -10)
	cccpopup.page.altleft:SetText(LunaOptions.clickcast[playerName][3][1] or "")
	cccpopup.page.altleft:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.altleft:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.altleft:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][3][1] = this:GetText() end)
																	
	cccpopup.page.altright = CreateFrame("Editbox", "rightaltEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.altright:SetHeight(20)
	cccpopup.page.altright:SetWidth(120)
	cccpopup.page.altright:SetAutoFocus(nil)
	cccpopup.page.altright:SetPoint("TOP", cccpopup.page.altleft, "BOTTOM", 0, -10)
	cccpopup.page.altright:SetText(LunaOptions.clickcast[playerName][3][2] or "")
	cccpopup.page.altright:SetScript("OnEnterPressed", function() this:ClearFocus()	end)
	cccpopup.page.altright:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.altright:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][3][2] = this:GetText() end)
	
	cccpopup.page.altmiddle = CreateFrame("Editbox", "middlealtEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.altmiddle:SetHeight(20)
	cccpopup.page.altmiddle:SetWidth(120)
	cccpopup.page.altmiddle:SetAutoFocus(nil)
	cccpopup.page.altmiddle:SetPoint("TOP", cccpopup.page.altright, "BOTTOM", 0, -10)
	cccpopup.page.altmiddle:SetText(LunaOptions.clickcast[playerName][3][3] or "")
	cccpopup.page.altmiddle:SetScript("OnEnterPressed", function() this:ClearFocus()	end)
	cccpopup.page.altmiddle:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.altmiddle:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][3][3] = this:GetText() end)
	
	cccpopup.page.altfour = CreateFrame("Editbox", "fouraltEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.altfour:SetHeight(20)
	cccpopup.page.altfour:SetWidth(120)
	cccpopup.page.altfour:SetAutoFocus(nil)
	cccpopup.page.altfour:SetPoint("TOP", cccpopup.page.altmiddle, "BOTTOM", 0, -10)
	cccpopup.page.altfour:SetText(LunaOptions.clickcast[playerName][3][4] or "")
	cccpopup.page.altfour:SetScript("OnEnterPressed", function() this:ClearFocus()	end)
	cccpopup.page.altfour:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.altfour:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][3][4] = this:GetText() end)
	
	cccpopup.page.altfive = CreateFrame("Editbox", "fivealtEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.altfive:SetHeight(20)
	cccpopup.page.altfive:SetWidth(120)
	cccpopup.page.altfive:SetAutoFocus(nil)
	cccpopup.page.altfive:SetPoint("TOP", cccpopup.page.altfour, "BOTTOM", 0, -10)
	cccpopup.page.altfive:SetText(LunaOptions.clickcast[playerName][3][5] or "")
	cccpopup.page.altfive:SetScript("OnEnterPressed", function() this:ClearFocus()	end)
	cccpopup.page.altfive:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.altfive:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][3][5] = this:GetText() end)
	
	cccpopup.page.ctrltext = cccpopup.page:CreateFontString(nil, "OVERLAY", cccpopup.page)
	cccpopup.page.ctrltext:SetPoint("CENTER", cccpopup.page.alttext, "CENTER", 135, 0)
	cccpopup.page.ctrltext:SetFont("Fonts\\FRIZQT__.TTF", 10)
	cccpopup.page.ctrltext:SetTextColor(1,0.82,0)
	cccpopup.page.ctrltext:SetText("CTRL")
	
	cccpopup.page.ctrlleft = CreateFrame("Editbox", "leftctrlEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.ctrlleft:SetHeight(20)
	cccpopup.page.ctrlleft:SetWidth(120)
	cccpopup.page.ctrlleft:SetAutoFocus(nil)
	cccpopup.page.ctrlleft:SetPoint("TOP", cccpopup.page.ctrltext, "BOTTOM", 0, -10)
	cccpopup.page.ctrlleft:SetText(LunaOptions.clickcast[playerName][4][1] or "")
	cccpopup.page.ctrlleft:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.ctrlleft:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.ctrlleft:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][4][1] = this:GetText() end)
																	
	cccpopup.page.ctrlright = CreateFrame("Editbox", "rightctrlEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.ctrlright:SetHeight(20)
	cccpopup.page.ctrlright:SetWidth(120)
	cccpopup.page.ctrlright:SetAutoFocus(nil)
	cccpopup.page.ctrlright:SetPoint("TOP", cccpopup.page.ctrlleft, "BOTTOM", 0, -10)
	cccpopup.page.ctrlright:SetText(LunaOptions.clickcast[playerName][4][2] or "")
	cccpopup.page.ctrlright:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.ctrlright:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.ctrlright:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][4][2] = this:GetText() end)
	
	cccpopup.page.ctrlmiddle = CreateFrame("Editbox", "middlectrlEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.ctrlmiddle:SetHeight(20)
	cccpopup.page.ctrlmiddle:SetWidth(120)
	cccpopup.page.ctrlmiddle:SetAutoFocus(nil)
	cccpopup.page.ctrlmiddle:SetPoint("TOP", cccpopup.page.ctrlright, "BOTTOM", 0, -10)
	cccpopup.page.ctrlmiddle:SetText(LunaOptions.clickcast[playerName][4][3] or "")
	cccpopup.page.ctrlmiddle:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.ctrlmiddle:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.ctrlmiddle:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][4][3] = this:GetText() end)
	
	cccpopup.page.ctrlfour = CreateFrame("Editbox", "fourctrlEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.ctrlfour:SetHeight(20)
	cccpopup.page.ctrlfour:SetWidth(120)
	cccpopup.page.ctrlfour:SetAutoFocus(nil)
	cccpopup.page.ctrlfour:SetPoint("TOP", cccpopup.page.ctrlmiddle, "BOTTOM", 0, -10)
	cccpopup.page.ctrlfour:SetText(LunaOptions.clickcast[playerName][4][4] or "")
	cccpopup.page.ctrlfour:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.ctrlfour:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.ctrlfour:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][4][4] = this:GetText() end)
	
	cccpopup.page.ctrlfive = CreateFrame("Editbox", "fivectrlEditBox", cccpopup.page, "InputBoxTemplate")
	cccpopup.page.ctrlfive:SetHeight(20)
	cccpopup.page.ctrlfive:SetWidth(120)
	cccpopup.page.ctrlfive:SetAutoFocus(nil)
	cccpopup.page.ctrlfive:SetPoint("TOP", cccpopup.page.ctrlfour, "BOTTOM", 0, -10)
	cccpopup.page.ctrlfive:SetText(LunaOptions.clickcast[playerName][4][5] or "")
	cccpopup.page.ctrlfive:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	cccpopup.page.ctrlfive:SetScript("OnEditFocusGained", function() cccpopup.current = this end)
	cccpopup.page.ctrlfive:SetScript("OnEditFocusLost", function() LunaOptions.clickcast[playerName][4][5] = this:GetText() end)
	
	cccpopup.page.desc = cccpopup.page:CreateFontString(nil, "OVERLAY", cccpopup.page)
	cccpopup.page.desc:SetPoint("BOTTOMLEFT", cccpopup.page, "BOTTOMLEFT", 10, 10)
	cccpopup.page.desc:SetFont("Fonts\\FRIZQT__.TTF", 10)
	cccpopup.page.desc:SetTextColor(1,1,1)
	cccpopup.page.desc:SetText("HowTo:\n\n\"target\"\nNormal target behaviour.\n\n\"menu\"\nNormal popup menu.\n\n<Spellname>\nYour spell of choice. Note: You can select a box and then shift click spells from your spellbook.\n\nfunction()\nA function from the UI or one of your add-ons. While its executed your target will be the one you clicked.")
	cccpopup.page.desc:SetJustifyH("LEFT")
	
	local function AddLine(line)
		if cccpopup.current then
			cccpopup.current:SetText(line)
			cccpopup.current:ClearFocus()
		end
	end
	
	SpellButton_OnClick = function(drag)
		local id = SpellBook_GetSpellID(this:GetID());
		if ( id > MAX_SPELLS ) then
			return;
		end
		this:SetChecked("false");
		if ( drag ) then
			PickupSpell(id, SpellBookFrame.bookType);
		elseif ( IsShiftKeyDown() ) then
			if ( MacroFrame and MacroFrame:IsVisible() ) then
				local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType);
				if ( spellName and not IsSpellPassive(id, SpellBookFrame.bookType) ) then
					if ( subSpellName and (strlen(subSpellName) > 0) ) then
						MacroFrame_AddMacroLine(TEXT(SLASH_CAST1).." "..spellName.."("..subSpellName..")");
					else
						MacroFrame_AddMacroLine(TEXT(SLASH_CAST1).." "..spellName);
					end
				end
			elseif ( cccpopup and cccpopup:IsVisible() ) then
				local spellName, subSpellName = GetSpellName(id, SpellBookFrame.bookType);
				if ( spellName and not IsSpellPassive(id, SpellBookFrame.bookType) ) then
					if ( subSpellName and (strlen(subSpellName) > 0) ) then
						AddLine(spellName.."("..subSpellName..")");		
					else
						AddLine(spellName);
					end
				end
			else
				PickupSpell(id, SpellBookFrame.bookType );
			end
		elseif ( arg1 ~= "LeftButton" and SpellBookFrame.bookType == BOOKTYPE_PET ) then
			ToggleSpellAutocast(id, SpellBookFrame.bookType);
		else
			CastSpell(id, SpellBookFrame.bookType);
			SpellButton_UpdateSelection();
		end
	end
	
	LunaOptionsFrame.helpframe = CreateFrame("Frame", nil, LunaOptionsFrame)
	LunaOptionsFrame.helpframe:SetHeight(690)
	LunaOptionsFrame.helpframe:SetWidth(300)
	LunaOptionsFrame.helpframe:SetBackdrop(LunaOptions.backdrop)
	LunaOptionsFrame.helpframe:SetBackdropColor(0.18,0.27,0.5)
	LunaOptionsFrame.helpframe:SetPoint("TOPLEFT", LunaOptionsFrame, "TOPRIGHT", 5, 0)
	
	LunaOptionsFrame.helpframe.title = LunaOptionsFrame.helpframe:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.helpframe)
	LunaOptionsFrame.helpframe.title:SetFont(LunaOptions.font, 20)
	LunaOptionsFrame.helpframe.title:SetText("Tags")
	LunaOptionsFrame.helpframe.title:SetJustifyH("CENTER")
	LunaOptionsFrame.helpframe.title:SetJustifyV("TOP")
	LunaOptionsFrame.helpframe.title:SetPoint("TOP", LunaOptionsFrame.helpframe, "TOP")
	LunaOptionsFrame.helpframe.title:SetHeight(20)
	LunaOptionsFrame.helpframe.title:SetWidth(300)
	
	LunaOptionsFrame.helpframe.texts = {}
	local dist
	local prevframe = LunaOptionsFrame.helpframe.title
	for k,v in pairs(TagDesc) do
		LunaOptionsFrame.helpframe.texts[k] = LunaOptionsFrame.helpframe:CreateFontString(nil, "OVERLAY", LunaOptionsFrame.helpframe)
		LunaOptionsFrame.helpframe.texts[k]:SetFont(LunaOptions.font, 10)
		LunaOptionsFrame.helpframe.texts[k]:SetText("["..k.."]: "..v)
		LunaOptionsFrame.helpframe.texts[k]:SetJustifyH("LEFT")
		LunaOptionsFrame.helpframe.texts[k]:SetJustifyV("TOP")
		if LunaOptionsFrame.helpframe.texts[k]:GetStringWidth() > 280 then
			LunaOptionsFrame.helpframe.texts[k]:SetHeight(22)
		else
			LunaOptionsFrame.helpframe.texts[k]:SetHeight(11)
		end
		LunaOptionsFrame.helpframe.texts[k]:SetWidth(300)
		if not dist then
			LunaOptionsFrame.helpframe.texts[k]:SetPoint("TOP", prevframe, "BOTTOM")
		else
			LunaOptionsFrame.helpframe.texts[k]:SetPoint("TOPLEFT", prevframe, "BOTTOMLEFT")
		end
		prevframe = LunaOptionsFrame.helpframe.texts[k]
		dist = 1
	end
	LunaOptionsFrame.helpframe:Hide()
end

function LunaUnitFrames:UpdateBarTextures()
	local texture = BarTexturesPath .. BarTextures[LunaOptions.BarTexture]

	-- Player
	LunaPlayerFrame.bars["Healthbar"]:SetStatusBarTexture(texture)
	LunaPlayerFrame.incHeal:SetStatusBarTexture(texture)
	LunaPlayerFrame.bars["Powerbar"]:SetStatusBarTexture(texture)
	LunaPlayerFrame.bars["Castbar"]:SetStatusBarTexture(texture)
	LunaPlayerFrame.bars["Druidbar"]:SetStatusBarTexture(texture)

	for i=1, 4 do
		LunaPlayerFrame.totems[i]:SetStatusBarTexture(texture)
	end

	-- ExperienceBar
	LunaUnitFrames.frames.ReputationBar.RepBar:SetStatusBarTexture(texture)
	LunaUnitFrames.frames.ExperienceBar.RestedBar:SetStatusBarTexture(texture)
	LunaUnitFrames.frames.ExperienceBar.XPBar:SetStatusBarTexture(texture)

	-- Pet
	LunaPetFrame.bars["Healthbar"]:SetStatusBarTexture(texture)
	LunaPetFrame.bars["Powerbar"]:SetStatusBarTexture(texture)

	-- Target
	for i=1, 5 do
		LunaTargetFrame.cp[i]:SetStatusBarTexture(texture)
	end

	-- TargetTarget
	LunaTargetTargetFrame.bars["Healthbar"]:SetStatusBarTexture(texture)
	LunaTargetTargetFrame.bars["Powerbar"]:SetStatusBarTexture(texture)
	LunaTargetTargetTargetFrame.bars["Healthbar"]:SetStatusBarTexture(texture)
	LunaTargetTargetTargetFrame.bars["Powerbar"]:SetStatusBarTexture(texture)
	LunaTargetFrame.bars["Healthbar"]:SetStatusBarTexture(texture)
	LunaTargetFrame.incHeal:SetStatusBarTexture(texture)
	LunaTargetFrame.bars["Powerbar"]:SetStatusBarTexture(texture)
	LunaTargetFrame.bars["Castbar"]:SetStatusBarTexture(texture)

	for i=1, 4 do
		-- Party
		LunaPartyFrames[i].bars["Healthbar"]:SetStatusBarTexture(texture)
		LunaPartyFrames[i].incHeal:SetStatusBarTexture(texture)
		LunaPartyFrames[i].bars["Powerbar"]:SetStatusBarTexture(texture)
		-- PartyPet
		LunaPartyPetFrames[i].HealthBar:SetStatusBarTexture(texture)
		-- PartyTarget
		LunaPartyTargetFrames[i].HealthBar:SetStatusBarTexture(texture)
	end

	-- Raid
	for i=1, 80 do
		LunaUnitFrames.frames.members[i].HealthBar:SetStatusBarTexture(texture)
		LunaUnitFrames.frames.members[i].HealBar:SetStatusBarTexture(texture)
		LunaUnitFrames.frames.members[i].bg:SetTexture(texture)
		LunaUnitFrames.frames.members[i].PowerBar:SetStatusBarTexture(texture)
	end
end