local Cast = {}
local L = LunaUF.L
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")
local FADE_TIME = 0.30
local currentCasts = {}
local interruptIDs = {
	[GetSpellInfo(1766)] = true, -- kick
	[GetSpellInfo(6552)] = true, -- pummel
	[GetSpellInfo(2139)] = true, -- counterspell
	[GetSpellInfo(72) or "Shield Bash"] = true, -- shield bash
	[GetSpellInfo(8042)] = true, -- earth shock
	[GetSpellInfo(853)] = true, -- hammer of justice
	[GetSpellInfo(7922)] = true, -- Charge stun
	[GetSpellInfo(20615)] = true, -- intercept stun
	[GetSpellInfo(5246)] = true, -- Intimidating shout
	[GetSpellInfo(5530) or "Mace Stun"] = true, -- Mace Stun
	[GetSpellInfo(6358)] = true, -- Seduction
	[GetSpellInfo(6789)] = true, -- Death Coil
	[GetSpellInfo(22703)] = true, -- Inferno Effect
	[GetSpellInfo(5484)] = true, -- Howl of Terror
	[GetSpellInfo(5782)] = true, -- Fear
	[GetSpellInfo(408)] = true, -- Kidney Shot
	[GetSpellInfo(1776)] = true, -- Gouge
	[GetSpellInfo(2094)] = true, -- Blind
	[GetSpellInfo(15269) or "Blackout"] = true, -- Blackout
	[GetSpellInfo(15487)] = true, -- Silence
	[GetSpellInfo(8122)] = true, -- Psychic Scream
	[GetSpellInfo(20170) or "Stun"] = true, -- Seal of Justice
	[GetSpellInfo(3355)] = true, -- Freezing Trap
	[GetSpellInfo(9005) or "Pounce"] = true, -- Pounce
	[GetSpellInfo(16922) or "Starfire Stun"] = true, -- Starfire Stun
	[GetSpellInfo(5211)] = true, -- Bash
	[GetSpellInfo(19675) or "Feral Charge Effect"] = true, -- Feral Charge Effect
	
}

LunaUF:RegisterModule(Cast, "castBar", L["Cast bar"], true)

function LunaUF:GetCastName(unitGUID)
	if currentCasts[unitGUID] then
		return currentCasts[unitGUID].name
	end
end

function LunaUF:GetCastTime(unitGUID)
	if currentCasts[unitGUID] then
		return currentCasts[unitGUID].endTime
	end
end

local function updateFrame(casterID, spellID)
	for frame in pairs(LunaUF.Units.frameList) do
		if frame.unitGUID == casterID and LunaUF.db.profile.units[frame.unitRealType].castBar.enabled then
			if spellID then
				Cast:EventStopCast(frame, event, frame.unit, nil, spellID)
			else
				Cast:UpdateCurrentCast(frame)
			end
		end
	end
end

local function combatlogEvent()
	local _, event, _, casterID, _, _, _, targetID = CombatLogGetCurrentEventInfo()
	local spellID = select(12,CombatLogGetCurrentEventInfo())
	local name, rank, icon, castTime = GetSpellInfo(spellID)

	if interruptIDs[name] and currentCasts[targetID] then
		spellID = currentCasts[targetID].spellID
		currentCasts[targetID] = nil
		updateFrame(targetID, spellID)
		return
	end

	if event == "SPELL_CAST_FAILED" and currentCasts[casterID] then
		currentCasts[casterID] = nil
		updateFrame(casterID, spellID)
	elseif event ~= "SPELL_CAST_START" then
		return
	end

	if castTime and castTime > 0 then
		currentCasts[casterID] = {
			["spellID"] = spellID,
			["name"] = name,
			["rank"] = rank,
			["icon"] = icon,
			["castTime"] = castTime,
			["startTime"] = GetTime(),
			["endTime"] = castTime/1000 + GetTime()
		}
		updateFrame(casterID)
	end
end

function Cast:OnEnable(frame)
	if( not frame.castBar ) then
		frame.castBar = CreateFrame("Frame", nil, frame)
		frame.castBar.bar = LunaUF.Units:CreateBar(frame)
		frame.castBar.background = frame.castBar.bar.background
		frame.castBar.bar.parent = frame
		frame.castBar.bar.background = frame.castBar.background
		
		frame.castBar.icon = frame.castBar.bar:CreateTexture(nil, "ARTWORK")
	end

	if frame.unitRealType == "player" then
		frame:RegisterUnitEvent("UNIT_SPELLCAST_START", self, "EventUpdateCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self, "EventStopCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self, "EventStopCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self, "EventInterruptCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self, "EventDelayCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", self, "EventCastSucceeded")
		
		frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self, "EventUpdateChannel")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self, "EventStopCast")
		--frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_INTERRUPTED", self, "EventInterruptCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self, "EventDelayChannel")
	end

	frame:RegisterUpdateFunc(self, "UpdateCurrentCast")
end

function Cast:OnLayoutApplied(frame, config)
	if( not frame.visibility.castBar ) then return end
	
	-- Set textures
	frame.castBar.bar:SetStatusBarTexture(LunaUF.Layout:LoadMedia(SML.MediaType.STATUSBAR, LunaUF.db.profile.units[frame.unitType].castBar.statusbar))
	frame.castBar.bar:GetStatusBarTexture():SetHorizTile(false)
	frame.castBar.bar:SetStatusBarColor(0, 0, 0, 0)
	frame.castBar.background:SetVertexColor(0, 0, 0, 0)
	frame.castBar.background:SetHorizTile(false)
	
	-- Setup fill
	frame.castBar.bar:SetOrientation(config.castBar.vertical and "VERTICAL" or "HORIZONTAL")
	frame.castBar.bar:SetReverseFill(config.castBar.reverse and true or false)

	-- Setup the main bar + icon
	frame.castBar.bar:ClearAllPoints()
	frame.castBar.bar:SetHeight(frame.castBar:GetHeight())
	frame.castBar.bar:SetValue(0)
	frame.castBar.bar:SetMinMaxValues(0, 1)
	
	-- Use the entire bars width and show the icon
	if( config.castBar.icon == "HIDE" ) then
		frame.castBar.bar:SetWidth(frame.castBar:GetWidth())
		frame.castBar.bar:SetAllPoints(frame.castBar)
		frame.castBar.icon:Hide()
	-- Shift the bar to the side and show an icon
	else
		frame.castBar.bar:SetWidth(frame.castBar:GetWidth() - frame.castBar:GetHeight())
		frame.castBar.icon:ClearAllPoints()
		frame.castBar.icon:SetWidth(frame.castBar:GetHeight())
		frame.castBar.icon:SetHeight(frame.castBar:GetHeight())
		frame.castBar.icon:Show()

		if( config.castBar.icon == "LEFT" ) then
			frame.castBar.bar:SetPoint("TOPLEFT", frame.castBar, "TOPLEFT", frame.castBar:GetHeight() + 1, 0)
			frame.castBar.icon:SetPoint("TOPRIGHT", frame.castBar.bar, "TOPLEFT", -1, 0)
		else
			frame.castBar.bar:SetPoint("TOPLEFT", frame.castBar, "TOPLEFT", 1, 0)
			frame.castBar.icon:SetPoint("TOPLEFT", frame.castBar.bar, "TOPRIGHT", 0, 0)
		end
	end

	if( config.castBar.autoHide and not UnitCastingInfo(frame.unit) and not UnitChannelInfo(frame.unit) ) then
		LunaUF.Layout:SetBarVisibility(frame, "castBar", false)
	else
		LunaUF.Layout:SetBarVisibility(frame, "castBar", true)
	end
end

function Cast:OnDisable(frame, unit)
	frame:UnregisterAll(self)

	if( frame.castBar ) then
		cancelFakeCastMonitor(frame)

		frame.castBar.bar:Hide()
	end
end

-- Easy coloring
local function setBarColor(self, r, g, b)
	self.parent:SetBlockColor(self, "castBar", r, g, b)
end

-- Cast OnUpdates
local function fadeOnUpdate(self, elapsed)
	self.fadeElapsed = self.fadeElapsed - elapsed
	
	if( self.fadeElapsed <= 0 ) then
		self.fadeElapsed = nil
		self:Hide()
		
		local frame = self:GetParent()
		if( LunaUF.db.profile.units[frame.unitType].castBar.autoHide ) then
			LunaUF.Layout:SetBarVisibility(frame, "castBar", false)
		end
	else
		local alpha = self.fadeElapsed / self.fadeStart
		self:SetAlpha(alpha)
	end
end

local function castOnUpdate(self, elapsed)
	local time = GetTime()
	self.elapsed = self.elapsed + (time - self.lastUpdate)
	self.lastUpdate = time
	self:SetValue(self.elapsed)
	
	if( self.elapsed <= 0 ) then
		self.elapsed = 0
	end

	-- Cast finished, do a quick fade
	if( self.elapsed >= self.endSeconds ) then

		self.spellName = nil
		self.fadeElapsed = FADE_TIME
		self.fadeStart = FADE_TIME
		self:SetScript("OnUpdate", fadeOnUpdate)
	end
end

local function channelOnUpdate(self, elapsed)
	local time = GetTime()
	self.elapsed = self.elapsed - (time - self.lastUpdate)
	self.lastUpdate = time
	self:SetValue(self.elapsed)

	if( self.elapsed <= 0 ) then
		self.elapsed = 0
	end

	-- Channel finished, do a quick fade
	if( self.elapsed <= 0 ) then

		self.spellName = nil
		self.fadeElapsed = FADE_TIME
		self.fadeStart = FADE_TIME
		self:SetScript("OnUpdate", fadeOnUpdate)
	end
end

function Cast:UpdateCurrentCast(frame)
	if( UnitCastingInfo(frame.unit) ) then
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(frame.unit)
		self:UpdateCast(frame, frame.unit, false, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
	elseif( UnitChannelInfo(frame.unit) ) then
		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(frame.unit)
		self:UpdateCast(frame, frame.unit, true, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
	elseif currentCasts[frame.unitGUID] and currentCasts[frame.unitGUID].endTime > GetTime() and not UnitIsDeadOrGhost(frame.unit) then
		local cast = currentCasts[frame.unitGUID]
		self:UpdateCast(frame, frame.unit, false, cast.name, "", cast.icon, cast.startTime, cast.endTime, nil, nil, cast.spellID)
	else
		if( LunaUF.db.profile.units[frame.unitType].castBar.autoHide ) then
			LunaUF.Layout:SetBarVisibility(frame, "castBar", false)
		end

		setBarColor(frame.castBar.bar, 0, 0, 0)
		
		frame.castBar.bar.spellName = nil
		frame.castBar.bar:Hide()
	end
end

-- Cast updated/changed
function Cast:EventUpdateCast(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(frame.unit)
	self:UpdateCast(frame, frame.unit, false, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
end

function Cast:EventDelayCast(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(frame.unit)
	self:UpdateDelay(frame, name, text, texture, startTime, endTime)
end

-- Channel updated/changed
function Cast:EventUpdateChannel(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(frame.unit)
	self:UpdateCast(frame, frame.unit, true, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
end

function Cast:EventDelayChannel(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(frame.unit)
	self:UpdateDelay(frame, name, text, texture, startTime, endTime)
end

-- Cast finished
function Cast:EventStopCast(frame, event, unit, castID, spellID)
	local cast = frame.castBar.bar
	if( cast.spellID ~= spellID or ( event == "UNIT_SPELLCAST_FAILED" and cast.isChannelled ) ) then return end

	if( LunaUF.db.profile.units[frame.unitType].castBar.autoHide ) then
		LunaUF.Layout:SetBarVisibility(frame, "castBar", true)
	end

	cast.spellName = nil
	cast.fadeElapsed = FADE_TIME
	cast.fadeStart = FADE_TIME
	cast:SetScript("OnUpdate", fadeOnUpdate)
	cast:SetMinMaxValues(0, 1)
	cast:SetValue(1)
	cast:Show()
end

-- Cast interrupted
function Cast:EventInterruptCast(frame, event, unit, castID, spellID)
	local cast = frame.castBar.bar
	if( spellID and cast.spellID ~= spellID ) then return end
	
	if( LunaUF.db.profile.units[frame.unitType].castBar.autoHide ) then
		LunaUF.Layout:SetBarVisibility(frame, "castBar", true)
	end

	updateFrame(UnitGUID(frame.unit), spellID)
	currentCasts[UnitGUID(frame.unit)] = nil

	cast.spellID = nil
	cast.fadeElapsed = FADE_TIME + 0.20
	cast.fadeStart = cast.fadeElapsed
	cast:SetScript("OnUpdate", fadeOnUpdate)
	cast:SetMinMaxValues(0, 1)
	cast:SetValue(1)
	cast:Show()
end

-- Cast succeeded
function Cast:EventCastSucceeded(frame, unit, spell)
	local cast = frame.castBar.bar
end

function Cast:UpdateDelay(frame, spell, displayName, icon, startTime, endTime)
	if( not spell or not frame.castBar.bar.startTime ) then return end
	local cast = frame.castBar.bar
	startTime = startTime / 1000
	endTime = endTime / 1000
	
	-- For a channel, delay is a negative value so using plus is fine here
	local delay = startTime - cast.startTime
	if( not cast.isChannelled ) then
		cast.endSeconds = cast.endSeconds + delay
		cast:SetMinMaxValues(0, cast.endSeconds)
	else
		cast.elapsed = cast.elapsed + delay
	end

	cast.pushback = cast.pushback + delay
	cast.lastUpdate = GetTime()
	cast.startTime = startTime
	cast.endTime = endTime
end

-- Update the actual bar
function Cast:UpdateCast(frame, unit, channelled, spell, displayName, icon, startTime, endTime, isTradeSkill, notInterruptible, spellID)
	if( not spell ) then return end
	local cast = frame.castBar.bar
	if( LunaUF.db.profile.units[frame.unitType].castBar.autoHide ) then
		LunaUF.Layout:SetBarVisibility(frame, "castBar", true)
	end

	-- Set spell icon
	if( LunaUF.db.profile.units[frame.unitType].castBar.icon ~= "HIDE" ) then
		frame.castBar.icon:SetTexture(icon)
		frame.castBar.icon:Show()
	end
		
	-- Setup cast info
	cast.isChannelled = channelled
	cast.startTime = startTime / 1000
	cast.endTime = endTime / 1000
	cast.endSeconds = cast.endTime - cast.startTime
	cast.elapsed = cast.isChannelled and cast.endSeconds or 0
	cast.spellName = spell
	cast.spellID = spellID
	cast.pushback = 0
	cast.lastUpdate = cast.startTime
	cast:SetMinMaxValues(0, cast.endSeconds)
	cast:SetValue(cast.elapsed)
	cast:SetAlpha(1) --LunaUF.db.profile.bars.alpha)
	cast:Show()
	
	if( cast.isChannelled ) then
		cast:SetScript("OnUpdate", channelOnUpdate)
	else
		cast:SetScript("OnUpdate", castOnUpdate)
	end
	
	if( cast.isChannelled ) then
		setBarColor(cast, LunaUF.db.profile.colors.channel.r, LunaUF.db.profile.colors.channel.g, LunaUF.db.profile.colors.channel.b)
	else
		setBarColor(cast, LunaUF.db.profile.colors.cast.r, LunaUF.db.profile.colors.cast.g, LunaUF.db.profile.colors.cast.b)
	end
end

LunaUF.castMonitor = CreateFrame("Frame")
LunaUF.castMonitor:SetScript("OnEvent", combatlogEvent)
LunaUF.castMonitor:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")