local Cast = {}
local L = LunaUF.L
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")
local LibCC = LibStub:GetLibrary("LibClassicCasterino")

LunaUF:RegisterModule(Cast, "castBar", L["Cast bar"], true)

local FADE_TIME = 0.30

function Cast:OnEnable(frame)
	if( not frame.castBar ) then
		frame.castBar = CreateFrame("Frame", nil, frame)
		frame.castBar.bar = LunaUF.Units:CreateBar(frame)
		frame.castBar.bar:SetFrameLevel(2)
		frame.castBar.background = frame.castBar.bar.background
		frame.castBar.bar.parent = frame
		
		frame.castBar.icon = frame.castBar.bar:CreateTexture(nil, "ARTWORK")
	end

	frame.UpdateCastBar = function(self) Cast:UpdateCurrentCast(self) end

	LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_START", "UpdateCastBar", frame)
	LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_STOP", "UpdateCastBar", frame)
	LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_FAILED", "UpdateCastBar", frame)
	LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_INTERRUPTED", "UpdateCastBar", frame)
	LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_CHANNEL_START", "UpdateCastBar", frame)
	LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_CHANNEL_STOP", "UpdateCastBar", frame)

	if frame.unitRealType == "player" then
		LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_DELAYED", "UpdateCastBar", frame) -- only for player
		LibCC.RegisterCallback(frame,"UNIT_SPELLCAST_CHANNEL_UPDATE", "UpdateCastBar", frame) -- only for player
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

	if( config.castBar.autoHide and not CastingInfo() and not ChannelInfo() ) then
		LunaUF.Layout:SetBarVisibility(frame, "castBar", false)
	else
		LunaUF.Layout:SetBarVisibility(frame, "castBar", true)
	end
end

function Cast:OnDisable(frame, unit)
	frame:UnregisterAll(self)

	if( frame.castBar ) then
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
	self.elapsed = self.elapsed + elapsed
	self.lastUpdate = time
	
	if( self.elapsed >= self.endSeconds ) then
		self.elapsed = 0
		self.endSeconds = 0
	end

	self:SetValue(self.elapsed)

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
	self.elapsed = self.elapsed - elapsed

	if( self.elapsed <= 0 ) then
		self.elapsed = 0
		self.endSeconds = 0
	end

	self:SetValue(self.elapsed)

	-- Channel finished, do a quick fade
	if( self.elapsed <= 0 ) then
		self.spellName = nil
		self.fadeElapsed = FADE_TIME
		self.fadeStart = FADE_TIME
		self:SetScript("OnUpdate", fadeOnUpdate)
	end
end

function Cast:UpdateCurrentCast(frame)
	if( LibCC:UnitCastingInfo(frame.unit) ) then
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = LibCC:UnitCastingInfo(frame.unit)
		self:UpdateCast(frame, frame.unit, false, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
	elseif( LibCC:UnitChannelInfo(frame.unit) ) then
		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = LibCC:UnitChannelInfo(frame.unit)
		self:UpdateCast(frame, frame.unit, true, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
	else
		if( LunaUF.db.profile.units[frame.unitRealType].castBar.autoHide ) then
			LunaUF.Layout:SetBarVisibility(frame, "castBar", false)
		end

		setBarColor(frame.castBar.bar, 0, 0, 0)
		
		frame.castBar.bar.spellName = nil
		frame.castBar.bar:Hide()
	end
end

-- Cast updated/changed
function Cast:EventUpdateCast(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = CastingInfo()
	self:UpdateCast(frame, frame.unit, false, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
end

function Cast:EventDelayCast(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = CastingInfo()
	self:UpdateDelay(frame, name, text, texture, startTime, endTime)
end

-- Channel updated/changed
function Cast:EventUpdateChannel(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = ChannelInfo()
	self:UpdateCast(frame, frame.unit, true, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
end

function Cast:EventDelayChannel(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = ChannelInfo()
	self:UpdateDelay(frame, name, text, texture, startTime, endTime)
end

-- Cast finished
function Cast:EventStopCast(frame, event, unit, castID, spellID)
	local cast = frame.castBar.bar
	if( (cast.spellID ~= spellID and spellID ~= nil) or ( event == "UNIT_SPELLCAST_FAILED" and cast.isChannelled ) ) then return end

	if( LunaUF.db.profile.units[frame.unitType].castBar.autoHide ) then
		LunaUF.Layout:SetBarVisibility(frame, "castBar", true)
	end

--	cast.spellName = nil
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
	if( not spell or not frame.castBar or not frame.castBar.bar.startTime ) then return end
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
	if( not spell or not frame.castBar ) then return end
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
	cast.elapsed = cast.isChannelled and (cast.endTime - GetTime()) or (GetTime() - cast.startTime)
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