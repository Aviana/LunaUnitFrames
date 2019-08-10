-- Luna Unit Frames by Aviana

LunaUF = select(2, ...)

local L = LunaUF.L
local ACR = LibStub("AceConfigRegistry-3.0", true)
LunaUF.version = 3029
LunaUF.unitList = {"player", "pet", "pettarget", "target", "targettarget", "targettargettarget", "party", "partytarget", "partypet", "raid", "raidpet", "maintank", "maintanktarget", "mainassist", "mainassisttarget"}
LunaUF.fakeUnits = {["targettarget"] = true, ["targettargettarget"] = true, ["pettarget"] = true, ["partytarget"] = true, ["maintanktarget"] = true, ["mainassisttarget"] = true}
LunaUF.enabledUnits = {}
LunaUF.modules = {}
LunaUF.moduleOrder = {}

-- Cache the units so we don't have to concat every time it updates
LunaUF.unitTarget = setmetatable({}, {__index = function(tbl, unit) rawset(tbl, unit, unit .. "target"); return unit .. "target" end})
LunaUF.partyUnits, LunaUF.partytargetUnits, LunaUF.partypetUnits, LunaUF.raidUnits, LunaUF.raidPetUnits = {}, {}, {}, {}, {}
LunaUF.maintankUnits, LunaUF.mainassistUnits, LunaUF.raidpetUnits = LunaUF.raidUnits, LunaUF.raidUnits, LunaUF.raidPetUnits
for i=1, MAX_PARTY_MEMBERS do LunaUF.partyUnits[i] = "party" .. i end
for i=1, MAX_PARTY_MEMBERS do LunaUF.partytargetUnits[i] = "partytarget" .. i end
for i=1, MAX_PARTY_MEMBERS do LunaUF.partypetUnits[i] = "partypet" .. i end
for i=1, MAX_RAID_MEMBERS do LunaUF.raidUnits[i] = "raid" .. i end
for i=1, MAX_RAID_MEMBERS do LunaUF.raidPetUnits[i] = "raidpet" .. i end

function LunaUF:OnInitialize()
	
	self:LoadDefaults()
	
	-- Initialize DB
	self.db = LibStub:GetLibrary("AceDB-3.0"):New("LunaUFDB", self.defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfilesChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfilesChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileReset")

	self.db.profile.version = self.version
	self:FireModuleEvent("OnInitialize")

	self:HideBlizzardFrames()

	self.Layout:LoadSML()
	self:LoadUnits()
	self.modules.movers:Update()
	self:CreateConfig()
end

function LunaUF:ProfilesChanged()
	if( resetTimer ) then resetTimer:Hide() end
	
	self.db:RegisterDefaults(self.defaults)
	
	-- No active layout, register the default one
	if( not self.db.profile.loadedLayout ) then
		self:LoadDefaults()
	end
	
	self:FireModuleEvent("OnProfileChange")
	self:HideBlizzardFrames()
	self.Units:ProfileChanged()
	self:LoadUnits()
	self.modules.movers:Update()
	LunaUF.Layout:Reload()
end

local resetTimer
function LunaUF:ProfileReset()
	self:Print("The Profile was reset!")
	if( not resetTimer ) then
		resetTimer = CreateFrame("Frame")
		resetTimer:SetScript("OnUpdate", function(self)
			LunaUF:ProfilesChanged()
			self:Hide()
		end)
	end
	
	resetTimer:Show()
end

function LunaUF:RegisterModule(module, key, name, isBar, class)

	self.modules[key] = module

	module.moduleKey = key
	module.moduleHasBar = isBar
	module.moduleName = name
	module.moduleClass = class
	
	table.insert(self.moduleOrder, module)
end

function LunaUF:FireModuleEvent(event, frame, unit)
	for _, module in pairs(self.moduleOrder) do
		if( module[event] ) then
			module[event](module, frame, unit)
		end
	end
end

LunaUF.noop = function() end
LunaUF.hiddenFrame = CreateFrame("Frame")
LunaUF.hiddenFrame:Hide()

local rehideFrame = function(self)
	if( not InCombatLockdown() ) then
		self:Hide()
	end
end

local function basicHideBlizzardFrames(...)
	for i=1, select("#", ...) do
		local frame = select(i, ...)
		frame:UnregisterAllEvents()
		frame:HookScript("OnShow", rehideFrame)
		frame:Hide()
	end
end

local function hideBlizzardFrames(taint, ...)
	for i=1, select("#", ...) do
		local frame = select(i, ...)
		frame:UnregisterAllEvents()
		frame:Hide()

		if( frame.manabar ) then frame.manabar:UnregisterAllEvents() end
		if( frame.healthbar ) then frame.healthbar:UnregisterAllEvents() end
		if( frame.spellbar ) then frame.spellbar:UnregisterAllEvents() end
		if( frame.powerBarAlt ) then frame.powerBarAlt:UnregisterAllEvents() end

		if( taint ) then
			frame.Show = LunaUF.noop
		else
			frame:SetParent(LunaUF.hiddenFrame)
			frame:HookScript("OnShow", rehideFrame)
		end
	end
end

local active_hiddens = {}
function LunaUF:HideBlizzardFrames()
	if( self.db.profile.hidden.cast and not active_hiddens.cast ) then
		hideBlizzardFrames(true, CastingBarFrame)
	end

	if( self.db.profile.hidden.party and not active_hiddens.party ) then
		for i=1, MAX_PARTY_MEMBERS do
			local name = "PartyMemberFrame" .. i
			hideBlizzardFrames(true, _G[name], _G[name .. "HealthBar"], _G[name .. "ManaBar"])
		end
		
		-- This stops the compact party frame from being shown		
		UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")

		-- This just makes sure
		if( CompactPartyFrame ) then
			hideBlizzardFrames(false, CompactPartyFrame)
		end
	end

	if( CompactRaidFrameManager ) then
		if( self.db.profile.hidden.raid and not active_hiddens.raidTriggered ) then
			active_hiddens.raidTriggered = true

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
		hideBlizzardFrames(false, BuffFrame, TemporaryEnchantFrame)
	end
	
	if( self.db.profile.hidden.player and not active_hiddens.player ) then
		hideBlizzardFrames(false, PlayerFrame)
		
		PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		PlayerFrame:SetMovable(true)
		PlayerFrame:SetUserPlaced(true)
		PlayerFrame:SetDontSavePosition(true)
	end

	if( self.db.profile.hidden.pet and not active_hiddens.pet ) then
		hideBlizzardFrames(false, PetFrame)
	end

	if( self.db.profile.hidden.target and not active_hiddens.target ) then
		hideBlizzardFrames(false, TargetFrame, ComboFrame, TargetFrameToT)
	end

	-- As a reload is required to reset the hidden hooks, we can just set this to true if anything is true
	for type, flag in pairs(self.db.profile.hidden) do
		if( flag ) then
			active_hiddens[type] = true
		end
	end
end

function LunaUF:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF2150C2LunaUnitFrames|cFFFFFFFF: ".. msg)
end

function LunaUF:LoadUnits()
	
	for _, type in pairs(self.unitList) do
		local enabled = self.db.profile.units[type].enabled
		
		self.enabledUnits[type] = enabled
		
		if( enabled ) then
			self.Units:InitializeFrame(type)
		else
			self.Units:UninitializeFrame(type)
		end
	end
end

SLASH_LUNAUF1 = "/luf"
SLASH_LUNAUF2 = "/luna"
SLASH_LUNAUF3 = "/lunauf"
SLASH_LUNAUF4 = "/lunaunitframes"
SlashCmdList["LUNAUF"] = function(msg)
	msg = msg and string.lower(msg)
	if( msg and string.match(msg, "^profile (.+)") ) then
		local profile = string.match(msg, "^profile (.+)")
		
		for id, name in pairs(LunaUF.db:GetProfiles()) do
			if( string.lower(name) == profile ) then
				LunaUF.db:SetProfile(name)
				LunaUF:Print(string.format(L["Changed profile to %s."], name))
				return
			end
		end
		
		LunaUF:Print(string.format(L["Cannot find any profiles named \"%s\"."], profile))
		return
	end
	
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")
	AceConfigDialog:Open("LunaUnitFrames")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function(self, event, addon)
	if( event == "PLAYER_LOGIN" ) then
		LunaUF:OnInitialize()
		self:UnregisterEvent("PLAYER_LOGIN")
	elseif( event == "ADDON_LOADED" and ( addon == "Blizzard_ArenaUI" or addon == "Blizzard_CompactRaidFrames" ) ) then
		LunaUF:HideBlizzardFrames()
	elseif event == "PLAYER_REGEN_DISABLED" then
		LunaUF.db.profile.locked = true
		LunaUF.InCombatLockdown = true
		LunaUF.modules.movers:Update()
		if( ACR ) then
			ACR:NotifyChange("LunaUnitFrames")
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		LunaUF.InCombatLockdown = nil
		if( ACR ) then
			ACR:NotifyChange("LunaUnitFrames")
		end
	end
end)