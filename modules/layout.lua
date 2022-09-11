LUF = select(2, ...)

local oUF = LUF.oUF
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	tile = true,
	tileSize = 16,
	insets = {left = -1, right = -1, top = -1, bottom = -1},
}

local RaidStatusIndicatorOffsets = {
	["topleft"] = {
		x = 1,
		y = -1,
	},
	["top"] = {
		x = 0,
		y = -1,
	},
	["topright"] = {
		x = -1,
		y = -1,
	},
	["left"] = {
		x = 1,
		y = 0,
	},
	["center"] = {
		x = 0,
		y = 0,
	},
	["right"] = {
		x = -1,
		y = 0,
	},
	["bottomleft"] = {
		x = 1,
		y = 1,
	},
	["bottom"] = {
		x = 0,
		y = 1,
	},
	["bottomright"] = {
		x = -1,
		y = 1,
	},
}

local UnitSpecific = {
	player = function(frame)
	-- Regen Ticker
		local RegenTicker = CreateFrame("StatusBar", nil, frame.Power)
		frame.RegenTicker = RegenTicker

	-- Power Prediction
		frame.PowerPrediction = {}
		local mainBar = CreateFrame("StatusBar", nil, frame.Power)
		mainBar:SetStatusBarTexture([[Interface\ChatFrame\ChatFrameBackground]])
		mainBar:SetReverseFill(true)
		mainBar:SetFrameLevel(frame.Power:GetFrameLevel())
		mainBar:GetStatusBarTexture():SetDrawLayer("ARTWORK",7)
		frame.Power:SetScript("OnSizeChanged", function(self)
			local orientation = self:GetOrientation()
			local mod = self:GetParent().PowerPrediction.mainBar
			mod:ClearAllPoints()
			mod:SetOrientation(orientation)
			if orientation == "HORIZONTAL" then
				mod:SetPoint("TOP")
				mod:SetPoint("BOTTOM")
				mod:SetPoint("RIGHT", self:GetStatusBarTexture(), "RIGHT")
				mod:SetWidth(self:GetWidth())
			else
				mod:SetPoint("LEFT")
				mod:SetPoint("RIGHT")
				mod:SetPoint("TOP", self:GetStatusBarTexture(), "TOP")
				mod:SetHeight(self:GetHeight())
			end
		end)
		frame.PowerPrediction.mainBar = mainBar

	-- Castbar
		local Castbar = CreateFrame("StatusBar", nil, frame)

		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetAllPoints(Castbar)

		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(10, 10)
		Icon:SetPoint("TOPLEFT", Castbar, "TOPLEFT")

		local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")

		Castbar.bg = Background
		Castbar.Icon = Icon
		Castbar.SafeZone = SafeZone
		Castbar:SetScript("OnShow", LUF.PlaceModules)
		Castbar:SetScript("OnHide", LUF.PlaceModules)
		frame.Castbar = Castbar
		frame.modules.castBar = Castbar
		frame.modules.castBar.name = "Castbar"
		
	-- Totembar
		if select(2, UnitClass('player')) == "SHAMAN" then
			local totemBar = CreateFrame("Frame", nil, frame)
			frame.Totems = {}
			for i=1,4 do
				frame.Totems[i] = CreateFrame("StatusBar", nil, totemBar)
				frame.Totems[i]:SetMinMaxValues(0,1)
				frame.Totems[i]:SetValue(0)
				frame.Totems[i].bg = frame.Totems[i]:CreateTexture(nil, "BACKGROUND")
				frame.Totems[i].bg:SetAllPoints(frame.Totems[i])
			end
			frame.Totems.PostUpdate = LUF.overrides["Totems"].PostUpdate
			totemBar.Totems = frame.Totems
			totemBar.Update = LUF.overrides["Totems"].Update
			frame.modules.totemBar = totemBar
			frame.modules.totemBar.name = "Totems"
		end
		
	-- Druid Bar
		if select(2, UnitClass('player')) == "DRUID" then
			local AdditionalPower = CreateFrame("StatusBar", nil, frame)

			local Background = AdditionalPower:CreateTexture(nil, "BACKGROUND")
			Background:SetAllPoints(AdditionalPower)

			AdditionalPower.frequentUpdates = true
			AdditionalPower.colorDisconnected = true
			AdditionalPower.colorPower = true

			AdditionalPower.PostUpdateVisibility = LUF.overrides["AdditionalPower"].PostUpdateVisibility

			AdditionalPower.bg = Background
			frame.AdditionalPower = AdditionalPower
			frame.modules.druidBar = AdditionalPower
			frame.modules.druidBar.name = "AdditionalPower"

			frame.tags.druidBar = {}
			
	-- Regen Ticker
			local AdditionalRegenTicker = CreateFrame("StatusBar", nil, frame.AdditionalPower)
			frame.AdditionalRegenTicker = AdditionalRegenTicker
		end
		
	-- Reckoning
		if select(2, UnitClass('player')) == "PALADIN" then
			local reckStacks = CreateFrame("Frame", nil, frame)
			local Reckoning = {}
			for i=1,4 do
				Reckoning[i] = CreateFrame("StatusBar", nil, reckStacks)
				Reckoning[i].bg = reckStacks:CreateTexture(nil, "BACKGROUND")
				Reckoning[i].bg:SetAllPoints(Reckoning[i])
			end
			reckStacks.Update = LUF.overrides["Reckoning"].Update
			Reckoning.PostUpdate = LUF.overrides["Reckoning"].PostUpdate
			reckStacks.Reckoning = Reckoning
			reckStacks.name = "Reckoning"
			frame.modules.reckStacks = reckStacks
			frame.Reckoning = Reckoning
		end
		
	-- XP Bar
		local xpBarFrame = CreateFrame("Frame", nil, frame)
		xpBarFrame:SetScript("OnSizeChanged", function(self)
			self.xpBar:ClearAllPoints()
			self.repBar:ClearAllPoints()
			if self.xpBar:IsShown() and not self.repBar:IsShown() then
				self.xpBar:SetAllPoints(mod)
			elseif not self.xpBar:IsShown() and self.repBar:IsShown() then
				self.repBar:SetAllPoints(mod)
			elseif self.xpBar:IsShown() and self.repBar:IsShown() then
				local x,y = self:GetWidth(), self:GetHeight() / 2
				self.xpBar:SetPoint("BOTTOM", self, "BOTTOM")
				self.xpBar:SetSize(x,y)
				self.repBar:SetPoint("TOP", self, "TOP")
				self.repBar:SetSize(x,y)
			end
		end)
		local xpBar = CreateFrame("StatusBar", nil, xpBarFrame)
		xpBar:SetFrameLevel(xpBarFrame:GetFrameLevel())
		xpBarFrame.xpBar = xpBar
		xpBar.bg = xpBar:CreateTexture(nil, "BACKGROUND")
		xpBar.bg:SetAllPoints(xpBar)
		local repBar = CreateFrame("StatusBar", nil, xpBarFrame)
		repBar:SetFrameLevel(xpBarFrame:GetFrameLevel())
		xpBarFrame.repBar = repBar
		repBar.bg = repBar:CreateTexture(nil, "BACKGROUND")
		repBar.bg:SetAllPoints(repBar)
		frame.XPRepBar = {
			xpBar = xpBar,
			repBar = repBar,
			PostUpdate = LUF.overrides["XPBar"].PostUpdate
		}
		frame.modules.xpBar = xpBarFrame
		frame.modules.xpBar.name = "XPRepBar"
		frame.tags.xpBar = {}

		if select(2, UnitClass('player')) == "DEATHKNIGHT" then
	-- Ghoul Timer
			local Ghoul = CreateFrame("StatusBar", nil, frame)

			local Background = Ghoul:CreateTexture(nil, "BACKGROUND")
			Background:SetAllPoints(Ghoul)

			Ghoul.bg = Background
			Ghoul:SetScript("OnShow", LUF.PlaceModules)
			Ghoul:SetScript("OnHide", LUF.PlaceModules)
			Ghoul:SetMinMaxValues(0,1)
			Ghoul:SetValue(0)
			Ghoul.PostUpdate = LUF.overrides["Ghoul"].PostUpdate
			frame.Ghoul = Ghoul
			frame.modules.ghoul = Ghoul
			frame.modules.ghoul.name = "Ghoul"

	-- Runes
			local runes = CreateFrame("Frame", nil, frame)
			local Runes = {}
			for i=1,6 do
				Runes[i] = CreateFrame("StatusBar", nil, runes)
				Runes[i].bg = runes:CreateTexture(nil, "BACKGROUND")
				Runes[i].bg:SetAllPoints(Runes[i])
				Runes[i].timer = Runes[i]:CreateFontString("LUFRuneCooldown"..i, "OVERLAY")
				Runes[i].timer:SetPoint("CENTER", Runes[i], "CENTER")
			end
			runes.Update = LUF.overrides["Runes"].Update
			Runes.PostUpdate = LUF.overrides["Runes"].PostUpdate
			runes.Runes = Runes
			runes.name = "Runes"
			frame.modules.runes = runes
			frame.Runes = Runes
		end

	-- Combo Points
		local comboPoints = CreateFrame("Frame", nil, frame)
		local ComboPoints = {}
		for i=1,5 do
			ComboPoints[i] = CreateFrame("StatusBar", nil, comboPoints)
			ComboPoints[i].bg = comboPoints:CreateTexture(nil, "BACKGROUND")
			ComboPoints[i].bg:SetAllPoints(ComboPoints[i])
		end
		comboPoints.Update = LUF.overrides["ComboPoints"].Update
		ComboPoints.PostUpdate = LUF.overrides["ComboPoints"].PostUpdate
		comboPoints.ComboPoints = ComboPoints
		comboPoints.name = "ComboPoints"
		frame.modules.comboPoints = comboPoints
		frame.ComboPoints = ComboPoints
	end,

	pet = function(frame)
	-- XP Bar
		local xpBarFrame = CreateFrame("Frame", nil, frame)
		xpBarFrame:SetScript("OnSizeChanged", function() end)
		local xpBar = CreateFrame("StatusBar", nil, xpBarFrame)
		xpBar:SetFrameLevel(xpBarFrame:GetFrameLevel())
		xpBarFrame.xpBar = xpBar
		xpBar.bg = xpBar:CreateTexture(nil, "BACKGROUND")
		xpBar.bg:SetAllPoints(xpBar)
		xpBar:SetAllPoints(xpBarFrame)
		frame.XPRepBar = {
			xpBar = xpBar,
			PostUpdate = LUF.overrides["XPBar"].PostUpdate
		}
		frame.modules.xpBar = xpBarFrame
		frame.modules.xpBar.name = "XPRepBar"
		frame.tags.xpBar = {}
	end,

	pettarget = function(frame)
	-- Nothing here yet
	end,

	pettargettarget = function(frame)
	-- Nothing here yet
	end,

	target = function(frame)
	-- Castbar
		local Castbar = CreateFrame("StatusBar", nil, frame)

		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetAllPoints(Castbar)

		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(10, 10)
		Icon:SetPoint("TOPLEFT", Castbar, "TOPLEFT")

		local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")

		Castbar.bg = Background
		Castbar.Icon = Icon
		Castbar.SafeZone = SafeZone
		Castbar:SetScript("OnShow", LUF.PlaceModules)
		Castbar:SetScript("OnHide", LUF.PlaceModules)
		frame.Castbar = Castbar
		frame.modules.castBar = Castbar
		frame.modules.castBar.name = "Castbar"
	
	-- Combo Points
		local comboPoints = CreateFrame("Frame", nil, frame)
		local ComboPoints = {}
		for i=1,5 do
			ComboPoints[i] = CreateFrame("StatusBar", nil, comboPoints)
			ComboPoints[i].bg = comboPoints:CreateTexture(nil, "BACKGROUND")
			ComboPoints[i].bg:SetAllPoints(ComboPoints[i])
		end
		comboPoints.Update = LUF.overrides["ComboPoints"].Update
		ComboPoints.PostUpdate = LUF.overrides["ComboPoints"].PostUpdate
		comboPoints.ComboPoints = ComboPoints
		comboPoints.name = "ComboPoints"
		frame.modules.comboPoints = comboPoints
		frame.ComboPoints = ComboPoints
	end,

	targettarget = function(frame)
	-- Nothing here yet
	end,

	targettargettarget = function(frame)
	-- Nothing here yet
	end,

	focus = function(frame)
	-- Castbar
		local Castbar = CreateFrame("StatusBar", nil, frame)

		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetAllPoints(Castbar)

		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(10, 10)
		Icon:SetPoint("TOPLEFT", Castbar, "TOPLEFT")

		local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")

		Castbar.bg = Background
		Castbar.Icon = Icon
		Castbar.SafeZone = SafeZone
		Castbar:SetScript("OnShow", LUF.PlaceModules)
		Castbar:SetScript("OnHide", LUF.PlaceModules)
		frame.Castbar = Castbar
		frame.modules.castBar = Castbar
		frame.modules.castBar.name = "Castbar"
	end,

	focustarget = function(frame)
	-- Nothing here yet
	end,

	focustargettarget = function(frame)
	-- Nothing here yet
	end,

	party = function(frame)
	-- Castbar
		local Castbar = CreateFrame("StatusBar", nil, frame)

		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetAllPoints(Castbar)

		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(10, 10)
		Icon:SetPoint("TOPLEFT", Castbar, "TOPLEFT")

		local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")

		Castbar.bg = Background
		Castbar.Icon = Icon
		Castbar.SafeZone = SafeZone
		Castbar:SetScript("OnShow", LUF.PlaceModules)
		Castbar:SetScript("OnHide", LUF.PlaceModules)
		frame.Castbar = Castbar
		frame.modules.castBar = Castbar
		frame.modules.castBar.name = "Castbar"
	end,

	partytarget = function(frame)
	-- Nothing here yet
	end,

	partypet = function(frame)
	-- Nothing here yet
	end,

	raid = function(frame)
	-- Castbar
		local Castbar = CreateFrame("StatusBar", nil, frame)

		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetAllPoints(Castbar)

		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(10, 10)
		Icon:SetPoint("TOPLEFT", Castbar, "TOPLEFT")

		local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")

		Castbar.bg = Background
		Castbar.Icon = Icon
		Castbar.SafeZone = SafeZone
		Castbar:SetScript("OnShow", LUF.PlaceModules)
		Castbar:SetScript("OnHide", LUF.PlaceModules)
		frame.Castbar = Castbar
		frame.modules.castBar = Castbar
		frame.modules.castBar.name = "Castbar"
	end,
	
	raidpet = function(frame)
	-- Nothing here yet
	end,
	
	maintank = function(frame)
	-- Castbar
		local Castbar = CreateFrame("StatusBar", nil, frame)

		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetAllPoints(Castbar)

		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(10, 10)
		Icon:SetPoint("TOPLEFT", Castbar, "TOPLEFT")

		local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")

		Castbar.bg = Background
		Castbar.Icon = Icon
		Castbar.SafeZone = SafeZone
		Castbar:SetScript("OnShow", LUF.PlaceModules)
		Castbar:SetScript("OnHide", LUF.PlaceModules)
		frame.Castbar = Castbar
		frame.modules.castBar = Castbar
		frame.modules.castBar.name = "Castbar"
	end,
	
	maintanktarget = function(frame)
	-- Nothing here yet
	end,
	
	maintanktargettarget = function(frame)
	-- Nothing here yet
	end,
	
	mainassist = function(frame)
	-- Castbar
		local Castbar = CreateFrame("StatusBar", nil, frame)

		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetAllPoints(Castbar)

		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(10, 10)
		Icon:SetPoint("TOPLEFT", Castbar, "TOPLEFT")

		local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")

		Castbar.bg = Background
		Castbar.Icon = Icon
		Castbar.SafeZone = SafeZone
		Castbar:SetScript("OnShow", LUF.PlaceModules)
		Castbar:SetScript("OnHide", LUF.PlaceModules)
		frame.Castbar = Castbar
		frame.modules.castBar = Castbar
		frame.modules.castBar.name = "Castbar"
	end,
	
	mainassisttarget = function(frame)
	-- Nothing here yet
	end,
	
	mainassisttargettarget = function(frame)
	-- Nothing here yet
	end,
	
	arena = function(frame)
	-- Castbar
		local Castbar = CreateFrame("StatusBar", nil, frame)

		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetAllPoints(Castbar)

		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(10, 10)
		Icon:SetPoint("TOPLEFT", Castbar, "TOPLEFT")

		local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")

		Castbar.bg = Background
		Castbar.Icon = Icon
		Castbar.SafeZone = SafeZone
		Castbar:SetScript("OnShow", LUF.PlaceModules)
		Castbar:SetScript("OnHide", LUF.PlaceModules)
		frame.Castbar = Castbar
		frame.modules.castBar = Castbar
		frame.modules.castBar.name = "Castbar"
		
	-- Trinket
		frame.Trinket = CreateFrame("Frame", nil, frame.toplevel)
		frame.Trinket.icon = frame.Trinket:CreateTexture(nil, "OVERLAY")
		frame.Trinket.icon:SetAllPoints()
		frame.Trinket.cd = CreateFrame("Cooldown", frame:GetName().."TrinketCooldown", frame.Trinket, "CooldownFrameTemplate")
		frame.Trinket.cd:SetAllPoints()
		frame.Trinket.cd:SetReverse(true)
	end,
	
	arenapet = function(frame)
	-- Nothing here yet
	end,
	
	arenatarget = function(frame)
	-- Nothing here yet
	end,

	boss = function(frame)
		-- Castbar
		local Castbar = CreateFrame("StatusBar", nil, frame)

		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetAllPoints(Castbar)

		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(10, 10)
		Icon:SetPoint("TOPLEFT", Castbar, "TOPLEFT")

		local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")

		Castbar.bg = Background
		Castbar.Icon = Icon
		Castbar.SafeZone = SafeZone
		Castbar:SetScript("OnShow", LUF.PlaceModules)
		Castbar:SetScript("OnHide", LUF.PlaceModules)
		frame.Castbar = Castbar
		frame.modules.castBar = Castbar
		frame.modules.castBar.name = "Castbar"
	end
}

LUF.IndicatorData = {
	happiness = {name = "HappinessIndicator", layer = "OVERLAY" },
	raidTarget = { name = "RaidTargetIndicator", layer = "OVERLAY" },
	elite = { name = "EliteIndicator", layer = "ARTWORK" },
	class = { name = "ClassIndicator", layer = "OVERLAY" },
	masterLoot = { name = "MasterLooterIndicator", layer = "OVERLAY" },
	leader = { name = "LeaderIndicator", layer = "OVERLAY", Override = LUF.overrides["LeaderIcon"].Update },
	pvp = { name = "PvPIndicator", layer = "OVERLAY" },
	pvprank = { name = "PvPRankIndicator", layer = "OVERLAY" },
	ready = { name = "ReadyCheckIndicator", layer = "OVERLAY" },
	status = { name = "StatusIndicator", layer = "OVERLAY" },
	rezz = { name = "ResurrectIndicator", layer = "OVERLAY" },
	grouprole = { name = "GroupRoleIndicator", layer = "OVERLAY" },
	raidrole = { name = "RaidRoleIndicator", layer = "OVERLAY" },
}

function LUF.InitializeUnit(frame, unit, notHeaderChild)
	if notHeaderChild then
		if frame:GetName():match("arena") then
			frame:SetAttribute("oUF-guessUnit", frame:GetName():match("LUFHeader(arena.*)UnitButton%d$"))
		elseif frame:GetName():match("boss") then
			frame:SetAttribute("oUF-guessUnit", frame:GetName():match("LUFHeader(boss.*)UnitButton%d$"))
		else
			frame:SetAttribute("oUF-guessUnit", unit)
		end
	end

	local unit = frame:GetAttribute("oUF-guessUnit")

	frame.toplevel = CreateFrame("Frame", nil, frame)
	frame.toplevel:SetFrameLevel(5)

	frame.modules = {}

	frame.tags = {}
	frame.tags.top = {}
	frame.tags.bottom = {}

	frame.indicators = {}

	frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetAllPoints(frame)
	frame.bg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")

	local Portrait = {
	}
	Portrait.model = CreateFrame("PlayerModel", nil, frame)
	Portrait.texture = frame:CreateTexture(nil, "OVERLAY")
	Portrait.texture:SetAllPoints(Portrait.model)

	frame.StatusPortrait = Portrait
	frame.modules.portrait = Portrait.model
	frame.modules.portrait.name = "StatusPortrait"

-- Healthbar
	local Health = CreateFrame("StatusBar", nil, frame)

	local Background = Health:CreateTexture(nil, "BACKGROUND")
	Background:SetAllPoints(Health)

	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorHealth = true
	Health.colorCivilian = true

	Health.UpdateColor = LUF.overrides["Health"].UpdateColor

	Health.bg = Background
	frame.Health = Health
	frame.modules.healthBar = Health
	frame.modules.healthBar.name = "Health"
	
	frame.tags.healthBar = {}

-- Powerbar
	local Power = CreateFrame("StatusBar", nil, frame)

	local Background = Power:CreateTexture(nil, "BACKGROUND")
	Background:SetAllPoints(Power)

	Power.frequentUpdates = true
	Power.colorDisconnected = true
	Power.colorPower = true

	Power.bg = Background
	frame.Power = Power
	frame.modules.powerBar = Power
	frame.modules.powerBar.name = "Power"

	frame.tags.powerBar = {}

-- Empty Bar
	frame.Empty = CreateFrame("StatusBar", nil, frame)
	frame.Empty.name = "Empty"
	frame.modules.emptyBar = frame.Empty
	frame.tags.emptyBar = {}

-- Indicators
	for iname in pairs(LUF.defaults.profile.units[unit].indicators) do
		local data = LUF.IndicatorData[iname]
		frame[data.name] = frame.toplevel:CreateTexture(nil, data.layer)
		if data.Override then
			frame[data.name].Override = data.Override
		end
		frame.indicators[iname] = frame[data.name]
	end

-- Range
	if unit ~= "player" then
		frame.Range = {
			range = 40,
			Override = LUF.overrides["Range"].Update
		}
	end

-- Combat Fader
	if not strmatch(unit,"^target.*$") then
		frame.SimpleFader = {
			combatAlpha = 1,
			inactiveAlpha = 0.35,
		}
	end

-- Auras
	frame.SimpleAuras = CreateFrame("Frame", nil, frame)
	frame.SimpleAuras:SetAllPoints(frame)

	if(UnitSpecific[unit]) then
		UnitSpecific[unit](frame)
	end

	if frame.Castbar then
		frame.Castbar.PostCastStart = LUF.overrides["CastBar"].PostCastStart
		frame.tags.castBar = {}
	end

	-- Combat Text
	frame.CombatText = CreateFrame("Frame", nil, frame.toplevel)

	-- Highlight
	frame.Highlight = frame.toplevel:CreateTexture(nil, "BACKGROUND")
	frame.Highlight:SetTexture([[Interface\AddOns\LunaUnitFrames\media\textures\highlight]])
	frame.Highlight:SetBlendMode("ADD")
	frame.Highlight:SetAllPoints(frame)

	-- Border Highlight
	frame.BorderHighlight = {}

	-- Squares
	local RaidStatusIndicators = {}
	for k in pairs(LUF.defaults.profile.units.player.squares) do
		local indicator = CreateFrame("Frame", nil, frame.toplevel, "BackdropTemplate")
		indicator:SetBackdrop(backdrop)
		indicator:SetBackdropColor(0,0,0)
		indicator.texture = indicator:CreateTexture(nil, "OVERLAY")
		indicator.texture:SetAllPoints(indicator)
		RaidStatusIndicators[k] = indicator
	end
	frame.RaidStatusIndicators = RaidStatusIndicators

	-- Heal Prediction
	local otherBeforeBar = CreateFrame("StatusBar", nil, frame.Health)
	otherBeforeBar:SetStatusBarTexture([[Interface\ChatFrame\ChatFrameBackground]])
	otherBeforeBar:Hide()

	local myBar = CreateFrame("StatusBar", nil, frame.Health)
	myBar:SetStatusBarTexture([[Interface\ChatFrame\ChatFrameBackground]])
	otherBeforeBar:Hide()

	local otherAfterBar = CreateFrame("StatusBar", nil, frame.Health)
	otherAfterBar:SetStatusBarTexture([[Interface\ChatFrame\ChatFrameBackground]])
	otherBeforeBar:Hide()

	local hotBar = CreateFrame("StatusBar", nil, frame.Health)
	hotBar:SetStatusBarTexture([[Interface\ChatFrame\ChatFrameBackground]])
	otherBeforeBar:Hide()

	frame.BetterHealthPrediction = {
		otherBeforeBar = otherBeforeBar,
		myBar = myBar,
		otherAfterBar = otherAfterBar,
		hotBar = hotBar,
	}
	frame.Health:SetScript("OnSizeChanged", function(self)
		local frame = self:GetParent()
		local orientation = self:GetOrientation()
		local otherBeforeBar, myBar, otherAfterBar, hotBar = frame.BetterHealthPrediction.otherBeforeBar, frame.BetterHealthPrediction.myBar, frame.BetterHealthPrediction.otherAfterBar, frame.BetterHealthPrediction.hotBar,
		otherBeforeBar:ClearAllPoints()
		otherBeforeBar:SetOrientation(orientation)
		myBar:ClearAllPoints()
		myBar:SetOrientation(orientation)
		otherAfterBar:ClearAllPoints()
		otherAfterBar:SetOrientation(orientation)
		hotBar:ClearAllPoints()
		hotBar:SetOrientation(orientation)
		if orientation == "HORIZONTAL" then
			otherBeforeBar:SetPoint("TOP")
			otherBeforeBar:SetPoint("BOTTOM")
			otherBeforeBar:SetPoint("LEFT", self:GetStatusBarTexture(), "RIGHT")
			otherBeforeBar:SetWidth(self:GetWidth())
			
			myBar:SetPoint("TOP")
			myBar:SetPoint("BOTTOM")
			myBar:SetPoint("LEFT", otherBeforeBar:GetStatusBarTexture(), "RIGHT")
			myBar:SetWidth(self:GetWidth())
			
			otherAfterBar:SetPoint("TOP")
			otherAfterBar:SetPoint("BOTTOM")
			otherAfterBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
			otherAfterBar:SetWidth(self:GetWidth())
			
			hotBar:SetPoint("TOP")
			hotBar:SetPoint("BOTTOM")
			hotBar:SetPoint("LEFT", otherAfterBar:GetStatusBarTexture(), "RIGHT")
			hotBar:SetWidth(self:GetWidth())
		else
			otherBeforeBar:SetPoint("LEFT")
			otherBeforeBar:SetPoint("RIGHT")
			otherBeforeBar:SetPoint("BOTTOM", self:GetStatusBarTexture(), "TOP")
			otherBeforeBar:SetHeight(self:GetHeight())
			
			myBar:SetPoint("LEFT")
			myBar:SetPoint("RIGHT")
			myBar:SetPoint("BOTTOM", otherBeforeBar:GetStatusBarTexture(), "TOP")
			myBar:SetHeight(self:GetHeight())
			
			otherAfterBar:SetPoint("LEFT")
			otherAfterBar:SetPoint("RIGHT")
			otherAfterBar:SetPoint("BOTTOM", myBar:GetStatusBarTexture(), "TOP")
			otherAfterBar:SetHeight(self:GetHeight())
			
			hotBar:SetPoint("LEFT")
			hotBar:SetPoint("RIGHT")
			hotBar:SetPoint("BOTTOM", otherAfterBar:GetStatusBarTexture(), "TOP")
			hotBar:SetHeight(self:GetHeight())
		end
	end)

-- Fontstrings
	for bar,fstrings in pairs(frame.tags) do
		local parent = frame.modules[bar] or frame
		fstrings.left = parent:CreateFontString(nil, "OVERLAY")
		fstrings.left:SetDrawLayer("OVERLAY", 7)
		fstrings.left:SetJustifyH("LEFT")
		fstrings.center = parent:CreateFontString(nil, "OVERLAY")
		fstrings.center:SetDrawLayer("OVERLAY", 7)
		fstrings.center:SetJustifyH("CENTER")
		fstrings.right = parent:CreateFontString(nil, "OVERLAY")
		fstrings.right:SetDrawLayer("OVERLAY", 7)
		fstrings.right:SetJustifyH("RIGHT")
	end
	
	frame:SetScript("OnEnter", function(self)
		if( LUF.db.profile.tooltipCombat or not InCombatLockdown() ) then
			if not GameTooltip:IsForbidden() then
				if LUF.db.profile.locked then
					UnitFrame_OnEnter(self)
				else
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:SetText(LUF.L[self:GetAttribute("oUF-guessUnit")], 1, 0.81, 0, 1, true)
					GameTooltip:Show()
				end
			end
		end
	end)
	frame:SetScript("OnLeave", function(self)
		if not GameTooltip:IsForbidden() then
			UnitFrame_OnLeave(self)
		end
	end)
	
	frame:SetClampedToScreen(true)
	frame:RegisterForClicks("AnyUp")
end