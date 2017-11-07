--[[
Name: DruidManaLib-1.0
Revision: $Rev: 10220 $
Author(s): aviana
Website: https://github.com/Aviana
Description: A library to provide mana values while in shape shift.
Dependencies: AceLibrary, AceEvent-2.0
]]

local MAJOR_VERSION = "DruidManaLib-1.0"
local MINOR_VERSION = "$Revision: 10220 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end

local DruidManaLib = {}
local DruidManaLibTip = CreateFrame("GameTooltip", "DruidManaLibTip", nil, "GameTooltipTemplate")
local DruidManaLibOnUpdateFrame = CreateFrame("Frame")

------------------------------------------------
-- Locales
------------------------------------------------

local L = {}
local locale = GetLocale()

if locale == "deDE" then
	L["Equip: Restores %d+ mana per 5 sec."] = "Anlegen: Stellt alle 5 Sek. %d+ Punkt(e) Mana wieder her.";
	L["Mana Regen %d+ per 5 sec."] = "Manaregeneration %d+ per 5 Sek.";
	L["Equip: Restores (%d+) mana per 5 sec."] = "Anlegen: Stellt alle 5 Sek. (%d+) Punkt(e) Mana wieder her."
	L["Mana Regen (%d+) per 5 sec."] = "Manaregeneration (%d+) per 5 Sek.";
	L["(%d+) Mana"] = "(%d+) Mana";
elseif locale == "ruRU" then
	L["Equip: Restores %d+ mana per 5 sec."] = "Если на персонаже: Восполнение %d+ ед%. маны раз в 5 сек%.";
	L["Mana Regen %d+ per 5 sec."] = "Восполнение %d+ ед%. маны каждые 5 сек%.";
	L["Equip: Restores (%d+) mana per 5 sec."] = "Если на персонаже: Восполнение (%d+) ед%. маны раз в 5 сек%."
	L["Mana Regen (%d+) per 5 sec."] = "Восполнение (%d+) ед%. маны каждые 5 сек%.";
	L["(%d+) Mana"] = "(%d+) ед%. маны";
elseif locale == "frFR" then
	L["Equip: Restores %d+ mana per 5 sec."] = "Equip\195\169 : Rend %d+ points de mana toutes les 5 secondes.";
	L["Mana Regen %d+ per 5 sec."] = "R\195\169cup. mana %d+/5 sec.";
	L["Equip: Restores (%d+) mana per 5 sec."] = "Equip\195\169 : Rend (%d+) points de mana toutes les 5 secondes."
	L["Mana Regen (%d+) per 5 sec."] = "R\195\169cup. mana (%d+)/5 sec.";
	L[" "] = ":";
elseif locale == "zhCN" then
	L["Equip: Restores %d+ mana per 5 sec."] = "装备：每5秒回复%d+点法力值。";
	L["Mana Regen %d+ per 5 sec."] = "每5秒恢复%d+点法力值。";
	L["Equip: Restores (%d+) mana per 5 sec."] = "装备：每5秒回复(%d+)点法力值。"
	L["Mana Regen (%d+) per 5 sec."] = "每5秒恢复(%d+)点法力值。";
	L["(%d+) Mana"] = "(%d+)法力值";
else
	L["Equip: Restores %d+ mana per 5 sec."] = "Equip: Restores %d+ mana per 5 sec.";
	L["Mana Regen %d+ per 5 sec."] = "Mana Regen %d+ per 5 sec.";
	L["Equip: Restores (%d+) mana per 5 sec."] = "Equip: Restores (%d+) mana per 5 sec."
	L["Mana Regen (%d+) per 5 sec."] = "Mana Regen (%d+) per 5 sec.";
	L["(%d+) Mana"] = "(%d+) Mana";
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
		self.SpecialEventScheduler = instance
		self.SpecialEventScheduler:embed(self)
		self:UnregisterAllEvents()
		self:CancelAllScheduledEvents()
		if self.SpecialEventScheduler:IsFullyInitialized() then
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
	if playerClass and playerClass == "DRUID" then
		self:RegisterEvent("UNIT_MANA", "OnEvent")
		self:RegisterEvent("UNIT_MAXMANA", "OnEvent")
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
		self:RegisterEvent("UNIT_INVENTORY_CHANGED", "OnEvent")
		self:RegisterEvent("PLAYER_AURAS_CHANGED", "OnEvent")
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", "OnEvent")
		self:RegisterEvent("SPELLCAST_STOP", "OnEvent")
		self:MaxManaScript()
		DruidManaLibOnUpdateFrame:SetScript("OnUpdate", DruidManaLib_OnUpdate)
		self:TriggerEvent("DruidManaLib_Enabled")
	end
end

------------------------------------------------
-- Addon Code
------------------------------------------------

local curMana = 0
local maxMana = 10
local curInt = 0
local subtractMana = 0
local extra = 0
local lowregentimer = 0
local fullmanatimer = 0
local waitonce = nil
_, playerClass = UnitClass("player")
local inform = (UnitPowerType("player") ~= 0)
DruidManaLibTip:SetOwner(WorldFrame, "ANCHOR_NONE")

function DruidManaLib:GetShapeshiftCost()
	subtractMana = 0;
	local _, _, c, d = GetSpellTabInfo(4);
	local spelltexture
	for i = 1, c+d, 1 do
		spelltexture = GetSpellTexture(i, BOOKTYPE_SPELL);
		if spelltexture and spelltexture == "Interface\\Icons\\Ability_Racial_BearForm" then
			DruidManaLibTip:SetSpell(i, 1);
			local msg = DruidManaLibTipTextLeft2:GetText();
			if msg then
				local params;
				if (locale == "frFR" or locale == "koKR") then
					local index = strfind(msg, L[" "]);
					if index then
						params = strsub(msg, index+1);
					end
				else
					_,_,params = strfind(msg, L["(%d+) Mana"])
				end
				if params then
					subtractMana = tonumber(params);
					if subtractMana and subtractMana > 0 then return; end
				end
			end
		end
	end
end

function DruidManaLib:MaxManaScript()
	local _, int = UnitStat("player", 4);
	self:GetShapeshiftCost();
	if UnitPowerType("player") == 0 then
		if UnitManaMax("player") > 0 then
			maxMana = UnitManaMax("player");
			curMana = UnitMana("player");
			curInt = int;
			self.SpecialEventScheduler:TriggerEvent("DruidManaLib_Manaupdate")
		end
	elseif UnitPowerType("player") ~= 0 then
		if curInt ~= int then
			if int > curInt then
				local dif = int - curInt;
				maxMana = maxMana + (dif * 15);
				curInt = int;
			elseif int < curInt then
				local dif = curInt - int;
				maxMana = maxMana - (dif * 15);
				curInt = int;
			end
		end
		if curMana > maxMana then
			curMana = maxMana;
		end
	end
	extra = 0;
	for i = 1, 18 do
		DruidManaLibTip:ClearLines();
		DruidManaLibTip:SetInventoryItem("player", i);
		for j = 1, DruidManaLibTip:NumLines() do
			local strchek = getglobal("DruidManaLibTipTextLeft"..j):GetText();
			if strchek then
				if strfind(strchek, L["Equip: Restores %d+ mana per 5 sec."]) then
					local num = string.gsub(strchek, L["Equip: Restores (%d+) mana per 5 sec."], "%1")
					extra = extra or 0 + tonumber(num or "0")
				end
				if strfind(strchek, L["Mana Regen %d+ per 5 sec."]) then
					local num = string.gsub(strchek, L["Mana Regen (%d+) per 5 sec."], "%1")
					extra = extra or 0 + tonumber(num or "0")
				end
			end
		end
	end
	extra = ceil((extra * 2) / 5);
end

function DruidManaLib:Subtract()
	local j = 1;
	local icon
	while (UnitBuff("player",j)) do
		icon = UnitBuff("player",j)
		if icon and icon == "Interface\\Icons\\Inv_Misc_Rune_06" then
			return
		end
		j = j + 1
	end
	curMana = curMana - (subtractMana or 0);
	self.SpecialEventScheduler:TriggerEvent("DruidManaLib_Manaupdate")
end

function DruidManaLib:ReflectionCheck()
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
	if lowregentimer > 0 then 
		if waitonce then
			local _, _, _, _, rank = GetTalentInfo(3, 6);
			if rank == 0 then return 0; else
				managain = ceil(((UnitStat("player",5) / 5)+15) * (0.05 * rank));
			end
		else
			waitonce = true;
		end
	elseif lowregentimer <= 0 then
		managain = (ceil(UnitStat("player",5) / 5)+15);
	end
	return managain;
end

function DruidManaLib:OnEvent()
	if event == "UNIT_MAXMANA" and arg1 == "player" then
		self:MaxManaScript();
	elseif event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then
		self:MaxManaScript();
	elseif event == "UNIT_MANA" and arg1 == "player" then
		if UnitPowerType(arg1) == 0 then
			curMana = UnitMana(arg1);
			self.SpecialEventScheduler:TriggerEvent("DruidManaLib_Manaupdate")
		elseif curMana < maxMana then
			local add = self:ReflectionCheck();
			curMana = curMana + add + extra;
			self.SpecialEventScheduler:TriggerEvent("DruidManaLib_Manaupdate")
			if curMana > maxMana then curMana = maxMana; end
		end
		fullmanatimer = 0
	elseif event == "PLAYER_AURAS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORMS" then
		if UnitPowerType("player") == 1 and not inform then
			--Bear
			inform = true
			self:Subtract()
		elseif UnitPowerType("player") == 3 and not inform then
			--Cat
			inform = true
			self:Subtract()
		elseif UnitPowerType("player") == 0 and inform then
			inform = nil
			curMana = UnitMana("player")
			maxMana = UnitManaMax("player")
			self.SpecialEventScheduler:TriggerEvent("DruidManaLib_Manaupdate")
			--player/aqua/travel
		end
	elseif (event == "SPELLCAST_STOP") then
		if UnitPowerType("player") == 0 then
			lowregentimer = 5
			waitonce = nil
		end
	end
end
local timer = 0
function DruidManaLib_OnUpdate()
	timer = timer + arg1
	if lowregentimer > 0 then
		lowregentimer = lowregentimer - arg1;
		if lowregentimer <= 0 then lowregentimer = 0; end
	end
	if UnitPowerType("player") ~= 0 then
		fullmanatimer = fullmanatimer + arg1;
		if fullmanatimer > 6 and floor((curMana*100) / maxMana) > 90 then
			curMana = maxMana;
			local AceEvent = AceLibrary("AceEvent-2.0")
			AceEvent:TriggerEvent("DruidManaLib_Manaupdate")
		end
	end
end

function DruidManaLib:GetMana()
	return curMana, maxMana
end

AceLibrary:Register(DruidManaLib, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
DruidManaLib = nil