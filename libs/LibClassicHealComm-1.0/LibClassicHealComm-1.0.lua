--[[
Name: LibClassicHealComm-1.0
Revision: $Revision: 14 $
Author(s): Aviana, Original by Shadowed (shadowed.wow@gmail.com)
Description: Healing communication library. This is a heavily modified clone of LibHealComm-4.0.
Dependencies: LibStub, ChatThrottleLib
]]

local major = "LibClassicHealComm-1.0"
local minor = 17
assert(LibStub, string.format("%s requires LibStub.", major))

local HealComm = LibStub:NewLibrary(major, minor)
if( not HealComm ) then return end

-- API CONSTANTS
--local ALL_DATA = 0x0f
local DIRECT_HEALS = 0x01
local CHANNEL_HEALS = 0x02
local HOT_HEALS = 0x04
--local ABSORB_SHIELDS = 0x08
local ALL_HEALS = bit.bor(DIRECT_HEALS, CHANNEL_HEALS, HOT_HEALS)
local CASTED_HEALS = bit.bor(DIRECT_HEALS, CHANNEL_HEALS)
local OVERTIME_HEALS = bit.bor(HOT_HEALS, CHANNEL_HEALS)

HealComm.ALL_HEALS, HealComm.CHANNEL_HEALS, HealComm.DIRECT_HEALS, HealComm.HOT_HEALS, HealComm.CASTED_HEALS, HealComm.ABSORB_SHIELDS, HealComm.ALL_DATA = ALL_HEALS, CHANNEL_HEALS, DIRECT_HEALS, HOT_HEALS, CASTED_HEALS, ABSORB_SHIELDS, ALL_DATA

local COMM_PREFIX = "LCHC10"
local playerGUID, playerName, playerLevel
local playerHealModifier = 1

HealComm.callbacks = HealComm.callbacks or LibStub:GetLibrary("CallbackHandler-1.0"):New(HealComm)
HealComm.spellData = HealComm.spellData or {}
HealComm.hotData = HealComm.hotData or {}
HealComm.talentData = HealComm.talentData or {}
HealComm.itemSetsData = HealComm.itemSetsData or {}
HealComm.glyphCache = HealComm.glyphCache or {}
HealComm.equippedSetCache = HealComm.equippedSetCache or {}
HealComm.guidToGroup = HealComm.guidToGroup or {}
HealComm.guidToUnit = HealComm.guidToUnit or {}
HealComm.pendingHeals = HealComm.pendingHeals or {}
HealComm.pendingHots = HealComm.pendingHots or {}
HealComm.tempPlayerList = HealComm.tempPlayerList or {}
HealComm.activePets = HealComm.activePets or {}
HealComm.activeHots = HealComm.activeHots or {}

if( not HealComm.unitToPet ) then
	HealComm.unitToPet = {["player"] = "pet"}
	for i=1, MAX_PARTY_MEMBERS do HealComm.unitToPet["party" .. i] = "partypet" .. i end
	for i=1, MAX_RAID_MEMBERS do HealComm.unitToPet["raid" .. i] = "raidpet" .. i end
end

local spellData, hotData, tempPlayerList, pendingHeals, pendingHots = HealComm.spellData, HealComm.hotData, HealComm.tempPlayerList, HealComm.pendingHeals, HealComm.pendingHots
local equippedSetCache, itemSetsData, talentData = HealComm.equippedSetCache, HealComm.itemSetsData, HealComm.talentData
local activeHots, activePets = HealComm.activeHots, HealComm.activePets

-- Figure out what they are now since a few things change based off of this
local playerClass = select(2, UnitClass("player"))
local isHealerClass = playerClass == "DRUID" or playerClass == "PRIEST" or playerClass == "SHAMAN" or playerClass == "PALADIN" or playerClass == "HUNTER"

if( not HealComm.compressGUID ) then

	HealComm.compressGUID = setmetatable({}, {
		__index = function(tbl, guid)
			local str
			if strsub(guid,1,6) ~= "Player" then
				for unit,pguid in pairs(activePets) do
					if pguid == guid then
						str = "p-" .. string.match(UnitGUID(unit), "^%w*-([-%w]*)$")
					end
				end
				if not str then
					--assert(str, "Could not encode: "..guid)
					return nil
				end
			else
				str = string.match(guid, "^%w*-([-%w]*)$")
			end
			rawset(tbl, guid, str)
			return str
	end})

	HealComm.decompressGUID = setmetatable({}, {
		__index = function(tbl, str)
			if( not str ) then return nil end
			local guid
			if strsub(str,1,2) == "p-" then
				guid = activePets[HealComm.guidToUnit["Player-"..strsub(str,3)]]
			else
				guid = "Player-"..str
			end
	
			rawset(tbl, str, guid)
			return guid
	end})

end

local compressGUID, decompressGUID = HealComm.compressGUID, HealComm.decompressGUID

-- Record management, because this is getting more complicted to deal with
local function updateRecord(pending, guid, amount, stack, endTime, ticksLeft)
	if( pending[guid] ) then
		local id = pending[guid]
		
		pending[id] = guid
		pending[id + 1] = amount
		pending[id + 2] = stack
		pending[id + 3] = endTime or 0
		pending[id + 4] = ticksLeft or 0
	else
		pending[guid] = #(pending) + 1
		table.insert(pending, guid)
		table.insert(pending, amount)
		table.insert(pending, stack)
		table.insert(pending, endTime or 0)
		table.insert(pending, ticksLeft or 0)

		if( pending.bitType == HOT_HEALS or pending.bitType == CHANNEL_HEALS ) then
			activeHots[guid] = (activeHots[guid] or 0) + 1
			HealComm.hotMonitor:Show()
		end
	end
end

local function getRecord(pending, guid)
	local id = pending[guid]
	if( not id ) then return nil end
	
	-- amount, stack, endTime, ticksLeft
	return pending[id + 1], pending[id + 2], pending[id + 3], pending[id + 4]
end

local function removeRecord(pending, guid)
	local id = pending[guid]
	if( not id ) then return nil end
	
	-- ticksLeft, endTime, stack, amount, guid
	table.remove(pending, id + 4)
	table.remove(pending, id + 3)
	table.remove(pending, id + 2)
	local amount = table.remove(pending, id + 1)
	table.remove(pending, id)
	pending[guid] = nil
	
	-- Release the table
	if( type(amount) == "table" ) then HealComm:DeleteTable(amount) end
	
	if( pending.bitType == HOT_HEALS and activeHots[guid] ) then
		activeHots[guid] = activeHots[guid] - 1
		activeHots[guid] = activeHots[guid] > 0 and activeHots[guid] or nil
	end
	
	-- Shift any records after this ones index down 5 to account for the removal
	for i=1, #(pending), 5 do
		local guid = pending[i]
		if( pending[guid] > id ) then
			pending[guid] = pending[guid] - 5
		end
	end
end

local function removeRecordList(pending, inc, comp, ...)
	for i=1, select("#", ...), inc do
		local guid = select(i, ...)
		guid = comp and decompressGUID[guid] or guid
		
		local id = pending[guid]
		-- ticksLeft, endTime, stack, amount, guid
		table.remove(pending, id + 4)
		table.remove(pending, id + 3)
		table.remove(pending, id + 2)
		local amount = table.remove(pending, id + 1)
		table.remove(pending, id)
		pending[guid] = nil

		-- Release the table
		if( type(amount) == "table" ) then HealComm:DeleteTable(amount) end
	end
	
	-- Redo all the id maps
	for i=1, #(pending), 5 do
		pending[pending[i]] = i
	end
end

-- Removes every mention to the given GUID
local function removeAllRecords(guid)
	local changed
	for _, spells in pairs(pendingHeals) do
		for _, pending in pairs(spells) do
			if( pending.bitType and pending[guid] ) then
				local id = pending[guid]
				
				-- ticksLeft, endTime, stack, amount, guid
				table.remove(pending, id + 4)
				table.remove(pending, id + 3)
				table.remove(pending, id + 2)
				local amount = table.remove(pending, id + 1)
				table.remove(pending, id)
				pending[guid] = nil
				
				-- Release the table
				if( type(amount) == "table" ) then HealComm:DeleteTable(amount) end

				-- Shift everything back
				if( #(pending) > 0 ) then
					for i=1, #(pending), 5 do
						local guid = pending[i]
						if( pending[guid] > id ) then
							pending[guid] = pending[guid] - 5
						end
					end
				else
					table.wipe(pending)
				end
				
				changed = true
			end
		end
	end
	
	for _, spells in pairs(pendingHots) do
		for _, pending in pairs(spells) do
			if( pending.bitType and pending[guid] ) then
				local id = pending[guid]
				
				-- ticksLeft, endTime, stack, amount, guid
				table.remove(pending, id + 4)
				table.remove(pending, id + 3)
				table.remove(pending, id + 2)
				local amount = table.remove(pending, id + 1)
				table.remove(pending, id)
				pending[guid] = nil
				
				-- Release the table
				if( type(amount) == "table" ) then HealComm:DeleteTable(amount) end

				-- Shift everything back
				if( #(pending) > 0 ) then
					for i=1, #(pending), 5 do
						local guid = pending[i]
						if( pending[guid] > id ) then
							pending[guid] = pending[guid] - 5
						end
					end
				else
					table.wipe(pending)
				end
				
				changed = true
			end
		end
	end
	
	activeHots[guid] = nil
	
	if( changed ) then
		HealComm.callbacks:Fire("HealComm_GUIDDisappeared", guid)
	end
end

-- These are not public APIs and are purely for the wrapper to use
HealComm.removeRecordList = removeRecordList
HealComm.removeRecord = removeRecord
HealComm.getRecord = getRecord
HealComm.updateRecord = updateRecord

-- Removes all pending heals, if it's a group that is causing the clear then we won't remove the players heals on themselves
local function clearPendingHeals()
	for casterGUID, spells in pairs(pendingHeals) do
		for _, pending in pairs(spells) do
			if( pending.bitType ) then
 				table.wipe(tempPlayerList)
				for i=#(pending), 1, -5 do table.insert(tempPlayerList, pending[i - 4]) end
				
				if( #(tempPlayerList) > 0 ) then
					local spellID, bitType = pending.spellID, pending.bitType
					table.wipe(pending)
					
					HealComm.callbacks:Fire("HealComm_HealStopped", casterGUID, spellID, bitType, true, unpack(tempPlayerList))
				end
			end
		end
	end
	for casterGUID, spells in pairs(pendingHots) do
		for _, pending in pairs(spells) do
			if( pending.bitType ) then
 				table.wipe(tempPlayerList)
				for i=#(pending), 1, -5 do table.insert(tempPlayerList, pending[i - 4]) end
				
				if( #(tempPlayerList) > 0 ) then
					local spellID, bitType = pending.spellID, pending.bitType
					table.wipe(pending)
					
					HealComm.callbacks:Fire("HealComm_HealStopped", casterGUID, spellID, bitType, true, unpack(tempPlayerList))
				end
			end
		end
	end
end

-- APIs
-- Returns the players current heaing modifier
function HealComm:GetPlayerHealingMod()
	return playerHealModifier or 1
end

-- Returns the current healing modifier for the GUID
function HealComm:GetHealModifier(guid)
	return HealComm.currentModifiers[guid] or 1
end

-- Returns whether or not the GUID has casted a heal
function HealComm:GUIDHasHealed(guid)
	return (pendingHeals[guid] or pendingHots[guid]) and true or nil
end

-- Returns the guid to unit table
function HealComm:GetGUIDUnitMapTable()
	if( not HealComm.protectedMap ) then
		HealComm.protectedMap = setmetatable({}, {
			__index = function(tbl, key) return HealComm.guidToUnit[key] end,
			__newindex = function() error("This is a read only table and cannot be modified.", 2) end,
			__metatable = false
		})
	end
	
	return HealComm.protectedMap
end

-- Gets the next heal landing on someone using the passed filters
function HealComm:GetNextHealAmount(guid, bitFlag, time, ignoreGUID)
	local healTime, healAmount, healFrom
	local currentTime = GetTime()
	
	for casterGUID, spells in pairs(pendingHeals) do
		if( not ignoreGUID or ignoreGUID ~= casterGUID ) then
			for _, pending in pairs(spells) do
				if( pending.bitType and bit.band(pending.bitType, bitFlag) > 0 ) then
					for i=1, #(pending), 5 do
						local guid = pending[i]
						local amount = pending[i + 1]
						local stack = pending[i + 2]
						local endTime = pending[i + 3]
						endTime = endTime > 0 and endTime or pending.endTime
						
						-- Direct heals are easy, if they match the filter then return them
						if( ( not time or endTime <= time ) ) then
							if( not healTime or endTime < healTime ) then
								healTime = endTime
								healAmount = amount * stack
								healFrom = casterGUID
							end
						end
					end
				end
			end
		end
	end
	for casterGUID, spells in pairs(pendingHots) do
		if( not ignoreGUID or ignoreGUID ~= casterGUID ) then
			for _, pending in pairs(spells) do
				if( pending.bitType and bit.band(pending.bitType, bitFlag) > 0 ) then
					for i=1, #(pending), 5 do
						local guid = pending[i]
						local amount = pending[i + 1]
						local stack = pending[i + 2]
						local endTime = pending[i + 3]
						endTime = endTime > 0 and endTime or pending.endTime
							
						local secondsLeft = time and time - currentTime or endTime - currentTime
						local nextTick = currentTime + (secondsLeft % pending.tickInterval)
						if( not healTime or nextTick < healTime ) then
							healTime = nextTick
							healAmount = amount[1] * stack
							healFrom = casterGUID
						end
					end
				end
			end
		end
	end
	
	return healTime, healFrom, healAmount
end

-- Get the healing amount that matches the passed filters
local function filterData(spells, filterGUID, bitFlag, time, ignoreGUID)
	local healAmount = 0
	local currentTime = GetTime()
	
	for _, pending in pairs(spells) do
		if( pending.bitType and bit.band(pending.bitType, bitFlag) > 0 ) then
			for i=1, #(pending), 5 do
				local guid = pending[i]
				if( guid == filterGUID or ignoreGUID ) then
					local amount = pending[i + 1]
					local stack = pending[i + 2]
					local endTime = pending[i + 3]
					endTime = endTime > 0 and endTime or pending.endTime

					-- Direct heals are easy, if they match the filter then return them
					if( ( pending.bitType == DIRECT_HEALS ) and ( not time or endTime <= time ) ) then
						healAmount = healAmount + amount * stack
					-- Channeled heals and hots, have to figure out how many times it'll tick within the given time band
					elseif( ( pending.bitType == HOT_HEALS or pending.bitType == CHANNEL_HEALS ) and endTime > currentTime ) then
						local ticksLeft = pending[i + 4]
						if( not time or time >= endTime ) then
							healAmount = healAmount + (amount * stack) * ticksLeft
						else
							local secondsLeft = endTime - currentTime
							local bandSeconds = time - currentTime
							local ticks = math.floor(math.min(bandSeconds, secondsLeft) / pending.tickInterval)
							local nextTickIn = secondsLeft % pending.tickInterval
							local fractionalBand = bandSeconds % pending.tickInterval
							if( nextTickIn > 0 and nextTickIn < fractionalBand ) then
								ticks = ticks + 1
							end
							
							healAmount = healAmount + (amount * stack) * math.min(ticks, ticksLeft)
						end
					end
				end
			end
		end
	end
	
	return healAmount
end

-- Gets healing amount using the passed filters
function HealComm:GetHealAmount(guid, bitFlag, time, casterGUID)
	local amount = 0
	if( casterGUID and pendingHeals[casterGUID] ) then
		amount = filterData(pendingHeals[casterGUID], guid, bitFlag, time) + filterData(pendingHots[casterGUID], guid, bitFlag, time)
	elseif( not casterGUID ) then
		for _, spells in pairs(pendingHeals) do
			amount = amount + filterData(spells, guid, bitFlag, time)
		end
		for _, spells in pairs(pendingHots) do
			amount = amount + filterData(spells, guid, bitFlag, time)
		end
	end
	
	return amount > 0 and amount or nil
end

-- Gets healing amounts for everyone except the player using the passed filters
function HealComm:GetOthersHealAmount(guid)
	local amount = 0
	for casterGUID, spells in pairs(pendingHeals) do
		if( casterGUID ~= playerGUID ) then
			amount = amount + filterData(spells, guid, bitFlag, time)
		end
	end
	for casterGUID, spells in pairs(pendingHots) do
		if( casterGUID ~= playerGUID ) then
			amount = amount + filterData(spells, guid, bitFlag, time)
		end
	end
	
	return amount > 0 and amount or nil
end

function HealComm:GetCasterHealAmount(guid)
	local amount = pendingHeals[guid] and filterData(pendingHeals[guid], nil, bitFlag, time, true) or 0
	amount = amount + (pendingHots[guid] and filterData(pendingHots[guid], nil, bitFlag, time, true) or 0)
	return amount > 0 and amount or nil
end

-- Healing class data
-- Thanks to Gagorian (DrDamage) for letting me steal his formulas and such
local playerCurrentRelic
local guidToUnit, guidToGroup, glyphCache = HealComm.guidToUnit, HealComm.guidToGroup, HealComm.glyphCache

-- UnitBuff priortizes our buffs over everyone elses when there is a name conflict, so yay for that
local function unitHasAura(unit, spellID)
	local currentID
	for i=1, 40 do
		currentID = select(10, UnitBuff(unit, i))
		if not currentID then
			return
		elseif currentID == spellID then
			return math.max(select(3, UnitBuff(unit, i)),1)
		end
	end
end

-- Note because I always forget on the order:
-- Talents that effective the coeffiency of spell power to healing are first and are tacked directly onto the coeffiency (Empowered Rejuvenation)
-- Penalty modifiers (downranking/spell level too low) are applied directly to the spell power
-- Spell power modifiers are then applied to the spell power
-- Heal modifiers are applied after all of that
-- Crit modifiers are applied after
-- Any other modifiers such as Mortal Strike or Avenging Wrath are applied after everything else
local function calculateGeneralAmount(level, amount, spellPower, spModifier, healModifier)
	-- Apply downranking penalities for spells below 20
	local penalty = level > 20 and 1 or (1 - ((20 - level) * 0.0375))
	spellPower = spellPower * penalty

	-- Do the general factoring
	return healModifier * (amount + (spellPower * spModifier))
end

-- Yes silly function, just cleaner to look at
local function avg(a, b)
	return (a + b) / 2
end

--[[
	What the different callbacks do:
	
	AuraHandler: Specific aura tracking needed for this class, who has Beacon up on them and such
	
	ResetChargeData: Due to spell "queuing" you can't always rely on aura data for buffs that last one or two casts, for example Divine Favor (+100% crit, one spell)
	if you cast Holy Light and queue Flash of Light the library would still see they have Divine Favor and give them crits on both spells. The reset means that the flag that indicates
	they have the aura can be killed and if they interrupt the cast then it will call this and let you reset the flags.
	
	What happens in terms of what the client thinks and what actually is, is something like this:
	
	UNIT_SPELLCAST_START, Holy Light -> Divine Favor up
	UNIT_SPELLCAST_SUCCEEDED, Holy Light -> Divine Favor up (But it was really used)
	UNIT_SPELLCAST_START, Flash of Light -> Divine Favor up (It's not actually up but auras didn't update)
	UNIT_AURA -> Divine Favor up (Split second where it still thinks it's up)
	UNIT_AURA -> Divine Favor faded (Client catches up and realizes it's down)
	
	CalculateHealing: Calculates the healing value, does all the formula calculations talent modifiers and such
	
	CalculateHotHealing: Used specifically for calculating the heals of hots
	
	GetHealTargets: Who the heal is going to hit, used for setting extra targets for Beacon of Light + Paladin heal or Prayer of Healing.
	The returns should either be:
	
	"compressedGUID1,compressedGUID2,compressedGUID3,compressedGUID4", healthAmount
	Or if you need to set specific healing values for one GUID it should be
	"compressedGUID1,healthAmount1,compressedGUID2,healAmount2,compressedGUID3,healAmount3", -1
	
	The latter is for cases like Glyph of Healing Wave where you need a heal for 1,000 on A and a heal for 200 on the player for B without sending 2 events.
	The -1 tells the library to look in the GUId list for the heal amounts
	
	**NOTE** Any GUID returned from GetHealTargets must be compressed through a call to compressGUID[guid]
]]

local CalculateHealing, GetHealTargets, AuraHandler, CalculateHotHealing, ResetChargeData, LoadClassData

-- DRUIDS
if( playerClass == "DRUID" ) then
	LoadClassData = function()
		-- Rejuvenation
		local Rejuvenation = GetSpellInfo(774)
		hotData[774] = {interval = 3, level = 4, average = 32}
		hotData[1058] = {interval = 3, level = 10, average = 56}
		hotData[1430] = {interval = 3, level = 16, average = 116}
		hotData[2090] = {interval = 3, level = 22, average = 180}
		hotData[2091] = {interval = 3, level = 28, average = 244}
		hotData[3627] = {interval = 3, level = 34, average = 304}
		hotData[8910] = {interval = 3, level = 40, average = 388}
		hotData[9839] = {interval = 3, level = 46, average = 488}
		hotData[9840] = {interval = 3, level = 52, average = 608}
		hotData[9841] = {interval = 3, level = 58, average = 756}
		hotData[25299] = {interval = 3, level = 60, average = 888}
		-- Regrowth (Hot)
		local Regrowth = GetSpellInfo(8936)
		hotData[8936] = {interval = 3, ticks = 7, coeff = 0.07328, level = 12, average = 98}
		hotData[8938] = {interval = 3, ticks = 7, coeff = 0.07328, level = 18, average = 175}
		hotData[8939] = {interval = 3, ticks = 7, coeff = 0.07328, level = 24, average = 259}
		hotData[8940] = {interval = 3, ticks = 7, coeff = 0.07328, level = 30, average = 343}
		hotData[8941] = {interval = 3, ticks = 7, coeff = 0.07328, level = 36, average = 427}
		hotData[9750] = {interval = 3, ticks = 7, coeff = 0.07328, level = 42, average = 546}
		hotData[9856] = {interval = 3, ticks = 7, coeff = 0.07328, level = 48, average = 686}
		hotData[9857] = {interval = 3, ticks = 7, coeff = 0.07328, level = 54, average = 861}
		hotData[9858] = {interval = 3, ticks = 7, coeff = 0.07328, level = 60, average = 1064}
		
		-- Regrowth
		spellData[8936] = { level = 12, average = avg(93, 107)}
		spellData[8938] = { level = 18, average = avg(176, 201)}
		spellData[8939] = { level = 24, average = avg(255, 290)}
		spellData[8940] = { level = 30, average = avg(336, 378)}
		spellData[8941] = { level = 36, average = avg(425, 478)}
		spellData[9750] = { level = 42, average = avg(534, 599)}
		spellData[9856] = { level = 48, average = avg(672, 751)}
		spellData[9857] = { level = 54, average = avg(833, 929)}
		spellData[9858] = { level = 60, average = avg(1003, 1119)}
		
		-- Healing Touch
		local HealingTouch = GetSpellInfo(5185)
		spellData[5185] = {coeff = 0.4286, level = 0, average = avg(40, 55)}
		spellData[5186] = {coeff = 0.5714, level = 8, average = avg(94, 119)}
		spellData[5187] = {coeff = 0.7143, level = 14, average = avg(204, 253)}
		spellData[5188] = {coeff = 0.8571, level = 20, average = avg(376, 459)}
		spellData[5189] = {coeff = 1, level = 26, average = avg(589, 712)}
		spellData[6778] = {coeff = 1, level = 32, average = avg(762, 914)}
		spellData[8903] = {coeff = 1, level = 38, average = avg(958, 1143)}
		spellData[9758] = {coeff = 1, level = 44, average = avg(1225, 1453)}
		spellData[9888] = {coeff = 1, level = 50, average = avg(1545, 1826)}
		spellData[9889] = {coeff = 1, level = 56, average = avg(1903, 2244)}
		spellData[25297] = {coeff = 1, level = 60, average = avg(2267, 2677)}
		
		-- Tranquility
		local Tranquility = GetSpellInfo(740)
		spellData[740] = {interval = 2, level = 30, ticks = 5, average = 490}
		spellData[8918] = {interval = 2, level = 40, ticks = 5, average = 710}
		spellData[9862] = {interval = 2, level = 50, ticks = 5, average = 1050}
		spellData[9863] = {interval = 2, level = 60, ticks = 5, average = 1470}
		
		-- Talent data, these are filled in later and modified on talent changes
		-- Gift of Nature (Add)
		local GiftofNature = GetSpellInfo(17104)
		talentData[GiftofNature] = {mod = 0.02, current = 0}
		-- Improved Rejuvenation (Add)
		local ImprovedRejuv = GetSpellInfo(17111)
		talentData[ImprovedRejuv] = {mod = 0.05, current = 0}
		
		local MarkoftheWild = GetSpellInfo(29166)
		
		-- Set data
		-- 8 piece, +3 seconds to Regrowth
		itemSetsData["Stormrage"] = {16903, 16898, 16904, 16897, 16900, 16899, 16901, 16902}

		GetHealTargets = function(bitType, guid, healAmount, spellID)
			local spellName = GetSpellInfo(spellID)
			-- Tranquility pulses on everyone within 30 yards, if they are in range of Mark of the Wild they'll get Tranquility
			if( spellName == Tranquility ) then
				local targets = compressGUID[playerGUID]
				local playerGroup = guidToGroup[playerGUID]
				
				for groupGUID, id in pairs(guidToGroup) do
					if( id == playerGroup and playerGUID ~= groupGUID and IsSpellInRange(MarkoftheWild, guidToUnit[groupGUID]) == 1 ) then
						targets = targets .. "," .. compressGUID[groupGUID]
					end
				end
				
				return targets, healAmount
			end
			
			return compressGUID[guid], healAmount
		end
		
		-- Calculate hot heals
		local wgTicks = {}
		CalculateHotHealing = function(guid, spellID)
			local spellName = GetSpellInfo(spellID)
			local healAmount = hotData[spellID].average
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			local totalTicks, duration, ticks
			healModifier = healModifier + talentData[GiftofNature].current
			
			-- Rejuvenation
			if( spellName == Rejuvenation ) then
				healModifier = healModifier + talentData[ImprovedRejuv].current
	
				-- 22398 - Idol of Rejuvenation, +50 SP to Rejuv
				if( playerCurrentRelic == 22398 ) then
					spellPower = spellPower + 50
				end
				
				duration = 12
				ticks = 4
				healAmount = healAmount / ticks
				
				-- Stormrage, +3 seconds
				if( equippedSetCache["Stormrage"] >= 8 ) then ticks = ticks + 1 duration = 15 end
				
				totalTicks = ticks
				spellPower = spellPower * 0.2

			-- Regrowth
			elseif( spellName == Regrowth ) then
				spellPower = spellPower * hotData[spellID].coeff
				healAmount = healAmount / hotData[spellID].ticks
				
				duration = 21
				totalTicks = 7
			end
	
			healAmount = calculateGeneralAmount(hotData[spellID].level, healAmount, spellPower, spModifier, healModifier)
			return HOT_HEALS, math.ceil(healAmount), duration
		end
		
		-- Calcualte direct and channeled heals
		CalculateHealing = function(guid, spellID)
			local spellName = GetSpellInfo(spellID)
			local healAmount = spellData[spellID].average
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			
			-- Gift of Nature
			healModifier = healModifier + talentData[GiftofNature].current
			
			-- Regrowth
			if( spellName == Regrowth ) then
				spellPower = spellPower * 0.2784
			-- Healing Touch
			elseif( spellName == HealingTouch ) then
				spellPower = spellPower * spellData[spellID].coeff
	
			-- Tranquility
			elseif( spellName == Tranquility ) then
				spellPower = spellPower * 0.3846
			end
			
			healAmount = calculateGeneralAmount(spellData[spellID].level, healAmount, spellPower, spModifier, healModifier)
			
			-- 100% chance to crit with Nature, this mostly just covers fights like Loatheb where you will basically have 100% crit
			if( GetSpellCritChance(4) >= 100 ) then
				healAmount = healAmount * 1.50
			end
			
			if( spellData[spellID].ticks ) then
				return CHANNEL_HEALS, math.ceil(healAmount / spellData[spellID].ticks), spellData[spellID].ticks, spellData[spellID].ticks
			end
			
			return DIRECT_HEALS, math.ceil(healAmount)
		end
	end
end

-- PALADINS
if( playerClass == "PALADIN" ) then
	LoadClassData = function()
		-- Spell data
		-- Holy Light
		local HolyLight = GetSpellInfo(635)
		spellData[635] = {coeff = 2.5 / 3.5, level = 0, average = avg(42, 51)}
		spellData[639] = {coeff = 2.5 / 3.5, level = 4, average = avg(81, 96)}
		spellData[647] = {coeff = 2.5 / 3.5, level = 12, average = avg(167, 196)}
		spellData[1026] = {coeff = 2.5 / 3.5, level = 22, average = avg(322, 368)}
		spellData[1042] = {coeff = 2.5 / 3.5, level = 30, average = avg(506, 569)}
		spellData[3472] = {coeff = 2.5 / 3.5, level = 38, average = avg(717, 799)}
		spellData[10328] = {coeff = 2.5 / 3.5, level = 46, average = avg(968, 1076)}
		spellData[10329] = {coeff = 2.5 / 3.5, level = 54, average = avg(1266, 1409)}
		spellData[25292] = {coeff = 2.5 / 3.5, level = 60, average = avg(1590, 1770)}
		
		-- Flash of Light
		local FlashofLight = GetSpellInfo(19750)
		spellData[19750] = {coeff = 1.5 / 3.5, level = 20, average = avg(67, 77)}
		spellData[19939] = {coeff = 1.5 / 3.5, level = 26, average = avg(102, 117)}
		spellData[19940] = {coeff = 1.5 / 3.5, level = 34, average = avg(153, 171)}
		spellData[19941] = {coeff = 1.5 / 3.5, level = 42, average = avg(206, 231)}
		spellData[19942] = {coeff = 1.5 / 3.5, level = 50, average = avg(278, 310)}
		spellData[19943] = {coeff = 1.5 / 3.5, level = 58, average = avg(343, 383)}
		
		-- Talent data
		-- Healing Light (Add)
		local HealingLight = GetSpellInfo(20237)
		talentData[HealingLight] = {mod = 0.04, current = 0}

		local flashLibrams = {[23006] = 83, [23201] = 53}
		
		local blessings = {
			[19977] = {
				[HolyLight] = 210,
				[FlashofLight] = 60,
			},
			[19978] = {
				[HolyLight] = 300,
				[FlashofLight] = 85,
			},
			[19979] = {
				[HolyLight] = 400,
				[FlashofLight] = 115,
			},
			[25890] = {
				[HolyLight] = 400,
				[FlashofLight] = 115,
			},
		}
		
		local hasDivineFavor
		AuraHandler = function(unit, guid)
			-- Check Divine Favor
			if( unit == "player" ) then
				hasDivineFavor = unitHasAura("player", 20216)
			end
		end
		
		ResetChargeData = function(guid)
			hasDivineFavor = unitHasAura("player", 20216)
		end

		GetHealTargets = function(bitType, guid, healAmount, spellID)
			return compressGUID[guid], healAmount
		end
	
		CalculateHealing = function(guid, spellID, targetUnit)
			local spellName = GetSpellInfo(spellID)
			local healAmount = spellData[spellID].average
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			
			healModifier = healModifier + talentData[HealingLight].current
			
			-- Apply extra spell power based on libram
			if( playerCurrentRelic ) then
				if( spellName == FlashofLight and flashLibrams[playerCurrentRelic] ) then
					spellPower = spellPower + flashLibrams[playerCurrentRelic]
				end
			end
			
			-- Normal calculations
			spellPower = spellPower * spellData[spellID].coeff
			
			healAmount = calculateGeneralAmount(spellData[spellID].level, healAmount, spellPower, spModifier, healModifier)
			
			for auraID, values in pairs(blessings) do
				if unitHasAura(targetUnit,auraID) then
					healAmount = calculateGeneralAmount(spellData[spellID].level, healAmount, values[spellName], 1, 1)
					break
				end
			end
			
			-- Divine Favor, 100% chance to crit
			-- ... or the player has over a 100% chance to crit with Holy spells
			if( hasDivineFavor or GetSpellCritChance(2) >= 100 ) then
				hasDivineFavor = nil
				healAmount = healAmount * 1.50
			end
			
			return DIRECT_HEALS, math.ceil(healAmount)
		end
	end
end

-- PRIESTS
if( playerClass == "PRIEST" ) then
	LoadClassData = function()
		-- Hot data
		-- Renew
		local Renew = GetSpellInfo(139)
		hotData[139] = {coeff = 1, interval = 3, ticks = 5, level = 8, average = 45}
		hotData[6074] = {coeff = 1, interval = 3, ticks = 5, level = 14, average = 100}
		hotData[6075] = {coeff = 1, interval = 3, ticks = 5, level = 20, average = 175}
		hotData[6076] = {coeff = 1, interval = 3, ticks = 5, level = 26, average = 245}
		hotData[6077] = {coeff = 1, interval = 3, ticks = 5, level = 32, average = 315}
		hotData[6078] = {coeff = 1, interval = 3, ticks = 5, level = 38, average = 400}
		hotData[10927] = {coeff = 1, interval = 3, ticks = 5, level = 44, average = 510}
		hotData[10928] = {coeff = 1, interval = 3, ticks = 5, level = 50, average = 650}
		hotData[10929] = {coeff = 1, interval = 3, ticks = 5, level = 56, average = 810}
		hotData[25315] = {coeff = 1, interval = 3, ticks = 5, level = 60, average = 970}
		
		-- Greater Heal (T2 8pc)
		local GreaterHealHot = GetSpellInfo(22009)
		hotData[22009] = {coeff = 1, interval = 3, ticks = 5, level = 32, average = 315}
		
		-- Spell data
		-- Greater Heal
		local GreaterHeal = GetSpellInfo(2060)
		spellData[2060] = {coeff = 3 / 3.5, level = 40, average = avg(924, 1039)}
		spellData[10963] = {coeff = 3 / 3.5, level = 46, average = avg(1178, 1318)}
		spellData[10964] = {coeff = 3 / 3.5, level = 52, average = avg(1470, 1642)}
		spellData[10965] = {coeff = 3 / 3.5, level = 58, average = avg(1798, 2006)}
		spellData[25314] = {coeff = 3 / 3.5, level = 60, average = avg(1966, 2194)}
		
		-- Prayer of Healing
		local PrayerofHealing = GetSpellInfo(596)
		spellData[596] = {coeff = 3 / 3.5 / 3, level = 30, average = avg(312, 333)}
		spellData[996] = {coeff = 3 / 3.5 / 3, level = 40, average = avg(458, 487)}
		spellData[10960] = {coeff = 3 / 3.5 / 3, level = 50, average = avg(673, 711)}
		spellData[10961] = {coeff = 3 / 3.5 / 3, level = 60, average = avg(939, 991)}
		spellData[25316] = {coeff = 3 / 3.5 / 3, level = 60, average = avg(1041, 1099)}
		
		-- Flash Heal
		local FlashHeal = GetSpellInfo(2061)
		spellData[2061] = {coeff = 1.5 / 3.5, level = 20, average = avg(202, 247)}
		spellData[9472] = {coeff = 1.5 / 3.5, level = 26, average = avg(269, 325)}
		spellData[9473] = {coeff = 1.5 / 3.5, level = 32, average = avg(339, 406)}
		spellData[9474] = {coeff = 1.5 / 3.5, level = 38, average = avg(414, 492)}
		spellData[10915] = {coeff = 1.5 / 3.5, level = 44, average = avg(534, 633)}
		spellData[10916] = {coeff = 1.5 / 3.5, level = 52, average = avg(662, 783)}
		spellData[10917] = {coeff = 1.5 / 3.5, level = 58, average = avg(820, 967)}
		
		-- Heal
		local Heal = GetSpellInfo(2054)
		spellData[2054] = {coeff = 3 / 3.5, level = 16, average = avg(307, 353)}
		spellData[2055] = {coeff = 3 / 3.5, level = 22, average = avg(445, 507)}
		spellData[6063] = {coeff = 3 / 3.5, level = 28, average = avg(586, 662)}
		spellData[6064] = {coeff = 3 / 3.5, level = 34, average = avg(734, 827)}
		
		-- Lesser Heal
		local LesserHeal = GetSpellInfo(2050)
		spellData[2050] = {coeff = 1.5 / 3.5, level = 0, average = avg(47, 58)}
		spellData[2052] = {coeff = 2 / 3.5, level = 4, average = avg(76, 91)}
		spellData[2053] = {coeff = 2.5 / 3.5, level = 10, average = avg(143, 165)}
		
		-- Talent data
		local SpiritualHealing = GetSpellInfo(14898)
		talentData[SpiritualHealing] = {mod = 0.02, current = 0}
		-- Improved Renew (Add)
		local ImprovedRenew = GetSpellInfo(14908)
		talentData[ImprovedRenew] = {mod = 0.05, current = 0}
		
		-- Set data
		-- 5 piece, +3 seconds to Renew
		itemSetsData["Oracle"] = {21351, 21349, 21350, 21348, 21352}
		
		GetHealTargets = function(bitType, guid, healAmount, spellID)
			local spellName = GetSpellInfo(spellID)
			if( spellName == PrayerofHealing ) then
				guid = UnitGUID("player")
				local targets = compressGUID[guid]
				local group = guidToGroup[guid]
				
				for groupGUID, id in pairs(guidToGroup) do
					local unit = guidToUnit[groupGUID]
					if( id == group and guid ~= groupGUID and CheckInteractDistance(unit, 4) ) then
						targets = targets .. "," .. compressGUID[groupGUID]
					end
				end
				
				return targets, healAmount
			end
			return compressGUID[guid], healAmount
		end

		CalculateHotHealing = function(guid, spellID)
			local spellName = GetSpellInfo(spellID)
			local healAmount = hotData[spellID].average
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			local totalTicks, duration

			healModifier = healModifier + talentData[SpiritualHealing].current

			if( spellName == Renew or spellName == GreaterHealHot ) then
				healModifier = healModifier + talentData[ImprovedRenew].current

				ticks = hotData[spellID].ticks
				duration = 15
				
				healAmount = healAmount / ticks
				
				-- Oracle, +3 seconds
				if( equippedSetCache["Oracle"] >= 5 ) then ticks = ticks + 1 duration = 18 end
				
				totalTicks = ticks
				spellPower = spellPower * 0.2
			end

			healAmount = calculateGeneralAmount(hotData[spellID].level, healAmount, spellPower, spModifier, healModifier)
			return HOT_HEALS, math.ceil(healAmount), duration
		end

		CalculateHealing = function(guid, spellID)
			local healAmount = spellData[spellID].average
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1

			healModifier = healModifier + talentData[SpiritualHealing].current

			spellPower = spellPower * spellData[spellID].coeff

			healAmount = calculateGeneralAmount(spellData[spellID].level, healAmount, spellPower, spModifier, healModifier)

			-- Player has over a 100% chance to crit with Holy spells
			if( GetSpellCritChance(2) >= 100 ) then
				healAmount = healAmount * 1.50
			end

			return DIRECT_HEALS, math.ceil(healAmount)
		end
	end
end

-- SHAMANS
if( playerClass == "SHAMAN" ) then
	LoadClassData = function()
		-- Spell data
		
		-- Chain Heal
		local ChainHeal = GetSpellInfo(1064)
		spellData[1064] = {coeff = 2.5 / 3.5, level = 40, average = avg(332, 381)}
		spellData[10622] = {coeff = 2.5 / 3.5, level = 46, average = avg(419, 479)}
		spellData[10623] = {coeff = 2.5 / 3.5, level = 54, average = avg(564, 643)}
		
		-- Healing Wave
		local HealingWave = GetSpellInfo(331)
		spellData[331] = {coeff = 1.5 / 3.5, level = 0, average = avg(36, 47)}
		spellData[332] = {coeff = 2 / 3.5, level = 6, average = avg(69, 83)}
		spellData[547] = {coeff = 2.5 / 3.5, level = 12, average = avg(136, 163)}
		spellData[913] = {coeff = 3 / 3.5, level = 18, average = avg(279, 328)}
		spellData[939] = {coeff = 3 / 3.5, level = 24, average = avg(389, 454)}
		spellData[959] = {coeff = 3 / 3.5, level = 32, average = avg(552, 639)}
		spellData[8005] = {coeff = 3 / 3.5, level = 40, average = avg(759, 874)}
		spellData[10395] = {coeff = 3 / 3.5, level = 48, average = avg(1040, 1191)}
		spellData[10396] = {coeff = 3 / 3.5, level = 56, average = avg(1378, 1572)}
		spellData[25357] = {coeff = 3 / 3.5, level = 60, average = avg(1620, 1850)}
		
		-- Lesser Healing Wave
		local LesserHealingWave = GetSpellInfo(8004)
		spellData[8004] = {coeff = 1.5 / 3.5, level = 20, average = avg(162, 186)}
		spellData[8008] = {coeff = 1.5 / 3.5, level = 28, average = avg(247, 281)}
		spellData[8010] = {coeff = 1.5 / 3.5, level = 36, average = avg(337, 381)}
		spellData[10466] = {coeff = 1.5 / 3.5, level = 44, average = avg(458, 514)}
		spellData[10467] = {coeff = 1.5 / 3.5, level = 52, average = avg(631, 705)}
		spellData[10468] = {coeff = 1.5 / 3.5, level = 60, average = avg(832, 928)}
		
		-- Talent data
		-- Purification (Add)
		local Purification = GetSpellInfo(16178)
		talentData[Purification] = {mod = 0.02, current = 0}
		
		-- Totems
		local lhwTotems = {[23200] = 53, [22396] = 80}
		
		-- Lets a specific override on how many people this will hit
		GetHealTargets = function(bitType, guid, healAmount, spellID)
			return compressGUID[guid], healAmount
		end
		
		CalculateHealing = function(guid, spellID, targetUnit)
			local spellName = GetSpellInfo(spellID)
			local healAmount = spellData[spellID].average
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			
			healModifier = healModifier + talentData[Purification].current
			
			-- Heaing Wave
			if( spellName == HealingWave ) then
				
				-- Add Healing Way
				
				local hwStacks = unitHasAura(targetUnit, 29203)
				if( hwStacks ) then
					healModifier = healModifier * ((hwStacks * 0.06) + 1)
				end
				
			-- Lesser Healing Wave
			elseif( spellName == LesserHealingWave ) then
				spellPower = spellPower + (playerCurrentRelic and lhwTotems[playerCurrentRelic] or 0)
			end
			
			spellPower = spellPower * spellData[spellID].coeff
			healAmount = calculateGeneralAmount(spellData[spellID].level, healAmount, spellPower, spModifier, healModifier)
			
			-- Player has over a 100% chance to crit with Nature spells
			if( GetSpellCritChance(4) >= 100 ) then
				healAmount = healAmount * 1.50
			end
			
			-- Apply the final modifier of any MS or self heal increasing effects
			return DIRECT_HEALS, math.ceil(healAmount)
		end
	end
end

if( playerClass == "HUNTER" ) then
	LoadClassData = function()
		-- Spell data
		
		local MendPet = GetSpellInfo(136)
		spellData[136] = {interval = 1, level = 12, ticks = 5, average = 100}
		spellData[3111] = {interval = 1, level = 20, ticks = 5, average = 190}
		spellData[3661] = {interval = 1, level = 28, ticks = 5, average = 340}
		spellData[3662] = {interval = 1, level = 36, ticks = 5, average = 515}
		spellData[13542] = {interval = 1, level = 44, ticks = 5, average = 710}
		spellData[13543] = {interval = 1, level = 52, ticks = 5, average = 945}
		spellData[13544] = {interval = 1, level = 60, ticks = 5, average = 1225}
		
		itemSetsData["Giantstalker"] = {16851, 16849, 16850, 16845, 16848, 16852, 16846, 16847}
		
		GetHealTargets = function(bitType, guid, healAmount, spellID)
			return compressGUID[UnitGUID("pet")], healAmount
		end

		CalculateHotHealing = function(guid, spellID)
			return HOT_HEALS, 0, 0
		end

		CalculateHealing = function(guid, spellID)
			local amount = spellData[spellID].average
			if( equippedSetCache["Giantstalker"] >= 3 ) then amount = amount * 1.1 end
			return CHANNEL_HEALS, math.ceil(amount / spellData[spellID].ticks), spellData[spellID].ticks, spellData[spellID].ticks
		end
	end
end

-- Healing modifiers
if( not HealComm.aurasUpdated ) then
	HealComm.aurasUpdated = true
	HealComm.healingModifiers = nil
end

HealComm.currentModifiers = HealComm.currentModifiers or {}

HealComm.healingModifiers = HealComm.healingModifiers or {
	[28776] = 0.10, -- Necrotic Poison
	[19716] = 0.25, -- Gehennas' Curse
	[24674] = 0.25, -- Veil of Shadow
	[13218] = 0.50, -- Wound Poison1
	[13222] = 0.50, -- Wound Poison2
	[13223] = 0.50, -- Wound Poison3
	[13224] = 0.50, -- Wound Poison4
	[21551] = 0.50, -- Mortal Strike
	[23169] = 0.50, -- Brood Affliction: Green
	[22859] = 0.50, -- Mortal Cleave
	[17820] = 0.25, -- Veil of Shadow
	[22687] = 0.25, -- Veil of Shadow
	[23224] = 0.25, -- Veil of Shadow
	[24674] = 0.25, -- Veil of Shadow
	[28440] = 0.25, -- Veil of Shadow
	[13583] = 0.50, -- Curse of the Deadwood
	[23230] = 0.50, -- Blood Fury
}

HealComm.healingStackMods = HealComm.healingStackMods or {
	-- Mortal Wound
	[25646] = function(stacks) return 1 - stacks * 0.10 end, 
	[28467] = function(stacks) return 1 - stacks * 0.10 end, 
}

local healingStackMods = HealComm.healingStackMods
local healingModifiers, currentModifiers = HealComm.healingModifiers, HealComm.currentModifiers

local distribution
local CTL = ChatThrottleLib
local function sendMessage(msg)
	if( distribution and string.len(msg) <= 240 ) then
		CTL:SendAddonMessage("BULK", COMM_PREFIX, msg, distribution)
	end
end

-- Keep track of where all the data should be going
local instanceType
local function updateDistributionChannel()
	local lastChannel = distribution
	if( instanceType == "pvp" or instanceType == "arena" ) then
		distribution = "BATTLEGROUND"
	elseif( UnitInRaid("player") ) then
		distribution = "RAID"
	elseif( UnitInParty("player") ) then
		distribution = "PARTY"
	else
		distribution = nil
	end

	if( distribution == lastChannel ) then return end
	
	-- If the player is not a healer, some events can be disabled until the players grouped.
	if( distribution ) then
		HealComm.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
		if( not isHealerClass ) then
			HealComm.eventFrame:RegisterEvent("UNIT_AURA")
			HealComm.eventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
			HealComm.eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
			HealComm.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	else
		HealComm.eventFrame:UnregisterEvent("CHAT_MSG_ADDON")
		if( not isHealerClass ) then
			HealComm.eventFrame:UnregisterEvent("UNIT_AURA")
			HealComm.eventFrame:UnregisterEvent("UNIT_SPELLCAST_DELAYED")
			HealComm.eventFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
			HealComm.eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end

-- Figure out where we should be sending messages and wipe some caches
function HealComm:PLAYER_ENTERING_WORLD()
	HealComm.eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	HealComm:ZONE_CHANGED_NEW_AREA()
end

function HealComm:ZONE_CHANGED_NEW_AREA()
	local type = select(2, IsInInstance())
	
	if( type ~= instanceType ) then
		instanceType = type
		
		updateDistributionChannel()
		clearPendingHeals()
		table.wipe(activeHots)
	end

	instanceType = type
end

function HealComm:UNIT_AURA(unit)
	local guid = UnitGUID(unit)
	if( not guidToUnit[guid] ) then return end
	local increase, decrease, playerIncrease, playerDecrease = 1, 1, 1, 1

	-- Scan debuffs
	id = 1
	while( true ) do
		local _, _, stack, _, _, _, _, _, _, spellID = UnitAura(unit, id, "HARMFUL")
		if( not spellID ) then break end
		
		if( healingModifiers[spellID] ) then
			decrease = math.min(decrease, healingModifiers[spellID])
		elseif( healingStackMods[spellID] ) then
			decrease = math.min(decrease, healingStackMods[spellID](stack))
		end
		
		id = id + 1
	end
	
	-- Check if modifier changed
	local modifier = increase * decrease
	if( modifier ~= currentModifiers[guid] ) then
		if( currentModifiers[guid] or modifier ~= 1 ) then
			currentModifiers[guid] = modifier
			self.callbacks:Fire("HealComm_ModifierChanged", guid, modifier)
		else
			currentModifiers[guid] = modifier
		end
	end
	
	if( unit == "player" ) then
		playerHealModifier = playerIncrease * playerDecrease
	end
	
	-- Class has a specific monitor it needs for auras
	if( AuraHandler ) then
		AuraHandler(unit, guid)
	end
end

-- Invalidate he average cache to recalculate for spells that increase in power due to leveling up (but not training new ranks)
function HealComm:PLAYER_LEVEL_UP(level)
	-- WoWProgramming says this is a string, why this is a string I do not know.
	playerLevel = tonumber(level) or UnitLevel("player")
end

-- Cache player talent data for spells we need
function HealComm:CHARACTER_POINTS_CHANGED()
	for tabIndex=1, GetNumTalentTabs() do
		for i=1, GetNumTalents(tabIndex) do
			local name, _, _, _, spent = GetTalentInfo(tabIndex, i)
			if( name and talentData[name] ) then
				talentData[name].current = talentData[name].mod * spent
				talentData[name].spent = spent
			end
		end
	end
end

-- Save the currently equipped range weapon
local RANGED_SLOT = GetInventorySlotInfo("RangedSlot")
function HealComm:PLAYER_EQUIPMENT_CHANGED()
	-- Caches set bonus info, as you can't reequip set bonus gear in combat no sense in checking it
	if( not InCombatLockdown() ) then
		for name, items in pairs(itemSetsData) do
			equippedSetCache[name] = 0
			for _, itemID in pairs(items) do
				if( IsEquippedItem(itemID) ) then
					equippedSetCache[name] = equippedSetCache[name] + 1
				end
			end
		end
	end
	
	-- Check relic
	local relic = GetInventoryItemLink("player", RANGED_SLOT)
	playerCurrentRelic = relic and tonumber(string.match(relic, "item:(%d+):")) or nil
end

-- Direct heal started
local function loadHealList(pending, amount, stack, endTime, ticksLeft, ...)
	table.wipe(tempPlayerList)
	
	-- For the sake of consistency, even a heal doesn't have multiple end times like a hot, it'll be treated as such in the DB
	if( amount ~= -1 and amount ~= "-1" ) then
		
		for i=1, select("#", ...) do
			local guid = select(i, ...)
			if( guid ) then
				updateRecord(pending, decompressGUID[guid], amount, stack, endTime, ticksLeft)
				table.insert(tempPlayerList, decompressGUID[guid])
			end
		end
	else
		for i=1, select("#", ...), 2 do
			local guid = select(i, ...)
			local amount = tonumber((select(i + 1, ...)))
			if( guid and amount ) then
				updateRecord(pending, decompressGUID[guid], amount, stack, endTime, ticksLeft)
				table.insert(tempPlayerList, decompressGUID[guid])
			end
		end
	end
end

local function parseDirectHeal(casterGUID, spellID, amount, castTime, ...)
	local unit = guidToUnit[casterGUID]
	if( not unit or not spellID or not amount or select("#", ...) == 0 ) then return end

	local endTime
	if unit == "player" then
		endTime = select(5, CastingInfo())
	else
		endTime = GetTime() + castTime
	end

	pendingHeals[casterGUID] = pendingHeals[casterGUID] or {}
	pendingHeals[casterGUID][spellID] = pendingHeals[casterGUID][spellID] or {}
	
	local pending = pendingHeals[casterGUID][spellID]
	table.wipe(pending)
	pending.endTime = endTime / 1000
	pending.spellID = spellID
	pending.bitType = DIRECT_HEALS

	loadHealList(pending, amount, 1, pending.endTime, nil, ...)

	HealComm.callbacks:Fire("HealComm_HealStarted", casterGUID, spellID, pending.bitType, pending.endTime, unpack(tempPlayerList))
end

HealComm.parseDirectHeal = parseDirectHeal

-- Channeled heal started
local function parseChannelHeal(casterGUID, spellID, amount, totalTicks, ...)
	local unit = guidToUnit[casterGUID]
	if( not unit or not spellID or not totalTicks or not amount or select("#", ...) == 0 ) then return end

	local startTime, endTime
	if unit == "player" then
		startTime, endTime = select(4, ChannelInfo())
	else
		startTime = GetTime()
		endTime = GetTime() + 10
	end

	pendingHots[casterGUID] = pendingHots[casterGUID] or {}
	pendingHots[casterGUID][spellID] = pendingHots[casterGUID][GetSpellInfo(spellID)] or {}

	local pending = pendingHots[casterGUID][GetSpellInfo(spellID)]
	table.wipe(pending)
	pending.startTime = startTime / 1000
	pending.endTime = endTime / 1000
	pending.duration = math.max(0, pending.endTime - pending.startTime)
	pending.totalTicks = totalTicks
	pending.tickInterval = playerClass == "DRUID" and 2 or 1
	pending.spellID = spellID
	pending.isMultiTarget = select("#", ...) > 1
	pending.bitType = CHANNEL_HEALS
	
	loadHealList(pending, amount, 1, pending.endTime, math.ceil(pending.duration / pending.tickInterval), ...)
	
	HealComm.callbacks:Fire("HealComm_HealStarted", casterGUID, spellID, pending.bitType, pending.endTime, unpack(tempPlayerList))
end

-- Hot heal started
-- When the person is within visible range of us, the aura is available by the time the message reaches the target
-- as such, we can rely that at least one person is going to have the aura data on them (and that it won't be different, at least for this cast)
local function findAura(casterGUID, spellID, ...)
	for i=1, select("#", ...) do
		local guid = decompressGUID[select(i, ...)]
		local unit = guid and guidToUnit[guid]
		if( unit and UnitIsVisible(unit) ) then
			local id = 1
			while( true ) do
				local _,_, stack,_, duration, endTime, caster,_,_,spell = UnitBuff(unit, id)
				if( not spell ) then break end
				
				if( spell == spellID and caster and UnitGUID(caster) == casterGUID ) then
					return (stack and stack > 0 and stack or 1), duration or 0, endTime or 0
				end

				id = id + 1
			end
		end
	end
end

local function parseHotHeal(casterGUID, wasUpdated, spellID, tickAmount, duration, ...)
	local spellName = GetSpellInfo(spellID)
	if( not tickAmount or not spellID or select("#", ...) == 0 ) then return end
	-- Retrieve the hot information
	local stack, spellDuration, endTime = findAura(casterGUID, spellID, ...)
	spellDuration = spellDuration and spellDuration > 0 and spellDuration or duration
	endTime = endTime and endTime > 0 and endTime or (GetTime() + spellDuration)
	if( not stack or not spellDuration or not endTime ) then return end

	pendingHots[casterGUID] = pendingHots[casterGUID] or {}
	pendingHots[casterGUID][spellName] = pendingHots[casterGUID][spellName] or {}
	
	local pending = pendingHots[casterGUID][spellName]
	pending.duration = duration
	pending.endTime = endTime
	pending.stack = stack
	pending.totalTicks = totalTicks
	pending.tickInterval = 3
	pending.spellID = spellID
	pending.isMutliTarget = select("#", ...) > 1
	pending.bitType = HOT_HEALS
	
	local ticksLeft = math.floor(pending.duration / 3)
	loadHealList(pending, tickAmount, stack, endTime, ticksLeft, ...)

	if( not wasUpdated ) then
		HealComm.callbacks:Fire("HealComm_HealStarted", casterGUID, spellID, pending.bitType, endTime, unpack(tempPlayerList))
	else
		HealComm.callbacks:Fire("HealComm_HealUpdated", casterGUID, spellID, pending.bitType, endTime, unpack(tempPlayerList))
	end
end

-- Heal finished
local function parseHealEnd(casterGUID, pending, checkField, spellID, interrupted, ...)
	if( not spellID or not (pendingHeals[casterGUID] or pendingHots[casterGUID]) ) then return end
	
	-- Hots use spell IDs while everything else uses spell names. Avoids naming conflicts for multi-purpose spells such as Lifebloom or Regrowth
	if( not pending ) then
		pending = checkField == "id" and pendingHots[casterGUID] and pendingHots[casterGUID][GetSpellInfo(spellID)] or checkField ~= "id" and pendingHeals[casterGUID] and pendingHeals[casterGUID][spellID]
	end
	if( not pending or not pending.bitType ) then return end
			
	table.wipe(tempPlayerList)
	
	if( select("#", ...) == 0 ) then
		for i=#(pending), 1, -5 do
			table.insert(tempPlayerList, pending[i - 4])
			removeRecord(pending, pending[i - 4])
		end
	else
		for i=1, select("#", ...) do
			local guid = decompressGUID[select(i, ...)]
			
			table.insert(tempPlayerList, guid)
			removeRecord(pending, guid)
		end
	end
	
	-- Double check and make sure we actually removed at least one person
	if( #(tempPlayerList) == 0 ) then return end

	local bitType = pending.bitType
	-- Clear data if we're done
	if( #(pending) == 0 ) then table.wipe(pending) end
	
	HealComm.callbacks:Fire("HealComm_HealStopped", casterGUID, spellID, bitType, interrupted, unpack(tempPlayerList))
end

HealComm.parseHealEnd = parseHealEnd

-- Heal delayed
local function parseHealDelayed(casterGUID, startTime, endTime, spellID)
	local pending = pendingHeals[casterGUID] and pendingHeals[casterGUID][spellID] or pendingHots[casterGUID][GetSpellInfo(spellID)]
	-- It's possible to get duplicate interrupted due to raid1 = party1, player = raid# etc etc, just block it here
	if( pending.endTime == endTime and pending.startTime == startTime ) then return end
	
	-- Casted heal
	if( pending.bitType == DIRECT_HEALS ) then
		pending.startTime = startTime
		pending.endTime = endTime
	-- Channel heal
	elseif( pending.bitType == CHANNEL_HEALS ) then
		pending.startTime = startTime
		pending.endTime = endTime
		pending.ticksLeft = math.floor((endTime - GetTime()) / 2)
	else
		return
	end

	table.wipe(tempPlayerList)
	for i=1, #(pending), 5 do
		table.insert(tempPlayerList, pending[i])
	end

	HealComm.callbacks:Fire("HealComm_HealDelayed", casterGUID, pending.spellID, pending.bitType, pending.endTime, unpack(tempPlayerList))
end

-- After checking around 150-200 messages in battlegrounds, server seems to always be passed (if they are from another server)
-- Channels use tick total because the tick interval varies by haste
-- Hots use tick interval because the total duration varies but the tick interval stays the same
function HealComm:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if( not commType or not spellID or not casterGUID ) then return end
	
	local commType, castTime, spellID, arg1, arg2, arg3 = string.split(":", message)
	local casterGUID = UnitGUID(Ambiguate(sender, "none"))
	spellID = tonumber(spellID)
	
	if( prefix ~= COMM_PREFIX or channel ~= distribution or sender == playerName ) then return end
	
	-- New direct heal - D:<castTime>:<spellID>:<amount>:target1,target2...
	if( commType == "D" and arg1 and arg2 ) then
		parseDirectHeal(casterGUID, spellID, tonumber(arg1), castTime, string.split(",", arg2))
	-- Direct or channel heal delayed - DL:<extra>:<spellID>:<start>:<end>...
	elseif( commType == "DL" and arg1 and arg2 ) then
		parseHealDelayed(casterGUID, tonumber(arg1)/1000, tonumber(arg2)/1000, spellID)
	-- New channel heal - C:<extra>:<spellID>:<amount>:<totalTicks>:target1,target2...
	elseif( commType == "C" and arg1 and arg3 ) then
		parseChannelHeal(casterGUID, spellID, tonumber(arg1), tonumber(arg2), string.split(",", arg3))
	-- New hot - H:<extra>:<spellID>:<amount>:<duration>:target1,target2...
	elseif( commType == "H" and arg1 and arg2 ) then
		parseHotHeal(casterGUID, false, spellID, tonumber(arg1), tonumber(arg2), string.split(",", arg3))
	-- Heal stopped - S:<extra>:<spellID>:<ended early: 0/1>:target1,target2...
	elseif( commType == "S" or commType == "HS" ) then
		local interrupted = arg1 == "1" and true or false
		local type = commType == "HS" and "id" or "name"
		
		if( arg2 and arg2 ~= "" ) then
			parseHealEnd(casterGUID, nil, type, spellID, interrupted, string.split(",", arg2))
		else
			parseHealEnd(casterGUID, nil, type, spellID, interrupted)
		end
	end
end

-- Bucketing reduces the number of events triggered for heals such as Tranquility that hit multiple targets
-- instead of firing 5 events * ticks it will fire 1 (maybe 2 depending on lag) events
HealComm.bucketHeals = HealComm.bucketHeals or {}
local bucketHeals = HealComm.bucketHeals
local BUCKET_FILLED = 0.30

HealComm.bucketFrame = HealComm.bucketFrame or CreateFrame("Frame")
HealComm.bucketFrame:Hide()

HealComm.bucketFrame:SetScript("OnUpdate", function(self, elapsed)
	local totalLeft = 0
	for casterGUID, spells in pairs(bucketHeals) do
		for id, data in pairs(spells) do
			if( data.timeout ) then
				data.timeout = data.timeout - elapsed
				if( data.timeout <= 0 ) then
					-- This shouldn't happen, on the offhand chance it does then don't bother sending an event
					if( #(data) == 0 or not data.spellName ) then
						table.wipe(data)
					-- We're doing a bucket for a tick heal like Tranquility or Wild Growth
					elseif( data.type == "tick" ) then
						local pending = pendingHots[casterGUID] and pendingHots[casterGUID][data.spellName]
						if( pending and pending.bitType ) then
							local endTime = select(3, getRecord(pending, data[1]))
							HealComm.callbacks:Fire("HealComm_HealUpdated", casterGUID, nil, pending.bitType, endTime, unpack(data))
						end

						table.wipe(data)
					end
				else
					totalLeft = totalLeft + 1
				end
			end
		end
	end
	
	if( totalLeft <= 0 ) then
		self:Hide()
	end
end)

-- Monitor aura changes as well as new hots being cast
local eventRegistered = {["SPELL_HEAL"] = true, ["SPELL_PERIODIC_HEAL"] = true}
if( isHealerClass ) then
	eventRegistered["SPELL_AURA_REMOVED"] = true
	eventRegistered["SPELL_AURA_APPLIED"] = true
	eventRegistered["SPELL_AURA_REFRESH"] = true
end

local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
function HealComm:COMBAT_LOG_EVENT_UNFILTERED()
	local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, _, spellName, spellSchool, auraType = CombatLogGetCurrentEventInfo()
	local spellID = select(7,GetSpellInfo(spellName))
	if( not eventRegistered[eventType] ) then return end
	-- Heal or hot ticked that the library is tracking
	-- It's more efficient/accurate to have the library keep track of this locally, spamming the comm channel would not be a very good thing especially when a single player can have 4 - 8 hots/channels going on them.
	if( eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" ) then
		local pending  = sourceGUID and pendingHots[sourceGUID] and pendingHots[sourceGUID][spellName]
		if( pending and pending[destGUID] and pending.bitType and bit.band(pending.bitType, OVERTIME_HEALS) > 0 ) then
			local amount, stack, endTime, ticksLeft = getRecord(pending, destGUID)
			ticksLeft = math.max(ticksLeft - 1, 0)
			
			updateRecord(pending, destGUID, amount, stack, endTime, ticksLeft)
			
			if( pending.isMultiTarget ) then
				bucketHeals[sourceGUID] = bucketHeals[sourceGUID] or {}
				bucketHeals[sourceGUID][spellName] = bucketHeals[sourceGUID][spellName] or {}
				
				local spellBucket = bucketHeals[sourceGUID][spellName]
				if( not spellBucket[destGUID] ) then
					spellBucket.timeout = BUCKET_FILLED
					spellBucket.type = "tick"
					spellBucket.spellName = spellName
					spellBucket[destGUID] = true
					table.insert(spellBucket, destGUID)
					
					self.bucketFrame:Show()
				end
			else
				HealComm.callbacks:Fire("HealComm_HealUpdated", sourceGUID, nil, pending.bitType, endTime, destGUID)
			end
		end

	-- New hot was applied
	elseif( ( eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH" or eventType == "SPELL_AURA_APPLIED_DOSE" ) and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
		if( hotData[spellID] and guidToUnit[destGUID] ) then
			-- Single target so we can just send it off now thankfully
			local type, amount, duration = CalculateHotHealing(destGUID, spellID)
			if( type ) then
				local targets, amount = GetHealTargets(type, destGUID, math.max(amount, 0), spellName)
				parseHotHeal(sourceGUID, false, spellID, amount, duration, string.split(",", targets))
				sendMessage(string.format("H::%d:%d::%d:%s", spellID, amount, duration, targets))
			end
		end
	-- Aura faded		
	elseif( eventType == "SPELL_AURA_REMOVED" ) then
		
		-- Hot faded that we cast 
		if( hotData[spellID] and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
			parseHealEnd(sourceGUID, nil, "id", spellID, false, compressGUID[destGUID])
			if compressGUID[destGUID] then
				sendMessage(string.format("HS::%d::%s", spellID, compressGUID[destGUID]))
			end
		end
	end
end

-- Spell cast magic
-- When auto self cast is on, the UNIT_SPELLCAST_SENT event will always come first followed by the funciton calls
-- Otherwise either SENT comes first then function calls, or some function calls then SENT then more function calls
local castTarget, castID, mouseoverGUID, mouseoverName, hadTargetingCursor, lastSentID, lastTargetGUID, lastTargetName
local lastFriendlyGUID, lastFriendlyName, lastGUID, lastName, lastIsFriend
local castGUIDs, guidPriorities = {}, {}

-- Deals with the fact that functions are called differently
-- Why a table when you can only cast one spell at a time you ask? When you factor in lag and mash clicking it's possible to:
-- cast A, interrupt it, cast B and have A fire SUCEEDED before B does, the tables keeps it from bugging out
local function setCastData(priority, name, guid)
	if( not guid or not lastSentID ) then return end
	if( guidPriorities[lastSentID] and guidPriorities[lastSentID] >= priority ) then return end
	
	-- This is meant as a way of locking a cast in because which function has accurate data can be called into question at times, one of them always does though
	-- this means that as soon as it finds a name match it locks the GUID in until another SENT is fired. Technically it's possible to get a bad GUID but it first requires
	-- the functions to return different data and it requires the messed up call to be for another name conflict.
	if( castTarget and castTarget == name ) then priority = 99 end
	
	castGUIDs[lastSentID] = guid
	guidPriorities[lastSentID] = priority
end

function HealComm:UNIT_SPELLCAST_SENT(casterUnit, targetName, castGUID, spellID)
	if( casterUnit ~= "player" or not spellData[spellID] ) then return end
	
	targetName = targetName or UnitName("player")
	
	castTarget = string.gsub(targetName, "(.-)%-(.*)$", "%1")
	lastSentID = spellID
	
	-- Self cast is off which means it's possible to have a spell waiting for a target.
	-- It's possible that it's the mouseover unit, but if a Target, TargetLast or AssistUnit call comes right after it means it's casting on that instead instead.
	if( hadTargetingCursor ) then
		hadTargetingCursor = nil
		self.resetFrame:Show()
		
		guidPriorities[lastSentID] = nil
		setCastData(5, mouseoverName, mouseoverGUID)
	else
		-- If the player is ungrouped and healing, you can't take advantage of the name -> "unit" map, look in the UnitIDs that would most likely contain the information that's needed.
		local guid = UnitGUID(targetName)
		if( not guid ) then
			guid = UnitName("target") == castTarget and UnitGUID("target") or UnitName("mouseover") == castTarget and UnitGUID("mouseover") or UnitName("targettarget") == castTarget and UnitGUID("target")
		end
		
		guidPriorities[lastSentID] = nil
		setCastData(0, nil, guid)
	end
end

function HealComm:UNIT_SPELLCAST_START(casterUnit, cast, spellID)
	if( casterUnit ~= "player" or not spellData[spellID] or UnitIsCharmed("player") or not UnitPlayerControlled("player") ) then return end
	local castGUID = castGUIDs[spellID]
	if( not castGUID or not guidToUnit[castGUID] ) then
		return
	end

	castID = spellID

	-- Figure out who we are healing and for how much
	local type, amount, ticks, localTicks = CalculateHealing(castGUID, spellID, guidToUnit[castGUID])
	local targets, amount = GetHealTargets(type, castGUID, math.max(amount, 0), spellID)

	local startTime, endTime = select(4,CastingInfo())

	if( type == DIRECT_HEALS ) then
		parseDirectHeal(playerGUID, spellID, amount, (endTime - startTime) / 1000, string.split(",", targets))
		sendMessage(string.format("D:%d:%d:%d:%s", (endTime - startTime) / 1000, spellID or 0, amount or "", targets))
	elseif( type == CHANNEL_HEALS ) then
		parseChannelHeal(playerGUID, spellID, amount, localTicks, string.split(",", targets))
		sendMessage(string.format("C::%d:%d:%s:%s", spellID or 0, amount, ticks, targets))
	end
end

HealComm.UNIT_SPELLCAST_CHANNEL_START = HealComm.UNIT_SPELLCAST_START

function HealComm:UNIT_SPELLCAST_SUCCEEDED(casterUnit, castGUID, spellID)
	if( casterUnit ~= "player" or not spellData[spellID] or spellID ~= castID or spellID == 0 ) then return end
	castID = nil

	parseHealEnd(playerGUID, nil, "name", spellID, false)
	sendMessage(string.format("S::%d:0", spellID))
end

function HealComm:UNIT_SPELLCAST_STOP(casterUnit, castGUID, spellID)
	if( casterUnit ~= "player" or not spellData[spellID] or spellID ~= castID ) then return end
	
	castID = nil
	parseHealEnd(playerGUID, nil, "name", spellID, true)
	sendMessage(string.format("S::%d:1", spellID))
end

function HealComm:UNIT_SPELLCAST_CHANNEL_STOP(casterUnit, castGUID, spellID)
	if( casterUnit ~= "player" or not spellData[spellID] or spellID ~= castID ) then return end

	castID = nil
	parseHealEnd(playerGUID, nil, "name", spellID, false)
	sendMessage(string.format("S::%d:0", spellID))
end

function HealComm:UNIT_SPELLCAST_INTERRUPTED(casterUnit, castGUID, spellID)
	if( casterUnit ~= "player" or not spellData[spellID] or castID ~= spellID ) then return end
	
	local guid = castGUIDs[spellID]
	if( guid ) then
		ResetChargeData(guid, spellID)
	end
end

function HealComm:UNIT_SPELLCAST_DELAYED(casterUnit, castGUID, spellID)
	if( not pendingHeals[playerGUID] or not pendingHeals[playerGUID][spellID] ) then return end
	
	-- Direct heal delayed
	if( pendingHeals[playerGUID][spellID].bitType == DIRECT_HEALS ) then
		local startTime, endTime = select(4, CastingInfo())
		if( startTime and endTime ) then
			parseHealDelayed(playerGUID, startTime / 1000, endTime / 1000, spellID)
			sendMessage(string.format("DL::%d:%d:%d", spellID or 0, startTime, endTime))
		end
	elseif( pendingHeals[playerGUID][spellID].bitType == CHANNEL_HEALS ) then
		local startTime, endTime = select(4, ChannelInfo())
		if( startTime and endTime ) then
			parseHealDelayed(playerGUID, startTime / 1000, endTime / 1000, spellID)
			sendMessage(string.format("DL::%d:%d:%d", spellID or 0, startTime, endTime))
		end
	end
end

HealComm.UNIT_SPELLCAST_CHANNEL_UPDATE = HealComm.UNIT_SPELLCAST_DELAYED

-- Need to keep track of mouseover as it can change in the split second after/before casts
function HealComm:UPDATE_MOUSEOVER_UNIT()
	mouseoverGUID = UnitCanAssist("player", "mouseover") and UnitGUID("mouseover")
	mouseoverName = UnitCanAssist("player", "mouseover") and UnitName("mouseover")
end

-- Keep track of our last target/friendly target for the sake of /targetlast and /targetlastfriend
function HealComm:PLAYER_TARGET_CHANGED()
	if( lastGUID and lastName ) then
		if( lastIsFriend ) then
			lastFriendlyGUID, lastFriendlyName = lastGUID, lastName
		end
		
		lastTargetGUID, lastTargetName = lastGUID, lastName
	end
	
	-- Despite the fact that it's called target last friend, UnitIsFriend won't actually work
	lastGUID = UnitGUID("target")
	lastName = UnitName("target")
	lastIsFriend = UnitCanAssist("player", "target")
end

-- Unit was targeted through a function
function HealComm:Target(unit)
	if( self.resetFrame:IsShown() and UnitCanAssist("player", unit) ) then
		setCastData(6, UnitName(unit), UnitGUID(unit))
	end

	self.resetFrame:Hide()
end

-- This is only needed when auto self cast is off, in which case this is called right after UNIT_SPELLCAST_SENT
-- because the player got a waiting-for-cast icon up and they pressed a key binding to target someone
HealComm.TargetUnit = HealComm.Target

-- Works the same as the above except it's called when you have a cursor icon and you click on a secure frame with a target attribute set
HealComm.SpellTargetUnit = HealComm.Target

-- Used in /assist macros
function HealComm:AssistUnit(unit)
	if( self.resetFrame:IsShown() and UnitCanAssist("player", unit .. "target") ) then
		setCastData(6, UnitName(unit .. "target"), UnitGUID(unit .. "target"))
	end
	
	self.resetFrame:Hide()
end

-- Target last was used, the only reason this is called with reset frame being shown is we're casting on a valid unit
-- don't have to worry about the GUID no longer being invalid etc
function HealComm:TargetLast(guid, name)
	if( name and guid and self.resetFrame:IsShown() ) then
		setCastData(6, name, guid) 
	end
	
	self.resetFrame:Hide()
end

function HealComm:TargetLastFriend()
	self:TargetLast(lastFriendlyGUID, lastFriendlyName)
end

function HealComm:TargetLastTarget()
	self:TargetLast(lastTargetGUID, lastTargetName)
end

-- Spell was cast somehow
function HealComm:CastSpell(arg, unit)
	-- If the spell is waiting for a target and it's a spell action button then we know that the GUID has to be mouseover or a key binding cast.
	if( unit and UnitCanAssist("player", unit)  ) then
		setCastData(4, UnitName(unit), UnitGUID(unit))
	-- No unit, or it's a unit we can't assist 
	elseif( not SpellIsTargeting() ) then
		if( UnitCanAssist("player", "target") ) then
			setCastData(4, UnitName("target"), UnitGUID("target"))
		else
			setCastData(4, playerName, playerGUID)
		end
	end
end

HealComm.CastSpellByName = HealComm.CastSpell
HealComm.CastSpellByID = HealComm.CastSpell
HealComm.UseAction = HealComm.CastSpell

-- Make sure we don't have invalid units in this
local function sanityCheckMapping()
	for guid, unit in pairs(guidToUnit) do
		-- Unit no longer exists, remove all healing for them
		if( not UnitExists(unit) ) then
			-- Check for (and remove) any active heals
			if( pendingHeals[guid] ) then
				for id, pending in pairs(pendingHeals[guid]) do
					if( pending.bitType ) then
						parseHealEnd(guid, pending, nil, pending.spellID, true)
					end
				end
				
				pendingHeals[guid] = nil
			end
			
			if( pendingHots[guid] ) then
				for id, pending in pairs(pendingHots[guid]) do
					if( pending.bitType ) then
						parseHealEnd(guid, pending, nil, pending.spellID, true)
					end
				end
				
				pendingHots[guid] = nil
			end
			
			-- Remove any heals that are on them
			removeAllRecords(guid)
		
			guidToUnit[guid] = nil
			guidToGroup[guid] = nil
		end
	end
end

-- 5s poll that tries to solve the problem of X running out of range while a HoT is ticking
-- this is not really perfect far from it in fact. If I can find a better solution I will switch to that.
if( not HealComm.hotMonitor ) then
	HealComm.hotMonitor = CreateFrame("Frame")
	HealComm.hotMonitor:Hide()
	HealComm.hotMonitor.timeElapsed = 0
	HealComm.hotMonitor:SetScript("OnUpdate", function(self, elapsed)
		self.timeElapsed = self.timeElapsed + elapsed
		if( self.timeElapsed < 5 ) then return end
		self.timeElapsed = self.timeElapsed - 5
		
		-- For the time being, it will only remove them if they don't exist and it found a valid unit
		-- units that leave the raid are automatically removed 
		local found
		for guid in pairs(activeHots) do
			if( guidToUnit[guid] and not UnitIsVisible(guidToUnit[guid]) ) then
				removeAllRecords(guid)
			else
				found = true
			end
		end
		
		if( not found ) then
			self:Hide()
		end
	end)
end

-- After the player leaves a group, tables are wiped out or released for GC
local wasInParty, wasInRaid
local function clearGUIDData()
	clearPendingHeals()
	
	table.wipe(compressGUID)
	table.wipe(decompressGUID)
	table.wipe(activePets)
	
	playerGUID = playerGUID or UnitGUID("player")
	HealComm.guidToUnit = {[playerGUID] = "player"}
	guidToUnit = HealComm.guidToUnit
	
	HealComm.guidToGroup = {}
	guidToGroup = HealComm.guidToGroup
	
	HealComm.activeHots = {}
	activeHots = HealComm.activeHots
	
	HealComm.pendingHeals = {}
	pendingHeals = HealComm.pendingHeals
	
	HealComm.pendingHots = {}
	pendingHots = HealComm.pendingHots
	
	HealComm.bucketHeals = {}
	bucketHeals = HealComm.bucketHeals
	
	wasInParty, wasInRaid = nil, nil
end

-- Keeps track of pet GUIDs, as pets are considered vehicles this will also map vehicle GUIDs to unit
function HealComm:UNIT_PET(unit)
	local pet = self.unitToPet[unit]
	local guid = pet and UnitGUID(pet)
	
	-- We have an active pet guid from this user and it's different, kill it
	local activeGUID = activePets[unit]
	if( activeGUID and activeGUID ~= guid ) then
		removeAllRecords(activeGUID)

		guidToUnit[activeGUID] = nil
		guidToGroup[activeGUID] = nil
		activePets[unit] = nil
	end

	-- Add the new record
	if( guid ) then
		guidToUnit[guid] = pet
		guidToGroup[guid] = guidToGroup[UnitGUID(unit)]
		activePets[unit] = guid
	end
end

-- Keep track of party GUIDs, ignored in raids as RRU will handle that mapping
function HealComm:GROUP_ROSTER_UPDATE()
	updateDistributionChannel()
	
	if( not (UnitInParty("player") or UnitInRaid("player")) )  then
		if( wasInParty or wasInRaid ) then
			clearGUIDData()
		end
		return
	end
	
	if UnitInParty("player") then
	
		-- Parties are not considered groups in terms of API, so fake it and pretend they are all in group 0
		guidToGroup[playerGUID or UnitGUID("player")] = 0
		if( not wasInParty ) then self:UNIT_PET("player") end
		
		for i=1, MAX_PARTY_MEMBERS do
			local unit = "party" .. i
			if( UnitExists(unit) ) then
				local lastGroup = guidToGroup[guid]
				local guid = UnitGUID(unit)
				guidToUnit[guid] = unit
				guidToGroup[guid] = 0
				
				if( not wasInParty or lastGroup ~= guidToGroup[guid] ) then
					self:UNIT_PET(unit)
				end
			end
		end

		wasInParty = true
	end
	if UnitInRaid("player") then
		
		-- Add new members
		for i=1, MAX_RAID_MEMBERS do
			local unit = "raid" .. i
			if( UnitExists(unit) ) then
				local lastGroup = guidToGroup[guid]
				local guid = UnitGUID(unit)
				guidToUnit[guid] = unit
				guidToGroup[guid] = select(3, GetRaidRosterInfo(i))
				
				-- If the pets owners group changed then the pets group should be updated too
				if( not wasInRaid or guidToGroup[guid] ~= lastGroup ) then
					self:UNIT_PET(unit)
				end
			end
		end
		
		wasInRaid = true
	end
	
	sanityCheckMapping()
end

-- PLAYER_ALIVE = got talent data
function HealComm:PLAYER_ALIVE()
	self:PLAYER_TALENT_UPDATE()
	self.eventFrame:UnregisterEvent("PLAYER_ALIVE")
end

-- Initialize the library
function HealComm:OnInitialize()
	-- If another instance already loaded then the tables should be wiped to prevent old data from persisting
	-- in case of a spell being removed later on, only can happen if a newer LoD version is loaded
	table.wipe(spellData)
	table.wipe(hotData)
	table.wipe(itemSetsData)
	table.wipe(talentData)

	-- Load all of the classes formulas and such
	LoadClassData()
	
	clearGUIDData()
	
	self:PLAYER_EQUIPMENT_CHANGED()
	
	self:GROUP_ROSTER_UPDATE()
	
	-- When first logging in talent data isn't available until at least PLAYER_ALIVE, so if we don't have data
	-- will wait for that event otherwise will just cache it right now
	if( GetNumTalentTabs() == 0 ) then
		self.eventFrame:RegisterEvent("PLAYER_ALIVE")
	else
		self:CHARACTER_POINTS_CHANGED()
	end
	
	if( ResetChargeData ) then
		HealComm.eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	end
	
	-- Finally, register it all
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self.eventFrame:RegisterEvent("UNIT_PET")
	self.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self.eventFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
	self.eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	self.eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self.eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
	self.eventFrame:RegisterEvent("UNIT_AURA")
	
	if( self.initialized ) then return end
	self.initialized = true

	self.resetFrame = CreateFrame("Frame")
	self.resetFrame:Hide()
	self.resetFrame:SetScript("OnUpdate", function(self) self:Hide() end)

	-- You can't unhook secure hooks after they are done, so will hook once and the HealComm table will update with the latest functions
	-- automagically. If a new function is ever used it'll need a specific variable to indicate those set of hooks.
	-- By default most of these are mapped to a more generic function, but I call separate ones so I don't have to rehook
	-- if it turns out I need to know something specific
	hooksecurefunc("TargetUnit", function(...) HealComm:TargetUnit(...) end)
	hooksecurefunc("SpellTargetUnit", function(...) HealComm:SpellTargetUnit(...) end)
	hooksecurefunc("AssistUnit", function(...) HealComm:AssistUnit(...) end)
	hooksecurefunc("UseAction", function(...) HealComm:UseAction(...) end)
	hooksecurefunc("TargetLastFriend", function(...) HealComm:TargetLastFriend(...) end)
	hooksecurefunc("TargetLastTarget", function(...) HealComm:TargetLastTarget(...) end)
	hooksecurefunc("CastSpellByName", function(...) HealComm:CastSpellByName(...) end)
	hooksecurefunc("CastSpellByID", function(...) HealComm:CastSpellByID(...) end)

end

-- General event handler
local function OnEvent(self, event, ...)
	HealComm[event](HealComm, ...)
end

-- Event handler
HealComm.eventFrame = HealComm.eventFrame or CreateFrame("Frame")
HealComm.eventFrame:UnregisterAllEvents()
HealComm.eventFrame:SetScript("OnEvent", OnEvent)

-- At PLAYER_LEAVING_WORLD (Actually more like MIRROR_TIMER_STOP but anyway) UnitGUID("player") returns nil, delay registering
-- events and set a playerGUID/playerName combo for all players on PLAYER_LOGIN not just the healers.
function HealComm:PLAYER_LOGIN()
	playerGUID = UnitGUID("player")
	playerName = UnitName("player")
	playerLevel = UnitLevel("player")
	
	-- Oddly enough player GUID is not available on file load, so keep the map of player GUID to themselves too
	guidToUnit[playerGUID] = "player"

	if( isHealerClass ) then
		self:OnInitialize()
	end

	self.eventFrame:UnregisterEvent("PLAYER_LOGIN")
	self.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
--	self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	self:ZONE_CHANGED_NEW_AREA()
	C_ChatInfo.RegisterAddonMessagePrefix(COMM_PREFIX)
end

if( not IsLoggedIn() ) then
	HealComm.eventFrame:RegisterEvent("PLAYER_LOGIN")
else
	HealComm:PLAYER_LOGIN()
end