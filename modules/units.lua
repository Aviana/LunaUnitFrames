local Units = {headerFrames = {}, unitFrames = {}, frameList = {}, unitEvents = {}, canCure = {}}
local Units = {headerFrames = {}, unitFrames = {}, frameList = {}, unitEvents = {}, canCure = {}}
Units.headerUnits = {["raid"] = true, ["raidpet"] = true, ["party"] = true, ["partytarget"] = true, ["partypet"] = true, ["maintank"] = true, ["maintanktarget"] = true, ["mainassist"] = true, ["mainassisttarget"] =true}

local headerFrames, unitFrames, frameList, unitEvents, headerUnits = Units.headerFrames, Units.unitFrames, Units.frameList, Units.unitEvents, Units.headerUnits
local _G = getfenv(0)
local playerClass = select(2, UnitClass("player"))

local L = LunaUF.L
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")

LunaUF.Units = Units
LunaUF:RegisterModule(Units, "units", "Units")

local stateMonitor = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")
stateMonitor.raids = {}

local classOrder = {
	[1] = "DRUID",
	[2] = "HUNTER",
	[3] = "MAGE",
	[4] = "PALADIN",
	[5] = "PRIEST",
	[6] = "ROGUE",
	[7] = "WARLOCK",
	[8] = "WARRIOR",
}

-- Frame shown, do a full update
local function FullUpdate(self)
	for i=1, #(self.fullUpdates), 2 do
		local handler = self.fullUpdates[i]
		handler[self.fullUpdates[i + 1]](handler, self)
	end
end

-- Re-registers events when unit changes
local function ReregisterUnitEvents(self)
	-- Not an unit event
	if( LunaUF.fakeUnits[self.unitRealType] or not headerUnits[self.unitType] ) then return end

	for event, list in pairs(self.registeredEvents) do
		if( unitEvents[event] ) then
			local hasHandler
			for handler in pairs(list) do
				hasHandler = true
				break
			end

			if( hasHandler ) then
				self:UnregisterEvent(event)
				self:BlizzRegisterUnitEvent(event, self.unit)
			end
		end
	end
end

-- Register an event that should always call the frame
local function RegisterNormalEvent(self, event, handler, func, unitOverride)
	-- Make sure the handler/func exists
	if( not handler[func] ) then
		error(string.format("Invalid handler/function passed for %s on event %s, the function %s does not exist.", self:GetName() or tostring(self), tostring(event), tostring(func)), 3)
		return
	end

	if( unitEvents[event] and not LunaUF.fakeUnits[self.unitRealType] ) then
		self:BlizzRegisterUnitEvent(event, unitOverride or self.unit)
		if unitOverride then
			self.unitEventOverrides = self.unitEventOverrides or {}
			self.unitEventOverrides[event] = unitOverride
		end
	else
		self:RegisterEvent(event)
	end

	self.registeredEvents[event] = self.registeredEvents[event] or {}
	
	-- Each handler can only register an event once per a frame.
	if( self.registeredEvents[event][handler] ) then
		return
	end

	self.registeredEvents[event][handler] = func
end

-- Unregister an event
local function UnregisterEvent(self, event, handler)
	if( self.registeredEvents[event] and self.registeredEvents[event][handler] ) then
		self.registeredEvents[event][handler] = nil
		
		local hasHandler
		for handler in pairs(self.registeredEvents[event]) do
			hasHandler = true
			break
		end
		
		if( not hasHandler ) then
			self:UnregisterEvent(event)
		end
	end
end

-- Register an event thats only called if it's for the actual unit
local function RegisterUnitEvent(self, event, handler, func)
	unitEvents[event] = true
	RegisterNormalEvent(self, event, handler, func)
end

-- Register a function to be called in an OnUpdate if it's an invalid unit (targettarget/etc)
local function RegisterUpdateFunc(self, handler, func)
	if( not handler[func] ) then
		error(string.format("Invalid handler/function passed to RegisterUpdateFunc for %s, the function %s does not exist.", self:GetName() or tostring(self), func), 3)
		return
	end

	for i=1, #(self.fullUpdates), 2 do
		local data = self.fullUpdates[i]
		if( data == handler and self.fullUpdates[i + 1] == func ) then
			return
		end
	end
	
	table.insert(self.fullUpdates, handler)
	table.insert(self.fullUpdates, func)
end

local function UnregisterUpdateFunc(self, handler, func)
	for i=#(self.fullUpdates), 1, -1 do
		if( self.fullUpdates[i] == handler and self.fullUpdates[i + 1] == func ) then
			table.remove(self.fullUpdates, i + 1)
			table.remove(self.fullUpdates, i)
		end
	end
end

-- Used when something is disabled, removes all callbacks etc to it
local function UnregisterAll(self, handler)
	for i=#(self.fullUpdates), 1, -1 do
		if( self.fullUpdates[i] == handler ) then
			table.remove(self.fullUpdates, i + 1)
			table.remove(self.fullUpdates, i)
		end
	end

	for event, list in pairs(self.registeredEvents) do
		if( list[handler] ) then
			list[handler] = nil
			
			local hasRegister
			for handler in pairs(list) do
				hasRegister = true
				break
			end
			
			if( not hasRegister ) then
				self:UnregisterEvent(event)
			end
		end
	end
end

-- Handles setting alphas in a way so combat fader and range checker don't override each other
local function DisableRangeAlpha(self, toggle)
	self.disableRangeAlpha = toggle
	
	if( not toggle and self.rangeAlpha ) then
		self:SetAlpha(self.rangeAlpha)
	end
end

local function SetRangeAlpha(self, alpha)
	if( not self.disableRangeAlpha ) then
		self:SetAlpha(alpha)
	else
		self.rangeAlpha = alpha
	end
end

local function SetBarColor(self, key, r, g, b)
	self:SetBlockColor(self[key], key, r, g, b)
end

local function SetBlockColor(self, bar, key, r, g, b)
	--local bgColor = bar.background.overrideColor or bar.background.backgroundColor
	--if( not LunaUF.db.profile.units[self.unitType][key].invert ) then
	if true then
		bar:SetStatusBarColor(r, g, b)--, LunaUF.db.profile.bars.alpha)
		if( not bgColor ) then
			bar.background:SetVertexColor(r, g, b)--, LunaUF.db.profile.bars.backgroundAlpha)
		else
			bar.background:SetVertexColor(r, g, b, LunaUF.db.profile.bars.backgroundAlpha)
		end
	else
		bar.background:SetVertexColor(r, g, b, LunaUF.db.profile.bars.alpha)
		if( not bgColor ) then
			bar:SetStatusBarColor(0, 0, 0, 1 - LunaUF.db.profile.bars.backgroundAlpha)
		else
			bar:SetStatusBarColor(bgColor.r, bgColor.g, bgColor.b, 1 - LunaUF.db.profile.bars.backgroundAlpha)
		end
	end
end

-- Event handling
local function OnEvent(self, event, unit, ...)
	if( not unitEvents[event] or self.unit == unit or (self.unitEventOverrides and self.unitEventOverrides[event] == unit)) then
		for handler, func in pairs(self.registeredEvents[event]) do
			handler[func](handler, self, event, unit, ...)
		end
	end
end

Units.OnEvent = OnEvent

-- Do a full update OnShow, and stop watching for events when it's not visible
local function OnShowForced(self)
	-- Reset the event handler
	self:SetScript("OnEvent", OnEvent)
	self:FullUpdate()
end

local function OnShow(self)
	-- Reset the event handler
	self:SetScript("OnEvent", OnEvent)
	Units:CheckUnitStatus(self)
end

local function OnHide(self)
	self:SetScript("OnEvent", nil)

	-- If it's a volatile such as target, next time it's shown it has to do an update
	-- OR if the unit is still shown, but it's been hidden because our parent (Basically UIParent)
	-- we want to flag it as having changed so it can be updated
	if( self.isUnitVolatile or self:IsShown() ) then
		self.unitGUID = nil
	end
end

-- Deal with enabling modules inside a zone
local function CheckModules(self)
	local layoutUpdate

	-- Selectively disable modules
	for _, module in pairs(LunaUF.moduleOrder) do
		if( module.OnEnable and module.OnDisable and LunaUF.db.profile.units[self.unitType][module.moduleKey] ) then
			local key = module.moduleKey
			local enabled = LunaUF.db.profile.units[self.unitType][key].enabled
			
			-- These modules have mini-modules, the entire module should be enabled if at least one is enabled, and disabled if all are disabled
			if( key == "auras" or key == "indicators" or key == "squares" or key == "highlight" or key == "borders" ) then
				enabled = nil
				for _, option in pairs(LunaUF.db.profile.units[self.unitType][key]) do
					if( type(option) == "table" and option.enabled or option == true or option == false) then
						enabled = true
						break
					end
				end
			end

			-- Force disable modules for people who aren't the appropriate class
			if( module.moduleClass and module.moduleClass ~= playerClass ) then
				enabled = nil
			end

			-- Module isn't enabled all the time, only in this zone so we need to force it to be enabled
			if( enabled ) then
				if ( not self.visibility[key] ) then
					module:OnEnable(self)
					layoutUpdate = true
				end
			elseif( not enabled ) then
				if ( self.visibility[key] ) then
					module:OnDisable(self)
					layoutUpdate = true
				end
			end
			self.visibility[key] = enabled or nil
		end
	end

	-- We had a module update, force a full layout update of this frame
	if( layoutUpdate ) then
		LunaUF.Layout:Load(self)
	end
end

local function checkForGroupNumber(self)
	if LunaUF.db.profile.units.raid.groupnumbers then
		if self:GetWidth() > 1 and self:GetHeight() > 1 or not LunaUF.db.profile.locked then
			self.number:Show()
			if self.groupID == 4 and LunaUF.db.profile.units.raid.groupBy == "CLASS" then --Since UnitFactionGroup returns garbage on login, we hack
				if UnitFactionGroup("player") == "Horde" then
					self.number:SetText(LOCALIZED_CLASS_NAMES_MALE["SHAMAN"])
				else
					self.number:SetText(LOCALIZED_CLASS_NAMES_MALE["PALADIN"])
				end
			end
			return
		end
	end
	self.number:Hide()
end

local function checkForPetGroupNumber(self,x,y)
	if LunaUF.db.profile.units.raid.groupnumbers then
		if x > 1 and y > 1 or not LunaUF.db.profile.locked then
			self.number:Show()
			return
		end
	end
	self.number:Hide()
end

-- Handles checking for GUID changes for doing a full update, this fixes frames sometimes showing the wrong unit when they change
function Units:CheckUnitStatus(frame)
	local guid = frame.unit and UnitGUID(frame.unit)
	if( guid ~= frame.unitGUID ) then
		frame.unitGUID = guid
		
		if( guid ) then
			frame:FullUpdate()
		end
	end
end

-- The argument from UNIT_PET is the pets owner, so the player summoning a new pet gets "player", party1 summoning a new pet gets "party1" and so on
function Units:CheckPetUnitUpdated(frame, event, unit)
	if( unit == frame.unitRealOwner and UnitExists(frame.unit) ) then
		frame.unitGUID = UnitGUID(frame.unit)
		frame:FullUpdate()
	end
end

function Units:CheckGroupedUnitStatus(frame)
	frame.unitGUID = UnitGUID(frame.unit)
	frame:FullUpdate()
end

local OnAttributeChanged

local function createFakeUnitUpdateTimer(frame)
	if( not frame.updateTimer ) then
		frame.updateTimer = C_Timer.NewTicker(0.1, function() if( UnitExists(frame.unit) ) then frame:FullUpdate() end end)
	end
end

-- Attribute set, something changed
-- unit = Active unitid
-- unitID = Just the number from the unitid
-- unitType = Unitid minus numbers in it, used for configuration
-- unitRealType = The actual unit type, if party is shown in raid this will be "party" while unitType is still "raid"
OnAttributeChanged = function(self, name, unit)
	if( name ~= "unit" or not unit or unit == self.unit ) then return end

	-- Nullify the previous entry if it had one
	local configUnit = self.unitUnmapped or unit
	if( self.configUnit and unitFrames[self.configUnit] == self ) then unitFrames[self.configUnit] = nil end
	
	-- Setup identification data
	self.unit = unit
	self.unitID = tonumber(string.match(unit, "([0-9]+)"))
	self.unitRealType = string.gsub(unit, "([0-9]+)", "")
	self.unitType = self.unitUnmapped and string.gsub(self.unitUnmapped, "([0-9]+)", "") or self.unitType or self.unitRealType

	-- Split everything into two maps, this is the simple parentUnit -> frame map
	-- This is for things like finding a party parent for party target/pet, the main map for doing full updates is
	-- an indexed frame that is updated once and won't have unit conflicts.
	if( self.unitRealType == self.unitType ) then
		unitFrames[configUnit] = self
	end

	frameList[self] = true

	-- Unit already exists but unitid changed, update the info we got on them
	-- Don't need to recheck the unitType and force a full update, because a raid frame can never become
	-- a party frame, or a player frame and so on
	if( self.unitInitialized ) then
		self:ReregisterUnitEvents()
		self:FullUpdate()
		return
	end

	self.unitInitialized = true

	-- Add to Clique
	if( not self:GetAttribute("isHeaderDriven") ) then
		ClickCastFrames = ClickCastFrames or {}
		ClickCastFrames[self] = true
	end

	-- Pet changed, going from pet -> vehicle for one
	if( self.unit == "pet" or self.unitType == "partypet" ) then
		self.unitRealOwner = self.unit == "pet" and "player" or LunaUF.partyUnits[self.unitID]
		self:SetAttribute("unitRealOwner", self.unitRealOwner)
		self:RegisterNormalEvent("UNIT_PET", Units, "CheckPetUnitUpdated")

		stateMonitor:WrapScript(self, "OnAttributeChanged", [[
			if( name == "state-unitexists" ) then
				-- Unit does not exist, hide frame
				if( not self:GetAttribute("state-unitexists") ) then
					self:Hide()
				-- Unit exists, show it
				else
					self:Show()
				end
			end
		]])

	-- Automatically do a full update on target change
	elseif( self.unit == "target" ) then
		self.isUnitVolatile = true
		self:RegisterNormalEvent("PLAYER_TARGET_CHANGED", Units, "CheckUnitStatus")
		self:RegisterUnitEvent("UNIT_TARGETABLE_CHANGED", self, "FullUpdate")

	elseif( self.unit == "player" ) then

		-- Force a full update when the player is alive to prevent freezes when releasing in a zone that forces a ressurect (naxx/tk/etc)
		self:RegisterNormalEvent("PLAYER_ALIVE", self, "FullUpdate")

	-- Check for a unit guid to do a full update
	elseif( self.unitRealType == "raid" ) then
		self:RegisterNormalEvent("GROUP_ROSTER_UPDATE", Units, "CheckGroupedUnitStatus")
		self:RegisterUnitEvent("UNIT_NAME_UPDATE", Units, "CheckUnitStatus")
		self:RegisterUnitEvent("UNIT_CONNECTION", self, "FullUpdate")
		
	-- Party members need to watch for changes
	elseif( self.unitRealType == "party" ) then
		self:RegisterNormalEvent("GROUP_ROSTER_UPDATE", Units, "CheckGroupedUnitStatus")
		self:RegisterNormalEvent("PARTY_MEMBER_ENABLE", Units, "CheckGroupedUnitStatus")
		self:RegisterNormalEvent("PARTY_MEMBER_DISABLE", Units, "CheckGroupedUnitStatus")
		self:RegisterUnitEvent("UNIT_NAME_UPDATE", Units, "CheckUnitStatus")
		self:RegisterUnitEvent("UNIT_OTHER_PARTY_CHANGED", self, "FullUpdate")
		self:RegisterUnitEvent("UNIT_CONNECTION", self, "FullUpdate")
	
	-- *target units are not real units, thus they do not receive events and must be polled for data
	elseif( LunaUF.fakeUnits[self.unitRealType] ) then
		createFakeUnitUpdateTimer(self)
		
		-- Speeds up updating units when their owner changes target, if party1 changes target then party1target is force updated, if target changes target
		-- then targettarget and targettargettarget are also force updated
		if( self.unitRealType == "partytarget" ) then
			self.unitRealOwner = LunaUF.partyUnits[self.unitID]
		elseif( self.unitRealType == "raid" ) then
			self.unitRealOwner = LunaUF.raidUnits[self.unitID]
		elseif( self.unit == "targettarget" or self.unit == "targettargettarget" ) then
			self.unitRealOwner = "target"
			self:RegisterNormalEvent("PLAYER_TARGET_CHANGED", Units, "CheckUnitStatus")
		end

		self:RegisterNormalEvent("UNIT_TARGET", Units, "CheckPetUnitUpdated")
	end

	self:CheckModules()
	Units:CheckUnitStatus(self)
end

Units.OnAttributeChanged = OnAttributeChanged

local secureInitializeUnit = [[
	local header = self:GetParent()

	self:SetHeight(header:GetAttribute("style-height"))
	self:SetWidth(header:GetAttribute("style-width"))
	self:SetScale(header:GetAttribute("style-scale"))

	self:SetAttribute("*type1", "target")
	self:SetAttribute("*type2", "togglemenu")
	self:SetAttribute("type2", "togglemenu")

	self:SetAttribute("isHeaderDriven", true)

	-- initialize frame
	header:CallMethod("initialConfigFunction", self:GetName())

	-- Clique integration
	local clickHeader = header:GetFrameRef("clickcast_header")
	if( clickHeader ) then
		clickHeader:SetAttribute("clickcast_button", self)
		clickHeader:RunAttribute("clickcast_register")
	end
]]

local unitButtonTemplate = ClickCastHeader and "ClickCastUnitTemplate,SecureUnitButtonTemplate,SecureHandlerStateTemplate" or "SecureUnitButtonTemplate,SecureHandlerStateTemplate"

-- Header unit initialized
local function initializeUnit(header, frameName)
	local frame = _G[frameName]

	frame.ignoreAnchor = true
	frame.unitType = header.unitType

	Units:CreateUnit(frame)
end

-- Show tooltip
local function OnEnter(self)
	if( self.OnEnter ) then
		self:OnEnter()
	end
end

local function OnLeave(self)
	if( self.OnLeave ) then
		self:OnLeave()
	end
end

local function LUF_OnEnter(self)
	if( not LunaUF.db.profile.tooltipCombat or not InCombatLockdown() ) then
		if not GameTooltip:IsForbidden() then
			UnitFrame_OnEnter(self)
		end
	end
end

local function LUF_OnLeave(self)
	if not GameTooltip:IsForbidden() then
		UnitFrame_OnLeave(self)
	end
end

local function ClassToken(self)
	return (select(2, UnitClass(self.unit)))
end

function Units:CreateUnit(...)
	local frame = select("#", ...) > 1 and CreateFrame(...) or select(1, ...)
	frame.fullUpdates = {}
	frame.registeredEvents = {}
	frame.BlizzRegisterUnitEvent = frame.RegisterUnitEvent
	frame.RegisterNormalEvent = RegisterNormalEvent
	frame.RegisterUnitEvent = RegisterUnitEvent
	frame.RegisterUpdateFunc = RegisterUpdateFunc
	frame.UnregisterAll = UnregisterAll
	frame.UnregisterSingleEvent = UnregisterEvent
	frame.SetRangeAlpha = SetRangeAlpha
	frame.visibility = {}
	frame.CheckModules = CheckModules
	frame.DisableRangeAlpha = DisableRangeAlpha
	frame.UnregisterUpdateFunc = UnregisterUpdateFunc
	frame.ReregisterUnitEvents = ReregisterUnitEvents
	frame.SetBarColor = SetBarColor
	frame.SetBlockColor = SetBlockColor
	frame.FullUpdate = FullUpdate
	frame.UnitClassToken = ClassToken
	frame.topFrameLevel = 5

	-- Ensures that text is the absolute highest thing there is
	frame.highFrame = CreateFrame("Frame", nil, frame)
	frame.highFrame:SetFrameLevel(frame.topFrameLevel + 2)
	frame.highFrame:SetAllPoints(frame)
	frame:HookScript("OnAttributeChanged", OnAttributeChanged)
	if frame.unitType == "partytarget" or frame.unitType == "maintanktarget" or frame.unitType == "mainassisttarget" then
		-- Brute forcing targets into a party header since blizz doesn't provide target headers
		stateMonitor:WrapScript(frame, "OnAttributeChanged", [[
			if( name == "unit" ) then
				if ( not value ) then
					UnregisterUnitWatch(self)
				elseif value ~= "player" and value ~= "target" and not strmatch(value, "target$") then
					self:SetAttribute("unit", value.."target")
					RegisterUnitWatch(self)
					return false
				elseif value == "player" then
					self:SetAttribute("unit", "target")
					RegisterUnitWatch(self)
					return false
				end
			end
		]])
	elseif frame.unitType == "partypet" then
		-- Brute forcing partypets into a party header since the pet group template sucks ass
		stateMonitor:WrapScript(frame, "OnAttributeChanged", [[
			if( name == "unit" ) then
				if ( not value ) then
					UnregisterUnitWatch(self)
				elseif value ~= "player" and value ~= "pet" and not strmatch(value, "^partypet%d$") then
					local unitID = strmatch(value, "%d")
					self:SetAttribute("unit", "partypet"..unitID)
					RegisterUnitWatch(self)
					return false
				elseif value == "player" then
					self:SetAttribute("unit", "pet")
					RegisterUnitWatch(self)
					return false
				end
			end
		]])
	end
	frame:SetScript("OnEvent", OnEvent)
	frame:HookScript("OnEnter", OnEnter)
	frame:HookScript("OnLeave", OnLeave)
	frame:SetScript("OnShow", OnShow)
	frame:SetScript("OnHide", OnHide)

	frame.OnEnter = LUF_OnEnter
	frame.OnLeave = LUF_OnLeave

	frame:RegisterForClicks("AnyUp")
	-- non-header frames don't set those, so we need to do it
	if( not InCombatLockdown() and not frame:GetAttribute("isHeaderDriven") ) then
		frame:SetAttribute("*type1", "target")
		frame:SetAttribute("*type2", "togglemenu")
	end
	
	return frame
end

-- Reload a header completely
function Units:ReloadHeader(type)
	if( type == "raid" ) then
		self:InitializeFrame("raid")
	elseif( headerFrames[type] ) then
		self:SetHeaderAttributes(headerFrames[type], type)
		LunaUF.Layout:AnchorFrame(headerFrames[type], LunaUF.db.profile.units[type])
		LunaUF:FireModuleEvent("OnLayoutReload", type)
	end
end

function Units:CheckGroupVisibility()
	if( not LunaUF.db.profile.locked ) then return end
	local raid = headerFrames.raid1
	local raidpet = headerFrames.raidpet
	local party = headerFrames.party
	local partytarget = headerFrames.partytarget
	local partypet = headerFrames.partypet
	
	if( party ) then
		party:SetAttribute("showParty", true)
		party:SetAttribute("showPlayer", LunaUF.db.profile.units.party.showPlayer)
		party:SetAttribute("showSolo", LunaUF.db.profile.units.party.showPlayersolo)
	end

	if( partytarget ) then
		partytarget:SetAttribute("showParty", LunaUF.db.profile.units.raid.showParty)
		partytarget:SetAttribute("showPlayer", LunaUF.db.profile.units.party.showPlayer)
		partytarget:SetAttribute("showSolo", LunaUF.db.profile.units.party.showPlayersolo)
	end

	if( partypet ) then
		partypet:SetAttribute("showParty", LunaUF.db.profile.units.raid.showParty)
		partypet:SetAttribute("showPlayer", LunaUF.db.profile.units.party.showPlayer)
		partypet:SetAttribute("showSolo", LunaUF.db.profile.units.party.showPlayersolo)
	end

	if( raid ) then
		
		raid:SetAttribute("showParty", LunaUF.db.profile.units.raid.showParty)
		raid:SetAttribute("showPlayer", LunaUF.db.profile.units.raid.showParty)
		raid:SetAttribute("showSolo", LunaUF.db.profile.units.raid.showSolo)
	end
	
	if ( raidpet ) then
		raidpet:SetAttribute("showParty", LunaUF.db.profile.units.raid.showParty)
		raidpet:SetAttribute("showPlayer", LunaUF.db.profile.units.raid.showParty)
		raidpet:SetAttribute("showSolo", LunaUF.db.profile.units.raid.showSolo)
	end
end

function Units:SetHeaderAttributes(frame, type)
	
	local config = LunaUF.db.profile.units[type]
	local offset = config.offset

	-- Normal raid, ma or mt
	if( type == "raidpet" or type == "raid" or type == "mainassist" or type == "maintank" ) then
		local filter
		if( config.filters ) then
			if config.groupBy == "GROUP" then
				filter = config.filters[frame.groupID] and frame.groupID
			elseif config.groupBy == "CLASS" then
				filter = frame.groupID == 4 and "SHAMAN,PALADIN" or classOrder[frame.groupID]
			end
			stateMonitor.raids[frame.groupID]:SetAttribute("raidDisabled", not config.filters[frame.groupID])
		end
		
		if type == "raidpet" then
			local raidconfig = LunaUF.db.profile.units.raid
			checkForPetGroupNumber(frame,frame:GetWidth(),frame:GetHeight())
			frame.number:SetFont(LunaUF.Layout:LoadMedia(SML.MediaType.FONT, LunaUF.db.profile.units.raid.font), LunaUF.db.profile.units.raid.fontsize)
			frame.number:SetText(L["Pet"])
			
			if raidconfig.attribPoint == "RIGHT" then
				frame.number:ClearAllPoints()
				frame.number:SetPoint("LEFT", frame, "RIGHT")
			elseif raidconfig.attribPoint == "LEFT" then
				frame.number:ClearAllPoints()
				frame.number:SetPoint("RIGHT", frame, "LEFT")
			elseif raidconfig.attribPoint == "BOTTOM" then
				frame.number:ClearAllPoints()
				frame.number:SetPoint("TOP", frame, "BOTTOM")
			else
				frame.number:ClearAllPoints()
				frame.number:SetPoint("BOTTOM", frame, "TOP")
			end
		end

		frame:SetAttribute("showRaid", LunaUF.db.profile.locked and true)
		frame:SetAttribute("maxColumns", config.maxColumns or 1)
		frame:SetAttribute("unitsPerColumn", LunaUF.db.profile.locked and config.unitsPerColumn or 5)
		frame:SetAttribute("columnSpacing", config.columnSpacing)
		frame:SetAttribute("columnAnchorPoint", config.attribAnchorPoint)
		frame:SetAttribute("groupFilter", filter or "1,2,3,4,5,6,7,8")
		frame:SetAttribute("roleFilter", config.roleFilter)

	elseif( type == "party" ) then
		frame:SetAttribute("maxColumns", 5)
		frame:SetAttribute("unitsPerColumn", 5)
		frame:SetAttribute("columnSpacing", config.columnSpacing)
		frame:SetAttribute("columnAnchorPoint", config.attribAnchorPoint)
		self:CheckGroupVisibility()
		if( stateMonitor.party ) then
			stateMonitor.party:SetAttribute("hideSemiRaid", LunaUF.db.profile.units.party.hideSemiRaid)
			stateMonitor.party:SetAttribute("hideAnyRaid", LunaUF.db.profile.units.party.hideAnyRaid)
		end
	elseif( type == "partypet" or type == "partytarget" ) then
		if( stateMonitor[type] ) then
			stateMonitor[type]:SetAttribute("hideSemiRaid", LunaUF.db.profile.units.party.hideSemiRaid)
			stateMonitor[type]:SetAttribute("hideAnyRaid", LunaUF.db.profile.units.party.hideAnyRaid)
		end
		config = LunaUF.db.profile.units["party"]
		frame:SetAttribute("maxColumns", 5)
		frame:SetAttribute("unitsPerColumn", 5)
		frame:SetAttribute("columnSpacing", config.columnSpacing)
		frame:SetAttribute("columnAnchorPoint", config.attribAnchorPoint)
		self:CheckGroupVisibility()
	end
	
	if( type == "raid" ) then
		self:CheckGroupVisibility()

		for id, monitor in pairs(stateMonitor.raids) do
			monitor:SetAttribute("hideSemiRaid", LunaUF.db.profile.units.raid.hideSemiRaid)
		end
	end

	local xMod = config.attribPoint == "LEFT" and 1 or config.attribPoint == "RIGHT" and -1 or 0
	local yMod = config.attribPoint == "TOP" and -1 or config.attribPoint == "BOTTOM" and 1 or 0
	
	frame:SetAttribute("point", config.attribPoint)
	frame:SetAttribute("sortMethod", config.sortMethod)
	frame:SetAttribute("sortDir", config.sortOrder)
	
	frame:SetAttribute("xOffset", offset * xMod)
	frame:SetAttribute("yOffset", offset * yMod)
	frame:SetAttribute("xMod", xMod)
	frame:SetAttribute("yMod", yMod)

	if( not InCombatLockdown() and headerUnits[type] and frame.shouldReset ) then
		-- Children no longer have ClearAllPoints() called on them before they are repositioned
		-- this tries to stop it from bugging out by clearing it then forcing it to reposition everything
		local name = frame:GetName() .. "UnitButton"
		local index = 1
		local child = _G[name .. index]
		while( child ) do
			child:ClearAllPoints()

			index = index + 1
			child = _G[name .. index]
		end
	
		-- Hiding and reshowing the header forces an update
		if( frame:IsShown() ) then
			frame:Hide()
			frame:Show()
		end
	end

	frame.shouldReset = true
end

-- Load a single unit such as player, target, pet, etc
function Units:LoadUnit(unit)
	-- Already be loaded, just enable
	if( unitFrames[unit] ) then
		RegisterUnitWatch(unitFrames[unit], unitFrames[unit].hasStateWatch)
		return
	end
	
	local frame = self:CreateUnit("Button", "LUFUnit" .. unit, UIParent, "SecureUnitButtonTemplate")
	
	frame:SetAttribute("unit", unit)
	frame.hasStateWatch = unit == "pet"
	
	RegisterUnitWatch(frame, frame.hasStateWatch)
end

local function setupRaidStateMonitor(id, headerFrame)
	if( stateMonitor.raids[id] ) then return end

	stateMonitor.raids[id] = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")
--	stateMonitor.raids[id]:SetAttribute("raidDisabled", nil)
	stateMonitor.raids[id]:SetFrameRef("raidHeader", headerFrame)
	stateMonitor.raids[id]:SetAttribute("hideSemiRaid", LunaUF.db.profile.units.raid.hideSemiRaid)
	stateMonitor.raids[id]:WrapScript(stateMonitor.raids[id], "OnAttributeChanged", [[
		if( name ~= "state-raidmonitor" and name ~= "raiddisabled" and name ~= "hidesemiraid" ) then
			return
		end

		local header = self:GetFrameRef("raidHeader")
		if( self:GetAttribute("raidDisabled") ) then
			if( header:IsVisible() ) then header:Hide() end
			return
		end
		
		if( self:GetAttribute("hideSemiRaid") and self:GetAttribute("state-raidmonitor") ~= "raid6" ) then
			header:Hide()
		else
			header:Show()
		end
	]])
	
	RegisterStateDriver(stateMonitor.raids[id], "raidmonitor", "[target=raid6, exists] raid6; none")
end

function Units:LoadRaidGroupHeader(type)

	for id, monitor in pairs(stateMonitor.raids) do
		monitor:SetAttribute("hideSemiRaid", LunaUF.db.profile.units.raid.hideSemiRaid)
--		monitor:SetAttribute("raidDisabled", id == -1 and true or nil)
		monitor:SetAttribute("recheck", time())
	end

	local config = LunaUF.db.profile.units[type]
	local xMod = config.attribPoint == "LEFT" and 1 or config.attribPoint == "RIGHT" and -1 or 0
	local yMod = config.attribPoint == "TOP" and -1 or config.attribPoint == "BOTTOM" and 1 or 0
	
	for id, enabled in pairs(LunaUF.db.profile.units[type].filters) do
		local frame = headerFrames["raid" .. id]
		if( not frame ) then
			frame = CreateFrame("Frame", "LUFHeader" .. type .. id, UIParent, "SecureGroupHeaderTemplate")
			frame:SetAttribute("template", unitButtonTemplate)
			frame:SetAttribute("initial-unitWatch", true)
			frame:SetAttribute("showRaid", true)
			frame:SetAttribute("groupFilter", id)
			frame:SetAttribute("initialConfigFunction", secureInitializeUnit)
			frame.initialConfigFunction = initializeUnit
			frame.isHeaderFrame = true
			frame.unitType = type
			frame.unitMappedType = type
			frame.splitParent = type
			frame.groupID = id
--			frame:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1})
--			frame:SetBackdropBorderColor(1, 0, 0, 1)
--			frame:SetBackdropColor(0, 0, 0, 0)
			
			frame.number = frame:CreateFontString(nil, "ARTWORK")
			frame.number:SetShadowColor(0, 0, 0, 1.0)
			frame.number:SetShadowOffset(0.80, -0.80)
			frame.number:SetJustifyH("CENTER")
			
			frame:HookScript("OnAttributeChanged",checkForGroupNumber)
			frame:HookScript("OnSizeChanged",checkForGroupNumber)
			
			frame:SetAttribute("style-height", config.height)
			frame:SetAttribute("style-width", config.width)
			frame:SetAttribute("style-scale", config.scale)
			
			frame.shouldReset = true
			
			if( ClickCastHeader ) then
				-- the OnLoad adds the functions like SetFrameRef to the header
				SecureHandler_OnLoad(frame)
				frame:SetFrameRef("clickcast_header", ClickCastHeader)
			end
			
			headerFrames["raid" .. id] = frame
			
			setupRaidStateMonitor(id, frame)
		end
		if( enabled ) then
			
			checkForGroupNumber(frame)
			frame.number:SetFont(LunaUF.Layout:LoadMedia(SML.MediaType.FONT, LunaUF.db.profile.units.raid.font), LunaUF.db.profile.units.raid.fontsize)
			if LunaUF.db.profile.units.raid.groupBy == "GROUP" then
				frame.number:SetText(GROUP.." "..id)
			else
				if id == 4 and LunaUF.db.profile.units.raid.groupBy == "CLASS" then --Since UnitFactionGroup returns garbage on login, we hack
					if UnitFactionGroup("player") == "Horde" then
						frame.number:SetText(LOCALIZED_CLASS_NAMES_MALE["SHAMAN"])
					else
						frame.number:SetText(LOCALIZED_CLASS_NAMES_MALE["PALADIN"])
					end
				else
					frame.number:SetText(LOCALIZED_CLASS_NAMES_MALE[classOrder[id]])
				end
			end
			
			if config.attribPoint == "RIGHT" then
				frame.number:ClearAllPoints()
				frame.number:SetPoint("LEFT", frame, "RIGHT")
			elseif config.attribPoint == "LEFT" then
				frame.number:ClearAllPoints()
				frame.number:SetPoint("RIGHT", frame, "LEFT")
			elseif config.attribPoint == "BOTTOM" then
				frame.number:ClearAllPoints()
				frame.number:SetPoint("TOP", frame, "BOTTOM")
			else
				frame.number:ClearAllPoints()
				frame.number:SetPoint("BOTTOM", frame, "TOP")
			end
			
		end
		LunaUF.Layout:AnchorFrame(frame, LunaUF.db.profile.units.raid.positions[id])
		self:SetHeaderAttributes(frame, type)
	end
	
end

-- Load a header unit, party or pets
function Units:LoadGroupHeader(type)
	-- Already created, so just reshow and we out
	if( headerFrames[type] ) then
		headerFrames[type]:Show()

		if( (type == "party" or type == "partypet" or type == "partytarget") and stateMonitor[type] ) then
			stateMonitor[type]:SetAttribute("partyDisabled", nil)
		end

		if( type == "party" or type == "raid" ) then
			self:CheckGroupVisibility()
		end
		
		LunaUF.Layout:AnchorFrame(headerFrames[type], LunaUF.db.profile.units[type])
		return
	end

	local headerFrame = CreateFrame("Frame", "LUFHeader" .. type, UIParent, type == "raidpet" and "SecureGroupPetHeaderTemplate" or "SecureGroupHeaderTemplate")
	headerFrames[type] = headerFrame

	if type == "raidpet" then
		local raidconfig = LunaUF.db.profile.units.raid
		headerFrame.number = headerFrame:CreateFontString(nil, "ARTWORK")
		headerFrame.number:SetShadowColor(0, 0, 0, 1.0)
		headerFrame.number:SetShadowOffset(0.80, -0.80)
		headerFrame.number:SetJustifyH("CENTER")
		headerFrame:HookScript("OnSizeChanged",checkForPetGroupNumber)
	end

	self:SetHeaderAttributes(headerFrame, type)

	headerFrame:SetAttribute("template", unitButtonTemplate)
	headerFrame:SetAttribute("initial-unitWatch", true)
	headerFrame:SetAttribute("initialConfigFunction", secureInitializeUnit)

	headerFrame.initialConfigFunction = initializeUnit
	headerFrame.isHeaderFrame = true
	headerFrame.unitType = type
	headerFrame.unitMappedType = type

	-- For securely managing the display
	local config = LunaUF.db.profile.units[type]

	headerFrame:SetAttribute("style-height", config.height)
	headerFrame:SetAttribute("style-width", config.width)
	headerFrame:SetAttribute("style-scale", config.scale)

	if( ClickCastHeader ) then
		-- the OnLoad adds the functions like SetFrameRef to the header
		SecureHandler_OnLoad(headerFrame)
		headerFrame:SetFrameRef("clickcast_header", ClickCastHeader)
	end

	LunaUF.Layout:AnchorFrame(headerFrame, LunaUF.db.profile.units[type])
	
	-- We have to do party hiding based off raid as a state driver so that we can smoothly hide the party frames based off of combat and such
	-- technically this isn't the cleanest solution because party frames will still have unit watches active
	-- but this isn't as big of a deal, because LUF automatically will unregister the OnEvent for party frames while hidden
	if( type == "party" or type == "partypet" or type == "partytarget" ) then
		stateMonitor[type] = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")
		stateMonitor[type]:SetAttribute("partyDisabled", nil)
		stateMonitor[type]:SetFrameRef("partyHeader", headerFrame)
		stateMonitor[type]:SetAttribute("hideSemiRaid", LunaUF.db.profile.units[type].hideSemiRaid)
		stateMonitor[type]:SetAttribute("hideAnyRaid", LunaUF.db.profile.units[type].hideAnyRaid)
		stateMonitor[type]:WrapScript(stateMonitor[type], "OnAttributeChanged", [[
			if( name ~= "state-raidmonitor" and name ~= "partydisabled" and name ~= "hideanyraid" and name ~= "hidesemiraid" and name ~= "showPlayer" and name ~= "showPlayersolo" ) then return end
			if( self:GetAttribute("state-raidmonitor") == "combat" ) then return end
			if( self:GetAttribute("partyDisabled") ) then return end
			
			if( self:GetAttribute("hideAnyRaid") and ( self:GetAttribute("state-raidmonitor") == "raid1" or self:GetAttribute("state-raidmonitor") == "raid6" ) ) then
				self:GetFrameRef("partyHeader"):Hide()
			elseif( self:GetAttribute("hideSemiRaid") and self:GetAttribute("state-raidmonitor") == "raid6" ) then
				self:GetFrameRef("partyHeader"):Hide()
			else
				self:GetFrameRef("partyHeader"):Show()
			end
		]])
		RegisterStateDriver(stateMonitor[type], "raidmonitor", "[target=raid6, exists] raid6; [target=raid1, exists] raid1; none")
	else
		headerFrame:Show()
	end
end

-- Initialize units
function Units:InitializeFrame(type)
	if( type == "raid" ) then
		self:LoadRaidGroupHeader(type)
	elseif( headerUnits[type] ) then
		self:LoadGroupHeader(type)
	else
		self:LoadUnit(type)
	end
end

-- Uninitialize units
function Units:UninitializeFrame(type)
	if( type == "party" or type == "raid" ) then
		self:CheckGroupVisibility()
	end

	-- Disables showing party in raid automatically if raid frames are disabled
	if( (type == "party" or type == "partytarget" or type == "partypet") and stateMonitor[type] ) then
		stateMonitor[type]:SetAttribute("partyDisabled", true)
	end
	if( type == "raid" ) then
		for _, monitor in pairs(stateMonitor.raids) do
			monitor:SetAttribute("raidDisabled", true)
		end
	end

	if( headerFrames[type] ) then
		headerFrames[type]:Hide()
	else
		-- Disable all frames of this type
		for frame in pairs(frameList) do
			if( frame.unitType == type ) then
				UnregisterUnitWatch(frame)
				frame:SetAttribute("state-unitexits", false)
				frame:Hide()
			end
		end
	end
end

-- Profile changed, reload units
function Units:ProfileChanged()
	-- Reset the anchors for all frames to prevent X is dependant on Y
	for frame in pairs(frameList) do
		if( frame.unit ) then
			frame:ClearAllPoints()
		end
	end
	
	for frame in pairs(frameList) do
		if( frame.unit and LunaUF.db.profile.units[frame.unitType].enabled ) then
			-- Force all enabled modules to disable
			for key, module in pairs(LunaUF.modules) do
				if( frame[key] and frame.visibility[key] ) then
					frame.visibility[key] = nil
					module:OnDisable(frame)
				end
			end
			
			-- Now enable whatever we need to
			LunaUF.Layout:Load(frame)
			frame:FullUpdate()
		end
	end
	
	for _, frame in pairs(headerFrames) do
		if( LunaUF.db.profile.units[frame.unitType].enabled ) then
			self:ReloadHeader(frame.unitType)
		end
	end
end

-- Small helper function for creating bars with
function Units:CreateBar(parent)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetFrameLevel(parent.topFrameLevel or 5)
	bar.parent = parent
	
	bar.background = bar:CreateTexture(nil, "BORDER")
	bar.background:SetHeight(1)
	bar.background:SetWidth(1)
	bar.background:SetAllPoints(bar)
	bar.background:SetHorizTile(false)

	return bar
end

-- Handle figuring out what auras players can cure
local curableSpells = {
	["DRUID"] = {[2782] = {"Curse"}, [2893] = {"Poison"}, [8946] = {"Poison"}},
	["PRIEST"] = {[528] = {"Disease"}, [552] = {"Disease"}, [527] = {"Magic"}, [988] = {"Magic"}},
	["PALADIN"] = {[4987] = {"Poison", "Disease", "Magic"}, [1152] = {"Poison", "Disease"}},
	["SHAMAN"] = {[2870] = {"Disease"}, [526] = {"Poison"}},
}

curableSpells = curableSpells[select(2, UnitClass("player"))]

local function checkCurableSpells()
	table.wipe(Units.canCure)
	
	if select(2, UnitClass("player")) == "WARLOCK" then
		if IsUsableSpell(GetSpellInfo(19505)) then
			Units.canCure["Magic"] = true
		end
	elseif curableSpells then
		for spellID, cures in pairs(curableSpells) do
			if( IsPlayerSpell(spellID) ) then
				for _, auraType in pairs(cures) do
					Units.canCure[auraType] = true
				end
			end
		end
	end
end

local centralFrame = CreateFrame("Frame")
centralFrame:RegisterEvent("PLAYER_LOGIN")
centralFrame:SetScript("OnEvent", function(self, event, arg1)
	-- Monitor talent changes for curable changes
	if( event == "LEARNED_SPELL_IN_TAB" ) then
		checkCurableSpells()
		for frame in pairs(LunaUF.Units.frameList) do
			if( frame.unit and frame:IsVisible() ) then
				frame:FullUpdate()
			end
		end
	elseif event == "UNIT_PET" and arg1 == "player" then
		checkCurableSpells()
		for frame in pairs(LunaUF.Units.frameList) do
			if( frame.unit and frame:IsVisible() ) then
				frame:FullUpdate()
			end
		end
	elseif( event == "PLAYER_LOGIN" ) then
		checkCurableSpells()
		if select(2, UnitClass("player")) == "WARLOCK" then
			self:RegisterEvent("UNIT_PET")
		elseif curableSpells then
			self:RegisterEvent("LEARNED_SPELL_IN_TAB")
		end
	end
end)
