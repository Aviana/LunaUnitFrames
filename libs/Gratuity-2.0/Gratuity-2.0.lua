--[[
Name: Gratuity-2.0
Revision: $Rev: 11053 $
Author: Tekkub Stoutwrithe (tekkub@gmail.com)
Website: http://wiki.wowace.com/index.php/GratuityLib
Documentation: http://wiki.wowace.com/index.php/Gratuity-2.0_API_Documentation
SVN: svn://svn.wowace.com/root/trunk/GratuityLib/Gratuity-2.0
Description: Tooltip parsing library
Dependencies: AceLibrary, (optional) Compost-2.0, (optional) Deformat-2.0
]]

local vmajor, vminor = "Gratuity-2.0", "$Revision: 11053 $"

if not AceLibrary then error(vmajor .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(vmajor, vminor) then return end

local lib = {}
local methods = {
	"SetBagItem", "SetAction", "SetAuctionItem", "SetAuctionSellItem", "SetBuybackItem",
	"SetCraftItem", "SetCraftSpell", "SetHyperlink", "SetInboxItem", "SetInventoryItem",
	"SetLootItem", "SetLootRollItem", "SetMerchantItem", "SetPetAction", "SetPlayerBuff",
	"SetQuestItem", "SetQuestLogItem", "SetQuestRewardSpell", "SetSendMailItem", "SetShapeshift",
	"SetSpell", "SetTalent", "SetTrackingSpell", "SetTradePlayerItem", "SetTradeSkillItem", "SetTradeTargetItem",
	"SetTrainerService", "SetUnit", "SetUnitBuff", "SetUnitDebuff",
}


-- Activate a new instance of this library
local function activate(self, oldLib, oldDeactivate)
	if oldLib then self.vars = oldLib.vars
	else
		self.vars = {}
		self:CreateTooltip()
	end

	self:CreateSetMethods()

	if oldDeactivate then oldDeactivate(oldLib) end
end


function lib:InitCompost()
	if not self.vars.compost and AceLibrary:HasInstance("Compost-2.0") then self.vars.compost = AceLibrary("Compost-2.0") end
end


function lib:CreateTooltip()
	local tt = CreateFrame("GameTooltip")

	self.vars.tooltip = tt
	tt:SetOwner(tt, "ANCHOR_NONE")
--	tooltip:SetParent()

	self.vars.Llines, self.vars.Rlines = {}, {}
	for i=1,30 do
		self.vars.Llines[i], self.vars.Rlines[i] = tt:CreateFontString(), tt:CreateFontString()
		self.vars.Llines[i]:SetFontObject(GameFontNormal)
		self.vars.Rlines[i]:SetFontObject(GameFontNormal)
		tt:AddFontStrings(self.vars.Llines[i], self.vars.Rlines[i])
	end
end


--	Clears the tooltip completely, none of this "erase left, hide right" crap blizzard does
function lib:Erase()
	self.vars.tooltip:ClearLines() -- Ensures tooltip's NumLines is reset
	for i=1,30 do self.vars.Rlines[i]:SetText() end -- Clear text from right side (ClearLines only hides them)
	if not self.vars.tooltip:IsOwned(self.vars.tooltip) then self.vars.tooltip:SetOwner(self.vars.tooltip, "ANCHOR_NONE") end
	self:assert(self.vars.tooltip:IsOwned(self.vars.tooltip), "Gratuity's tooltip is not scanable")
end


-- Get the number of lines
-- Arg: endln - If passed and tooltip's NumLines is higher, endln is returned back
function lib:NumLines(endln)
	local num = self.vars.tooltip:NumLines()
	return endln and num > endln and endln or num or 0
end

local FindDefault = function(str, pattern)
	return string.find(str, pattern);
end;

local FindExact = function(str, pattern)
	if (str == pattern) then
		return string.find(str, pattern);
	end;
end;

--	If text is found on tooltip then results of string.find are returned
--  Args:
--    txt      - The text string to find
--    startln  - First tooltip line to check, default 1
--    endln    - Last line to test, default 30
--    ignoreleft / ignoreright - Causes text on one side of the tooltip to be ignored
--    exact	   - the compare will be an exact match vs the default behaviour of
function lib:Find(txt, startln, endln, ignoreleft, ignoreright, exact)
	local searchFunction = FindDefault;
	if (exact == true) then
		searchFunction = FindExact;
	end;
	self:argCheck(txt, 2, "string", "number")
	local t1, t2 = type(startln or 1), type(self:NumLines(endln))
	if (t1 ~= "number" or t2 ~= "number") then print(t1, t2, (startln or 1),self:NumLines(endln)) end
	for i=(startln or 1),self:NumLines(endln) do
		if not ignoreleft then
			local txtl = self.vars.Llines[i]:GetText()
			if (txtl and searchFunction(txtl, txt)) then return string.find(txtl, txt) end
		end

		if not ignoreright then
			local txtr = self.vars.Rlines[i]:GetText()
			if (txtr and searchFunction(txtr, txt)) then return string.find(txtr, txt) end
		end
	end
end


--  Calls Find many times.
--  Args are passed directly to Find, t1-t10 replace the txt arg
--  Returns Find results for the first match found, if any
function lib:MultiFind(startln, endln, ignoreleft, ignoreright, t1,t2,t3,t4,t5,t6,t7,t8,t9,t10)
	self:argCheck(t1, 6, "string", "number")
	if t1 and self:Find(t1, startln, endln, ignoreleft, ignoreright) then return self:Find(t1, startln, endln, ignoreleft, ignoreright)
	elseif t2 then return self:MultiFind(startln, endln, ignoreleft, ignoreright, t2,t3,t4,t5,t6,t7,t8,t9,t10) end
end


local deformat
--	If text is found on tooltip then results of deformat:Deformat are returned
--  Args:
--    txt      - The text string to deformat and serach for
--    startln  - First tooltip line to check, default 1
--    endln    - Last line to test, default 30
--    ignoreleft / ignoreright - Causes text on one side of the tooltip to be ignored
function lib:FindDeformat(txt, startln, endln, ignoreleft, ignoreright)
	self:argCheck(txt, 2, "string", "number")
	if not deformat then
		self:assert(AceLibrary:HasInstance("Deformat-2.0"), "FindDeformat requires Deformat-2.0 to be available")
		deformat = AceLibrary("Deformat-2.0")
	end

	for i=(startln or 1),self:NumLines(endln) do
		if not ignoreleft then
			local txtl = self.vars.Llines[i]:GetText()
			if (txtl and deformat(txtl, txt)) then return deformat(txtl, txt) end
		end

		if not ignoreright then
			local txtr = self.vars.Rlines[i]:GetText()
			if (txtr and deformat(txtr, txt)) then return deformat(txtr, txt) end
		end
	end
end


--	Returns a table of strings pulled from the tooltip, or nil if no strings in tooltip
--  Args:
--    startln  - First tooltip line to check, default 1
--    endln    - Last line to test, default 30
--    ignoreleft / ignoreright - Causes text on one side of the tooltip to be ignored
function lib:GetText(startln, endln, ignoreleft, ignoreright)
	self:InitCompost()
	local retval

	for i=(startln or 1),(endln or 30) do
		local txtl, txtr
		if not ignoreleft then txtl = self.vars.Llines[i]:GetText() end
		if not ignoreright then txtr = self.vars.Rlines[i]:GetText() end
		if txtl or txtr then
			if not retval then retval = self.vars.compost and self.vars.compost:Acquire() or {} end
			local t = self.vars.compost and self.vars.compost:Acquire(txtl, txtr) or {txtl, txtr}
			table.insert(retval, t)
		end
	end

	return retval
end


--	Returns the text from a specific line (both left and right unless second arg is true)
--  Args:
--    line     - the line number you wish to retrieve
--    getright - if passed the right line will be returned, if not the left will be returned
function lib:GetLine(line, getright)
	self:argCheck(line, 2, "number")
	if self.vars.tooltip:NumLines() < line then return end
	if getright then return self.vars.Rlines[line] and self.vars.Rlines[line]:GetText()
	elseif self.vars.Llines[line] then
		return self.vars.Llines[line]:GetText(), self.vars.Rlines[line]:GetText()
	end
end


-----------------------------------
--      Set tooltip methods      --
-----------------------------------

-- These methods are designed to immitate the GameTooltip API
local testmethods = {
	SetAction = function(id) return HasAction(id) end,
}
local gettrue = function() return true end
function lib:CreateSetMethods()
	for _,m in pairs(methods) do
		local meth = m
		local func = testmethods[meth] or gettrue
		self[meth] = function(self,a1,a2,a3,a4)
			self:Erase()
			if not func(a1,a2,a3,a4) then return end
			return self:pcall(self.vars.tooltip[meth], self.vars.tooltip,a1,a2,a3,a4) end
	end
end


--------------------------------
--      Load this bitch!      --
--------------------------------
AceLibrary:Register(lib, vmajor, vminor, activate)
lib = nil
