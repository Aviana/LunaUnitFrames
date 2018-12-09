-- A library that sends needed info through the addon channel to allow for accurate healing predictions.

local major = "ClassicHealComm-1.0"
local minor = 1

assert(LibStub, format("%s requires LibStub.", major))

local Lib = LibStub:NewLibrary(major, minor)
if not Lib then return end

if not Lib.eventFrame then
	Lib.eventFrame = CreateFrame("Frame")
end

Lib.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
--UNIT_SPELLCAST_START, self, event, unit
--COMBAT_LOG_EVENT_UNFILTERED, nil
--UNIT_SPELLCAST_SENT, self, event, unit, targetName, spellGUID, spellID

local function OnEvent(...)
	--print(CombatLogGetCurrentEventInfo())

	--if unit ~= "player" then return end
	local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, arg1, arg2, arg3, arg4 = CombatLogGetCurrentEventInfo()
	if eventType ~= "SPELL_CAST_START" then return end
	--print(CombatLogGetCurrentEventInfo())
	local _, rank, icon, castTime, minRange, maxRange, _ = GetSpellInfo(spellID)
	--local castName, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("player") --No channeled heals in classic
	--if castName ~= spellName then return end
	--ChatFrame1:AddMessage((sourceName or "Unknown").." casting "..spellName..": ["..((endTime-startTime)/1000).." sec] on "..destGUID)
	print(sourceName.." casting "..spellName.." ["..(castTime/1000).." sec]")
end

Lib.eventFrame:SetScript("OnEvent", OnEvent)