local lib = LibStub and LibStub("LibClassicDurations", true)
if not lib then return end

local Type, Version = "SpellTable", 13
if lib:GetDataVersion(Type) >= Version then return end  -- older versions didn't have that function

local Spell = lib.AddAura
local Talent = lib.Talent

------------------
-- GLOBAL
------------------

Spell(1604, { duration = 4 }) -- Common Daze
Spell( 23605, { duration = 5 }) -- Nightfall (Axe) Proc
Spell( 835, { duration = 3 }) -- Tidal Charm
Spell( 11196, { duration = 60 }) -- Recently Bandaged

Spell({ 13099, 13138, 16566 }, {
    duration = function(spellID)
        if spellID == 13138 then return 20 -- backfire
        elseif spellID == 16566 then return 30 -- backfire
        else return 10 end
    end
}) -- Net-o-Matic

Spell( 23451, { duration = 10 }) -- Battleground speed buff
Spell( 23493, { duration = 10 }) -- Battleground heal buff
Spell( 23505, { duration = 60 }) -- Battleground damage buff
Spell({ 4068, 19769 }, { duration = 3 }) -- Iron Grenade, Thorium
Spell( 6615, { duration = 30, type = "BUFF" }) -- Free Action Potion
Spell( 24364, { duration = 5, type = "BUFF" }) -- Living Action Potion
Spell( 3169, { duration = 6, type = "BUFF" }) -- Limited Invulnerability Potion
Spell( 16621, { duration = 3, type = "BUFF" }) -- Invulnerable Mail
Spell( 1090, { duration = 30 }) -- Magic Dust
Spell( 13327, { duration = 30 }) -- Reckless Charge
Spell({ 26740, 13181 }, { duration = 20 }) -- Mind Control Cap + Backfire
Spell( 11359, { duration = 30, type = "BUFF" }) -- Restorative Potion
Spell( 6727, { duration = 30 }) -- Violet Tragan
Spell( 5024, { duration = 10, type = "BUFF" }) -- Skull of Impending Doom
Spell( 2379, { duration = 15, type = "BUFF" }) -- Swiftness Potion
Spell( 5134, { duration = 10 }) -- Flash Bomb
Spell( 23097, { duration = 5, type = "BUFF" }) -- Fire Reflector
Spell( 23131, { duration = 5, type = "BUFF" }) -- Frost Reflector
Spell( 23132, { duration = 5, type = "BUFF" }) -- Shadow Reflector
Spell({ 25750, 25747, 25746, 23991 }, { duration = 15, type = "BUFF" }) -- AB Trinkets
Spell( 23506, { duration = 20, type = "BUFF" }) -- Arena Grand Master trinket
Spell( 29506, { duration = 20, type = "BUFF" }) -- Burrower's Shell trinket
Spell( 12733, { duration = 30, type = "BUFF" }) -- Blacksmith trinket
-- Spell( 15753, { duration = 2 }) -- Linken's Boomerang stun
-- Spell( 15752, { duration = 10 }) -- Linken's Boomerang disarm
Spell( 14530, { duration = 10, type = "BUFF" }) -- Nifty Stopwatch
Spell( 13237, { duration = 3 }) -- Goblin Mortar trinket
Spell( 14253, { duration = 8, type = "BUFF" }) -- Black Husk Shield
Spell( 9175, { duration = 15, type = "BUFF" }) -- Swift Boots
Spell( 13141, { duration = 20, type = "BUFF" }) -- Gnomish Rocket Boots
Spell( 8892, { duration = 20, type = "BUFF" }) -- Goblin Rocket Boots
Spell( 9774, { duration = 5, type = "BUFF" }) -- Spider Belt & Ornate Mithril Boots

-------------
-- RACIALS
-------------

Spell( 26635 ,{ duration = 10, type = "BUFF" }) -- Berserking
Spell( 20600 ,{ duration = 20, type = "BUFF" }) -- Perception
Spell( 23234 ,{ duration = 15, type = "BUFF" }) -- Blood Fury
Spell( 23230 ,{ duration = 25 }) -- Blood Fury debuff
Spell( 20594 ,{ duration = 8, type = "BUFF" }) -- Stoneform
Spell( 20549 ,{ duration = 2 }) -- War Stomp
Spell( 7744, { duration = 5, type = "BUFF" }) -- Will of the Forsaken

-------------
-- PRIEST
-------------

-- Spell({ 1243, 1244, 1245, 2791, 10937, 10938 }, { duration = 1800, type = "BUFF" }) -- Power Word: Fortitude and Prayer of Fortitude
-- Spell({ 21562, 21564 }, { duration = 3600, type = "BUFF" }) -- Prayer of Fortitude
-- Spell({ 976, 10957, 10958 }, { duration = 600, type = "BUFF" }) -- Shadow Protection
-- Spell( 27683, { duration = 600, type = "BUFF" }) -- Prayer of Shadow Protection
-- Spell({ 14752, 14818, 14819, 27841 }, { duration = 1800, type = "BUFF" }) -- Divine Spirit
-- Spell( 27681, { duration = 3600, type = "BUFF" }) -- Prayer of Spirit

Spell({ 14743, 27828 }, { duration = 6, type = "BUFF" }) -- Focused Casting (Martyrdom)
Spell( 27827, { duration = 10, type = "BUFF" }) -- Spirit of Redemption
Spell( 15271, { duration = 15, type = "BUFF" }) -- Spirit Tap

Spell({ 2652, 19261, 19262, 19264, 19265, 19266 }, { duration = 600, type = "BUFF" }) -- Touch of Weakness
Spell({ 13896, 19271, 19273, 19274, 19275 }, { duration = 15, type = "BUFF" }) -- Feedback
Spell({ 2651, 19289, 19291, 19292, 19293 }, { duration = 15, type = "BUFF" }) -- Elune's Grace
Spell({ 9035, 19281, 19282, 19283, 19284, 19285 }, { duration = 120 }) -- Hex of Weakness

Spell( 6346, { duration = 600, type = "BUFF" }) -- Fear Ward
Spell({ 7001, 27873, 27874 }, { duration = 10, type = "BUFF" }) -- Lightwell Renew
Spell( 552, { duration = 20, type = "BUFF" }) -- Abolish Disease
Spell({ 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 }, {duration = 30, type = "BUFF" }) -- PWS
Spell( 6788, { duration = 15 }) -- Weakened Soul
Spell({ 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315 }, { duration = 15, type = "BUFF" }) -- Renew

Spell( 15487, { duration = 5 }) -- Silence
Spell({ 10797, 19296, 19299, 19302, 19303, 19304, 19305 }, { duration = 6, stacking = true }) -- starshards
Spell({ 2944, 19276, 19277, 19278, 19279, 19280 }, { duration = 24, stacking = true }) --devouring plague
Spell({ 453, 8192, 10953 }, { duration = 15 }) -- mind soothe

Spell({ 9484, 9485, 10955 }, {
    duration = function(spellID)
        if spellID == 9484 then return 30
        elseif spellID == 9485 then return 40
        else return 50 end
    end
}) -- Shackle Undead

Spell( 10060, { duration = 15, type = "BUFF" }) --Power Infusion
Spell({ 14914, 15261, 15262, 15263, 15264, 15265, 15266, 15267 }, { duration = 10, stacking = true }) -- Holy Fire, stacking?
Spell({ 586, 9578, 9579, 9592, 10941, 10942 }, { duration = 10, type = "BUFF" }) -- Fade
Spell({ 8122, 8124, 10888, 10890 }, { duration = 8,  }) -- Psychic Scream
Spell({ 589, 594, 970, 992, 2767, 10892, 10893, 10894 }, { stacking = true,
    duration = function(spellID, isSrcPlayer)
        -- Improved SWP, 2 ranks: Increases the duration of your Shadow Word: Pain spell by 3 sec.
        local talents = isSrcPlayer and 3*Talent(15275, 15317) or 0
        return 18 + talents
    end
}) -- SW:P
Spell( 15269 ,{ duration = 3 }) -- Blackout
Spell( 15258 ,{ duration = 15 }) -- Shadow Vulnerability
Spell( 15286 ,{ duration = 60 }) -- Vampiric Embrace
Spell({ 15407, 17311, 17312, 17313, 17314, 18807 }, { duration = 3 }) -- Mind Flay
Spell({ 605, 10911, 10912 }, { duration = 60 }) -- Mind Control

---------------
-- DRUID
---------------

-- Spell({ 1126, 5232, 5234, 6756, 8907, 9884, 9885 }, { duration = 1800, type = "BUFF" }) -- Mark of the Wild
-- Spell({ 21849, 21850 }, { duration = 3600, type = "BUFF" }) -- Gift of the Wild
Spell( 19975, { duration = 12 }) -- Nature's Grasp root
Spell({ 16689, 16810, 16811, 16812, 16813, 17329 }, { duration = 45, type = "BUFF" }) -- Nature's Grasp
Spell( 16864, { duration = 600, type = "BUFF" }) -- Omen of Clarity
Spell( 16870, { duration = 15, type = "BUFF" }) -- Clearcasting from OoC



Spell( 19675, { duration = 4 }) -- Feral Charge
Spell({ 467, 782, 1075, 8914, 9756, 9910 }, { duration = 600, type = "BUFF" }) -- Thorns
Spell( 22812 ,{ duration = 15, type = "BUFF" }) -- Barkskin
--SKIPPING: Hurricane (Channeled)
Spell({ 339, 1062, 5195, 5196, 9852, 9853 }, {
    duration = function(spellID)
        if spellID == 339 then return 12
        elseif spellID == 1062 then return 15
        elseif spellID == 5195 then return 18
        elseif spellID == 5196 then return 21
        elseif spellID == 9852 then return 24
        else return 27 end
    end
}) -- Entangling Roots
Spell({ 2908, 8955, 9901 }, { duration = 15 }) -- Soothe Animal
Spell({ 770, 778, 9749, 9907, 17390, 17391, 17392 }, { duration = 40 }) -- Faerie Fire
Spell({ 2637, 18657, 18658 }, {
    duration = function(spellID)
        if spellID == 2637 then return 20
        elseif spellID == 18657 then return 30
        else return 40 end
    end
}) -- Hibernate
Spell({ 99, 1735, 9490, 9747, 9898 }, { duration = 30 }) -- Demoralizing Roar
Spell({ 5211, 6798, 8983 }, { stacking = true, -- stacking?
    duration = function(spellID)
        local brutal_impact = Talent(16940, 16941)*0.5
        if spellID == 5211 then return 2+brutal_impact
        elseif spellID == 6798 then return 3+brutal_impact
        else return 4+brutal_impact end
    end
}) -- Bash
Spell( 5209, { duration = 6 }) -- Challenging Roar
Spell( 6795, { duration = 3 }) -- Taunt

Spell({ 1850, 9821 }, { duration = 15, type = "BUFF" }) -- Dash
Spell( 5229, { duration = 10, type = "BUFF" }) -- Enrage
Spell({ 22842, 22895, 22896 }, { duration = 10, type = "BUFF" }) -- Frenzied Regeneration
Spell( 16922, { duration = 3 }) -- Imp Starfire Stun
Spell({ 9005, 9823, 9827 }, {
    duration = function(spellID)
        local brutal_impact = Talent(16940, 16941)*0.5
        return 2+brutal_impact
    end
}) -- Pounce
Spell({ 9007, 9824, 9826 }, { duration = 18, stacking = true, }) -- Pounce Bleed
Spell({ 8921, 8924, 8925, 8926, 8927, 8928, 8929, 9833, 9834, 9835 }, {
    duration = function(spellID)
        if spellID == 8921 then return 9
        else return 12 end
    end
}) -- Moonfire
Spell({ 1822, 1823, 1824, 9904 }, { duration = 9, stacking = true }) -- Rake
Spell({ 1079, 9492, 9493, 9752, 9894, 9896 }, { duration = 12, stacking = true }) -- Rip
Spell({ 5217, 6793, 9845, 9846 }, { name = "Tiger's Fury", duration = 6 })

Spell( 2893 ,{ duration = 8, type = "BUFF" }) -- Abolish Poison
Spell( 29166 , { duration = 20, type = "BUFF" }) -- Innervate

Spell({ 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858 }, { duration = 21, type = "BUFF" }) -- Regrowth
Spell({ 774, 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299 }, { duration = 12, stacking = false, type = "BUFF" }) -- Rejuv
Spell({ 5570, 24974, 24975, 24976, 24977 }, { duration = 12, stacking = true }) -- Insect Swarm

-------------
-- WARRIOR
-------------

Spell( 12294, { duration = 10 }) -- Mortal Strike Healing Reduction

Spell({72, 1671, 1672}, { duration = 6 }) -- Shield Bash
Spell( 18498, { duration = 3 }) -- Improved Shield Bash

Spell( 20230, { duration = 15, type = "BUFF" }) -- Retaliation
Spell( 1719, { duration = 15, type = "BUFF" }) -- Recklessness
Spell( 871, { type = "BUFF", duration = 10 }) -- Shield wall, varies
Spell( 12976, { duration = 20, type = "BUFF" }) -- Last Stand
Spell( 12328, { duration = 30 }) -- Death Wish
Spell({ 772, 6546, 6547, 6548, 11572, 11573, 11574 }, { stacking = true,
    duration = function(spellID)
        if spellID == 772 then return 9
        elseif spellID == 6546 then return 12
        elseif spellID == 6547 then return 15
        elseif spellID == 6548 then return 18
        else return 21 end
    end
}) -- Rend
Spell( 12721, { duration = 12, stacking = true }) -- Deep Wounds

Spell({ 1715, 7372, 7373 }, { duration = 15 }) -- Hamstring
Spell( 23694 , { duration = 5 }) -- Improved Hamstring
Spell({ 6343, 8198, 8204, 8205, 11580, 11581 }, {
    duration = function(spellID)
        if spellID == 6343 then return 10
        elseif spellID == 8198 then return 14
        elseif spellID == 8204 then return 18
        elseif spellID == 8205 then return 22
        elseif spellID == 11580 then return 26
        else return 30 end
    end
}) -- Thunder Clap
Spell({ 694, 7400, 7402, 20559, 20560 }, { duration = 6 }) -- Mocking Blow
Spell( 1161 ,{ duration = 6 }) -- Challenging Shout
Spell( 355 ,{ duration = 3 }) -- Taunt
Spell({ 5242, 6192, 6673, 11549, 11550, 11551, 25289 }, { type = "BUFF",
    duration = function(spellID, isSrcPlayer)
        local talents = isSrcPlayer and Talent(12321, 12835, 12836, 12837, 12838) or 0
        return 120 * (1 + 0.1 * talents)
    end
}) -- Battle Shout
Spell({ 1160, 6190, 11554, 11555, 11556 }, {
    duration = function(spellID, isSrcPlayer)
        local talents = isSrcPlayer and Talent(12321, 12835, 12836, 12837, 12838) or 0
        return 30 * (1 + 0.1 * talents)
    end
}) -- Demoralizing Shout, varies
Spell( 18499, { duration = 10, type = "BUFF" }) -- Berserker Rage
Spell({ 20253, 20614, 20615 }, { duration = 3 }) -- Intercept
Spell( 12323, { duration = 6 }) -- Piercing Howl
Spell( 5246, { duration = 8 }) -- Intimidating Shout Fear
Spell( 20511, { duration = 8 }) -- Intimidating Shout Main Target Cower Effect

Spell( 676 ,{
    duration = function(spellID, isSrcPlayer)
        local talents = isSrcPlayer and Talent(12313, 12804, 12807) or 0
        return 10 + talents
    end,
}) -- Disarm, varies
Spell( 29131 ,{ duration = 10, type = "BUFF" }) -- Bloodrage
Spell( 12798 , { duration = 3 }) -- Imp Revenge Stun
Spell( 2565 ,{ duration = 5, type = "BUFF" }) -- Shield Block, varies BUFF

Spell({ 7386, 7405, 8380, 11596, 11597 }, { duration = 30 }) -- Sunder Armor
Spell( 12809 ,{ duration = 5 }) -- Concussion Blow
Spell( 12292 ,{ duration = 20, type = "BUFF" }) -- Sweeping Strikes
Spell({ 12880, 14201, 14202, 14203, 14204 }, { duration = 12, type = "BUFF" }) -- Enrage
Spell({ 12966, 12967, 12968, 12969, 12970 }, { duration = 15, type = "BUFF" }) -- Flurry
Spell({ 16488, 16490, 16491 }, { duration = 6, type = "BUFF" }) -- Blood Craze
Spell(7922, { duration = 1 }) -- Charge
Spell(5530, { duration = 3 }) -- Mace Specialization

--------------
-- ROGUE
--------------

Spell( 14278 , { duration = 7, type = "BUFF" }) -- Ghostly Strike
Spell({ 16511, 17347, 17348 }, { duration = 15 }) -- Hemorrhage
Spell({ 11327, 11329 }, { duration = 10 }) -- Vanish
Spell({ 3409, 11201 }, { duration = 12 }) -- Crippling Poison
Spell({ 13218, 13222, 13223, 13224 }, { duration = 15 }) -- Wound Poison
Spell({ 2818, 2819, 11353, 11354, 25349 }, { duration = 12, stacking = true }) -- Deadly Poison
Spell({ 5760, 8692, 11398 }, {
    duration = function(spellID)
        if spellID == 5760 then return 10
        elseif spellID == 8692 then return 12
        else return 14 end
    end
}) -- Mind-numbing Poison

Spell( 18425, { duration = 2 }) -- Improved Kick Silence
Spell( 13750, { duration = 15, type = "BUFF" }) -- Adrenaline Rush
Spell( 13877, { duration = 15, type = "BUFF" }) -- Blade Flurry
Spell( 1833, { duration = 4 }) -- Cheap Shot
Spell({ 2070, 6770, 11297 }, {
    duration = function(spellID)
        if spellID == 6770 then return 25 -- yes, Rank 1 spell id is 6770 actually
        elseif spellID == 2070 then return 35
        else return 45 end
    end
}) -- Sap
Spell( 2094 , { duration = 10 }) -- Blind

Spell({ 8647, 8649, 8650, 11197, 11198 }, { duration = 30 }) -- Expose Armor
Spell({ 703, 8631, 8632, 8633, 11289, 11290 }, { duration = 18 }) -- Garrote
Spell({ 408, 8643 }, {
    duration = function(spellID, isSrcPlayer, comboPoints)
        local duration = spellID == 8643 and 1 or 0 -- if Rank 2, add 1s
        if isSrcPlayer then
            return duration + comboPoints
        else
            return duration + 5 -- just assume 5cp i guess
        end
    end
}) -- Kidney Shot

Spell({ 1943, 8639, 8640, 11273, 11274, 11275 }, { stacking = true,
    duration = function(spellID, isSrcPlayer, comboPoints)
        if isSrcPlayer then
            return (6 + comboPoints*2)
        else
            return 16
        end
    end
}) -- Rupture
-- SnD -- player-only, can skip

Spell({ 2983, 8696, 11305 }, { duration = 8, type = "BUFF" }) -- Sprint
Spell( 5277 ,{ duration = 15, type = "BUFF" }) -- Evasion
Spell({ 1776, 1777, 8629, 11285, 11286 }, {
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer then
            return 4 + 0.5*Talent(13741, 13793, 13792)
        else
            return 5.5
        end
    end
}) -- Gouge

Spell( 14251 , { duration = 6 }) -- Riposte (disarm)

------------
-- WARLOCK
------------

Spell({ 20707, 20762, 20763, 20764, 20765 }, { duration = 1800, type = "BUFF" }) -- Soulstone Resurrection
-- Spell({ 687, 696, 706, 1086, 11733, 11734, 11735 }, { duration = 1800, type = "BUFF" }) -- Demon SKin/Armor
-- Spell({ 18791, 18789, 18792, 18790 }, { duration = 1800, type = "BUFF" })  -- Touch of Shadow, Burning Wish, Fel Energy, Fel Stamina

--SKIPPING: Drain Life, Mana, Soul, Enslave, Health funnel, kilrog
Spell( 24259 ,{ duration = 3 }) -- Spell Lock Silence
Spell({ 17767, 17850, 17851, 17852, 17853, 17854 }, { duration = 10 }) -- Consume Shadows (Voidwalker)
Spell( 18118, { duration = 5 }) -- Aftermath Proc
Spell({ 132, 2970, 11743 }, { duration = 600 }) -- Detect Invisibility
Spell( 5697, { duration = 600 }) -- Unending Breath
Spell({ 17794, 17798, 17797, 17799, 17800 }, { duration = 12 }) -- Shadow Vulnerability (Imp Shadow Bolt)
-- SKIPPING: Amplify Curse
Spell({ 1714, 11719 }, { duration = 30 }) -- Curse of Tongues
Spell({ 702, 1108, 6205, 7646, 11707, 11708 },{ duration = 120 }) -- Curse of Weakness
Spell({ 17862, 17937 }, { duration = 300 }) -- Curse of Shadows
Spell({ 1490, 11721, 11722 }, { duration = 300 }) -- Curse of Elements
Spell({ 704, 7658, 7659, 11717 }, { duration = 120 }) -- Curse of Recklessness
Spell( 603 ,{ duration = 60, stacking = true }) -- Curse of Doom
Spell( 18223 ,{ duration = 12 }) -- Curse of Exhaustion
Spell( 6358, {
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer then
            local mul = 1 + Talent(18754, 18755, 18756)*0.1
            return 20*mul
        else
            return 20
        end
    end
}) -- Seduction, varies, Improved Succubus
Spell({ 5484, 17928 }, {
    duration = function(spellID)
        return spellID == 5484 and 10 or 15
    end
}) -- Howl of Terror
Spell({ 5782, 6213, 6215 }, {
    duration = function(spellID)
        if spellID == 5782 then return 10
        elseif spellID == 6213 then return 15
        else return 20 end
    end
}) -- Fear

Spell({ 710, 18647 }, {
    duration = function(spellID)
        return spellID == 710 and 20 or 30
    end
}) -- Banish
Spell({ 6789, 17925, 17926 }, { duration = 3 }) -- Death Coil

Spell({ 18265, 18879, 18880, 18881}, { duration = 30, stacking = true }) -- Siphon Life
Spell({ 980, 1014, 6217, 11711, 11712, 11713 }, { duration = 24, stacking = true }) -- Curse of Agony
Spell({ 172, 6222, 6223, 7648, 11671, 11672, 25311 }, { stacking = true,
    duration = function(spellID)
        if spellID == 172 then
            return 12
        elseif spellID == 6222 then
            return 15
        else
            return 18
        end
    end
})
Spell({ 348, 707, 1094, 2941, 11665, 11667, 11668, 25309 },{ duration = 15, stacking = true }) -- Immolate

Spell({ 6229, 11739, 11740, 28610 } ,{ duration = 30, type = "BUFF" }) -- Shadow Ward
Spell({ 7812, 19438, 19440, 19441, 19442, 19443 }, { duration = 30, type = "BUFF" }) -- Sacrifice
Spell({ 17877, 18867, 18868, 18869, 18870, 18871 }, { duration = 5 }) -- Shadowburn Debuff
Spell( 18093 ,{ duration = 3 }) -- Pyroclasm

---------------
-- SHAMAN
---------------

-- Spell({ 324, 325, 905, 945, 8134, 10431, 10432 }, { duration = 600, type = "BUFF" }) -- Lightning Shield
Spell( 546 ,{ duration = 600, type = "BUFF" }) -- Water Walkign
Spell( 131 ,{ duration = 600, type = "BUFF" }) -- Water Breahing
Spell({ 16257, 16277, 16278, 16279, 16280 }, { duration = 15, type = "BUFF" }) -- Flurry

Spell( 17364 ,{ duration = 12 }) -- Stormstrike
Spell({ 16177, 16236, 16237 }, { duration = 15, type = "BUFF" }) -- Ancestral Fortitude from Ancestral Healing
Spell({ 8056, 8058, 10472, 10473 }, { duration = 8 }) -- Frost Shock
Spell({ 8050, 8052, 8053, 10447, 10448, 29228 }, { duration = 12, stacking = true }) -- Flame Shock
Spell( 29203 ,{ duration = 15, type = "BUFF" }) -- Healing Way
Spell({ 8034, 8037, 10458, 16352, 16353 }, { duration = 8 }) -- Frostbrand Attack
Spell( 3600 ,{ duration = 5 }) -- Earthbind Totem
-- Spell( 8178 ,{ type = "BUFF" }) -- Grounding Totem Effect, no duration

--------------
-- PALADIN
--------------

-- Spell( 25780, { duration = 1800, type = "BUFF" }) -- Righteous Fury

Spell({ 19740, 19834, 19835, 19836, 19837, 19838, 25291 }, { duration = 300, type = "BUFF" }) -- Blessing of Might
Spell({ 25782, 25916 }, { duration = 900, type = "BUFF" }) -- Greater Blessing of Might

Spell({ 19742, 19850, 19852, 19853, 19854, 25290 }, { duration = 300, type = "BUFF" }) -- Blessing of Wisdom
Spell({ 25894, 25918 }, { duration = 900, type = "BUFF" }) -- Greater Blessing of Might

Spell(20217, { duration = 300, type = "BUFF" }) -- Blessing of Kings
Spell(25898, { duration = 900, type = "BUFF" }) -- Greater Blessing of Kings

Spell({ 20911, 20912, 20913 }, { duration = 300, type = "BUFF" }) -- Blessing of Sanctuary
Spell(25899, { duration = 900, type = "BUFF" }) -- Greater Blessing of Sanctuary

Spell(1038, { duration = 300, type = "BUFF" }) -- Blessing of Salvation
Spell(25895, { duration = 900, type = "BUFF" }) -- Greater Blessing of Salvation

Spell({ 19977, 19978, 19979 }, { duration = 300, type = "BUFF" }) -- Blessing of Light
Spell(25890, { duration = 900, type = "BUFF" }) -- Greater Blessing of Light

Spell( 20066, { duration = 6 }) -- Repentance
Spell({ 2878, 5627, 5627 }, {
    duration = function(spellID)
        if spellID == 2878 then return 10
        elseif spellID == 5627 then return 15
        else return 20 end
    end
}) -- Turn Undead

Spell( 1044, { duration = 10, type = "BUFF" }) -- Blessing of Freedom
Spell({ 6940, 20729 }, { duration = 30, type = "BUFF" }) -- Blessing of Sacrifice
Spell({ 1022, 5599, 10278 }, { type = "BUFF",
    duration = function(spellID)
        if spellID == 1022 then return 6
        elseif spellID == 5599 then return 8
        else return 10 end
    end
}) -- Blessing of Protection
Spell(25771, { duration = 60 }) -- Forbearance
Spell({ 498, 5573 }, { type = "BUFF",
    duration = function(spellID)
        return spellID == 498 and 6 or 8
    end
}) -- Divine Protection
Spell({ 642, 1020 }, { type = "BUFF",
    duration = function(spellID)
        return spellID == 642 and 10 or 12
    end
}) -- Divine Shield
Spell({ 20375, 20915, 20918, 20919, 20920 }, { duration = 30, type = "BUFF" }) -- Seal of Command
Spell({ 21084, 20287, 20288, 20289, 20290, 20291, 20292, 20293 }, { duration = 30, type = "BUFF"}) -- Seal of Righteousness
Spell({ 20162, 20305, 20306, 20307, 20308, 21082 }, { duration = 30, type = "BUFF" }) -- Seal of the Crusader
Spell({ 20165, 20347, 20348, 20349 }, { duration = 30, type = "BUFF" }) -- Seal of Light
Spell({ 20166, 20356, 20357 }, { duration = 30, type = "BUFF" }) -- Seal of Wisdom
Spell( 20164 , { duration = 30, type = "BUFF" }) -- Seal of Justice

Spell({ 21183, 20188, 20300, 20301, 20302, 20303 }, { duration = 10 }) -- Judgement of the Crusader
Spell({ 20185, 20344, 20345, 20346 }, {
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer then
            local talents = 10*Talent(20359, 20360, 20361)
            return 10+talents
        else
            return 10
        end
    end
}) -- Judgement of Light
Spell({ 20186, 20354, 20355 }, {
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer then
            local talents = 10*Talent(20359, 20360, 20361)
            return 10+talents
        else
            return 10
        end
    end
}) -- Judgement of Wisdom
Spell(20184, { duration = 10 }) -- Judgement of Justice

Spell({ 853, 5588, 5589, 10308 }, {
    duration = function(spellID)
        if spellID == 853 then return 3
        elseif spellID == 5588 then return 4
        elseif spellID == 5589 then return 5
        else return 6 end
    end
}) -- Hammer of Justice

Spell({ 20925, 20927, 20928 }, { duration = 10, type = "BUFF" }) -- Holy Shield
Spell({ 20128, 20131, 20132, 20133, 20134 }, { duration = 10, type = "BUFF" }) -- Holy Shield
Spell({ 67, 26017, 26018 }, { duration = 10, type = "BUFF" }) -- Vindication
Spell({ 20050, 20052, 20053, 20054, 20055 }, { duration = 8, type = "BUFF" }) -- Vengeance
Spell( 20170 ,{ duration = 2 }) -- Seal of Justice stun

-------------
-- HUNTER
-------------

-- Spell({ 19506, 20905, 20906 }, { duration = 1800, type = "BUFF" }) -- Trueshot Aura
--SKIPPING: Frenzy
Spell({ 1130, 14323, 14324, 14325 }, { duration = 120 }) -- Hunter's Mark
Spell(19263, { duration = 10, type = "BUFF" }) -- Deterrence
Spell(3045, { duration = 15, type = "BUFF" }) -- Rapid Fire
Spell(19574, { duration = 18, type = "BUFF" }) -- Bestial Wrath
Spell({ 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295 }, { duration = 15, stacking = true }) -- Serpent Sting
Spell({ 3043, 14275, 14276, 14277 }, { duration = 20 }) -- Scorpid Sting
Spell({ 3034, 14279, 14280 }, { duration = 8 }) -- Viper Sting
Spell({ 19386, 24132, 24133 }, { duration = 12 }) -- Wyvern Sting
Spell({ 24131, 24134, 24135 }, { duration = 12 }) -- Wyvern Sting Dot
Spell({ 1513, 14326, 14327 }, {
    duration = function(spellID)
        if spellID == 1513 then return 10
        elseif spellID == 14326 then return 15
        else return 20 end
    end
}) -- Scare Beast

Spell(19229, { duration = 5 }) -- Wing Clip Root
Spell({ 19306, 20909, 20910 }, { duration = 5 }) -- Counterattack
-- Spell({ 13812, 14314, 14315 }, { duration = 20, stacking = true }) -- Explosive Trap
Spell({ 13797, 14298, 14299, 14300, 14301 }, { duration = 15, stacking = true }) -- Immolation Trap
Spell({ 3355, 14308, 14309 }, {
    duration = function(spellID, isSrcPlayer)
        local mul = 1
        if isSrcPlayer then
            mul = mul + 0.15*Talent(19239, 19245) -- Clever Traps
        end
        if spellID == 3355 then return 10*mul
        elseif spellID == 14308 then return 15*mul
        else return 20*mul end
    end
}) -- Freezing Trap
Spell(19503, { duration = 4 }) -- Scatter Shot
Spell({ 2974, 14267, 14268 }, { duration = 10 }) -- Wing Clip
Spell(5116, { duration = 4 }) -- Concussive Shot
Spell(19410, { duration = 3 }) -- Conc Stun
Spell(24394, { duration = 3 }) -- Intimidation
Spell(15571, { duration = 4 }) -- Daze from Aspect
Spell(19185, { duration = 5 }) -- Entrapment
Spell(25999, { duration = 1 }) -- Boar Charge

-------------
-- MAGE
-------------

-- Spell({ 1459, 1460, 1461, 10156, 10157 }, { duration = 1800, type = "BUFF" }) -- Arcane Intellect
-- Spell( 23028, { duration = 1800, type = "BUFF" }) -- Arcane Brilliance
-- Spell({ 6117, 22782, 22783 }, { duration = 1800, type = "BUFF" }) -- Mage Armor
-- Spell({ 168, 7300, 7301, 7302, 7320, 10219, 10220 }, { duration = 1800, type = "BUFF" }) -- Frost/Ice Armor

Spell( 2855, { duration = 1800, type = "BUFF" }) -- Detect Magic
Spell( 130, { duration = 1800, type = "BUFF" }) -- Slow Fall

Spell({ 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306 }, {
    duration = function(spellID)
        if spellID == 133 then return 4
        elseif spellID == 143 then return 6
        elseif spellID == 145 then return 6
        else return 8 end
    end
}) -- Fireball


Spell({ 604, 8450, 8451, 10173, 10174 }, { duration = 600, type = "BUFF" }) -- Dampen Magic
Spell({ 1008, 8455, 10169, 10170 }, { duration = 600, type = "BUFF" }) -- Amplify Magic

Spell(18469, { duration = 4 }) -- Imp CS Silence
Spell({ 118, 12824, 12825, 12826, 28270, 28271, 28272 }, {
    duration = function(spellID)
        if spellID == 118 then return 20
        elseif spellID == 12824 then return 30
        elseif spellID == 12825 then return 40
        else return 50 end
    end
}) -- Polymorph
Spell(11958, { duration = 10, type = "BUFF" }) -- Ice Block
Spell({ 1463, 8494, 8495, 10191, 10192, 10193 }, { duration = 60, type = "BUFF" }) -- Mana Shield
Spell({ 11426, 13031, 13032, 13033 }, { duration = 60, type = "BUFF" }) -- Ice Barrier
Spell({ 543, 8457, 8458, 10223, 10225 }, { duration = 30, type = "BUFF" }) -- Fire Ward
Spell({ 6143, 8461, 8462, 10177, 28609 }, { duration = 30, type = "BUFF" }) -- Frost Ward

Spell(12355, { duration = 2 }) -- Impact
Spell(12654, { duration = 4 }) -- Ignite
Spell(22959, { duration = 30 }) -- Fire Vulnerability
Spell({ 11113, 13018, 13019, 13020, 13021 }, { duration = 6 }) -- Blast Wave

Spell({ 2120, 2121, 8422, 8423, 10215, 10216 }, { duration = 8, stacking = true }) -- Flamestrike

Spell({ 120, 8492, 10159, 10160, 10161 }, {
    duration = function(spellID, isSrcPlayer)
        local permafrost = isSrcPlayer and Talent(11175, 12569, 12571) or 0
        return 8 + permafrost
    end
}) -- Cone of Cold

-- DOESN'T APPEAR IN COMBAT LOG
-- Spell({ 12484, 12485, 12486 }, {
--     duration = function(spellID, isSrcPlayer)
--         local permafrost = isSrcPlayer and Talent(11175, 12569, 12571) or 0
--         return 1.5 + permafrost
--     end
-- }) -- Improved Blizzard

Spell({6136, 7321}, {
    duration = function(spellID, isSrcPlayer)
        local permafrost = isSrcPlayer and Talent(11175, 12569, 12571) or 0
        return 5 + permafrost
    end
}) -- Frost Armor

Spell({ 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304 }, {
    duration = function(spellID, isSrcPlayer)
        local permafrost = isSrcPlayer and Talent(11175, 12569, 12571) or 0
        if spellID == 116 then return 5 + permafrost
        elseif spellID == 205 then return 6 + permafrost
        elseif spellID == 837 then return 6 + permafrost
        elseif spellID == 7322 then return 7 + permafrost
        elseif spellID == 8406 then return 7 + permafrost
        elseif spellID == 8407 then return 8 + permafrost
        elseif spellID == 8408 then return 8 + permafrost
        else return 9 + permafrost end
    end
}) -- Frostbolt

Spell(12494, { duration = 5 }) -- Frostbite
Spell({ 122, 865, 6131, 10230 }, { duration = 8 }) -- Frost Nova
-- Spell(12536, { duration = 15 }) -- Clearcasting
Spell(12043, { duration = 15 }) -- Presence of Mind
Spell(12042, { duration = 15 }) -- Arcane Power
Spell(12051, { duration = 8, type = "BUFF" }) -- Evocation




lib:SetDataVersion(Type, Version)