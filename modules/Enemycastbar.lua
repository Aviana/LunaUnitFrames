LunaUnitFrames.CasterDB = {}
LunaUnitFrames.Enemycastbar = CreateFrame("Frame")

EnemyCastBar_Spells = {

	-- All Classes
		-- General
	["Hearthstone"] = {t=10.0, ni=1};
	["Rough Copper Bomb"] = {t=1, ni=1};
	["Large Copper Bomb"] = {t=1, ni=1};
	["Small Bronze Bomb"] = {t=1, ni=1};
	["Big Bronze Bomb"] = {t=1, ni=1};
	["Iron Grenade"] = {t=1, ni=1};
	["Big Iron Bomb"] = {t=1, ni=1};
	["Mithril Frag Bomb"] = {t=1, ni=1};
	["Hi-Explosive Bomb"] = {t=1, ni=1};
	["Thorium Grenade"] = {t=1, ni=1};
	["Dark Iron Bomb"] = {t=1, ni=1};
	["Arcane Bomb"] = {t=1, ni=1};
	["Sleep"] = {t=1.5, ni=1};
	["Reckless Charge"] = {t=0};

		-- First Aid
	["First Aid"] = {t=8.0, ni=1};
	["Linen Bandage"] = {t=3.0, ni=1};
	["Heavy Linen Bandage"] = {t=3.0, ni=1};
	["Wool Bandage"] = {t=3.0, ni=1};
	["Heavy Wool Bandage"] = {t=3.0, ni=1};
	["Silk Bandage"] = {t=3.0, ni=1};
	["Heavy Silk Bandage"] = {t=3.0, ni=1};
	["Mageweave Bandage"] = {t=3.0, ni=1};
	["Heavy Mageweave Bandage"] = {t=3.0, ni=1};
	["Runecloth Bandage"] = {t=3.0, ni=1};
	["Heavy Runecloth Bandage"] = {t=3.0, ni=1};
	
	-- Druid
	["Healing Touch"] = {t=3.0};
	["Regrowth"] = {t=2.0, g=21.0};
	["Rebirth"] = {t=2.0, d=1800.0};
	["Starfire"] = {t=3};
	["Wrath"] = {t=1.5};
	["Entangling Roots"] = {t=1.5};
	["Hibernate"] = {t=1.5};
	["Soothe Animal"] = {t=1.5};
	["Barkskin"] = {t=0};
	["Teleport: Moonglade"] = {t=10.0};
	["Travel Form"] = {t=0};
	["Dire Bear Form"] = {t=0};
	["Cat Form"] = {t=0};
	["Bear Form"] = {t=0};
	["Moonkin Form"] = {t=0};
	["Aquatic Form"] = {t=0};
	["Feral Charge Effect"] = {t=0};
	["Bash"] = {t=0};
	["Starfire Stun"] = {t=0};
	["Pounce"] = {t=0};
	["Nature's Swiftness"] = {t=0};
	
	-- Hunter
	["Aimed Shot"] = {t=3.0};
	["Scare Beast"] = {t=1.5};
	["Dismiss Pet"] = {t=5.0};
	["Revive Pet"] = {t=10.0};
	["Eyes of the Beast"] = {t=2.0};
	["Scatter Shot"] = {t=0};
	["Freezing Trap Effect"] = {t=0};
	["Intimidation"] = {t=0};
	["Wyvern Sting"] = {t=0};
	
	-- Mage
	["Frostbolt"] = {t=2.5};
	["Fireball"] = {t=3.0};
	["Conjure Water"] = {t=3.0};
	["Conjure Food"] = {t=3.0};
	["Conjure Mana Ruby"] = {t=3.0};
	["Conjure Mana Citrine"] = {t=3.0};
	["Conjure Mana Jade"] = {t=3.0};
	["Conjure Mana Agate"] = {t=3.0};
	["Polymorph"] = {t=1.5};
	["Polymorph: Pig"] = {t=1.5};
	["Polymorph: Turtle"] = {t=1.5};
	["Pyroblast"] = {t=6.0, d=60.0};
	["Scorch"] = {t=1.5};
	["Flamestrike"] = {t=3.0, r="Death Talon Hatcher", a=2.5};
	["Slow Fall"] = {t=0, c="gains"};
	["Portal: Darnassus"] = {t=10.0};
	["Portal: Thunder Bluff"] = {t=10.0};
	["Portal: Ironforge"] = {t=10.0};
	["Portal: Orgrimmar"] = {t=10.0};
	["Portal: Stormwind"] = {t=10.0};
	["Portal: Undercity"] = {t=10.0};
	["Teleport: Darnassus"] = {t=10.0};
	["Teleport: Thunder Bluff"] = {t=10.0};
	["Teleport: Ironforge"] = {t=10.0};
	["Teleport: Orgrimmar"] = {t=10.0};
	["Teleport: Stormwind"] = {t=10.0};
	["Teleport: Undercity"] = {t=10.0};
	["Impact"] = {t=0};
	["Fire Ward"] = {t=0.0};
	["Frost Ward"] = {t=0.0};
	["Frost Armor"] = {t=0.0};
	["Ice Armor"] = {t=0.0};
	["Mage Armor"] = {t=0.0};
	["Counterspell - Silenced"] = {t=0.0, ni=1};
	["Ice Barrier"] = {t=0.0};
	["Mana Shield"] = {t=0.0};
	["Blink"] = {t=0};
	["Ice Block"] = {t=0};
	
	-- Paladin
	["Seal of Wisdom"] = {t=0};
	["Seal of Light"] = {t=0};
	["Seal of Righteousness"] = {t=0};
	["Seal of Command"] = {t=0};
	["Seal of the Crusader"] = {t=0};
	["Seal of Justice"] = {t=0};
	["Righteous Fury"] = {t=0};
	["Holy Light"] = {t=2.5};
	["Flash of Light"] = {t=1.5};
	["Summon Charger"] = {t=3.0, g=0.0};
	["Summon Warhorse"] = {t=3.0, g=0.0};
	["Hammer of Wrath"] = {t=1.0, d=6.0};
	["Holy Wrath"] = {t=2.0, d=60.0};
	["Turn Undead"] = {t=1.5, d=30.0};
	["Redemption"] = {t=10.0};
	["Divine Protection"] = {t=0};
	["Divine Shield"] = {t=0};
	["Hammer of Justice"] = {t=0};
	
	-- Priest
	["Greater Heal"] = {t=2.5};
	["Flash Heal"] = {t=1.5};
	["Heal"] = {t=2.5};
	["Resurrection"] = {t=10.0};
	["Smite"] = {t=2};
	["Mind Blast"] = {t=1.5, d=8.0};
	["Mind Control"] = {t=3.0};
	["Mana Burn"] = {t=2.5};
	["Holy Fire"] = {t=3.0, d=15.0};
	["Mind Soothe"] = {t=0};
	["Prayer of Healing"] = {t=3.0};
	["Shackle Undead"] = {t=1.5};
	["Fade"] = {t=0};
	["Psychic Scream"] = {t=0.0};
	["Silence"] = {t=0.0, ni = 1};
	["Blackout"] = {t=0.0};
	
	-- Rogue
	["Disarm Trap"] = {t=5.0};
	["Mind-numbing Poison"] = {t=3.0};
	["Mind-numbing Poison II"] = {t=3.0};
	["Mind-numbing Poison III"] = {t=3.0};
	["Instant Poison"] = {t=3.0};
	["Instant Poison II"] = {t=3.0};
	["Instant Poison III"] = {t=3.0};
	["Instant Poison IV"] = {t=3.0};
	["Instant Poison V"] = {t=3.0};
	["Instant Poison VI"] = {t=3.0};
	["Deadly Poison"] = {t=3.0};
	["Deadly Poison II"] = {t=3.0};
	["Deadly Poison III"] = {t=3.0};
	["Deadly Poison IV"] = {t=3.0};
	["Deadly Poison V"] = {t=3.0};
	["Crippling Poison"] = {t=3.0};
	["Pick Lock"] = {t=5.0};
	["Blind"] = {t=0.0};
	["Gouge"] = {t=0.0};
	["Kidney Shot"] = {t=0.0};
	["Kick - Silenced"] = {t=0.0};
	
	-- Shaman
	["Lesser Healing Wave"] = {t=1.5};
	["Healing Wave"] = {t=3.0};
	["Ancestral Spirit"] = {t=10.0};
	["Chain Lightning"] = {t=1.5, d=6.0};
	["Ghost Wolf"] = {t=3.0};
	["Astral Recall"] = {t=10.0};
	["Chain Heal"] = {t=2.5};
	["Lightning Bolt"] = {t=2.0};
	["Far Sight"] = {t=2.0};
	
	-- Warlock
	["Shadow Bolt"] = {t=2.5};
	["Immolate"] = {t=1.5};
	["Soul Fire"] = {t=4.0};
	["Searing Pain"] = {t=1.5};
	["Summon Dreadsteed"] = {t=3.0};
	["Summon Felsteed"] = {t=3.0};
	["Summon Imp"] = {t=6.0};
	["Summon Succubus"] = {t=6.0};
	["Summon Voidwalker"] = {t=6.0};
	["Summon Felhunter"] = {t=6.0};
	["Fear"] = {t=1.5};
	["Howl of Terror"] = {t=2.0};
	["Banish"] = {t=1.5};
	["Ritual of Summoning"] = {t=5.0};
	["Ritual of Doom"] = {t=10.0};
	["Create Spellstone"] = {t=5.0};
	["Create Soulstone"] = {t=3.0};
	["Create Healthstone"] = {t=3.0};
	["Create Firestone"] = {t=3.0};
	["Enslave Demon"] = {t=3.0};
	["Inferno"] = {t=2.0};
	["Inferno Effect"] = {t=0};
	["Shadow Ward"] = {t=0};
	["Death Coil"] = {t=0.0};
	["Corruption"] = {t=2};
	["Demon Armor"] = {t=0};
	["Demon Skin"] = {t=0};

		-- Succubus
		["Seduction"] = {t=1.5};
		
		-- Felhunter
		["Spell Lock"] = {t=0.0, ni=1};

	-- Warrior
	["Charge Stun"] = {t=0};
	["Intercept Stun"] = {t=0};
	["Revenge Stun"] = {t=0};
	["Mace Stun Effect"] = {t=0};
	["Intimidating Shout"] = {t=0};
	["Shield Bash - Silenced"] = {t=0};
	
}

EnemyCastBar_Raids = {

	-- Ahn'Qiraj

		-- 20 Man Trash
		["Explode"] = {t=6.0};

	-- Blackwing Lair
			
		-- Firemaw/Flamegor/Ebonroc
		["Shadow Flame"] = {t=2.0, c="hostile"};
		
		-- Neferian/Onyxia
		["Bellowing Roar"] = {t=2.0, c="hostile", r="Onyxia", a=1.5};
		
}

EnemyCastBar_NonAfflictions = {
	["Frostbolt"] = true;
	["Fireball"] = true;
	["Pyroblast"] = true;
	["Entangling Roots"] = true;
	["Soothe Animal"] = true;
	["Mind Soothe"] = true;
	["Immolate"] = true;
	["Corruption"] = true;
	["Regrowth"] = true;
	["Mind Control"] = true;
	["Holy Fire"] = true;
	["Greater Heal"] = true;
}
	

EnemyCastBar_SPELL_GAINS 				= "(.+) gains (.+)."
EnemyCastBar_SPELL_CAST 				= "(.+) begins to cast (.+)."
EnemyCastBar_SPELL_PERFORM				= "(.+) begins to perform (.+)."
EnemyCastBar_SPELL_AFFLICTED			= "(.+) (.+) afflicted by (.+).";


LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE");
LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF");

LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE");
LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF");

LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS");
LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS");

LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE");
LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE");
LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE");

LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE");
LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF");

LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE");
LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS");

LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS");
LunaUnitFrames.Enemycastbar:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE");

LunaUnitFrames.Enemycastbar:RegisterEvent("PLAYER_TARGET_CHANGED");

LunaUnitFrames.Enemycastbar.OnEvent = function ()
	if (event == "PLAYER_TARGET_CHANGED") then
		EnemyCastBar_Restore()
	else
		EnemyCastBar_Gfind(arg1)
	end
end

LunaUnitFrames.Enemycastbar:SetScript("OnEvent", LunaUnitFrames.Enemycastbar.OnEvent)

function EnemyCastBar_Gfind(arg1)
	if (arg1 ~= nil) then
		for mob, spell in string.gfind(arg1, EnemyCastBar_SPELL_CAST) do	
			EnemyCastBar_Control(mob, spell, "casts")
			return
		end	
		for mob, spell in string.gfind(arg1, EnemyCastBar_SPELL_PERFORM) do
			EnemyCastBar_Control(mob, spell, "performs")
			return
		end
		for mob, spell in string.gfind(arg1, EnemyCastBar_SPELL_GAINS) do
			EnemyCastBar_Control(mob, spell, "gains")
			return
		end

		for mob, crap, spell in string.gfind(arg1, EnemyCastBar_SPELL_AFFLICTED) do
			EnemyCastBar_Control(mob, spell, "afflicted")
			return
		end
	end
end

function EnemyCastBar_Control(mob, spell, special)
	if EnemyCastBar_Raids[spell] ~= nil then
		castime = EnemyCastBar_Raids[spell].t
		-- Spell might have the same name but a different cast time on another mob, ie. Onyxia/Nefarian on Bellowing Roar
		if EnemyCastBar_Raids[spell].r then
			if (mob == EnemyCastBar_Raids[spell].r) then
				castime = EnemyCastBar_Raids[spell].a
			end
		end
		if EnemyCastBar_Raids[spell].m then
			mob = EnemyCastBar_Raids[spell].m
		end
		EnemyCastBar_Show(mob, spell, castime)
	else
		if EnemyCastBar_Spells[spell] ~= nil then
			if special == "afflicted" then
				if not EnemyCastBar_NonAfflictions[spell] then
					EnemyCastBar_Hide(mob, spell)
				end
				return
			end
			castime = EnemyCastBar_Spells[spell].t
			if special == "gains" then
				if not EnemyCastBar_NonAfflictions[spell] then
					EnemyCastBar_Hide(mob, spell)
				end
				return
			end
			-- Spell might have the same name but a different cast time on another mob, ie. Death Talon Hatchers/Players on Bellowing Roar
			if EnemyCastBar_Spells[spell].r then
				if mob == EnemyCastBar_Spells[spell].r then
					castime = EnemyCastBar_Spells[spell].a
				end
			end
			EnemyCastBar_Show(mob, spell, castime)
		end
	end
end

function EnemyCastBar_Show(mob, spell, castime)
	LunaUnitFrames.CasterDB[mob] = {sp = spell, start = GetTime(), ct = castime}
	if mob == UnitName("target") then
		LunaUnitFrames:StartTargetCast(GetTime(), spell, castime)
	end
end

function EnemyCastBar_Hide(mob, spell)
	if LunaUnitFrames.CasterDB[mob] and not (EnemyCastBar_Spells[spell].ni and EnemyCastBar_Spells[LunaUnitFrames.CasterDB[mob].sp].ni) then
		LunaUnitFrames.CasterDB[mob]["ct"] = 0
		if mob == UnitName("target") then
			LunaUnitFrames:StopTargetCast()
		end
	end
end

function EnemyCastBar_Restore()
	local mob = UnitName("target")
	if LunaUnitFrames.CasterDB[mob] then
		LunaUnitFrames:StartTargetCast(LunaUnitFrames.CasterDB[mob]["start"], LunaUnitFrames.CasterDB[mob]["sp"], LunaUnitFrames.CasterDB[mob]["ct"])
	else
		LunaUnitFrames:StopTargetCast()
	end
end