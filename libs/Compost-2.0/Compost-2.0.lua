
--[[
	Name: Compost-2.0
	Revision: $Rev: 17406 $
	Author: Tekkub Stoutwrithe (tekkub@gmail.com)
	Website: http://wiki.wowace.com/index.php/CompostLib
	Documentation: http://wiki.wowace.com/index.php/Compost-2.0_API_Documentation
	SVN: svn://svn.wowace.com/root/trunk/CompostLib/Compost-2.0
	Description: Recycle tables to reduce garbage generation
	Dependencies: AceLibrary
]]

local vmajor, vminor = "Compost-2.0", "$Revision: 17406 $"

if not AceLibrary then error(vmajor .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(vmajor, vminor) then return end

local lua51 = loadstring("return function(...) return ... end") and true or false
local lib = {}


-- Activate a new instance of this library
local function activate(self, oldLib, oldDeactivate)
	if oldLib then -- if upgrading
		self.var, self.k = oldLib.var, oldLib.k
	else
		self.k = {  -- Constants go here
			maxcache = 10,		-- I think this is a good number, I'll change it later if necessary
		}
		self.var = {  -- "Local" variables go here
			cache = {},
			secondarycache = {},
		}

		-- This makes the secondary cache table a weak table, any values in it will be reclaimed
		-- during a GC if there are no other references to them
		setmetatable(self.var.secondarycache, {__mode = "v"})
	end
	if not self.var.tablechecks then
		self.var.tablechecks = {}
		setmetatable(self.var.tablechecks, {__mode = "kv"})
		for i,v in ipairs(self.var.cache) do self.var.tablechecks[v] = true end
		for i,v in ipairs(self.var.secondarycache) do self.var.tablechecks[v] = true end
	end
	if oldDeactivate then oldDeactivate(oldLib) end
end


-- Removes an empty table from the cache and returns it
-- or generates a new table if none available
function lib:GetTable()
	if lua51 or self.var.disabled then return {} end

	if table.getn(self.var.cache) > 0 then
		for i in pairs(self.var.cache) do
			local t = table.remove(self.var.cache, i)
			self.var.tablechecks[t] = nil
			if next(t) then  -- Table has been modified, someone holds a ref still, discard it
				error("Someone is modifying tables reclaimed by Compost!")
				self:IncDec("numdiscarded", 1)
			else  -- It's clean, we think... return it.
				self:IncDec("totn", -1)
				self:IncDec("numrecycled", 1)
				return t
			end
		end
	end

	if next(self.var.secondarycache) then
		for i in pairs(self.var.secondarycache) do
			local t = table.remove(self.var.secondarycache, i)
			self.var.tablechecks[t] = nil
			if next(t) then  -- Table has been modified, someone holds a ref still, discard it
				error("Someone is modifying tables reclaimed by Compost!")
				self:IncDec("numdiscarded", 1)
			else  -- It's clean, we think... return it.
				self:IncDec("totn", -1)
				self:IncDec("numrecycled", 1)
				return t
			end
		end
	end

	self:IncDec("numnew", 1)
	return {}
end


-- Returns a table, populated with any variables passed
-- basically: return {a1, a2, ... a20}
if lua51 then
	--[[
		function lib:Acquire(...)
		return self:Populate({}, ...)
		end
	]]
	lib.Acquire = loadstring([[return function(self, ...)
		return self:Populate({}, ...)
	end]])()
else
	function lib:Acquire(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		local t = self:GetTable()
		return self:Populate(t,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
	end
end


-- Acquires a table and fills it with values, hash style
-- basically: return {k1 = v1, k2 = v2, ... k10 = v10}
if lua51 then
	--[[
		function lib:AcquireHash(...)
		return self:PopulateHash({}, ...)
		end
	]]
	lib.AcquireHash = loadstring([[return function(self, ...)
		return self:PopulateHash({}, ...)
	end]])()
else
	function lib:AcquireHash(k1,v1,k2,v2,k3,v3,k4,v4,k5,v5,k6,v6,k7,v7,k8,v8,k9,v9,k10,v10)
		local t = self:GetTable()
		return self:PopulateHash(t,k1,v1,k2,v2,k3,v3,k4,v4,k5,v5,k6,v6,k7,v7,k8,v8,k9,v9,k10,v10)
	end
end


-- Erases the table passed, fills it with the args passed, and returns it
-- Essentially the same as doing Reclaim then Acquire, except the same table is reused
if lua51 then
	--[[
		function lib:Recycle(t, ...)
		t = self:Erase(t)
		return self:Populate(t, ...)
		end
	]]
	lib.Recycle = loadstring([[return function(self, t, ...)
		t = self:Erase(t)
		return self:Populate(t, ...)
	end]])()
else
	function lib:Recycle(t,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		t = self:Erase(t)
		return self:Populate(t,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
	end
end


-- Erases the table passed, fills it with the args passed, and returns it
-- Essentially the same as doing Reclaim then AcquireHash, except the same table is reused
if lua51 then
	--[[
		function lib:RecycleHash(t, ...)
		t = self:Erase(t)
		return self:PopulateHash(t, ...)
		end
	]]
	lib.RecycleHash = loadstring([[return function(self, t, ...)
		t = self:Erase(t)
		return self:PopulateHash(t, ...)
	end]])()
else
	function lib:RecycleHash(t,k1,v1,k2,v2,k3,v3,k4,v4,k5,v5,k6,v6,k7,v7,k8,v8,k9,v9,k10,v10)
		t = self:Erase(t)
		return self:PopulateHash(t,k1,v1,k2,v2,k3,v3,k4,v4,k5,v5,k6,v6,k7,v7,k8,v8,k9,v9,k10,v10)
	end
end

-- Returns a table to the cache
-- All tables referenced inside the passed table will be reclaimed also
-- If a depth is passed, Reclaim will call itsself recursivly
-- to reclaim all tables contained in t to the depth specified
if lua51 then
	function lib:Reclaim() end
else
	function lib:Reclaim(t, depth)
		if type(t) ~= "table" or self.var.disabled then return end
		self:assert(not self.var.tablechecks[t], "Cannot reclaim a table twice")
		
		if not self:ItemsInSecondaryCache() then self.var.totn = table.getn(self.var.cache) end
		
		if depth and depth > 0 then
			for i in pairs(t) do
				if type(t[i]) == "table" then self:Reclaim(t[i], depth - 1) end
			end
		end
		self:Erase(t)
		if self.k.maxcache and table.getn(self.var.cache) >= self.k.maxcache then
			table.insert(self.var.secondarycache, t)
		else
			table.insert(self.var.cache, t)
		end
		self:IncDec("numreclaim", 1)
		self:IncDec("totn", 1)
		self.var.maxn = math.max(self.var.maxn or 0, self.var.totn)
		self.var.tablechecks[t] = true
	end
end

-- Reclaims multiple tables, can take 10 recursive sets or 20 non-recursives,
-- or any combination of the two.  Pass args in the following manner:
-- table1, depth1, tabl2, depth2, table3, table4, table5, depth5, ...
if lua51 then
	function lib:ReclaimMulti() end
else
	function lib:ReclaimMulti(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		if not a1 then return end
		if type(a2) == "number" then
			self:Reclaim(a1, a2)
			self:ReclaimMulti(a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		else
			self:Reclaim(a1)
			self:ReclaimMulti(a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		end
	end
end

-- Erases the table passed, nothing more nothing less :)
-- Tables referenced inside the passed table are NOT erased
if lua51 then
	function lib:Erase() return {} end
else
	function lib:Erase(t)
		if type(t) ~= "table" then return end
		if self.var.disabled then return {} end
		local mem = gcinfo()
		setmetatable(t, nil)
		for i in pairs(t) do
			t[i] = nil
		end
		t.reset = 1
		t.reset = nil
		table.setn(t, 0)
		self:IncDec("memfreed", math.abs(gcinfo() - mem))
		self:IncDec("numerased", 1)
		return t
	end
end

-- Fills the table passed with the args passed
if lua51 then
	--[[
		function lib:Populate(t, a, ...)
		if not t then return
	elseif a ~= nil then
		table.insert(t, a)
		return self:Populate(t, ...)
	else return t end
		end
	]]
	lib.Populate = loadstring([[return function(self, t, a, ...)
		if not t then return
	elseif a ~= nil then
		table.insert(t, a)
		return self:Populate(t, ...)
	else return t end
	end]])()
else
	function lib:Populate(t,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		if not t then return end
		if a1 ~= nil then table.insert(t, a1) end
		if a2 ~= nil then table.insert(t, a2) end
		if a3 ~= nil then table.insert(t, a3) end
		if a4 ~= nil then table.insert(t, a4) end
		if a5 ~= nil then table.insert(t, a5) end
		if a6 ~= nil then table.insert(t, a6) end
		if a7 ~= nil then table.insert(t, a7) end
		if a8 ~= nil then table.insert(t, a8) end
		if a9 ~= nil then table.insert(t, a9) end
		if a10 ~= nil then table.insert(t, a10) end
		if a11 ~= nil then table.insert(t, a11) end
		if a12 ~= nil then table.insert(t, a12) end
		if a13 ~= nil then table.insert(t, a13) end
		if a14 ~= nil then table.insert(t, a14) end
		if a15 ~= nil then table.insert(t, a15) end
		if a16 ~= nil then table.insert(t, a16) end
		if a17 ~= nil then table.insert(t, a17) end
		if a18 ~= nil then table.insert(t, a18) end
		if a19 ~= nil then table.insert(t, a19) end
		if a20 ~= nil then table.insert(t, a20) end
		return t
	end
end

-- Same as Populate, but takes 10 key-value pairs instead
if lua51 then
	--[[
		function lib:PopulateHash(t, k, v, ...)
		if not t then return
	elseif k ~= nil then
		t[k] = v
		return self:PopulateHash(t, ...)
	else return t end
		end
	]]
	lib.PopulateHash = loadstring([[return function(self, t, k, v, ...)
		if not t then return
	elseif k ~= nil then
		t[k] = v
		return self:PopulateHash(t, ...)
	else return t end
	end]])()
else
	function lib:PopulateHash(t,k1,v1,k2,v2,k3,v3,k4,v4,k5,v5,k6,v6,k7,v7,k8,v8,k9,v9,k10,v10)
		if not t then return end
		if k1 ~= nil then t[k1] = v1 end
		if k2 ~= nil then t[k2] = v2 end
		if k3 ~= nil then t[k3] = v3 end
		if k4 ~= nil then t[k4] = v4 end
		if k5 ~= nil then t[k5] = v5 end
		if k6 ~= nil then t[k6] = v6 end
		if k7 ~= nil then t[k7] = v7 end
		if k8 ~= nil then t[k8] = v8 end
		if k9 ~= nil then t[k9] = v9 end
		if k10 ~= nil then t[k10] = v10 end
		return t
	end
end

function lib:IncDec(variable, diff)
	self.var[variable] = (self.var[variable] or 0) + diff
end


function lib:ItemsInSecondaryCache()
	for i in pairs(self.var.secondarycache) do return true end
end


function lib:GetSecondaryCacheSize()
	local n = 0
	for i in pairs(self.var.secondarycache) do n = n + 1 end
	return n
end


-- Prints out statistics on table recycling
-- /script CompostLib:GetInstance("compost-1"):Stats()
function lib:Stats()
	if self.var.disabled then ChatFrame1:AddMessage("CompostLib is disabled!")
	else
		ChatFrame1:AddMessage(string.format(
		"|cff00ff00New: %d|r | |cffffff00Recycled: %d|r | |cff00ffffMain: %d|r | |cffff0000Secondary: %d|r | |cffff8800Max %d|r | |cff888888Erases: %d|r | |cffff00ffMem Saved: %d KiB|r | |cffff0088Lost to GC: %d",
		self.var.numnew or 0,
		self.var.numrecycled or 0,
		table.getn(self.var.cache),
		self:GetSecondaryCacheSize(),
		self.var.maxn or 0,
		(self.var.numerased or 0) - (self.var.numreclaim or 0),
		(self.var.memfreed or 0) + 32/1024*(self.var.numrecycled or 0),
		(self.var.numreclaim or 0) - (self.var.numrecycled or 0) - table.getn(self.var.cache)))
	end
end

setmetatable(lib, { __call = lib.Acquire })

--------------------------------
--      Load this bitch!      --
--------------------------------
AceLibrary:Register(lib, vmajor, vminor, activate)
lib = nil