local MAJOR_VERSION = "ItemBonusLib-1.0"
local MINOR_VERSION = "$Revision: 17465 $"

if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceLocale-2.2") then error(MAJOR_VERSION .. " requires AceLocale-2.2") end
if not AceLibrary:HasInstance("Gratuity-2.0") then error(MAJOR_VERSION .. " requires Gratuity-2.0") end
if not AceLibrary:HasInstance("Deformat-2.0") then error(MAJOR_VERSION .. " requires Deformat-2.0") end

local DEBUG = false

local ItemBonusLib = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDebug-2.0")
ItemBonusLib:SetDebugging(DEBUG)

local Gratuity = AceLibrary("Gratuity-2.0")
local Deformat = AceLibrary("Deformat-2.0")

local L = AceLibrary("AceLocale-2.2"):new("ItemBonusLib")

-- bonuses[BONUS] = VALUE
local bonuses = {}

-- details[BONUS][SLOT] = VALUE
local details = {}

-- items[LINK].bonuses[BONUS] = VALUE
-- items[LINK].set = SETNAME
-- items[LINK].set_line = number
local items = {}

-- sets[SETNAME].count = COUNT
-- sets[SETNAME].bonuses[NUM][BONUS] = VALUE
-- sets[SETNAME].scan_count = COUNT
-- sets[SETNAME].scan_bonuses = COUNT
local sets = {}

local slots = {
	["Head"] = true,
	["Neck"] = true,
	["Shoulder"] = true,
	["Shirt"] = true,
	["Chest"] = true,
	["Waist"] = true,
	["Legs"] = true,
	["Feet"] = true,
	["Wrist"] = true,
	["Hands"] = true,
	["Finger0"] = true,
	["Finger1"] = true,
	["Trinket0"] = true,
	["Trinket1"] = true,
	["Back"] = true,
	["MainHand"] = true,
	["SecondaryHand"] = true,
	["Ranged"] = true,
	["Tabard"] = true,
}

function ItemBonusLib:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LEAVING_WORLD")
	for s in pairs(slots) do
		slots[s] = GetInventorySlotInfo (s.."Slot")
	end
	
	local options = {
		type = "group",
		desc = L["An addon to get information about bonus from equipped items"],
		args = {
			show = {
				type = "execute",
				name = L["show"],
				desc = L["Show all bonuses from the current equipment"],
				func = function ()
					self:Print(L["Current equipment bonuses:"])
					for bonus, value in pairs(bonuses) do
						self:Print("%s : %d", self:GetBonusFriendlyName(bonus), value)
					end
				end
			},
			details = {
				type = "execute",
				name = L["details"],
				desc = L["Shows bonuses with slot distribution"],
				func = function ()
					self:Print(L["Current equipment bonus details:"])
					for bonus, detail in pairs(details) do
						local s = {}
						for slot, value in pairs(detail) do
							table.insert(s, string.format("%s : %d", slot, value))
						end
						self:Print("%s : %d (%s)", self:GetBonusFriendlyName(bonus), bonuses[bonus], table.concat(s, ", "))
					end
				end
			},
			item = {
				type = "text",
				name = L["item"],
				desc = L["show bonuses of given itemlink"],
				usage = L["<itemlink>"],
				get = false,
				set = function (link)
					local info = self:ScanItemLink(link)
					self:Print(L["Bonuses for %s:"], link)
					for bonus, value in pairs(info.bonuses) do
						self:Print("%s : %d", self:GetBonusFriendlyName(bonus), value)
					end
					if info.set then
						self:Print(L["Item is part of set [%s]"], info.set)
						local set = sets[info.set]
						for number, bonuses in pairs(set.bonuses) do
							local has_bonus = number <= set.count and "*" or " "
							self:Print(L[" %sBonus for %d pieces :"], has_bonus, number)
							for bonus, value in pairs(bonuses) do
								self:Print("    %s : %d", self:GetBonusFriendlyName(bonus), value)
							end
						end
					end
				end
			},
			slot = {
				type = "text",
				name = L["slot"],
				desc = L["show bonuses of given slot"],
				usage = L["<slotname>"],
				get = false,
				set = function (slot)
					self:Print(L["Bonuses of slot %s:"], slot)
					for bonus, detail in pairs(details) do
						if detail[slot] then
							self:Print("%s : %d", self:GetBonusFriendlyName(bonus), detail[slot])
						end
					end
				end
			},
		},
	}
	
	self:RegisterChatCommand(L.CHAT_COMMANDS, options)
	
end

function ItemBonusLib:PLAYER_ENTERING_WORLD()
	self:RegisterBucketEvent("UNIT_INVENTORY_CHANGED", 0.5)
	self:ScheduleEvent(function() self:ScanEquipment() end, 1)
end

function ItemBonusLib:PLAYER_LEAVING_WORLD()
	self:UnregisterBucketEvent("UNIT_INVENTORY_CHANGED")
end

function ItemBonusLib:UNIT_INVENTORY_CHANGED(units)
	if units.player then
		self:ScanEquipment()
	end
end

local cleanItemLink
do
	local s = string
	local trim = function (str)
		local gsub = s.gsub
		str = gsub (str, "^%s+", "" )
		str = gsub (str, "%s+$", "" )
		str = gsub (str, "%.$", "" )
		return str
	end

	local equip = ITEM_SPELL_TRIGGER_ONEQUIP
	local l_equip = s.len(equip)
		
	function cleanItemLink(itemLink)
		local _, _, link = s.find(itemLink, "|c%x+|H(item:%d+:%d+:%d+:%d+)|h%[.-%]|h|r")
		return link or itemLink
	end

	function ItemBonusLib:AddValue(bonuses, effect, value)
		if type(effect) == "string" then
			bonuses[effect] = (bonuses[effect] or 0) + value
		elseif type(value) == "table" then
			for i, e in ipairs(effect) do
				self:AddValue (bonuses, e, value[i])
			end
		else
			for _, e in ipairs(effect) do
				self:AddValue (bonuses, e, value)
			end
		end
	end
	
	function ItemBonusLib:CheckPassive(bonuses, line)
		for _, p in pairs(L.PATTERNS_PASSIVE) do
			local _, _, value = s.find (line, "^" .. p.pattern)
			if value then
				self:AddValue (bonuses, p.effect, value)
				return true
			end
		end
	end
	
	function ItemBonusLib:CheckToken(bonuses, token, value)
		local t = L.PATTERNS_GENERIC_LOOKUP[token]
		if t then
			self:AddValue (bonuses, t, value)
			return true
		else
			local s1, s2

			for _, p in ipairs(L.PATTERNS_GENERIC_STAGE1) do
				if s.find (token, p.pattern, 1, 1) then
					s1 = p.effect
					break
				end
			end	
			for _, p in ipairs(L.PATTERNS_GENERIC_STAGE2) do
				if s.find(token, p.pattern, 1, 1) then
					s2 = p.effect
					break
				end
			end	
			if s1 and s2 then
				self:AddValue (bonuses, s1..s2, value)
				return true
			end
		end
		self:Debug("CheckToken failed for \"%s\" (%d)", token, value)
	end
	
	function ItemBonusLib:CheckGeneric(bonuses, line)
		local found
		
		while s.len(line) > 0 do
			local tmpStr
			local pos = s.find (line, "/", 1, true)
			if pos then
				tmpStr = s.sub (line, 1, pos-1)
				line = s.sub (line, pos+1)
			else
				tmpStr = line
				line = ""
			end

			-- trim line
			tmpStr = trim (tmpStr)

			local _, _, value, token = s.find(tmpStr, "^%+(%d+)%%?(.*)$")
			if not value then
				_, _,  token, value = s.find(tmpStr, "^(.*)%+(%d+)%%?$")
			end
			if token and value then
				-- trim token
				token = trim (token)
				if self:CheckToken (bonuses, token, value) then
					found = true
				end
			end
		end
		return found
	end
	
	function ItemBonusLib:CheckOther(bonuses, line)
		for _, p in ipairs(L.PATTERNS_OTHER) do
			local start, _, value = s.find (line, "^" .. p.pattern)
			if start then
				if p.value then
					self:AddValue(bonuses, p.effect, p.value)
				elseif value then
					self:AddValue (bonuses, p.effect, value)
				end
				return true
			end
		end
	end

	function ItemBonusLib:AddBonusInfo(bonuses, line, no_prefix)
		local found
		if no_prefix then
			found = self:CheckPassive(bonuses, line)
		elseif s.sub (line, 0, l_equip) == equip then
			found = self:CheckPassive (bonuses, s.sub(line, l_equip + 2))
		end
		if not found then
			found = self:CheckGeneric(bonuses, line)
			if not found then
				found = self:CheckOther(bonuses, line)
				if not found then
					self:Debug("Unmatched bonus line \"%s\"", line)
				end
			end
		end
	end
end

do
	local ITEM_SET_NAME = ITEM_SET_NAME
	local ITEM_SET_BONUS = ITEM_SET_BONUS
	local ITEM_SET_BONUS_GRAY = ITEM_SET_BONUS_GRAY
	
	function ItemBonusLib:ScanItemLink(link)
		link = cleanItemLink(link)
		local info = items[link]
		local scan_set
		local set_name, set_count, set_total
		if not info then
			info = { bonuses = {} }
			Gratuity:SetHyperlink(link)
			for i = 2, Gratuity:NumLines() do
				local line = Gratuity:GetLine(i)
				set_name, set_count, set_total = Deformat(line, ITEM_SET_NAME)
				if set_name then
					info.set = set_name
					info.set_line = i
					local set = sets[set_name]
					if not set or set.scan_count > set_count and set.scan_bonuses > 1 then
						scan_set = true
					end
					break
				end
				self:AddBonusInfo(info.bonuses, line)
			end
			items[link] = info
		elseif info.set then
			Gratuity:SetHyperlink(link)
			set_name, set_count, set_total = Deformat(Gratuity:GetLine(info.set_line), ITEM_SET_NAME)
			local set = sets[set_name]
			if set.scan_count > set_count and set.scan_bonuses > 1 then
				scan_set = true
			end
		end
		if scan_set then
			self:Debug("Scanning set \"%s\"", set_name)
			local set = { count = 0, bonuses = {}, scan_count = set_count, scan_bonuses = 0 }
			for i = info.set_line + set_total + 2, Gratuity:NumLines() do
				local line = Gratuity:GetLine(i)
				local count, bonus
				local bonus = Deformat(line, ITEM_SET_BONUS)
				if bonus then
					set.scan_bonuses = set.scan_bonuses + 1
					count = set_count
				else
					count, bonus = Deformat(
					line, ITEM_SET_BONUS_GRAY)
				end
				if not bonus then
					self:Debug("Invalid set line \"%s\"", line)
					-- break
				else
					local bonuses = set.bonuses[count] or {}
					self:AddBonusInfo(bonuses, bonus, true)
					set.bonuses[count] = bonuses
				end
			end
			sets[set_name] = set
		end
		return info
	end
end

function ItemBonusLib:ScanEquipment()
	-- clean bonus information
	for bonus in pairs(bonuses) do
		bonuses[bonus] = nil
	end
	for bonus, detail in pairs(details) do
		for slot in pairs(detail) do
			detail[slot] = nil
		end
	end
	for _, set in pairs(sets) do
		set.count = 0
	end
	
	for slot, id in pairs(slots) do
		local link = GetInventoryItemLink("player", id)
		if link then
			self:Debug("Scanning item %s", link)
			local info = self:ScanItemLink(link)
			local set = info.set
			if set then
				sets[set].count = sets[set].count + 1
			end
			for bonus, value in pairs(info.bonuses) do
				bonuses[bonus] = (bonuses[bonus] or 0) + value
				if not details[bonus] then
					details[bonus] = {}
				end
				details[bonus][slot] = (details[bonus][slot] or 0) + value
			end
		end
	end
	for _, set in pairs(sets) do
		for i = 2, set.count do
			if set.bonuses[i] then
				for bonus, value in pairs(set.bonuses[i]) do
					bonuses[bonus] = (bonuses[bonus] or 0) + value
					if not details[bonus] then
						details[bonus] = {}
					end
					details[bonus].Set = (details[bonus].Set or 0) + value
				end
			end
		end
	end
	self:TriggerEvent("ItemBonusLib_Update")
end

-- DEBUG
if DEBUG then
	function ItemBonusLib:DumpCachedItems(clear)
		DevTools_Dump(items)
		if clear then
			items = {}
		end
	end

	function ItemBonusLib:DumpCachedSets(clear)
		DevTools_Dump(sets)
	end

	function ItemBonusLib:DumpBonuses()
		DevTools_Dump(bonuses)
	end

	function ItemBonusLib:DumpDetails()
		DevTools_Dump(details)
	end

	function ItemBonusLib:Reload()
		items = {}
		sets = {}
		self:ScanEquipment()
	end
end

-- BonusScanner compatible API
function ItemBonusLib:GetBonus(bonus)
	return bonuses[bonus] or 0
end

function ItemBonusLib:GetSlotBonuses (slotname)
	local bonuses = {}
	for bonus, detail in pairs(details) do
		if detail[slotname] then
			bonuses[bonus] = detail[slotname]
		end
	end
	return bonuses
end

function ItemBonusLib:GetBonusDetails (bonus)
	return details[bonus] or {}
end

function ItemBonusLib:GetSlotBonus (bonus, slotname)
	local detail = details[bonus]
	return detail and detail[slotname] or 0
end

function ItemBonusLib:GetBonusFriendlyName (bonus)
	return L.NAMES[bonus] or bonus
end

function ItemBonusLib:IsActive ()
	return true
end

function ItemBonusLib:ScanItem (itemlink, excludeSet)
	if not excludeSet then
		self:error("excludeSet can't be false on BonusScanner compatible API")
	end
	local name, link = GetItemInfo(itemlink)
	if not name then
		return
	end
	return self:ScanItemLink(link).bonuses
end

function ItemBonusLib:ScanTooltipFrame (frame, excludeSet)
	self:error("BonusScanner:ScanTooltipFrame() is not available")
end

AceLibrary:Register(ItemBonusLib, MAJOR_VERSION, MINOR_VERSION)
