--[[
Name: RosterLib-2.0
Revision: $Revision: 16213 $
X-ReleaseDate: $Date: 2006-08-10 08:55:29 +0200 (Thu, 10 Aug 2006) $
Author: Maia (maia.proudmoore@gmail.com)
Website: http://wiki.wowace.com/index.php/RosterLib-2.0
Documentation: http://wiki.wowace.com/index.php/RosterLib-2.0_API_Documentation
SVN: http://svn.wowace.com/root/trunk/RosterLib-2.0/
Description: party/raid roster management
Dependencies: AceLibrary, AceOO-2.0, AceEvent-2.0
]]

local MAJOR_VERSION = "RosterLib-2.0"
local MINOR_VERSION = "$Revision: 16213 $"

if not AceLibrary then error(vmajor .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0") end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end

local updatedUnits = {}
local unknownUnits = {}
local RosterLib = {}
local roster

------------------------------------------------
-- activate, enable, disable
------------------------------------------------

local function print(text)
	ChatFrame3:AddMessage(text)
end

local function activate(self, oldLib, oldDeactivate)
	RosterLib = self
	if oldLib then
		self.roster = oldLib.roster
		oldLib:UnregisterAllEvents()
		oldLib:CancelAllScheduledEvents()
	end
	if not self.roster then self.roster = {} end
	if oldDeactivate then oldDeactivate(oldLib) end
	roster = self.roster
end


local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		AceEvent = instance
		AceEvent:embed(self)
		self:UnregisterAllEvents()
		self:CancelAllScheduledEvents()
		if AceEvent:IsFullyInitialized() then
			self:AceEvent_FullyInitialized()
		else
			self:RegisterEvent("AceEvent_FullyInitialized", "AceEvent_FullyInitialized", true)
		end		
	elseif major == "Compost-2.0" then
		Compost = instance
	end
end


function RosterLib:Enable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end


function RosterLib:Disable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end

------------------------------------------------
-- Internal functions
------------------------------------------------

function RosterLib:AceEvent_FullyInitialized()
	self:TriggerEvent("RosterLib_Enabled")
	self:RegisterEvent("RAID_ROSTER_UPDATE","ScanFullRoster")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED","ScanFullRoster")
	self:RegisterEvent("UNIT_PET","ScanPet")
	self:ScanFullRoster()
end


------------------------------------------------
-- Unit iterator
------------------------------------------------

local playersent, petsent, unitcount, petcount, pmem, rmem, unit

local function NextUnit()
	-- STEP 1: pet
	if not petsent then
		petsent = true
		if rmem == 0 then
			unit = "pet"
			if UnitExists(unit) then return unit end
		end
	end
	-- STEP 2: player
	if not playersent then
		playersent = true
		if rmem == 0 then
			unit = "player"
			if UnitExists(unit) then return unit end
		end
	end
	-- STEP 3: raid units
	if rmem > 0 then
		-- STEP 3a: pet units
		for i = petcount, rmem do
			unit = string.format("raidpet%d", i)
			petcount = petcount + 1
			if UnitExists(unit) then return unit end
		end
		-- STEP 3b: player units
		for i = unitcount, rmem do
			unit = string.format("raid%d", i)
			unitcount = unitcount + 1
			if UnitExists(unit) then return unit end
		end
	-- STEP 4: party units
	elseif pmem > 0 then
		-- STEP 3a: pet units
		for i = petcount, pmem do
			unit = string.format("partypet%d", i)
			petcount = petcount + 1
			if UnitExists(unit) then return unit end
		end
		-- STEP 3b: player units
		for i = unitcount, pmem do
			unit = string.format("party%d", i)
			unitcount = unitcount + 1
			if UnitExists(unit) then return unit end
		end
	end
end

local function UnitIterator()
	playersent, petsent, unitcount, petcount, pmem, rmem = false, false, 1, 1, GetNumPartyMembers(), GetNumRaidMembers()
	return NextUnit
end

------------------------------------------------
-- Roster code
------------------------------------------------


function RosterLib:ScanFullRoster()
	-- save all units we currently have, this way we can check who to remove from roster later.
	local temp = Compost and Compost:Acquire() or {}
	for name in pairs(roster) do 
		temp[name] = true
	end
	-- update data
	for unitid in UnitIterator() do
		local name = self:CreateOrUpdateUnit(unitid)
		-- we successfully added a unit, so we don't need to remove it next step
		if name then temp[name] = nil end
	end
	-- clear units we had in roster that either left the raid or are unknown for some reason.
	for name in pairs(temp) do
		self:RemoveUnit(name)
	end
	if Compost then Compost:Reclaim(temp) end
	self:ProcessRoster()
end


function RosterLib:ScanPet(owner)
	local unitid = self:GetPetFromOwner(owner)
	if not unitid then
		return
	elseif not UnitExists(unitid) then
		unknownUnits[unitid] = nil
		-- find the pet in the roster we need to delete
		for _,u in pairs(roster) do
			if u.unitid == unitid then
				self:RemoveUnit(u.name)
			end
		end
	else
		self:CreateOrUpdateUnit(unitid)
	end
	self:ProcessRoster()
end


function RosterLib:GetPetFromOwner(id)
	-- convert party3 crap to raid IDs when in raid.
	local owner = self:GetUnitIDFromUnit(id)
	if not owner then
		return
	end
	-- get ID
	if string.find(owner,"raid") then
		return string.gsub(owner, "raid", "raidpet")
	elseif string.find(owner,"party") then
		return string.gsub(owner, "party", "partypet")
	elseif owner == "player" then
		return "pet"
	else
		return nil
	end
end


function RosterLib:ScanUnknownUnits()
	local name
	for unitid in pairs(unknownUnits) do 
		if UnitExists(unitid) then
			name = self:CreateOrUpdateUnit(unitid)
		else
			unknownUnits[unitid] = nil
		end
		-- some pets never have a name. too bad for them, farewell!
		if not name and string.find(unitid,"pet") then
			unknownUnits[unitid] = nil
		end
	end
	self:ProcessRoster()
end


function RosterLib:ProcessRoster()
	if next(updatedUnits, nil) then
		self:TriggerEvent("RosterLib_RosterChanged", updatedUnits)
		for name in pairs(updatedUnits) do
			local u = updatedUnits[name]
			self:TriggerEvent("RosterLib_UnitChanged", u.unitid, u.name, u.class, u.subgroup, u.rank, u.oldname, u.oldunitid, u.oldclass, u.oldsubgroup, u.oldrank)
			if Compost then Compost:Reclaim(updatedUnits[name]) end
			updatedUnits[name] = nil
		end
	end
	if next(unknownUnits, nil) then
		self:CancelScheduledEvent("ScanUnknownUnits")
		self:ScheduleEvent("ScanUnknownUnits",self.ScanUnknownUnits, 1, self)
	end
end


function RosterLib:CreateOrUpdateUnit(unitid)
	local old = nil
	-- check for name
	local name = UnitName(unitid)
	if name and name ~= UNKNOWNOBJECT and name ~= UKNOWNBEING and not UnitIsCharmed(unitid) then
		-- clear stuff
		unknownUnits[unitid] = nil
		-- return if a pet attempts to replace a player name
		-- this doesnt fix the problem with 2 pets overwriting each other FIXME
		if string.find(unitid,"pet") then
			if roster[name] and roster[name].class ~= "pet" then
				return name
			end
		end
		-- save old data if existing
		if roster[name] then
			old          = Compost and Compost:Acquire() or {}
			old.name     = roster[name].name
			old.unitid   = roster[name].unitid
			old.class    = roster[name].class
			old.rank     = roster[name].rank
			old.subgroup = roster[name].subgroup
			old.online   = roster[name].online
		end
		-- object
		if not roster[name] then
			roster[name] = Compost and Compost:Acquire() or {}
		end
		-- name
		roster[name].name = name
		-- unitid
		roster[name].unitid = unitid
		-- class
		if string.find(unitid,"pet") then
			roster[name].class = "PET"
		else
			_,roster[name].class = UnitClass(unitid)
		end
		-- subgroup and rank
		if GetNumRaidMembers() > 0 then
			local _,_,num = string.find(unitid, "(%d+)")
			_,roster[name].rank,roster[name].subgroup = GetRaidRosterInfo(num)
		else
			roster[name].subgroup = 1
			roster[name].rank = 0
		end
		-- online/offline status
		roster[name].online = UnitIsConnected(unitid)

		-- compare data
		if not old
		or roster[name].name     ~= old.name
		or roster[name].unitid   ~= old.unitid
		or roster[name].class    ~= old.class
		or roster[name].subgroup ~= old.subgroup
		or roster[name].rank     ~= old.rank
		or roster[name].online   ~= old.online
		then
			updatedUnits[name]             = Compost and Compost:Acquire() or {}
			updatedUnits[name].oldname     = (old and old.name) or nil
			updatedUnits[name].oldunitid   = (old and old.unitid) or nil
			updatedUnits[name].oldclass    = (old and old.class) or nil
			updatedUnits[name].oldsubgroup = (old and old.subgroup) or nil
			updatedUnits[name].oldrank     = (old and old.rank) or nil
			updatedUnits[name].oldonline   = (old and old.online) or nil
			updatedUnits[name].name        = roster[name].name
			updatedUnits[name].unitid      = roster[name].unitid
			updatedUnits[name].class       = roster[name].class
			updatedUnits[name].subgroup    = roster[name].subgroup
			updatedUnits[name].rank        = roster[name].rank
			updatedUnits[name].online      = roster[name].online
		end
		-- compost our table
		if old and Compost then
			Compost:Reclaim(old)
		end
		return name
	else
		unknownUnits[unitid] = true
		return false
	end
end


function RosterLib:RemoveUnit(name)
	updatedUnits[name]             = Compost and Compost:Acquire() or {}
	updatedUnits[name].oldname     = roster[name].name
	updatedUnits[name].oldunitid   = roster[name].unitid
	updatedUnits[name].oldclass    = roster[name].class
	updatedUnits[name].oldsubgroup = roster[name].subgroup
	updatedUnits[name].oldrank     = roster[name].rank
	if Compost then Compost:Reclaim(roster[name]) end
	roster[name] = nil
end


------------------------------------------------
-- API
------------------------------------------------

function RosterLib:GetUnitIDFromName(name)
	if roster[name] then
		return roster[name].unitid
	else
		return nil
	end
end


function RosterLib:GetUnitIDFromUnit(unit)
	local name = UnitName(unit)
	if name and roster[name] then
		return roster[name].unitid
	else
		return nil
	end
end


function RosterLib:GetUnitObjectFromName(name)
	if roster[name] then
		return roster[name]
	else
		return nil
	end
end


function RosterLib:GetUnitObjectFromUnit(unit)
	local name = UnitName(unit)
	if roster[name] then
		return roster[name]
	else
		return nil
	end
end


function RosterLib:IterateRoster(pets)
	local key
	return function()
		repeat
			key = next(roster, key)
		until (roster[key] == nil or pets or roster[key].class ~= "PET")

		return roster[key]
	end
end


AceLibrary:Register(RosterLib, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
