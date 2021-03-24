-- Luna Unit Frames 4.0 by Aviana

LUF = select(2, ...)
LUF.version = 4090

local L = LUF.L
local ACR = LibStub("AceConfigRegistry-3.0", true)
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")
local oUF = LUF.oUF

-- Disable oUFs Anti Blizzard function since we make our own
oUF.DisableBlizzard = function() end

LUF.frameIndex = {}

L.player = PLAYER
L.pet = PET
L.target = TARGET
L.party = PARTY
L.raid = RAID
L.maintank = MAINTANK
L.mainassist = MAIN_ASSIST
L.focus = FOCUS

LUF.stateMonitor = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")
LUF.stateMonitor:WrapScript(LUF.stateMonitor, "OnAttributeChanged", [[
	if( name == "partyEnabled" or name == "partytargetEnabled" or name == "partypetEnabled" ) then return end
	
	local partyFrame = self:GetFrameRef("partyFrame")
	local partytargetFrame = self:GetFrameRef("partytargetFrame")
	local partypetFrame = self:GetFrameRef("partypetFrame")
	
	local status = self:GetAttribute("state-raidstatus")
	local setting = self:GetAttribute("hideraid")
	local showParty = setting == "never" or status ~= "full" and setting == "5man" or setting == "always" and status == "none"
	
	if partyFrame and self:GetAttribute("partyEnabled") then
		partyFrame:SetAttribute("raidHidden", not showParty)
		if showParty then
			partyFrame:Show()
		else
			partyFrame:Hide()
		end
	end
	if partytargetFrame and self:GetAttribute("partytargetEnabled") then
		partytargetFrame:SetAttribute("raidHidden", not showParty)
		if showParty then
			partytargetFrame:Show()
		else
			partytargetFrame:Hide()
		end
	end
	if partypetFrame and self:GetAttribute("partypetEnabled") then
		partypetFrame:SetAttribute("raidHidden", not showParty)
		if showParty then
			partypetFrame:Show()
		else
			partypetFrame:Hide()
		end
	end
]])

LUF.unitList = {
	"player",
	"pet",
	"pettarget",
	"pettargettarget",
	"target",
	"targettarget",
	"targettargettarget",
	"focus",
	"focustarget",
	"focustargettarget",
	"party",
	"partytarget",
	"partypet",
	"raid",
	"raidpet",
	"maintank",
	"maintanktarget",
	"maintanktargettarget",
	"mainassist",
	"mainassisttarget",
	"mainassisttargettarget",
}

LUF.fakeUnits = {
	["targettarget"] = true,
	["targettargettarget"] = true,
	["pettarget"] = true,
	["pettargettarget"] = true,
	["focustarget"] = true,
	["focustargettarget"] = true,
	["partytarget"] = true,
	["maintanktarget"] = true,
	["maintanktargettarget"] = true,
	["mainassisttarget"] = true,
	["mainassisttargettarget"] = true
}

LUF.HeaderFrames = {
	["party"] = true,
	["partytarget"] = true,
	["partypet"] = true,
	["raid"] = true,
	["raidpet"] = true,
	["maintank"] = true,
	["maintanktarget"] = true,
	["maintanktargettarget"] = true,
	["mainassist"] = true,
	["mainassisttarget"] = true,
	["mainassisttargettarget"] = true,
}

function LUF:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF2150C2LunaUnitFrames|cFFFFFFFF: ".. msg)
end

function LUF:LoadoUFSettings()
	self.oUF.LUF_fakePlayerClassification = self.db.profile.units.player.indicators.elite.enabled and self.db.profile.units.player.indicators.elite.type or nil
	self.oUF.LUF_fakePetClassification = self.db.profile.units.pet.indicators.elite.enabled and self.db.profile.units.pet.indicators.elite.type or nil
	
	local colors = self.db.profile.colors
	self.oUF.colors.smooth = { colors.red.r, colors.red.g, colors.red.b, colors.yellow.r, colors.yellow.g, colors.yellow.b, colors.green.r, colors.green.g, colors.green.b }
	self.oUF.colors.health = {colors.static.r, colors.static.g, colors.static.b}
	
	self.oUF.colors.disconnected = {colors.offline.r, colors.offline.g, colors.offline.b}
	self.oUF.colors.tapped = {colors.tapped.r, colors.tapped.g, colors.tapped.b}
	self.oUF.colors.civilian = {colors.enemyCivilian.r, colors.enemyCivilian.g, colors.enemyCivilian.b}
	
	self.oUF.colors.class.HUNTER = {colors.HUNTER.r, colors.HUNTER.g, colors.HUNTER.b}
	self.oUF.colors.class.WARLOCK = {colors.WARLOCK.r, colors.WARLOCK.g, colors.WARLOCK.b}
	self.oUF.colors.class.PRIEST = {colors.PRIEST.r, colors.PRIEST.g, colors.PRIEST.b}
	self.oUF.colors.class.PALADIN = {colors.PALADIN.r, colors.PALADIN.g, colors.PALADIN.b}
	self.oUF.colors.class.MAGE = {colors.MAGE.r, colors.MAGE.g, colors.MAGE.b}
	self.oUF.colors.class.ROGUE = {colors.ROGUE.r, colors.ROGUE.g, colors.ROGUE.b}
	self.oUF.colors.class.DRUID = {colors.DRUID.r, colors.DRUID.g, colors.DRUID.b}
	self.oUF.colors.class.SHAMAN = {colors.SHAMAN.r, colors.SHAMAN.g, colors.SHAMAN.b}
	self.oUF.colors.class.WARRIOR = {colors.WARRIOR.r, colors.WARRIOR.g, colors.WARRIOR.b}
	
	self.oUF.colors.power.MANA = {colors.MANA.r, colors.MANA.g, colors.MANA.b}
	self.oUF.colors.power[0] = self.oUF.colors.power.MANA
	self.oUF.colors.power.RAGE = {colors.RAGE.r, colors.RAGE.g, colors.RAGE.b}
	self.oUF.colors.power[1] = self.oUF.colors.power.RAGE
	self.oUF.colors.power.FOCUS = {colors.FOCUS.r, colors.FOCUS.g, colors.FOCUS.b}
	self.oUF.colors.power[2] = self.oUF.colors.power.FOCUS
	self.oUF.colors.power.ENERGY = {colors.ENERGY.r, colors.ENERGY.g, colors.ENERGY.b}
	self.oUF.colors.power[3] = self.oUF.colors.power.ENERGY
	self.oUF.colors.power.COMBO_POINTS = {colors.COMBOPOINTS.r, colors.COMBOPOINTS.g, colors.COMBOPOINTS.b}
	self.oUF.colors.power[4] = self.oUF.colors.power.COMBOPOINTS
	
	self.oUF.colors.happiness[1] = {colors.unhappy.r, colors.unhappy.g, colors.unhappy.b}
	self.oUF.colors.happiness[2] = {colors.content.r, colors.content.g, colors.content.b}
	self.oUF.colors.happiness[3] = {colors.happy.r, colors.happy.g, colors.happy.b}
	
	self.oUF.colors.reaction[1] = {colors.hated.r, colors.hated.g, colors.hated.b}
	self.oUF.colors.reaction[2] = {colors.hostile.r, colors.hated.g, colors.hated.b}
	self.oUF.colors.reaction[3] = {colors.unfriendly.r, colors.unfriendly.g, colors.unfriendly.b}
	self.oUF.colors.reaction[4] = {colors.neutral.r, colors.neutral.g, colors.neutral.b}
	self.oUF.colors.reaction[5] = {colors.friendly.r, colors.friendly.g, colors.friendly.b}
	self.oUF.colors.reaction[6] = {colors.honored.r, colors.honored.g, colors.honored.b}
	self.oUF.colors.reaction[7] = {colors.revered.r, colors.revered.g, colors.revered.b}
	self.oUF.colors.reaction[8] = {colors.exalted.r, colors.exalted.g, colors.exalted.b}
	
	self.oUF.colors.threat[1] = self.oUF.colors.reaction[8]
	self.oUF.colors.threat[2] = self.oUF.colors.reaction[4]
	self.oUF.colors.threat[3] = self.oUF.colors.reaction[2]
	self.oUF.colors.threat[4] = self.oUF.colors.reaction[1]
	
	self.oUF.TagsWithHealTimeFrame = self.db.profile.inchealTime
	self.oUF.TagsWithHealDisableHots = self.db.profile.disablehots
end

function LUF:ResetColors()
	for name, color in pairs(LUF.db.profile.colors) do
		local default = LUF.defaults.profile.colors[name]
		color.r = default.r
		color.g = default.g
		color.b = default.b
		color.a = default.a
	end
	ACR:NotifyChange("LunaUnitFrames")
	self:LoadoUFSettings()
	self:ReloadAll()
end

function LUF:OnLoad()
	
	self:LoadDefaults()
	
	-- Initialize DB
	self.db = LibStub:GetLibrary("AceDB-3.0"):New("LunaUFDB", self.defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfilesChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfilesChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileReset")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileDeleted")

	self.db.profile.version = self.version
	
	SML.RegisterCallback(self, "LibSharedMedia_Registered", "MediaRegistered")
	SML.RegisterCallback(self, "LibSharedMedia_SetGlobal", "MediaForced")

	self:LoadoUFSettings()
	self:SpawnUnits()
	self:HideBlizzardFrames()
	self:CreateConfig()
	self:UpdateMovers()
	self:PlaceAllFrames()
	self:AutoswitchProfileSetup()
	if self.db.global.switchtype == "RESOLUTION" then
		self:AutoswitchProfile("DISPLAY_SIZE_CHANGED")
	elseif self.db.global.switchtype == "GROUP" then
		self:AutoswitchProfile("GROUP_ROSTER_UPDATE")
	end
end

local mediaNeeded = {}
function LUF:LoadMedia(type, name)
	local mediaName = name or self.db.profile[type]
	local media = SML:Fetch(type, mediaName or SML.DefaultMedia[type], true)
	if( not media ) then
		mediaNeeded[type] = mediaName
		return SML:Fetch(type, SML.DefaultMedia[type], true)
	end
	return media
end

function LUF:MediaRegistered(event, mediaType, key)
	if( mediaNeeded[mediaType] == key ) then
		mediaNeeded[mediaType] = nil
		
		self:ReloadAll()
	end
end

function LUF:MediaForced(mediaType)
	self:ReloadAll()
end

function LUF:ProfilesChanged()
	if( resetTimer ) then resetTimer:Hide() end
	
	self.db:RegisterDefaults(self.defaults)
	
	-- No active layout, register the default one
	if( not self.db.profile.loadedLayout ) then
		self:LoadDefaults()
	end
	
	self:LoadoUFSettings()
	self:HideBlizzardFrames()
	self:ReloadAll()
	self:SetupAllHeaders()
	self:UpdateMovers()
	self:PlaceAllFrames()
end

local resetTimer
function LUF:ProfileReset()
	self:Print("The Profile was reset!")
	if( not resetTimer ) then
		resetTimer = CreateFrame("Frame")
		resetTimer:SetScript("OnUpdate", function(self)
			LUF:ProfilesChanged()
			self:Hide()
		end)
	end
	
	resetTimer:Show()
end

function LUF:OnProfileDeleted(event, key, name)
	-- Remove deleted profiles from autoswitching
	if self.db.global.resdb then
		for k,v in pairs(self.db.global.resdb) do
			if v == name then
				self.db.global.resdb[k] = nil
			end
		end
	end
	if self.db.global.grpdb then
		for k,v in pairs(self.db.global.grpdb) do
			if v == name then
				self.db.global.grpdb[k] = nil
			end
		end
	end
end

function LUF:AutoswitchProfile(event)
	local profile
	if event == "DISPLAY_SIZE_CHANGED" then
		local resolutions = {GetScreenResolutions()}
		profile = self.db.char.resdb[resolutions[GetCurrentResolution()]]
	else
		local groupType
		if IsInRaid() then
			local maxGrp = 1
			for i=1,MAX_RAID_MEMBERS do
				maxGrp = math.max((select(3,GetRaidRosterInfo(i)) or 0),maxGrp)
			end
			if maxGrp == 1 then
				groupType = "RAID5"
			elseif maxGrp == 2 then
				groupType = "RAID10"
			elseif maxGrp == 3 then
				groupType = "RAID15"
			elseif maxGrp == 4 then
				groupType = "RAID20"
			else
				groupType = "RAID40"
			end
		elseif IsInGroup() then
			groupType = "PARTY"
		else
			groupType = "SOLO"
		end
		profile = self.db.char.grpdb[groupType]
	end
	if profile and profile ~= self.db:GetCurrentProfile() then
		self.db:SetProfile(profile)
	end
end

local hiddenParent = CreateFrame("Frame", nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local function handleFrame(baseName)
	local frame
	if(type(baseName) == "string") then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		frame:SetParent(hiddenParent)

		local health = frame.healthBar or frame.healthbar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.castBar or frame.spellbar
		if(spell) then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end

		local buffFrame = frame.BuffFrame
		if(buffFrame) then
			buffFrame:UnregisterAllEvents()
		end
	end
end

local active_hiddens = {
}
function LUF:HideBlizzardFrames()
	if( self.db.profile.hidden.cast ) then
		handleFrame(CastingBarFrame)
		active_hiddens.cast = true
	elseif( not self.db.profile.hidden.cast and not active_hiddens.cast ) then
		CastingBarFrame_OnLoad(CastingBarFrame, "player", true, false) --restore castbar as oUF kills it
	end

	if( CompactRaidFrameManager ) then
		if( self.db.profile.hidden.raid and not active_hiddens.raid ) then
			active_hiddens.raid = true
			local function hideRaid()
				CompactRaidFrameManager:UnregisterAllEvents()
				CompactRaidFrameContainer:UnregisterAllEvents()
				if( InCombatLockdown() ) then return end
	
				CompactRaidFrameManager:Hide()
				local shown = CompactRaidFrameManager_GetSetting("IsShown")
				if( shown and shown ~= "0" ) then
					CompactRaidFrameManager_SetSetting("IsShown", "0")
				end
			end
			
			hooksecurefunc("CompactRaidFrameManager_UpdateShown", function()
				if( self.db.profile.hidden.raid ) then
					hideRaid()
				end
			end)
			
			hideRaid()
			CompactRaidFrameContainer:HookScript("OnShow", hideRaid)
			CompactRaidFrameManager:HookScript("OnShow", hideRaid)
		end
	end

	if( self.db.profile.hidden.buffs and not active_hiddens.buffs ) then
		BuffFrame:UnregisterAllEvents()
		BuffFrame:Hide()
		TemporaryEnchantFrame:UnregisterAllEvents()
		TemporaryEnchantFrame:Hide()
		TemporaryEnchantFrame_Hide()
	end

	if( self.db.profile.hidden.player and not active_hiddens.player ) then
		handleFrame(PlayerFrame)
	end

	if( self.db.profile.hidden.pet and not active_hiddens.pet ) then
		handleFrame(PetFrame)
	end

	if( self.db.profile.hidden.focus and not active_hiddens.focus ) then
		handleFrame(FocusFrame)
	end

	if( self.db.profile.hidden.target and not active_hiddens.target ) then
		handleFrame(TargetFrame)
		handleFrame(ComboFrame)
		handleFrame(TargetFrameToT)
	end

	if( self.db.profile.hidden.party and not active_hiddens.party ) then
		for i = 1, MAX_PARTY_MEMBERS do
			handleFrame(string.format("PartyMemberFrame%d", i))
		end
	end

	-- As a reload is required to reset the hidden hooks, we can just set this to true if anything is true
	for type, flag in pairs(self.db.profile.hidden) do
		if( flag ) then
			active_hiddens[type] = true
		end
	end
end

local moduleSettings = {
	healthBar = function(mod, config)
		mod.texture = LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar)
		mod:SetStatusBarTexture(LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar))
		if config.background or config.invert then
			mod.bg:SetTexture(mod.texture)
			mod.bg:Show()
			mod.bg:SetAlpha(config.invert and 1 or config.backgroundAlpha)
		else
			mod.bg:Hide()
		end
		mod.colorHappiness = config.colorType == "happiness"
		mod.colorClass = config.colorType == "class"
		mod.colorReaction = config.reactionType ~= "none" and config.reactionType
		mod.colorSmooth = config.colorType == "percent"
		mod.colorInvert = config.invert
		mod:SetOrientation(config.vertical and "VERTICAL" or "HORIZONTAL")
		if mod.__owner.unit == "pet" then
			if config.enabled then
				mod.__owner:RegisterEvent("UNIT_HAPPINESS", LUF.overrides["Health"].UpdateColor) -- Fix for bug in oUF not updating 
			else
				mod.__owner:UnregisterEvent("UNIT_HAPPINESS", LUF.overrides["Health"].UpdateColor)
			end
		end
	end,
	powerBar = function(mod, config)
		mod.texture = LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar)
		mod:SetStatusBarTexture(LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar))
		if config.background then
			mod.bg:SetTexture(mod.texture)
			mod.bg:Show()
			mod.bg:SetAlpha(config.backgroundAlpha)
		else
			mod.bg:Hide()
		end
		mod.colorClass = config.colorType == "class"
		mod.colorClassNPC = config.colorType == "class"
		mod.colorPower = config.colorType == "type"
		mod:SetOrientation(config.vertical and "VERTICAL" or "HORIZONTAL")
	end,
	castBar = function(mod, config)
		mod.texture = LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar)
		mod:SetStatusBarTexture(LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar))
		if config.background then
			mod.bg:SetTexture(mod.texture)
			mod.bg:SetVertexColor(1, 1, 1)
			mod.bg:Show()
			mod.bg:SetAlpha(config.backgroundAlpha)
		else
			mod.bg:Hide()
		end
		if config.icon == "HIDE" then
			mod.Icon:Hide()
		else
			mod.Icon:Show()
			mod.Icon:ClearAllPoints()
			if config.icon == "LEFT" then
				mod.Icon:SetPoint("RIGHT", mod, "LEFT")
			else
				mod.Icon:SetPoint("LEFT", mod, "RIGHT")
			end
		end
	end,
	emptyBar = function(mod, config)
		mod.texture = LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar)
		mod:SetStatusBarTexture(LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar))
		mod.alpha = config.alpha
		mod.colorReaction = config.reactionType ~= "none" and config.reactionType
		mod.colorClass = config.class
		mod:SetOrientation(config.vertical and "VERTICAL" or "HORIZONTAL")
	end,
	comboPoints = function(mod, config)
		local texture = LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar)
		for i=1, 5 do
			local point = mod.ComboPoints[i]
			point:SetStatusBarTexture(texture)
			point.bg:SetTexture(texture)
			point.bg:SetAlpha(config.backgroundAlpha)
			if config.background then
				point.bg:Show()
			else
				point.bg:Hide()
			end
		end
		mod.autoHide = config.autoHide
		mod.growth = config.growth
		mod:Update()
	end,
	totemBar = function(mod, config)
		local texture = LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar)
		local totemColors = {
			[1] = {1,0,0},
			[2] = {0.78,0.61,0.43},
			[3] = {0,0,1},
			[4] = {0.41,0.8,0.94},
		}
		for i=1, 4 do
			local totem = mod.Totems[i]
			totem:SetStatusBarTexture(texture)
			totem:SetStatusBarColor(unpack(totemColors[i]))
			totem.bg:SetTexture(texture)
			totem.bg:SetVertexColor(unpack(totemColors[i]))
			totem.bg:SetAlpha(config.backgroundAlpha)
			if config.background then
				totem.bg:Show()
			else
				totem.bg:Hide()
			end
		end
		mod.autoHide = config.autoHide
		mod:Update()
	end,
	druidBar = function(mod, config)
		mod.texture = LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar)
		mod:SetStatusBarTexture(LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar))
		if config.background then
			mod.bg:SetTexture(mod.texture)
			mod.bg:Show()
			mod.bg:SetAlpha(config.backgroundAlpha)
		else
			mod.bg:Hide()
		end
		mod:SetOrientation(config.vertical and "VERTICAL" or "HORIZONTAL")
	end,
	reckStacks = function(mod, config)
		local texture = LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar)
		local color = LUF.db.profile.colors.COMBOPOINTS
		for i=1, 4 do
			local point = mod.Reckoning[i]
			point:SetStatusBarTexture(texture)
			point:SetStatusBarColor(color.r, color.g, color.b)
			point.bg:SetTexture(texture)
			point.bg:SetVertexColor(color.r, color.g, color.b)
			point.bg:SetAlpha(config.backgroundAlpha)
			if config.background then
				point.bg:Show()
			else
				point.bg:Hide()
			end
		end
		mod.autoHide = config.autoHide
		mod.growth = config.growth
		mod:Update()
	end,
	xpBar = function(mod, config)
		if not config.enabled then mod:Hide() return end
		local texture = LUF:LoadMedia(SML.MediaType.STATUSBAR, config.statusbar)
		mod:GetParent()[mod.name].tooltip = config.mouse
		mod.xpBar:SetStatusBarTexture(texture)
		mod.xpBar.rested:SetStatusBarTexture(texture)
		mod.xpBar:SetAlpha(config.alpha)
		local normal = LUF.db.profile.colors.normal
		mod.xpBar:SetStatusBarColor(normal.r, normal.g, normal.b)
		local rested = LUF.db.profile.colors.rested
		mod.xpBar.rested:SetStatusBarColor(rested.r, rested.g, rested.b)
		if mod.repBar then
			mod.repBar:SetStatusBarTexture(texture)
			mod.repBar:SetAlpha(config.alpha)
		end
		if config.background then
			mod.xpBar.bg:SetTexture(texture)
			mod.xpBar.bg:Show()
			mod.xpBar.bg:SetAlpha(config.backgroundAlpha)
			if mod.repBar then
				mod.repBar.bg:SetTexture(texture)
				mod.repBar.bg:Show()
				mod.repBar.bg:SetAlpha(config.backgroundAlpha)
			end
		else
			mod.xpBar.bg:Hide()
			if mod.repBar then
				mod.repBar.bg:Hide()
			end
		end
	end,
}

local fstringoffsets = { left = 3, center = 0, right = -3 }
function LUF.ApplySettings(frame)
	local config = LUF.db.profile.units[frame:GetAttribute("oUF-guessUnit")]
	
	-- Background
	local bgColor = LUF.db.profile.colors.background
	frame.bg:SetVertexColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
	
	-- Bars
	for barname,barobj in pairs(frame.modules) do
		if moduleSettings[barname] then
			moduleSettings[barname](barobj, config[barname])
		end
	end
	
	-- Portrait
	if frame.StatusPortrait then
		frame.StatusPortrait.showStatus = config.portrait.showStatus
		frame.StatusPortrait.verbosePortraitIcon = config.portrait.verboseStatus
		frame.StatusPortrait.type = config.portrait.type
	end
	
	-- Regen Ticker
	if frame.RegenTicker then
		if (config.powerBar.ticker or config.powerBar.fivesecond) and select(2, UnitClass("player")) ~= "WARRIOR" then
			frame:EnableElement("RegenTicker")
			frame.RegenTicker.hideTicks = not config.powerBar.ticker
			frame.RegenTicker.hideFive = not config.powerBar.fivesecond
			frame.RegenTicker.autoHide = config.powerBar.hideticker
			frame.RegenTicker.vertical = config.powerBar.vertical
		else
			frame:DisableElement("RegenTicker")
		end
	end
	
	-- Additional Regen Ticker
	if frame.AdditionalRegenTicker then
		if (config.druidBar.ticker or config.druidBar.fivesecond) then
			frame:EnableElement("RegenTickerAlt")
			frame.AdditionalRegenTicker.hideTicks = not config.druidBar.ticker
			frame.AdditionalRegenTicker.hideFive = not config.druidBar.fivesecond
			frame.AdditionalRegenTicker.autoHide = config.druidBar.hideticker
			frame.AdditionalRegenTicker.vertical = config.druidBar.vertical
		else
			frame:DisableElement("RegenTickerAlt")
		end
	end
	
	-- Power Prediction
	if frame.PowerPrediction then
		if config.manaPrediction.enabled then
			frame:EnableElement("PowerPrediction")
			local predColor = config.manaPrediction.color
			frame.PowerPrediction.mainBar:SetStatusBarColor(predColor.r, predColor.g, predColor.b)
			frame.PowerPrediction.mainBar:SetAlpha(predColor.a)
		else
			frame:DisableElement("PowerPrediction")
		end
	end
	
	-- Tags
	for barname,fstrings in pairs(frame.tags) do
		for side,fstring in pairs(fstrings) do
			fstring:ClearAllPoints()
			local barconfig = config.tags[barname]
			if frame.modules[barname] then
				fstring:SetPoint(strupper(side), frame.modules[barname], strupper(side), fstringoffsets[side], barconfig[side].offset or 0)
			elseif barname == "top" then
				if side ~= "center" then
					fstring:SetPoint("BOTTOM"..strupper(side), frame, "TOP"..strupper(side), fstringoffsets[side], barconfig[side].offset or 0)
				else
					fstring:SetPoint("BOTTOM", frame, "TOP", fstringoffsets[side], barconfig[side].offset or 0)
				end
			else
				if side ~= "center" then
					fstring:SetPoint("TOP"..strupper(side), frame, "BOTTOM"..strupper(side), fstringoffsets[side], barconfig[side].offset or 0)
				else
					fstring:SetPoint("TOP", frame, "BOTTOM", fstringoffsets[side], barconfig[side].offset or 0)
				end
			end
			fstring:SetFont(LUF:LoadMedia(SML.MediaType.FONT, barconfig.font), barconfig.size, (barconfig.outline or LUF.db.profile.fontoutline) and "OUTLINE")
			if barconfig.shadow or LUF.db.profile.fontshadow then
				fstring:SetShadowColor(0, 0, 0, 1.0)
				fstring:SetShadowOffset(0.80, -0.80)
			else
				fstring:SetShadowColor(0, 0, 0, 0)
			end
			frame:Tag(fstring, barconfig[side].tagline)
		end
	end
	
	-- Indicators
	for iname,iobj in pairs(frame.indicators) do
		local objconfig = config.indicators[iname]
		local objdata = LUF.IndicatorData[iname]
		if objconfig.enabled then
			frame:EnableElement(objdata.name)
			if iname ~= "elite" then
				iobj:ClearAllPoints()
				iobj:SetPoint("CENTER", frame, objconfig.anchorPoint, objconfig.x, objconfig.y )
				iobj:SetSize(objconfig.size, objconfig.size)
			else
				iobj.side = objconfig.side
			end
		else
			frame:DisableElement(objdata.name)
		end
	end
	
	-- Range
	if frame.Range then
		if config.range.enabled then
			frame.Range.range = LUF.db.profile.range.dist
			frame.Range.outsideAlpha = LUF.db.profile.range.alpha
			frame:EnableElement("Range")
		else
			frame:DisableElement("Range")
		end
	end
	
	-- Combat Fader
	if frame.SimpleFader then
		if config.fader.enabled then
			frame.SimpleFader.combatAlpha = config.fader.combatAlpha
			frame.SimpleFader.inactiveAlpha = config.fader.inactiveAlpha
			frame.SimpleFader.fastFade = config.fader.speedyFade
			frame:EnableElement("SimpleFader")
		else
			frame:DisableElement("SimpleFader")
		end
	end
	
	-- Auras
	if config.auras.buffs or config.auras.weaponbuffs or config.auras.debuffs then
		frame:EnableElement("SimpleAuras")
		local Auras = frame.SimpleAuras
		local AuraConfig = config.auras
		Auras.weapons = AuraConfig.weaponbuffs
		
		Auras.buffs = AuraConfig.buffs
		Auras.buffAnchor = AuraConfig.buffpos
		Auras.buffFilter = AuraConfig.filterbuffs
		Auras.buffSize = AuraConfig.buffsize
		Auras.largeBuffSize = AuraConfig.enlargedbuffsize
		Auras.wrapBuffSide = AuraConfig.wrapbuffside
		Auras.wrapBuff = AuraConfig.wrapbuff
		
		Auras.debuffs = AuraConfig.debuffs
		Auras.debuffAnchor = AuraConfig.debuffpos
		Auras.debuffFilter = AuraConfig.filterdebuffs
		Auras.debuffSize = AuraConfig.debuffsize
		Auras.largeDebuffSize = AuraConfig.enlargeddebuffsize
		Auras.wrapDebuffSide = AuraConfig.wrapdebuffside
		Auras.wrapDebuff = AuraConfig.wrapdebuff
		
		Auras.timer = AuraConfig.timer
		Auras.spacing = AuraConfig.padding
		Auras.forceShow = LUF.db.profile.previewauras and not LUF.db.profile.locked
		Auras.showType = AuraConfig.bordercolor
		Auras.disableOCC = LUF.db.profile.omnicc
		Auras.disableBCC = LUF.db.profile.blizzardcc
		
		local auraborderType = LUF.db.profile.auraborderType
		Auras.overlay = auraborderType and auraborderType ~= "blizzard" and "Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\border-" .. auraborderType
	else
		frame:DisableElement("SimpleAuras")
	end
	
	-- Combat Text
	if frame.CombatText then
		frame.CombatText.feedbackFontHeight = config.combatText.size
		frame.CombatText.font = LUF:LoadMedia(SML.MediaType.FONT, config.combatText.font)
		if config.combatText.enabled then
			frame:EnableElement("CombatText")
			frame.CombatText:ClearAllPoints()
			if config.portrait.enabled and config.portrait.alignment ~= "CENTER" then
				frame.CombatText:SetAllPoints(frame.StatusPortrait.model)
			else
				frame.CombatText:SetAllPoints(frame)
			end
		else
			frame:DisableElement("CombatText")
		end
	end
	
	-- Highlight
	if frame.Highlight then
		local target, mouseover, aggro, debuff = config.highlight.target, config.highlight.mouseover, config.highlight.aggro, config.highlight.debuff
		if target or mouseover or aggro or debuff ~=1 then
			frame:EnableElement("Highlight")
			frame.Highlight.target = target
			frame.Highlight.mouseover = mouseover
			frame.Highlight.aggro = aggro
			frame.Highlight.debuff = debuff
			frame.Highlight.mouseoverColor = {LUF.db.profile.colors.mouseover.r, LUF.db.profile.colors.mouseover.g, LUF.db.profile.colors.mouseover.b}
			frame.Highlight.targetColor = {LUF.db.profile.colors.target.r, LUF.db.profile.colors.target.g, LUF.db.profile.colors.target.b}
		else
			frame:DisableElement("Highlight")
		end
	end
	
	-- Border Highlight
	if frame.BorderHighlight then
		local target, mouseover, aggro, debuff = config.borders.target, config.borders.mouseover, config.borders.aggro, config.borders.debuff
		if target or mouseover or aggro or debuff ~=1 then
			frame:EnableElement("BorderHighlight")
			frame.BorderHighlight.target = target
			frame.BorderHighlight.mouseover = mouseover
			frame.BorderHighlight.aggro = aggro
			frame.BorderHighlight.debuff = debuff
			frame.BorderHighlight.mouseoverColor = {LUF.db.profile.colors.mouseover.r, LUF.db.profile.colors.mouseover.g, LUF.db.profile.colors.mouseover.b}
			frame.BorderHighlight.targetColor = {LUF.db.profile.colors.target.r, LUF.db.profile.colors.target.g, LUF.db.profile.colors.target.b}
			frame.BorderHighlight.size = config.borders.size
		else
			frame:DisableElement("BorderHighlight")
		end
	end
	
	--Squares
	if frame.RaidStatusIndicators then
		local isEnabled
		for name in pairs(LUF.defaults.profile.units.player.squares) do
			local indicator = frame.RaidStatusIndicators[name]
			local squarecfg = config.squares
			if squarecfg[name].enabled then
				isEnabled = true
				indicator.type = squarecfg[name].type
				indicator.showTexture = squarecfg[name].texture
				indicator.timer = squarecfg[name].timer
				if indicator.type == "missing" then
					indicator.nameID = {}
					for i,v in ipairs({strsplit(";", squarecfg[name].value or "")}) do
						table.insert(indicator.nameID, {strsplit("/",v)})
					end
				else
					indicator.nameID = {strsplit(";", squarecfg[name].value or "")}
				end
			else
				indicator.type = nil
				indicator:Hide()
			end
			indicator:SetSize(squarecfg[name].size, squarecfg[name].size)
		end
		if isEnabled then
			frame:EnableElement("RaidStatusIndicators")
		else
			frame:DisableElement("RaidStatusIndicators")
		end
	end
	
	--Healing Prediction
	if frame.BetterHealthPrediction then
		local healConfig = config.incHeal
		if healConfig.enabled then
			frame.BetterHealthPrediction.timeFrame = LUF.db.profile.inchealTime
			frame.BetterHealthPrediction.maxOverflow = healConfig.cap
			frame.BetterHealthPrediction.disableHots = LUF.db.profile.disablehots
			local color = LUF.db.profile.colors.incheal
			frame.BetterHealthPrediction.otherBeforeBar:SetStatusBarColor(color.r, color.g, color.b, healConfig.alpha)
			frame.BetterHealthPrediction.otherAfterBar:SetStatusBarColor(color.r, color.g, color.b, healConfig.alpha)
			color = LUF.db.profile.colors.incownheal
			frame.BetterHealthPrediction.myBar:SetStatusBarColor(color.r, color.g, color.b, healConfig.alpha)
			color = LUF.db.profile.colors.inchots
			frame.BetterHealthPrediction.hotBar:SetStatusBarColor(color.r, color.g, color.b, healConfig.alpha)
			frame:EnableElement("BetterHealthPrediction")
		else
			frame:DisableElement("BetterHealthPrediction")
		end
	end
	
	frame:UpdateAllElements("RefreshUnit")
end

local sortUp = function(a, b) return a.order < b.order end
local sortDown = function(a, b) return a.order > b.order end
local horiz,vert = {},{}
function LUF.PlaceModules(frame)
	local frame = frame:IsObjectType("Statusbar") and frame:GetParent() or frame
	local config = LUF.db.profile.units[frame:GetAttribute("oUF-guessUnit")]
	if not config then return end
	
	wipe(horiz)
	wipe(vert)
	local attFrame, point = frame, "TOPLEFT"
	local xOffset, yOffset = 1, -1
	local usableX, usableY = frame:GetWidth() - 2
	local vertValue, horizValue = 0, 0
	
	frame.tags.top.left:SetWidth(usableX*config.tags.top.left.size/100)
	frame.tags.top.center:SetWidth(usableX*config.tags.top.center.size/100)
	frame.tags.top.right:SetWidth(usableX*config.tags.top.right.size/100)
	frame.tags.bottom.left:SetWidth(usableX*config.tags.bottom.left.size/100)
	frame.tags.bottom.center:SetWidth(usableX*config.tags.bottom.center.size/100)
	frame.tags.bottom.right:SetWidth(usableX*config.tags.bottom.right.size/100)
	
	for k,v in pairs(frame.modules) do
		v:ClearAllPoints()
		if config[k].enabled then
			frame:EnableElement(v.name)
			if k == "totemBar" then -- Bandaid for oUF totems being broken
				for _,totem in ipairs(frame.Totems) do
					totem:Show()
				end
			end
			if k == "portrait" and config.portrait.alignment ~= "CENTER" then
				v:SetPoint(config.portrait.alignment, frame, config.portrait.alignment, config.portrait.alignment == "LEFT" and 1 or -1, 0)
				v:SetHeight(frame:GetHeight() - 2)
				usableX = (frame:GetWidth() - 2) * config.portrait.width
				v:SetWidth(usableX)
				usableX = frame:GetWidth() - usableX - 2
			elseif (not config[k].autoHide or v:IsShown()) and not v.isDisabled then
				if config[k].vertical then
					table.insert(vert,{key = k, order = config[k].order, size = config[k].height})
					vertValue = vertValue + config[k].height
				else
					table.insert(horiz, {key = k, order = config[k].order, size = config[k].height})
					horizValue = horizValue + config[k].height
				end
			end
		else
			frame:DisableElement(v.name)
		end
	end
	table.sort(vert,sortDown)
	table.sort(horiz,sortUp)
	usableY = frame:GetHeight() - #horiz - 1
	if vertValue > 0 and horizValue > 0 then
		usableX = usableX - 1
	end
	
	-- Horizontal bars
	if config.portrait.enabled and config.portrait.alignment == "LEFT" then
		xOffset = xOffset + frame.modules.portrait:GetWidth()
	end
	local attrPoint = point
	local sqrX
	for i,data in pairs(horiz) do
		if sqrX then
			frame.modules[data.key]:SetPoint(point, attFrame, attrPoint, xOffset-sqrX, yOffset)
			sqrX = nil
		elseif frame.modules[data.key] ~= attFrame then
			frame.modules[data.key]:SetPoint(point, attFrame, attrPoint, xOffset, yOffset)
		end
		local width = usableX * (horizValue/(horizValue+vertValue))
		local height = usableY*(data.size/horizValue)
		frame.modules[data.key]:SetWidth(width)
		frame.modules[data.key]:SetHeight(height)
		if frame.tags[data.key] then
			local tagconfig = config.tags[data.key]
			frame.tags[data.key].left:SetWidth(width*tagconfig.left.size/100)
			frame.tags[data.key].left:SetHeight(height)
			frame.tags[data.key].center:SetWidth(width*tagconfig.center.size/100)
			frame.tags[data.key].center:SetHeight(height)
			frame.tags[data.key].right:SetWidth(width*tagconfig.right.size/100)
			frame.tags[data.key].right:SetHeight(height)
		end
		if frame.modules[data.key].Update then
			frame.modules[data.key]:Update()
		end
		if data.key == "castBar" and config.castBar.icon ~= "HIDE" then
			sqrX = frame.modules.castBar:GetHeight()
			frame.modules.castBar.Icon:SetSize(sqrX, sqrX)
			frame.modules.castBar:SetWidth(frame.modules.castBar:GetWidth() - sqrX)
			if config.castBar.icon == "LEFT" then
				frame.modules.castBar:ClearAllPoints()
				frame.modules.castBar:SetPoint(point, attFrame, attrPoint, xOffset + sqrX, yOffset)
			else
				sqrX = nil
			end
		end
		xOffset = 0
		attrPoint = "BOTTOMLEFT"
		attFrame = frame.modules[data.key]
	end
	
	-- Vertical bars
	attFrame = frame
	point = "TOPRIGHT"
	xOffset = -1
	usableX = usableX - #vert + 1
	if config.portrait.enabled and config.portrait.alignment == "RIGHT" then
		xOffset = xOffset - frame.modules.portrait:GetWidth()
	end
	yOffset = -1
	attrPoint = point
	for i,data in pairs(vert) do
		frame.modules[data.key]:SetPoint(point, attFrame, attrPoint, xOffset, yOffset)
		local width = usableX*(vertValue/(horizValue+vertValue))*(data.size/vertValue)
		local height = frame:GetHeight()-2
		frame.modules[data.key]:SetWidth(width)
		frame.modules[data.key]:SetHeight(height)
		if frame.tags[data.key] then
			local tagconfig = config.tags[data.key]
			frame.tags[data.key].left:SetWidth(width*tagconfig.left.size/100)
			frame.tags[data.key].left:SetHeight(height)
			frame.tags[data.key].center:SetWidth(width*tagconfig.center.size/100)
			frame.tags[data.key].center:SetHeight(height)
			frame.tags[data.key].right:SetWidth(width*tagconfig.right.size/100)
			frame.tags[data.key].right:SetHeight(height)
		end
		if frame.modules[data.key].Update then
			frame.modules[data.key]:Update()
		end
		xOffset = -1
		yOffset = 0
		attrPoint = "TOPLEFT"
		attFrame = frame.modules[data.key]
	end
end

function LUF:PlaceFrame(frame)
	local scale = 1
	local unit = frame:GetAttribute("headerType") or frame:GetAttribute("oUF-guessUnit")
	local config = self.db.profile.units[unit]
	if config.positions then
		config = config.positions[tonumber(strsub(frame:GetName(),14))]
	end
	
	if config.anchorTo == "UIParent" then
		scale = frame:GetScale() * UIParent:GetScale()
	end
	
	frame:ClearAllPoints()
	frame:SetPoint(config.point, _G[config.anchorTo], config.relativePoint, (config.x / scale), (config.y / scale))
end

function LUF:PlaceAllFrames()
	for unit,frame in pairs(self.frameIndex) do
		self:PlaceFrame(frame)
	end
end

local initialConfigFunction = [[
	local parent = self:GetParent()
	local unit = "%s"
	if strmatch(unit,"targettarget") then
		self:SetAttribute("unitsuffix", "targettarget")
	elseif strmatch(unit,"target") then
		self:SetAttribute("unitsuffix", "target")
	elseif strmatch(unit,"partypet") then
		self:SetAttribute("refreshUnitChange", parent:GetAttribute("refreshUnitChange"))
	end
	self:SetAttribute("oUF-guessUnit",unit)
	
	self:SetHeight(parent:GetAttribute("x-height") or 1)
	self:SetWidth(parent:GetAttribute("x-width") or 1)
	self:SetScale(parent:GetAttribute("x-scale") or 1)
]]

local refreshUnitChange = [[
	local unit = self:GetAttribute("unit")
	if unit and not strmatch(unit, "pet") then
		if unit == "player" then
			unit = "pet"
		else
			unit = "partypet"..(strmatch(unit,"%d") or "")
		end
		self:SetAttribute("unit", unit)
	end
]]

function LUF:SpawnUnits()
	oUF:RegisterStyle("LunaUnitFrames", self.InitializeUnit)
	oUF:RegisterInitCallback(function(frame) LUF.PlaceModules(frame) LUF.ApplySettings(frame) end)
	for unit, config in pairs(self.db.profile.units) do
		if self.HeaderFrames[unit] then
			if unit == "raid" then
				for id=1,9 do
					local data = config.positions[id]
					self.frameIndex["raid"..id] = oUF:SpawnHeader("LUFHeaderraid"..id, nil, nil, "oUF-initialConfigFunction", format(initialConfigFunction, "raid"))
					self.frameIndex["raid"..id]:Show() --Set Show() early to allow child spawning
					self.frameIndex["raid"..id]:SetAttribute("headerType", unit)
				end
			else
				local template
				if unit == "raidpet" then
					template = "SecureGroupPetHeaderTemplate"
				end
				self.frameIndex[unit] = oUF:SpawnHeader("LUFHeader"..unit, template, nil, "oUF-initialConfigFunction", format(initialConfigFunction, unit))
				if unit == "partypet" then
					self.frameIndex[unit]:SetAttribute("refreshUnitChange", refreshUnitChange)
				end
				self.frameIndex[unit]:Show() --Set Show() early to allow child spawning
				self.frameIndex[unit]:SetAttribute("headerType", unit)
			end
		else
			self.frameIndex[unit] = oUF:Spawn(unit, "LUFUnit"..unit)
			if unit == "player" then
				self.frameIndex[unit].isChild = true --Hack to prevent oUF from hiding the castbar
			end
		end
	end
	self.stateMonitor:SetFrameRef("partyFrame", self.frameIndex["party"])
	self.stateMonitor:SetFrameRef("partytargetFrame", self.frameIndex["partytarget"])
	self.stateMonitor:SetFrameRef("partypetFrame", self.frameIndex["partypet"])
	self.stateMonitor:SetAttribute("partyEnabled", self.db.profile.units.party.enabled)
	self.stateMonitor:SetAttribute("partytargetEnabled", self.db.profile.units.partytarget.enabled)
	self.stateMonitor:SetAttribute("partypetEnabled", self.db.profile.units.partypet.enabled)
	self.stateMonitor:SetAttribute("hideraid", self.db.profile.units.party.hideraid)
	RegisterStateDriver(self.stateMonitor, "raidstatus", "[target=raid6, exists] full; [target=raid1, exists] semi; none")
	for i=1, 10 do
		local frame
		if i == 10 then
			frame = self.frameIndex["raidpet"]
		else
			frame = self.frameIndex["raid"..i]
		end
		local child = frame:GetChildren()
		frame.grpNumber = child:CreateFontString(nil, "ARTWORK")
		frame.grpNumber:SetShadowColor(0, 0, 0, 1.0)
		frame.grpNumber:SetShadowOffset(0.80, -0.80)
		frame.grpNumber:SetJustifyH("CENTER")
		frame.grpNumber:SetFont("Fonts\\FRIZQT__.TTF", 11) --A default value to prevent "font not set" errors
		frame.grpNumber:SetText(PET)
	end
	self:SetupAllHeaders()
	self.frameIndex.target.PostUpdate = LUF.overrides.Target.PostUpdate
	self.frameIndex.target:HookScript("OnHide", LUF.overrides.Target.PostUpdate)
end

local function SetHeaderAttributes(header, config)
	if not config.enabled or config.filters and not config.filters[tonumber(strmatch(header:GetName(),".+(%d)"))] then
		header:Hide()
		return
	end
	local xMod = config.attribPoint == "LEFT" and 1 or config.attribPoint == "RIGHT" and -1 or 0
	local yMod = config.attribPoint == "TOP" and -1 or config.attribPoint == "BOTTOM" and 1 or 0
	header:SetAttribute("_ignore", "attributeChanges")
	header:SetAttribute("showParty", config.showParty)
	header:SetAttribute("showRaid", config.showRaid)
	header:SetAttribute("showSolo", config.showSolo)
	header:SetAttribute("showPlayer", config.showPlayer)
	header:SetAttribute("columnSpacing", config.columnSpacing)
	header:SetAttribute("groupsPerRow", config.groupsPerRow)
	if config.groupBy == "CLASS" then
		header:SetAttribute("unitsPerColumn", 40)
	else
		header:SetAttribute("unitsPerColumn", config.unitsPerColumn or 5)
	end
	header:SetAttribute("maxColumns", config.maxColumns)
	header:SetAttribute("groupSpacing", 0)
	header:SetAttribute("point", config.attribPoint)
	header:SetAttribute("columnAnchorPoint", config.attribAnchorPoint)
	header:SetAttribute("xOffset", config.offset * xMod)
	header:SetAttribute("yOffset", config.offset * yMod)
	header:SetAttribute("xMod", xMod)
	header:SetAttribute("yMod", yMod)
	header:SetAttribute("sortMethod", config.sortMethod)
	header:SetAttribute("sortDir", config.sortOrder)
	header:SetAttribute("roleFilter", config.roleFilter)
	header:SetAttribute("x-height", config.height)
	header:SetAttribute("x-width", config.width)
	header:SetAttribute("x-scale", config.scale)
	header:SetAttribute("_ignore", nil)

	if header.grpNumber then
		if config.attribPoint == "RIGHT" then
			header.grpNumber:ClearAllPoints()
			header.grpNumber:SetPoint("LEFT", header, "RIGHT")
		elseif config.attribPoint == "LEFT" then
			header.grpNumber:ClearAllPoints()
			header.grpNumber:SetPoint("RIGHT", header, "LEFT")
		elseif config.attribPoint == "BOTTOM" then
			header.grpNumber:ClearAllPoints()
			header.grpNumber:SetPoint("TOP", header, "BOTTOM")
		else
			header.grpNumber:ClearAllPoints()
			header.grpNumber:SetPoint("BOTTOM", header, "TOP")
		end
	end
	
	local ButtonName = header:GetName() .. "UnitButton"
	local num = 1
	local frame = _G[ButtonName .. num]
	while( frame ) do
		frame:ClearAllPoints()
		frame:SetWidth(config.width)
		frame:SetHeight(config.height)
		frame:SetScale(config.scale)
		LUF.PlaceModules(frame)
		num = num + 1
		frame = _G[ButtonName .. num]
	end
	if not header:GetAttribute("raidHidden") then -- Do not refresh if hidden in raid
		header:Hide()
		header:Show()
	end
	
	if not LUF.db.profile.locked then
		LUF:UpdateMovers()
	end
end

local function SetHeaderSettings(header)
	if header.grpNumber then
		if LUF.db.profile.units.raid.groupnumbers then
			header.grpNumber:Show()
			header.grpNumber:SetFont(LUF:LoadMedia(SML.MediaType.FONT, LUF.db.profile.units.raid.font), LUF.db.profile.units.raid.fontsize)
		else
			header.grpNumber:Hide()
		end
	end
	local HeaderName = header:GetName() .. "UnitButton"
	local num = 1
	local frame = _G[HeaderName .. num]
	while( frame ) do
		LUF.PlaceModules(frame)
		LUF.ApplySettings(frame)
		num = num + 1
		frame = _G[HeaderName .. num]
	end
end

local classOrder = {
	[1] = "DRUID",
	[2] = "HUNTER",
	[3] = "MAGE",
	[4] = "PALADIN",
	[5] = "PRIEST",
	[6] = "ROGUE",
	[7] = "SHAMAN",
	[8] = "WARLOCK",
	[9] = "WARRIOR",
}

function LUF:SetupHeader(headerUnit)
	local header
	local config = self.db.profile.units[headerUnit] or self.db.profile.units.raid
	
	if headerUnit == "raid" then
		if not self.frameIndex["raid1"] then return end
		for id=1,9 do
			header = self.frameIndex["raid"..id]
			if config.groupBy == "GROUP" then
				header:SetAttribute("groupFilter", tostring(id))
				header.grpNumber:SetText(GROUP.." "..id)
			else
				header:SetAttribute("groupFilter", classOrder[id])
				header.grpNumber:SetText(LOCALIZED_CLASS_NAMES_MALE[classOrder[id]])
			end
			SetHeaderAttributes(header, config)
		end
	else
		header = self.frameIndex[headerUnit]
		if not header then return end
		--header:SetAttribute("groupFilter", nil)
		SetHeaderAttributes(header, config)
	end
end

function LUF:SetupAllHeaders()
	for i,unit in pairs(LUF.unitList) do
		if self.HeaderFrames[unit] then
			self:SetupHeader(unit)
		end
	end
end

function LUF:ReloadHeaderUnits(headerUnit)
	local header
	
	if headerUnit == "raid" then
		if not self.frameIndex["raid1"] then return end
		for id=1,9 do
			header = self.frameIndex["raid"..id]
			SetHeaderSettings(header)
		end
	else
		header = self.frameIndex[headerUnit]
		if not header then return end
		SetHeaderSettings(header)
	end
end

function LUF:ReloadSingleUnit(unit)
	local frame = self.frameIndex[unit]
	local config = self.db.profile.units[unit]
	--local res = GetScreenHeight() / strmatch(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)$")
	
	if not LUF.InCombatLockdown then
		frame:SetWidth(config.width)
		frame:SetHeight(config.height)
		frame:SetScale(config.scale)
	end
	LUF.PlaceModules(frame, unit)
	LUF.ApplySettings(frame)
	
	if not config.enabled and frame:IsEnabled() then
		frame:Disable()
	elseif config.enabled and not frame:IsEnabled() then
		frame:Enable()
	end
end

function LUF:Reload(unit)
	if self.HeaderFrames[unit] then
		self:ReloadHeaderUnits(unit)
	else
		self:ReloadSingleUnit(unit)
	end
end

function LUF:ReloadAll()
	for i,unit in pairs(self.unitList) do
		self:Reload(unit)
	end
end

local queuedEvent
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function(self, event, addon)
	if( event == "PLAYER_LOGIN" ) then
		LUF:OnLoad()
		self:UnregisterEvent("PLAYER_LOGIN")
	elseif( event == "ADDON_LOADED" and ( addon == "Blizzard_ArenaUI" or addon == "Blizzard_CompactRaidFrames" ) and not LUF.InCombatLockdown) then
		LUF:HideBlizzardFrames()
	elseif event == "PLAYER_REGEN_DISABLED" then
		LUF.InCombatLockdown = true
		if not LUF.db.profile.locked then
			LUF.db.profile.locked = true
			LUF:UpdateMovers()
			if( ACR ) then
				ACR:NotifyChange("LunaUnitFrames")
			end
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		LUF.InCombatLockdown = nil
		LUF:AutoswitchProfile(queuedEvent)
		queuedEvent = nil
		if( ACR ) then
			ACR:NotifyChange("LunaUnitFrames")
		end
	elseif event == "DISPLAY_SIZE_CHANGED" and LUF.db.char.switchtype == "RESOLUTION" then
		if not LUF.InCombatLockdown then
			LUF:AutoswitchProfile(event)
		else
			queuedEvent = event
		end
	elseif event == "GROUP_ROSTER_UPDATE" and LUF.db.char.switchtype == "GROUP" then
		if not LUF.InCombatLockdown then
			LUF:AutoswitchProfile(event)
		else
			queuedEvent = event
		end
	end
end)

function LUF:AutoswitchProfileSetup()
	queuedEvent = nil
	frame:UnregisterEvent("DISPLAY_SIZE_CHANGED")
	frame:UnregisterEvent("GROUP_ROSTER_UPDATE")
	if self.db.char.switchtype == "RESOLUTION" then
		frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
	elseif self.db.char.switchtype == "GROUP" then
		frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	end
end
