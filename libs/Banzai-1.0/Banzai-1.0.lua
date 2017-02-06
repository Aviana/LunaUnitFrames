--[[
Name: Banzai-1.0
Revision: $Rev: 15000 $
Author(s): Rabbit (rabbit.magtheridon@gmail.com), maia
Documentation: http://www.wowace.com/index.php/Banzai-1.0_API_Documentation
SVN: http://svn.wowace.com/root/trunk/BanzaiLib/Banzai-1.0
Description: Aggro notification library.
Dependencies: AceLibrary, AceEvent-2.0, RosterLib-2.0
]]

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local MAJOR_VERSION = "Banzai-1.0"
local MINOR_VERSION = "$Revision: 15000 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:HasInstance("RosterLib-2.0") then error(MAJOR_VERSION .. " requires RosterLib-2.0.") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local lib = {}
AceLibrary("AceEvent-2.0"):embed(lib)

local RL = nil
local roster = nil
local playerName = nil

-------------------------------------------------------------------------------
-- Compost Heap, courtesy of Tekkub/SEEA.
-------------------------------------------------------------------------------

local table_setn
do
	local version = GetBuildInfo()
	if string.find(version, "^2%.") then
		-- 2.0.0
		table_setn = function() end
	else
		table_setn = table.setn
	end
end

local heap = {}
setmetatable(heap, {__mode = "kv"})

local function acquire()
	local t = next(heap)
	if t then
		heap[t] = nil
		assert(not next(t), "A table in the compost heap has been modified!")
	end
	t = t or {}
	return t
end


local function reclaim(t, d)
	if type(t) ~= "table" then return end
	if d and d > 0 then
		for i in pairs(t) do
			if type(t[i]) == "table" then reclaim(t[i], d - 1) end
		end
	end
	for i in pairs(t) do t[i] = nil end
	table_setn(t, 0)
	heap[t] = true
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

-- Activate a new instance of this library
function activate(self, oldLib, oldDeactivate)
	if oldLib then
		self.vars = oldLib.vars
		if oldLib:IsEventScheduled("UpdateAggroList") then
			oldLib:CancelScheduledEvent("UpdateAggroList")
		end
	end

	RL = AceLibrary("RosterLib-2.0")
	roster = RL.roster
	playerName = UnitName("player")
	self:ScheduleRepeatingEvent("UpdateAggroList", self.UpdateAggroList, 0.2, self)

	if oldDeactivate then oldDeactivate(oldLib) end
end

-------------------------------------------------------------------------------
-- Library
-------------------------------------------------------------------------------

function lib:UpdateAggroList()
	local oldBanzai = acquire()

	for _, unit in pairs(roster) do
		oldBanzai[unit.unitid] = unit.banzai

		-- deduct aggro for all, increase it later for everyone with aggro
		unit.banzaiModifier = math.max(0, (unit.banzaiModifier or 0) - 5)

		-- check for aggro
		local targetId = unit.unitid .. "target"
		local rosterUnit = roster[UnitName(targetId .. "target")]
		if rosterUnit and UnitCanAttack("player", targetId) and UnitCanAttack(targetId, "player") then
			rosterUnit.banzaiModifier = (rosterUnit.banzaiModifier or 0) + 10
		end

		-- cleanup
		unit.banzaiModifier = math.min(20, unit.banzaiModifier)

		-- set aggro
		unit.banzai = (unit.banzaiModifier > 15)
	end

	for _, unit in pairs(roster) do
		if oldBanzai[unit.unitid] ~= nil and oldBanzai[unit.unitid] ~= unit.banzai then
			-- Aggro status has changed.
			if unit.banzai == true then
				-- Unit has aggro
				self:TriggerEvent("Banzai_UnitGainedAggro", unit.unitid)
				if unit.name == playerName then
					self:TriggerEvent("Banzai_PlayerGainedAggro")
				end
			else
				-- Unit lost aggro
				self:TriggerEvent("Banzai_UnitLostAggro", unit.unitid)
				if unit.name == playerName then
					self:TriggerEvent("Banzai_PlayerLostAggro")
				end
			end
		end
	end

	reclaim(oldBanzai)
	oldBanzai = nil
end

-------------------------------------------------------------------------------
-- API
-------------------------------------------------------------------------------

function lib:GetUnitAggroByUnitId( unitId )
	local rosterUnit = RL:GetUnitObjectFromUnit(unitId)
	if not rosterUnit then return nil end
	return rosterUnit.banzai
end

function lib:GetUnitAggroByUnitName( unitName )
	local rosterUnit = RL:GetUnitObjectFromName(unitName)
	if not rosterUnit then return nil end
	return rosterUnit.banzai
end

-------------------------------------------------------------------------------
-- Register
-------------------------------------------------------------------------------
AceLibrary:Register(lib, MAJOR_VERSION, MINOR_VERSION, activate)

