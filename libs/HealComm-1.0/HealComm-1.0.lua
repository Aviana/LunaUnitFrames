--[[
Name: HealComm-1.0
Revision: $Rev: 11732 $
Author(s): aviana
Website: https://github.com/Aviana
Description: A library to provide communication of heals and resurrections.
Dependencies: AceLibrary, AceEvent-2.0, RosterLib-2.0, ItemBonusLib-1.0
]]

local MAJOR_VERSION = "HealComm-1.0"
local MINOR_VERSION = "$Revision: 11732 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end
if not AceLibrary:HasInstance("RosterLib-2.0") then error(MAJOR_VERSION .. " requires RosterLib-2.0") end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(MAJOR_VERSION .. " requires AceEvent-2.0") end
if not AceLibrary:HasInstance("AceHook-2.1") then error(MAJOR_VERSION .. " requires AceHook-2.1") end
if not AceLibrary:HasInstance("ItemBonusLib-1.0") then error(MAJOR_VERSION .. " requires ItemBonusLib-1.0") end

local roster = AceLibrary("RosterLib-2.0")
local itemBonus = AceLibrary("ItemBonusLib-1.0")
local L = AceLibrary("AceLocale-2.2"):new("HealComm-1.0")
local HealComm = {}

------------------------------------------------
-- Locales
------------------------------------------------

L:RegisterTranslations("enUS", function() return {
	["Libram of Divinity"] = true,
	["Libram of Light"] = true,
	["Set: Increases the duration of your Rejuvenation spell by 3 sec."] = true,
	["Set: Increases the duration of your Renew spell by 3 sec."] = true,
	["Totem of Life"] = true,
	["Totem of Sustaining"] = true,
	["^Corpse of (.+)$"] = true,
	["Holy Light"] = true,
	["Flash of Light"] = true,
	["Lesser Heal"] = true,
	["Heal"] = true,
	["Greater Heal"] = true,
	["Flash Heal"] = true,
	["Prayer of Healing"] = true,
	["Lesser Healing Wave"] = true,
	["Healing Wave"] = true,
	["Chain Heal"] = true,
	["Healing Touch"] = true,
	["Regrowth"] = true,
	["Resurrection"] = true;
	["Rebirth"] = true;
	["Redemption"] = true;
	["Ancestral Spirit"] = true;
	["Renew"] = true;
	["Rejuvenation"] = true;
	["Power Infusion"] = true,
	["Divine Favor"] = true,
	["Nature Aligned"] = true,
	["Crusader's Wrath"] = true,
	["The Furious Storm"] = true,
	["Holy Power"] = true,
	["Prayer Beads Blessing"] = true,
	["Chromatic Infusion"] = true,
	["Ascendance"] = true,
	["Ephemeral Power"] = true,
	["Unstable Power"] = true,
	["Healing of the Ages"] = true,
	["Essence of Sapphiron"] = true,
	["The Eye of the Dead"] = true,
	["Mortal Strike"] = true,
	["Wound Poison"] = true,
	["Curse of the Deadwood"] = true,
	["Veil of Shadow"] = true,
	["Gehennas' Curse"] = true,
	["Mortal Wound"] = true,
	["Necrotic Poison"] = true,
	["Blood Fury"] = true,
	["Necrotic Aura"] = true,
	["Blessing of Light"] = true,
	["Healing Way"] = true,
	["Warsong Gulch"] = true,
	["Arathi Basin"] = true,
	["Alterac Valley"] = true,
} end)
L:RegisterTranslations("ruRU", function() return {
	["Libram of Divinity"] = "Манускрипт божественности",
	["Libram of Light"] = "Манускрипт света",
	["Set: Increases the duration of your Rejuvenation spell by 3 sec."] = "Комплект: Увеличение длительности заклинания \"Омоложение\" на 3 сек.", -- T2
	["Set: Increases the duration of your Renew spell by 3 sec."] = "Комплект: Увеличение длительности заклинания \"Обновление\" на 3 сек.", -- T2.5
	["Totem of Life"] = "Тотем жизни",
	["Totem of Sustaining"] = "Тотем воодушевления",
	["^Corpse of (.+)$"] = "^Труп (.+)$",
	["Holy Light"] = "Свет небес",
	["Flash of Light"] = "Улучшенная вспышка света",
	["Lesser Heal"] = "Малое исцеление",
	["Heal"] = "Исцеление",
	["Greater Heal"] = "Великое исцеление",
	["Flash Heal"] = "Быстрое исцеление",
	["Prayer of Healing"] = "Молитва исцеления",
	["Lesser Healing Wave"] = "Малая волна исцеления",
	["Healing Wave"] = "Волна исцеления",
	["Chain Heal"] = "Цепное исцеление",
	["Healing Touch"] = "Целительное прикосновение",
	["Regrowth"] = "Восстановление",
	["Resurrection"] = "Воскрешение",
	["Rebirth"] = "Возрождение",
	["Redemption"] = "Искупление",
	["Ancestral Spirit"] = "Дух предков",
	["Renew"] = "Обновление",
	["Rejuvenation"] = "Омоложение",
	["Power Infusion"] = "Придание сил",
	["Divine Favor"] = "Божественное одобрение",
	["Nature Aligned"] = "Упорядочение Природы",
	["Crusader's Wrath"] = "Гнев рыцаря Света",
	["The Furious Storm"] = "Яростный шторм",
	["Holy Power"] = "Священная сила",
	["Prayer Beads Blessing"] = "Благословение четок",
	["Chromatic Infusion"] = "Цветной настой",
	["Ascendance"] = "Господство",
	["Ephemeral Power"] = "Эфемерная Власть",
	["Unstable Power"] = "Изменчивая сила",
	["Healing of the Ages"] = "Исцеление Эпох",
	["Essence of Sapphiron"] = "Сущность Сапфирона",
	["The Eye of the Dead"] = "Глаз Мертвого",
	["Mortal Strike"] = "Смертельный удар",
	["Wound Poison"] = "Нейтрализующий яд",
	["Curse of the Deadwood"] = "Проклятие Мертвого Леса",
	["Veil of Shadow"] = "Пелена Тени",
	["Gehennas' Curse"] = "Проклятие Гееннаса",
	["Mortal Wound"] = "Смертоносная рана",
	["Necrotic Poison"] = "Некротический яд",
	["Blood Fury"] = "Кровавое неистовство",
	["Necrotic Aura"] = "Мертвенная аура",
	["Blessing of Light"] = "Благословение Света",
	["Healing Way"] = "Путь исцеления",
	["Warsong Gulch"] = "Ущелье Песни Войны",
	["Arathi Basin"] = "Низина Арати",
	["Alterac Valley"] = "Альтеракская долина",
} end)
L:RegisterTranslations("deDE", function() return {
	["Libram of Divinity"] = "Buchband der Offenbarung",
	["Libram of Light"] = "Buchband des Lichts",
	["Set: Increases the duration of your Rejuvenation spell by 3 sec."] = "Set: Erh\195\182ht die Dauer Eures Zaubers \'Verj\195\188ngung\' um 3 Sek.",
	["Set: Increases the duration of your Renew spell by 3 sec."] = "Set: Erh\195\182ht die Dauer Eures Zaubers 'Erneuerung' um 3 Sek.",
	["Totem of Life"] = "Totem des Lebens",
	["Totem of Sustaining"] = "Totem der Erhaltung",
	["^Corpse of (.+)$"] = "^Leichnam von (.+)$",
	["Holy Light"] = "Heiliges Licht",
	["Flash of Light"] = "Lichtblitz",
	["Lesser Heal"] = "Geringes Heilen",
	["Heal"] = "Heilen",
	["Greater Heal"] = "Große Heilung",
	["Flash Heal"] = "Blitzheilung",
	["Prayer of Healing"] = "Gebet der Heilung",
	["Lesser Healing Wave"] = "Geringe Welle der Heilung",
	["Healing Wave"] = "Welle der Heilung",
	["Chain Heal"] = "Kettenheilung",
	["Healing Touch"] = "Heilende Ber\195\188hrung",
	["Regrowth"] = "Nachwachsen",
	["Resurrection"] = "Auferstehung",
	["Rebirth"] = "Wiedergeburt",
	["Redemption"] = "Erl\195\182sung",
	["Ancestral Spirit"] = "Geist der Ahnen",
	["Renew"] = "Erneuerung",
	["Rejuvenation"] = "Verj\195\188ngung",
	["Power Infusion"] = "Seele der Macht",
	["Divine Favor"] = "G\195\182ttliche Gunst",
	["Nature Aligned"] = "Naturverbundenheit",
	["Crusader's Wrath"] = "Zorn des Kreuzfahrers",
	["The Furious Storm"] = "Der wilde Sturm",
	["Holy Power"] = "Heilige Kraft",
	["Prayer Beads Blessing"] = "Segen der Gebetsperlen",
	["Chromatic Infusion"] = "Erf\195\188llt mit chromatischer Macht",
	["Ascendance"] = "Überlegenheit",
	["Ephemeral Power"] = "Ephemere Macht",
	["Unstable Power"] = "Instabile Macht",
	["Healing of the Ages"] = "Heilung der Urzeiten",
	["Essence of Sapphiron"] = "Essenz Saphirons",
	["The Eye of the Dead"] = "Das Auge des Todes",
	["Mortal Strike"] = "T\195\182dlicher Stoß",
	["Wound Poison"] = "Wundgift",
	["Curse of the Deadwood"] = "Fluch der Totenwaldfelle",
	["Veil of Shadow"] = "Schattenschleier",
	["Gehennas' Curse"] = "Gehennas' Fluch",
	["Mortal Wound"] = "Trauma",
	["Necrotic Poison"] = "Nekrotisches Gift",
	["Blood Fury"] = "Kochendes Blut",
	["Necrotic Aura"] = "Nekrotische Aura",
	["Blessing of Light"] = "Segen des Lichts",
	["Healing Way"] = "Pfad der Heilung",
	["Warsong Gulch"] = "Warsongschlucht",
	["Arathi Basin"] = "Arathibecken",
	["Alterac Valley"] = "Alteractal",
} end)
L:RegisterTranslations("frFR", function() return {
	["Libram of Divinity"] = "Libram de divinit\195\169",
	["Libram of Light"] = "Libram de lumi\195\168re",
	["Set: Increases the duration of your Rejuvenation spell by 3 sec."] = "Set: Augmente la dur\195\169e de votre sort R\195\169cup\195\169ration de 3 s.",
	["Set: Increases the duration of your Renew spell by 3 sec."] = "Set: Augmente la dur\195\169e de votre sort R\195\169novation de 3 s.",	
	["Totem of Life"] = "Totem de vie",
	["Totem of Sustaining"] = "Totem de soutien",
	["^Corpse of (.+)$"] = "^Cadavre |2 (.+)$",
	["Holy Light"] = "Lumi\195\168re sacr\195\169e",
	["Flash of Light"] = "Eclair lumineux",
	["Lesser Heal"] = "Soins inf\195\169rieurs",
	["Heal"] = "Soins",
	["Greater Heal"] = "Soins sup\195\169rieurs",
	["Flash Heal"] = "Soins rapides",
	["Prayer of Healing"] = "Pri\195\168re de soins",
	["Lesser Healing Wave"] = "Vague de soins inf\195\169rieurs",
	["Healing Wave"] = "Vague de soins",
	["Chain Heal"] = "Salve de gu\195\169rison",
	["Healing Touch"] = "Toucher gu\195\169risseur",
	["Regrowth"] = "R\195\169tablissement",
	["Resurrection"] = "R\195\169surrection",
	["Rebirth"] = "Renaissance",
	["Redemption"] = "R\195\169demption",
	["Ancestral Spirit"] = "Esprit ancestral",
	["Renew"] = "R\195\169novation",
	["Rejuvenation"] = "R\195\169cup\195\169ration",
	["Power Infusion"] = "Infusion de puissance",
	["Divine Favor"] = "Faveur divine",
	["Nature Aligned"] = "Alignement sur la nature",
	["Crusader's Wrath"] = "Col\195\168re du crois\195\169",
	["The Furious Storm"] = "La temp\195\170te furieuse",
	["Holy Power"] = "Puissance sacr\195\169e",
	["Prayer Beads Blessing"] = "B\195\169n\195\169diction du chapelet",
	["Chromatic Infusion"] = "Infusion chromatique",
	["Ascendance"] = "Ascendance",
	["Ephemeral Power"] = "Puissance \195\169ph\195\169m\195\168re",
	["Unstable Power"] = "Puissance instable",
	["Healing of the Ages"] = "Soins des \195\162ges",
	["Essence of Sapphiron"] = "Essence de Saphiron",
	["The Eye of the Dead"] = "L'Oeil du mort",
	["Mortal Strike"] = "Frappe mortelle",
	["Wound Poison"] = "Poison douloureux",
	["Curse of the Deadwood"] = "Mal\195\169diction des Mort-bois",
	["Veil of Shadow"] = "Voile de l'ombre",
	["Gehennas' Curse"] = "Mal\195\169diction de Gehennas",
	["Mortal Wound"] = "Blessures mortelles",
	["Necrotic Poison"] = "Poison n\195\169crotique",
	["Blood Fury"] = "Fureur sanguinaire",
	["Necrotic Aura"] = "Aura n\195\169crotique",
	["Blessing of Light"] = "B\195\169n\195\169diction de lumi\195\168re",
	["Healing Way"] = "Flots de soins",
	["Warsong Gulch"] = "Goulet des Warsong",
	["Arathi Basin"] = "Bassin d'Arathi",
	["Alterac Valley"] = "Vall\195\169e d'Alterac",
} end)
L:RegisterTranslations("zhCN", function() return {
	["Libram of Divinity"] = "神性圣契",
	["Libram of Light"] = "光明圣契",
	["Set: Increases the duration of your Rejuvenation spell by 3 sec."] = "套装：使你的回春术的持续时间延长3秒。", -- T2
	["Set: Increases the duration of your Renew spell by 3 sec."] = "套装：使你的恢复术的持续时间延长3秒。", -- T2.5
	["Totem of Life"] = "生命图腾",
	["Totem of Sustaining"] = "持久图腾",
	["^Corpse of (.+)$"] = "(.+)的尸体",
	["Holy Light"] = "圣光术",
	["Flash of Light"] = "圣光闪现",
	["Lesser Heal"] = "次级治疗术",
	["Heal"] = "治疗术",
	["Greater Heal"] = "强效治疗术",
	["Flash Heal"] = "快速治疗",
	["Prayer of Healing"] = "治疗祷言",
	["Lesser Healing Wave"] = "次级治疗波",
	["Healing Wave"] = "治疗波",
	["Chain Heal"] = "治疗链",
	["Healing Touch"] = "治疗之触",
	["Regrowth"] = "愈合",
	["Resurrection"] = "复活",
	["Rebirth"] = "复生",
	["Redemption"] = "救赎",
	["Ancestral Spirit"] = "先祖之魂",
	["Renew"] = "恢复",
	["Rejuvenation"] = "回春术",
	["Power Infusion"] = "能量灌注",
	["Divine Favor"] = "神恩术",
	["Nature Aligned"] = "自然之盟",
	["Crusader's Wrath"] = "十字军之怒",
	["The Furious Storm"] = "狂野风暴",
	["Holy Power"] = "神圣强化",
	["Prayer Beads Blessing"] = "祈祷之珠",
	["Chromatic Infusion"] = "多彩能量",
	["Ascendance"] = "优越",
	["Ephemeral Power"] = "短暂强力",
	["Unstable Power"] = "能量无常",
	["Healing of the Ages"] = "远古治疗",
	["Essence of Sapphiron"] = "萨菲隆的精华",
	["The Eye of the Dead"] = "亡者之眼",
	["Mortal Strike"] = "致死打击",
	["Wound Poison"] = "致伤毒药",
	["Curse of the Deadwood"] = "死木诅咒",
	["Veil of Shadow"] = "暗影之雾", -- 存在多个不同名技能，暗影之雾/暗影迷雾/幽影之雾
	["Gehennas' Curse"] = "基赫纳斯的诅咒",
	["Mortal Wound"] = "重伤",
	["Necrotic Poison"] = "死灵之毒",
	["Blood Fury"] = "血性狂暴",
	["Necrotic Aura"] = "死灵光环",
	["Blessing of Light"] = "光明祝福",
	["Healing Way"] = "治疗之道",
	["Warsong Gulch"] = "战歌峡谷",
	["Arathi Basin"] = "阿拉希盆地",
	["Alterac Valley"] = "奥特兰克山谷",
} end)
L:RegisterTranslations("koKR", function() return {
	["Libram of Divinity"] = "신앙의 성서",
	["Libram of Light"] = "빛의 성서",
	["Set: Increases the duration of your Rejuvenation spell by 3 sec."] = true, --needs translation
	["Set: Increases the duration of your Renew spell by 3 sec."] = true, --needs translation
	["Totem of Life"] = "생명의 토템",
	["Totem of Sustaining"] = "지탱의 토템",
	["^Corpse of (.+)$"] = true, --needs translation
	["Holy Light"] = "성스러운 빛",
	["Flash of Light"] = "빛의 섬광",
	["Lesser Heal"] = "하급 치유",
	["Heal"] = "치유",
	["Greater Heal"] = "상급 치유",
	["Flash Heal"] = "순간 치유",
	["Prayer of Healing"] = "치유의 기원",
	["Lesser Healing Wave"] = "하급 치유의 물결",
	["Healing Wave"] = "치유의 물결",
	["Chain Heal"] = "연쇄 치유",
	["Healing Touch"] = "치유의 손길",
	["Regrowth"] = "재생",
	["Resurrection"] = "부활",
	["Rebirth"] = "환생",
	["Redemption"] = "구원",
	["Ancestral Spirit"] = "고대의 영혼",
	["Renew"] = "소생",
	["Rejuvenation"] = "회복",
	["Power Infusion"] = "마력 주입",
	["Divine Favor"] = "신의 은총",
	["Nature Aligned"] = "자연 동화",
	["Crusader's Wrath"] = "성전사의 격노",
	["The Furious Storm"] = "휘몰아치는 폭풍",
	["Holy Power"] = "신성 마법 강화",
	["Prayer Beads Blessing"] = "기원의 묵주의 축복",
	["Chromatic Infusion"] = "오색 용력",
	["Ascendance"] = "승리의 기세",
	["Ephemeral Power"] = "마력의 힘",
	["Unstable Power"] = "불안정한 마력",
	["Healing of the Ages"] = "세월의 치유",
	["Essence of Sapphiron"] = "사피론의 정수",
	["The Eye of the Dead"] = "사자의 눈",
	["Mortal Strike"] = "죽음의 일격",
	["Wound Poison"] = "상처 감염 독",
	["Curse of the Deadwood"] = "마른가지의 저주",
	["Veil of Shadow"] = "암흑의 장막",
	["Gehennas' Curse"] = "게헨나스의 저주",
	["Mortal Wound"] = "죽음의 상처",
	["Necrotic Poison"] = "부패의 독",
	["Blood Fury"] = "피의 격노",
	["Necrotic Aura"] = "괴저 오라",
	["Blessing of Light"] = "빛의 축복",
	["Healing Way"] = "치유의 길",
	["Warsong Gulch"] = "전쟁노래 협곡",
	["Arathi Basin"] = "아라시 분지",
	["Alterac Valley"] = "알터랙 계곡",
} end)
------------------------------------------------
-- activate, enable, disable
------------------------------------------------

local function activate(self, oldLib, oldDeactivate)
	HealComm = self
	if oldLib then
		self.Heals = oldLib.Heals
		self.GrpHeals = oldLib.GrpHeals
		self.Lookup = oldLib.Lookup
		self.pendingResurrections = oldLib.pendingResurrections
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
		self:RegisterEvent("SPELLCAST_INTERRUPTED")
		self:RegisterEvent("SPELLCAST_FAILED")
		self:RegisterEvent("SPELLCAST_DELAYED")
		self:RegisterEvent("SPELLCAST_STOP")
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("UNIT_HEALTH")
		self:RegisterEvent("PLAYER_LOGIN")
		self:TriggerEvent("HealComm_Enabled")
	end
	if major == "AceHook-2.1" then
		local AceHook = instance
		AceHook:embed(self)
	end
end

function HealComm:PLAYER_LOGIN()
	self:HookScript(WorldFrame, "OnMouseDown", "OnMouseDown")
	self:Hook("CastSpell")
	self:Hook("CastSpellByName")
	self:Hook("UseAction")
	self:Hook("SpellTargetUnit")
	self:Hook("SpellStopTargeting")
	self:Hook("TargetUnit")
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
				if name == 	L["Libram of Divinity"] then
					lp = 53
				elseif name == L["Libram of Light"] then
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
				if name == 	L["Libram of Divinity"] then
					lp = 53
				elseif name == L["Libram of Light"] then
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
				if name == 	L["Libram of Divinity"] then
					lp = 53
				elseif name == L["Libram of Light"] then
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
				if name == 	L["Libram of Divinity"] then
					lp = 53
				elseif name == L["Libram of Light"] then
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
				if name == 	L["Libram of Divinity"] then
					lp = 53
				elseif name == L["Libram of Light"] then
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
				if name == 	L["Libram of Divinity"] then
					lp = 53
				elseif name == L["Libram of Light"] then
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
				if name == 	L["Libram of Divinity"] then
					lp = 53
				elseif name == L["Libram of Light"] then
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
				if name == L["Totem of Sustaining"] then
					tp = 53
				elseif name == L["Totem of Life"] then
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
				if name == L["Totem of Sustaining"] then
					tp = 53
				elseif name == L["Totem of Life"] then
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
				if name == L["Totem of Sustaining"] then
					tp = 53
				elseif name == L["Totem of Life"] then
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
				if name == L["Totem of Sustaining"] then
					tp = 53
				elseif name == L["Totem of Life"] then
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
				if name == L["Totem of Sustaining"] then
					tp = 53
				elseif name == L["Totem of Life"] then
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
				if name == L["Totem of Sustaining"] then
					tp = 53
				elseif name == L["Totem of Life"] then
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

local Hots = {
	[L["Renew"]] = true;
	[L["Rejuvenation"]] = true;
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
	local text = "healcommTipTextLeft"..(healcommTip:NumLines() or 1)
	local text = getglobal(text)
	if text then
		text = text:GetText()
	else
		return nil
	end
	if text == L["Set: Increases the duration of your Rejuvenation spell by 3 sec."] or text == L["Set: Increases the duration of your Renew spell by 3 sec."] then
		return true
	else
		return nil
	end
end
	
function HealComm:GetBuffSpellPower()
	local Spellpower = 0
	local healmod = 1
	for i=1, 32 do
		local buffTexture, buffApplications = UnitBuff("player", i)
		if not buffTexture then
			return Spellpower, healmod
		end
		healcommTip:SetUnitBuff("player", i)
		local buffName = healcommTipTextLeft1:GetText()
		if self.Buffs[buffName] and self.Buffs[buffName].icon == buffTexture then
			Spellpower = (self.Buffs[buffName].amount * buffApplications) + Spellpower
			healmod = (self.Buffs[buffName].mod * buffApplications) + healmod
		end
	end
	return Spellpower, healmod
end

function HealComm:GetUnitSpellPower(unit, spell)
	local targetpower = 0
	local targetmod = 1
	local buffTexture, buffApplications
	local debuffTexture, debuffApplications
	local buffName
	for i=1, 32 do
		if UnitIsVisible(unit) and UnitIsConnected(unit) and UnitCanAssist("player", unit) then
			buffTexture, buffApplications = UnitBuff(unit, i)
			healcommTip:SetUnitBuff(unit, i)
		else
			buffTexture, buffApplications = UnitBuff("player", i)
			healcommTip:SetUnitBuff("player", i)
		end
		if not buffTexture then
			break
		end
		buffName = healcommTipTextLeft1:GetText()
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
		if UnitIsVisible(unit) and UnitIsConnected(unit) and UnitCanAssist("player", unit) then
			debuffTexture, debuffApplications = UnitDebuff(unit, i)
			healcommTip:SetUnitDebuff(unit, i)
		else
			debuffTexture, debuffApplications = UnitDebuff("player", i)
			healcommTip:SetUnitDebuff("player", i)
		end
		if not debuffTexture then
			break
		end
		local debuffName = healcommTipTextLeft1:GetText()
		if self.Debuffs[debuffName] then
			targetpower = (self.Debuffs[debuffName].amount * debuffApplications) + targetpower
			targetmod = (1-(self.Debuffs[debuffName].mod * debuffApplications)) * targetmod
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
	self.Heals[target][caster] = {amount = math.floor(size), ctime = (casttime/1000)+GetTime()}
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
	self.GrpHeals[caster] = {amount = math.floor(size), ctime = (casttime/1000)+GetTime(), targets = {party1, party2, party3, party4, party5}}
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
		local Bonus = itemBonus:GetBonus("HEAL")
		local buffpower, buffmod = self:GetBuffSpellPower()
		local targetpower, targetmod = self.SpellCastInfo[4], self.SpellCastInfo[5]
		local Bonus = Bonus + buffpower
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
		self:startResurrection(UnitName("player"), self.SpellCastInfo[3])
	end
	self.spellIsCasting = arg1
end

function HealComm:SPELLCAST_INTERRUPTED()
	if self:IsEventScheduled("TriggerRegrowthHot") then
		self:CancelScheduledEvent("TriggerRegrowthHot")
	end

	if self.Spells[self.spellIsCasting] then
		if self.spellIsCasting == L["Prayer of Healing"] then
			self:SendAddonMessage("GrpHealstop")
			self:stopGrpHeal(UnitName("player"))
		else
			self:SendAddonMessage("Healstop")
			self:stopHeal(UnitName("player"))
		end
	elseif Resurrections[self.spellIsCasting] then
		self:SendAddonMessage("Resurrection/stop/")
		self:cancelResurrection(UnitName("player"))
	end
	self.CurrentSpellRank = nil
	self.CurrentSpellName =  nil
	self.spellIsCasting = nil
	for key in pairs(self.SpellCastInfo) do
		self.SpellCastInfo[key] = nil
	end
end

function HealComm:SPELLCAST_FAILED()
	self.failed = true
end

function HealComm:SPELLCAST_DELAYED()
	if self.spellIsCasting == L["Prayer of Healing"] then
		self:SendAddonMessage("GrpHealdelay/"..arg1.."/")
		self:delayGrpHeal(UnitName("player"), arg1)
	else
		self:SendAddonMessage("Healdelay/"..arg1.."/")
		self:delayHeal(UnitName("player"), arg1)
	end
end

function HealComm:TriggerRegrowthHot()
	local dur = 21
	self:SendAddonMessage("Regr/"..self.savetarget.."/"..dur.."/")
	if not self.Hots[self.savetarget] then
		self.Hots[self.savetarget] = {}
	end
	if not self.Hots[self.savetarget]["Regr"] then
		self.Hots[self.savetarget]["Regr"]= {}
	end
	self.Hots[self.savetarget]["Regr"].start = GetTime()
	self.Hots[self.savetarget]["Regr"].dur = dur
	self:TriggerEvent("HealComm_Hotupdate", roster:GetUnitIDFromName(self.savetarget), "Regrowth")
end

function HealComm:SPELLCAST_STOP()
	if not self.SpellCastInfo then return end
	local targetUnit = roster:GetUnitIDFromName(self.SpellCastInfo[3])
	if targetUnit then
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
		elseif self.SpellCastInfo[1] == L["Regrowth"] then
			self.savetarget = self.SpellCastInfo[3]
			self:ScheduleEvent("TriggerRegrowthHot", self.TriggerRegrowthHot, 0.3, self)
		end
	end
	self.CurrentSpellRank = nil
	self.CurrentSpellName =  nil
	for key in pairs(self.SpellCastInfo) do
		self.SpellCastInfo[key] = nil
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
	
	if self.failed or (self.CurrentSpellName and not SpellIsTargeting()) then
		self.failed = nil
		return
	end
	
	local spellName, rank = GetSpellName(spellId, spellbookTabNum)
	_,_,rank = string.find(rank,"(%d+)")
	
	if not (self.Spells[spellName] or Resurrections[spellName] or Hots[spellName]) then return end

	self.CurrentSpellName = spellName
	self.CurrentSpellRank = rank
	if not SpellIsTargeting() then
		if ( UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") ) then
			-- Spell is being cast on the current target.  
			if UnitIsPlayer("target") then
				self:ProcessSpellCast("target")
			end
		else
			self:ProcessSpellCast("player")
		end
	end
end

function HealComm:CastSpellByName(spellName, onSelf)
	self.hooks.CastSpellByName(spellName, onSelf)
	
	if self.failed then
		self.failed = nil
		return
	end
	
	if (self.CurrentSpellName and not SpellIsTargeting()) or (GetCVar("AutoSelfCast") == "0" and onSelf ~= 1 and not SpellIsTargeting() and not (UnitExists("target") and UnitCanAssist("player", "target"))) then return end
	
	local _,_,rank = string.find(spellName,"(%d+)")
	local _, _, spellName = string.find(spellName, "^([^%(]+)")
	spellName = string.lower(spellName)
	local i = 1
	while GetSpellName(i, BOOKTYPE_SPELL) do
		local s, r = GetSpellName(i, BOOKTYPE_SPELL)
		if string.lower(s) == spellName then
			spellName = s
			if rank then
				break
			else
				while s == spellName do
					rank = r
					i = i+1
					s, r = GetSpellName(i, BOOKTYPE_SPELL)
				end
				break
			end
		end
		i = i+1
	end
	if rank then
		_,_,rank = string.find(rank,"(%d+)")
	end
	if spellName then
		if not (self.Spells[spellName] or Resurrections[spellName] or Hots[spellName]) then return end
		self.CurrentSpellName = spellName
		self.CurrentSpellRank = rank
		
		if not SpellIsTargeting() then
			if UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") and onSelf ~= 1 then
				if UnitIsPlayer("target") then
					self:ProcessSpellCast("target")
				end
			else
				self:ProcessSpellCast("player")
			end
		end
	end
end

function HealComm:OnMouseDown(object)
	local unit = "mouseover"
	if ( self.CurrentSpellName and GameTooltipTextLeft1:IsVisible() ) then
		local _, _, name = string.find(GameTooltipTextLeft1:GetText(), L["^Corpse of (.+)$"])
		if ( name ) then
			unit = roster:GetUnitIDFromName(name)
		end
	end
	if ( self.CurrentSpellName and SpellIsTargeting() and UnitExists(unit) ) then
		self:ProcessSpellCast(unit)
	end
	if ( self.hooks[object]["OnMouseDown"] ) then
		self.hooks[object]["OnMouseDown"]()
	end
end

function HealComm:UseAction(slot, checkCursor, onSelf)
	healcommTip:ClearLines()
	healcommTip:SetAction(slot)
	local spellName = healcommTipTextLeft1:GetText()
	
	self.hooks.UseAction(slot, checkCursor, onSelf)
	
	-- Test to see if this is a macro
	if self.failed or GetActionText(slot) or (self.CurrentSpellName and not SpellIsTargeting()) or not (self.Spells[spellName] or Resurrections[spellName] or Hots[spellName]) then
		self.failed = nil
		return
	end
	
	self.CurrentSpellName = spellName
	local rank = healcommTipTextRight1:GetText()
	if rank then
		_,_,rank = string.find(rank,"(%d+)")
	end
	self.CurrentSpellRank = rank or 1
	
	if not SpellIsTargeting() then
		if ( UnitIsVisible("target") and UnitIsConnected("target") and UnitCanAssist("player", "target") and onSelf ~= 1) then
			-- Spell is being cast on the current target
			if UnitIsPlayer("target") then
				self:ProcessSpellCast("target")
			end
		else
			-- Spell is being cast on the player
			self:ProcessSpellCast("player")
		end
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
			self:ProcessSpellCast(unit)
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
		self:ProcessSpellCast(unit)
	end
	self.hooks.TargetUnit(unit)
end

function HealComm:ProcessSpellCast(unit)
	local power, mod = self:GetUnitSpellPower(unit, self.CurrentSpellName)
	self.SpellCastInfo[1] = (self.SpellCastInfo[1] or self.CurrentSpellName)
	self.SpellCastInfo[2] = (self.SpellCastInfo[2] or self.CurrentSpellRank)
	self.SpellCastInfo[3] = (self.SpellCastInfo[3] or UnitName(unit))
	self.SpellCastInfo[4] = (self.SpellCastInfo[4] or power)
	self.SpellCastInfo[5] = (self.SpellCastInfo[5] or mod)
end

AceLibrary:Register(HealComm, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
HealComm = nil
