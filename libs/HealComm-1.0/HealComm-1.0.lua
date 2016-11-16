--[[
Name: HealComm-1.0
Revision: $Rev: 11350 $
Author(s): aviana
Website: https://github.com/Aviana
Description: A library to provide communication of heals and resurrections.
Dependencies: AceLibrary, AceEvent-2.0, RosterLib-2.0
]]

local MAJOR_VERSION = "HealComm-1.0"
local MINOR_VERSION = "$Revision: 11350 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("RosterLib-2.0") then error(MAJOR_VERSION .. " requires RosterLib-2.0") end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end

local roster = AceLibrary("RosterLib-2.0")
local HealComm = CreateFrame("Frame")

------------------------------------------------
-- Locales
------------------------------------------------

local L = {}
if( GetLocale() == "deDE" ) then
	L["Renew"] = "Erneuerung"
	L["Rejuvenation"] = "Verj\195\188ngung"
	L["Holy Light"] = "Heiliges Licht"
	L["Flash of Light"] = "Lichtblitz"
	L["Healing Wave"] = "Welle der Heilung"
	L["Lesser Healing Wave"] = "Geringe Welle der Heilung"
	L["Chain Heal"] = "Kettenheilung"
	L["Lesser Heal"] = "Geringe Heilung"
	L["Heal"] = "Heilung"
	L["Flash Heal"] = "Blitzheilung"
	L["Greater Heal"] = "Große Heilung"
	L["Prayer of Healing"] = "Gebet der Heilung"
	L["Healing Touch"] = "Heilende Ber\195\188hrung"
	L["Regrowth"] = "Nachwachsen"
	L["Resurrection"] = "Wiederbelebung"
	L["Rebirth"] = "Wiedergeburt"
	L["Redemption"] = "Erl\195\182sung"
	L["Ancestral Spirit"] = "Geist der Ahnen"
	L["Libram of Divinity"] = "Buchband der Offenbarung"
	L["Libram of Light"] = "Buchband des Lichts"
	L["Totem of Sustaining"] = "Totem der Erhaltung"
	L["Totem of Life"] = "Totem des Lebens"
	L["Power Infusion"] = "Seele der Macht"
	L["Divine Favor"] = "G\195\182ttliche Gunst"
	L["Nature Aligned"] = "Naturverbundenheit"
	L["Crusader's Wrath"] = "Zorn des Kreuzfahrers"
	L["The Furious Storm"] = "Der wilde Sturm"
	L["Holy Power"] = "Heilige Kraft"
	L["Prayer Beads Blessing"] = "Segen der Gebetsperlen"
	L["Chromatic Infusion"] = "Erf\195\188llt mit chromatischer Macht"
	L["Ascendance"] = "\154berlegenheit"
	L["Ephemeral Power"] = "Ephemere Macht"
	L["Unstable Power"] = "Instabile Macht"
	L["Healing of the Ages"] = "Heilung der Urzeiten"
	L["Essence of Sapphiron"] = "Essenz Saphirons"
	L["The Eye of the Dead"] = "Das Auge des Todes"
	L["Mortal Strike"] = "T\195\182dlicher Stoß"
	L["Wound Poison"] = "Wundgift"
	L["Curse of the Deadwood"] = "Fluch der Totenwaldfelle"
	L["Veil of Shadow"] = "Schattenschleier"
	L["Gehennas' Curse"] = "Gehennas' Fluch"
	L["Mortal Wound"] = "Trauma"
	L["Necrotic Poison"] = "Nekrotisches Gift"
	L["Necrotic Aura"] = "Nekrotische Aura"
	L["Healing Way"] = "Pfad der Heilung"
	L["Warsong Gulch"] = "Kriegshymnenschlucht"
	L["Arathi Basin"] = "Arathibecken"
	L["Alterac Valley"] = "Alteractal"
	L["Blessing of Light"] = "Segen des Lichts"
	L["Blood Fury"] = "Kochendes Blut"
	L["Set: Increases the duration of your Rejuvenation spell by 3 sec."] = "Set: Erh\195\182ht die Dauer Eures Zaubers \'Verj\195\188ngung\' um 3 Sek."
	L["Set: Increases the duration of your Renew spell by 3 sec."] = "Set: Erh\195\182ht die Dauer Eures Zaubers 'Erneuerung' um 3 Sek."
elseif ( GetLocale() == "frFR" ) then
	L["Renew"] = "R\195\169novation"
	L["Rejuvenation"] = "R\195\169cup\195\169ration"
	L["Holy Light"] = "Lumi\195\168re sacr\195\169e"
	L["Flash of Light"] = "Eclair lumineux"
	L["Healing Wave"] = "Vague de soins"
	L["Lesser Healing Wave"] = "Vague de soins inf\195\169rieurs"
	L["Chain Heal"] = "Salve de gu\195\169rison"
	L["Lesser Heal"] = "Soins inf\195\169rieurs"
	L["Heal"] = "Soins"
	L["Flash Heal"] = "Soins rapides"
	L["Greater Heal"] = "Soins sup\195\169rieurs"
	L["Prayer of Healing"] = "Pri\195\168re de soins"
	L["Healing Touch"] = "Toucher gu\195\169risseur"
	L["Regrowth"] = "R\195\169tablissement"
	L["Resurrection"] = "R\195\169surrection"
	L["Rebirth"] = "Renaissance"
	L["Redemption"] = "R\195\169demption"
	L["Ancestral Spirit"] = "Esprit ancestral"
	L["Libram of Divinity"] = "Libram de divinit\195\169"
	L["Libram of Light"] = "Libram de lumi\195\168re"
	L["Totem of Sustaining"] = "Totem de soutien"
	L["Totem of Life"] = "Totem de vie"
	L["Power Infusion"] = "Infusion de puissance"
	L["Divine Favor"] = "Faveur divine"
	L["Nature Aligned"] = "Alignement sur la nature"
	L["Crusader's Wrath"] = "Col\195\168re du crois\195\169"
	L["The Furious Storm"] = "La temp\195\170te furieuse"
	L["Holy Power"] = "Puissance sacr\195\169e"
	L["Prayer Beads Blessing"] = "B\195\169n\195\169diction du chapelet"
	L["Chromatic Infusion"] = "Infusion chromatique"
	L["Ascendance"] = "Ascendance"
	L["Ephemeral Power"] = "Puissance \195\169ph\195\169m\195\168re"
	L["Unstable Power"] = "Puissance instable"
	L["Healing of the Ages"] = "Soins des \195\162ges"
	L["Essence of Sapphiron"] = "Essence de Saphiron"
	L["The Eye of the Dead"] = "L'Oeil du mort"
	L["Mortal Strike"] = "Frappe mortelle"
	L["Wound Poison"] = "Poison douloureux"
	L["Curse of the Deadwood"] = "Mal\195\169diction des Mort-bois"
	L["Veil of Shadow"] = "Voile de l'ombre"
	L["Gehennas' Curse"] = "Mal\195\169diction de Gehennas"
	L["Mortal Wound"] = "Blessures mortelles"
	L["Necrotic Poison"] = "Poison n\195\169crotique"
	L["Necrotic Aura"] = "Aura n\195\169crotique"
	L["Healing Way"] = "Flots de soins"
	L["Warsong Gulch"] = "Goulet des Warsong"
	L["Arathi Basin"] = "Bassin d'Arathi"
	L["Alterac Valley"] = "Vall\195\169e d'Alterac"
	L["Blood Fury"] = "Fureur sanguinaire"
	L["Blessing of Light"] = "B\195\169n\195\169diction de lumi\195\168re"
	L["Set: Increases the duration of your Rejuvenation spell by 3 sec."] = "Set: Augmente la dur\195\169e de votre sort R\195\169cup\195\169ration de 3 s."
	L["Set: Increases the duration of your Renew spell by 3 sec."] = "Set: Augmente la dur\195\169e de votre sort R\195\169novation de 3 s."
else
	L["Renew"] = "Renew"
	L["Rejuvenation"] = "Rejuvenation"
	L["Holy Light"] = "Holy Light"
	L["Flash of Light"] = "Flash of Light"
	L["Healing Wave"] = "Healing Wave"
	L["Lesser Healing Wave"] = "Lesser Healing Wave"
	L["Chain Heal"] = "Chain Heal"
	L["Lesser Heal"] = "Lesser Heal"
	L["Heal"] = "Heal"
	L["Flash Heal"] = "Flash Heal"
	L["Greater Heal"] = "Greater Heal"
	L["Prayer of Healing"] = "Prayer of Healing"
	L["Healing Touch"] = "Healing Touch"
	L["Regrowth"] = "Regrowth"
	L["Resurrection"] = "Resurrection"
	L["Rebirth"] = "Rebirth"
	L["Redemption"] = "Redemption"
	L["Ancestral Spirit"] = "Ancestral Spirit"
	L["Libram of Divinity"] = "Libram of Divinity"
	L["Libram of Light"] = "Libram of Light"
	L["Totem of Sustaining"] = "Totem of Sustaining"
	L["Totem of Life"] = "Totem of Life"
	L["Power Infusion"] = "Power Infusion"
	L["Divine Favor"] = "Divine Favor"
	L["Nature Aligned"] = "Nature Aligned"
	L["Crusader's Wrath"] = "Crusader's Wrath"
	L["The Furious Storm"] = "The Furious Storm"
	L["Holy Power"] = "Holy Power"
	L["Prayer Beads Blessing"] = "Prayer Beads Blessing"
	L["Chromatic Infusion"] = "Chromatic Infusion"
	L["Ascendance"] = "Ascendance"
	L["Ephemeral Power"] = "Ephemeral Power"
	L["Unstable Power"] = "Unstable Power"
	L["Healing of the Ages"] = "Healing of the Ages"
	L["Essence of Sapphiron"] = "Essence of Sapphiron"
	L["The Eye of the Dead"] = "The Eye of the Dead"
	L["Mortal Strike"] = "Mortal Strike"
	L["Wound Poison"] = "Wound Poison"
	L["Curse of the Deadwood"] = "Curse of the Deadwood"
	L["Veil of Shadow"] = "Veil of Shadow"
	L["Gehennas' Curse"] = "Gehennas' Curse"
	L["Mortal Wound"] = "Mortal Wound"
	L["Necrotic Poison"] = "Necrotic Poison"
	L["Necrotic Aura"] = "Necrotic Aura"
	L["Healing Way"] = "Healing Way"
	L["Warsong Gulch"] = "Warsong Gulch"
	L["Arathi Basin"] = "Arathi Basin"
	L["Alterac Valley"] = "Alterac Valley"
	L["Blessing of Light"] = "Blessing of Light"
	L["Blood Fury"] = "Blood Fury"
	L["Set: Increases the duration of your Rejuvenation spell by 3 sec."] = "Set: Increases the duration of your Rejuvenation spell by 3 sec."
	L["Set: Increases the duration of your Renew spell by 3 sec."] = "Set: Increases the duration of your Renew spell by 3 sec."
end
	
------------------------------------------------
-- activate, enable, disable
------------------------------------------------

local function activate(self, oldLib, oldDeactivate)
	HealComm = self
	if oldLib then
		self.Heals = oldLib.Heals
		self.GrpHeals = oldLib.GrpHeals
		self.Lookup = oldLib.Lookup
		self.Hots = oldLib.Hots
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
	if not self.Hots then
		self.Hots = {}
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
	self:RegisterEvent("SPELLCAST_STOP", HealComm.OnEvent)
	self:RegisterEvent("CHAT_MSG_ADDON", HealComm.OnEvent)
	self:RegisterEvent("UNIT_AURA", HealComm.OnEvent)
	self:RegisterEvent("UNIT_HEALTH" , HealComm.OnHealth)
end

------------------------------------------------
-- Addon Code
------------------------------------------------

function strmatch(str, pat, init)
	local a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a13,a14,a15,a16,a17,a18,a19,a20 = string.find(str, pat, init)
	return a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a13,a14,a15,a16,a17,a18,a19,a20
end

HealComm.Spells = {
	[L["Holy Light"]] = {
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
	[L["Flash of Light"]] = {
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
	[L["Healing Wave"]] = {
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
	[L["Lesser Healing Wave"]] = {
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
	[L["Chain Heal"]] = {
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
	[L["Lesser Heal"]] = {
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
	[L["Heal"]] = {
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
	[L["Flash Heal"]] = {
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
	[L["Greater Heal"]] = {
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
	[L["Prayer of Healing"]] = {
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
		[5] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(2,14)
			local _,Spirit,_,_ = UnitStat("player",5)
			local sgMod = Spirit * 5*talentRank/100
			local _,_,_,_,talentRank2,_ = GetTalentInfo(2,15)
			local shMod = 2*talentRank2/100 + 1
			return (1070*shMod+((3/3.5/3) * (SpellPower+sgMod)))
		end;
	};
	[L["Healing Touch"]] = {
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
	[L["Regrowth"]] = {
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
	[L["Resurrection"]] = true;
	[L["Rebirth"]] = true;
	[L["Redemption"]] = true;
	[L["Ancestral Spirit"]] = true;
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
local healcomm_SpellCast = {}

local healcommTip = CreateFrame("GameTooltip", "healcommTip", nil, "GameTooltipTemplate")
healcommTip:SetOwner(WorldFrame, "ANCHOR_NONE")

HealComm.Buffs = {
	[L["Power Infusion"]] = {amount = 0, mod = 0.2, icon = "Interface\\Icons\\Spell_Holy_PowerInfusion"};
	[L["Divine Favor"]] = {amount = 0, mod = 0.5, icon = "Interface\\Icons\\Spell_Holy_Heal"};
	[L["Nature Aligned"]] = {amount = 0, mod = 0.2, icon = "Interface\\Icons\\Spell_Nature_SpiritArmor"};
	[L["Crusader's Wrath"]] = {amount = 95, mod = 0, icon = "Interface\\Icons\\Spell_Nature_GroundingTotem"};
	[L["The Furious Storm"]] = {amount = 95, mod = 0, icon = "Interface\\Icons\\Spell_Nature_CallStorm"};
	[L["Holy Power"]] = {amount = 80, mod = 0, icon = "Interface\\Icons\\Spell_Holy_HolyNova"};
	[L["Prayer Beads Blessing"]] = {amount = 190, mod = 0, icon = "Interface\\Icons\\Inv_Jewelry_Necklace_11"};
	[L["Chromatic Infusion"]] = {amount = 190, mod = 0, icon = "Interface\\Icons\\Spell_Holy_MindVision"};
	[L["Ascendance"]] = {amount = 75, mod = 0, icon = "Interface\\Icons\\Spell_Lightning_LightningBolt01"};
	[L["Ephemeral Power"]] = {amount = 175, mod = 0, icon = "Interface\\Icons\\Spell_Holy_MindVision"};
	[L["Unstable Power"]] = {amount = 34, mod = 0, icon = "Interface\\Icons\\Spell_Lightning_LightningBolt01"};
	[L["Healing of the Ages"]] = {amount = 350, mod = 0, icon = "Interface\\Icons\\Spell_Nature_HealingWaveGreater"};
	[L["Essence of Sapphiron"]] = {amount = 130, mod = 0, icon = "Interface\\Icons\\Inv_Trinket_Naxxramas06"};
	[L["The Eye of the Dead"]] = {amount = 450, mod = 0, icon = "Interface\\Icons\\Inv_Trinket_Naxxramas01"}
}
	
HealComm.Debuffs = {
	[L["Mortal Strike"]] = {amount = 0, mod = 0.5, icon = "Interface\\Icons\\Ability_Warrior_SavageBlow"};
	[L["Wound Poison"]] = {amount = -135, mod = 0, icon = "Interface\\Icons\\Inv_Misc_Herb_16"};
	[L["Curse of the Deadwood"]] = {amount = 0, mod = 0.5, icon = "Interface\\Icons\\Spell_Shadow_GatherShadows"};
	[L["Veil of Shadow"]] = {amount = 0, mod = 0.75, icon = "Interface\\Icons\\Spell_Shadow_GatherShadows"};
	[L["Gehennas' Curse"]] = {amount = 0, mod = 0.75, icon = "Interface\\Icons\\Spell_Shadow_GatherShadows"};
	[L["Mortal Wound"]] = {amount = 0, mod = 0.1, icon = "Interface\\Icons\\Ability_CriticalStrike"};
	[L["Necrotic Poison"]] = {amount = 0, mod = 0.9, icon = "Interface\\Icons\\Ability_Creature_Poison_03"};
	[L["Blood Fury"]] = {amount = 0, mod = 0.5, icon = "Interface\\Icons\\Ability_Rogue_FeignDeath"};
	[L["Necrotic Aura"]] = {amount = 0, mod = 1, icon = "Interface\\Icons\\Ability_Creature_Disease_05"}
}
	
local function getSetBonus()
	healcommTip:SetInventoryItem("player", 1)
	local text = getglobal("healcommTipTextLeft"..healcommTip:NumLines()):GetText()
	if text == L["Set: Increases the duration of your Rejuvenation spell by 3 sec."] or text == L["Set: Increases the duration of your Renew spell by 3 sec."] then
		return true
	else
		return nil
	end
end
	
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
		if buffName == L["Blessing of Light"] then
			local HLBonus, FoLBonus = strmatch(healcommTipTextLeft2:GetText(),"(%d+).-(%d+)")
			if (spell == L["Flash of Light"]) then
				targetpower = FoLBonus + targetpower
			elseif spell == L["Holy Light"] then
				targetpower = HLBonus + targetpower
			end
		end
		if buffName == L["Healing Way"] and spell == L["Healing Wave"] then
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
	if HealComm.SpecialEventScheduler:IsEventScheduled("Healcomm_"..caster) then
		HealComm.SpecialEventScheduler:CancelScheduledEvent("Healcomm_"..caster)
	end
	if HealComm.Lookup[caster] then
		HealComm.Heals[HealComm.Lookup[caster]][caster] = nil
		HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Healupdate", HealComm.Lookup[caster])
		HealComm.Lookup[caster] = nil
	end
end

function HealComm.startHeal(caster, target, size, casttime)
	HealComm.SpecialEventScheduler:ScheduleEvent("Healcomm_"..caster, HealComm.stopHeal, (casttime/1000), caster)
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
	HealComm.SpecialEventScheduler:CancelScheduledEvent("Healcomm_"..caster)
	if HealComm.Lookup[caster] and HealComm.Heals[HealComm.Lookup[caster]] then
		HealComm.Heals[HealComm.Lookup[caster]][caster].ctime = HealComm.Heals[HealComm.Lookup[caster]][caster].ctime + (delay/1000)
		HealComm.SpecialEventScheduler:ScheduleEvent("Healcomm_"..caster, HealComm.stopHeal, (HealComm.Heals[HealComm.Lookup[caster]][caster].ctime-GetTime()), caster)
	end
end

function HealComm.startGrpHeal(caster, size, casttime, party1, party2, party3, party4, party5)
	HealComm.SpecialEventScheduler:ScheduleEvent("Healcomm_"..caster, HealComm.stopGrpHeal, (casttime/1000), caster)
	HealComm.GrpHeals[caster] = {amount = size, ctime = (casttime/1000)+GetTime(), targets = {party1, party2, party3, party4, party5}}
	for i=1,getn(HealComm.GrpHeals[caster].targets) do
		HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Healupdate", HealComm.GrpHeals[caster].targets[i])
	end
end

function HealComm.stopGrpHeal(caster)
	if HealComm.SpecialEventScheduler:IsEventScheduled("Healcomm_"..caster) then
		HealComm.SpecialEventScheduler:CancelScheduledEvent("Healcomm_"..caster)
	end
	local targets
	if HealComm.GrpHeals[caster] then
		targets = HealComm.GrpHeals[caster].targets
	end
	HealComm.GrpHeals[caster] = nil
	if targets then
		for i=1,getn(targets) do
			HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Healupdate", targets[i])
		end
	end
end

function HealComm.delayGrpHeal(caster, delay)
	HealComm.SpecialEventScheduler:CancelScheduledEvent("Healcomm_"..caster)
	if HealComm.GrpHeals[caster] then
		HealComm.GrpHeals[caster].ctime = HealComm.GrpHeals[caster].ctime + (delay/1000)
		HealComm.SpecialEventScheduler:ScheduleEvent("Healcomm_"..caster, HealComm.stopGrpHeal, (HealComm.GrpHeals[caster].ctime-GetTime()), caster)
	end
end

function HealComm.startResurrection(caster, target)
	if not HealComm.pendingResurrections[target] then
		HealComm.pendingResurrections[target] = {}
	end
	HealComm.pendingResurrections[target][caster] = GetTime()+70
	HealComm.SpecialEventScheduler:ScheduleEvent("Healcomm_"..caster..target, HealComm.RessExpire, 70, caster, target)
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
	if zone == L["Warsong Gulch"] or zone == L["Arathi Basin"] or zone == L["Alterac Valley"] then
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
			local targetpower, targetmod = healcomm_SpellCast[4], healcomm_SpellCast[5]
			local Bonus = Bonus + buffpower
			healcomm_spellIsCasting = arg1
			local amount = ((math.floor(HealComm.Spells[healcomm_SpellCast[1]][tonumber(healcomm_SpellCast[2])](Bonus))+targetpower)*buffmod*targetmod)
			if arg1 == L["Prayer of Healing"] then
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
		for _,val in pairs(healcomm_SpellCast) do
			val = nil
		end
	elseif (event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED") and HealComm.Spells[healcomm_spellIsCasting] then
		if healcomm_spellIsCasting == L["Prayer of Healing"] then
			HealComm.SendAddonMessage("GrpHealstop")
			HealComm.stopGrpHeal(UnitName("player"))
		else
			HealComm.SendAddonMessage("Healstop")
			HealComm.stopHeal(UnitName("player"))
		end
		healcomm_spellIsCasting = nil
		for _,val in pairs(healcomm_SpellCast) do
			val = nil
		end
		healcomm_RankRank = nil
		healcomm_SpellSpell =  nil
	elseif (event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED") and HealComm.Resurrections[healcomm_spellIsCasting] then
		HealComm.SendAddonMessage("Resurrection/stop/")
		healcomm_spellIsCasting = nil
		for _,val in pairs(healcomm_SpellCast) do
			val = nil
		end
		healcomm_RankRank = nil
		healcomm_SpellSpell =  nil
		HealComm.cancelResurrection(UnitName("player"))
	elseif event == "SPELLCAST_DELAYED" then
		if healcomm_spellIsCasting == L["Prayer of Healing"] then
			HealComm.SendAddonMessage("GrpHealdelay/"..arg1.."/")
			HealComm.delayGrpHeal(UnitName("player"), arg1)
		else
			HealComm.SendAddonMessage("Healdelay/"..arg1.."/")
			HealComm.delayHeal(UnitName("player"), arg1)
		end
	elseif event == "SPELLCAST_STOP" and healcomm_SpellCast then
		local targetUnit = roster:GetUnitIDFromName(healcomm_SpellCast[3])
		if not targetUnit then
			healcomm_spellIsCasting = nil
			for _,val in pairs(healcomm_SpellCast) do
				val = nil
			end
			healcomm_RankRank = nil
			healcomm_SpellSpell =  nil
			return
		end
		if healcomm_SpellCast and healcomm_SpellCast[1] == L["Renew"] then
			local dur = getSetBonus() and 18 or 15
			HealComm.SendAddonMessage("Renew/"..healcomm_SpellCast[3].."/"..dur.."/")
			if not HealComm.Hots[healcomm_SpellCast[3]] then
				HealComm.Hots[healcomm_SpellCast[3]] = {}
			end
			if not HealComm.Hots[healcomm_SpellCast[3]]["Renew"] then
				HealComm.Hots[healcomm_SpellCast[3]]["Renew"]= {}
			end
			HealComm.Hots[healcomm_SpellCast[3]]["Renew"].start = GetTime()
			HealComm.Hots[healcomm_SpellCast[3]]["Renew"].dur = dur
			HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Hotupdate", targetUnit, "Renew")
			healcomm_spellIsCasting = nil
			for _,val in pairs(healcomm_SpellCast) do
				val = nil
			end
			healcomm_RankRank = nil
			healcomm_SpellSpell =  nil
		elseif healcomm_SpellCast and healcomm_SpellCast[1] == L["Rejuvenation"] then
			local dur = getSetBonus() and 15 or 12
			HealComm.SendAddonMessage("Reju/"..healcomm_SpellCast[3].."/"..dur.."/")
			if not HealComm.Hots[healcomm_SpellCast[3]] then
				HealComm.Hots[healcomm_SpellCast[3]] = {}
			end
			if not HealComm.Hots[healcomm_SpellCast[3]]["Reju"] then
				HealComm.Hots[healcomm_SpellCast[3]]["Reju"]= {}
			end
			HealComm.Hots[healcomm_SpellCast[3]]["Reju"].start = GetTime()
			HealComm.Hots[healcomm_SpellCast[3]]["Reju"].dur = dur
			HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Hotupdate", targetUnit, "Rejuvenation")
			healcomm_spellIsCasting = nil
			for _,val in pairs(healcomm_SpellCast) do
				val = nil
			end
			healcomm_RankRank = nil
			healcomm_SpellSpell =  nil
		elseif healcomm_SpellCast and healcomm_SpellCast[1] == L["Regrowth"] then
			local dur = 21
			HealComm.SendAddonMessage("Regr/"..healcomm_SpellCast[3].."/"..dur.."/")
			if not HealComm.Hots[healcomm_SpellCast[3]] then
				HealComm.Hots[healcomm_SpellCast[3]] = {}
			end
			if not HealComm.Hots[healcomm_SpellCast[3]]["Regr"] then
				HealComm.Hots[healcomm_SpellCast[3]]["Regr"]= {}
			end
			HealComm.Hots[healcomm_SpellCast[3]]["Regr"].start = GetTime()
			HealComm.Hots[healcomm_SpellCast[3]]["Regr"].dur = dur
			HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Hotupdate", targetUnit, "Regrowth")
			healcomm_spellIsCasting = nil
			for _,val in pairs(healcomm_SpellCast) do
				val = nil
			end
			healcomm_RankRank = nil
			healcomm_SpellSpell =  nil
		end
	elseif event == "CHAT_MSG_ADDON" then
		if arg1 == "HealComm" and arg4 ~= UnitName("player") then
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
			elseif arg2 == "GrpHealstop" then
				HealComm.stopGrpHeal(arg4)
			elseif result[1] == "GrpHealdelay" then
				HealComm.delayGrpHeal(arg4, result[2])
			elseif result[1] == "Renew" then
				if not HealComm.Hots[result[2]] then
					HealComm.Hots[result[2]] = {}
				end
				if not HealComm.Hots[result[2]]["Renew"] then
					HealComm.Hots[result[2]]["Renew"]= {}
				end
				HealComm.Hots[result[2]]["Renew"].dur = result[3]
				HealComm.Hots[result[2]]["Renew"].start = GetTime()
				local targetUnit = roster:GetUnitIDFromName(result[2])
				HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Hotupdate", targetUnit, "Renew")
			elseif result[1] == "Reju" then
				if not HealComm.Hots[result[2]] then
					HealComm.Hots[result[2]] = {}
				end
				if not HealComm.Hots[result[2]]["Reju"] then
					HealComm.Hots[result[2]]["Reju"]= {}
				end
				HealComm.Hots[result[2]]["Reju"].dur = result[3]
				HealComm.Hots[result[2]]["Reju"].start = GetTime()
				local targetUnit = roster:GetUnitIDFromName(result[2])
				HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Hotupdate", targetUnit, "Rejuvenation")
			elseif result[1] == "Regr" then
				if not HealComm.Hots[result[2]] then
					HealComm.Hots[result[2]] = {}
				end
				if not HealComm.Hots[result[2]]["Regr"] then
					HealComm.Hots[result[2]]["Regr"]= {}
				end
				HealComm.Hots[result[2]]["Regr"].dur = result[3]
				HealComm.Hots[result[2]]["Regr"].start = GetTime()
				local targetUnit = roster:GetUnitIDFromName(result[2])
				HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Hotupdate", targetUnit, "Regrowth")
			end
		end
	elseif event == "UNIT_AURA" then
		local name = UnitName(arg1)
		if HealComm.Hots[name] and (HealComm.Hots[name]["Regr"] or HealComm.Hots[name]["Reju"] or HealComm.Hots[name]["Renew"]) then
			local regr,reju,renew
			for i=1,32 do
				if not UnitBuff(arg1,i) then
					break
				end
				healcommTip:ClearLines()
				healcommTip:SetUnitBuff(arg1,i)
				regr = regr or healcommTipTextLeft1:GetText() == L["Regrowth"]
				reju = reju or healcommTipTextLeft1:GetText() == L["Rejuvenation"]
				renew = renew or healcommTipTextLeft1:GetText() == L["Renew"]
			end
			if not regr then
				HealComm.Hots[name]["Regr"] = nil
				HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Hotupdate", arg1, "Regrowth")
			end
			if not reju then
				HealComm.Hots[name]["Reju"] = nil
				HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Hotupdate", arg1, "Rejuvenation")
			end
			if not renew then
				HealComm.Hots[name]["Renew"] = nil
				HealComm.SpecialEventScheduler:TriggerEvent("HealComm_Hotupdate", arg1, "Renew")
			end			
		end
	end
end

function HealComm:getRegrTime(unit)
	if unit == UNKNOWNOBJECT or unit == UKNOWNBEING then
		return
 	end
	local dbUnit = HealComm.Hots[UnitName(unit)]
	if dbUnit and dbUnit["Regr"] and (dbUnit["Regr"].start + dbUnit["Regr"].dur) > GetTime() then
		return dbUnit["Regr"].start, dbUnit["Regr"].dur
	else
		return
	end
end
	
function HealComm:getRejuTime(unit)
	if unit == UNKNOWNOBJECT or unit == UKNOWNBEING then
		return
 	end
	local dbUnit = HealComm.Hots[UnitName(unit)]
	if dbUnit and dbUnit["Reju"] and (dbUnit["Reju"].start + dbUnit["Reju"].dur) > GetTime() then
		return dbUnit["Reju"].start, dbUnit["Reju"].dur
	else
		return
	end
end

function HealComm:getRenewTime(unit)
	if unit == UNKNOWNOBJECT or unit == UKNOWNBEING then
		return
 	end
	local dbUnit = HealComm.Hots[UnitName(unit)]
	if dbUnit and dbUnit["Renew"] and (dbUnit["Renew"].start + dbUnit["Renew"].dur) > GetTime() then
		return dbUnit["Renew"].start, dbUnit["Renew"].dur
	else
		return
	end
end

function HealComm:getHeal(unit)
	if unit == UNKNOWNOBJECT or unit == UKNOWNBEING then
		return 0
 	end
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
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") ) then
       -- Spell is being cast on the current target.  
       -- If ClearTarget() had been called, we'd be waiting target
		if UnitIsPlayer("target") then
			healcomm_ProcessSpellCast(spellName, rank, UnitName("target"))
		else
			for _,val in pairs(healcomm_SpellCast) do
				val = nil
			end
		end
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
			healcomm_RankRank = rank
		else
			if UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") and onSelf ~= 1 then
				if UnitIsPlayer("target") then
					healcomm_ProcessSpellCast(spellName, rank, UnitName("target"))
				else
					for _,val in pairs(healcomm_SpellCast) do
						val = nil
					end
				end
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
function healcomm_newUseAction(slot, checkCursor, onSelf)
	healcommTip:ClearLines()
	healcommTip:SetAction(slot)
	local spellName = healcommTipTextLeft1:GetText()
	healcomm_SpellSpell = spellName
	
	-- Call the original function
	healcomm_oldUseAction(slot, checkCursor, onSelf)
	-- Test to see if this is a macro
	if ( GetActionText(slot) or not healcomm_SpellSpell ) then
		return
	end
	local rank = healcommTipTextRight1:GetText()
	if rank then
		_,_,rank = string.find(rank,"(%d+)")
	end
	if not rank then
		rank = 1
	end
	healcomm_RankRank = rank
	if ( SpellIsTargeting() ) then
		-- Spell is waiting for a target
		return
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") and onSelf ~= 1) then
		-- Spell is being cast on the current target
		if UnitIsPlayer("target") then
			healcomm_ProcessSpellCast(spellName, rank, UnitName("target"))
		else
			for _,val in pairs(healcomm_SpellCast) do
				val = nil
			end
		end
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
		if UnitIsPlayer(unit) then
			healcomm_ProcessSpellCast(healcomm_SpellSpell, healcomm_RankRank, UnitName(unit))
		else
			for _,val in pairs(healcomm_SpellCast) do
				val = nil
			end
		end
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
	-- Look to see if we're currently waiting for a target internally
	-- If we are, then well glean the target info here.
	if ( healcomm_SpellSpell and UnitExists(unit) ) and UnitIsPlayer(unit) then
		healcomm_ProcessSpellCast(healcomm_SpellSpell, healcomm_RankRank, UnitName(unit))
	else
		for _,val in pairs(healcomm_SpellCast) do
			val = nil
		end
	end
	-- Call the original function
	healcomm_oldTargetUnit(unit)
end
TargetUnit = healcomm_newTargetUnit

function healcomm_ProcessSpellCast(spellName, rank, targetName)
	local unit = roster:GetUnitIDFromName(targetName)
	if ( spellName and rank and targetName and unit ) then
		local power, mod = GetTargetSpellPower(spellName)
		healcomm_SpellCast[1] = spellName
		healcomm_SpellCast[2] = rank
		healcomm_SpellCast[3] = targetName
		healcomm_SpellCast[4] = power
		healcomm_SpellCast[5] = mod
	end
end

HealComm:SetScript("OnEvent", HealComm.OnEvent)

AceLibrary:Register(HealComm, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
