--[[
Name: HealComm-1.0
Revision: $Rev: 10000 $
Author(s): aviana
Website: https://github.com/Aviana
Description: A library to provide communication of heals and resurrections.
Dependencies: AceLibrary, AceEvent-2.0, RosterLib-2.0
]]

local MAJOR_VERSION = "HealComm-1.0"
local MINOR_VERSION = "$Revision: 10000 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("RosterLib-2.0") then error(MAJOR_VERSION .. " requires RosterLib-2.0") end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end

local roster = AceLibrary("RosterLib-2.0")
local HealComm = CreateFrame("Frame")

------------------------------------------------
-- activate, enable, disable
------------------------------------------------

local function activate(self, oldLib, oldDeactivate)
	HealComm = self
	if oldLib then
		self.Heals = oldLib.Heals
		self.GrpHeals = oldLib.GrpHeals
		self.Lookup = oldlib.Lookup
		self.pendingResurrections = oldlib.pendingResurrections
		oldLib:UnregisterAllEvents()
		oldLib:CancelAllScheduledEvents()
	end
	if not self.Heals then
		self.Heals = {}
	end
	if not self.GrpHeals then
		self.GrpHeals = {}
	end
	if not self.Lookup then
		self.Lookup = {}
	end
	if not self.pendingResurrections then
		self.pendingResurrections = {}
	end
	if oldDeactivate then oldDeactivate(oldLib) end
end


local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		HealComm.SpecialEventScheduler = instance
		HealComm.SpecialEventScheduler:embed(self)
		self:UnregisterAllEvents()
		self:CancelAllScheduledEvents()
		if HealComm.SpecialEventScheduler:IsFullyInitialized() then
			self:AceEvent_FullyInitialized()
		else
			self:RegisterEvent("AceEvent_FullyInitialized", "AceEvent_FullyInitialized", true)
		end		
	end
end


function HealComm:Enable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end


function HealComm:Disable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end

------------------------------------------------
-- Internal functions
------------------------------------------------

function HealComm:AceEvent_FullyInitialized()
	self:TriggerEvent("HealComm_Enabled")
	self:RegisterEvent("SPELLCAST_START", HealComm.OnEvent)
	self:RegisterEvent("SPELLCAST_INTERRUPTED", HealComm.OnEvent)
	self:RegisterEvent("SPELLCAST_FAILED", HealComm.OnEvent)
	self:RegisterEvent("SPELLCAST_DELAYED", HealComm.OnEvent)
	self:RegisterEvent("CHAT_MSG_ADDON", HealComm.OnEvent)
	self:RegisterEvent("UNIT_HEALTH" , HealComm.OnHealth)
end

------------------------------------------------
-- Addon Code
------------------------------------------------

HealComm.Spells = {
	["Holy Light"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (44*hlMod+(((2.5/3.5) * SpellPower)*0.1))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (88*hlMod+(((2.5/3.5) * SpellPower)*0.224))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (174*hlMod+(((2.5/3.5) * SpellPower)*0.476))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (334*hlMod+((2.5/3.5) * SpellPower))
		end;
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (522*hlMod+((2.5/3.5) * SpellPower))
		end;
		[6] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (740*hlMod+((2.5/3.5) * SpellPower))
		end;
		[7] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (1000*hlMod+((2.5/3.5) * SpellPower))
		end;
		[8] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (1318*hlMod+((2.5/3.5) * SpellPower))
		end;
		[9] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (1681*hlMod+((2.5/3.5) * SpellPower))
		end;
	};
	["Flash of Light"] = {
		[1] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (68*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[2] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (104*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[3] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (155*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[4] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (210*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[5] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (284*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[6] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (364*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
		[7] = function (SpellPower)
			local lp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Libram of Divinity" then
					lp = 53
				elseif name == "Libram of Light" then
					lp = 83
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(1,5)
			local hlMod = 4*talentRank/100 + 1
			return (481*hlMod+lp+((1.5/3.5) * SpellPower))
		end;
	};
	["Healing Wave"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (40*pMod+(((1.5/3.5) * SpellPower)*0.22))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (72*pMod+(((2/3.5) * SpellPower)*0.38))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (143*pMod+(((2.5/3.5) * SpellPower)*0.446))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (293*pMod+(((3/3.5) * SpellPower)*0.7))
		end;
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (409*pMod+((3/3.5) * SpellPower))
		end;
		[6] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (580*pMod+((3/3.5) * SpellPower))
		end;
		[7] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (798*pMod+((3/3.5) * SpellPower))
		end;
		[8] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (1093*pMod+((3/3.5) * SpellPower))
		end;
		[9] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (1465*pMod+((3/3.5) * SpellPower))
		end;
		[10] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (1736*pMod+((3/3.5) * SpellPower))
		end;
	};
	["Lesser Healing Wave"] = {
		[1] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (175*pMod+tp+((1.5/3.5) * SpellPower))
		end;
		[2] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (265*pMod+tp+((1.5/3.5) * SpellPower))
		end;
		[3] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (360*pMod+tp+((1.5/3.5) * SpellPower))
		end;
		[4] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (487*pMod+tp+((1.5/3.5) * SpellPower))
		end;
		[5] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (669*pMod+tp+((1.5/3.5) * SpellPower))
		end;
		[6] = function (SpellPower)
			local tp = 0
			if GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")) then
				local _,_,itemstring = string.find(GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot")), "|H(.+)|h")
				local name = GetItemInfo(itemstring)
				if name == "Totem of Sustaining" then
					tp = 53
				elseif name == "Totem of Life" then
					tp = 80
				end
			end
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (881*pMod+tp+((1.5/3.5) * SpellPower))
		end;
	};
	["Chain Heal"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (344*pMod+((2.5/3.5) * SpellPower))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (435*pMod+((2.5/3.5) * SpellPower))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,14)
			local pMod = 2*talentRank/100 + 1
			return (591*pMod+((2.5/3.5) * SpellPower))
		end;
	};
	["Lesser Heal"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (52*shMod+((1.5/3.5) * (SpellPower+sgMod))*0.19)
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (79*shMod+((2/3.5) * (SpellPower+sgMod))*0.34)
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (147*shMod+((2.5/3.5) * (SpellPower+sgMod))*0.6)
		end;
	};
	["Heal"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (319*shMod+((3/3.5) * (SpellPower+sgMod))*0.586)
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (471*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (610*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (759*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
	};
	["Flash Heal"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (216*shMod+((1.5/3.5) * (SpellPower+sgMod)))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (287*shMod+((1.5/3.5) * (SpellPower+sgMod)))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (361*shMod+((1.5/3.5) * (SpellPower+sgMod)))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (440*shMod+((1.5/3.5) * (SpellPower+sgMod)))
		end;
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (568*shMod+((1.5/3.5) * (SpellPower+sgMod)))
		end;
		[6] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (705*shMod+((1.5/3.5) * (SpellPower+sgMod)))
		end;
		[7] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (886*shMod+((1.5/3.5) * (SpellPower+sgMod)))
		end;
	};
	["Greater Heal"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (957*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (1220*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (1524*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (1903*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (2081*shMod+((3/3.5) * (SpellPower+sgMod)))
		end;
	};
	["Prayer of Healing"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (311*shMod+((3/3.5/3) * (SpellPower+sgMod)))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (460*shMod+((3/3.5/3) * (SpellPower+sgMod)))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (676*shMod+((3/3.5/3) * (SpellPower+sgMod)))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (965*shMod+((3/3.5/3) * (SpellPower+sgMod)))
		end;
	};
	["Healing Touch"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return (43*gnMod+((1.5/3.5) * SpellPower)*0.246)
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return (101*gnMod+((2/3.5) * SpellPower)*0.487)
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return (220*gnMod+((2.5/3.5) * SpellPower)*0.568)
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return (435*gnMod+((3/3.5) * SpellPower))
		end;
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((634*gnMod)+SpellPower)
		end;
		[6] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((819*gnMod)+SpellPower)
		end;
		[7] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((1029*gnMod)+SpellPower)
		end;
		[8] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((1314*gnMod)+SpellPower)
		end;
		[9] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((1657*gnMod)+SpellPower)
		end;
		[10] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((2061*gnMod)+SpellPower)
		end;
		[11] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((2473*gnMod)+SpellPower)
		end;
	};
	["Regrowth"] = {
		[1] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((91*gnMod)+(((2/3.5)*SpellPower)*0.5*0.38))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((177*gnMod)+(((2/3.5)*SpellPower)*0.5*0.513))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((258*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[4] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((340*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((432*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[6] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((544*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[7] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((686*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[8] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((858*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
		[9] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return ((1062*gnMod)+(((2/3.5)*SpellPower)*0.5))
		end;
	};
}

HealComm.Resurrections = {
	["Resurrection"] = true;
	["Rebirth"] = true;
	["Redemption"] = true;
	["Ancestral Spirit"] = true;
}

local function strsplit(pString, pPattern)
	local Table = {}
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = strfind(pString, fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(Table,cap)
		end
		last_end = e+1
		s, e, cap = strfind(pString, fpat, last_end)
	end
	if last_end <= strlen(pString) then
		cap = strfind(pString, last_end)
		table.insert(Table, cap)
	end
	return Table
end

local healcomm_SpellSpell = nil
local healcomm_RankRank = nil
local healcomm_SpellCast = nil

local healcommTip = CreateFrame("GameTooltip", "healcommTip", nil, "GameTooltipTemplate")
healcommTip:SetOwner(WorldFrame, "ANCHOR_NONE")

HealComm.Buffs = {
	["Power Infusion"] = {amount = 0, mod = 0.2, icon = "Interface\\Icons\\Spell_Holy_PowerInfusion"};
	["Divine Favor"] = {amount = 0, mod = 0.5, icon = "Interface\\Icons\\Spell_Holy_Heal"};
	["Nature Aligned"] = {amount = 0, mod = 0.2, icon = "Interface\\Icons\\Spell_Nature_SpiritArmor"};
	["Crusader's Wrath"] = {amount = 95, mod = 0, icon = "Interface\\Icons\\Spell_Nature_GroundingTotem"};
	["The Furious Storm"] = {amount = 95, mod = 0, icon = "Interface\\Icons\\Spell_Nature_CallStorm"};
	["Holy Power"] = {amount = 80, mod = 0, icon = "Interface\\Icons\\Spell_Holy_HolyNova"};
	["Prayer Beads Blessing"] = {amount = 190, mod = 0, icon = "Interface\\Icons\\Inv_Jewelry_Necklace_11"};
	["Chromatic Infusion"] = {amount = 190, mod = 0, icon = "Interface\\Icons\\Spell_Holy_MindVision"};
	["Ascendance"] = {amount = 75, mod = 0, icon = "Interface\\Icons\\Spell_Lightning_LightningBolt01"};
	["Ephemeral Power"] = {amount = 175, mod = 0, icon = "Interface\\Icons\\Spell_Holy_MindVision"};
	["Unstable Power"] = {amount = 34, mod = 0, icon = "Interface\\Icons\\Spell_Lightning_LightningBolt01"};
	["Healing of the Ages"] = {amount = 350, mod = 0, icon = "Interface\\Icons\\Spell_Nature_HealingWaveGreater"};
	["Essence of Sapphiron"] = {amount = 130, mod = 0, icon = "Interface\\Icons\\Inv_Trinket_Naxxramas06"};
	["The Eye of the Dead"] = {amount = 450, mod = 0, icon = "Interface\\Icons\\Inv_Trinket_Naxxramas01"}
}
	
HealComm.Debuffs = {
	["Mortal Strike"] = {amount = 0, mod = 0.5, icon = "Interface\\Icons\\Ability_Warrior_SavageBlow"};
	["Wound Poison"] = {amount = -135, mod = 0, icon = "Interface\\Icons\\Ability_Warrior_SavageBlow"};
	["Curse of the Deadwood"] = {amount = 0, mod = 0.5, icon = "Interface\\Icons\\Spell_Shadow_GatherShadows"};
	["Veil of Shadow"] = {amount = 0, mod = 0.75, icon = "Interface\\Icons\\Spell_Shadow_GatherShadows"};
	["Gehennas' Curse"] = {amount = 0, mod = 0.75, icon = "Interface\\Icons\\Spell_Shadow_GatherShadows"};
	["Mortal Wound"] = {amount = 0, mod = 0.1, icon = "Interface\\Icons\\Ability_CriticalStrike"};
	["Necrotic Poison"] = {amount = 0, mod = 0.9, icon = "Interface\\Icons\\Ability_CriticalStrike"};
	["Necrotic Aura"] = {amount = 0, mod = 1, icon = "Interface\\Icons\\Ability_CriticalStrike"}
}
	
local function GetBuffSpellPower()
	local Spellpower = 0
	local healmod = 1
	for i=1, 16 do
		local buffTexture, buffApplications = UnitBuff("player", i)
		if not buffTexture then
			return Spellpower, healmod
		end
		healcommTip:SetUnitBuff("player", i)
		local buffName = healcommTipTextLeft1:GetText()
		if HealComm.Buffs[buffName] and HealComm.Buffs[buffName].icon == buffTexture then
			Spellpower = (HealComm.Buffs[buffName].amount * buffApplications) + Spellpower
			healmod = (HealComm.Buffs[buffName].mod * buffApplications) + healmod
		end
	end
	return Spellpower, healmod
end

local function GetTargetSpellPower(spell)
	local targetpower = 0
	local targetmod = 1
	local buffTexture, buffApplications
	local debuffTexture, debuffApplications
	for i=1, 16 do
		if UnitIsVisible("target") and UnitIsConnected("target") and UnitReaction("target", "player") > 4 then
			buffTexture, buffApplications = UnitBuff("target", i)
			healcommTip:SetUnitBuff("target", i)
		else
			buffTexture, buffApplications = UnitBuff("player", i)
			healcommTip:SetUnitBuff("player", i)
		end
		if not buffTexture then
			break
		end
		local buffName = healcommTipTextLeft1:GetText()
		if (buffTexture == "Interface\\Icons\\Spell_Holy_PrayerOfHealing02" or buffTexture == "Interface\\Icons\\Spell_Holy_GreaterBlessingofLight") then
			local _,_, HLBonus, FoLBonus = string.find(healcommTipTextLeft2:GetText(),"Receives up to (%d+) extra healing from Holy Light spells%, and up to (%d+) extra healing from Flash of Light spells%.")
			if (spell == "Flash of Light") then
				targetpower = FoLBonus + targetpower
			elseif spell == "Holy Light" then
				targetpower = HLBonus + targetpower
			end
		end
		if buffName == "Healing Way" and spell == "Healing Wave" then
			targetmod = targetmod * ((buffApplications * 0.06) + 1)
		end
	end
	for i=1, 16 do
		if UnitIsVisible("target") and UnitIsConnected("target") and UnitReaction("target", "player") > 4 then
			debuffTexture, debuffApplications = UnitDebuff("target", i)
			healcommTip:SetUnitDebuff("target", i)
		else
			debuffTexture, debuffApplications = UnitDebuff("player", i)
			healcommTip:SetUnitDebuff("player", i)
		end
		if not debuffTexture then
			break
		end
		local debuffName = healcommTipTextLeft1:GetText()
		if HealComm.Debuffs[debuffName] then
			targetpower = (HealComm.Debuffs[debuffName].amount * debuffApplications) + targetpower
			targetmod = (1-(HealComm.Debuffs[debuffName].mod * debuffApplications)) * targetmod
		end
	end
	return targetpower, targetmod
end			

function HealComm.OnHealth()
	local name = UnitName(arg1)
	if HealComm.pendingResurrections[name] then
		for k,v in pairs(HealComm.pendingResurrections[name]) do
			HealComm.pendingResurrections[name][k] = nil
		end
		HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Ressupdate", name)
	end
end
			
function HealComm.stopHeal(caster)
	if HealComm.SpecialEventScheduler:IsEventScheduled(caster) then
		HealComm.SpecialEventScheduler:CancelScheduledEvent(caster)
	end
	if HealComm.Lookup[caster] then
		HealComm.Heals[HealComm.Lookup[caster]][caster] = nil
		HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Healupdate", HealComm.Lookup[caster])
		HealComm.Lookup[caster] = nil
	end
end

function HealComm.startHeal(caster, target, size, casttime)
	HealComm.SpecialEventScheduler:ScheduleEvent(caster, HealComm.stopHeal, (casttime/1000), caster)
	if not HealComm.Heals[target] then
		HealComm.Heals[target] = {}
	end
	if HealComm.Lookup[caster] then
		HealComm.Heals[HealComm.Lookup[caster]][caster] = nil
		HealComm.Lookup[caster] = nil
	end
	HealComm.Heals[target][caster] = {amount = size, ctime = (casttime/1000)+GetTime()}
	HealComm.Lookup[caster] = target
	HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Healupdate", target)
end

function HealComm.delayHeal(caster, delay)
	HealComm.SpecialEventScheduler:CancelScheduledEvent(caster)
	if HealComm.Heals[HealComm.Lookup[caster]] then
		HealComm.Heals[HealComm.Lookup[caster]][caster].ctime = HealComm.Heals[HealComm.Lookup[caster]][caster].ctime + (delay/1000)
		HealComm.SpecialEventScheduler:ScheduleEvent(caster, HealComm.stopHeal, (HealComm.Heals[HealComm.Lookup[caster]][caster].ctime-GetTime()), caster)
	end
end

function HealComm.startGrpHeal(caster, size, casttime, party1, party2, party3, party4, party5)
	HealComm.SpecialEventScheduler:ScheduleEvent(caster, HealComm.stopGrpHeal, (casttime/1000), caster)
	HealComm.GrpHeals[caster] = {amount = size, ctime = (casttime/1000)+GetTime(), targets = {party1, party2, party3, party4, party5}}
	for i=1,getn(HealComm.GrpHeals[caster].targets) do
		HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Healupdate", HealComm.GrpHeals[caster].targets[i])
	end
end

function HealComm.stopGrpHeal(caster)
	if HealComm.SpecialEventScheduler:IsEventScheduled(caster) then
		HealComm.SpecialEventScheduler:CancelScheduledEvent(caster)
	end
	local targets = HealComm.GrpHeals[caster].targets
	HealComm.GrpHeals[caster] = nil
	for i=1,getn(targets) do
		HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Healupdate", targets[i])
	end
end

function HealComm.delayGrpHeal(caster, delay)
	HealComm.SpecialEventScheduler:CancelScheduledEvent(caster)
	HealComm.GrpHeals[caster].ctime = HealComm.GrpHeals[caster].ctime + (delay/1000)
	HealComm.SpecialEventScheduler:ScheduleEvent(caster, HealComm.stopGrpHeal, (HealComm.GrpHeals[caster].ctime-GetTime()), caster)
end

function HealComm.startResurrection(caster, target)
	if not HealComm.pendingResurrections[target] then
		HealComm.pendingResurrections[target] = {}
	end
	HealComm.pendingResurrections[target][caster] = GetTime()+70
	HealComm.SpecialEventScheduler:ScheduleEvent(caster..target, HealComm.RessExpire, 70, caster, target)
	HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Ressupdate", target)
end

function HealComm.cancelResurrection(caster)
	for k,v in pairs(HealComm.pendingResurrections) do
		if v[caster] and (v[caster]-GetTime()) > 60 then
			HealComm.pendingResurrections[k][caster] = nil
			HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Ressupdate", k)
		end
	end
end

function HealComm.RessExpire(caster, target)
	HealComm.pendingResurrections[target][caster] = nil
	HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Ressupdate", target)
end

function HealComm.SendAddonMessage(msg)
	local zone = GetRealZoneText()
	if zone == "Warsong Gulch" or zone == "Arathi Basin" or zone == "Alterac Valley" then
		SendAddonMessage("HealComm", msg, "BATTLEGROUND")
	else
		SendAddonMessage("HealComm", msg, "RAID")
	end
end

HealComm.OnEvent = function()
	if ( event == "SPELLCAST_START" ) then
		if ( healcomm_SpellCast and healcomm_SpellCast[1] == arg1 and HealComm.Spells[arg1] ) then
			local Bonus = 0
			if BonusScanner then
				Bonus = tonumber(BonusScanner:GetBonus("HEAL"))
			end
			local buffpower, buffmod = GetBuffSpellPower()
			local Bonus = Bonus + buffpower
			healcomm_spellIsCasting = arg1
			local amount = (math.floor(HealComm.Spells[healcomm_SpellCast[1]][tonumber(healcomm_SpellCast[2])](Bonus))*buffmod)
			if arg1 == "Prayer of Healing" then
				local targets = {UnitName("player")}
				local targetsstring = UnitName("player").."/"
				for i=1,4 do
					if CheckInteractDistance("party"..i, 4) then
						table.insert(targets, i ,UnitName("party"..i))
						targetsstring = targetsstring..UnitName("party"..i).."/"
					end
				end
				HealComm.SendAddonMessage("GrpHeal/"..amount.."/"..arg2.."/"..targetsstring)
				HealComm.startGrpHeal(UnitName("player"), amount, arg2, targets[1], targets[2], targets[3], targets[4], targets[5])
			else
				HealComm.SendAddonMessage("Heal/"..healcomm_SpellCast[3].."/"..amount.."/"..arg2.."/")
				HealComm.startHeal(UnitName("player"), healcomm_SpellCast[3], amount, arg2)
			end
		elseif ( healcomm_SpellCast and healcomm_SpellCast[1] == arg1 and HealComm.Resurrections[arg1] ) then
			HealComm.SendAddonMessage("Resurrection/"..healcomm_SpellCast[3].."/start/")
			healcomm_spellIsCasting = arg1
			HealComm.startResurrection(UnitName("player"), healcomm_SpellCast[3])
		end
	elseif (event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED") and HealComm.Spells[healcomm_spellIsCasting] then
		if healcomm_spellIsCasting == "Prayer of Healing" then
			HealComm.SendAddonMessage("GrpHealstop")
			HealComm.stopGrpHeal(UnitName("player"))
		else
			HealComm.SendAddonMessage("Healstop")
			HealComm.stopHeal(UnitName("player"))
		end
		healcomm_spellIsCasting = nil
		healcomm_SpellCast =  nil
		healcomm_RankRank = nil
		healcomm_SpellSpell =  nil
	elseif (event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED") and HealComm.Resurrections[healcomm_spellIsCasting] then
		HealComm.SendAddonMessage("Resurrection/stop/")
		healcomm_spellIsCasting = nil
		healcomm_SpellCast =  nil
		healcomm_RankRank = nil
		healcomm_SpellSpell =  nil
		HealComm.cancelResurrection(UnitName("player"))
	elseif event == "SPELLCAST_DELAYED" then
		if healcomm_spellIsCasting == "Prayer of Healing" then
			HealComm.SendAddonMessage("GrpHealdelay/"..arg1.."/")
			HealComm.delayGrpHeal(UnitName("player"), arg1)
		else
			HealComm.SendAddonMessage("Healdelay/"..arg1.."/")
			HealComm.delayHeal(UnitName("player"), arg1)
		end
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == "HealComm" or arg1 == "healcommComm" and arg4 ~= UnitName("player") then
			local result = strsplit(arg2,"/")
			if result[1] == "Heal" then
				HealComm.startHeal(arg4, result[2], result[3], result[4])
			elseif arg2 == "Healstop" then
				HealComm.stopHeal(arg4)
			elseif result[1] == "Healdelay" then
				HealComm.delayHeal(arg4, result[2])
			elseif result[1] == "Resurrection" and result[2] == "stop" then
				HealComm.cancelResurrection(arg4)
			elseif result[1] == "Resurrection" and result[3] == "start" then
				HealComm.startResurrection(arg4, result[2])
			elseif result[1] == "GrpHeal" then
				HealComm.startGrpHeal(arg4, result[2], result[3], result[4], result[5], result[6], result[7], result[8])
			elseif result[1] == "GrpHealstop" then
				HealComm.stopGrpHeal(arg4)
			elseif result[1] == "GrpHealdelay" then
				HealComm.delayGrpHeal(arg4, result[2])
			end
		end
	end
end

function HealComm:getHeal(unit)
	local healamount = 0
	if HealComm.Heals[unit] then
		for k,v in HealComm.Heals[unit] do
			healamount = healamount+v.amount
		end
	end
	for k,v in pairs(HealComm.GrpHeals) do
		for j,c in pairs(v.targets) do
			if unit == c then
				healamount = healamount+v.amount
			end
		end
	end
	return healamount
end

function HealComm:UnitisResurrecting(unit)
	local resstime
	if HealComm.pendingResurrections[unit] then
		for k,v in pairs(HealComm.pendingResurrections[unit]) do
			if v < GetTime() then
				HealComm.pendingResurrections[unit][k] = nil
			elseif not resstime or resstime > v then
				resstime = v
			end
		end
	end
	return resstime
end

healcomm_oldCastSpell = CastSpell
function healcomm_newCastSpell(spellId, spellbookTabNum)
	-- Call the original function so there's no delay while we process
	healcomm_oldCastSpell(spellId, spellbookTabNum)
	
	local spellName, rank = GetSpellName(spellId, spellbookTabNum)
	_,_,rank = string.find(rank,"(%d+)")
	if ( SpellIsTargeting() ) then 
       -- Spell is waiting for a target
       healcomm_SpellSpell = spellName
	   healcomm_RankRank = rank
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitReaction("target", "player") > 4 ) then
       -- Spell is being cast on the current target.  
       -- If ClearTarget() had been called, we'd be waiting target
	   healcomm_ProcessSpellCast(spellName, rank, UnitName("target"))
	else
		healcomm_ProcessSpellCast(spellName, rank, UnitName("player"))
	end
end
CastSpell = healcomm_newCastSpell

healcomm_oldCastSpellByName = CastSpellByName
function healcomm_newCastSpellByName(spellName, onSelf)
	-- Call the original function
	healcomm_oldCastSpellByName(spellName, onSelf)
	local _,_,rank = string.find(spellName,"(%d+)")
	local _, _, spellName = string.find(spellName, "^([^%(]+)")
	if not rank then
		local i = 1
		while GetSpellName(i, BOOKTYPE_SPELL) do
			local s, r = GetSpellName(i, BOOKTYPE_SPELL)
			if s == spellName then
				rank = r
			end
			i = i+1
		end
		if rank then
			_,_,rank = string.find(rank,"(%d+)")
		end
	end
	if ( spellName ) then
		if ( SpellIsTargeting() ) then
			healcomm_SpellSpell = spellName
		else
			if UnitIsVisible("target") and UnitIsConnected("target") and UnitReaction("target", "player") > 4 then
				healcomm_ProcessSpellCast(spellName, rank, UnitName("target"))
			else
				healcomm_ProcessSpellCast(spellName, rank, UnitName("player"))
			end
		end
	end
end
CastSpellByName = healcomm_newCastSpellByName

healcomm_oldWorldFrameOnMouseDown = WorldFrame:GetScript("OnMouseDown")
WorldFrame:SetScript("OnMouseDown", function()
	-- If we're waiting to target
	local targetName
	
	if ( healcomm_SpellSpell and UnitName("mouseover") ) then
		targetName = UnitName("mouseover")
	elseif ( healcomm_SpellSpell and GameTooltipTextLeft1:IsVisible() ) then
		local _, _, name = string.find(GameTooltipTextLeft1:GetText(), "^Corpse of (.+)$")
		if ( name ) then
			targetName = name
		end
	end
	if ( healcomm_oldWorldFrameOnMouseDown ) then
		healcomm_oldWorldFrameOnMouseDown()
	end
	if ( healcomm_SpellSpell and targetName ) then
		healcomm_ProcessSpellCast(healcomm_SpellSpell, healcomm_RankRank, targetName)
	end
end)

healcomm_oldUseAction = UseAction
function healcomm_newUseAction(a1, a2, a3)
	
	healcommTip:SetAction(a1)
	local spellName = healcommTipTextLeft1:GetText()
	healcomm_SpellSpell = spellName
	
	-- Call the original function
	healcomm_oldUseAction(a1, a2, a3)
	
	-- Test to see if this is a macro
	if ( GetActionText(a1) or not healcomm_SpellSpell ) then
		return
	end
	local rank = healcommTipTextRight1:GetText()
	if rank then
		_,_,rank = string.find(rank,"(%d+)")
		healcomm_RankRank = rank
	end
	
	if ( SpellIsTargeting() ) then
		-- Spell is waiting for a target
		return
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitReaction("target", "player") > 4 ) then
		-- Spell is being cast on the current target
		healcomm_ProcessSpellCast(spellName, rank, UnitName("target"))
	else
		-- Spell is being cast on the player
		healcomm_ProcessSpellCast(spellName, rank, UnitName("player"))
	end
end
UseAction = healcomm_newUseAction

healcomm_oldSpellTargetUnit = SpellTargetUnit
function healcomm_newSpellTargetUnit(unit)
	-- Call the original function
	local shallTargetUnit
	if ( SpellIsTargeting() ) then
		shallTargetUnit = true
	end
	healcomm_oldSpellTargetUnit(unit)
	if ( shallTargetUnit and healcomm_SpellSpell and not SpellIsTargeting() ) then
		healcomm_ProcessSpellCast(healcomm_SpellSpell, healcomm_RankRank, UnitName(unit))
		healcomm_SpellSpell = nil
		healcomm_RankRank = nil
	end
end
SpellTargetUnit = healcomm_newSpellTargetUnit

healcomm_oldSpellStopTargeting = SpellStopTargeting
function healcomm_newSpellStopTargeting()
	healcomm_oldSpellStopTargeting()
	healcomm_SpellSpell = nil
	healcomm_RankRank = nil
end
SpellStopTargeting = healcomm_newSpellStopTargeting

healcomm_oldTargetUnit = TargetUnit
function healcomm_newTargetUnit(unit)
	-- Call the original function
	healcomm_oldTargetUnit(unit)
	
	-- Look to see if we're currently waiting for a target internally
	-- If we are, then well glean the target info here.
	
	if ( healcomm_SpellSpell and UnitExists(unit) ) then
		healcomm_ProcessSpellCast(healcomm_SpellSpell, healcomm_RankRank, UnitName(unit))
	end
end
TargetUnit = healcomm_newTargetUnit

function healcomm_ProcessSpellCast(spellName, rank, targetName)
	if ( spellName and rank and targetName ) then
		local power, mod = GetTargetSpellPower(spellName)
		healcomm_SpellCast = { spellName, rank, targetName, power, mod }
	end
end

HealComm:SetScript("OnEvent", HealComm.OnEvent)

AceLibrary:Register(HealComm, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)