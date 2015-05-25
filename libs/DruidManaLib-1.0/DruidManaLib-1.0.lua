--[[
Name: DruidManaLib-1.0
Revision: $Rev: 10000 $
Author(s): aviana
Website: https://github.com/Aviana
Description: A library to provide mana values while in shape shift.
Dependencies: AceLibrary, AceEvent-2.0
]]

local MAJOR_VERSION = "DruidManaLib-1.0"
local MINOR_VERSION = "$Revision: 10100 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end

DruidManaLib = CreateFrame("Frame")
local DruidManaLibTip = CreateFrame("GameTooltip", "DruidManaLibTip", nil, "GameTooltipTemplate")
local DruidManaLibOnUpdateFrame = CreateFrame("Frame")
DruidManaLibOnUpdateFrame:RegisterEvent("PLAYER_LOGIN")

------------------------------------------------
-- Locales
------------------------------------------------

local L = {}

if( GetLocale() == "deDE" ) then
	L["Equip: Restores %d+ mana per 5 sec."] = "Anlegen: Stellt alle 5 Sek. %d+ Punkt(e) Mana wieder her.";
	L["Mana Regen %d+ per 5 sec."] = "Manaregeneration %d+ per 5 Sek.";
	L["Equip: Restores (%d+) mana per 5 sec."] = "Anlegen: Stellt alle 5 Sek. (%d+) Punkt(e) Mana wieder her."
	L["Mana Regen (%d+) per 5 sec."] = "Manaregeneration (%d+) per 5 Sek.";
	L[" "] = " ";
elseif( GetLocale() == "frFR" ) then
	L["Equip: Restores %d+ mana per 5 sec."] = "Equip\195\169 : Rend %d+ points de mana toutes les 5 secondes.";
	L["Mana Regen %d+ per 5 sec."] = "R\195\169cup. mana %d+/5 sec.";
	L["Equip: Restores (%d+) mana per 5 sec."] = "Equip\195\169 : Rend (%d+) points de mana toutes les 5 secondes."
	L["Mana Regen (%d+) per 5 sec."] = "R\195\169cup. mana (%d+)/5 sec.";
	L[" "] = ":";
else
	L["Equip: Restores %d+ mana per 5 sec."] = "Equip: Restores %d+ mana per 5 sec.";
	L["Mana Regen %d+ per 5 sec."] = "Mana Regen %d+ per 5 sec.";
	L["Equip: Restores (%d+) mana per 5 sec."] = "Equip: Restores (%d+) mana per 5 sec."
	L["Mana Regen (%d+) per 5 sec."] = "Mana Regen (%d+) per 5 sec.";
	L[" "] = " ";
end

------------------------------------------------
-- activate, enable, disable
------------------------------------------------

local function activate(self, oldLib, oldDeactivate)
	DruidManaLib = self
	if oldLib then
		oldLib:UnregisterAllEvents()
		oldLib:CancelAllScheduledEvents()
	end
	if oldDeactivate then oldDeactivate(oldLib) end
end


local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		DruidManaLib.SpecialEventScheduler = instance
		DruidManaLib.SpecialEventScheduler:embed(self)
		self:UnregisterAllEvents()
		self:CancelAllScheduledEvents()
		if DruidManaLib.SpecialEventScheduler:IsFullyInitialized() then
			self:AceEvent_FullyInitialized()
		else
			self:RegisterEvent("AceEvent_FullyInitialized", "AceEvent_FullyInitialized", true)
		end		
	end
end

function DruidManaLib:Enable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end


function DruidManaLib:Disable()
-- not used anymore, but as addons still might be calling this method, we're keeping it.
end

------------------------------------------------
-- Internal functions
------------------------------------------------

function DruidManaLib:AceEvent_FullyInitialized()
	self:TriggerEvent("DruidManaLib_Enabled")
	self:RegisterEvent("UNIT_MANA", DruidManaLib.OnEvent)
	self:RegisterEvent("UNIT_MAXMANA", DruidManaLib.OnEvent)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", DruidManaLib.OnEvent)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", DruidManaLib.OnEvent)
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", DruidManaLib.OnEvent)
	self:RegisterEvent("PLAYER_AURAS_CHANGED", DruidManaLib.OnEvent)
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", DruidManaLib.OnEvent)
	self:RegisterEvent("SPELLCAST_STOP", DruidManaLib.OnEvent)
end

------------------------------------------------
-- Addon Code
------------------------------------------------

DruidManaLib.keepthemana = 0
DruidManaLib.maxmana = 10
DruidManaLib.int = 0
DruidManaLib.subtractmana = 0
DruidManaLib.extra = 0
DruidManaLib.lowregentimer = 0
DruidManaLib.fullmanatimer = 0
DruidManaLib.waitonce = nil
_, DruidManaLib.init = UnitClass("player")
DruidManaLib.inform = (UnitPowerType("player") ~= 0)
DruidManaLibTip:SetOwner(DruidManaLib, "ANCHOR_NONE")

local function DruidManaLib_GetShapeshiftCost()
	DruidManaLib.subtractmana = 0;
	local a, b, c, d = GetSpellTabInfo(4);
	local spelltexture
	for i = 1, c+d, 1 do
		spelltexture = GetSpellTexture(i, BOOKTYPE_SPELL);
		if spelltexture and spelltexture == "Interface\\Icons\\Ability_Druid_CatForm" then
			DruidManaLibTip:SetSpell(i, 1);
			local msg = DruidManaLibTipTextLeft2:GetText();
			local params;
			if msg then
				local index = strfind(msg, L[" "]);
				if index then
					if (GetLocale() == "frFR" or GetLocale() == "koKR") then params = strsub(msg, index+1); else params = strsub(msg, 1, index-1); end
					DruidManaLib.subtractmana = tonumber(params);
					if DruidManaLib.subtractmana and DruidManaLib.subtractmana > 0 then return; end
				end
			end
		end
	end
end

local function DruidManaLib_MaxManaScript()
	local _, int = UnitStat("player", 4);
	DruidManaLib_GetShapeshiftCost();
	if UnitPowerType("player") == 0 then
		if UnitManaMax("player") > 0 then
			DruidManaLib.maxmana = UnitManaMax("player");
			DruidManaLib.keepthemana = UnitMana("player");
			DruidManaLib.int = int;
			DruidManaLib.SpecialEventScheduler:TriggerEvent("DruidManaLib_Manaupdate")
		end
	elseif UnitPowerType("player") ~= 0 then
		if DruidManaLib.int ~= int then
			if int > DruidManaLib.int then
				local dif = int - DruidManaLib.int;
				DruidManaLib.maxmana = DruidManaLib.maxmana + (dif * 15);
				DruidManaLib.int = int;
			elseif int < DruidManaLib.int then
				local dif = DruidManaLib.int - int;
				DruidManaLib.maxmana = DruidManaLib.maxmana - (dif * 15);
				DruidManaLib.int = int;
			end
		end
		if DruidManaLib.keepthemana > DruidManaLib.maxmana then
			DruidManaLib.keepthemana = DruidManaLib.maxmana;
		end
	end
	DruidManaLib.extra = 0;
	for i = 1, 18 do
		DruidManaLibTip:ClearLines();
		DruidManaLibTip:SetInventoryItem("player", i);
		for j = 1, DruidManaLibTip:NumLines() do
			local strchek = getglobal("DruidManaLibTipTextLeft"..j):GetText();
			if strchek then
				if strfind(strchek, L["Equip: Restores %d+ mana per 5 sec."]) then
					DruidManaLib.extra = DruidManaLib.extra + string.gsub(strchek, L["Equip: Restores (%d+) mana per 5 sec."], "%1")
				end
				if strfind(strchek, L["Mana Regen %d+ per 5 sec."]) then
					DruidManaLib.extra = DruidManaLib.extra + string.gsub(strchek, L["Mana Regen (%d+) per 5 sec."], "%1");
				end
			end
		end
	end
	DruidManaLib.extra = ceil((DruidManaLib.extra * 2) / 5);
end

local function DruidManaLib_Subtract()
	local j = 1;
	local icon
	while (UnitBuff("player",j)) do
		icon = UnitBuff("player",j)
		if icon and icon == "Interface\\Icons\\Inv_Misc_Rune_06" then
			return
		end
		j = j + 1
	end
	DruidManaLib.keepthemana = DruidManaLib.keepthemana - DruidManaLib.subtractmana;
	DruidManaLib.SpecialEventScheduler:TriggerEvent("DruidManaLib_Manaupdate")
end

local function DruidManaLib_ReflectionCheck()
	local managain = 0;
	local j = 1;
	local icon
	while (UnitBuff("player",j)) do
		icon = UnitBuff("player",j)
		if icon and icon == "Interface\\Icons\\Spell_Nature_Lightning" then
			return ((ceil(UnitStat(arg1,5) / 5)+15) * 5);
		end
		j = j + 1;
	end
	if DruidManaLib.lowregentimer > 0 then 
		if DruidManaLib.waitonce then
			local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(3, 6);
			if rank == 0 then return 0; else
				managain = ceil(((UnitStat("player",5) / 5)+15) * (0.05 * rank));
			end
		else
			DruidManaLib.waitonce = true;
		end
	elseif DruidManaLib.lowregentimer <= 0 then
		managain = (ceil(UnitStat("player",5) / 5)+15);
	end
	return managain;
end

DruidManaLib.OnEvent = function()
	if DruidManaLib.init and DruidManaLib.init == "DRUID" then
		if event == "UNIT_MAXMANA" and arg1 == "player" then
			DruidManaLib_MaxManaScript();
		elseif event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then
			DruidManaLib_MaxManaScript();
		elseif event == "UNIT_MANA" and arg1 == "player" then
			if UnitPowerType(arg1) == 0 then
				DruidManaLib.keepthemana = UnitMana(arg1);
				DruidManaLib.SpecialEventScheduler:TriggerEvent("DruidManaLib_Manaupdate")
			elseif DruidManaLib.keepthemana < DruidManaLib.maxmana then
				local add = DruidManaLib_ReflectionCheck();
				DruidManaLib.keepthemana = DruidManaLib.keepthemana + add + DruidManaLib.extra;
				if DruidManaLib.keepthemana > DruidManaLib.maxmana then DruidManaLib.keepthemana = DruidManaLib.maxmana; end
			end
			DruidManaLib.fullmanatimer = 0
		elseif event == "PLAYER_AURAS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORMS" then
			if UnitPowerType("player") == 1 and not DruidManaLib.inform then
				--Bear
				DruidManaLib.inform = true
				DruidManaLib_Subtract()
			elseif UnitPowerType("player") == 3 and not DruidManaLib.inform then
				--Cat
				DruidManaLib.inform = true
				DruidManaLib_Subtract()
			elseif UnitPowerType("player") == 0 and DruidManaLib.inform then
				DruidManaLib.inform = nil
				DruidManaLib.keepthemana = UnitMana("player")
				DruidManaLib.maxmana = UnitManaMax("player")
				--player/aqua/travel
			end
		elseif (event == "SPELLCAST_STOP") then
			if UnitPowerType("player") == 0 then
				DruidManaLib.lowregentimer = 5
				DruidManaLib.waitonce = nil
			end
		end
	end
end
local timer = 0
function DruidManaLib_OnUpdate()
	timer = timer + arg1
	if DruidManaLib.init and DruidManaLib.init == "DRUID" then
		if DruidManaLib.lowregentimer > 0 then
			DruidManaLib.lowregentimer = DruidManaLib.lowregentimer - arg1;
			if DruidManaLib.lowregentimer <= 0 then DruidManaLib.lowregentimer = 0; end
		end
		if UnitPowerType("player") ~= 0 then
			DruidManaLib.fullmanatimer = DruidManaLib.fullmanatimer + arg1;
			if DruidManaLib.fullmanatimer > 6 and floor((DruidManaLib.keepthemana*100) / DruidManaLib.maxmana) > 90 then
				DruidManaLib.keepthemana = DruidManaLib.maxmana;
			end
		end
	end
	if timer > 2 then
		timer = 0
		if DruidManaLib.init and DruidManaLib.init == "DRUID" and UnitPowerType("player") ~= 0 then
			DruidManaLib.SpecialEventScheduler:TriggerEvent("DruidManaLib_Manaupdate")
		end
	end
end

DruidManaLibOnUpdateFrame:SetScript("OnUpdate", DruidManaLib_OnUpdate)
DruidManaLibOnUpdateFrame:SetScript("OnEvent", DruidManaLib_MaxManaScript)

function DruidManaLib:GetMana()
	return DruidManaLib.keepthemana, DruidManaLib.maxmana
end

AceLibrary:Register(DruidManaLib, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)