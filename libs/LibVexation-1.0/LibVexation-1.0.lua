--[[
Name: LibVexation-1.0
Revision: $Revision: 1 $
Author(s): Aviana, Original by Rabbit (rabbit.magtheridon@gmail.com), maia
Description: Aggro notification library. This is a modified clone of LibBanzai-2.0. The purpose is to avoid conflicts for now and this will later be replaced by an official successor of LibBanzai.
Dependencies: LibStub
]]

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local MAJOR_VERSION = "LibVexation-1.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1 $"):match("(%d+)"))

if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

lib.callbacks = lib.callbacks or {}
local callbacks = lib.callbacks
lib.frame = lib.frame or CreateFrame("Frame")
local frame = lib.frame

local _G = _G
local UnitExists = _G.UnitExists
local UnitName = _G.UnitName
local UnitCanAttack = _G.UnitCanAttack
local IsInRaid = _G.IsInRaid
local IsInGroup = _G.IsInGroup
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetNumSubgroupMembers = _G.GetNumSubgroupMembers
local unpack = _G.unpack

-------------------------------------------------------------------------------
-- Roster
-------------------------------------------------------------------------------

local raidUnits = setmetatable({}, {__index =
	function(self, key)
		self[key] = ("raid%d"):format(key)
		return self[key]
	end
})
local raidPetUnits = setmetatable({}, {__index =
	function(self, key)
		self[key] = ("raidpet%d"):format(key)
		return self[key]
	end
})
local partyUnits = {"party1","party2","party3","party4"}
local partyPetUnits = {"partypet1","partypet2","partypet3","partypet4"}
local roster = {}
local needsUpdate = nil

local function addUnit(unit)
	if not UnitExists(unit) then return end
	local GUID = UnitGUID(unit)
	if not roster[GUID] then roster[GUID] = {} end
	roster[GUID][#roster[GUID] + 1] = unit
end

local function actuallyUpdateRoster()
	wipe(roster)
	addUnit("player")
	addUnit("pet")
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			addUnit(raidUnits[i])
			addUnit(raidPetUnits[i])
		end
	elseif IsInGroup() then
		for i = 1, GetNumSubgroupMembers() do
			addUnit(partyUnits[i])
			addUnit(partyPetUnits[i])
		end
	end
	needsUpdate = nil
end

local function updateRoster()
	needsUpdate = true
end

-------------------------------------------------------------------------------
-- Vexation
-------------------------------------------------------------------------------

local targets = setmetatable({}, {__index =
	function(self, key)
		self[key] = key .. "target"
		return self[key]
	end
})

local aggro = {}
local vexation = {}

local total = 0
local function updateVexation(_, elapsed)
	total = total + elapsed
	if total > 0.2 then
		if needsUpdate then actuallyUpdateRoster() end
		for GUID, units in pairs(roster) do
			local unit = units[1]
			local targetId = targets[unit]
			if UnitExists(targetId) then
				local ttId = targets[targetId]
				if unit == "focus" and UnitIsEnemy("focus", "player") then
					ttId = "focustarget"
					targetId = "focus"
				end
				if UnitExists(ttId) and UnitCanAttack(ttId, targetId) then
					for n, u in pairs(roster) do
						if UnitIsUnit(u[1], ttId) then
							vexation[n] = (vexation[n] or 0) + 10
							break
						end
					end
				end
			end
			if vexation[GUID] then
				if vexation[GUID] >= 5 then vexation[GUID] = vexation[GUID] - 5 end
				if vexation[GUID] > 25 then vexation[GUID] = 25 end
			end
		end
		for GUID, units in pairs(roster) do
			if vexation[GUID] and vexation[GUID] > 15 then
				if not aggro[GUID] then
					aggro[GUID] = true
					for i, v in next, callbacks do
						v(1, GUID, unpack(units))
					end
				end
			elseif aggro[GUID] then
				aggro[GUID] = nil
				for i, v in next, callbacks do
					v(0, GUID, unpack(units))
				end
			end
		end
		total = 0
	end
end

-------------------------------------------------------------------------------
-- Starting and stopping
-------------------------------------------------------------------------------

local running = nil
local function start()
	if running then return end
	updateRoster()
	frame:SetScript("OnUpdate", updateVexation)
	frame:SetScript("OnEvent", updateRoster)
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	frame:RegisterEvent("UNIT_PET")
	running = true
end

local function stop()
	if not running then return end
	frame:SetScript("OnUpdate", nil)
	frame:SetScript("OnEvent", nil)
	frame:UnregisterAllEvents()
	running = nil
end

-------------------------------------------------------------------------------
-- API
-------------------------------------------------------------------------------

function lib:IsRunning() return running end
function lib:GetUnitAggroByUnitGUID(GUID) return aggro[GUID] end
function lib:GetUnitAggroByUnitId(unit)
	if not UnitExists(unit) then return end
	return aggro[UnitGUID(unit)]
end

function lib:RegisterCallback(func)
	if type(func) ~= "function" then
		error(("Bad argument to :RegisterCallback, function expected, got %q."):format(type(func)), 2)
	end

	callbacks[#callbacks + 1] = func
	start()
end

function lib:UnregisterCallback(func)
	if type(func) ~= "function" then
		error(("Bad argument to :UnregisterCallback, function expected, got %q."):format(type(func)), 2)
	end

	local found = nil
	for i, v in next, callbacks do
		if v == func then
			table.remove(callbacks, i)
			found = true
			break
		end
	end
	if #callbacks == 0 then stop() end

	if not found then
		error("Bad argument to :UnregisterCallback, the provided function was not registered.", 2)
	end
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

frame:SetScript("OnUpdate", nil)
frame:SetScript("OnEvent", nil)
frame:UnregisterAllEvents()
if #callbacks > 0 then start() end