local LunaUF = LunaUF
local Cast = CreateFrame("Frame")
local L = LunaUF.L
local BS = LunaUF.BS
local CL = LunaUF.CL
LunaUF:RegisterModule(Cast, "castBar", L["Cast bar"], true)

local CasterDB = {}
local berserkValue = 0
local buffed = false
local _,playerRace = UnitRace("player")
local _,playerClass = UnitClass("player")

local DisabledZones = {
	[L["Shadow Wing Lair"]] = true,
	[L["Halls of Strife"]] = true,
}

local CHAT_PATTERNS = {
	["gains"] = {
				[1] = string.gsub(string.gsub(AURAADDEDOTHERHELPFUL,"%d%$",""), "%%s", "(.+)"),
				},								-- "(.+) gains (.+)."
	["casts"] = {
				[1] = string.gsub(string.gsub(SPELLCASTOTHERSTART,"%d%$",""), "%%s", "(.+)"), -- "(.+) begins to cast (.+)."
				[2] = string.gsub(string.gsub(SPELLPERFORMOTHERSTART,"%d%$",""), "%%s", "(.+)"), -- "(.+) begins to perform (.+)."
				},
	["afflicted"] = {
				[1] = string.gsub(string.gsub(AURAADDEDOTHERHARMFUL,"%d%$",""), "%%s", "(.+)") -- "(.+) is afflicted by (.+)."
				},
	["selfinterrupt"] = {
				[1] = string.gsub(string.gsub(string.gsub(SPELLLOGSELFOTHER,"%d%$",""),"%%d","%%d+"),"%%s","(.+)"), -- "Your (.+) hits (.+) for %d+\."
				[2] = string.gsub(string.gsub(string.gsub(SPELLLOGCRITSELFOTHER,"%d%$",""),"%%d","%%d+"),"%%s","(.+)"), -- "Your (.+) crits (.+) for %d+\."
				--[3] = string.gsub(string.gsub(SPELLINTERRUPTSELFOTHER,"%d%$",""), "%%s", "(.+)"), -- "You interrupt %s's %s."
				},
	["interrupt"] = {
				[1] = string.gsub(string.gsub(string.gsub(SPELLLOGOTHEROTHER,"%d%$",""), "%%s", "(.+)"), "%%d", "%%d+"), -- "%a+'s (.+) hits (.+) for %d+\."
				[2] = string.gsub(string.gsub(string.gsub(SPELLLOGCRITOTHEROTHER,"%d%$",""), "%%s", "(.+)"), "%%d", "%%d+"), -- "%a+'s (.+) crits (.+) for %d+\."
				--[3] = string.gsub(string.gsub(SPELLINTERRUPTOTHEROTHER,"%d%$",""), "%%s", "(.+)"), -- "%s interrupts %s's %s."
				},
}

local Spells = {

	-- All Classes
		-- General
	[L["Hearthstone"]] = {t=10.0};
	[L["Rough Copper Bomb"]] = {t=1, ni=1};
	[L["Large Copper Bomb"]] = {t=1, ni=1};
	[L["Small Bronze Bomb"]] = {t=1, ni=1};
	[L["Big Bronze Bomb"]] = {t=1, ni=1};
	[L["Iron Grenade"]] = {t=1, ni=1};
	[L["Big Iron Bomb"]] = {t=1, ni=1};
	[L["Mithril Frag Bomb"]] = {t=1, ni=1};
	[L["Hi-Explosive Bomb"]] = {t=1, ni=1};
	[L["Thorium Grenade"]] = {t=1, ni=1};
	[L["Dark Iron Bomb"]] = {t=1, ni=1};
	[L["Arcane Bomb"]] = {t=1, ni=1};
	[L["Sleep"]] = {t=1.5, ni=1};
	[L["Reckless Charge"]] = {t=0};
	[L["Dark Mending"]] = {t=3.5};
	[L["Intense Pain"]] = {t=1};
	[BS["Sacrifice"]] = {t=1};
	[L["Great Heal"]] = {t=2};
	[L["Sweep"]] = {t=1.5};
	[L["Sand Blast"]] = {t=2.0};
	[L["Locust Swarm"]] = {t=3};
	[L["Meteor"]] = {t=1.5};
	[L["Unyielding Pain"]] = {t=2};
	[L["Condemnation"]] = {t=2};
	[L["Holy Bolt"]] = {t=2};
	[L["Polarity Shift"]] = {t=3};
	[L["Ball Lightning"]] = {t=1};
	[L["Destroy Egg"]] = {t=3};
	[L["Fireball Volley"]] = {2};
	[L["Flame Breath"]] = {2};
	[L["Time Lapse"]] = {2};
	[L["Incinerate"]] = {2};
	[L["Ignite Flesh"]] = {2};
	[L["Frost Burn"]] = {2};
	[L["Corrosive Acid"]] = {2};
	[L["Dominate Mind"]] = {2};
	[L["Demon Portal"]] = {0.5};
	

		-- First Aid
	[L["First Aid"]] = {t=8.0};
	[L["Linen Bandage"]] = {t=3.0};
	[L["Heavy Linen Bandage"]] = {t=3.0};
	[L["Wool Bandage"]] = {t=3.0};
	[L["Heavy Wool Bandage"]] = {t=3.0};
	[L["Silk Bandage"]] = {t=3.0};
	[L["Heavy Silk Bandage"]] = {t=3.0};
	[L["Mageweave Bandage"]] = {t=3.0};
	[L["Heavy Mageweave Bandage"]] = {t=3.0};
	[L["Runecloth Bandage"]] = {t=3.0};
	[L["Heavy Runecloth Bandage"]] = {t=3.0};
	
	-- Druid
	[BS["Healing Touch"]] = {t=3.0};
	[BS["Regrowth"]] = {t=2.0, g=21.0};
	[BS["Rebirth"]] = {t=2.0, d=1800.0};
	[BS["Starfire"]] = {t=3};
	[BS["Wrath"]] = {t=1.5};
	[BS["Entangling Roots"]] = {t=1.5};
	[BS["Hibernate"]] = {t=1.5};
	[BS["Soothe Animal"]] = {t=1.5};
	[BS["Barkskin"]] = {t=0};
	[BS["Teleport: Moonglade"]] = {t=10.0};
	[BS["Travel Form"]] = {t=0};
	[BS["Dire Bear Form"]] = {t=0};
	[BS["Cat Form"]] = {t=0};
	[BS["Bear Form"]] = {t=0};
	[BS["Moonkin Form"]] = {t=0};
	[BS["Aquatic Form"]] = {t=0};
	[L["Feral Charge Effect"]] = {t=0};
	[BS["Bash"]] = {t=0};
	[L["Starfire Stun"]] = {t=0};
	[BS["Pounce"]] = {t=0};
	[BS["Nature's Swiftness"]] = {t=0};
	
	-- Hunter
	[BS["Aimed Shot"]] = {t=3.0};
	[BS["Multi-Shot"]] = {t=0.5};
	[BS["Scare Beast"]] = {t=1.5};
	[BS["Dismiss Pet"]] = {t=5.0};
	[BS["Revive Pet"]] = {t=10.0};
	[BS["Eyes of the Beast"]] = {t=2.0};
	[BS["Scatter Shot"]] = {t=0};
	[BS["Freezing Trap Effect"]] = {t=0};
	[BS["Intimidation"]] = {t=0};
	[BS["Wyvern Sting"]] = {t=0};
	
	-- Mage
	[BS["Frostbolt"]] = {t=2.5};
	[BS["Fireball"]] = {t=3.0};
	[BS["Conjure Water"]] = {t=3.0};
	[BS["Conjure Food"]] = {t=3.0};
	[BS["Conjure Mana Ruby"]] = {t=3.0};
	[BS["Conjure Mana Citrine"]] = {t=3.0};
	[BS["Conjure Mana Jade"]] = {t=3.0};
	[BS["Conjure Mana Agate"]] = {t=3.0};
	[BS["Polymorph"]] = {t=1.5};
	[L["Polymorph: Pig"]] = {t=1.5};
	[L["Polymorph: Turtle"]] = {t=1.5};
	[BS["Pyroblast"]] = {t=6.0, d=60.0};
	[BS["Scorch"]] = {t=1.5};
	[BS["Flamestrike"]] = {t=3.0, r="Death Talon Hatcher", a=2};
	[BS["Slow Fall"]] = {t=0, c="gains"};
	[BS["Portal: Darnassus"]] = {t=10.0};
	[BS["Portal: Thunder Bluff"]] = {t=10.0};
	[BS["Portal: Ironforge"]] = {t=10.0};
	[BS["Portal: Orgrimmar"]] = {t=10.0};
	[BS["Portal: Stormwind"]] = {t=10.0};
	[BS["Portal: Undercity"]] = {t=10.0};
	[BS["Teleport: Darnassus"]] = {t=10.0};
	[BS["Teleport: Thunder Bluff"]] = {t=10.0};
	[BS["Teleport: Ironforge"]] = {t=10.0};
	[BS["Teleport: Orgrimmar"]] = {t=10.0};
	[BS["Teleport: Stormwind"]] = {t=10.0};
	[BS["Teleport: Undercity"]] = {t=10.0};
	[BS["Impact"]] = {t=0};
	[BS["Fire Ward"]] = {t=0.0};
	[BS["Frost Ward"]] = {t=0.0};
	[BS["Frost Armor"]] = {t=0.0};
	[BS["Ice Armor"]] = {t=0.0};
	[BS["Mage Armor"]] = {t=0.0};
	[L["Counterspell - Silenced"]] = {t=0.0, ni=1};
	[BS["Ice Barrier"]] = {t=0.0};
	[BS["Mana Shield"]] = {t=0.0};
	[BS["Blink"]] = {t=0};
	[BS["Ice Block"]] = {t=0};
	
	-- Paladin
	[BS["Seal of Wisdom"]] = {t=0};
	[BS["Seal of Light"]] = {t=0};
	[BS["Seal of Righteousness"]] = {t=0};
	[BS["Seal of Command"]] = {t=0};
	[BS["Seal of the Crusader"]] = {t=0};
	[BS["Seal of Justice"]] = {t=0};
	[BS["Righteous Fury"]] = {t=0};
	[BS["Holy Light"]] = {t=2.5};
	[BS["Flash of Light"]] = {t=1.5};
	[BS["Summon Charger"]] = {t=3.0, g=0.0};
	[BS["Summon Warhorse"]] = {t=3.0, g=0.0};
	[BS["Hammer of Wrath"]] = {t=1.0, d=6.0};
	[BS["Holy Wrath"]] = {t=2.0, d=60.0};
	[BS["Turn Undead"]] = {t=1.5, d=30.0};
	[BS["Redemption"]] = {t=10.0};
	[BS["Divine Protection"]] = {t=0};
	[BS["Divine Shield"]] = {t=0};
	[BS["Hammer of Justice"]] = {t=0};
	
	-- Priest
	[BS["Greater Heal"]] = {t=2.5};
	[BS["Flash Heal"]] = {t=1.5};
	[BS["Heal"]] = {t=2.5};
	[BS["Resurrection"]] = {t=10.0};
	[BS["Smite"]] = {t=2};
	[BS["Mind Blast"]] = {t=1.5, d=8.0};
	[BS["Mind Control"]] = {t=3.0};
	[BS["Mana Burn"]] = {t=2.5};
	[BS["Holy Fire"]] = {t=3.0, d=15.0};
	[BS["Mind Soothe"]] = {t=0};
	[BS["Prayer of Healing"]] = {t=3.0};
	[BS["Shackle Undead"]] = {t=1.5};
	[BS["Fade"]] = {t=0};
	[BS["Psychic Scream"]] = {t=0.0};
	[BS["Silence"]] = {t=0.0, ni = 1};
	[BS["Blackout"]] = {t=0.0};
	
	-- Rogue
	[BS["Disarm Trap"]] = {t=5.0};
	[BS["Mind-numbing Poison"]] = {t=3.0};
	[BS["Mind-numbing Poison II"]] = {t=3.0};
	[BS["Mind-numbing Poison III"]] = {t=3.0};
	[BS["Instant Poison"]] = {t=3.0};
	[BS["Instant Poison II"]] = {t=3.0};
	[BS["Instant Poison III"]] = {t=3.0};
	[BS["Instant Poison IV"]] = {t=3.0};
	[BS["Instant Poison V"]] = {t=3.0};
	[BS["Instant Poison VI"]] = {t=3.0};
	[BS["Deadly Poison"]] = {t=3.0};
	[BS["Deadly Poison II"]] = {t=3.0};
	[BS["Deadly Poison III"]] = {t=3.0};
	[BS["Deadly Poison IV"]] = {t=3.0};
	[BS["Deadly Poison V"]] = {t=3.0};
	[BS["Crippling Poison"]] = {t=3.0};
	[BS["Pick Lock"]] = {t=5.0};
	[BS["Blind"]] = {t=0};
	[BS["Gouge"]] = {t=0};
	[BS["Kidney Shot"]] = {t=0};
	[L["Kick - Silenced"]] = {t=0, ni=1};
	[BS["Kick"]] = {t=0, ni=1};
	
	-- Shaman
	[BS["Lesser Healing Wave"]] = {t=1.5};
	[BS["Healing Wave"]] = {t=3.0};
	[BS["Ancestral Spirit"]] = {t=10.0};
	[BS["Chain Lightning"]] = {t=1.5, d=6.0};
	[BS["Ghost Wolf"]] = {t=3.0};
	[BS["Astral Recall"]] = {t=10.0};
	[BS["Chain Heal"]] = {t=2.5};
	[BS["Lightning Bolt"]] = {t=2.0};
	[BS["Far Sight"]] = {t=2.0};
	[BS["Earth Shock"]] = {t=0, ni=1};
	
	-- Warlock
	[BS["Drain Life"]] = {t=7};
	[BS["Shadow Bolt"]] = {t=2.5};
	[BS["Immolate"]] = {t=1.5};
	[BS["Soul Fire"]] = {t=4.0};
	[BS["Searing Pain"]] = {t=1.5};
	[BS["Summon Dreadsteed"]] = {t=3.0};
	[BS["Summon Felsteed"]] = {t=3.0};
	[BS["Summon Imp"]] = {t=6.0};
	[BS["Summon Succubus"]] = {t=6.0};
	[BS["Summon Voidwalker"]] = {t=6.0};
	[BS["Summon Felhunter"]] = {t=6.0};
	[BS["Fear"]] = {t=1.5};
	[BS["Howl of Terror"]] = {t=2.0};
	[BS["Banish"]] = {t=1.5};
	[BS["Ritual of Summoning"]] = {t=5.0};
	[BS["Ritual of Doom"]] = {t=10.0};
	[BS["Create Spellstone"]] = {t=5.0};
	[BS["Create Soulstone"]] = {t=3.0};
	[BS["Create Healthstone"]] = {t=3.0};
	[BS["Create Firestone"]] = {t=3.0};
	[BS["Enslave Demon"]] = {t=3.0};
	[BS["Inferno"]] = {t=2.0};
	[L["Inferno Effect"]] = {t=0};
	[BS["Shadow Ward"]] = {t=0};
	[BS["Death Coil"]] = {t=0.0};
	[BS["Corruption"]] = {t=0};
	[BS["Demon Armor"]] = {t=0};
	[BS["Demon Skin"]] = {t=0};

		-- Succubus
		[BS["Seduction"]] = {t=1.5};
		
		-- Felhunter
		[BS["Spell Lock"]] = {t=0.0, ni=1};
		
		-- Imp
		[BS["Firebolt"]] = {t=2};

	-- Warrior
	[BS["Charge Stun"]] = {t=0};
	[BS["Intercept Stun"]] = {t=0};
	[BS["Revenge Stun"]] = {t=0};
	[BS["Mace Stun Effect"]] = {t=0};
	[BS["Intimidating Shout"]] = {t=0};
	[L["Shield Bash - Silenced"]] = {t=0};
	[BS["Shield Bash"]] = {t=0, ni=1};
	[BS["Pummel"]] = {t=0, ni=1};
	
}

local Raids = {

	-- Ahn'Qiraj

		-- 20 Man Trash
		[L["Explode"]] = {t=6.0};

		-- 40 Man C'thun
		[L["Eye Beam"]] = {t=2};

	-- Blackwing Lair
			
		-- Firemaw/Flamegor/Ebonroc
		[L["Shadow Flame"]] = {t=2.0};
		[L["Wing Buffet"]] = {t=1.0};
		
		-- Neferian/Onyxia
		[L["Bellowing Roar"]] = {t=1.5};
		
		[L["High Priestess Mar'li"]] = true;
		[BS["Drain Life"]] = {t=7};
		
		[L["Emperor Vek'lor"]] = true;
		[L["Gehennas"]] = true;
		[L["Gothik the Harvester"]] = true;
		[BS["Shadow Bolt"]] = {t=1, r=L["Gehennas"], a=0.5};
		[L["Flamewaker Elite"]] = true;
		[BS["Fireball"]] = {t=3, r=L["Flamewaker Elite"], a=1};
		[L["Flamewaker Priest"]] = true;
		[L["Dark Mending"]] = {t=3.5, r=L["Flamewaker Priest"], a=2};
		
		-- Zul'Gurub
		[L["Unstable Concoction"]] = {t=3.0};
}

local NonAfflictions = {
	[BS["Frostbolt"]] = true;
	[BS["Fireball"]] = true;
	[BS["Pyroblast"]] = true;
	[BS["Entangling Roots"]] = true;
	[BS["Soothe Animal"]] = true;
	[BS["Mind Soothe"]] = true;
	[BS["Immolate"]] = true;
	[BS["Corruption"]] = true;
	[BS["Regrowth"]] = true;
--	[BS["Mind Control"]] = true;
	[BS["Holy Fire"]] = true;
	[BS["Greater Heal"]] = true;
}

local Interrupts = {
	[BS["Shield Bash"]] = true;
	[BS["Pummel"]] = true;
	[BS["Kick"]] = true;
	[BS["Earth Shock"]] = true;
}

Cast:RegisterEvent("MINIMAP_ZONE_CHANGED")

local function TriggerCast(mob, spell, castime)
	if CasterDB[mob] then
		CasterDB[mob].sp = spell
		CasterDB[mob].start = GetTime()
		CasterDB[mob].ct = castime
	else
		CasterDB[mob] = {sp = spell, start = GetTime(), ct = castime}
	end
	for _,frame in pairs(LunaUF.Units.frameList) do
		if frame.unit and frame.castBar and LunaUF.db.profile.units[frame.unitGroup].castBar.enabled and mob == UnitName(frame.unit) then
			Cast:FullUpdate(frame)
		end
	end
end

local function TriggerCastStop(mob, spell)
	if CasterDB[mob] and CasterDB[mob].sp and Spells[spell] and not (Spells[spell].ni and Spells[CasterDB[mob].sp] and Spells[CasterDB[mob].sp].ni) then
		if (CasterDB[mob].start + (CasterDB[mob].ct or 0)) > GetTime() then
			CasterDB[mob].ct = 0
			for _,frame in pairs(LunaUF.Units.frameList) do
				if frame.unit and frame.castBar and LunaUF.db.profile.units[frame.unitGroup].castBar.enabled and mob == UnitName(frame.unit) then
					Cast:FullUpdate(frame)
				end
			end
		end
	end
end

local function ProcessData(mob, spell, special)
	local castime
	if (Raids[mob] and Raids[spell]) or (Raids[spell] and not Spells[spell]) then
		if special ~= "hit" then
			castime = Raids[spell].t
			-- Spell might have the same name but a different cast time on another mob, ie. Onyxia/Nefarian on Bellowing Roar
			if Raids[spell].r then
				if (mob == Raids[spell].r) then
					castime = Raids[spell].a
				end
			end
			TriggerCast(mob, spell, castime)
		elseif Interrupts[spell] then
			if CasterDB[mob] and CasterDB[mob].ct and CasterDB[mob].ct > 0 then
				TriggerCastStop(mob, spell)
				return
			end
		end
	else
		if Spells[spell] and special ~= "hit" then
			if special == "afflicted" then
				if not NonAfflictions[spell] then
					TriggerCastStop(mob, spell)
				end
				return
			end
			castime = Spells[spell].t
			if special == "gains" then
				if not NonAfflictions[spell] then
					TriggerCastStop(mob, spell)
				end
				return
			end
			-- Spell might have the same name but a different cast time on another mob, ie. Death Talon Hatchers/Players on Bellowing Roar
			if Spells[spell].r then
				if mob == Spells[spell].r then
					castime = Spells[spell].a
				end
			end
			TriggerCast(mob, spell, castime)
		elseif Interrupts[mob] then -- for these, the two things are parsed in reverse order
			if CasterDB[spell] and CasterDB[spell].ct and CasterDB[spell].ct > 0 then
				TriggerCastStop(spell, mob)
				return
			end
		end
	end
end

function Cast:CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS(arg1)
	if LunaUF.db.profile.enemyCastbars then return end
	for _, pattern in pairs(CHAT_PATTERNS["gains"]) do
		for mob, spell in string.gfind(arg1, pattern) do
			ProcessData(mob, spell, "gains")
			return
		end
	end
end
Cast.CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS = Cast.CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS
Cast.CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS = Cast.CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS

function Cast:CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF(arg1)
	if LunaUF.db.profile.enemyCastbars then return end
	-- casts/performs
	for _, pattern in pairs(CHAT_PATTERNS["casts"]) do
		for mob, spell in string.gfind(arg1, pattern) do
			ProcessData(mob, spell, "casts")
			return
		end
	end
	for _, pattern in pairs(CHAT_PATTERNS["interrupt"]) do
		for mob, spell in string.gfind(arg1, pattern) do
			ProcessData(mob, spell, "hit")
			return
		end
	end
end
Cast.CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF = Cast.CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
Cast.CHAT_MSG_SPELL_PARTY_BUFF = Cast.CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
Cast.CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF = Cast.CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
Cast.CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF = Cast.CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
Cast.CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF = Cast.CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
Cast.CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE = Cast.CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
Cast.CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE = Cast.CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
Cast.CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE = Cast.CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
Cast.CHAT_MSG_SPELL_PARTY_DAMAGE = Cast.CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF

function Cast:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(arg1)
	if LunaUF.db.profile.enemyCastbars then return end
	for _, pattern in pairs(CHAT_PATTERNS["afflicted"]) do
		for mob, spell in string.gfind(arg1, pattern) do
			ProcessData(mob, spell, "afflicted")
			return
		end
	end
end
Cast.CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE = Cast.CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
Cast.CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE = Cast.CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
Cast.CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE = Cast.CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE

function Cast:CHAT_MSG_SPELL_SELF_DAMAGE(arg1)
	if LunaUF.db.profile.enemyCastbars then return end
	for _, pattern in pairs(CHAT_PATTERNS["selfinterrupt"]) do
		for mob, spell in string.gfind(arg1, pattern) do
			ProcessData(mob, spell, "hit")
			return
		end
	end
end

local function OnUpdateOther()
	local elapsed = GetTime() - this.startTime
	if this.casting then
		if this.maxValue >= elapsed then
			this.bar:SetValue(elapsed)
			this.Time:SetText(math.floor((this.maxValue - elapsed)*100)/100)
		else
			this.bar:SetMinMaxValues(0,1)
			this.bar:SetValue(0)
			this.casting = false
			this.Text:Hide()
			this.Time:Hide()
			if LunaUF.db.profile.units[this:GetParent().unitGroup].castBar.hide and not this.hidden then
				this.hidden = true
				LunaUF.Units:PositionWidgets(this:GetParent())
			end
		end
	end
end

local function OnUpdatePlayer()
	local sign
	local frame = this:GetParent()
	local elapsed = GetTime() - frame.castBar.startTime
	local text = string.sub(math.max((frame.castBar.maxValue - elapsed + frame.castBar.delaySum),0)+0.001,1,4)
	if (frame.castBar.delaySum ~= 0) then
		local delay = string.sub(math.max(frame.castBar.delaySum, 0)+0.001,1,4)
		if (frame.castBar.channeling == 1) then
			sign = "-"
		else
			sign = "+"
		end
		text = "|cffcc0000"..sign..delay.."|r "..text
	end
	if frame.castBar.casting or frame.castBar.channeling then
		frame.castBar.Time:SetText(text)
	else
		frame.castBar.Time:SetText("")
	end
	
	if (frame.castBar.casting) then
		if (elapsed > (frame.castBar.maxValue + frame.castBar.delaySum) ) then
			frame.castBar.casting = nil
			elapsed = frame.castBar.maxValue
			frame.castBar:SetScript("OnUpdate", nil)
			Cast:FullUpdate(frame)
			return
		end
		frame.castBar.bar:SetValue(elapsed)
	elseif (frame.castBar.channeling) then
		if (elapsed > frame.castBar.maxValue) then
			elapsed = frame.castBar.maxValue
		end
		if (elapsed == frame.castBar.maxValue) then
			frame.castBar.channeling = nil
			frame.castBar:SetScript("OnUpdate", nil)
			Cast:FullUpdate(frame)
			return
		end
		frame.castBar.bar:SetValue(frame.castBar.maxValue - elapsed)
	end
end

-- stolen from OCB, thanks Athene!

local function ItemLinkToName(link)
	return gsub(link,"^.*%[(.*)%].*$","%1");
end

local function GetItemIconTexture(item)
	if ( not item ) or type(item) ~= "string" or item == "" then return "Interface\\Icons\\Temp" end
	item = string.lower(item)
	local link;
	for i = 1,23 do
		link = GetInventoryItemLink("player",i)
		if ( link ) then
			if ( item == string.lower(ItemLinkToName(link)) )then
				return GetInventoryItemTexture('player', i)
			end
		end
	end
	for i = 1,12 do
		inventoryID = KeyRingButtonIDToInvSlotID(i)
		link = GetInventoryItemLink("player",inventoryID)
		if ( link ) then
			if ( item == string.lower(ItemLinkToName(link)) )then
				return GetInventoryItemTexture('player', inventoryID)
			end
		end
	end
	local texture
	for i = 0,NUM_BAG_FRAMES do
		for j = 1,MAX_CONTAINER_ITEMS do
			link = GetContainerItemLink(i,j)
			if ( link ) then
				if (string.find(string.lower(ItemLinkToName(link)), item)) then
					texture = GetContainerItemInfo(i,j)
				end
			end
		end
	end
	return texture or "Interface\\Icons\\Temp"
end

local function isBuffed()
	for i=1, 32 do
		if UnitBuff("player",i) == "Interface\\Icons\\Racial_Troll_Berserk" then
			return true
		end
	end
end

local function OnEvent()
	local frame = this:GetParent()
	if event == "SPELLCAST_CHANNEL_START" then
		frame.castBar.startTime = GetTime()
		frame.castBar.maxValue = (arg1 / 1000)
		frame.castBar.bar:SetMinMaxValues(0, frame.castBar.maxValue)
		frame.castBar.bar:SetValue(frame.castBar.maxValue)
		frame.castBar.casting = false
		frame.castBar.channeling = true
		frame.castBar.delaySum = 0
		local spellName = CL:GetSpell()
		frame.castBar.Text:SetText(spellName)
		if LunaUF.db.profile.units[frame.unitGroup].castBar.icon then
			frame.castBar.icon:SetTexture(BS:GetSpellIcon(spellName or "") or GetItemIconTexture(spellName))
		end
		frame.castBar:SetScript("OnUpdate", OnUpdatePlayer)
		Cast:FullUpdate(frame)
	elseif event == "SPELLCAST_CHANNEL_UPDATE" then
		if (arg1 == 0) then
			frame.castBar.channeling = nil
			frame.castBar.delaySum = 0
		elseif (frame.castBar.channeling) then
			local losttime = frame.castBar.maxValue - (frame.castBar.maxValue - (arg1 / 1000)) - (arg1 / 1000)
			--frame.castBar.elapsed = frame.castBar.maxValue - (arg1 / 1000)
			frame.castBar.delaySum = frame.castBar.delaySum + losttime
		end
	elseif event == "SPELLCAST_DELAYED" then
		if arg1 then
			frame.castBar.delaySum = (frame.castBar.delaySum or 0) + (arg1 / 1000)
			local statusMin, statusMax = frame.castBar.bar:GetMinMaxValues()
			frame.castBar.bar:SetMinMaxValues(statusMin, (statusMax + (arg1 / 1000)))
		end
	elseif event == "SPELLCAST_START" then
		frame.castBar.maxValue = (arg2 / 1000)
		frame.castBar.startTime = GetTime()
		frame.castBar.casting = true
		frame.castBar.channeling = false
		frame.castBar.delaySum = 0
		frame.castBar.Text:SetText(arg1)
		if LunaUF.db.profile.units[frame.unitGroup].castBar.icon then
			frame.castBar.icon:SetTexture(BS:GetSpellIcon(arg1) or GetItemIconTexture(arg1))
		end
		frame.castBar.bar:SetMinMaxValues(0, frame.castBar.maxValue)
		frame.castBar.bar:SetValue(0)
		frame.castBar:SetScript("OnUpdate", OnUpdatePlayer)
		Cast:FullUpdate(frame)
	elseif event == "UNIT_AURA" then
		local newBuffStatus = isBuffed()
		if not buffed and newBuffStatus then
			buffed = true
			if((UnitHealth("player")/UnitHealthMax("player")) >= 0.40) then
				berserkValue = (1.30 - (UnitHealth("player")/UnitHealthMax("player")))/3
			else
				berserkValue = 0.3
			end
		elseif buffed and not newBuffStatus then
			berserkValue = 0
			buffed = nil
		end
	else
		if (event == "SPELLCAST_CHANNEL_STOP" and not frame.castBar.channeling) then return end
		if (event == "SPELLCAST_FAILED" and frame.castBar.channeling) then return end
		frame.castBar.casting = false
		frame.castBar.channeling = false
		frame.castBar:SetScript("OnUpdate", nil)
		Cast:FullUpdate(frame)
	end
end

local function OnAimed(cast)
	if cast == BS["Aimed Shot"] then
		local _,_, latency = GetNetStats()
		local casttime = 3
		for i=1,32 do
			if UnitBuff("player",i) == "Interface\\Icons\\Ability_Warrior_InnerRage" then
				casttime = casttime/1.3
			end
			if UnitBuff("player",i) == "Interface\\Icons\\Ability_Hunter_RunningShot" then
				casttime = casttime/1.4
			end
			if UnitBuff("player",i) == "Interface\\Icons\\Racial_Troll_Berserk" then
				casttime = casttime/ (1 + berserkValue)
			end
			if UnitBuff("player",i) == "Interface\\Icons\\Inv_Trinket_Naxxramas04" then
				casttime = casttime/1.2
			end
			if UnitDebuff("player",i) == "Interface\\Icons\\Spell_Shadow_CurseOfTounges" then
				casttime = casttime/0.5
			end
		end
		for _,uframe in pairs(LunaUF.Units.frameList) do
			if uframe.castBar and LunaUF.db.profile.units[uframe.unitGroup].castBar.enabled and UnitIsUnit(uframe.unit,"player") then
				uframe.castBar.maxValue = casttime + (latency/1000)
				uframe.castBar.casting = true
				uframe.castBar.channeling = false
				uframe.castBar.delaySum = 0
				uframe.castBar.startTime = GetTime()
				uframe.castBar.Text:SetText(BS["Aimed Shot"])
				if LunaUF.db.profile.units[uframe.unitGroup].castBar.icon then
					uframe.castBar.icon:SetTexture(BS:GetSpellIcon("Aimed Shot"))
				end
				uframe.castBar.bar:SetMinMaxValues(0, uframe.castBar.maxValue)
				uframe.castBar.bar:SetValue(0)
				uframe.castBar:SetScript("OnUpdate", OnUpdatePlayer)
				Cast:FullUpdate(uframe)
			end
		end
	elseif cast == BS["Multi-Shot"] then
		local _,_, latency = GetNetStats()
		for _,uframe in pairs(LunaUF.Units.frameList) do
			if uframe.castBar and LunaUF.db.profile.units[uframe.unitGroup].castBar.enabled and UnitIsUnit(uframe.unit,"player") then
				uframe.castBar.maxValue = 0.5 + (latency/1000)
				uframe.castBar.casting = true
				uframe.castBar.channeling = false
				uframe.castBar.delaySum = 0
				uframe.castBar.startTime = GetTime()
				uframe.castBar.Text:SetText(BS["Multi-Shot"])
				if LunaUF.db.profile.units[uframe.unitGroup].castBar.icon then
					uframe.castBar.icon:SetTexture(BS:GetSpellIcon("Multi-Shot"))
				end
				uframe.castBar.bar:SetMinMaxValues(0, uframe.castBar.maxValue)
				uframe.castBar.bar:SetValue(0)
				uframe.castBar:SetScript("OnUpdate", OnUpdatePlayer)
				Cast:FullUpdate(uframe)
			end
		end
	end
end

local function OnSizeChanged(frame)
	local castBar = frame or this
	local height = castBar:GetHeight()
	local width = castBar:GetWidth()
	local config = LunaUF.db.profile.units[castBar:GetParent().unitGroup].castBar
	if config.icon then
		castBar.icon:ClearAllPoints()
		castBar.bar:ClearAllPoints()
		if config.vertical then
			if config.reverse then
				castBar.icon:SetPoint("TOP", castBar, "TOP")
				castBar.bar:SetPoint("BOTTOM", castBar, "BOTTOM")
			else
				castBar.icon:SetPoint("BOTTOM", castBar, "BOTTOM")
				castBar.bar:SetPoint("TOP", castBar, "TOP")
			end
			castBar.icon:SetHeight(width)
			castBar.icon:SetWidth(width)
			castBar.bar:SetHeight(height-width)
			castBar.bar:SetWidth(width)
		else
			if config.reverse then
				castBar.icon:SetPoint("RIGHT", castBar, "RIGHT")
				castBar.bar:SetPoint("LEFT", castBar, "LEFT")
			else
				castBar.icon:SetPoint("LEFT", castBar, "LEFT")
				castBar.bar:SetPoint("RIGHT", castBar, "RIGHT")
			end
			castBar.icon:SetHeight(height)
			castBar.icon:SetWidth(height)
			castBar.bar:SetHeight(height)
			castBar.bar:SetWidth(width-height)
		end
	else
		castBar.bar:SetHeight(height)
		castBar.bar:SetWidth(width)
	end
end

function Cast:OnEnable(frame)
	if not frame.castBar then
		frame.castBar = CreateFrame("Frame", nil, frame)
		frame.castBar.bar = LunaUF.Units:CreateBar(frame.castBar)
		frame.castBar.bar:SetAllPoints(frame.castBar)
		frame.castBar.icon = frame.castBar:CreateTexture(nil, "ARTWORK")
		frame.castBar.Text = frame.castBar.bar:CreateFontString(nil, "ARTWORK")
		frame.castBar.Text:SetAllPoints(frame.castBar.bar)
		frame.castBar.Text:SetShadowColor(0, 0, 0, 1.0)
		frame.castBar.Text:SetShadowOffset(0.80, -0.80)
		frame.castBar.Text:SetJustifyH("LEFT")
		frame.castBar.Time = frame.castBar.bar:CreateFontString(nil, "ARTWORK")
		frame.castBar.Time:SetAllPoints(frame.castBar.bar)
		frame.castBar.Time:SetShadowColor(0, 0, 0, 1.0)
		frame.castBar.Time:SetShadowOffset(0.80, -0.80)
		frame.castBar.Time:SetJustifyH("RIGHT")
	end
	frame.castBar:RegisterEvent("SPELLCAST_CHANNEL_START")
	frame.castBar:RegisterEvent("SPELLCAST_CHANNEL_STOP")
	frame.castBar:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
	frame.castBar:RegisterEvent("SPELLCAST_DELAYED")
	frame.castBar:RegisterEvent("SPELLCAST_FAILED")
	frame.castBar:RegisterEvent("SPELLCAST_INTERRUPTED")
	frame.castBar:RegisterEvent("SPELLCAST_START")
	frame.castBar:RegisterEvent("SPELLCAST_STOP")
	if playerRace == "Troll" and playerClass == "HUNTER" then
		frame.castBar:RegisterEvent("UNIT_AURA")
	end
	if not LunaUF:IsEventRegistered("CASTLIB_STARTCAST") and playerClass == "HUNTER" then
		LunaUF:RegisterEvent("CASTLIB_STARTCAST", OnAimed)
	end
	frame.castBar:SetScript("OnSizeChanged", OnSizeChanged)
end

function Cast:OnDisable(frame)
	if frame.castBar then
		frame.castBar:SetScript("OnUpdate", nil)
		frame.castBar:SetScript("OnEvent", nil)
		frame.castBar.casting = false
		frame.castBar.channeling = false
		frame.castBar:UnregisterAllEvents()
		frame.castBar:Hide()
	end
end

function Cast:FullUpdate(frame)
	local unitname = UnitName(frame.unit)
	frame.castBar.Text:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\"..LunaUF.db.profile.font..".ttf", LunaUF.db.profile.units[frame.unitGroup].tags.bartags["castBar"].size)
	frame.castBar.Time:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\"..LunaUF.db.profile.font..".ttf", LunaUF.db.profile.units[frame.unitGroup].tags.bartags["castBar"].size)
	if LunaUF.db.profile.units[frame.unitGroup].castBar.vertical then
		frame.castBar.bar:SetOrientation("VERTICAL")
	else
		frame.castBar.bar:SetOrientation("HORIZONTAL")
	end
	frame.castBar.bar:SetReverse(LunaUF.db.profile.units[frame.unitGroup].castBar.reverse)
	if frame.castBar and LunaUF.db.profile.units[frame.unitGroup].castBar.enabled and unitname then
		if not LunaUF.db.profile.units[frame.unitGroup].castBar.icon then
			frame.castBar.icon:SetTexture(nil)
		elseif frame.castBar.casting or frame.castBar.channeling then
			frame.castBar.icon:SetTexture(BS:GetSpellIcon(frame.castBar.Text:GetText() or "") or GetItemIconTexture(frame.castBar.Text:GetText() or ""))
		end
		if frame.castBar.casting then
			frame.castBar.bar:SetStatusBarColor(LunaUF.db.profile.castColors.cast.r, LunaUF.db.profile.castColors.cast.g, LunaUF.db.profile.castColors.cast.b)
		elseif frame.castBar.channeling then
			frame.castBar.bar:SetStatusBarColor(LunaUF.db.profile.castColors.channel.r, LunaUF.db.profile.castColors.channel.g, LunaUF.db.profile.castColors.channel.b)
		end
		if UnitIsUnit(frame.unit,"player") then
			frame.castBar:SetScript("OnEvent", OnEvent)
			if (frame.castBar.casting or frame.castBar.channeling) then
				if not LunaUF.db.profile.units[frame.unitGroup].castBar.vertical then
					frame.castBar.Text:Show()
					frame.castBar.Time:Show()
				end
				if frame.castBar.hidden then
					frame.castBar.hidden = false
					LunaUF.Units:PositionWidgets(frame)
				end
			else
				frame.castBar.Text:Hide()
				frame.castBar.Time:Hide()
				frame.castBar.icon:SetTexture(nil)
				frame.castBar.bar:SetMinMaxValues(0,1)
				frame.castBar.bar:SetValue(0)
				if LunaUF.db.profile.units[frame.unitGroup].castBar.hide and not frame.castBar.hidden then
					frame.castBar.hidden = true
					LunaUF.Units:PositionWidgets(frame)
				elseif not LunaUF.db.profile.units[frame.unitGroup].castBar.hide and frame.castBar.hidden then
					frame.castBar.hidden = nil
					LunaUF.Units:PositionWidgets(frame)
				end
			end
		else
			frame.castBar:SetScript("OnEvent", nil)
			if CasterDB[unitname] and CasterDB[unitname].ct and (CasterDB[unitname].start + CasterDB[unitname].ct) > GetTime() then
				frame.castBar.bar:SetMinMaxValues(0, CasterDB[unitname].ct)
				frame.castBar.startTime = CasterDB[unitname].start
				frame.castBar.maxValue = CasterDB[unitname].ct
				if not LunaUF.db.profile.units[frame.unitGroup].castBar.vertical then
					frame.castBar.Text:Show()
					frame.castBar.Time:Show()
				end
				frame.castBar.Text:SetText(CasterDB[unitname].sp)
				if LunaUF.db.profile.units[frame.unitGroup].castBar.icon then
					frame.castBar.icon:SetTexture(BS:GetSpellIcon(CasterDB[unitname].sp) or GetItemIconTexture(CasterDB[unitname].sp))
				end
				frame.castBar.casting = true
				frame.castBar:SetScript("OnUpdate", OnUpdateOther)
				if frame.castBar.hidden then
					frame.castBar.hidden = false
					LunaUF.Units:PositionWidgets(frame)
				end
			else
				frame.castBar.casting = false
				frame.castBar.channeling = false
				frame.castBar.bar:SetMinMaxValues(0,1)
				frame.castBar.bar:SetValue(0)
				frame.castBar.Text:Hide()
				frame.castBar.Time:Hide()
				frame.castBar.icon:SetTexture(nil)
				frame.castBar:SetScript("OnUpdate", nil)
				if LunaUF.db.profile.units[frame.unitGroup].castBar.hide and not frame.castBar.hidden then
					frame.castBar.hidden = true
					LunaUF.Units:PositionWidgets(frame)
				elseif not LunaUF.db.profile.units[frame.unitGroup].castBar.hide and frame.castBar.hidden then
					frame.castBar.hidden = nil
					LunaUF.Units:PositionWidgets(frame)
				end
			end
		end
		OnSizeChanged(frame.castBar)
	end
end

function Cast:SetBarTexture(frame,texture)
	frame.castBar.bar:SetStatusBarTexture(texture)
	frame.castBar.bar:SetStretchTexture(LunaUF.db.profile.stretchtex)
end

function Cast:MINIMAP_ZONE_CHANGED()
	if DisabledZones[GetMinimapZoneText()] then
		Cast:UnregisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
		Cast:UnregisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")
		Cast:UnregisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
	else
		Cast:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
		Cast:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")
		Cast:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
	end
end

Cast:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
Cast:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF")
Cast:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
Cast:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
Cast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
Cast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
Cast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
Cast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
Cast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE")
Cast:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
Cast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
Cast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
Cast:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF")
Cast:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF")
Cast:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
Cast:MINIMAP_ZONE_CHANGED()
Cast:SetScript("OnEvent", function() this[event](this, arg1) end)