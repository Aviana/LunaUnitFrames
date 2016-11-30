local Fader = {}
LunaUF:RegisterModule(Fader, "fader", LunaUF.L["Combat fader"])

local events = {
	["UNIT_HEALTH"] = true,
	["UNIT_MANA"] = true,
	["UNIT_MAXHEALTH"] = true,
	["UNIT_MAXMANA"] = true,
}

local function OnEvent()
	local frame = this:GetParent()
	if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
		if UnitAffectingCombat("player") then
			Fader:PLAYER_REGEN_DISABLED(frame, "PLAYER_REGEN_DISABLED")
		else
			Fader:PLAYER_REGEN_ENABLED(frame, "PLAYER_REGEN_ENABLED")
		end
	elseif events[event] then
		if frame.unit == arg1 then
			Fader:Update(frame, event)
		end
	else
		Fader:Update(frame, event)
	end
end

local function faderUpdate()
	local frame = this:GetParent()
	this.timeElapsed = this.timeElapsed + arg1
	if( this.timeElapsed >= this.fadeTime ) then
		frame:SetAlpha(this.alphaEnd)
		this:Hide()
		
		if( this.fadeType == "in" ) then
			frame.DisableRangeAlpha = nil
		end
		return
	end
	
	if( this.fadeType == "in" ) then
		frame:SetAlpha((this.timeElapsed / this.fadeTime) * (this.alphaEnd - this.alphaStart) + this.alphaStart)
	else
		frame:SetAlpha(((this.fadeTime - this.timeElapsed) / this.fadeTime) * (this.alphaStart - this.alphaEnd) + this.alphaEnd)
	end
end

local function startFading(frame, type, alpha, speedyFade)
	if( frame.fader.fadeType == type ) then return end
	if( type == "out" ) then
		frame.DisableRangeAlpha = true
	end
	
	frame.fader.fadeTime = speedyFade and 0.05 or type == "in" and 0.25 or type == "out" and 0.75
	frame.fader.fadeType = type
	frame.fader.timeElapsed = 0
	frame.fader.alphaEnd = alpha
	frame.fader.alphaStart = frame:GetAlpha()
	frame.fader:Show()
end

function Fader:OnEnable(frame)
	if( not frame.fader ) then
		frame.fader = CreateFrame("Frame", nil, frame)
		frame.fader.timeElapsed = 0
		frame.fader:Hide()
	end
	frame.fader:SetScript("OnUpdate", faderUpdate)
	frame.fader:SetScript("OnEvent", OnEvent)
	frame.fader:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame.fader:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	if UnitAffectingCombat("player") then
		Fader:PLAYER_REGEN_DISABLED(frame, "PLAYER_REGEN_DISABLED")
	else
		Fader:PLAYER_REGEN_ENABLED(frame, "PLAYER_REGEN_ENABLED")
	end
end

function Fader:OnDisable(frame)
	if( frame.fader ) then
		frame.fader:UnregisterAllEvents()
		frame.fader:SetScript("OnUpdate", nil)
		frame.fader:SetScript("OnEvent", nil)
		frame:SetAlpha(1.0)
		frame.fader.fadeType = nil
		frame.fader:Hide()
		frame.DisableRangeAlpha = nil
	end
end

-- While we're in combat, we don't care about the other events so we might as well unregister them
function Fader:PLAYER_REGEN_ENABLED(frame, event)
	Fader:Update(frame, event)
	frame.fader:RegisterEvent("PLAYER_TARGET_CHANGED")
	frame.fader:RegisterEvent("UNIT_HEALTH")
	frame.fader:RegisterEvent("UNIT_MANA")
	frame.fader:RegisterEvent("UNIT_MAXHEALTH")
	frame.fader:RegisterEvent("UNIT_MAXMANA")
	frame.fader:RegisterEvent("SPELLCAST_START")
	frame.fader:RegisterEvent("SPELLCAST_STOP")
	frame.fader:RegisterEvent("SPELLCAST_CHANNEL_START")
	frame.fader:RegisterEvent("SPELLCAST_CHANNEL_STOP")
end

function Fader:PLAYER_REGEN_DISABLED(frame, event)
	Fader:Update(frame, event)
	frame.fader:UnregisterEvent("PLAYER_TARGET_CHANGED")
	frame.fader:UnregisterEvent("UNIT_HEALTH")
	frame.fader:UnregisterEvent("UNIT_MANA")
	frame.fader:UnregisterEvent("UNIT_MAXHEALTH")
	frame.fader:UnregisterEvent("UNIT_MAXMANA")
	frame.fader:UnregisterEvent("SPELLCAST_START")
	frame.fader:UnregisterEvent("SPELLCAST_STOP")
	frame.fader:UnregisterEvent("SPELLCAST_CHANNEL_START")
	frame.fader:UnregisterEvent("SPELLCAST_CHANNEL_STOP")
end

function Fader:Update(frame, event)
	-- In combat, fade back in
	if( UnitAffectingCombat("player") or event == "PLAYER_REGEN_DISABLED" ) then
		startFading(frame, "in", LunaUF.db.profile.units[frame.unitGroup].fader.combatAlpha, LunaUF.db.profile.units[frame.unitGroup].fader.speedyFade)
	-- Player is casting, fade in
	elseif( UnitIsUnit(frame.unit,"player") and frame.castBar and (frame.castBar.casting or frame.castBar.channeling) ) then
		startFading(frame, "in", LunaUF.db.profile.units[frame.unitGroup].fader.combatAlpha, true)
	-- Either mana or energy is not at 100%, fade in
	elseif( ( UnitPowerType(frame.unit) == 0 or UnitPowerType(frame.unit) == 3 ) and UnitMana(frame.unit) ~= UnitManaMax(frame.unit) ) then
		startFading(frame, "in", LunaUF.db.profile.units[frame.unitGroup].fader.combatAlpha, LunaUF.db.profile.units[frame.unitGroup].fader.speedyFade)
	-- Health is not at max, fade in
	elseif( UnitHealth(frame.unit) ~= UnitHealthMax(frame.unit) ) then
		startFading(frame, "in", LunaUF.db.profile.units[frame.unitGroup].fader.combatAlpha, LunaUF.db.profile.units[frame.unitGroup].fader.speedyFade)
	-- Targetting somebody, fade in
	elseif( UnitIsUnit(frame.unit,"player") and UnitExists("target") ) then
		startFading(frame, "in", LunaUF.db.profile.units[frame.unitGroup].fader.combatAlpha, LunaUF.db.profile.units[frame.unitGroup].fader.speedyFade)
	-- Nothing else? Fade out!
	else
		startFading(frame, "out", LunaUF.db.profile.units[frame.unitGroup].fader.inactiveAlpha, LunaUF.db.profile.units[frame.unitGroup].fader.speedyFade)
	end
end

function Fader:FullUpdate(frame)
	if( frame.fader ) then
		frame.fader.fadeType = nil
	end
end
