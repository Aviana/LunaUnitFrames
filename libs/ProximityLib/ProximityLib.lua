

local vmajor, vminor = "1", tonumber(string.sub("$Revision: 14736 $", 12, -3))
local stubvarname = "TekLibStub"
local libvarname = "ProximityLib"


-- Check to see if an update is needed
-- if not then just return out now before we do anything
local libobj = getglobal(libvarname)
if libobj and not libobj:NeedsUpgraded(vmajor, vminor) then return end


local stubobj = getglobal(stubvarname)
if not stubobj then
	stubobj = {}
	setglobal(stubvarname, stubobj)


	-- Instance replacement method, replace contents of old with that of new
	function stubobj:ReplaceInstance(old, new)
		 for k,v in pairs(old) do old[k]=nil end
		 for k,v in pairs(new) do old[k]=v end
	end


	-- Get a new copy of the stub
	function stubobj:NewStub(name)
		local newStub = {}
		self:ReplaceInstance(newStub, self)
		newStub.libName = name
		newStub.lastVersion = ''
		newStub.versions = {}
		return newStub
	end


	-- Get instance version
	function stubobj:NeedsUpgraded(vmajor, vminor)
		local versionData = self.versions[vmajor]
		if not versionData or versionData.minor < vminor then return true end
	end


	-- Get instance version
	function stubobj:GetInstance(version)
		if not version then version = self.lastVersion end
		local versionData = self.versions[version]
		if not versionData then print(string.format("<%s> Cannot find library version: %s", self.libName, version or "")) return end
		return versionData.instance
	end


	-- Register new instance
	function stubobj:Register(newInstance)
		 local version,minor = newInstance:GetLibraryVersion()
		 self.lastVersion = version
		 local versionData = self.versions[version]
		 if not versionData then
				-- This one is new!
				versionData = {
					instance = newInstance,
					minor = minor,
					old = {},
				}
				self.versions[version] = versionData
				newInstance:LibActivate(self)
				return newInstance
		 end
		 -- This is an update
		 local oldInstance = versionData.instance
		 local oldList = versionData.old
		 versionData.instance = newInstance
		 versionData.minor = minor
		 local skipCopy = newInstance:LibActivate(self, oldInstance, oldList)
		 table.insert(oldList, oldInstance)
		 if not skipCopy then
				for i, old in ipairs(oldList) do self:ReplaceInstance(old, newInstance) end
		 end
		 return newInstance
	end
end


-------------------------------
--      Library Methods      --
-------------------------------

if not libobj then
	libobj = stubobj:NewStub(libvarname)
	setglobal(libvarname, libobj)
end

local lib = {}


-- Return the library's current version
function lib:GetLibraryVersion()
	return vmajor, vminor
end


-- This table needs to be localized, of course
local events = {
	CHAT_MSG_COMBAT_PARTY_HITS = "(%a+) c?[rh]its .+",
	CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS = "(%a+) c?[rh]its .+",
	CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS = ".+ c?[rh]its (%a+) for .+",
	CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS = ".+ c?[rh]its (%a+) for .+",
	CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS = ".+ c?[rh]its (%a+) for .+",

	CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE = {".+'s .+ c?[rh]its (%a+) for .+", ".+'s .+ was resisted by (%a+)%."},
	CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE = {".+'s .+ c?[rh]its (%a+) for .+", ".+'s .+ was resisted by (%a+)%."},
	CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE = {".+'s .+ c?[rh]its (%a+) for .+", ".+'s .+ was resisted by (%a+)%."},
	CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF = "(%a+)'s .+",
	CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE = "(%a+)'s .+ c?[rh]its .+",
	CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE = ".+'s .+ c?[rh]its (%a+) for .+",
	CHAT_MSG_SPELL_PARTY_BUFF = "(%a+)'s .+",
	CHAT_MSG_SPELL_PARTY_DAMAGE = "(%a+)'s .+ c?[rh]its .+",
	CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE = "%a+ suffers %d+ %a+ damage from (%a+)'s .+",
	CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS = ".+ gains %d+ health from (.+)'s .+",
	CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE = "(%a+) suffers %d+ .+",
	CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE = "(%a+) suffers %d+ .+",
	CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE = "(%a+) suffers %d+ .+",
	CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS = ".+ gains %d+ health from (.+)'s .+",
}

if ( GetLocale() == "koKR" ) then
	events = {
		CHAT_MSG_COMBAT_PARTY_HITS = "(.+)|1이;가; .-|1을;를; 공격하여 %d+의 [^%s]+ 입혔습니다",
		CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS = "(.+)|1이;가; .-|1을;를; 공격하여 %d+의 [^%s]+ 입혔습니다",
		CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS = ".-의 공격을 받아 %d+의 [^%s]+ 입었습니다",
		CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS = ".+|1이;가; ([^%s]+)|1을;를; 공격하여 %d+의 [^%s]+ 입혔습니다",
		CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS = ".+|1이;가; ([^%s]+)|1을;를; 공격하여 %d+의 [^%s]+ 입혔습니다",

		CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE = {".-|1이;가; .+|1으로;로; 당신에게 %d+의 .- 입혔습니다", ".-|1이;가; .-|1으로;로; 공격했지만 저항했습니다"},
		CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE = {".-|1이;가; .+|1으로;로; (.-)에게 %d+의 .- 입혔습니다", ".-|1이;가; .-|1으로;로; (.-)|1을;를; 공격했지만 저항했습니다"},
		CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE = {".-|1이;가; .+|1으로;로; (.-)에게 %d+의 .- 입혔습니다", ".-|1이;가; .-|1으로;로; (.-)|1을;를; 공격했지만 저항했습니다"},
		CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF = "([^%s]+)의 .+%.",
		CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE = "(.-)|1이;가; .+|1으로;로; .-에게 %d+의 .- 입혔습니다",
		CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE = ".-|1이;가; .+|1으로;로; (.-)에게 %d+의 .- 입혔습니다",
		CHAT_MSG_SPELL_PARTY_BUFF = "([^%s]+)의 .+%.",
		CHAT_MSG_SPELL_PARTY_DAMAGE = "(.-)|1이;가; .+|1으로;로; .-에게 %d+의 .- 입혔습니다",
		CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE = ".-|1이;가; ([^%s]+)의 .-에 의해 %d+의 .+",
		CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS = "([^%s]+)|1이;가; .+%.",
		CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE = "([^%s]+)|1이;가; .-에 의해 %d+의 .+",
		CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE = "([^%s]+)|1이;가; .-에 의해 %d+의 .+",
		CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE = "([^%s]+)|1이;가; .-에 의해 %d+의 .+",
		CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS = "([^%s]+)|1이;가; .+%.",
	}
end

local rosterevents = {
	RAID_ROSTER_UPDATE = true,
	UNIT_PET = true,
	PARTY_MEMBERS_CHANGED = true,
	MEETINGSTONE_CHANGED = true,
}
local roster, ranges, times, updatetimes, unknownunits
local rate = 0.5
local elapsed = 0

-- Activate a new instance of this library
function lib:LibActivate(stub, oldLib, oldList)
	if oldLib then
		self.vars = oldLib.vars
		self.frame = oldLib.frame
	else
		self.vars = {}
		self.vars.ranges, self.vars.times = {}, {}
		self.vars.roster, self.vars.updatetimes, self.vars.unknownunits = {}, {}, {}
		self.frame = CreateFrame("Frame")
		self.frame.name = "ProximityLib Frame"
	end
	self.frame:UnregisterAllEvents()
	for i in pairs(events) do self.frame:RegisterEvent(i) end
	for i in pairs(rosterevents) do self.frame:RegisterEvent(i) end
	self.frame:SetScript("OnEvent", self.OnEvent)
	self.frame:SetScript("OnUpdate", self.OnUpdate)
	self.frame:Show()
	roster, ranges, times, updatetimes, unknownunits = self.vars.roster, self.vars.ranges, self.vars.times, self.vars.updatetimes, self.vars.unknownunits
end


function lib:OnEvent()
	local self = lib
	if events[event] then self:ParseCombatMessage(events[event])
	elseif rosterevents[event] then
		-- Times are wiped clean on a roster update, so recent log-range entries will be lost
		for i in pairs(self.vars.roster) do self.vars.roster[i] = nil end
		for unitid in self:UnitIDIter() do
			self:CreateUnit(unitid)
		end
	end
end


function lib:OnUpdate()
	elapsed = elapsed + arg1
	if elapsed < rate then return end
	local self = lib
	local t = GetTime()
	elapsed = 0
	if next(self.vars.unknownunits, nil) then
		for unitid in pairs(self.vars.unknownunits) do 
			self:CreateUnit(unitid)
		end
	end
	for unit in pairs(self.vars.roster) do
		if not self.vars.updatetimes[unit] or (self.vars.updatetimes[unit] < (t - rate)) then
			self:UpdateUnit(unit)
		end
	end
end


function lib:CreateUnit(unitid)
	local n = UnitName(unitid)
	if n then 
		if n == UNKNOWNOBJECT or n == UKNOWNBEING then
			self.vars.unknownunits[unitid] = true
			return false
		else
			self.vars.roster[n] = unitid
			self.vars.unknownunits[unitid] = nil
			return true
		end
	end
end


function lib:ParseCombatMessage(eventstr)
	if type(eventstr) == "string" then
		local startstring, endstring = string.find(arg1, eventstr)
		if startstring then
			_, _, unit = string.find(arg1, eventstr)
			if unit then
				self:UpdateUnit(unit, true) 
			else
				self:UpdateUnit(UnitName("player"), ture)
			end
		end
	elseif type(eventstr) == "table" then
		for _,val in pairs(eventstr) do
			local startstring, endstring = string.find(arg1, val)
			if startstring then
				_, _, unit = string.find(arg1, val)
				if unit then
					self:UpdateUnit(unit, true)
					return
				else
					self:UpdateUnit(UnitName("player"), ture)
					return
				end
			end
		end
	end
end


function lib:UpdateUnit(unit, inlogrange)
	assert(unit, "No unit passed")
	local unitid = self.vars.roster[unit]
	if not unitid then return end

	if CheckInteractDistance(unitid, 1) then
		self.vars.ranges[unit] = 10
		self.vars.times[unit] = GetTime()
	elseif CheckInteractDistance(unitid, 3) then
		self.vars.ranges[unit] = 10
		self.vars.times[unit] = GetTime()
	elseif CheckInteractDistance(unitid, 4) then
		self.vars.ranges[unit] = 30
		self.vars.times[unit] = GetTime()
	elseif inlogrange then
		self.vars.ranges[unit] = 45
		self.vars.times[unit] = GetTime()
	end
	self.vars.updatetimes[unit] = GetTime()
--	print("UpdateUnit", self.vars.ranges[unit], self.vars.times[unit])
end


-----------------------------
--      Query Methods      --
-----------------------------

function lib:GetUnitRange(unitid)
	assert(unitid, "No unitID passed")
	if UnitIsUnit(unitid, "player") then return 0, GetTime() end

	local unit = UnitName(unitid)
	return self.vars.ranges[unit], self.vars.times[unit]
end


--------------------------------
--      UnitID Iterators      --
--------------------------------

local playersent, petsent, unitcount, petcount, pmem, rmem

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

function lib:UnitIDIter()
	playersent, petsent, unitcount, petcount, pmem, rmem = false, false, 1, 1, GetNumPartyMembers(), GetNumRaidMembers()
	return NextUnit
end




--------------------------------
--      Load this bitch!      --
--------------------------------
libobj:Register(lib)
