if AceLibrary:HasInstance("ItemBonusLib-1.0") then return end

local L = AceLibrary("AceLocale-2.2"):new("ItemBonusLib")

L:RegisterTranslations("enUS", function () return {
	CHAT_COMMANDS = { "/abonus" },
	["An addon to get information about bonus from equipped items"] = true,
	["show"] = true,
	["Show all bonuses from the current equipment"] = true,
	["Current equipment bonuses:"] = true,
	["details"] = true,
	["Shows bonuses with slot distribution"] = true,
	["Current equipment bonus details:"] = true,
	["item"] = true,
	["show bonuses of given itemlink"] = true,
	["<itemlink>"] = true,
	["Bonuses for %s:"] = true,
	["Item is part of set [%s]"] = true,
	[" %sBonus for %d pieces :"] = true,
	["slot"] = true,
	["show bonuses of given slot"] = true,
	["<slotname>"] = true,
	["Bonuses of slot %s:"] = true,
	
	-- bonus names
	NAMES = {	
		STR 		= "Strength",
		AGI 		= "Agility",
		STA 		= "Stamina",
		INT 		= "Intellect",
		SPI 		= "Spirit",
		ARMOR 		= "Reinforced Armor",

		ARCANERES 	= "Arcane Resistance",	
		FIRERES 	= "Fire Resistance",
		NATURERES 	= "Nature Resistance",
		FROSTRES 	= "Frost Resistance",
		SHADOWRES 	= "Shadow Resistance",

		FISHING 	= "Fishing",
		MINING 		= "Mining",
		HERBALISM 	= "Herbalism",
		SKINNING 	= "Skinning",
		DEFENSE 	= "Defense",
		
		BLOCK 		= "Chance to Block",
		BLOCKVALUE  = "Block value",
		DODGE 		= "Dodge",
		PARRY 		= "Parry",
		ATTACKPOWER = "Attack Power",
		ATTACKPOWERUNDEAD = "Attack Power against Undead",
		ATTACKPOWERFERAL = "Attack Power in feral form",
		CRIT 		= "Crit. hits",
		RANGEDATTACKPOWER = "Ranged Attack Power",
		RANGEDCRIT 	= "Crit. Shots",
		TOHIT 		= "Chance to Hit",

		DMG 		= "Spell Damage",
		DMGUNDEAD	= "Spell Damage against Undead",
		ARCANEDMG 	= "Arcane Damage",
		FIREDMG 	= "Fire Damage",
		FROSTDMG 	= "Frost Damage",
		HOLYDMG 	= "Holy Damage",
		NATUREDMG 	= "Nature Damage",
		SHADOWDMG 	= "Shadow Damage",
		SPELLCRIT 	= "Crit. Spell",
		SPELLTOHIT 	= "Chance to Hit with spells",
		SPELLPEN 	= "Spell Penetration",
		HEAL 		= "Healing",
		HOLYCRIT 	= "Crit. Holy Spell",

		HEALTHREG 	= "Life Regeneration",
		MANAREG 	= "Mana Regeneration",
		HEALTH 		= "Life Points",
		MANA 		= "Mana Points"
	};


	-- passive bonus patterns. checked against lines which start with above prefixes
	PATTERNS_PASSIVE = {
		{ pattern = "+(%d+) ranged Attack Power%.", effect = "RANGEDATTACKPOWER" },
		{ pattern = "Increases your chance to block attacks with a shield by (%d+)%%%.", effect = "BLOCK" },
		{ pattern = "Increases the block value of your shield by (%d+)%.", effect = "BLOCKVALUE" },
		{ pattern = "Increases your chance to dodge an attack by (%d+)%%%.", effect = "DODGE" },
		{ pattern = "Increases your chance to parry an attack by (%d+)%%%.", effect = "PARRY" },
		{ pattern = "Improves your chance to get a critical strike with spells by (%d+)%%%.", effect = "SPELLCRIT" },
		{ pattern = "Improves your chance to get a critical strike with Holy spells by (%d+)%%%.", effect = "HOLYCRIT" },
		{ pattern = "Increases the critical effect chance of your Holy spells by (%d+)%%%.", effect = "HOLYCRIT" },
		{ pattern = "Improves your chance to get a critical strike by (%d+)%%%.", effect = "CRIT" },
		{ pattern = "Improves your chance to get a critical strike with missile weapons by (%d+)%%%.", effect = "RANGEDCRIT" },
		{ pattern = "Increases damage done by Arcane spells and effects by up to (%d+)%.", effect = "ARCANEDMG" },
		{ pattern = "Increases damage done by Fire spells and effects by up to (%d+)%.", effect = "FIREDMG" },
		{ pattern = "Increases damage done by Frost spells and effects by up to (%d+)%.", effect = "FROSTDMG" },
		{ pattern = "Increases damage done by Holy spells and effects by up to (%d+)%.", effect = "HOLYDMG" },
		{ pattern = "Increases damage done by Nature spells and effects by up to (%d+)%.", effect = "NATUREDMG" },
		{ pattern = "Increases damage done by Shadow spells and effects by up to (%d+)%.", effect = "SHADOWDMG" },
		{ pattern = "Increases healing done by spells and effects by up to (%d+)%.", effect = "HEAL" },
		{ pattern = "Increases damage and healing done by magical spells and effects by up to (%d+)%.", effect = {"HEAL", "DMG"} },
		{ pattern = "Increases damage done to Undead by magical spells and effects by up to (%d+)", effect = "DMGUNDEAD" },
		{ pattern = "+(%d+) Attack Power when fighting Undead.", effect = "ATTACKPOWERUNDEAD" },
		{ pattern = "Restores (%d+) health per 5 sec%.", effect = "HEALTHREG" }, 
		{ pattern = "Restores (%d+) health every 5 sec%.", effect = "HEALTHREG" },  -- both versions ('per' and 'every') seem to be used
		{ pattern = "Restores (%d+) mana per 5 sec%.", effect = "MANAREG" },
		{ pattern = "Restores (%d+) mana every 5 sec%.", effect = "MANAREG" },
		{ pattern = "Improves your chance to hit by (%d+)%%%.", effect = "TOHIT" },
		{ pattern = "Improves your chance to hit with spells by (%d+)%%%.", effect = "SPELLTOHIT" },
		{ pattern = "Decreases the magical resistances of your spell targets by (%d+).", effect = "SPELLPEN" },

		-- Added for HealPoints
		{ pattern = "Allows (%d+)%% of your Mana regeneration to continue while casting%.", effect = "CASTINGREG"},		
		{ pattern = "Improves your chance to get a critical strike with Nature spells by (%d+)%%%.", effect = "NATURECRIT"}, 
		{ pattern = "Reduces the casting time of your Regrowth spell by 0%.(%d+) sec%.", effect = "CASTINGREGROWTH"}, 
		{ pattern = "Reduces the casting time of your Holy Light spell by 0%.(%d+) sec%.", effect = "CASTINGHOLYLIGHT"},
		{ pattern = "Reduces the casting time of your Healing Touch spell by 0%.(%d+) sec%.", effect = "CASTINGHEALINGTOUCH"},
		{ pattern = "%-0%.(%d+) sec to the casting time of your Flash Heal spell%.", effect = "CASTINGFLASHHEAL"},
		{ pattern = "%-0%.(%d+) seconds on the casting time of your Chain Heal spell%.", effect = "CASTINGCHAINHEAL"},
		{ pattern = "Increases the duration of your Rejuvenation spell by (%d+) sec%.", effect = "DURATIONREJUV"},
		{ pattern = "Increases the duration of your Renew spell by (%d+) sec%.", effect = "DURATIONRENEW"},
		{ pattern = "Increases your normal health and mana regeneration by (%d+)%.", effect = "MANAREGNORMAL"},
		{ pattern = "Increases the amount healed by Chain Heal to targets beyond the first by (%d+)%%%.", effect = "IMPCHAINHEAL"},
		{ pattern = "Increases healing done by Rejuvenation by up to (%d+)%.", effect = "IMPREJUVENATION"},
		{ pattern = "Increases healing done by Lesser Healing Wave by up to (%d+)%.", effect = "IMPLESSERHEALINGWAVE"},
		{ pattern = "Increases healing done by Flash of Light by up to (%d+)%.", effect = "IMPFLASHOFLIGHT"},
		{ pattern = "After casting your Healing Wave or Lesser Healing Wave spell%, gives you a 25%% chance to gain Mana equal to (%d+)%% of the base cost of the spell%.", effect = "REFUNDHEALINGWAVE"},
		{ pattern = "Your Healing Wave will now jump to additional nearby targets%. Each jump reduces the effectiveness of the heal by (%d+)%%%, and the spell will jump to up to two additional targets%.", effect = "JUMPHEALINGWAVE"},
		{ pattern = "Reduces the mana cost of your Healing Touch%, Regrowth%, Rejuvenation and Tranquility spells by (%d+)%%%.", effect = "CHEAPERDRUID"},
		{ pattern = "On Healing Touch critical hits%, you regain (%d+)%% of the mana cost of the spell%.", effect = "REFUNDHTCRIT"},
		{ pattern = "Reduces the mana cost of your Renew spell by (%d+)%%%.", effect = "CHEAPERRENEW"},
	};

	-- generic patterns have the form "+xx bonus" or "bonus +xx" with an optional % sign after the value.

	-- first the generic bonus string is looked up in the following table
	PATTERNS_GENERIC_LOOKUP = {
		["All Stats"] 			= {"STR", "AGI", "STA", "INT", "SPI"},
		["Strength"]			= "STR",
		["Agility"]				= "AGI",
		["Stamina"]				= "STA",
		["Intellect"]			= "INT",
		["Spirit"] 				= "SPI",

		["All Resistances"] 	= { "ARCANERES", "FIRERES", "FROSTRES", "NATURERES", "SHADOWRES"},

		["Fishing"]				= "FISHING",
		["Fishing Lure"]		= "FISHING",
		["Increased Fishing"]	= "FISHING",
		["Mining"]				= "MINING",
		["Herbalism"]			= "HERBALISM",
		["Skinning"]			= "SKINNING",
		["Defense"]				= "DEFENSE",
		["Increased Defense"]	= "DEFENSE",

		["Attack Power"] 		= "ATTACKPOWER",
		["Attack Power when fighting Undead"] 		= "ATTACKPOWERUNDEAD",
		["Attack Power in Cat, Bear, and Dire Bear forms only"] = "ATTACKPOWERFERAL",

		["Dodge"] 				= "DODGE",
		["Block"]				= "BLOCK",
		["Block Value"]			= "BLOCKVALUE",
		["Hit"] 				= "TOHIT",
		["Spell Hit"]			= "SPELLTOHIT",
		["Blocking"]			= "BLOCK",
		["Ranged Attack Power"] = "RANGEDATTACKPOWER",
		["health every 5 sec"] = "HEALTHREG",
		["Healing Spells"] 		= "HEAL",
		["Increases Healing"] 	= "HEAL",
		["Healing and Spell Damage"] = {"HEAL", "DMG"},
		["Damage and Healing Spells"] = {"HEAL", "DMG"},
		["Spell Damage and Healing"] = {"HEAL", "DMG"},	
		["mana every 5 sec"] 	= "MANAREG",
		["Mana Regen"] 			= "MANAREG",
		["Spell Damage"] 		= {"HEAL", "DMG"},
		["Critical"] 			= "CRIT",
		["Critical Hit"] 		= "CRIT",
		["Damage"] 				= "DMG",
		["Health"]				= "HEALTH",
		["HP"]					= "HEALTH",
		["Mana"]				= "MANA",
		["Armor"]				= "ARMOR",
		["Reinforced Armor"]	= "ARMOR",
	};	

	-- next we try to match against one pattern of stage 1 and one pattern of stage 2 and concatenate the effect strings
	PATTERNS_GENERIC_STAGE1 = {
		{ pattern = "Arcane", 	effect = "ARCANE" },	
		{ pattern = "Fire", 	effect = "FIRE" },	
		{ pattern = "Frost", 	effect = "FROST" },	
		{ pattern = "Holy", 	effect = "HOLY" },	
		{ pattern = "Shadow",	effect = "SHADOW" },	
		{ pattern = "Nature", 	effect = "NATURE" }
	}; 	

	PATTERNS_GENERIC_STAGE2 = {
		{ pattern = "Resist", 	effect = "RES" },	
		{ pattern = "Damage", 	effect = "DMG" },
		{ pattern = "Effects", 	effect = "DMG" },
	}; 	

	-- finally if we got no match, we match against some special enchantment patterns.
	PATTERNS_OTHER = {
		{ pattern = "Mana Regen (%d+) per 5 sec%.", effect = "MANAREG" },
		
		{ pattern = "Minor Wizard Oil", effect = {"DMG", "HEAL"}, value = 8 },
		{ pattern = "Lesser Wizard Oil", effect = {"DMG", "HEAL"}, value = 16 },
		{ pattern = "Wizard Oil", effect = {"DMG", "HEAL"}, value = 24 },
		{ pattern = "Brilliant Wizard Oil", effect = {"DMG", "HEAL", "SPELLCRIT"}, value = {36, 36, 1} },

		{ pattern = "Minor Mana Oil", effect = "MANAREG", value = 4 },
		{ pattern = "Lesser Mana Oil", effect = "MANAREG", value = 8 },
		{ pattern = "Brilliant Mana Oil", effect = { "MANAREG", "HEAL"}, value = {12, 25} },
		
		{ pattern = "Eternium Line", effect = "FISHING", value = 5 }, 
		
		{ pattern = "Healing %+31 and 5 mana per 5 sec%.", effect = { "MANAREG", "HEAL"}, value = {5, 31} },
		{ pattern = "Stamina %+16 and Armor %+100", effect = { "STA", "ARMOR"}, value = {16, 100} },
		{ pattern = "Attack Power %+26 and %+1%% Critical Strike", effect = { "ATTACKPOWER", "CRIT"}, value = {26, 1} },
		{ pattern = "Spell Damage %+15 and %+1%% Spell Critical Strike", effect = { "DMG", "HEAL", "SPELLCRIT"}, value = {15, 15, 1} },

	}
} end)
