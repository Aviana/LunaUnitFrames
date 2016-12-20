--[[
Name: HealComm-1.0
Revision: $Rev: 11400 $
Author(s): aviana
Website: https://github.com/Aviana
Description: A library to provide communication of heals and resurrections.
Dependencies: AceLibrary, AceEvent-2.0, RosterLib-2.0
]]

local MAJOR_VERSION = "HealComm-1.0"
local MINOR_VERSION = "$Revision: 11400 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("RosterLib-2.0") then error(MAJOR_VERSION .. " requires RosterLib-2.0") end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end
if not AceLibrary:HasInstance("AceHook-2.1") then error(MAJOR_VERSION .. " requires AceHook-2.1") end

local roster = AceLibrary("RosterLib-2.0")
local HealComm = {}

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
	L["Lesser Heal"] = "Geringes Heilen"
	L["Heal"] = "Heilen"
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
	L["^Corpse of (.+)$"] = "^Leichnam von (.+)$"
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
	L["^Corpse of (.+)$"] = "^Cadavre |2 (.+)$"
elseif GetLocale() == "zhCN" then
	if AceLibrary:HasInstance("Babble-Spell-2.2") then
		L.BS = AceLibrary("Babble-Spell-2.2")
	end
	if AceLibrary:HasInstance("Babble-Zone-2.2") then
		L.BZ = AceLibrary("Babble-Zone-2.2")
	end
	setmetatable(L, {__index = function(table, key)
		if table.BS and table.BS:HasTranslation(key) then
			return table.BS[key]
		elseif table.BZ and table.BZ:HasTranslation(key) then
			return table.BZ[key]
		end
	end})
	L["Libram of Divinity"] = "神性圣契"
	L["Libram of Light"] = "光明圣契"
	L["Necrotic Aura"] = "死灵光环"  -- 这个技能不知道是否存在
	L["Set: Increases the duration of your Rejuvenation spell by 3 sec."] = "套装：使你的回春术的持续时间延长3秒。" -- T2
	L["Set: Increases the duration of your Renew spell by 3 sec."] = "套装：使你的恢复术的持续时间延长3秒。" -- T2.5
	L["Totem of Life"] = "生命图腾"
	L["Totem of Sustaining"] = "持久图腾"
	L["^Corpse of (.+)$"] = "(.+)的尸体"
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
	L["^Corpse of (.+)$"] = "^Corpse of (.+)$"
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
		self.pendingResurrections = oldlib.pendingResurrections
		self.Hots = oldLib.Hots
		self.SpellCastInfo = oldLib.SpellCastInfo
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
	if not self.SpellCastInfo then
		self.SpellCastInfo = {}
	end
	if oldDeactivate then oldDeactivate(oldLib) end
end


local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		local AceEvent = instance
		AceEvent:embed(self)
		self:RegisterEvent("SPELLCAST_START")
		self:RegisterEvent("SPELLCAST_INTERRUPTED", "SPELLCAST_FAILED")
		self:RegisterEvent("SPELLCAST_FAILED")
		self:RegisterEvent("SPELLCAST_DELAYED")
		self:RegisterEvent("SPELLCAST_STOP")
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("UNIT_HEALTH")
		self:TriggerEvent("HealComm_Enabled")
	end
	if major == "AceHook-2.1" then
		local AceHook = instance
		AceHook:embed(self)
		self:Hook("CastSpell")
		self:Hook("CastSpellByName")
		self:HookScript(WorldFrame, "OnMouseDown")
		self:Hook("UseAction")
		self:Hook("SpellTargetUnit")
		self:Hook("SpellStopTargeting")
		self:Hook("TargetUnit")
	end
end

function HealComm:Enable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end


function HealComm:Disable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
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
			return (43*gnMod+((1.5/3.5) * SpellPower * (1-((20-4)*0.0375))))
		end;
		[2] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return (101*gnMod+((2/3.5) * SpellPower * (1-((20-13)*0.0375))))
		end;
		[3] = function (SpellPower)
			local _,_,_,_,talentRank,_ = GetTalentInfo(3,12)
			local gnMod = 2*talentRank/100 + 1
			return (220*gnMod+((2.5/3.5) * SpellPower))
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

local Resurrections = {
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

local healcommTip = CreateFrame("GameTooltip", "healcommTip", nil, "GameTooltipTemplate")
healcommTip:SetOwner(WorldFrame, "ANCHOR_NONE")

local Buffs = {
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
	
local Debuffs = {
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
		if Buffs[buffName] and Buffs[buffName].icon == buffTexture then
			Spellpower = (Buffs[buffName].amount * buffApplications) + Spellpower
			healmod = (Buffs[buffName].mod * buffApplications) + healmod
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
		if Debuffs[debuffName] then
			targetpower = (Debuffs[debuffName].amount * debuffApplications) + targetpower
			targetmod = (1-(Debuffs[debuffName].mod * debuffApplications)) * targetmod
		end
	end
	return targetpower, targetmod
end			

function HealComm:UNIT_HEALTH()
	local name = UnitName(arg1)
	if self.pendingResurrections[name] then
		for k,v in pairs(self.pendingResurrections[name]) do
			self.pendingResurrections[name][k] = nil
		end
		self:TriggerEvent("HealComm_Ressupdate", name)
	end
end
			
function HealComm:stopHeal(caster)
	if self:IsEventScheduled("Healcomm_"..caster) then
		self:CancelScheduledEvent("Healcomm_"..caster)
	end
	if self.Lookup[caster] then
		self.Heals[self.Lookup[caster]][caster] = nil
		self:TriggerEvent("HealComm_Healupdate", self.Lookup[caster])
		self.Lookup[caster] = nil
	end
end

function HealComm:startHeal(caster, target, size, casttime)
	self:ScheduleEvent("Healcomm_"..caster, self.stopHeal, (casttime/1000), self, caster)
	if not self.Heals[target] then
		self.Heals[target] = {}
	end
	if self.Lookup[caster] then
		self.Heals[self.Lookup[caster]][caster] = nil
		self.Lookup[caster] = nil
	end
	self.Heals[target][caster] = {amount = size, ctime = (casttime/1000)+GetTime()}
	self.Lookup[caster] = target
	self:TriggerEvent("HealComm_Healupdate", target)
end

function HealComm:delayHeal(caster, delay)
	self:CancelScheduledEvent("Healcomm_"..caster)
	if self.Lookup[caster] and self.Heals[self.Lookup[caster]] then
		self.Heals[self.Lookup[caster]][caster].ctime = self.Heals[self.Lookup[caster]][caster].ctime + (delay/1000)
		self:ScheduleEvent("Healcomm_"..caster, self.stopHeal, (self.Heals[self.Lookup[caster]][caster].ctime-GetTime()), self, caster)
	end
end

function HealComm:startGrpHeal(caster, size, casttime, party1, party2, party3, party4, party5)
	self:ScheduleEvent("Healcomm_"..caster, self.stopGrpHeal, (casttime/1000), self, caster)
	self.GrpHeals[caster] = {amount = size, ctime = (casttime/1000)+GetTime(), targets = {party1, party2, party3, party4, party5}}
	for i=1,getn(self.GrpHeals[caster].targets) do
		self:TriggerEvent("HealComm_Healupdate", self.GrpHeals[caster].targets[i])
	end
end

function HealComm:stopGrpHeal(caster)
	if self:IsEventScheduled("Healcomm_"..caster) then
		self:CancelScheduledEvent("Healcomm_"..caster)
	end
	local targets
	if self.GrpHeals[caster] then
		targets = self.GrpHeals[caster].targets
	end
	self.GrpHeals[caster] = nil
	if targets then
		for i=1,getn(targets) do
			self:TriggerEvent("HealComm_Healupdate", targets[i])
		end
	end
end

function HealComm:delayGrpHeal(caster, delay)
	self:CancelScheduledEvent("Healcomm_"..caster)
	if self.GrpHeals[caster] then
		self.GrpHeals[caster].ctime = self.GrpHeals[caster].ctime + (delay/1000)
		self:ScheduleEvent("Healcomm_"..caster, self.stopGrpHeal, (self.GrpHeals[caster].ctime-GetTime()), self, caster)
	end
end

function HealComm:startResurrection(caster, target)
	if not self.pendingResurrections[target] then
		self.pendingResurrections[target] = {}
	end
	self.pendingResurrections[target][caster] = GetTime()+70
	self:ScheduleEvent("Healcomm_"..caster..target, self.RessExpire, 70, self, caster, target)
	self:TriggerEvent("HealComm_Ressupdate", target)
end

function HealComm:cancelResurrection(caster)
	for k,v in pairs(self.pendingResurrections) do
		if v[caster] and (v[caster]-GetTime()) > 60 then
			self.pendingResurrections[k][caster] = nil
			self:TriggerEvent("HealComm_Ressupdate", k)
		end
	end
end

function HealComm:RessExpire(caster, target)
	self.pendingResurrections[target][caster] = nil
	self:TriggerEvent("HealComm_Ressupdate", target)
end

function HealComm:SendAddonMessage(msg)
	local zone = GetRealZoneText()
	if zone == L["Warsong Gulch"] or zone == L["Arathi Basin"] or zone == L["Alterac Valley"] then
		SendAddonMessage("HealComm", msg, "BATTLEGROUND")
	else
		SendAddonMessage("HealComm", msg, "RAID")
	end
end

function HealComm:SPELLCAST_START()
	if ( self.SpellCastInfo and self.SpellCastInfo[1] == arg1 and self.Spells[arg1] ) then
		local Bonus = 0
		if BonusScanner then
			Bonus = tonumber(BonusScanner:GetBonus("HEAL"))
		end
		local buffpower, buffmod = GetBuffSpellPower(self)
		local targetpower, targetmod = self.SpellCastInfo[4], self.SpellCastInfo[5]
		local Bonus = Bonus + buffpower
		healcomm_spellIsCasting = arg1
		local amount = ((math.floor(self.Spells[self.SpellCastInfo[1]][tonumber(self.SpellCastInfo[2])](Bonus))+targetpower)*buffmod*targetmod)
		if arg1 == L["Prayer of Healing"] then
			local targets = {UnitName("player")}
			local targetsstring = UnitName("player").."/"
			for i=1,4 do
				if CheckInteractDistance("party"..i, 4) then
					table.insert(targets, i ,UnitName("party"..i))
					targetsstring = targetsstring..UnitName("party"..i).."/"
				end
			end
			self:SendAddonMessage("GrpHeal/"..amount.."/"..arg2.."/"..targetsstring)
			self:startGrpHeal(UnitName("player"), amount, arg2, targets[1], targets[2], targets[3], targets[4], targets[5])
		else
			self:SendAddonMessage("Heal/"..self.SpellCastInfo[3].."/"..amount.."/"..arg2.."/")
			self:startHeal(UnitName("player"), self.SpellCastInfo[3], amount, arg2)
		end
	elseif ( self.SpellCastInfo and self.SpellCastInfo[1] == arg1 and Resurrections[arg1] ) then
		self:SendAddonMessage("Resurrection/"..self.SpellCastInfo[3].."/start/")
		healcomm_spellIsCasting = arg1
		self:startResurrection(UnitName("player"), self.SpellCastInfo[3])
	end
	for _,val in pairs(self.SpellCastInfo) do
		val = nil
	end
end

function HealComm:SPELLCAST_FAILED()
	if self.Spells[healcomm_spellIsCasting] then
		if healcomm_spellIsCasting == L["Prayer of Healing"] then
			self:SendAddonMessage("GrpHealstop")
			self:stopGrpHeal(UnitName("player"))
		else
			self:SendAddonMessage("Healstop")
			self:stopHeal(UnitName("player"))
		end
		healcomm_spellIsCasting = nil
		for _,val in pairs(self.SpellCastInfo) do
			val = nil
		end
		self.CurrentSpellRank = nil
		self.CurrentSpellName =  nil
	elseif Resurrections[healcomm_spellIsCasting] then
		self:SendAddonMessage("Resurrection/stop/")
		healcomm_spellIsCasting = nil
		for _,val in pairs(self.SpellCastInfo) do
			val = nil
		end
		self.CurrentSpellRank = nil
		self.CurrentSpellName =  nil
		self:cancelResurrection(UnitName("player"))
	end
end

function HealComm:SPELLCAST_DELAYED()
	if healcomm_spellIsCasting == L["Prayer of Healing"] then
		self:SendAddonMessage("GrpHealdelay/"..arg1.."/")
		self:delayGrpHeal(UnitName("player"), arg1)
	else
		self:SendAddonMessage("Healdelay/"..arg1.."/")
		self:delayHeal(UnitName("player"), arg1)
	end
end

function HealComm:SPELLCAST_STOP()
	if not self.SpellCastInfo then return end
	local targetUnit = roster:GetUnitIDFromName(self.SpellCastInfo[3])
	if not targetUnit then
		healcomm_spellIsCasting = nil
		for _,val in pairs(self.SpellCastInfo) do
			val = nil
		end
		self.CurrentSpellRank = nil
		self.CurrentSpellName =  nil
		return
	end
	if self.SpellCastInfo[1] == L["Renew"] then
		local dur = getSetBonus() and 18 or 15
		self:SendAddonMessage("Renew/"..self.SpellCastInfo[3].."/"..dur.."/")
		if not self.Hots[self.SpellCastInfo[3]] then
			self.Hots[self.SpellCastInfo[3]] = {}
		end
		if not self.Hots[self.SpellCastInfo[3]]["Renew"] then
			self.Hots[self.SpellCastInfo[3]]["Renew"]= {}
		end
		self.Hots[self.SpellCastInfo[3]]["Renew"].start = GetTime()
		self.Hots[self.SpellCastInfo[3]]["Renew"].dur = dur
		self:TriggerEvent("HealComm_Hotupdate", targetUnit, "Renew")
		healcomm_spellIsCasting = nil
		for _,val in pairs(self.SpellCastInfo) do
			val = nil
		end
		self.CurrentSpellRank = nil
		self.CurrentSpellName =  nil
	elseif self.SpellCastInfo[1] == L["Rejuvenation"] then
		local dur = getSetBonus() and 15 or 12
		self:SendAddonMessage("Reju/"..self.SpellCastInfo[3].."/"..dur.."/")
		if not self.Hots[self.SpellCastInfo[3]] then
			self.Hots[self.SpellCastInfo[3]] = {}
		end
		if not self.Hots[self.SpellCastInfo[3]]["Reju"] then
			self.Hots[self.SpellCastInfo[3]]["Reju"]= {}
		end
		self.Hots[self.SpellCastInfo[3]]["Reju"].start = GetTime()
		self.Hots[self.SpellCastInfo[3]]["Reju"].dur = dur
		self:TriggerEvent("HealComm_Hotupdate", targetUnit, "Rejuvenation")
		healcomm_spellIsCasting = nil
		for _,val in pairs(self.SpellCastInfo) do
			val = nil
		end
		self.CurrentSpellRank = nil
		self.CurrentSpellName =  nil
	elseif self.SpellCastInfo[1] == L["Regrowth"] then
		local dur = 21
		self:SendAddonMessage("Regr/"..self.SpellCastInfo[3].."/"..dur.."/")
		if not self.Hots[self.SpellCastInfo[3]] then
			self.Hots[self.SpellCastInfo[3]] = {}
		end
		if not self.Hots[self.SpellCastInfo[3]]["Regr"] then
			self.Hots[self.SpellCastInfo[3]]["Regr"]= {}
		end
		self.Hots[self.SpellCastInfo[3]]["Regr"].start = GetTime()
		self.Hots[self.SpellCastInfo[3]]["Regr"].dur = dur
		self:TriggerEvent("HealComm_Hotupdate", targetUnit, "Regrowth")
		healcomm_spellIsCasting = nil
		for _,val in pairs(self.SpellCastInfo) do
			val = nil
		end
		self.CurrentSpellRank = nil
		self.CurrentSpellName =  nil
	end
end

function HealComm:CHAT_MSG_ADDON()
	if arg1 == "HealComm" and arg4 ~= UnitName("player") then
		local result = strsplit(arg2,"/")
		if result[1] == "Heal" then
			self:startHeal(arg4, result[2], result[3], result[4])
		elseif arg2 == "Healstop" then
			self:stopHeal(arg4)
		elseif result[1] == "Healdelay" then
			self:delayHeal(arg4, result[2])
		elseif result[1] == "Resurrection" and result[2] == "stop" then
			self:cancelResurrection(arg4)
		elseif result[1] == "Resurrection" and result[3] == "start" then
			self:startResurrection(arg4, result[2])
		elseif result[1] == "GrpHeal" then
			self:startGrpHeal(arg4, result[2], result[3], result[4], result[5], result[6], result[7], result[8])
		elseif arg2 == "GrpHealstop" then
			self:stopGrpHeal(arg4)
		elseif result[1] == "GrpHealdelay" then
			self:delayGrpHeal(arg4, result[2])
		elseif result[1] == "Renew" then
			if not self.Hots[result[2]] then
				self.Hots[result[2]] = {}
			end
			if not self.Hots[result[2]]["Renew"] then
				self.Hots[result[2]]["Renew"]= {}
			end
			self.Hots[result[2]]["Renew"].dur = result[3]
			self.Hots[result[2]]["Renew"].start = GetTime()
			local targetUnit = roster:GetUnitIDFromName(result[2])
			self:TriggerEvent("HealComm_Hotupdate", targetUnit, "Renew")
		elseif result[1] == "Reju" then
			if not self.Hots[result[2]] then
				self.Hots[result[2]] = {}
			end
			if not self.Hots[result[2]]["Reju"] then
				self.Hots[result[2]]["Reju"]= {}
			end
			self.Hots[result[2]]["Reju"].dur = result[3]
			self.Hots[result[2]]["Reju"].start = GetTime()
			local targetUnit = roster:GetUnitIDFromName(result[2])
			self:TriggerEvent("HealComm_Hotupdate", targetUnit, "Rejuvenation")
		elseif result[1] == "Regr" then
			if not self.Hots[result[2]] then
				self.Hots[result[2]] = {}
			end
			if not self.Hots[result[2]]["Regr"] then
				self.Hots[result[2]]["Regr"]= {}
			end
			self.Hots[result[2]]["Regr"].dur = result[3]
			self.Hots[result[2]]["Regr"].start = GetTime()
			local targetUnit = roster:GetUnitIDFromName(result[2])
			self:TriggerEvent("HealComm_Hotupdate", targetUnit, "Regrowth")
		end
	end
end

function HealComm:UNIT_AURA()
	local name = UnitName(arg1)
	if self.Hots[name] and (self.Hots[name]["Regr"] or self.Hots[name]["Reju"] or self.Hots[name]["Renew"]) then
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
			self.Hots[name]["Regr"] = nil
			self:TriggerEvent("HealComm_Hotupdate", arg1, "Regrowth")
		end
		if not reju then
			self.Hots[name]["Reju"] = nil
			self:TriggerEvent("HealComm_Hotupdate", arg1, "Rejuvenation")
		end
		if not renew then
			self.Hots[name]["Renew"] = nil
			self:TriggerEvent("HealComm_Hotupdate", arg1, "Renew")
		end			
	end
end

function HealComm:getRegrTime(unit)
	if unit == UNKNOWNOBJECT or unit == UKNOWNBEING then
		return
 	end
	local dbUnit = self.Hots[UnitName(unit)]
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
	local dbUnit = self.Hots[UnitName(unit)]
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
	local dbUnit = self.Hots[UnitName(unit)]
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
	if self.Heals[unit] then
		for k,v in self.Heals[unit] do
			healamount = healamount+v.amount
		end
	end
	for k,v in pairs(self.GrpHeals) do
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
	if self.pendingResurrections[unit] then
		for k,v in pairs(self.pendingResurrections[unit]) do
			if v < GetTime() then
				self.pendingResurrections[unit][k] = nil
			elseif not resstime or resstime > v then
				resstime = v
			end
		end
	end
	return resstime
end

function HealComm:getNumHeals(unit)
	if unit == UNKNOWNOBJECT or unit == UKNOWNBEING then
		return 0
 	end
	local heals = 0
	if self.Heals[unit] then
		for _ in self.Heals[unit] do
			heals = heals + 1
		end
	end
	for _,v in pairs(self.GrpHeals) do
		for _,c in pairs(v.targets) do
			if unit == c then
				heals = heals + 1
			end
		end
	end
	return heals
end


function HealComm:CastSpell(spellId, spellbookTabNum)
	self.hooks.CastSpell(spellId, spellbookTabNum)
	local spellName, rank = GetSpellName(spellId, spellbookTabNum)
	_,_,rank = string.find(rank,"(%d+)")
	if ( SpellIsTargeting() ) then 
       -- Spell is waiting for a target
       self.CurrentSpellName = spellName
	   self.CurrentSpellRank = rank
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") ) then
       -- Spell is being cast on the current target.  
       -- If ClearTarget() had been called, we'd be waiting target
		if UnitIsPlayer("target") then
			self:ProcessSpellCast(spellName, rank, UnitName("target"))
		else
			self.SpellCastInfo[1] = nil
			self.SpellCastInfo[2] = nil
			self.SpellCastInfo[3] = nil
			self.SpellCastInfo[4] = nil
			self.SpellCastInfo[5] = nil
		end
	else
		self:ProcessSpellCast(spellName, rank, UnitName("player"))
	end
end

function HealComm:CastSpellByName(spellName, onSelf)
	self.hooks.CastSpellByName(spellName, onSelf)
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
			self.CurrentSpellName = spellName
			self.CurrentSpellRank = rank
		else
			if UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") and onSelf ~= 1 then
				if UnitIsPlayer("target") then
					self:ProcessSpellCast(spellName, rank, UnitName("target"))
				else
					self.SpellCastInfo[1] = nil
					self.SpellCastInfo[2] = nil
					self.SpellCastInfo[3] = nil
					self.SpellCastInfo[4] = nil
					self.SpellCastInfo[5] = nil
				end
			else
				self:ProcessSpellCast(spellName, rank, UnitName("player"))
			end
		end
	end
end

function HealComm:OnMouseDown()
	-- If we're waiting to target
	local targetName
	
	if ( self.CurrentSpellName and UnitName("mouseover") ) then
		targetName = UnitName("mouseover")
	elseif ( self.CurrentSpellName and GameTooltipTextLeft1:IsVisible() ) then
		local _, _, name = string.find(GameTooltipTextLeft1:GetText(), L["^Corpse of (.+)$"])
		if ( name ) then
			targetName = name
		end
	end
	if ( self.hooks.WorldFrameOnMouseDown ) then
		self.hooks.WorldFrameOnMouseDown()
	end
	if ( self.CurrentSpellName and targetName ) then
		self:ProcessSpellCast(self.CurrentSpellName, self.CurrentSpellRank, targetName)
	end
end

function HealComm:UseAction(slot, checkCursor, onSelf)
	healcommTip:ClearLines()
	healcommTip:SetAction(slot)
	local spellName = healcommTipTextLeft1:GetText()
	self.CurrentSpellName = spellName
	
	self.hooks.UseAction(slot, checkCursor, onSelf)
	
	-- Test to see if this is a macro
	if ( GetActionText(slot) or not self.CurrentSpellName ) then
		return
	end
	local rank = healcommTipTextRight1:GetText()
	if rank then
		_,_,rank = string.find(rank,"(%d+)")
	end
	if not rank then
		rank = 1
	end
	self.CurrentSpellRank = rank
	if ( SpellIsTargeting() ) then
		-- Spell is waiting for a target
		return
	elseif ( UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") and onSelf ~= 1) then
		-- Spell is being cast on the current target
		if UnitIsPlayer("target") then
			self:ProcessSpellCast(spellName, rank, UnitName("target"))
		else
			self.SpellCastInfo[1] = nil
			self.SpellCastInfo[2] = nil
			self.SpellCastInfo[3] = nil
			self.SpellCastInfo[4] = nil
			self.SpellCastInfo[5] = nil
		end
	else
		-- Spell is being cast on the player
		self:ProcessSpellCast(spellName, rank, UnitName("player"))
	end
end

function HealComm:SpellTargetUnit(unit)
	local shallTargetUnit
	if ( SpellIsTargeting() ) then
		shallTargetUnit = true
	end
	self.hooks.SpellTargetUnit(unit)
	if ( shallTargetUnit and self.CurrentSpellName and not SpellIsTargeting() ) then
		if UnitIsPlayer(unit) then
			self:ProcessSpellCast(self.CurrentSpellName, self.CurrentSpellRank, UnitName(unit))
		else
			self.SpellCastInfo[1] = nil
			self.SpellCastInfo[2] = nil
			self.SpellCastInfo[3] = nil
			self.SpellCastInfo[4] = nil
			self.SpellCastInfo[5] = nil
		end
		self.CurrentSpellName = nil
		self.CurrentSpellRank = nil
	end
end

function HealComm:SpellStopTargeting()
	self.hooks.SpellStopTargeting()
	self.CurrentSpellName = nil
	self.CurrentSpellRank = nil
end

function HealComm:TargetUnit(unit)
	-- Look to see if we're currently waiting for a target internally
	-- If we are, then well glean the target info here.
	if ( self.CurrentSpellName and UnitExists(unit) ) and UnitIsPlayer(unit) then
		self:ProcessSpellCast(self.CurrentSpellName, self.CurrentSpellRank, UnitName(unit))
	else
		self.SpellCastInfo[1] = nil
		self.SpellCastInfo[2] = nil
		self.SpellCastInfo[3] = nil
		self.SpellCastInfo[4] = nil
		self.SpellCastInfo[5] = nil
	end
	self.hooks.TargetUnit(unit)
end

function HealComm:ProcessSpellCast(spellName, rank, targetName)
	local unit = roster:GetUnitIDFromName(targetName)
	if ( spellName and rank and targetName and unit ) then
		local power, mod = GetTargetSpellPower(spellName)
		self.SpellCastInfo[1] = spellName
		self.SpellCastInfo[2] = rank
		self.SpellCastInfo[3] = targetName
		self.SpellCastInfo[4] = power
		self.SpellCastInfo[5] = mod
	end
end

AceLibrary:Register(HealComm, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
HealComm = nil