local Cast = {}
local L = LunaUF.L
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")

LunaUF:RegisterModule(Cast, "castBar", L["Cast bar"], true)

local FADE_TIME = 0.30
local currentCasts = {}
local AimedDelay = 1
local interruptIDs = {
	[GetSpellInfo(1766)] = true, -- kick
	[GetSpellInfo(6552)] = true, -- pummel
	[GetSpellInfo(2139)] = true, -- counterspell
	[GetSpellInfo(72)] = true, -- shield bash
	[GetSpellInfo(8042)] = true, -- earth shock
	[GetSpellInfo(853)] = true, -- hammer of justice
	[GetSpellInfo(7922)] = true, -- Charge stun
	[GetSpellInfo(20615)] = true, -- intercept stun
	[GetSpellInfo(5246)] = true, -- Intimidating shout
	[GetSpellInfo(5530)] = true, -- Mace Stun
	[GetSpellInfo(6358)] = true, -- Seduction
	[GetSpellInfo(6789)] = true, -- Death Coil
	[GetSpellInfo(22703)] = true, -- Inferno Effect
	[GetSpellInfo(5484)] = true, -- Howl of Terror
	[GetSpellInfo(5782)] = true, -- Fear
	[GetSpellInfo(408)] = true, -- Kidney Shot
	[GetSpellInfo(1776)] = true, -- Gouge
	[GetSpellInfo(2094)] = true, -- Blind
	[GetSpellInfo(15269)] = true, -- Blackout
	[GetSpellInfo(15487)] = true, -- Silence
	[GetSpellInfo(8122)] = true, -- Psychic Scream
	[GetSpellInfo(20170)] = true, -- Seal of Justice
	[GetSpellInfo(3355)] = true, -- Freezing Trap
	[GetSpellInfo(9005)] = true, -- Pounce
	[GetSpellInfo(16922)] = true, -- Starfire Stun
	[GetSpellInfo(5211)] = true, -- Bash
	[GetSpellInfo(19675)] = true, -- Feral Charge Effect
	
}
local channelIDs = {
	[GetSpellInfo(10)] = 7.5,		--Blizzard
	[GetSpellInfo(605)] = 3,		--Mind Control
	[GetSpellInfo(689)] = 4.5,		--Drain Life
	[GetSpellInfo(740)] = 9.5,		--Tranquility
	[GetSpellInfo(746)] = 7,		--First Aid
	[GetSpellInfo(755)] = 10,		--Health Funnel
	[GetSpellInfo(1002)] = 60,		--Eyes of the Beast
	[GetSpellInfo(1120)] = 14.5,	--Drain Soul
	[GetSpellInfo(1949)] = 15,		--Hellfire
	[GetSpellInfo(2096)] = 60,		--Mind Vision
	[GetSpellInfo(5138)] = 4.5,		--Drain Mana
	[GetSpellInfo(5143)] = 4.5,		--Arcane Missiles
	[GetSpellInfo(5740)] = 7.5,		--Rain of Fire
	[GetSpellInfo(6197)] = 60,		--Eagle Eye
	[GetSpellInfo(12051)] = 8,		--Evocation
	[GetSpellInfo(13278)] = 4,		--Gnomish Death Ray
	[GetSpellInfo(15407)] = 3,		--Mind Flay
	[GetSpellInfo(17401)] = 9.5,	--Hurricane
	[GetSpellInfo(20577)] = 10,		--Cannibalize
}

local castTimeDB = {
	[GetSpellInfo(17745)] = 17745, -- Diseased Spit
	[GetSpellInfo(3960)] = 3960, -- Portable Bronze Mortar
	[GetSpellInfo(21954)] = 21954, -- Dispel Poison
	[GetSpellInfo(18440)] = 18440, -- Mooncloth Leggings
	[GetSpellInfo(28165)] = 28165, -- Shadow Guard
	[GetSpellInfo(17204)] = 17204, -- Summon Skeleton
	[GetSpellInfo(18403)] = 18403, -- Frostweave Tunic
	[GetSpellInfo(9781)] = 9781, -- Mithril Shield Spike
	[GetSpellInfo(9478)] = 9478, -- Invis Placing Bear Trap
	[GetSpellInfo(9972)] = 9972, -- Ornate Mithril Breastplate
	[GetSpellInfo(16641)] = 16641, -- Dense Sharpening Stone
	[GetSpellInfo(3173)] = 3173, -- Lesser Mana Potion
	[GetSpellInfo(19755)] = 19755, -- Frightalon
	[GetSpellInfo(19102)] = 19102, -- Runic Leather Armor
	[GetSpellInfo(13228)] = 13228, -- Wound Poison II
	[GetSpellInfo(28397)] = 28397, -- Reputation - Gadgetzan +500
	[GetSpellInfo(18452)] = 18452, -- Mooncloth Circlet
	[GetSpellInfo(19048)] = 19048, -- Heavy Scorpid Bracers
	[GetSpellInfo(29332)] = 29332, -- Fire-toasted Bun
	[GetSpellInfo(25177)] = 25177, -- Fire Weakness
	[GetSpellInfo(22566)] = 22566, -- Hex
	[GetSpellInfo(17196)] = 17196, -- Seeping Willow
	[GetSpellInfo(9575)] = 9575, -- Self Detonation
	[GetSpellInfo(25166)] = 25166, -- Call Glyphs of Warding
	[GetSpellInfo(19050)] = 19050, -- Green Dragonscale Breastplate
	[GetSpellInfo(12585)] = 12585, -- Solid Blasting Powder
	[GetSpellInfo(28297)] = 28297, -- Lightning Totem
	[GetSpellInfo(24165)] = 24165, -- Hoodoo Hex
	[GetSpellInfo(13692)] = 13692, -- Dire Growl
	[GetSpellInfo(12093)] = 12093, -- Tuxedo Jacket
	[GetSpellInfo(3978)] = 3978, -- Standard Scope
	[GetSpellInfo(16060)] = 16060, -- Golden Sabercat
	[GetSpellInfo(18442)] = 18442, -- Felcloth Hood
	[GetSpellInfo(12053)] = 12053, -- Black Mageweave Gloves
	[GetSpellInfo(2164)] = 2164, -- Fine Leather Gloves
	[GetSpellInfo(3170)] = 3170, -- Weak Troll's Blood Potion
	[GetSpellInfo(10840)] = 10840, -- Mageweave Bandage
	[GetSpellInfo(2666)] = 2666, -- Runed Copper Belt
	[GetSpellInfo(21544)] = 21544, -- Create Shredder
	[GetSpellInfo(24093)] = 24093, -- Bloodvine Boots
	[GetSpellInfo(5270)] = 5270, -- Stonesplinter Disguise
	[GetSpellInfo(20890)] = 20890, -- Dark Iron Reaver
	[GetSpellInfo(10703)] = 10703, -- Summon Wood Frog
	[GetSpellInfo(8365)] = 8365, -- Enlarge
	[GetSpellInfo(12511)] = 12511, -- Torch Combine
	[GetSpellInfo(28305)] = 28305, -- Copy of Great Heal
	[GetSpellInfo(3324)] = 3324, -- Runed Copper Pants
	[GetSpellInfo(3760)] = 3760, -- Hillman's Cloak
	[GetSpellInfo(16726)] = 16726, -- Runic Plate Helm
	[GetSpellInfo(9435)] = 9435, -- Detonation
	[GetSpellInfo(11988)] = 11988, -- Fireball Volley
	[GetSpellInfo(2661)] = 2661, -- Copper Chain Belt
	[GetSpellInfo(1916)] = 1916, -- Sacrifice (NSE)
	[GetSpellInfo(24655)] = 24655, -- Green Dragonscale Gauntlets
	[GetSpellInfo(3635)] = 3635, -- Crystal Gaze
	[GetSpellInfo(23214)] = 23214, -- Summon Charger
	[GetSpellInfo(9195)] = 9195, -- Dusky Leather Leggings
	[GetSpellInfo(13230)] = 13230, -- Wound Poison IV
	[GetSpellInfo(11535)] = 11535, -- Opening Safe
	[GetSpellInfo(11895)] = 11895, -- Healing Wave of Antu'sul
	[GetSpellInfo(16658)] = 16658, -- Imperial Plate Helm
	[GetSpellInfo(17951)] = 17951, -- Create Firestone
	[GetSpellInfo(2337)] = 2337, -- Lesser Healing Potion
	[GetSpellInfo(18406)] = 18406, -- Runecloth Robe
	[GetSpellInfo(15861)] = 15861, -- Jungle Stew
	[GetSpellInfo(16656)] = 16656, -- Radiant Boots
	[GetSpellInfo(18763)] = 18763, -- Freeze
	[GetSpellInfo(3861)] = 3861, -- Long Silken Cloak
	[GetSpellInfo(27721)] = 27721, -- Very Berry Cream
	[GetSpellInfo(19087)] = 19087, -- Frostsaber Gloves
	[GetSpellInfo(22905)] = 22905, -- Place Unfired Blade
	[GetSpellInfo(24263)] = 24263, -- UNUSED Quest - Create Empowered Mojo Bundle
	[GetSpellInfo(12198)] = 12198, -- Marksman Hit
	[GetSpellInfo(28738)] = 28738, -- Summon Speedy
	[GetSpellInfo(7673)] = 7673, -- Nether Gem
	[GetSpellInfo(27829)] = 27829, -- Titanic Leggings
	[GetSpellInfo(3605)] = 3605, -- Summon Remote-Controlled Golem
	[GetSpellInfo(17573)] = 17573, -- Greater Arcane Elixir
	[GetSpellInfo(3176)] = 3176, -- Strong Troll's Blood Potion
	[GetSpellInfo(3872)] = 3872, -- Rich Purple Silk Shirt
	[GetSpellInfo(23639)] = 23639, -- Blackfury
	[GetSpellInfo(24006)] = 24006, -- Bounty of the Harvest
	[GetSpellInfo(12907)] = 12907, -- Gnomish Mind Control Cap
	[GetSpellInfo(22704)] = 22704, -- Field Repair Bot 74A
	[GetSpellInfo(26265)] = 26265, -- Create Elune Stone
	[GetSpellInfo(16195)] = 16195, -- Create Knucklebone Pouch
	[GetSpellInfo(12248)] = 12248, -- Amplify Damage
	[GetSpellInfo(19719)] = 19719, -- Use Bauble
	[GetSpellInfo(11923)] = 11923, -- Repair the Blade of Heroes
	[GetSpellInfo(7720)] = 7720, -- Ritual of Summoning Effect
	[GetSpellInfo(3370)] = 3370, -- Crocolisk Steak
	[GetSpellInfo(3854)] = 3854, -- Azure Silk Gloves
	[GetSpellInfo(9957)] = 9957, -- Orcish War Leggings
	[GetSpellInfo(20565)] = 20565, -- Magma Blast
	[GetSpellInfo(17707)] = 17707, -- Summon Panda
	[GetSpellInfo(26069)] = 26069, -- Silence
	[GetSpellInfo(7636)] = 7636, -- Green Woolen Robe
	[GetSpellInfo(2829)] = 2829, -- Sharpen Blade II
	[GetSpellInfo(9068)] = 9068, -- Light Leather Pants
	[GetSpellInfo(23638)] = 23638, -- Black Amnesty
	[GetSpellInfo(3844)] = 3844, -- Heavy Woolen Cloak
	[GetSpellInfo(7147)] = 7147, -- Guardian Pants
	[GetSpellInfo(6358)] = 6358, -- Seduction
	[GetSpellInfo(12851)] = 12851, -- Release the Hounds
	[GetSpellInfo(18418)] = 18418, -- Cindercloth Cloak
	[GetSpellInfo(9954)] = 9954, -- Truesilver Gauntlets
	[GetSpellInfo(3939)] = 3939, -- Lovingly Crafted Boomstick
	[GetSpellInfo(3936)] = 3936, -- Deadly Blunderbuss
	[GetSpellInfo(6671)] = 6671, -- Create Scroll
	[GetSpellInfo(17453)] = 17453, -- Green Mechanostrider
	[GetSpellInfo(10696)] = 10696, -- Summon Azure Whelpling
	[GetSpellInfo(3657)] = 3657, -- Summon Spell Guard
	[GetSpellInfo(9193)] = 9193, -- Heavy Quiver
	[GetSpellInfo(6366)] = 6366, -- Create Firestone (Lesser)
	[GetSpellInfo(29467)] = 29467, -- Power of the Scourge
	[GetSpellInfo(22725)] = 22725, -- Defense +3
	[GetSpellInfo(19790)] = 19790, -- Thorium Grenade
	[GetSpellInfo(3849)] = 3849, -- Reinforced Woolen Shoulders
	[GetSpellInfo(3263)] = 3263, -- Touch of Ravenclaw
	[GetSpellInfo(7121)] = 7121, -- Anti-Magic Shield
	[GetSpellInfo(15575)] = 15575, -- Flame Cannon
	[GetSpellInfo(2740)] = 2740, -- Bronze Mace
	[GetSpellInfo(2881)] = 2881, -- Light Leather
	[GetSpellInfo(11466)] = 11466, -- Gift of Arthas
	[GetSpellInfo(16652)] = 16652, -- Thorium Boots
	[GetSpellInfo(3567)] = 3567, -- Teleport: Orgrimmar
	[GetSpellInfo(28327)] = 28327, -- Steam Tonk Controller
	[GetSpellInfo(25145)] = 25145, -- Merithra's Wake
	[GetSpellInfo(8240)] = 8240, -- Elixir of Giant Growth
	[GetSpellInfo(16058)] = 16058, -- Primal Leopard
	[GetSpellInfo(9654)] = 9654, -- Jumping Lightning
	[GetSpellInfo(17637)] = 17637, -- Flask of Supreme Power
	[GetSpellInfo(24179)] = 24179, -- Create Seal of the Dawn
	[GetSpellInfo(15095)] = 15095, -- Molten Blast
	[GetSpellInfo(3870)] = 3870, -- Dark Silk Shirt
	[GetSpellInfo(4165)] = 4165, -- Throw Rock II
	[GetSpellInfo(3565)] = 3565, -- Teleport: Darnassus
	[GetSpellInfo(3515)] = 3515, -- Golden Scale Boots
	[GetSpellInfo(3966)] = 3966, -- Craftsman's Monocle
	[GetSpellInfo(18560)] = 18560, -- Mooncloth
	[GetSpellInfo(6215)] = 6215, -- Fear
	[GetSpellInfo(23249)] = 23249, -- Great Brown Kodo
	[GetSpellInfo(20685)] = 20685, -- Storm Bolt
	[GetSpellInfo(25149)] = 25149, -- Arygos's Vengeance
	[GetSpellInfo(23652)] = 23652, -- Blackguard
	[GetSpellInfo(20916)] = 20916, -- Mithril Headed Trout
	[GetSpellInfo(19566)] = 19566, -- Salt Shaker
	[GetSpellInfo(22480)] = 22480, -- Tender Wolf Steak
	[GetSpellInfo(3325)] = 3325, -- Gemmed Copper Gauntlets
	[GetSpellInfo(30047)] = 30047, -- Crystal Throat Lozenge
	[GetSpellInfo(9200)] = 9200, -- Create Sapta
	[GetSpellInfo(16600)] = 16600, -- Might of Shahram
	[GetSpellInfo(7120)] = 7120, -- Proudmoore's Defense
	[GetSpellInfo(16744)] = 16744, -- Enchanted Thorium Leggings
	[GetSpellInfo(12908)] = 12908, -- Goblin Dragon Gun
	[GetSpellInfo(19058)] = 19058, -- Rugged Armor Kit
	[GetSpellInfo(20848)] = 20848, -- Flarecore Mantle
	[GetSpellInfo(25123)] = 25123, -- Brilliant Mana Oil
	[GetSpellInfo(3500)] = 3500, -- Shadow Crescent Axe
	[GetSpellInfo(3862)] = 3862, -- Icy Cloak
	[GetSpellInfo(3264)] = 3264, -- Blood Howl
	[GetSpellInfo(23709)] = 23709, -- Corehound Belt
	[GetSpellInfo(19512)] = 19512, -- Apply Salve
	[GetSpellInfo(3636)] = 3636, -- Crystalline Slumber
	[GetSpellInfo(27571)] = 27571, -- Cascade of Roses
	[GetSpellInfo(12709)] = 12709, -- Collecting Fallout
	[GetSpellInfo(12063)] = 12063, -- Stormcloth Gloves
	[GetSpellInfo(10707)] = 10707, -- Summon Great Horned Owl
	[GetSpellInfo(8467)] = 8467, -- White Woolen Dress
	[GetSpellInfo(22720)] = 22720, -- Black War Ram
	[GetSpellInfo(23308)] = 23308, -- Incinerate
	[GetSpellInfo(3506)] = 3506, -- Green Iron Leggings
	[GetSpellInfo(24815)] = 24815, -- Draw Ancient Glyphs
	[GetSpellInfo(7125)] = 7125, -- Toxic Saliva
	[GetSpellInfo(28396)] = 28396, -- Reputation - Everlook +500
	[GetSpellInfo(1002)] = 1002, -- Eyes of the Beast
	[GetSpellInfo(15833)] = 15833, -- Dreamless Sleep Potion
	[GetSpellInfo(10711)] = 10711, -- Summon Snowshoe Rabbit
	[GetSpellInfo(10790)] = 10790, -- Tiger
	[GetSpellInfo(28271)] = 28271, -- Polymorph
	[GetSpellInfo(12584)] = 12584, -- Gold Power Core
	[GetSpellInfo(10554)] = 10554, -- Tough Scorpid Boots
	[GetSpellInfo(9818)] = 9818, -- Barbaric Iron Boots
	[GetSpellInfo(3132)] = 3132, -- Chilling Breath
	[GetSpellInfo(16473)] = 16473, -- Summoned Urok
	[GetSpellInfo(24963)] = 24963, -- Honor Points +228
	[GetSpellInfo(18363)] = 18363, -- Riding Kodo
	[GetSpellInfo(2739)] = 2739, -- Copper Shortsword
	[GetSpellInfo(21160)] = 21160, -- Eye of Sulfuras
	[GetSpellInfo(7408)] = 7408, -- Heavy Copper Maul
	[GetSpellInfo(16032)] = 16032, -- Merging Oozes
	[GetSpellInfo(23180)] = 23180, -- Release Imp
	[GetSpellInfo(23219)] = 23219, -- Swift Mistsaber
	[GetSpellInfo(7213)] = 7213, -- Giant Clam Scorcho
	[GetSpellInfo(21370)] = 21370, -- Planting Jeztor's Beacon
	[GetSpellInfo(10687)] = 10687, -- Summon White Plymouth Rock
	[GetSpellInfo(25119)] = 25119, -- Lesser Wizard Oil
	[GetSpellInfo(13528)] = 13528, -- Decayed Strength
	[GetSpellInfo(24997)] = 24997, -- Greater Dispel
	[GetSpellInfo(12587)] = 12587, -- Bright-Eye Goggles
	[GetSpellInfo(3722)] = 3722, -- Summon Syndicate Spectre
	[GetSpellInfo(6530)] = 6530, -- Sling Dirt
	[GetSpellInfo(24912)] = 24912, -- Darkrune Gauntlets
	[GetSpellInfo(23704)] = 23704, -- Timbermaw Brawlers
	[GetSpellInfo(11478)] = 11478, -- Elixir of Detect Demon
	[GetSpellInfo(7295)] = 7295, -- Soul Drain
	[GetSpellInfo(29134)] = 29134, -- Maypole
	[GetSpellInfo(18476)] = 18476, -- Summon Minion
	[GetSpellInfo(21181)] = 21181, -- Summon Shadowstrike
	[GetSpellInfo(2833)] = 2833, -- Armor +24
	[GetSpellInfo(16447)] = 16447, -- Spawn Challenge to Urok
	[GetSpellInfo(6653)] = 6653, -- Dire Wolf
	[GetSpellInfo(7136)] = 7136, -- Shadow Port
	[GetSpellInfo(27832)] = 27832, -- Sageblade
	[GetSpellInfo(18423)] = 18423, -- Runecloth Boots
	[GetSpellInfo(9974)] = 9974, -- Truesilver Breastplate
	[GetSpellInfo(3447)] = 3447, -- Healing Potion
	[GetSpellInfo(4096)] = 4096, -- Raptor Hide Harness
	[GetSpellInfo(23204)] = 23204, -- Place Scryer
	[GetSpellInfo(17738)] = 17738, -- Curse of the Plague Rat
	[GetSpellInfo(4950)] = 4950, -- Summon Helcular's Puppets
	[GetSpellInfo(19095)] = 19095, -- Living Breastplate
	[GetSpellInfo(12758)] = 12758, -- Goblin Rocket Helmet
	[GetSpellInfo(3451)] = 3451, -- Mighty Troll's Blood Potion
	[GetSpellInfo(17635)] = 17635, -- Flask of the Titans
	[GetSpellInfo(12586)] = 12586, -- Solid Dynamite
	[GetSpellInfo(3973)] = 3973, -- Silver Contact
	[GetSpellInfo(25186)] = 25186, -- Super Crystal
	[GetSpellInfo(9156)] = 9156, -- Create Mage's Orb
	[GetSpellInfo(8465)] = 8465, -- Simple Dress
	[GetSpellInfo(16996)] = 16996, -- Incendia Powder
	[GetSpellInfo(10572)] = 10572, -- Wild Leather Leggings
	[GetSpellInfo(2393)] = 2393, -- White Linen Shirt
	[GetSpellInfo(16661)] = 16661, -- Storm Gauntlets
	[GetSpellInfo(22949)] = 22949, -- Seal Felvine Shard
	[GetSpellInfo(3942)] = 3942, -- Whirring Bronze Gizmo
	[GetSpellInfo(10436)] = 10436, -- Attack
	[GetSpellInfo(23221)] = 23221, -- Swift Frostsaber
	[GetSpellInfo(19772)] = 19772, -- Summon Lifelike Toad
	[GetSpellInfo(24847)] = 24847, -- Spitfire Gauntlets
	[GetSpellInfo(26420)] = 26420, -- Large Blue Rocket
	[GetSpellInfo(3400)] = 3400, -- Soothing Turtle Bisque
	[GetSpellInfo(7223)] = 7223, -- Golden Scale Bracers
	[GetSpellInfo(25813)] = 25813, -- Conjure Dream Rift
	[GetSpellInfo(28745)] = 28745, -- Quest - Prepare Field Duty Papers
	[GetSpellInfo(17009)] = 17009, -- Voodoo
	[GetSpellInfo(2165)] = 2165, -- Medium Armor Kit
	[GetSpellInfo(7179)] = 7179, -- Elixir of Water Breathing
	[GetSpellInfo(4141)] = 4141, -- Summon Myzrael
	[GetSpellInfo(23637)] = 23637, -- Dark Iron Gauntlets
	[GetSpellInfo(6630)] = 6630, -- Set NG-5 Charge (Red)
	[GetSpellInfo(10340)] = 10340, -- Uldaman Boss Agro
	[GetSpellInfo(29331)] = 29331, -- Copy of Dark Desire
	[GetSpellInfo(13227)] = 13227, -- Wound Poison
	[GetSpellInfo(7845)] = 7845, -- Elixir of Firepower
	[GetSpellInfo(12720)] = 12720, -- Goblin "Boom" Box
	[GetSpellInfo(20051)] = 20051, -- Runed Arcanite Rod
	[GetSpellInfo(5567)] = 5567, -- Miring Mud
	[GetSpellInfo(3813)] = 3813, -- Small Silk Pack
	[GetSpellInfo(12905)] = 12905, -- Gnomish Rocket Boots
	[GetSpellInfo(27658)] = 27658, -- Enchanted Mageweave Pouch
	[GetSpellInfo(9933)] = 9933, -- Heavy Mithril Pants
	[GetSpellInfo(24356)] = 24356, -- Bloodvine Goggles
	[GetSpellInfo(16651)] = 16651, -- Thorium Shield Spike
	[GetSpellInfo(23247)] = 23247, -- Great White Kodo
	[GetSpellInfo(9055)] = 9055, -- Create Witherbark Totem Bundle
	[GetSpellInfo(3949)] = 3949, -- Silver-plated Shotgun
	[GetSpellInfo(13900)] = 13900, -- Fiery Burst
	[GetSpellInfo(35)] = 35, -- Teleport Elwynn
	[GetSpellInfo(1403)] = 1403, -- Summon Succubus
	[GetSpellInfo(2157)] = 2157, -- Light Winter Boots
	[GetSpellInfo(23122)] = 23122, -- Jaina's Autograph
	[GetSpellInfo(3840)] = 3840, -- Heavy Linen Gloves
	[GetSpellInfo(14928)] = 14928, -- Nagmara's Love Potion
	[GetSpellInfo(3492)] = 3492, -- Hardened Iron Shortsword
	[GetSpellInfo(23708)] = 23708, -- Chromatic Gauntlets
	[GetSpellInfo(26373)] = 26373, -- Lunar Invititation
	[GetSpellInfo(15596)] = 15596, -- Smoking Heart of the Mountain
	[GetSpellInfo(10771)] = 10771, -- Soul Shatter
	[GetSpellInfo(19561)] = 19561, -- Summon Gnashjaw
	[GetSpellInfo(12903)] = 12903, -- Gnomish Harm Prevention Belt
	[GetSpellInfo(17463)] = 17463, -- Blue Skeletal Horse
	[GetSpellInfo(12802)] = 12802, -- Getting Tide Pool Sample #1
	[GetSpellInfo(16868)] = 16868, -- Banshee Wail
	[GetSpellInfo(19070)] = 19070, -- Heavy Scorpid Belt
	[GetSpellInfo(6419)] = 6419, -- Lean Venison
	[GetSpellInfo(17529)] = 17529, -- Vitreous Focuser
	[GetSpellInfo(30732)] = 30732, -- Worm Sweep
	[GetSpellInfo(8138)] = 8138, -- Mirkfallon Fungus
	[GetSpellInfo(12895)] = 12895, -- Inlaid Mithril Cylinder Plans
	[GetSpellInfo(9583)] = 9583, -- Water Sample
	[GetSpellInfo(24168)] = 24168, -- Animist's Caress
	[GetSpellInfo(458)] = 458, -- Brown Horse
	[GetSpellInfo(19819)] = 19819, -- Voice Amplification Modulator
	[GetSpellInfo(6918)] = 6918, -- Summon Snufflenose
	[GetSpellInfo(8764)] = 8764, -- Earthen Vest
	[GetSpellInfo(5761)] = 5761, -- Mind-numbing Poison
	[GetSpellInfo(10912)] = 10912, -- Mind Control
	[GetSpellInfo(9482)] = 9482, -- Amplify Flames
	[GetSpellInfo(10789)] = 10789, -- Spotted Frostsaber
	[GetSpellInfo(12805)] = 12805, -- Getting Tide Pool Sample #2
	[GetSpellInfo(16986)] = 16986, -- Blood Talon
	[GetSpellInfo(3335)] = 3335, -- Dark Sludge
	[GetSpellInfo(23208)] = 23208, -- Exorcise Spirits
	[GetSpellInfo(9950)] = 9950, -- Ornate Mithril Gloves
	[GetSpellInfo(3607)] = 3607, -- Yenniku's Release
	[GetSpellInfo(10683)] = 10683, -- Summon Green Wing Macaw
	[GetSpellInfo(14930)] = 14930, -- Quickdraw Quiver
	[GetSpellInfo(5666)] = 5666, -- Summon Timberling
	[GetSpellInfo(28526)] = 28526, -- Icebolt
	[GetSpellInfo(2149)] = 2149, -- Handstitched Leather Boots
	[GetSpellInfo(3920)] = 3920, -- Crafted Light Shot
	[GetSpellInfo(24334)] = 24334, -- Acid Spit
	[GetSpellInfo(25167)] = 25167, -- Call Ancients
	[GetSpellInfo(2538)] = 2538, -- Charred Wolf Meat
	[GetSpellInfo(6617)] = 6617, -- Rage Potion
	[GetSpellInfo(11453)] = 11453, -- Magic Resistance Potion
	[GetSpellInfo(6500)] = 6500, -- Goblin Deviled Clams
	[GetSpellInfo(10647)] = 10647, -- Feathered Breastplate
	[GetSpellInfo(12091)] = 12091, -- White Wedding Dress
	[GetSpellInfo(12089)] = 12089, -- Tuxedo Pants
	[GetSpellInfo(12890)] = 12890, -- Deep Slumber
	[GetSpellInfo(20531)] = 20531, -- Bind Chapter 3
	[GetSpellInfo(15998)] = 15998, -- Capture Worg Pup
	[GetSpellInfo(16528)] = 16528, -- Numbing Pain
	[GetSpellInfo(27291)] = 27291, -- Summon Magic Staff
	[GetSpellInfo(16654)] = 16654, -- Radiant Gloves
	[GetSpellInfo(16588)] = 16588, -- Dark Mending
	[GetSpellInfo(27287)] = 27287, -- Energy Siphon
	[GetSpellInfo(17458)] = 17458, -- Fluorescent Green Mechanostrider
	[GetSpellInfo(27860)] = 27860, -- Engulfing Shadows
	[GetSpellInfo(28472)] = 28472, -- Bramblewood Helm
	[GetSpellInfo(6305)] = 6305, -- Flame Burst
	[GetSpellInfo(6469)] = 6469, -- Skeletal Miner Explode
	[GetSpellInfo(26588)] = 26588, -- Opening Greater Scarab Coffer
	[GetSpellInfo(27590)] = 27590, -- Obsidian Mail Tunic
	[GetSpellInfo(26636)] = 26636, -- Elune's Candle
	[GetSpellInfo(17432)] = 17432, -- Opening Stratholme Postbox
	[GetSpellInfo(7222)] = 7222, -- Iron Counterweight
	[GetSpellInfo(20529)] = 20529, -- Bind Chapter 1
	[GetSpellInfo(9594)] = 9594, -- Attach Medallion to Shaft
	[GetSpellInfo(580)] = 580, -- Large Timber Wolf
	[GetSpellInfo(11209)] = 11209, -- Summon Smithing Hammer
	[GetSpellInfo(23510)] = 23510, -- Stormpike Battle Charger
	[GetSpellInfo(25117)] = 25117, -- Minor Wizard Oil
	[GetSpellInfo(24851)] = 24851, -- Sandstalker Breastplate
	[GetSpellInfo(15128)] = 15128, -- Mark of Flames
	[GetSpellInfo(11479)] = 11479, -- Transmute: Iron to Gold
	[GetSpellInfo(8693)] = 8693, -- Mind-numbing Poison II
	[GetSpellInfo(25122)] = 25122, -- Brilliant Wizard Oil
	[GetSpellInfo(23252)] = 23252, -- Swift Gray Wolf
	[GetSpellInfo(23679)] = 23679, -- Elementals Deck
	[GetSpellInfo(18414)] = 18414, -- Brightcloth Robe
	[GetSpellInfo(17727)] = 17727, -- Create Spellstone (Greater)
	[GetSpellInfo(25853)] = 25853, -- Empty Festive Mug
	[GetSpellInfo(13143)] = 13143, -- Summon Razelikh
	[GetSpellInfo(25465)] = 25465, -- Firework
	[GetSpellInfo(24973)] = 24973, -- Clean Up Stink Bomb
	[GetSpellInfo(10698)] = 10698, -- Summon Emerald Whelpling
	[GetSpellInfo(15491)] = 15491, -- Collect Blessed Water
	[GetSpellInfo(8895)] = 8895, -- Goblin Rocket Boots
	[GetSpellInfo(17565)] = 17565, -- Transmute: Life to Earth
	[GetSpellInfo(12616)] = 12616, -- Parachute Cloak
	[GetSpellInfo(11356)] = 11356, -- Deadly Poison IV
	[GetSpellInfo(17460)] = 17460, -- Frost Ram
	[GetSpellInfo(19049)] = 19049, -- Wicked Leather Gauntlets
	[GetSpellInfo(24420)] = 24420, -- Zandalar Signet of Serenity
	[GetSpellInfo(1842)] = 1842, -- Disarm Trap
	[GetSpellInfo(17579)] = 17579, -- Greater Holy Protection Potion
	[GetSpellInfo(15261)] = 15261, -- Holy Fire
	[GetSpellInfo(7929)] = 7929, -- Heavy Silk Bandage
	[GetSpellInfo(2166)] = 2166, -- Toughened Leather Armor
	[GetSpellInfo(2549)] = 2549, -- Seasoned Wolf Kabob
	[GetSpellInfo(11418)] = 11418, -- Portal: Undercity
	[GetSpellInfo(25018)] = 25018, -- Summon Murki
	[GetSpellInfo(8517)] = 8517, -- Opening Strongbox
	[GetSpellInfo(13978)] = 13978, -- Summon Aquementas
	[GetSpellInfo(20904)] = 20904, -- Aimed Shot
	[GetSpellInfo(4983)] = 4983, -- Create Cleansing Totem
	[GetSpellInfo(6805)] = 6805, -- Dousing
	[GetSpellInfo(16741)] = 16741, -- Stronghold Gauntlets
	[GetSpellInfo(21188)] = 21188, -- Stun Bomb Attack
	[GetSpellInfo(2964)] = 2964, -- Bolt of Woolen Cloth
	[GetSpellInfo(18246)] = 18246, -- Mightfish Steak
	[GetSpellInfo(10487)] = 10487, -- Thick Armor Kit
	[GetSpellInfo(1112)] = 1112, -- Shadow Nova II
	[GetSpellInfo(12056)] = 12056, -- Red Mageweave Vest
	[GetSpellInfo(21736)] = 21736, -- Winterax Wisdom
	[GetSpellInfo(10556)] = 10556, -- Turtle Scale Leggings
	[GetSpellInfo(7126)] = 7126, -- Handstitched Leather Vest
	[GetSpellInfo(8339)] = 8339, -- EZ-Thro Dynamite
	[GetSpellInfo(898)] = 898, -- Create Fervor Potion
	[GetSpellInfo(2795)] = 2795, -- Beer Basted Boar Ribs
	[GetSpellInfo(8607)] = 8607, -- Smoked Bear Meat
	[GetSpellInfo(3611)] = 3611, -- Minion of Morganth
	[GetSpellInfo(18163)] = 18163, -- Strength of Arko'narin
	[GetSpellInfo(27891)] = 27891, -- Disease Buffet
	[GetSpellInfo(7978)] = 7978, -- Throw Dynamite
	[GetSpellInfo(10009)] = 10009, -- Runed Mithril Hammer
	[GetSpellInfo(14871)] = 14871, -- Shadow Bolt Misfire
	[GetSpellInfo(19029)] = 19029, -- Create Coagulated Rot
	[GetSpellInfo(5272)] = 5272, -- Dalaran Wizard Disguise
	[GetSpellInfo(17562)] = 17562, -- Transmute: Water to Air
	[GetSpellInfo(444)] = 444, -- Teleport Lighthouse
	[GetSpellInfo(7962)] = 7962, -- Break Big Stuff
	[GetSpellInfo(3513)] = 3513, -- Polished Steel Boots
	[GetSpellInfo(8283)] = 8283, -- Snufflenose Command
	[GetSpellInfo(23787)] = 23787, -- Powerful Anti-Venom
	[GetSpellInfo(7754)] = 7754, -- Loch Frenzy Delight
	[GetSpellInfo(6661)] = 6661, -- Barbaric Harness
	[GetSpellInfo(17577)] = 17577, -- Greater Arcane Protection Potion
	[GetSpellInfo(11067)] = 11067, -- Perm. Illusion Tyrion
	[GetSpellInfo(24214)] = 24214, -- Heart of Hakkar - Molthor chucks the heart
	[GetSpellInfo(10180)] = 10180, -- Frostbolt
	[GetSpellInfo(23123)] = 23123, -- Cairne's Hoofprint
	[GetSpellInfo(19073)] = 19073, -- Chimeric Leggings
	[GetSpellInfo(6405)] = 6405, -- Furbolg Form
	[GetSpellInfo(16031)] = 16031, -- Releasing Corrupt Ooze
	[GetSpellInfo(1452)] = 1452, -- Arcane Spirit IV
	[GetSpellInfo(23710)] = 23710, -- Molten Belt
	[GetSpellInfo(7817)] = 7817, -- Rough Bronze Boots
	[GetSpellInfo(12047)] = 12047, -- Colorful Kilt
	[GetSpellInfo(3292)] = 3292, -- Heavy Copper Broadsword
	[GetSpellInfo(22372)] = 22372, -- Demon Portal
	[GetSpellInfo(18992)] = 18992, -- Teal Kodo
	[GetSpellInfo(7655)] = 7655, -- Hex of Ravenclaw
	[GetSpellInfo(19484)] = 19484, -- Majordomo Teleport Visual
	[GetSpellInfo(10574)] = 10574, -- Wild Leather Cloak
	[GetSpellInfo(16725)] = 16725, -- Radiant Leggings
	[GetSpellInfo(8778)] = 8778, -- Boots of Darkness
	[GetSpellInfo(22711)] = 22711, -- Shadowskin Gloves
	[GetSpellInfo(7751)] = 7751, -- Brilliant Smallfish
	[GetSpellInfo(17728)] = 17728, -- Create Spellstone (Major)
	[GetSpellInfo(12459)] = 12459, -- Deadly Scope
	[GetSpellInfo(28219)] = 28219, -- Polar Tunic
	[GetSpellInfo(22757)] = 22757, -- Elemental Sharpening Stone
	[GetSpellInfo(9072)] = 9072, -- Red Whelp Gloves
	[GetSpellInfo(3847)] = 3847, -- Red Woolen Boots
	[GetSpellInfo(23152)] = 23152, -- Summon Xorothian Dreadsteed
	[GetSpellInfo(17578)] = 17578, -- Greater Shadow Protection Potion
	[GetSpellInfo(14804)] = 14804, -- Copy of Release Rageclaw
	[GetSpellInfo(19052)] = 19052, -- Wicked Leather Bracers
	[GetSpellInfo(23008)] = 23008, -- Powerful Seaforium Charge
	[GetSpellInfo(12059)] = 12059, -- White Bandit Mask
	[GetSpellInfo(17554)] = 17554, -- Elixir of Superior Defense
	[GetSpellInfo(28299)] = 28299, -- Ball Lightning
	[GetSpellInfo(21935)] = 21935, -- SnowMaster 9000
	[GetSpellInfo(24252)] = 24252, -- Swift Zulian Tiger
	[GetSpellInfo(885)] = 885, -- Invisibility
	[GetSpellInfo(17555)] = 17555, -- Elixir of the Sages
	[GetSpellInfo(6415)] = 6415, -- Fillet of Frenzy
	[GetSpellInfo(16622)] = 16622, -- Enhance Blunt Weapon V
	[GetSpellInfo(442)] = 442, -- Teleport Northshire Abbey
	[GetSpellInfo(23254)] = 23254, -- Redeeming the Soul
	[GetSpellInfo(12754)] = 12754, -- The Big One
	[GetSpellInfo(7023)] = 7023, -- Goblin Camera Connection
	[GetSpellInfo(4982)] = 4982, -- Pillar Delving
	[GetSpellInfo(10708)] = 10708, -- Summon Snowy Owl
	[GetSpellInfo(10934)] = 10934, -- Smite
	[GetSpellInfo(7081)] = 7081, -- Encage
	[GetSpellInfo(21885)] = 21885, -- Heal Vylestem Vine
	[GetSpellInfo(19825)] = 19825, -- Master Engineer's Goggles
	[GetSpellInfo(16533)] = 16533, -- Emberseer Start
	[GetSpellInfo(10562)] = 10562, -- Big Voodoo Cloak
	[GetSpellInfo(18243)] = 18243, -- Nightfin Soup
	[GetSpellInfo(25804)] = 25804, -- Rumsey Rum Black Label
	[GetSpellInfo(15627)] = 15627, -- Applying the Lure
	[GetSpellInfo(17566)] = 17566, -- Transmute: Earth to Life
	[GetSpellInfo(17464)] = 17464, -- Brown Skeletal Horse
	[GetSpellInfo(12537)] = 12537, -- Quest - Summon Treant
	[GetSpellInfo(9903)] = 9903, -- Enhance Blunt Weapon IV
	[GetSpellInfo(22662)] = 22662, -- Wither
	[GetSpellInfo(22876)] = 22876, -- Summon Netherwalker
	[GetSpellInfo(5099)] = 5099, -- Disruption
	[GetSpellInfo(10548)] = 10548, -- Nightscape Pants
	[GetSpellInfo(12060)] = 12060, -- Red Mageweave Pants
	[GetSpellInfo(9813)] = 9813, -- Barbaric Iron Breastplate
	[GetSpellInfo(7836)] = 7836, -- Blackmouth Oil
	[GetSpellInfo(12080)] = 12080, -- Pink Mageweave Shirt
	[GetSpellInfo(17559)] = 17559, -- Transmute: Air to Fire
	[GetSpellInfo(12048)] = 12048, -- Black Mageweave Vest
	[GetSpellInfo(15734)] = 15734, -- Summon
	[GetSpellInfo(25118)] = 25118, -- Minor Mana Oil
	[GetSpellInfo(10721)] = 10721, -- Summon Elven Wisp
	[GetSpellInfo(3658)] = 3658, -- Summon Theurgist
	[GetSpellInfo(3925)] = 3925, -- Rough Boomstick
	[GetSpellInfo(18456)] = 18456, -- Truefaith Vestments
	[GetSpellInfo(22027)] = 22027, -- Remove Insignia
	[GetSpellInfo(12615)] = 12615, -- Spellpower Goggles Xtreme
	[GetSpellInfo(9952)] = 9952, -- Ornate Mithril Shoulders
	[GetSpellInfo(6234)] = 6234, -- Incineration
	[GetSpellInfo(12622)] = 12622, -- Green Lens
	[GetSpellInfo(606)] = 606, -- Mind Rot
	[GetSpellInfo(24889)] = 24889, -- Create Signet of Beckoning: Fire
	[GetSpellInfo(10738)] = 10738, -- Unlocking
	[GetSpellInfo(8800)] = 8800, -- Dynamite
	[GetSpellInfo(28505)] = 28505, -- Summon Poley
	[GetSpellInfo(24888)] = 24888, -- Create Crest of Beckoning: Water
	[GetSpellInfo(10621)] = 10621, -- Wolfshead Helm
	[GetSpellInfo(18166)] = 18166, -- Summon Magram Ravager
	[GetSpellInfo(18629)] = 18629, -- Runecloth Bandage
	[GetSpellInfo(30152)] = 30152, -- Summon White Tiger Cub
	[GetSpellInfo(10098)] = 10098, -- Smelt Truesilver
	[GetSpellInfo(1366)] = 1366, -- Summon Imp
	[GetSpellInfo(8153)] = 8153, -- Owl Form
	[GetSpellInfo(8368)] = 8368, -- Ironforge Gauntlets
	[GetSpellInfo(15746)] = 15746, -- Disturb Rookery Egg
	[GetSpellInfo(5414)] = 5414, -- Balance of Nature
	[GetSpellInfo(3759)] = 3759, -- Embossed Leather Pants
	[GetSpellInfo(28800)] = 28800, -- Word of Thawing
	[GetSpellInfo(2331)] = 2331, -- Minor Mana Potion
	[GetSpellInfo(23161)] = 23161, -- Summon Dreadsteed
	[GetSpellInfo(23705)] = 23705, -- Dawn Treaders
	[GetSpellInfo(9997)] = 9997, -- Wicked Mithril Blade
	[GetSpellInfo(6651)] = 6651, -- Instant Toxin
	[GetSpellInfo(2005)] = 2005, -- Bombard
	[GetSpellInfo(6413)] = 6413, -- Scorpid Surprise
	[GetSpellInfo(10854)] = 10854, -- Flames of Chaos
	[GetSpellInfo(16650)] = 16650, -- Wildthorn Mail
	[GetSpellInfo(12076)] = 12076, -- Shadoweave Shoulders
	[GetSpellInfo(11820)] = 11820, -- Electrified Net
	[GetSpellInfo(10733)] = 10733, -- Flame Spray
	[GetSpellInfo(11568)] = 11568, -- Uldaman Sub-Boss Agro
	[GetSpellInfo(20364)] = 20364, -- Bury Samuel's Remains
	[GetSpellInfo(2167)] = 2167, -- Dark Leather Boots
	[GetSpellInfo(23232)] = 23232, -- Binding Volume II
	[GetSpellInfo(16601)] = 16601, -- Fist of Shahram
	[GetSpellInfo(9970)] = 9970, -- Heavy Mithril Helm
	[GetSpellInfo(3113)] = 3113, -- Enhance Blunt Weapon II
	[GetSpellInfo(24167)] = 24167, -- Prophetic Aura
	[GetSpellInfo(5408)] = 5408, -- Quest - Sergra Darkthorn Spell
	[GetSpellInfo(14807)] = 14807, -- Greater Magic Wand
	[GetSpellInfo(7256)] = 7256, -- Shadow Protection Potion
	[GetSpellInfo(20756)] = 20756, -- Create Soulstone (Greater)
	[GetSpellInfo(13819)] = 13819, -- Summon Warhorse
	[GetSpellInfo(24801)] = 24801, -- Smoked Desert Dumplings
	[GetSpellInfo(23632)] = 23632, -- Girdle of the Dawn
	[GetSpellInfo(12618)] = 12618, -- Rose Colored Goggles
	[GetSpellInfo(23066)] = 23066, -- Red Firework
	[GetSpellInfo(12084)] = 12084, -- Red Mageweave Headband
	[GetSpellInfo(22598)] = 22598, -- Arcane Mantle of the Dawn
	[GetSpellInfo(3766)] = 3766, -- Dark Leather Belt
	[GetSpellInfo(12052)] = 12052, -- Shadoweave Pants
	[GetSpellInfo(23703)] = 23703, -- Might of the Timbermaw
	[GetSpellInfo(17708)] = 17708, -- Summon Diablo
	[GetSpellInfo(11399)] = 11399, -- Mind-numbing Poison III
	[GetSpellInfo(3443)] = 3443, -- Enchanted Quickness
	[GetSpellInfo(15794)] = 15794, -- Summon Blackhand Dreadweaver
	[GetSpellInfo(26419)] = 26419, -- Acid Spray
	[GetSpellInfo(28612)] = 28612, -- Conjure Food
	[GetSpellInfo(18454)] = 18454, -- Gloves of Spell Mastery
	[GetSpellInfo(20716)] = 20716, -- Sand Breath
	[GetSpellInfo(4209)] = 4209, -- Healing Tongue
	[GetSpellInfo(19077)] = 19077, -- Blue Dragonscale Breastplate
	[GetSpellInfo(9959)] = 9959, -- Heavy Mithril Breastplate
	[GetSpellInfo(8768)] = 8768, -- Iron Buckle
	[GetSpellInfo(17048)] = 17048, -- Soul Claim
	[GetSpellInfo(6741)] = 6741, -- Identify Brood
	[GetSpellInfo(3670)] = 3670, -- Unlock Maury's Foot
	[GetSpellInfo(8395)] = 8395, -- Emerald Raptor
	[GetSpellInfo(15255)] = 15255, -- Mechanical Repair Kit
	[GetSpellInfo(9983)] = 9983, -- Copper Claymore
	[GetSpellInfo(3644)] = 3644, -- Speak with Heads
	[GetSpellInfo(12085)] = 12085, -- Tuxedo Shirt
	[GetSpellInfo(27586)] = 27586, -- Jagged Obsidian Shield
	[GetSpellInfo(3143)] = 3143, -- Glacial Roar
	[GetSpellInfo(2841)] = 2841, -- Creeping Torment
	[GetSpellInfo(3857)] = 3857, -- Enchanter's Cowl
	[GetSpellInfo(23129)] = 23129, -- World Enlarger
	[GetSpellInfo(9461)] = 9461, -- Summon Swamp Ooze
	[GetSpellInfo(3537)] = 3537, -- Minions of Malathrom
	[GetSpellInfo(11473)] = 11473, -- Ghost Dye
	[GetSpellInfo(8089)] = 8089, -- Aquadynamic Fish Attractor
	[GetSpellInfo(19792)] = 19792, -- Thorium Rifle
	[GetSpellInfo(3377)] = 3377, -- Gooey Spider Cake
	[GetSpellInfo(27738)] = 27738, -- Right Piece of Lord Valthalak's Amulet
	[GetSpellInfo(4093)] = 4093, -- Reconstruction
	[GetSpellInfo(22331)] = 22331, -- Rugged Leather
	[GetSpellInfo(3448)] = 3448, -- Lesser Invisibility Potion
	[GetSpellInfo(24164)] = 24164, -- Presence of Sight
	[GetSpellInfo(12609)] = 12609, -- Catseye Elixir
	[GetSpellInfo(691)] = 691, -- Summon Felhunter
	[GetSpellInfo(19588)] = 19588, -- Place Ghost Magnet
	[GetSpellInfo(25992)] = 25992, -- Brood of Nozdormu Factoin +1000
	[GetSpellInfo(18240)] = 18240, -- Grilled Squid
	[GetSpellInfo(10623)] = 10623, -- Chain Heal
	[GetSpellInfo(6470)] = 6470, -- Tiny Bronze Key
	[GetSpellInfo(15999)] = 15999, -- Summon Worg Pup
	[GetSpellInfo(8016)] = 8016, -- Spirit Decay
	[GetSpellInfo(26102)] = 26102, -- Sand Blast
	[GetSpellInfo(2394)] = 2394, -- Blue Linen Shirt
	[GetSpellInfo(3934)] = 3934, -- Flying Tiger Goggles
	[GetSpellInfo(7753)] = 7753, -- Longjaw Mud Snapper
	[GetSpellInfo(13714)] = 13714, -- Create Samophlange Manual
	[GetSpellInfo(16730)] = 16730, -- Imperial Plate Leggings
	[GetSpellInfo(6618)] = 6618, -- Great Rage Potion
	[GetSpellInfo(24149)] = 24149, -- Presence of Might
	[GetSpellInfo(6925)] = 6925, -- Gift of the Xavian
	[GetSpellInfo(30156)] = 30156, -- Summon Hippogryph Hatchling
	[GetSpellInfo(18448)] = 18448, -- Mooncloth Shoulders
	[GetSpellInfo(27585)] = 27585, -- Heavy Obsidian Belt
	[GetSpellInfo(28099)] = 28099, -- Shock
	[GetSpellInfo(17456)] = 17456, -- Red & Blue Mechanostrider
	[GetSpellInfo(24901)] = 24901, -- Runed Stygian Leggings
	[GetSpellInfo(23078)] = 23078, -- Goblin Jumper Cables XL
	[GetSpellInfo(3775)] = 3775, -- Guardian Belt
	[GetSpellInfo(23678)] = 23678, -- Warlord Deck
	[GetSpellInfo(8256)] = 8256, -- Lethal Toxin
	[GetSpellInfo(126)] = 126, -- Eye of Kilrogg
	[GetSpellInfo(27739)] = 27739, -- Top Piece of Lord Valthalak's Amulet
	[GetSpellInfo(10630)] = 10630, -- Gauntlets of the Sea
	[GetSpellInfo(19085)] = 19085, -- Black Dragonscale Breastplate
	[GetSpellInfo(6461)] = 6461, -- Pick Lock
	[GetSpellInfo(3777)] = 3777, -- Guardian Leather Bracers
	[GetSpellInfo(11726)] = 11726, -- Enslave Demon
	[GetSpellInfo(7629)] = 7629, -- Red Linen Vest
	[GetSpellInfo(2951)] = 2951, -- Hellfire III
	[GetSpellInfo(24726)] = 24726, -- Deputize Agent of Nozdormu
	[GetSpellInfo(20814)] = 20814, -- Collect Dire Water
	[GetSpellInfo(18415)] = 18415, -- Brightcloth Gloves
	[GetSpellInfo(9901)] = 9901, -- Soothe Animal
	[GetSpellInfo(3768)] = 3768, -- Hillman's Shoulders
	[GetSpellInfo(10678)] = 10678, -- Summon Silver Tabby
	[GetSpellInfo(2332)] = 2332, -- Minor Rejuvenation Potion
	[GetSpellInfo(7481)] = 7481, -- Howling Rage
	[GetSpellInfo(472)] = 472, -- Pinto Horse
	[GetSpellInfo(3963)] = 3963, -- Compact Harvest Reaper Kit
	[GetSpellInfo(3860)] = 3860, -- Boots of the Enchanter
	[GetSpellInfo(15067)] = 15067, -- Summon Sprite Darter Hatchling
	[GetSpellInfo(21957)] = 21957, -- Create Amulet of Union
	[GetSpellInfo(8087)] = 8087, -- Shiny Bauble
	[GetSpellInfo(3453)] = 3453, -- Elixir of Detect Lesser Invisibility
	[GetSpellInfo(7919)] = 7919, -- Shoot Crossbow
	[GetSpellInfo(19053)] = 19053, -- Chimeric Gloves
	[GetSpellInfo(22979)] = 22979, -- Shadow Flame
	[GetSpellInfo(3323)] = 3323, -- Runed Copper Gauntlets
	[GetSpellInfo(23222)] = 23222, -- Swift Yellow Mechanostrider
	[GetSpellInfo(25180)] = 25180, -- Nature Weakness
	[GetSpellInfo(9853)] = 9853, -- Entangling Roots
	[GetSpellInfo(12596)] = 12596, -- Hi-Impact Mithril Slugs
	[GetSpellInfo(26587)] = 26587, -- Opening Scarab Coffer
	[GetSpellInfo(28270)] = 28270, -- Polymorph: Cow
	[GetSpellInfo(12070)] = 12070, -- Dreamweave Vest
	[GetSpellInfo(16028)] = 16028, -- Freeze Rookery Egg - Prototype
	[GetSpellInfo(8367)] = 8367, -- Ironforge Breastplate
	[GetSpellInfo(9577)] = 9577, -- Uldaman Key Staff
	[GetSpellInfo(7827)] = 7827, -- Rainbow Fin Albacore
	[GetSpellInfo(9945)] = 9945, -- Ornate Mithril Pants
	[GetSpellInfo(12258)] = 12258, -- Summon Shadowcaster
	[GetSpellInfo(818)] = 818, -- Basic Campfire
	[GetSpellInfo(17180)] = 17180, -- Enchanted Thorium
	[GetSpellInfo(3146)] = 3146, -- Daunting Growl
	[GetSpellInfo(2838)] = 2838, -- Creeping Pain
	[GetSpellInfo(18422)] = 18422, -- Cloak of Fire
	[GetSpellInfo(12617)] = 12617, -- Deepdive Helmet
	[GetSpellInfo(16378)] = 16378, -- Temperature Reading
	[GetSpellInfo(5403)] = 5403, -- Crash of Waves
	[GetSpellInfo(7156)] = 7156, -- Guardian Gloves
	[GetSpellInfo(3359)] = 3359, -- Drink Potion
	[GetSpellInfo(759)] = 759, -- Conjure Mana Agate
	[GetSpellInfo(8686)] = 8686, -- Instant Poison II
	[GetSpellInfo(7277)] = 7277, -- Harvest Swarm
	[GetSpellInfo(20855)] = 20855, -- Black Dragonscale Boots
	[GetSpellInfo(6510)] = 6510, -- Blinding Powder
	[GetSpellInfo(8789)] = 8789, -- Crimson Silk Cloak
	[GetSpellInfo(3361)] = 3361, -- Dummy NPC Summon
	[GetSpellInfo(12066)] = 12066, -- Red Mageweave Gloves
	[GetSpellInfo(20773)] = 20773, -- Redemption
	[GetSpellInfo(12243)] = 12243, -- Summon Mechanical Chicken
	[GetSpellInfo(15958)] = 15958, -- Collect Rookery Egg
	[GetSpellInfo(24966)] = 24966, -- Honor Points +2388
	[GetSpellInfo(16247)] = 16247, -- Curse of Thorns
	[GetSpellInfo(18887)] = 18887, -- Create Nimboya's Laden Pike
	[GetSpellInfo(7818)] = 7818, -- Silver Rod
	[GetSpellInfo(16653)] = 16653, -- Thorium Helm
	[GetSpellInfo(28161)] = 28161, -- Savage Guard
	[GetSpellInfo(22458)] = 22458, -- Healing Circle
	[GetSpellInfo(1451)] = 1451, -- Arcane Spirit III
	[GetSpellInfo(29475)] = 29475, -- Resilience of the Scourge
	[GetSpellInfo(17133)] = 17133, -- Create Pamela's Doll
	[GetSpellInfo(15120)] = 15120, -- Cenarion Beacon
	[GetSpellInfo(17638)] = 17638, -- Flask of Chromatic Resistance
	[GetSpellInfo(15792)] = 15792, -- Summon Blackhand Veteran
	[GetSpellInfo(9097)] = 9097, -- Summon Demon of the Orb
	[GetSpellInfo(3477)] = 3477, -- Spirit Steal
	[GetSpellInfo(19831)] = 19831, -- Arcane Bomb
	[GetSpellInfo(4320)] = 4320, -- Trelane's Freezing Touch
	[GetSpellInfo(3336)] = 3336, -- Green Iron Gauntlets
	[GetSpellInfo(12938)] = 12938, -- Fel Curse
	[GetSpellInfo(11643)] = 11643, -- Golden Scale Gauntlets
	[GetSpellInfo(3114)] = 3114, -- Enhance Blunt Weapon III
	[GetSpellInfo(8980)] = 8980, -- Skeletal Horse
	[GetSpellInfo(26072)] = 26072, -- Dust Cloud
	[GetSpellInfo(4629)] = 4629, -- Rain of Fire
	[GetSpellInfo(16640)] = 16640, -- Dense Weightstone
	[GetSpellInfo(2334)] = 2334, -- Elixir of Minor Fortitude
	[GetSpellInfo(22797)] = 22797, -- Force Reactive Disk
	[GetSpellInfo(2645)] = 2645, -- Ghost Wolf
	[GetSpellInfo(10053)] = 10053, -- Conjure Mana Citrine
	[GetSpellInfo(7359)] = 7359, -- Bright Campfire
	[GetSpellInfo(25247)] = 25247, -- Longsight
	[GetSpellInfo(3955)] = 3955, -- Explosive Sheep
	[GetSpellInfo(8688)] = 8688, -- Instant Poison III
	[GetSpellInfo(16667)] = 16667, -- Demon Forged Breastplate
	[GetSpellInfo(10011)] = 10011, -- Blight
	[GetSpellInfo(3174)] = 3174, -- Elixir of Poison Resistance
	[GetSpellInfo(21730)] = 21730, -- Planting Vipore's Beacon
	[GetSpellInfo(19106)] = 19106, -- Onyxia Scale Breastplate
	[GetSpellInfo(5274)] = 5274, -- Syndicate Disguise
	[GetSpellInfo(3852)] = 3852, -- Gloves of Meditation
	[GetSpellInfo(6490)] = 6490, -- Sarilus's Elementals
	[GetSpellInfo(11447)] = 11447, -- Elixir of Waterwalking
	[GetSpellInfo(11338)] = 11338, -- Instant Poison IV
	[GetSpellInfo(24895)] = 24895, -- Create Scepter of Beckoning: Fire
	[GetSpellInfo(578)] = 578, -- Black Wolf
	[GetSpellInfo(11434)] = 11434, -- Gong Zul'Farrak Gong
	[GetSpellInfo(22719)] = 22719, -- Black Battlestrider
	[GetSpellInfo(21144)] = 21144, -- Egg Nog
	[GetSpellInfo(10552)] = 10552, -- Turtle Scale Helm
	[GetSpellInfo(18502)] = 18502, -- Curse of Hakkar
	[GetSpellInfo(17536)] = 17536, -- Awaken Kerlonian
	[GetSpellInfo(10787)] = 10787, -- Panther
	[GetSpellInfo(6728)] = 6728, -- Enveloping Winds
	[GetSpellInfo(21729)] = 21729, -- Planting Slidore's Beacon
	[GetSpellInfo(22928)] = 22928, -- Shifting Cloak
	[GetSpellInfo(3956)] = 3956, -- Green Tinted Goggles
	[GetSpellInfo(19082)] = 19082, -- Runic Leather Headband
	[GetSpellInfo(16396)] = 16396, -- Flame Breath
	[GetSpellInfo(23664)] = 23664, -- Argent Boots
	[GetSpellInfo(14932)] = 14932, -- Thick Leather Ammo Pouch
	[GetSpellInfo(17634)] = 17634, -- Flask of Petrification
	[GetSpellInfo(7755)] = 7755, -- Bristle Whisker Catfish
	[GetSpellInfo(11729)] = 11729, -- Create Healthstone (Greater)
	[GetSpellInfo(6297)] = 6297, -- Fiery Blaze
	[GetSpellInfo(6690)] = 6690, -- Lesser Wizard's Robe
	[GetSpellInfo(8386)] = 8386, -- Attacking
	[GetSpellInfo(2406)] = 2406, -- Gray Woolen Shirt
	[GetSpellInfo(2395)] = 2395, -- Barbaric Linen Vest
	[GetSpellInfo(22840)] = 22840, -- Arcanum of Rapidity
	[GetSpellInfo(23442)] = 23442, -- Everlook Transporter
	[GetSpellInfo(8376)] = 8376, -- Earthgrab Totem
	[GetSpellInfo(5967)] = 5967, -- Pickpocket (PT)
	[GetSpellInfo(23054)] = 23054, -- Igniting Kroshius
	[GetSpellInfo(6619)] = 6619, -- Cowardly Flight Potion
	[GetSpellInfo(3397)] = 3397, -- Big Bear Steak
	[GetSpellInfo(17293)] = 17293, -- Burning Winds
	[GetSpellInfo(28210)] = 28210, -- Gaea's Embrace
	[GetSpellInfo(27659)] = 27659, -- Enchanted Runecloth Bag
	[GetSpellInfo(19078)] = 19078, -- Living Leggings
	[GetSpellInfo(7162)] = 7162, -- First Aid
	[GetSpellInfo(19796)] = 19796, -- Dark Iron Rifle
	[GetSpellInfo(17575)] = 17575, -- Greater Frost Protection Potion
	[GetSpellInfo(19060)] = 19060, -- Green Dragonscale Leggings
	[GetSpellInfo(19797)] = 19797, -- Conjure Torch of Retribution
	[GetSpellInfo(24195)] = 24195, -- Grom's Tribute
	[GetSpellInfo(7739)] = 7739, -- Inferno Shell
	[GetSpellInfo(12735)] = 12735, -- Fill the Egg of Hakkar
	[GetSpellInfo(12280)] = 12280, -- Acid of Hakkar
	[GetSpellInfo(24850)] = 24850, -- Sandstalker Gauntlets
	[GetSpellInfo(18439)] = 18439, -- Brightcloth Pants
	[GetSpellInfo(6777)] = 6777, -- Gray Ram
	[GetSpellInfo(6704)] = 6704, -- Thick Murloc Armor
	[GetSpellInfo(9879)] = 9879, -- Self Destruct
	[GetSpellInfo(9082)] = 9082, -- Create Containment Coffer
	[GetSpellInfo(3755)] = 3755, -- Linen Bag
	[GetSpellInfo(23399)] = 23399, -- Barbaric Bracers
	[GetSpellInfo(4942)] = 4942, -- Lesser Stoneshield Potion
	[GetSpellInfo(26418)] = 26418, -- Small Red Rocket
	[GetSpellInfo(24245)] = 24245, -- String Together Heads
	[GetSpellInfo(10688)] = 10688, -- Summon Cockroach
	[GetSpellInfo(4539)] = 4539, -- Strength of the Ages
	[GetSpellInfo(4974)] = 4974, -- Wither Touch
	[GetSpellInfo(12253)] = 12253, -- Dowse Eternal Flame
	[GetSpellInfo(3931)] = 3931, -- Coarse Dynamite
	[GetSpellInfo(6950)] = 6950, -- Faerie Fire
	[GetSpellInfo(11836)] = 11836, -- Freeze Solid
	[GetSpellInfo(16969)] = 16969, -- Ornate Thorium Handaxe
	[GetSpellInfo(4131)] = 4131, -- Banish Cresting Exile
	[GetSpellInfo(19669)] = 19669, -- Arcanite Skeleton Key
	[GetSpellInfo(9062)] = 9062, -- Small Leather Ammo Pouch
	[GetSpellInfo(4064)] = 4064, -- Rough Copper Bomb
	[GetSpellInfo(22722)] = 22722, -- Red Skeletal Warhorse
	[GetSpellInfo(14293)] = 14293, -- Lesser Magic Wand
	[GetSpellInfo(12065)] = 12065, -- Mageweave Bag
	[GetSpellInfo(20604)] = 20604, -- Dominate Mind
	[GetSpellInfo(18409)] = 18409, -- Runecloth Cloak
	[GetSpellInfo(22866)] = 22866, -- Belt of the Archmage
	[GetSpellInfo(24125)] = 24125, -- Blood Tiger Shoulders
	[GetSpellInfo(6202)] = 6202, -- Create Healthstone (Lesser)
	[GetSpellInfo(16497)] = 16497, -- Stun Bomb
	[GetSpellInfo(15783)] = 15783, -- Blizzard
	[GetSpellInfo(20762)] = 20762, -- Soulstone Resurrection
	[GetSpellInfo(8758)] = 8758, -- Azure Silk Pants
	[GetSpellInfo(22596)] = 22596, -- Shadow Mantle of the Dawn
	[GetSpellInfo(690)] = 690, -- Firebolt II
	[GetSpellInfo(19107)] = 19107, -- Black Dragonscale Leggings
	[GetSpellInfo(17953)] = 17953, -- Create Firestone (Major)
	[GetSpellInfo(18445)] = 18445, -- Mooncloth Bag
	[GetSpellInfo(3278)] = 3278, -- Heavy Wool Bandage
	[GetSpellInfo(10788)] = 10788, -- Leopard
	[GetSpellInfo(6296)] = 6296, -- Enchant: Fiery Blaze
	[GetSpellInfo(3501)] = 3501, -- Green Iron Bracers
	[GetSpellInfo(579)] = 579, -- Red Wolf
	[GetSpellInfo(447)] = 447, -- Teleport Treant
	[GetSpellInfo(12595)] = 12595, -- Mithril Blunderbuss
	[GetSpellInfo(2544)] = 2544, -- Crab Cake
	[GetSpellInfo(10682)] = 10682, -- Summon Hyacinth Macaw
	[GetSpellInfo(22563)] = 22563, -- Recall
	[GetSpellInfo(19088)] = 19088, -- Heavy Scorpid Helm
	[GetSpellInfo(3502)] = 3502, -- Green Iron Helm
	[GetSpellInfo(17162)] = 17162, -- Summon Water Elemental
	[GetSpellInfo(16587)] = 16587, -- Dark Whispers
	[GetSpellInfo(23223)] = 23223, -- Swift White Mechanostrider
	[GetSpellInfo(11082)] = 11082, -- Megavolt
	[GetSpellInfo(17571)] = 17571, -- Elixir of the Mongoose
	[GetSpellInfo(18960)] = 18960, -- Teleport: Moonglade
	[GetSpellInfo(23429)] = 23429, -- Summon Loggerhead Snapjaw
	[GetSpellInfo(7398)] = 7398, -- Birth
	[GetSpellInfo(19833)] = 19833, -- Flawless Arcanite Rifle
	[GetSpellInfo(14809)] = 14809, -- Lesser Mystic Wand
	[GetSpellInfo(26086)] = 26086, -- Felcloth Bag
	[GetSpellInfo(19083)] = 19083, -- Wicked Leather Pants
	[GetSpellInfo(2742)] = 2742, -- Bronze Shortsword
	[GetSpellInfo(28311)] = 28311, -- Slime Bolt
	[GetSpellInfo(21027)] = 21027, -- Spark
	[GetSpellInfo(8791)] = 8791, -- Crimson Silk Vest
	[GetSpellInfo(5140)] = 5140, -- Detonate
	[GetSpellInfo(20649)] = 20649, -- Heavy Leather
	[GetSpellInfo(8856)] = 8856, -- Bending Shinbone
	[GetSpellInfo(2541)] = 2541, -- Coyote Steak
	[GetSpellInfo(6717)] = 6717, -- Place Lion Carcass
	[GetSpellInfo(3295)] = 3295, -- Deadly Bronze Poniard
	[GetSpellInfo(7132)] = 7132, -- Summon Lupine Delusions
	[GetSpellInfo(15853)] = 15853, -- Lean Wolf Steak
	[GetSpellInfo(9149)] = 9149, -- Heavy Earthen Gloves
	[GetSpellInfo(10518)] = 10518, -- Turtle Scale Bracers
	[GetSpellInfo(16796)] = 16796, -- Summon Shy-Rotam
	[GetSpellInfo(9273)] = 9273, -- Goblin Jumper Cables
	[GetSpellInfo(12083)] = 12083, -- Stormcloth Headband
	[GetSpellInfo(24849)] = 24849, -- Sandstalker Bracers
	[GetSpellInfo(15779)] = 15779, -- White Mechanostrider
	[GetSpellInfo(23227)] = 23227, -- Swift Palomino
	[GetSpellInfo(4960)] = 4960, -- Create Fervor Potion (New)
	[GetSpellInfo(15750)] = 15750, -- Rookery Whelp Spawn-in Spell
	[GetSpellInfo(3503)] = 3503, -- Golden Scale Coif
	[GetSpellInfo(3013)] = 3013, -- Volley II
	[GetSpellInfo(7078)] = 7078, -- Simple Teleport Group
	[GetSpellInfo(7896)] = 7896, -- Exploding Shot
	[GetSpellInfo(19667)] = 19667, -- Golden Skeleton Key
	[GetSpellInfo(3866)] = 3866, -- Stylish Red Shirt
	[GetSpellInfo(24902)] = 24902, -- Runed Stygian Belt
	[GetSpellInfo(10700)] = 10700, -- Summon Faeling
	[GetSpellInfo(7383)] = 7383, -- Water Bubble
	[GetSpellInfo(25262)] = 25262, -- Abomination Spit
	[GetSpellInfo(26407)] = 26407, -- Festive Red Pant Suit
	[GetSpellInfo(30174)] = 30174, -- Riding Turtle
	[GetSpellInfo(16598)] = 16598, -- Will of Shahram
	[GetSpellInfo(6422)] = 6422, -- Ashcrombe's Teleport
	[GetSpellInfo(6501)] = 6501, -- Clam Chowder
	[GetSpellInfo(17564)] = 17564, -- Transmute: Water to Undeath
	[GetSpellInfo(16993)] = 16993, -- Masterwork Stormhammer
	[GetSpellInfo(9147)] = 9147, -- Earthen Leather Shoulders
	[GetSpellInfo(2158)] = 2158, -- Fine Leather Boots
	[GetSpellInfo(9616)] = 9616, -- Wild Regeneration
	[GetSpellInfo(4520)] = 4520, -- Wide Sweep
	[GetSpellInfo(27290)] = 27290, -- Increase Reputation
	[GetSpellInfo(9966)] = 9966, -- Mithril Scale Shoulders
	[GetSpellInfo(11460)] = 11460, -- Elixir of Detect Undead
	[GetSpellInfo(1698)] = 1698, -- Shockwave
	[GetSpellInfo(16081)] = 16081, -- Arctic Wolf
	[GetSpellInfo(13484)] = 13484, -- Plant Gor'tesh Head
	[GetSpellInfo(16059)] = 16059, -- Tawny Sabercat
	[GetSpellInfo(15664)] = 15664, -- Venom Spit
	[GetSpellInfo(16594)] = 16594, -- Crypt Scarabs
	[GetSpellInfo(10511)] = 10511, -- Turtle Scale Breastplate
	[GetSpellInfo(10258)] = 10258, -- Awaken Vault Warder
	[GetSpellInfo(581)] = 581, -- Winter Wolf
	[GetSpellInfo(16745)] = 16745, -- Enchanted Thorium Breastplate
	[GetSpellInfo(25688)] = 25688, -- Narain!
	[GetSpellInfo(7960)] = 7960, -- Scry on Azrethoc
	[GetSpellInfo(3818)] = 3818, -- Cured Heavy Hide
	[GetSpellInfo(7101)] = 7101, -- Flame Blast
	[GetSpellInfo(22597)] = 22597, -- Nature Mantle of the Dawn
	[GetSpellInfo(10799)] = 10799, -- Violet Raptor
	[GetSpellInfo(27724)] = 27724, -- Cenarion Herb Bag
	[GetSpellInfo(7430)] = 7430, -- Arclight Spanner
	[GetSpellInfo(10676)] = 10676, -- Summon Orange Tabby
	[GetSpellInfo(22999)] = 22999, -- Defibrillate
	[GetSpellInfo(3868)] = 3868, -- Phoenix Gloves
	[GetSpellInfo(21048)] = 21048, -- Curse of the Tribes
	[GetSpellInfo(16599)] = 16599, -- Blessing of Shahram
	[GetSpellInfo(1050)] = 1050, -- Sacrifice
	[GetSpellInfo(10520)] = 10520, -- Big Voodoo Robe
	[GetSpellInfo(8137)] = 8137, -- Silithid Pox
	[GetSpellInfo(16051)] = 16051, -- Barrier of Light
	[GetSpellInfo(23313)] = 23313, -- Corrosive Acid
	[GetSpellInfo(16570)] = 16570, -- Charged Arcane Bolt
	[GetSpellInfo(23124)] = 23124, -- Human Orphan Whistle
	[GetSpellInfo(25146)] = 25146, -- Transmute: Elemental Fire
	[GetSpellInfo(12075)] = 12075, -- Lavender Mageweave Shirt
	[GetSpellInfo(18437)] = 18437, -- Felcloth Boots
	[GetSpellInfo(22779)] = 22779, -- Biznicks 247x128 Accurascope
	[GetSpellInfo(10650)] = 10650, -- Dragonscale Breastplate
	[GetSpellInfo(19564)] = 19564, -- Draw Water Sample
	[GetSpellInfo(15591)] = 15591, -- Revive Ringo
	[GetSpellInfo(12684)] = 12684, -- Kadrak's Flag
	[GetSpellInfo(18416)] = 18416, -- Ghostweave Vest
	[GetSpellInfo(1450)] = 1450, -- Arcane Spirit II
	[GetSpellInfo(12904)] = 12904, -- Gnomish Ham Radio
	[GetSpellInfo(17117)] = 17117, -- Magatha Incendia Powder
	[GetSpellInfo(9811)] = 9811, -- Barbaric Iron Shoulders
	[GetSpellInfo(13258)] = 13258, -- Summon Goblin Bomb
	[GetSpellInfo(23041)] = 23041, -- Call Anathema
	[GetSpellInfo(17501)] = 17501, -- Cannon Fire
	[GetSpellInfo(27722)] = 27722, -- Sweet Surprise
	[GetSpellInfo(26422)] = 26422, -- Large Red Rocket
	[GetSpellInfo(23228)] = 23228, -- Swift White Steed
	[GetSpellInfo(17459)] = 17459, -- Icy Blue Mechanostrider
	[GetSpellInfo(24161)] = 24161, -- Death's Embrace
	[GetSpellInfo(19090)] = 19090, -- Stormshroud Shoulders
	[GetSpellInfo(28244)] = 28244, -- Icebane Bracers
	[GetSpellInfo(10695)] = 10695, -- Summon Dark Whelpling
	[GetSpellInfo(25704)] = 25704, -- Smoked Sagefish
	[GetSpellInfo(12072)] = 12072, -- Black Mageweave Headband
	[GetSpellInfo(24092)] = 24092, -- Bloodvine Leggings
	[GetSpellInfo(10677)] = 10677, -- Summon Siamese
	[GetSpellInfo(28133)] = 28133, -- Cure Disease
	[GetSpellInfo(19799)] = 19799, -- Dark Iron Bomb
	[GetSpellInfo(23248)] = 23248, -- Great Gray Kodo
	[GetSpellInfo(9552)] = 9552, -- Searing Flames
	[GetSpellInfo(12055)] = 12055, -- Shadoweave Robe
	[GetSpellInfo(7054)] = 7054, -- Forsaken Skills
	[GetSpellInfo(23430)] = 23430, -- Summon Olive Snapjaw
	[GetSpellInfo(11757)] = 11757, -- Digging for Cobalt
	[GetSpellInfo(8782)] = 8782, -- Truefaith Gloves
	[GetSpellInfo(16057)] = 16057, -- Place Unforged Seal
	[GetSpellInfo(2330)] = 2330, -- Minor Healing Potion
	[GetSpellInfo(11456)] = 11456, -- Goblin Rocket Fuel
	[GetSpellInfo(556)] = 556, -- Astral Recall
	[GetSpellInfo(19793)] = 19793, -- Lifelike Mechanical Toad
	[GetSpellInfo(16991)] = 16991, -- Annihilator
	[GetSpellInfo(2817)] = 2817, -- Teach Bark of Doom
	[GetSpellInfo(9888)] = 9888, -- Healing Touch
	[GetSpellInfo(12590)] = 12590, -- Gyromatic Micro-Adjustor
	[GetSpellInfo(10876)] = 10876, -- Mana Burn
	[GetSpellInfo(16071)] = 16071, -- Curse of the Firebrand
	[GetSpellInfo(10947)] = 10947, -- Mind Blast
	[GetSpellInfo(11365)] = 11365, -- Bly's Band's Escape
	[GetSpellInfo(28785)] = 28785, -- Locust Swarm
	[GetSpellInfo(21912)] = 21912, -- Dummy Nuke
	[GetSpellInfo(23663)] = 23663, -- Mantle of the Timbermaw
	[GetSpellInfo(16801)] = 16801, -- Warosh's Transform
	[GetSpellInfo(9612)] = 9612, -- Ink Spray
	[GetSpellInfo(23233)] = 23233, -- Binding Volume III
	[GetSpellInfo(2663)] = 2663, -- Copper Bracers
	[GetSpellInfo(3507)] = 3507, -- Golden Scale Leggings
	[GetSpellInfo(7901)] = 7901, -- Decayed Agility
	[GetSpellInfo(16645)] = 16645, -- Radiant Belt
	[GetSpellInfo(8784)] = 8784, -- Green Silk Armor
	[GetSpellInfo(28089)] = 28089, -- Polarity Shift
	[GetSpellInfo(24914)] = 24914, -- Darkrune Breastplate
	[GetSpellInfo(19104)] = 19104, -- Frostsaber Tunic
	[GetSpellInfo(12050)] = 12050, -- Black Mageweave Robe
	[GetSpellInfo(28995)] = 28995, -- Stoneskin
	[GetSpellInfo(18149)] = 18149, -- Volatile Infection
	[GetSpellInfo(20853)] = 20853, -- Corehound Boots
	[GetSpellInfo(18413)] = 18413, -- Ghostweave Gloves
	[GetSpellInfo(6306)] = 6306, -- Acid Splash
	[GetSpellInfo(10003)] = 10003, -- The Shatterer
	[GetSpellInfo(1536)] = 1536, -- Longshot II
	[GetSpellInfo(11763)] = 11763, -- Firebolt
	[GetSpellInfo(18407)] = 18407, -- Runecloth Tunic
	[GetSpellInfo(6249)] = 6249, -- Opening
	[GetSpellInfo(3566)] = 3566, -- Teleport: Thunder Bluff
	[GetSpellInfo(9481)] = 9481, -- Holy Smite
	[GetSpellInfo(23068)] = 23068, -- Green Firework
	[GetSpellInfo(3945)] = 3945, -- Heavy Blasting Powder
	[GetSpellInfo(6417)] = 6417, -- Dig Rat Stew
	[GetSpellInfo(22421)] = 22421, -- Massive Geyser
	[GetSpellInfo(19061)] = 19061, -- Living Shoulders
	[GetSpellInfo(28280)] = 28280, -- Bombard Slime
	[GetSpellInfo(12082)] = 12082, -- Shadoweave Boots
	[GetSpellInfo(16073)] = 16073, -- Filling
	[GetSpellInfo(18540)] = 18540, -- Ritual of Doom
	[GetSpellInfo(29335)] = 29335, -- Elderberry Pie
	[GetSpellInfo(16072)] = 16072, -- Purify and Place Food
	[GetSpellInfo(10348)] = 10348, -- Tune Up
	[GetSpellInfo(2161)] = 2161, -- Embossed Leather Boots
	[GetSpellInfo(3116)] = 3116, -- Coarse Weightstone
	[GetSpellInfo(7752)] = 7752, -- Slitherskin Mackerel
	[GetSpellInfo(22478)] = 22478, -- Intense Pain
	[GetSpellInfo(5208)] = 5208, -- Poisoned Harpoon
	[GetSpellInfo(6705)] = 6705, -- Murloc Scale Bracers
	[GetSpellInfo(15400)] = 15400, -- Lesser Arcane Amalgamation
	[GetSpellInfo(16007)] = 16007, -- Draco-Incarcinatrix 900
	[GetSpellInfo(4286)] = 4286, -- Poisonous Spit
	[GetSpellInfo(2543)] = 2543, -- Westfall Stew
	[GetSpellInfo(12722)] = 12722, -- Goblin Radio
	[GetSpellInfo(3495)] = 3495, -- Golden Iron Destroyer
	[GetSpellInfo(13240)] = 13240, -- The Mortar: Reloaded
	[GetSpellInfo(18630)] = 18630, -- Heavy Runecloth Bandage
	[GetSpellInfo(21728)] = 21728, -- Planting Ichman's Beacon
	[GetSpellInfo(21332)] = 21332, -- Aspect of Neptulon
	[GetSpellInfo(3780)] = 3780, -- Heavy Armor Kit
	[GetSpellInfo(10632)] = 10632, -- Helm of Fire
	[GetSpellInfo(3497)] = 3497, -- Frost Tiger Blade
	[GetSpellInfo(3971)] = 3971, -- Gnomish Cloaking Device
	[GetSpellInfo(10714)] = 10714, -- Summon Black Kingsnake
	[GetSpellInfo(2668)] = 2668, -- Rough Bronze Leggings
	[GetSpellInfo(12045)] = 12045, -- Simple Linen Boots
	[GetSpellInfo(4978)] = 4978, -- Cleanse Wildmane Well
	[GetSpellInfo(19051)] = 19051, -- Heavy Scorpid Vest
	[GetSpellInfo(3494)] = 3494, -- Solid Iron Maul
	[GetSpellInfo(12067)] = 12067, -- Dreamweave Gloves
	[GetSpellInfo(4164)] = 4164, -- Throw Rock
	[GetSpellInfo(8088)] = 8088, -- Nightcrawlers
	[GetSpellInfo(11452)] = 11452, -- Restorative Potion
	[GetSpellInfo(17454)] = 17454, -- Unpainted Mechanostrider
	[GetSpellInfo(16082)] = 16082, -- Palomino Stallion
	[GetSpellInfo(11339)] = 11339, -- Instant Poison V
	[GetSpellInfo(16379)] = 16379, -- Ozzie Explodes
	[GetSpellInfo(12591)] = 12591, -- Unstable Trigger
	[GetSpellInfo(3452)] = 3452, -- Mana Potion
	[GetSpellInfo(12078)] = 12078, -- Red Mageweave Shoulders
	[GetSpellInfo(28221)] = 28221, -- Polar Bracers
	[GetSpellInfo(17639)] = 17639, -- Wail of the Banshee
	[GetSpellInfo(10704)] = 10704, -- Summon Tree Frog
	[GetSpellInfo(12740)] = 12740, -- Summon Infernal Servant
	[GetSpellInfo(20629)] = 20629, -- Corrosive Venom Spit
	[GetSpellInfo(7255)] = 7255, -- Holy Protection Potion
	[GetSpellInfo(3652)] = 3652, -- Summon Spirit of Old
	[GetSpellInfo(5017)] = 5017, -- Divining Trance
	[GetSpellInfo(27723)] = 27723, -- Dark Desire
	[GetSpellInfo(2830)] = 2830, -- Sharpen Blade III
	[GetSpellInfo(22789)] = 22789, -- Gordok Green Grog
	[GetSpellInfo(3015)] = 3015, -- Bombard II
	[GetSpellInfo(7934)] = 7934, -- Anti-Venom
	[GetSpellInfo(10955)] = 10955, -- Shackle Undead
	[GetSpellInfo(22989)] = 22989, -- The Breaking
	[GetSpellInfo(10716)] = 10716, -- Summon Brown Snake
	[GetSpellInfo(10712)] = 10712, -- Summon Spotted Rabbit
	[GetSpellInfo(21979)] = 21979, -- Create The Pariah's Instructions
	[GetSpellInfo(18762)] = 18762, -- Hand of Iruxos
	[GetSpellInfo(22844)] = 22844, -- Arcanum of Focus
	[GetSpellInfo(11016)] = 11016, -- Soul Bite
	[GetSpellInfo(14292)] = 14292, -- Fling Torch
	[GetSpellInfo(2545)] = 2545, -- Cooked Crab Claw
	[GetSpellInfo(20849)] = 20849, -- Flarecore Gloves
	[GetSpellInfo(11454)] = 11454, -- Inlaid Mithril Cylinder
	[GetSpellInfo(3376)] = 3376, -- Curiously Tasty Omelet
	[GetSpellInfo(3229)] = 3229, -- Quick Bloodlust
	[GetSpellInfo(3769)] = 3769, -- Dark Leather Shoulders
	[GetSpellInfo(3368)] = 3368, -- Drink Minor Potion
	[GetSpellInfo(18989)] = 18989, -- Gray Kodo
	[GetSpellInfo(27624)] = 27624, -- Lesser Healing Wave
	[GetSpellInfo(3772)] = 3772, -- Green Leather Armor
	[GetSpellInfo(3007)] = 3007, -- Longshot III
	[GetSpellInfo(3120)] = 3120, -- Sol L
	[GetSpellInfo(3237)] = 3237, -- Curse of Thule
	[GetSpellInfo(23225)] = 23225, -- Swift Green Mechanostrider
	[GetSpellInfo(28242)] = 28242, -- Icebane Breastplate
	[GetSpellInfo(17229)] = 17229, -- Winterspring Frostsaber
	[GetSpellInfo(10254)] = 10254, -- Stone Dwarf Awaken Visual
	[GetSpellInfo(3974)] = 3974, -- Crude Scope
	[GetSpellInfo(9968)] = 9968, -- Heavy Mithril Boots
	[GetSpellInfo(8760)] = 8760, -- Azure Silk Hood
	[GetSpellInfo(11355)] = 11355, -- Deadly Poison III
	[GetSpellInfo(3108)] = 3108, -- Touch of Death
	[GetSpellInfo(10710)] = 10710, -- Summon Cottontail Rabbit
	[GetSpellInfo(22686)] = 22686, -- Bellowing Roar
	[GetSpellInfo(23765)] = 23765, -- Darkmoon Faire Fortune
	[GetSpellInfo(13463)] = 13463, -- Summon Bloodpetal Mini Pests
	[GetSpellInfo(27642)] = 27642, -- Copy of Increase Reputation
	[GetSpellInfo(5174)] = 5174, -- Cookie's Cooking
	[GetSpellInfo(12071)] = 12071, -- Shadoweave Gloves
	[GetSpellInfo(10550)] = 10550, -- Nightscape Cloak
	[GetSpellInfo(6499)] = 6499, -- Boiled Clams
	[GetSpellInfo(4961)] = 4961, -- Resupply
	[GetSpellInfo(6907)] = 6907, -- Diseased Slime
	[GetSpellInfo(23250)] = 23250, -- Swift Brown Wolf
	[GetSpellInfo(17161)] = 17161, -- Taking Moon Well Sample
	[GetSpellInfo(6974)] = 6974, -- Gnome Camera Connection
	[GetSpellInfo(9202)] = 9202, -- Green Whelp Bracers
	[GetSpellInfo(7920)] = 7920, -- Mebok Smart Drink
	[GetSpellInfo(11402)] = 11402, -- Shay's Bell
	[GetSpellInfo(15745)] = 15745, -- Summon Rookery Whelp
	[GetSpellInfo(7762)] = 7762, -- Summon Gunther's Visage
	[GetSpellInfo(3373)] = 3373, -- Crocolisk Gumbo
	[GetSpellInfo(22869)] = 22869, -- Mooncloth Gloves
	[GetSpellInfo(22867)] = 22867, -- Felcloth Gloves
	[GetSpellInfo(24696)] = 24696, -- Summon Murky
	[GetSpellInfo(22921)] = 22921, -- Girdle of Insight
	[GetSpellInfo(8363)] = 8363, -- Parasite
	[GetSpellInfo(16973)] = 16973, -- Enchanted Battlehammer
	[GetSpellInfo(16657)] = 16657, -- Imperial Plate Boots
	[GetSpellInfo(21267)] = 21267, -- Conjure Altar of Summoning
	[GetSpellInfo(23304)] = 23304, -- Manna-Enriched Horse Feed
	[GetSpellInfo(4055)] = 4055, -- Mechanical Squirrel
	[GetSpellInfo(17928)] = 17928, -- Howl of Terror
	[GetSpellInfo(12655)] = 12655, -- Enlightenment
	[GetSpellInfo(3869)] = 3869, -- Bright Yellow Shirt
	[GetSpellInfo(24422)] = 24422, -- Zandalar Signet of Might
	[GetSpellInfo(10792)] = 10792, -- Spotted Panther
	[GetSpellInfo(19100)] = 19100, -- Heavy Scorpid Shoulders
	[GetSpellInfo(19571)] = 19571, -- Destroy Ghost Magnet
	[GetSpellInfo(23633)] = 23633, -- Gloves of the Dawn
	[GetSpellInfo(22759)] = 22759, -- Flarecore Wraps
	[GetSpellInfo(11465)] = 11465, -- Elixir of Greater Intellect
	[GetSpellInfo(5219)] = 5219, -- Draw of Thistlenettle
	[GetSpellInfo(11024)] = 11024, -- Call of Thund
	[GetSpellInfo(22868)] = 22868, -- Inferno Gloves
	[GetSpellInfo(9198)] = 9198, -- Frost Leather Cloak
	[GetSpellInfo(15856)] = 15856, -- Hot Wolf Ribs
	[GetSpellInfo(5401)] = 5401, -- Lizard Bolt
	[GetSpellInfo(19877)] = 19877, -- Tranquilizing Shot
	[GetSpellInfo(21249)] = 21249, -- Call of the Nether
	[GetSpellInfo(3331)] = 3331, -- Silvered Bronze Boots
	[GetSpellInfo(16055)] = 16055, -- Nightsaber
	[GetSpellInfo(12902)] = 12902, -- Gnomish Net-o-Matic Projector
	[GetSpellInfo(1084)] = 1084, -- Firebolt III
	[GetSpellInfo(12760)] = 12760, -- Goblin Sapper Charge
	[GetSpellInfo(3188)] = 3188, -- Elixir of Ogre's Strength
	[GetSpellInfo(3177)] = 3177, -- Elixir of Defense
	[GetSpellInfo(15295)] = 15295, -- Dark Iron Shoulders
	[GetSpellInfo(15863)] = 15863, -- Carrion Surprise
	[GetSpellInfo(16056)] = 16056, -- Frostsaber
	[GetSpellInfo(7224)] = 7224, -- Steel Weapon Chain
	[GetSpellInfo(711)] = 711, -- Hellfire
	[GetSpellInfo(26218)] = 26218, -- Mistletoe
	[GetSpellInfo(14929)] = 14929, -- Fill Nagmara's Vial
	[GetSpellInfo(3112)] = 3112, -- Enhance Blunt Weapon
	[GetSpellInfo(3328)] = 3328, -- Rough Bronze Shoulders
	[GetSpellInfo(16197)] = 16197, -- Empty Charm Pouch
	[GetSpellInfo(8362)] = 8362, -- Renew
	[GetSpellInfo(24138)] = 24138, -- Bloodsoul Gauntlets
	[GetSpellInfo(21848)] = 21848, -- Snowman
	[GetSpellInfo(10059)] = 10059, -- Portal: Stormwind
	[GetSpellInfo(23239)] = 23239, -- Swift Gray Ram
	[GetSpellInfo(16746)] = 16746, -- Invulnerable Mail
	[GetSpellInfo(15441)] = 15441, -- Greater Arcane Amalgamation
	[GetSpellInfo(17176)] = 17176, -- Panther Cage Key
	[GetSpellInfo(3816)] = 3816, -- Cured Light Hide
	[GetSpellInfo(471)] = 471, -- Palamino Stallion
	[GetSpellInfo(446)] = 446, -- Teleport Cemetary
	[GetSpellInfo(4508)] = 4508, -- Discolored Healing Potion
	[GetSpellInfo(6421)] = 6421, -- Ashcrombe's Unlock
	[GetSpellInfo(12199)] = 12199, -- Summon Ishamuhale
	[GetSpellInfo(26426)] = 26426, -- Large Blue Rocket Cluster
	[GetSpellInfo(10140)] = 10140, -- Conjure Water
	[GetSpellInfo(20627)] = 20627, -- Lightning Breath
	[GetSpellInfo(15294)] = 15294, -- Dark Iron Sunderer
	[GetSpellInfo(26443)] = 26443, -- Firework Cluster Launcher
	[GetSpellInfo(26105)] = 26105, -- Glare
	[GetSpellInfo(23242)] = 23242, -- Swift Olive Raptor
	[GetSpellInfo(24201)] = 24201, -- Create Rune of the Dawn
	[GetSpellInfo(9820)] = 9820, -- Barbaric Iron Gloves
	[GetSpellInfo(3276)] = 3276, -- Heavy Linen Bandage
	[GetSpellInfo(13630)] = 13630, -- Scraping
	[GetSpellInfo(3398)] = 3398, -- Hot Lion Chops
	[GetSpellInfo(6688)] = 6688, -- Red Woolen Bag
	[GetSpellInfo(3304)] = 3304, -- Smelt Tin
	[GetSpellInfo(9918)] = 9918, -- Solid Sharpening Stone
	[GetSpellInfo(16450)] = 16450, -- Summon Smolderweb
	[GetSpellInfo(17506)] = 17506, -- Soul Breaker
	[GetSpellInfo(25347)] = 25347, -- Deadly Poison V
	[GetSpellInfo(3320)] = 3320, -- Rough Grinding Stone
	[GetSpellInfo(23677)] = 23677, -- Beasts Deck
	[GetSpellInfo(21067)] = 21067, -- Poison Bolt
	[GetSpellInfo(10490)] = 10490, -- Comfortable Leather Hat
	[GetSpellInfo(27)] = 27, -- Goldshire Portal
	[GetSpellInfo(3387)] = 3387, -- Rage of Thule
	[GetSpellInfo(15743)] = 15743, -- Flamecrack
	[GetSpellInfo(3926)] = 3926, -- Copper Modulator
	[GetSpellInfo(28243)] = 28243, -- Icebane Gauntlets
	[GetSpellInfo(16648)] = 16648, -- Radiant Breastplate
	[GetSpellInfo(21175)] = 21175, -- Spider Sausage
	[GetSpellInfo(27587)] = 27587, -- Thick Obsidian Breastplate
	[GetSpellInfo(12521)] = 12521, -- Teleport from Azshara Tower
	[GetSpellInfo(28023)] = 28023, -- Create Healthstone
	[GetSpellInfo(5110)] = 5110, -- Summon Living Flame
	[GetSpellInfo(3293)] = 3293, -- Copper Battle Axe
	[GetSpellInfo(7079)] = 7079, -- Simple Teleport Other
	[GetSpellInfo(22430)] = 22430, -- Refined Scale of Onyxia
	[GetSpellInfo(26056)] = 26056, -- Summon Green Qiraji Battle Tank
	[GetSpellInfo(7828)] = 7828, -- Rockscale Cod
	[GetSpellInfo(17461)] = 17461, -- Black Ram
	[GetSpellInfo(25162)] = 25162, -- Summon Disgusting Oozeling
	[GetSpellInfo(11459)] = 11459, -- Philosophers' Stone
	[GetSpellInfo(3855)] = 3855, -- Spidersilk Boots
	[GetSpellInfo(29163)] = 29163, -- Copy of Frostbolt
	[GetSpellInfo(12715)] = 12715, -- Goblin Rocket Fuel Recipe
	[GetSpellInfo(14008)] = 14008, -- Miblon's Bait
	[GetSpellInfo(3843)] = 3843, -- Heavy Woolen Gloves
	[GetSpellInfo(29483)] = 29483, -- Might of the Scourge
	[GetSpellInfo(4975)] = 4975, -- Cleanse Winterhoof Well
	[GetSpellInfo(20589)] = 20589, -- Escape Artist
	[GetSpellInfo(16781)] = 16781, -- Combining Charms
	[GetSpellInfo(6416)] = 6416, -- Strider Stew
	[GetSpellInfo(14327)] = 14327, -- Scare Beast
	[GetSpellInfo(17709)] = 17709, -- Summon Zergling
	[GetSpellInfo(25840)] = 25840, -- Full Heal
	[GetSpellInfo(3841)] = 3841, -- Green Linen Bracers
	[GetSpellInfo(17405)] = 17405, -- Domination
	[GetSpellInfo(2159)] = 2159, -- Fine Leather Cloak
	[GetSpellInfo(9986)] = 9986, -- Bronze Greatsword
	[GetSpellInfo(6521)] = 6521, -- Pearl-clasped Cloak
	[GetSpellInfo(6686)] = 6686, -- Red Linen Bag
	[GetSpellInfo(12304)] = 12304, -- Drawing Kit
	[GetSpellInfo(24136)] = 24136, -- Bloodsoul Breastplate
	[GetSpellInfo(3778)] = 3778, -- Gem-studded Leather Belt
	[GetSpellInfo(10713)] = 10713, -- Summon Albino Snake
	[GetSpellInfo(3508)] = 3508, -- Green Iron Hauberk
	[GetSpellInfo(28481)] = 28481, -- Sylvan Crown
	[GetSpellInfo(12718)] = 12718, -- Goblin Construction Helmet
	[GetSpellInfo(2480)] = 2480, -- Shoot Bow
	[GetSpellInfo(28146)] = 28146, -- Copy of Portal: Undercity
	[GetSpellInfo(18458)] = 18458, -- Robe of the Void
	[GetSpellInfo(21050)] = 21050, -- Melodious Rapture
	[GetSpellInfo(11417)] = 11417, -- Portal: Orgrimmar
	[GetSpellInfo(19065)] = 19065, -- Runic Leather Bracers
	[GetSpellInfo(6272)] = 6272, -- Eye of Yesmur (PT)
	[GetSpellInfo(23063)] = 23063, -- Dense Dynamite
	[GetSpellInfo(10969)] = 10969, -- Blue Mechanostrider
	[GetSpellInfo(3330)] = 3330, -- Silvered Bronze Shoulders
	[GetSpellInfo(22593)] = 22593, -- Flame Mantle of the Dawn
	[GetSpellInfo(698)] = 698, -- Ritual of Summoning
	[GetSpellInfo(8275)] = 8275, -- Poisoned Shot
	[GetSpellInfo(18991)] = 18991, -- Green Kodo
	[GetSpellInfo(184)] = 184, -- Fire Shield II
	[GetSpellInfo(19666)] = 19666, -- Silver Skeleton Key
	[GetSpellInfo(2576)] = 2576, -- Mining
	[GetSpellInfo(18420)] = 18420, -- Brightcloth Cloak
	[GetSpellInfo(7151)] = 7151, -- Barbaric Shoulders
	[GetSpellInfo(25748)] = 25748, -- Poison Stinger
	[GetSpellInfo(30001)] = 30001, -- Copy of Fear
	[GetSpellInfo(10529)] = 10529, -- Wild Leather Shoulders
	[GetSpellInfo(15728)] = 15728, -- Plague Cloud
	[GetSpellInfo(19066)] = 19066, -- Frostsaber Boots
	[GetSpellInfo(23229)] = 23229, -- Swift Brown Steed
	[GetSpellInfo(10679)] = 10679, -- Summon White Kitten
	[GetSpellInfo(3277)] = 3277, -- Wool Bandage
	[GetSpellInfo(9931)] = 9931, -- Mithril Scale Pants
	[GetSpellInfo(22808)] = 22808, -- Elixir of Greater Water Breathing
	[GetSpellInfo(18159)] = 18159, -- Curse of the Fallen Magram
	[GetSpellInfo(10097)] = 10097, -- Smelt Mithril
	[GetSpellInfo(3761)] = 3761, -- Fine Leather Tunic
	[GetSpellInfo(8000)] = 8000, -- Area Burn
	[GetSpellInfo(18711)] = 18711, -- Forging
	[GetSpellInfo(26417)] = 26417, -- Small Green Rocket
	[GetSpellInfo(3864)] = 3864, -- Star Belt
	[GetSpellInfo(19062)] = 19062, -- Ironfeather Shoulders
	[GetSpellInfo(17155)] = 17155, -- Sprinkling Purified Water
	[GetSpellInfo(13564)] = 13564, -- Opening Dark Coffer
	[GetSpellInfo(21913)] = 21913, -- Edge of Winter
	[GetSpellInfo(25662)] = 25662, -- Copy of Nightfin Soup
	[GetSpellInfo(22799)] = 22799, -- King of the Gordok
	[GetSpellInfo(11758)] = 11758, -- Dowsing
	[GetSpellInfo(17045)] = 17045, -- Dawn's Gambit
	[GetSpellInfo(12509)] = 12509, -- Teleport to Azshara Tower
	[GetSpellInfo(22434)] = 22434, -- Charged Scale of Onyxia
	[GetSpellInfo(16971)] = 16971, -- Huge Thorium Battleaxe
	[GetSpellInfo(8366)] = 8366, -- Ironforge Chain
	[GetSpellInfo(23507)] = 23507, -- Snake Burst Firework
	[GetSpellInfo(26001)] = 26001, -- Reputation - Ahn'Qiraj Temple Boss
	[GetSpellInfo(509)] = 509, -- Feeblemind II
	[GetSpellInfo(18153)] = 18153, -- Kodo Kombobulator
	[GetSpellInfo(15533)] = 15533, -- Stoned - Channel Cast Visual
	[GetSpellInfo(9928)] = 9928, -- Heavy Mithril Gauntlet
	[GetSpellInfo(9197)] = 9197, -- Green Whelp Armor
	[GetSpellInfo(16997)] = 16997, -- Gargoyle Strike
	[GetSpellInfo(22923)] = 22923, -- Swift Flight Bracers
	[GetSpellInfo(12079)] = 12079, -- Red Mageweave Bag
	[GetSpellInfo(18242)] = 18242, -- Hot Smoked Bass
	[GetSpellInfo(14814)] = 14814, -- Throw Dark Iron Ale
	[GetSpellInfo(3308)] = 3308, -- Smelt Gold
	[GetSpellInfo(2160)] = 2160, -- Embossed Leather Vest
	[GetSpellInfo(13565)] = 13565, -- Opening Secure Safe
	[GetSpellInfo(21950)] = 21950, -- Recite Words of Celebras
	[GetSpellInfo(2828)] = 2828, -- Sharpen Blade
	[GetSpellInfo(19668)] = 19668, -- Truesilver Skeleton Key
	[GetSpellInfo(9010)] = 9010, -- Create Filled Containment Coffer
	[GetSpellInfo(16724)] = 16724, -- Whitesoul Helm
	[GetSpellInfo(22870)] = 22870, -- Cloak of Warding
	[GetSpellInfo(7183)] = 7183, -- Elixir of Minor Defense
	[GetSpellInfo(17016)] = 17016, -- Placing Beacon Torch
	[GetSpellInfo(3207)] = 3207, -- Sol U
	[GetSpellInfo(10841)] = 10841, -- Heavy Mageweave Bandage
	[GetSpellInfo(11547)] = 11547, -- Drive Nimboya's Laden Pike
	[GetSpellInfo(3356)] = 3356, -- Flame Lash
	[GetSpellInfo(28615)] = 28615, -- Spike Volley
	[GetSpellInfo(10326)] = 10326, -- Turn Undead
	[GetSpellInfo(6898)] = 6898, -- White Ram
	[GetSpellInfo(11548)] = 11548, -- Summon Spider God
	[GetSpellInfo(27572)] = 27572, -- Smitten
	[GetSpellInfo(14250)] = 14250, -- Capture Grark
	[GetSpellInfo(1849)] = 1849, -- Beast Claws II
	[GetSpellInfo(26424)] = 26424, -- Green Rocket Cluster
	[GetSpellInfo(3491)] = 3491, -- Big Bronze Knife
	[GetSpellInfo(25309)] = 25309, -- Immolate
	[GetSpellInfo(7076)] = 7076, -- Summon Tervosh's Minion
	[GetSpellInfo(16987)] = 16987, -- Darkspear
	[GetSpellInfo(3334)] = 3334, -- Green Iron Boots
	[GetSpellInfo(25183)] = 25183, -- Shadow Weakness
	[GetSpellInfo(11048)] = 11048, -- Perm. Illusion Bishop Tyriona
	[GetSpellInfo(10681)] = 10681, -- Summon Cockatoo
	[GetSpellInfo(24365)] = 24365, -- Mageblood Potion
	[GetSpellInfo(11416)] = 11416, -- Portal: Ironforge
	[GetSpellInfo(23628)] = 23628, -- Heavy Timbermaw Belt
	[GetSpellInfo(10798)] = 10798, -- Obsidian Raptor
	[GetSpellInfo(8802)] = 8802, -- Crimson Silk Robe
	[GetSpellInfo(24703)] = 24703, -- Dreamscale Breastplate
	[GetSpellInfo(6700)] = 6700, -- Dimensional Portal
	[GetSpellInfo(7624)] = 7624, -- White Linen Robe
	[GetSpellInfo(16336)] = 16336, -- Haunting Phantoms
	[GetSpellInfo(15915)] = 15915, -- Spiced Chili Crab
	[GetSpellInfo(10228)] = 10228, -- Greater Invisibility
	[GetSpellInfo(23653)] = 23653, -- Nightfall
	[GetSpellInfo(11443)] = 11443, -- Cripple
	[GetSpellInfo(11435)] = 11435, -- Create Mallet of Zul'Farrak
	[GetSpellInfo(21646)] = 21646, -- Conjure Circle of Calling
	[GetSpellInfo(3396)] = 3396, -- Corrosive Poison
	[GetSpellInfo(20757)] = 20757, -- Create Soulstone (Major)
	[GetSpellInfo(3337)] = 3337, -- Heavy Grinding Stone
	[GetSpellInfo(16644)] = 16644, -- Thorium Bracers
	[GetSpellInfo(25178)] = 25178, -- Frost Weakness
	[GetSpellInfo(5784)] = 5784, -- Summon Felsteed
	[GetSpellInfo(19794)] = 19794, -- Spellpower Goggles Xtreme Plus
	[GetSpellInfo(461)] = 461, -- Righteous Flame On
	[GetSpellInfo(3763)] = 3763, -- Fine Leather Belt
	[GetSpellInfo(16084)] = 16084, -- Mottled Red Raptor
	[GetSpellInfo(10533)] = 10533, -- Tough Scorpid Bracers
	[GetSpellInfo(8677)] = 8677, -- Summon Effect
	[GetSpellInfo(21355)] = 21355, -- Planting Guse's Beacon
	[GetSpellInfo(9595)] = 9595, -- Attach Shaft to Medallion
	[GetSpellInfo(17235)] = 17235, -- Raise Undead Scarab
	[GetSpellInfo(15050)] = 15050, -- Psychometry
	[GetSpellInfo(9920)] = 9920, -- Solid Grinding Stone
	[GetSpellInfo(10568)] = 10568, -- Tough Scorpid Leggings
	[GetSpellInfo(30297)] = 30297, -- Heightened Senses
	[GetSpellInfo(8348)] = 8348, -- Julie's Blessing
	[GetSpellInfo(7124)] = 7124, -- Arugal's Gift
	[GetSpellInfo(10793)] = 10793, -- Striped Nightsaber
	[GetSpellInfo(7638)] = 7638, -- Potion Toss
	[GetSpellInfo(10207)] = 10207, -- Scorch
	[GetSpellInfo(5273)] = 5273, -- Dark Iron Dwarf Disguise
	[GetSpellInfo(24137)] = 24137, -- Bloodsoul Shoulders
	[GetSpellInfo(2641)] = 2641, -- Dismiss Pet
	[GetSpellInfo(3171)] = 3171, -- Elixir of Wisdom
	[GetSpellInfo(468)] = 468, -- White Stallion
	[GetSpellInfo(18444)] = 18444, -- Runecloth Headband
	[GetSpellInfo(1940)] = 1940, -- Rocket Blast
	[GetSpellInfo(23251)] = 23251, -- Swift Timber Wolf
	[GetSpellInfo(9208)] = 9208, -- Swift Boots
	[GetSpellInfo(22567)] = 22567, -- Summon Ar'lia
	[GetSpellInfo(18658)] = 18658, -- Hibernate
	[GetSpellInfo(16562)] = 16562, -- Urok Minions Vanish
	[GetSpellInfo(15276)] = 15276, -- Opening Bar Door
	[GetSpellInfo(18239)] = 18239, -- Cooked Glossy Mightfish
	[GetSpellInfo(15910)] = 15910, -- Heavy Kodo Stew
	[GetSpellInfo(8238)] = 8238, -- Savory Deviate Delight
	[GetSpellInfo(9232)] = 9232, -- Scarlet Resurrection
	[GetSpellInfo(22990)] = 22990, -- The Forming
	[GetSpellInfo(6905)] = 6905, -- Summon Illusionary Nightmare
	[GetSpellInfo(12759)] = 12759, -- Gnomish Death Ray
	[GetSpellInfo(2840)] = 2840, -- Creeping Anguish
	[GetSpellInfo(6196)] = 6196, -- Far Sight
	[GetSpellInfo(3863)] = 3863, -- Spider Belt
	[GetSpellInfo(20041)] = 20041, -- Tammra Sapling
	[GetSpellInfo(10001)] = 10001, -- Big Black Mace
	[GetSpellInfo(20748)] = 20748, -- Rebirth
	[GetSpellInfo(13524)] = 13524, -- Curse of Stalvan
	[GetSpellInfo(3924)] = 3924, -- Copper Tube
	[GetSpellInfo(21143)] = 21143, -- Gingerbread Cookie
	[GetSpellInfo(23707)] = 23707, -- Lava Belt
	[GetSpellInfo(28207)] = 28207, -- Glacial Vest
	[GetSpellInfo(8598)] = 8598, -- Lightning Blast
	[GetSpellInfo(9201)] = 9201, -- Dusky Bracers
	[GetSpellInfo(23432)] = 23432, -- Summon Hawksbill Snapjaw
	[GetSpellInfo(28482)] = 28482, -- Sylvan Shoulders
	[GetSpellInfo(17014)] = 17014, -- Bone Shards
	[GetSpellInfo(17777)] = 17777, -- Create Commission
	[GetSpellInfo(20201)] = 20201, -- Arcanite Rod
	[GetSpellInfo(21960)] = 21960, -- Manifest Spirit
	[GetSpellInfo(28224)] = 28224, -- Icy Scale Bracers
	[GetSpellInfo(3764)] = 3764, -- Hillman's Leather Gloves
	[GetSpellInfo(19079)] = 19079, -- Stormshroud Armor
	[GetSpellInfo(7084)] = 7084, -- Damage Car
	[GetSpellInfo(12906)] = 12906, -- Gnomish Battle Chicken
	[GetSpellInfo(3133)] = 3133, -- Beast Claws III
	[GetSpellInfo(23012)] = 23012, -- Summon Orphan
	[GetSpellInfo(17576)] = 17576, -- Greater Nature Protection Potion
	[GetSpellInfo(23071)] = 23071, -- Truesilver Transformer
	[GetSpellInfo(2335)] = 2335, -- Swiftness Potion
	[GetSpellInfo(7220)] = 7220, -- Weapon Chain
	[GetSpellInfo(15125)] = 15125, -- Scarshield Portal
	[GetSpellInfo(8762)] = 8762, -- Silk Headband
	[GetSpellInfo(5412)] = 5412, -- Balance of Nature Failure
	[GetSpellInfo(7221)] = 7221, -- Iron Shield Spike
	[GetSpellInfo(9858)] = 9858, -- Regrowth
	[GetSpellInfo(11448)] = 11448, -- Greater Mana Potion
	[GetSpellInfo(18238)] = 18238, -- Spotted Yellowtail
	[GetSpellInfo(25952)] = 25952, -- Reindeer Dust Effect
	[GetSpellInfo(2741)] = 2741, -- Bronze Axe
	[GetSpellInfo(16655)] = 16655, -- Fiery Plate Gauntlets
	[GetSpellInfo(9456)] = 9456, -- Tharnariun Cure 1
	[GetSpellInfo(6982)] = 6982, -- Gust of Wind
	[GetSpellInfo(3757)] = 3757, -- Woolen Bag
	[GetSpellInfo(23004)] = 23004, -- Summon Alarm-o-Bot
	[GetSpellInfo(28806)] = 28806, -- Toss Fuel on Bonfire
	[GetSpellInfo(10054)] = 10054, -- Conjure Mana Ruby
	[GetSpellInfo(8799)] = 8799, -- Crimson Silk Pantaloons
	[GetSpellInfo(24885)] = 24885, -- Create Crest of Beckoning: Air
	[GetSpellInfo(24221)] = 24221, -- Quest - Teleport Spawn-out
	[GetSpellInfo(3758)] = 3758, -- Green Woolen Bag
	[GetSpellInfo(470)] = 470, -- Black Stallion
	[GetSpellInfo(3958)] = 3958, -- Iron Strut
	[GetSpellInfo(18666)] = 18666, -- Corrupt Redpath
	[GetSpellInfo(26403)] = 26403, -- Festive Red Dress
	[GetSpellInfo(25181)] = 25181, -- Arcane Weakness
	[GetSpellInfo(8483)] = 8483, -- White Swashbuckler's Shirt
	[GetSpellInfo(9912)] = 9912, -- Wrath
	[GetSpellInfo(459)] = 459, -- Gray Wolf
	[GetSpellInfo(2540)] = 2540, -- Roasted Boar Meat
	[GetSpellInfo(22681)] = 22681, -- Shadowblink
	[GetSpellInfo(16075)] = 16075, -- Throw Axe
	[GetSpellInfo(8606)] = 8606, -- Summon Cyclonian
	[GetSpellInfo(20269)] = 20269, -- Enchanted Gaea Seed
	[GetSpellInfo(23312)] = 23312, -- Time Lapse
	[GetSpellInfo(5275)] = 5275, -- South Seas Pirate Disguise
	[GetSpellInfo(19873)] = 19873, -- Destroy Egg
	[GetSpellInfo(19057)] = 19057, -- Armor +40
	[GetSpellInfo(28394)] = 28394, -- Reputation - Ratchet +500
	[GetSpellInfo(3921)] = 3921, -- Deprecated Solid Shot
	[GetSpellInfo(26054)] = 26054, -- Summon Red Qiraji Battle Tank
	[GetSpellInfo(6949)] = 6949, -- Weak Frostbolt
	[GetSpellInfo(19059)] = 19059, -- Volcanic Leggings
	[GetSpellInfo(10869)] = 10869, -- Summon Embers
	[GetSpellInfo(15048)] = 15048, -- Summon Bomb
	[GetSpellInfo(19055)] = 19055, -- Runic Leather Gauntlets
	[GetSpellInfo(28393)] = 28393, -- Reputation - Booty Bay +500
	[GetSpellInfo(18449)] = 18449, -- Runecloth Shoulders
	[GetSpellInfo(19093)] = 19093, -- Onyxia Scale Cloak
	[GetSpellInfo(6576)] = 6576, -- Intimidating Growl
	[GetSpellInfo(17580)] = 17580, -- Major Mana Potion
	[GetSpellInfo(24649)] = 24649, -- Thousand Blades
	[GetSpellInfo(6414)] = 6414, -- Roasted Kodo Meat
	[GetSpellInfo(10796)] = 10796, -- Turquoise Raptor
	[GetSpellInfo(22756)] = 22756, -- Sharpen Weapon - Critical
	[GetSpellInfo(8986)] = 8986, -- Summon Illusionary Phantasm
	[GetSpellInfo(9657)] = 9657, -- Shadow Shell
	[GetSpellInfo(8139)] = 8139, -- Fevered Fatigue
	[GetSpellInfo(6758)] = 6758, -- Party Fever
	[GetSpellInfo(7421)] = 7421, -- Runed Copper Rod
	[GetSpellInfo(5213)] = 5213, -- Molten Metal
	[GetSpellInfo(20770)] = 20770, -- Resurrection
	[GetSpellInfo(3399)] = 3399, -- Tasty Lion Steak
	[GetSpellInfo(3326)] = 3326, -- Coarse Grinding Stone
	[GetSpellInfo(10318)] = 10318, -- Holy Wrath
	[GetSpellInfo(13262)] = 13262, -- Disenchant
	[GetSpellInfo(11202)] = 11202, -- Crippling Poison
	[GetSpellInfo(16138)] = 16138, -- Sharpen Blade V
	[GetSpellInfo(11790)] = 11790, -- Poison Cloud
	[GetSpellInfo(2399)] = 2399, -- Green Woolen Vest
	[GetSpellInfo(26181)] = 26181, -- Strike
	[GetSpellInfo(12062)] = 12062, -- Stormcloth Pants
	[GetSpellInfo(23241)] = 23241, -- Swift Blue Raptor
	[GetSpellInfo(20513)] = 20513, -- Enchanted Resonite Crystal
	[GetSpellInfo(3762)] = 3762, -- Hillman's Leather Vest
	[GetSpellInfo(12088)] = 12088, -- Cindercloth Boots
	[GetSpellInfo(26423)] = 26423, -- Blue Rocket Cluster
	[GetSpellInfo(26087)] = 26087, -- Core Felcloth Bag
	[GetSpellInfo(25807)] = 25807, -- Great Heal
	[GetSpellInfo(15699)] = 15699, -- Filling Empty Jar
	[GetSpellInfo(25120)] = 25120, -- Lesser Mana Oil
	[GetSpellInfo(13548)] = 13548, -- Summon Farm Chicken
	[GetSpellInfo(28740)] = 28740, -- Summon Whiskers
	[GetSpellInfo(3562)] = 3562, -- Teleport: Ironforge
	[GetSpellInfo(17556)] = 17556, -- Major Healing Potion
	[GetSpellInfo(3498)] = 3498, -- Massive Iron Axe
	[GetSpellInfo(2397)] = 2397, -- Reinforced Linen Cape
	[GetSpellInfo(23189)] = 23189, -- Frost Burn
	[GetSpellInfo(19094)] = 19094, -- Black Dragonscale Shoulders
	[GetSpellInfo(6755)] = 6755, -- Tell Joke
	[GetSpellInfo(13399)] = 13399, -- Cultivate Packet of Seeds
	[GetSpellInfo(2664)] = 2664, -- Runed Copper Bracers
	[GetSpellInfo(4980)] = 4980, -- Quick Frost Ward
	[GetSpellInfo(17455)] = 17455, -- Purple Mechanostrider
	[GetSpellInfo(23079)] = 23079, -- Major Recombobulator
	[GetSpellInfo(10705)] = 10705, -- Summon Eagle Owl
	[GetSpellInfo(8435)] = 8435, -- Forked Lightning
	[GetSpellInfo(15648)] = 15648, -- Summon Corrupted Kitten
	[GetSpellInfo(24368)] = 24368, -- Major Troll's Blood Potion
	[GetSpellInfo(17632)] = 17632, -- Alchemist's Stone
	[GetSpellInfo(12900)] = 12900, -- Mobile Alarm
	[GetSpellInfo(22846)] = 22846, -- Arcanum of Protection
	[GetSpellInfo(16988)] = 16988, -- Hammer of the Titans
	[GetSpellInfo(23136)] = 23136, -- Release J'eevee
	[GetSpellInfo(4526)] = 4526, -- Mass Dispell
	[GetSpellInfo(25808)] = 25808, -- Dispel
	[GetSpellInfo(11131)] = 11131, -- Icicle
	[GetSpellInfo(28163)] = 28163, -- Ice Guard
	[GetSpellInfo(7135)] = 7135, -- Dark Leather Pants
	[GetSpellInfo(23190)] = 23190, -- Heavy Leather Ball
	[GetSpellInfo(23629)] = 23629, -- Heavy Timbermaw Boots
	[GetSpellInfo(11085)] = 11085, -- Chain Bolt
	[GetSpellInfo(28898)] = 28898, -- Blessed Wizard Oil
	[GetSpellInfo(10482)] = 10482, -- Cured Thick Hide
	[GetSpellInfo(16429)] = 16429, -- Piercing Shadow
	[GetSpellInfo(10795)] = 10795, -- Ivory Raptor
	[GetSpellInfo(18436)] = 18436, -- Robe of Winter Night
	[GetSpellInfo(8880)] = 8880, -- Copper Dagger
	[GetSpellInfo(5106)] = 5106, -- Crystal Flash
	[GetSpellInfo(3115)] = 3115, -- Rough Weightstone
	[GetSpellInfo(3230)] = 3230, -- Elixir of Minor Agility
	[GetSpellInfo(12534)] = 12534, -- Flames of Retribution
	[GetSpellInfo(6201)] = 6201, -- Create Healthstone (Minor)
	[GetSpellInfo(693)] = 693, -- Create Soulstone (Minor)
	[GetSpellInfo(9074)] = 9074, -- Nimble Leather Gloves
	[GetSpellInfo(428)] = 428, -- Teleport Moonbrook
	[GetSpellInfo(18952)] = 18952, -- Opening Termite Barrel
	[GetSpellInfo(3944)] = 3944, -- Flame Deflector
	[GetSpellInfo(3595)] = 3595, -- Frost Oil
	[GetSpellInfo(16732)] = 16732, -- Runic Plate Leggings
	[GetSpellInfo(5407)] = 5407, -- Segra Darkthorn Effect
	[GetSpellInfo(23706)] = 23706, -- Golden Mantle of the Dawn
	[GetSpellInfo(3407)] = 3407, -- Rune of Opening
	[GetSpellInfo(6487)] = 6487, -- Ilkrud's Guardians
	[GetSpellInfo(10564)] = 10564, -- Tough Scorpid Shoulders
	[GetSpellInfo(20804)] = 20804, -- Triage
	[GetSpellInfo(5107)] = 5107, -- Opening Booty Chest
	[GetSpellInfo(8776)] = 8776, -- Linen Belt
	[GetSpellInfo(6627)] = 6627, -- Remote Detonate
	[GetSpellInfo(24141)] = 24141, -- Darksoul Shoulders
	[GetSpellInfo(23193)] = 23193, -- Forming Lok'delar
	[GetSpellInfo(8272)] = 8272, -- Mind Tremor
	[GetSpellInfo(3552)] = 3552, -- Conjure Mana Jade
	[GetSpellInfo(23077)] = 23077, -- Gyrofreeze Ice Reflector
	[GetSpellInfo(26427)] = 26427, -- Large Green Rocket Cluster
	[GetSpellInfo(11802)] = 11802, -- Dark Iron Land Mine
	[GetSpellInfo(2385)] = 2385, -- Brown Linen Vest
	[GetSpellInfo(11467)] = 11467, -- Elixir of Greater Agility
	[GetSpellInfo(11468)] = 11468, -- Elixir of Dream Vision
	[GetSpellInfo(8040)] = 8040, -- Druid's Slumber
	[GetSpellInfo(2658)] = 2658, -- Smelt Silver
	[GetSpellInfo(12458)] = 12458, -- Evil God Counterspell
	[GetSpellInfo(22727)] = 22727, -- Core Armor Kit
	[GetSpellInfo(24302)] = 24302, -- Eternium Fishing Line
	[GetSpellInfo(2963)] = 2963, -- Bolt of Linen Cloth
	[GetSpellInfo(110)] = 110, -- Spell Deflection (NYI)
	[GetSpellInfo(3933)] = 3933, -- Small Seaforium Charge
	[GetSpellInfo(457)] = 457, -- Feeblemind
	[GetSpellInfo(6899)] = 6899, -- Brown Ram
	[GetSpellInfo(11792)] = 11792, -- Opening Cage
	[GetSpellInfo(11021)] = 11021, -- Flamespit
	[GetSpellInfo(10509)] = 10509, -- Turtle Scale Gloves
	[GetSpellInfo(18451)] = 18451, -- Felcloth Robe
	[GetSpellInfo(16965)] = 16965, -- Bleakwood Hew
	[GetSpellInfo(9206)] = 9206, -- Dusky Belt
	[GetSpellInfo(7643)] = 7643, -- Greater Adept's Robe
	[GetSpellInfo(3175)] = 3175, -- Limited Invulnerability Potion
	[GetSpellInfo(7437)] = 7437, -- Break Stuff
	[GetSpellInfo(3865)] = 3865, -- Bolt of Mageweave
	[GetSpellInfo(24024)] = 24024, -- Unstable Concoction
	[GetSpellInfo(17572)] = 17572, -- Purification Potion
	[GetSpellInfo(12899)] = 12899, -- Gnomish Shrink Ray
	[GetSpellInfo(3756)] = 3756, -- Embossed Leather Gloves
	[GetSpellInfo(24399)] = 24399, -- Dark Iron Boots
	[GetSpellInfo(19815)] = 19815, -- Delicate Arcanite Converter
	[GetSpellInfo(24898)] = 24898, -- Create Scepter of Beckoning: Water
	[GetSpellInfo(17474)] = 17474, -- Find Relic Fragment
	[GetSpellInfo(3131)] = 3131, -- Frost Breath
	[GetSpellInfo(16728)] = 16728, -- Helm of the Great Chief
	[GetSpellInfo(15049)] = 15049, -- Summon Robot
	[GetSpellInfo(16053)] = 16053, -- Dominion of Soul
	[GetSpellInfo(24194)] = 24194, -- Uther's Tribute
	[GetSpellInfo(10418)] = 10418, -- Arugal spawn-in spell
	[GetSpellInfo(24923)] = 24923, -- Honor Points +398
	[GetSpellInfo(10684)] = 10684, -- Summon Senegal
	[GetSpellInfo(3488)] = 3488, -- Felstrom Resurrection
	[GetSpellInfo(16983)] = 16983, -- Serenity
	[GetSpellInfo(3243)] = 3243, -- Life Harvest
	[GetSpellInfo(12081)] = 12081, -- Admiral's Hat
	[GetSpellInfo(20549)] = 20549, -- War Stomp
	[GetSpellInfo(23509)] = 23509, -- Frostwolf Howler
	[GetSpellInfo(3307)] = 3307, -- Smelt Iron
	[GetSpellInfo(27146)] = 27146, -- Left Piece of Lord Valthalak's Amulet
	[GetSpellInfo(9070)] = 9070, -- Black Whelp Cloak
	[GetSpellInfo(11761)] = 11761, -- Scorpid Sample
	[GetSpellInfo(5262)] = 5262, -- Fanatic Blade
	[GetSpellInfo(3919)] = 3919, -- Rough Dynamite
	[GetSpellInfo(11759)] = 11759, -- Basilisk Sample
	[GetSpellInfo(9771)] = 9771, -- Radiation Bolt
	[GetSpellInfo(18990)] = 18990, -- Brown Kodo
	[GetSpellInfo(25031)] = 25031, -- Shoot Missile
	[GetSpellInfo(19092)] = 19092, -- Wicked Leather Belt
	[GetSpellInfo(16665)] = 16665, -- Runic Plate Boots
	[GetSpellInfo(5026)] = 5026, -- Create Water of the Seers
	[GetSpellInfo(18419)] = 18419, -- Felcloth Pants
	[GetSpellInfo(15119)] = 15119, -- Apply Seduction Gland
	[GetSpellInfo(6471)] = 6471, -- Tiny Iron Key
	[GetSpellInfo(3914)] = 3914, -- Brown Linen Pants
	[GetSpellInfo(22723)] = 22723, -- Black War Tiger
	[GetSpellInfo(9961)] = 9961, -- Mithril Coif
	[GetSpellInfo(25030)] = 25030, -- Shoot Rocket
	[GetSpellInfo(4506)] = 4506, -- CHU's QUEST SPELL
	[GetSpellInfo(2053)] = 2053, -- Lesser Heal
	[GetSpellInfo(1936)] = 1936, -- Teleport Anvilmar
	[GetSpellInfo(17563)] = 17563, -- Transmute: Undeath to Water
	[GetSpellInfo(17923)] = 17923, -- Searing Pain
	[GetSpellInfo(6064)] = 6064, -- Heal
	[GetSpellInfo(18447)] = 18447, -- Mooncloth Vest
	[GetSpellInfo(19795)] = 19795, -- Thorium Tube
	[GetSpellInfo(4954)] = 4954, -- Break Tool
	[GetSpellInfo(9148)] = 9148, -- Pilferer's Gloves
	[GetSpellInfo(24242)] = 24242, -- Swift Razzashi Raptor
	[GetSpellInfo(26656)] = 26656, -- Summon Black Qiraji Battle Tank
	[GetSpellInfo(7133)] = 7133, -- Fine Leather Pants
	[GetSpellInfo(7218)] = 7218, -- Weapon Counterweight
	[GetSpellInfo(24848)] = 24848, -- Spitfire Breastplate
	[GetSpellInfo(8795)] = 8795, -- Azure Shoulders
	[GetSpellInfo(11840)] = 11840, -- Summon Edana Hatetalon
	[GetSpellInfo(10015)] = 10015, -- Truesilver Champion
	[GetSpellInfo(271)] = 271, -- Call of the Void
	[GetSpellInfo(867)] = 867, -- Fumble III
	[GetSpellInfo(13028)] = 13028, -- Goldthorn Tea
	[GetSpellInfo(18976)] = 18976, -- Self Resurrection
	[GetSpellInfo(3294)] = 3294, -- Thick War Axe
	[GetSpellInfo(28352)] = 28352, -- Breath of Sargeras
	[GetSpellInfo(1056)] = 1056, -- Slow Poison II
	[GetSpellInfo(19435)] = 19435, -- Mooncloth Boots
	[GetSpellInfo(2168)] = 2168, -- Dark Leather Cloak
	[GetSpellInfo(2738)] = 2738, -- Copper Axe
	[GetSpellInfo(26010)] = 26010, -- Summon Tranquil Mechanical Yeti
	[GetSpellInfo(16989)] = 16989, -- Planting Banner
	[GetSpellInfo(25298)] = 25298, -- Starfire
	[GetSpellInfo(8489)] = 8489, -- Red Swashbuckler's Shirt
	[GetSpellInfo(6412)] = 6412, -- Kaldorei Spider Kabob
	[GetSpellInfo(29333)] = 29333, -- Midsummer Sausage
	[GetSpellInfo(31)] = 31, -- Teleport Goldshire
	[GetSpellInfo(24421)] = 24421, -- Zandalar Signet of Mojo
	[GetSpellInfo(3774)] = 3774, -- Green Leather Belt
	[GetSpellInfo(3964)] = 3964, -- Deprecated BKP "Impact" Shot
	[GetSpellInfo(16992)] = 16992, -- Frostguard
	[GetSpellInfo(2392)] = 2392, -- Red Linen Shirt
	[GetSpellInfo(26055)] = 26055, -- Summon Yellow Qiraji Battle Tank
	[GetSpellInfo(4075)] = 4075, -- Large Seaforium Charge
	[GetSpellInfo(2660)] = 2660, -- Rough Sharpening Stone
	[GetSpellInfo(13628)] = 13628, -- Runed Golden Rod
	[GetSpellInfo(23192)] = 23192, -- Forming Rhok'delar
	[GetSpellInfo(3496)] = 3496, -- Moonsteel Broadsword
	[GetSpellInfo(6626)] = 6626, -- Set NG-5 Charge (Blue)
	[GetSpellInfo(7630)] = 7630, -- Blue Linen Vest
	[GetSpellInfo(19074)] = 19074, -- Frostsaber Leggings
	[GetSpellInfo(8690)] = 8690, -- Hearthstone
	[GetSpellInfo(26085)] = 26085, -- Soul Pouch
	[GetSpellInfo(19791)] = 19791, -- Thorium Widget
	[GetSpellInfo(27890)] = 27890, -- Clone
	[GetSpellInfo(3817)] = 3817, -- Cured Medium Hide
	[GetSpellInfo(16629)] = 16629, -- Attuned Dampener
	[GetSpellInfo(19075)] = 19075, -- Heavy Scorpid Leggings
	[GetSpellInfo(22313)] = 22313, -- Purple Hands
	[GetSpellInfo(474)] = 474, -- Fumble
	[GetSpellInfo(18421)] = 18421, -- Wizardweave Leggings
	[GetSpellInfo(23338)] = 23338, -- Swift Stormsaber
	[GetSpellInfo(24913)] = 24913, -- Darkrune Helm
	[GetSpellInfo(12073)] = 12073, -- Black Mageweave Boots
	[GetSpellInfo(17567)] = 17567, -- Summon Blood Parrot
	[GetSpellInfo(26277)] = 26277, -- Elixir of Greater Firepower
	[GetSpellInfo(1179)] = 1179, -- Beast Claws
	[GetSpellInfo(513)] = 513, -- Earth Elemental
	[GetSpellInfo(10709)] = 10709, -- Summon Prairie Dog
	[GetSpellInfo(4068)] = 4068, -- Iron Grenade
	[GetSpellInfo(10617)] = 10617, -- Release Rageclaw
	[GetSpellInfo(16662)] = 16662, -- Thorium Leggings
	[GetSpellInfo(9993)] = 9993, -- Heavy Mithril Axe
	[GetSpellInfo(10837)] = 10837, -- Goblin Land Mine
	[GetSpellInfo(23220)] = 23220, -- Swift Dawnsaber
	[GetSpellInfo(12589)] = 12589, -- Mithril Tube
	[GetSpellInfo(1453)] = 1453, -- Arcane Spirit V
	[GetSpellInfo(15649)] = 15649, -- Collect Corrupted Water
	[GetSpellInfo(7893)] = 7893, -- Stylish Green Shirt
	[GetSpellInfo(28732)] = 28732, -- Widow's Embrace
	[GetSpellInfo(443)] = 443, -- Teleport Barracks
	[GetSpellInfo(2835)] = 2835, -- Deadly Poison
	[GetSpellInfo(15865)] = 15865, -- Mystery Stew
	[GetSpellInfo(23666)] = 23666, -- Flarecore Robe
	[GetSpellInfo(507)] = 507, -- Fumble II
	[GetSpellInfo(20829)] = 20829, -- Arcane Bolt
	[GetSpellInfo(18241)] = 18241, -- Filet of Redgill
	[GetSpellInfo(18113)] = 18113, -- Manifestation Cleansing
	[GetSpellInfo(3449)] = 3449, -- Shadow Oil
	[GetSpellInfo(12092)] = 12092, -- Dreamweave Circlet
	[GetSpellInfo(3678)] = 3678, -- Focusing
	[GetSpellInfo(12346)] = 12346, -- Awaken the Soulflayer
	[GetSpellInfo(24266)] = 24266, -- Gurubashi Mojo Madness
	[GetSpellInfo(28324)] = 28324, -- Forming Frame of Atiesh
	[GetSpellInfo(28473)] = 28473, -- Bramblewood Boots
	[GetSpellInfo(17557)] = 17557, -- Elixir of Brute Force
	[GetSpellInfo(20874)] = 20874, -- Dark Iron Bracers
	[GetSpellInfo(16660)] = 16660, -- Dawnbringer Shoulders
	[GetSpellInfo(3859)] = 3859, -- Azure Silk Vest
	[GetSpellInfo(27589)] = 27589, -- Black Grasp of the Destroyer
	[GetSpellInfo(10701)] = 10701, -- Summon Dart Frog
	[GetSpellInfo(10849)] = 10849, -- Form of the Moonstalker (no invis)
	[GetSpellInfo(5206)] = 5206, -- Plant Seeds
	[GetSpellInfo(2387)] = 2387, -- Linen Cloak
	[GetSpellInfo(697)] = 697, -- Summon Voidwalker
	[GetSpellInfo(28461)] = 28461, -- Ironvine Breastplate
	[GetSpellInfo(12074)] = 12074, -- Black Mageweave Shoulders
	[GetSpellInfo(3206)] = 3206, -- Sol H
	[GetSpellInfo(19097)] = 19097, -- Devilsaur Leggings
	[GetSpellInfo(12260)] = 12260, -- Rough Copper Vest
	[GetSpellInfo(15463)] = 15463, -- Legendary Arcane Amalgamation
	[GetSpellInfo(11343)] = 11343, -- Instant Poison VI
	[GetSpellInfo(24896)] = 24896, -- Create Scepter of Beckoning: Air
	[GetSpellInfo(11017)] = 11017, -- Summon Witherbark Felhunter
	[GetSpellInfo(27241)] = 27241, -- Summon Gurky
	[GetSpellInfo(6703)] = 6703, -- Murloc Scale Breastplate
	[GetSpellInfo(7953)] = 7953, -- Deviate Scale Cloak
	[GetSpellInfo(3839)] = 3839, -- Bolt of Silk Cloth
	[GetSpellInfo(2333)] = 2333, -- Elixir of Lesser Agility
	[GetSpellInfo(20873)] = 20873, -- Fiery Chain Shoulders
	[GetSpellInfo(15303)] = 15303, -- DEBUG Create Samophlange Manual
	[GetSpellInfo(3429)] = 3429, -- Plague Mind
	[GetSpellInfo(10719)] = 10719, -- Summon Ribbon Snake
	[GetSpellInfo(2547)] = 2547, -- Redridge Goulash
	[GetSpellInfo(3953)] = 3953, -- Bronze Framework
	[GetSpellInfo(2837)] = 2837, -- Deadly Poison II
	[GetSpellInfo(19071)] = 19071, -- Wicked Leather Headband
	[GetSpellInfo(11419)] = 11419, -- Portal: Darnassus
	[GetSpellInfo(8617)] = 8617, -- Skinning
	[GetSpellInfo(17646)] = 17646, -- Summon Onyxia Whelp
	[GetSpellInfo(16647)] = 16647, -- Imperial Plate Belt
	[GetSpellInfo(26416)] = 26416, -- Small Blue Rocket
	[GetSpellInfo(11472)] = 11472, -- Elixir of Giants
	[GetSpellInfo(4979)] = 4979, -- Quick Flame Ward
	[GetSpellInfo(6753)] = 6753, -- Backhand
	[GetSpellInfo(4069)] = 4069, -- Big Iron Bomb
	[GetSpellInfo(12719)] = 12719, -- Explosive Arrow
	[GetSpellInfo(9437)] = 9437, -- Placing Bear Trap
	[GetSpellInfo(877)] = 877, -- Elemental Fury
	[GetSpellInfo(7928)] = 7928, -- Silk Bandage
	[GetSpellInfo(13982)] = 13982, -- Bael'Gar's Fiery Essence
	[GetSpellInfo(19101)] = 19101, -- Volcanic Shoulders
	[GetSpellInfo(9207)] = 9207, -- Dusky Boots
	[GetSpellInfo(26442)] = 26442, -- Firework Launcher
	[GetSpellInfo(25037)] = 25037, -- Rumsey Rum Light
	[GetSpellInfo(6648)] = 6648, -- Chestnut Mare
	[GetSpellInfo(6702)] = 6702, -- Murloc Scale Belt
	[GetSpellInfo(3493)] = 3493, -- Jade Serpentblade
	[GetSpellInfo(20897)] = 20897, -- Dark Iron Destroyer
	[GetSpellInfo(3659)] = 3659, -- Mage Sight
	[GetSpellInfo(20872)] = 20872, -- Fiery Chain Girdle
	[GetSpellInfo(3504)] = 3504, -- Green Iron Shoulders
	[GetSpellInfo(15033)] = 15033, -- Summon Ancient Spirits
	[GetSpellInfo(21066)] = 21066, -- Void Bolt
	[GetSpellInfo(19773)] = 19773, -- Elemental Fire
	[GetSpellInfo(28148)] = 28148, -- Portal: Karazhan
	[GetSpellInfo(3721)] = 3721, -- Teleport Altar of the Tides
	[GetSpellInfo(28891)] = 28891, -- Consecrated Weapon
	[GetSpellInfo(12068)] = 12068, -- Stormcloth Vest
	[GetSpellInfo(10013)] = 10013, -- Ebon Shiv
	[GetSpellInfo(24091)] = 24091, -- Bloodvine Vest
	[GetSpellInfo(4945)] = 4945, -- Summon Dagun
	[GetSpellInfo(5166)] = 5166, -- Harvest Silithid Egg
	[GetSpellInfo(20854)] = 20854, -- Molten Helm
	[GetSpellInfo(10525)] = 10525, -- Tough Scorpid Breastplate
	[GetSpellInfo(17015)] = 17015, -- Destroy Tent
	[GetSpellInfo(2675)] = 2675, -- Shining Silver Breastplate
	[GetSpellInfo(22906)] = 22906, -- Plunging Blade into Onyxia
	[GetSpellInfo(12259)] = 12259, -- Silvered Bronze Leggings
	[GetSpellInfo(17187)] = 17187, -- Transmute: Arcanite
	[GetSpellInfo(3172)] = 3172, -- Minor Magic Resistance Potion
	[GetSpellInfo(10005)] = 10005, -- Dazzling Mithril Rapier
	[GetSpellInfo(3930)] = 3930, -- Crafted Heavy Shot
	[GetSpellInfo(17561)] = 17561, -- Transmute: Earth to Water
	[GetSpellInfo(24903)] = 24903, -- Runed Stygian Boots
	[GetSpellInfo(5280)] = 5280, -- Razor Mane
	[GetSpellInfo(15712)] = 15712, -- Linken's Boomerang
	[GetSpellInfo(23486)] = 23486, -- Dimensional Ripper - Everlook
	[GetSpellInfo(11537)] = 11537, -- Charge Stave of Equinex
	[GetSpellInfo(20777)] = 20777, -- Ancestral Spirit
	[GetSpellInfo(10717)] = 10717, -- Summon Crimson Snake
	[GetSpellInfo(2163)] = 2163, -- White Leather Jerkin
	[GetSpellInfo(27588)] = 27588, -- Light Obsidian Belt
	[GetSpellInfo(8797)] = 8797, -- Earthen Silk Belt
	[GetSpellInfo(19047)] = 19047, -- Cured Rugged Hide
	[GetSpellInfo(3569)] = 3569, -- Smelt Steel
	[GetSpellInfo(8334)] = 8334, -- Practice Lock
	[GetSpellInfo(17166)] = 17166, -- Release Umi's Yeti
	[GetSpellInfo(7181)] = 7181, -- Greater Healing Potion
	[GetSpellInfo(8211)] = 8211, -- Chain Burn
	[GetSpellInfo(20752)] = 20752, -- Create Soulstone (Lesser)
	[GetSpellInfo(7487)] = 7487, -- Call Bleak Worg
	[GetSpellInfo(8600)] = 8600, -- Fevered Plague
	[GetSpellInfo(18244)] = 18244, -- Poached Sunscale Salmon
	[GetSpellInfo(26103)] = 26103, -- Sweep
	[GetSpellInfo(8398)] = 8398, -- Frostbolt Volley
	[GetSpellInfo(7837)] = 7837, -- Fire Oil
	[GetSpellInfo(8919)] = 8919, -- Fill Jennea's Flask
	[GetSpellInfo(20530)] = 20530, -- Bind Chapter 2
	[GetSpellInfo(13895)] = 13895, -- Summon Spawn of Bael'Gar
	[GetSpellInfo(4153)] = 4153, -- Guile of the Raptor
	[GetSpellInfo(11433)] = 11433, -- Death & Decay
	[GetSpellInfo(3776)] = 3776, -- Green Leather Bracers
	[GetSpellInfo(968)] = 968, -- Feral Spirit II
	[GetSpellInfo(22810)] = 22810, -- Opening - No Text
	[GetSpellInfo(3765)] = 3765, -- Dark Leather Gloves
	[GetSpellInfo(23453)] = 23453, -- Gnomish Transporter
	[GetSpellInfo(23339)] = 23339, -- Wing Buffet
	[GetSpellInfo(19774)] = 19774, -- Summon Ragnaros
	[GetSpellInfo(25849)] = 25849, -- Summon Baby Shark
	[GetSpellInfo(2662)] = 2662, -- Copper Chain Pants
	[GetSpellInfo(21943)] = 21943, -- Gloves of the Greatfather
	[GetSpellInfo(15114)] = 15114, -- Summon Illusionary Dreamwatchers
	[GetSpellInfo(24162)] = 24162, -- Falcon's Call
	[GetSpellInfo(3845)] = 3845, -- Soft-soled Linen Boots
	[GetSpellInfo(18809)] = 18809, -- Pyroblast
	[GetSpellInfo(9743)] = 9743, -- Delete Me
	[GetSpellInfo(555)] = 555, -- Feral Spirit
	[GetSpellInfo(3858)] = 3858, -- Shadow Hood
	[GetSpellInfo(66)] = 66, -- Lesser Invisibility
	[GetSpellInfo(9060)] = 9060, -- Light Leather Quiver
	[GetSpellInfo(11661)] = 11661, -- Shadow Bolt
	[GetSpellInfo(15292)] = 15292, -- Dark Iron Pulverizer
	[GetSpellInfo(3848)] = 3848, -- Double-stitched Woolen Shoulders
	[GetSpellInfo(3655)] = 3655, -- Summon Shield Guard
	[GetSpellInfo(5512)] = 5512, -- Fill Phial
	[GetSpellInfo(3856)] = 3856, -- Spider Silk Slippers
	[GetSpellInfo(24377)] = 24377, -- Destroy Bijou
	[GetSpellInfo(13229)] = 13229, -- Wound Poison III
	[GetSpellInfo(6250)] = 6250, -- Fire Cannon
	[GetSpellInfo(18446)] = 18446, -- Wizardweave Robe
	[GetSpellInfo(6257)] = 6257, -- Torch Toss
	[GetSpellInfo(3871)] = 3871, -- Formal White Shirt
	[GetSpellInfo(9614)] = 9614, -- Rift Beacon
	[GetSpellInfo(3952)] = 3952, -- Minor Recombobulator
	[GetSpellInfo(7951)] = 7951, -- Toxic Spit
	[GetSpellInfo(7967)] = 7967, -- Naralex's Nightmare
	[GetSpellInfo(28209)] = 28209, -- Glacial Wrists
	[GetSpellInfo(2368)] = 2368, -- Herb Gathering
	[GetSpellInfo(13608)] = 13608, -- Hooked Net
	[GetSpellInfo(7279)] = 7279, -- Black Sludge
	[GetSpellInfo(11654)] = 11654, -- Call of Sul'thraze
	[GetSpellInfo(22732)] = 22732, -- Major Rejuvenation Potion
	[GetSpellInfo(15748)] = 15748, -- Freeze Rookery Egg
	[GetSpellInfo(21100)] = 21100, -- Conjure Elegant Letter
	[GetSpellInfo(7155)] = 7155, -- CreatureSpecial
	[GetSpellInfo(2671)] = 2671, -- Rough Bronze Bracers
	[GetSpellInfo(22902)] = 22902, -- Mooncloth Robe
	[GetSpellInfo(1122)] = 1122, -- Inferno
	[GetSpellInfo(18974)] = 18974, -- Summon Lunaclaw
	[GetSpellInfo(10699)] = 10699, -- Summon Bronze Whelpling
	[GetSpellInfo(7918)] = 7918, -- Shoot Gun
	[GetSpellInfo(12667)] = 12667, -- Soul Consumption
	[GetSpellInfo(3873)] = 3873, -- Black Swashbuckler's Shirt
	[GetSpellInfo(8286)] = 8286, -- Summon Boar Spirit
	[GetSpellInfo(6517)] = 6517, -- Pearl-handled Dagger
	[GetSpellInfo(34)] = 34, -- Teleport Duskwood
	[GetSpellInfo(24964)] = 24964, -- Honor Points +378
	[GetSpellInfo(15549)] = 15549, -- Chained Bolt
	[GetSpellInfo(12614)] = 12614, -- Mithril Heavy-bore Rifle
	[GetSpellInfo(3319)] = 3319, -- Copper Chain Boots
	[GetSpellInfo(11458)] = 11458, -- Wildvine Potion
	[GetSpellInfo(10149)] = 10149, -- Fireball
	[GetSpellInfo(21047)] = 21047, -- Corrosive Acid Spit
	[GetSpellInfo(23140)] = 23140, -- J'eevee summons object
	[GetSpellInfo(21559)] = 21559, -- Shredder Armor Melt
	[GetSpellInfo(22909)] = 22909, -- Eye of Immol'thar
	[GetSpellInfo(8766)] = 8766, -- Azure Silk Belt
	[GetSpellInfo(24706)] = 24706, -- Toss Stink Bomb
	[GetSpellInfo(20693)] = 20693, -- Summon Lost Amulet
	[GetSpellInfo(20626)] = 20626, -- Undermine Clam Chowder
	[GetSpellInfo(23315)] = 23315, -- Ignite Flesh
	[GetSpellInfo(23530)] = 23530, -- Summon Tiny Red Dragon
	[GetSpellInfo(15972)] = 15972, -- Glinting Steel Dagger
	[GetSpellInfo(18402)] = 18402, -- Runecloth Belt
	[GetSpellInfo(17924)] = 17924, -- Soul Fire
	[GetSpellInfo(427)] = 427, -- Teleport Monastery
	[GetSpellInfo(20733)] = 20733, -- Black Arrow
	[GetSpellInfo(5269)] = 5269, -- Defias Disguise
	[GetSpellInfo(3371)] = 3371, -- Blood Sausage
	[GetSpellInfo(12897)] = 12897, -- Gnomish Goggles
	[GetSpellInfo(22599)] = 22599, -- Chromatic Mantle of the Dawn
	[GetSpellInfo(27725)] = 27725, -- Satchel of Cenarius
	[GetSpellInfo(3117)] = 3117, -- Heavy Weightstone
	[GetSpellInfo(12044)] = 12044, -- Simple Linen Pants
	[GetSpellInfo(21652)] = 21652, -- Closing
	[GetSpellInfo(3929)] = 3929, -- Coarse Blasting Powder
	[GetSpellInfo(24874)] = 24874, -- Create Crest of Beckoning: Fire
	[GetSpellInfo(8786)] = 8786, -- Azure Silk Cloak
	[GetSpellInfo(5514)] = 5514, -- Darken Vision
	[GetSpellInfo(2542)] = 2542, -- Goretusk Liver Pie
	[GetSpellInfo(28614)] = 28614, -- Pointy Spike
	[GetSpellInfo(20528)] = 20528, -- Mor'rogal Enchant
	[GetSpellInfo(12279)] = 12279, -- Curse of Blood
	[GetSpellInfo(23665)] = 23665, -- Argent Shoulders
	[GetSpellInfo(3851)] = 3851, -- Phoenix Pants
	[GetSpellInfo(3957)] = 3957, -- Ice Deflector
	[GetSpellInfo(19081)] = 19081, -- Chimeric Vest
	[GetSpellInfo(7259)] = 7259, -- Nature Protection Potion
	[GetSpellInfo(9744)] = 9744, -- Jarkal's Translation
	[GetSpellInfo(895)] = 895, -- Fire Elemental
	[GetSpellInfo(27830)] = 27830, -- Persuader
	[GetSpellInfo(31364)] = 31364, -- Spice Mortar
	[GetSpellInfo(24366)] = 24366, -- Greater Dreamless Sleep Potion
	[GetSpellInfo(4971)] = 4971, -- Healing Ward
	[GetSpellInfo(1124)] = 1124, -- Hellfire II
	[GetSpellInfo(24123)] = 24123, -- Primal Batskin Bracers
	[GetSpellInfo(14532)] = 14532, -- Creeper Venom
	[GetSpellInfo(16642)] = 16642, -- Thorium Armor
	[GetSpellInfo(19470)] = 19470, -- Gem of the Serpent
	[GetSpellInfo(7791)] = 7791, -- Teleport
	[GetSpellInfo(20876)] = 20876, -- Dark Iron Leggings
	[GetSpellInfo(22647)] = 22647, -- Empower Pet
	[GetSpellInfo(20436)] = 20436, -- Drunken Pit Crew
	[GetSpellInfo(17636)] = 17636, -- Flask of Distilled Wisdom
	[GetSpellInfo(24887)] = 24887, -- Create Crest of Beckoning: Earth
	[GetSpellInfo(982)] = 982, -- Revive Pet
	[GetSpellInfo(3718)] = 3718, -- Syndicate Bomb
	[GetSpellInfo(8142)] = 8142, -- Grasping Vines
	[GetSpellInfo(19103)] = 19103, -- Runic Leather Shoulders
	[GetSpellInfo(18434)] = 18434, -- Cindercloth Pants
	[GetSpellInfo(23231)] = 23231, -- Binding Volume I
	[GetSpellInfo(10873)] = 10873, -- Red Mechanostrider
	[GetSpellInfo(20875)] = 20875, -- Rumsey Rum
	[GetSpellInfo(18411)] = 18411, -- Frostweave Gloves
	[GetSpellInfo(6725)] = 6725, -- Flame Spike
	[GetSpellInfo(18410)] = 18410, -- Ghostweave Belt
	[GetSpellInfo(19084)] = 19084, -- Devilsaur Gauntlets
	[GetSpellInfo(10697)] = 10697, -- Summon Crimson Whelpling
	[GetSpellInfo(24264)] = 24264, -- Extinguish
	[GetSpellInfo(15057)] = 15057, -- Mechanical Patch Kit
	[GetSpellInfo(10686)] = 10686, -- Summon Prairie Chicken
	[GetSpellInfo(932)] = 932, -- Replenish Spirit II
	[GetSpellInfo(7841)] = 7841, -- Swim Speed Potion
	[GetSpellInfo(24189)] = 24189, -- Force Punch
	[GetSpellInfo(9064)] = 9064, -- Rugged Leather Pants
	[GetSpellInfo(8804)] = 8804, -- Crimson Silk Gloves
	[GetSpellInfo(10605)] = 10605, -- Chain Lightning
	[GetSpellInfo(4962)] = 4962, -- Encasing Webs
	[GetSpellInfo(4981)] = 4981, -- Inducing Vision
	[GetSpellInfo(12619)] = 12619, -- Hi-Explosive Bomb
	[GetSpellInfo(22562)] = 22562, -- Fill Amethyst Phial
	[GetSpellInfo(9146)] = 9146, -- Herbalist's Gloves
	[GetSpellInfo(7077)] = 7077, -- Simple Teleport
	[GetSpellInfo(18408)] = 18408, -- Cindercloth Vest
	[GetSpellInfo(15781)] = 15781, -- Steel Mechanostrider
	[GetSpellInfo(12087)] = 12087, -- Stormcloth Shoulders
	[GetSpellInfo(21923)] = 21923, -- Elixir of Frost Power
	[GetSpellInfo(7364)] = 7364, -- Light Torch
	[GetSpellInfo(5668)] = 5668, -- Peasant Disguise
	[GetSpellInfo(25314)] = 25314, -- Greater Heal
	[GetSpellInfo(9942)] = 9942, -- Mithril Scale Gloves
	[GetSpellInfo(2672)] = 2672, -- Patterned Bronze Bracers
	[GetSpellInfo(11477)] = 11477, -- Elixir of Demonslaying
	[GetSpellInfo(25159)] = 25159, -- Call Prismatic Barrier
	[GetSpellInfo(3947)] = 3947, -- Crafted Solid Shot
	[GetSpellInfo(2336)] = 2336, -- Elixir of Tongues
	[GetSpellInfo(2362)] = 2362, -- Create Spellstone
	[GetSpellInfo(24239)] = 24239, -- Hammer of Wrath
	[GetSpellInfo(2659)] = 2659, -- Smelt Bronze
	[GetSpellInfo(13899)] = 13899, -- Fire Storm
	[GetSpellInfo(25783)] = 25783, -- Place Arcanite Buoy
	[GetSpellInfo(24576)] = 24576, -- Chromatic Mount
	[GetSpellInfo(10706)] = 10706, -- Summon Hawk Owl
	[GetSpellInfo(28697)] = 28697, -- Forgiveness
	[GetSpellInfo(2601)] = 2601, -- Fire Shield III
	[GetSpellInfo(22718)] = 22718, -- Black War Kodo
	[GetSpellInfo(25841)] = 25841, -- Prayer of Elune
	[GetSpellInfo(16798)] = 16798, -- Enchanting Lullaby
	[GetSpellInfo(5265)] = 5265, -- Stonesplinter Trogg Disguise
	[GetSpellInfo(16596)] = 16596, -- Flames of Shahram
	[GetSpellInfo(20755)] = 20755, -- Create Soulstone
	[GetSpellInfo(8681)] = 8681, -- Instant Poison
	[GetSpellInfo(6693)] = 6693, -- Green Silk Pack
	[GetSpellInfo(28353)] = 28353, -- Raise Dead
	[GetSpellInfo(30021)] = 30021, -- Crystal Infused Bandage
	[GetSpellInfo(15293)] = 15293, -- Dark Iron Mail
	[GetSpellInfo(8809)] = 8809, -- Slave Drain
	[GetSpellInfo(3275)] = 3275, -- Linen Bandage
	[GetSpellInfo(28222)] = 28222, -- Icy Scale Breastplate
	[GetSpellInfo(28208)] = 28208, -- Glacial Cloak
	[GetSpellInfo(26011)] = 26011, -- Tranquil Mechanical Yeti
	[GetSpellInfo(4130)] = 4130, -- Banish Burning Exile
	[GetSpellInfo(2329)] = 2329, -- Elixir of Lion's Strength
	[GetSpellInfo(13478)] = 13478, -- Opening Relic Coffer
	[GetSpellInfo(13583)] = 13583, -- Curse of the Deadwood
	[GetSpellInfo(18571)] = 18571, -- Breath
	[GetSpellInfo(8090)] = 8090, -- Bright Baubles
	[GetSpellInfo(17505)] = 17505, -- Curse of Timmy
	[GetSpellInfo(9095)] = 9095, -- Cantation of Manifestation
	[GetSpellInfo(3950)] = 3950, -- Big Bronze Bomb
	[GetSpellInfo(3979)] = 3979, -- Accurate Scope
	[GetSpellInfo(23082)] = 23082, -- Ultra-Flash Shadow Reflector
	[GetSpellInfo(3651)] = 3651, -- Shield of Reflection
	[GetSpellInfo(20650)] = 20650, -- Thick Leather
	[GetSpellInfo(10675)] = 10675, -- Summon Maine Coon
	[GetSpellInfo(512)] = 512, -- Chains of Ice
	[GetSpellInfo(15869)] = 15869, -- Superior Healing Ward
	[GetSpellInfo(2403)] = 2403, -- Gray Woolen Robe
	[GetSpellInfo(5884)] = 5884, -- Banshee Curse
	[GetSpellInfo(2401)] = 2401, -- Woolen Boots
	[GetSpellInfo(12090)] = 12090, -- Stormcloth Boots
	[GetSpellInfo(3940)] = 3940, -- Shadow Goggles
	[GetSpellInfo(22813)] = 22813, -- Gordok Ogre Suit
	[GetSpellInfo(10685)] = 10685, -- Summon Ancona
	[GetSpellInfo(14125)] = 14125, -- Opening Secret Safe
	[GetSpellInfo(15933)] = 15933, -- Monster Omelet
	[GetSpellInfo(10451)] = 10451, -- Implosion
	[GetSpellInfo(23081)] = 23081, -- Hyper-Radiant Flame Reflector
	[GetSpellInfo(7355)] = 7355, -- Stuck
	[GetSpellInfo(24962)] = 24962, -- Honor Points +138
	[GetSpellInfo(12755)] = 12755, -- Goblin Bomb Dispenser
	[GetSpellInfo(2386)] = 2386, -- Linen Boots
	[GetSpellInfo(6814)] = 6814, -- Sludge Toxin
	[GetSpellInfo(4094)] = 4094, -- Barbecued Buzzard Wing
	[GetSpellInfo(11464)] = 11464, -- Invisibility Potion
	[GetSpellInfo(28462)] = 28462, -- Ironvine Gloves
	[GetSpellInfo(10850)] = 10850, -- Powerful Smelling Salts
	[GetSpellInfo(16664)] = 16664, -- Runic Plate Shoulders
	[GetSpellInfo(16978)] = 16978, -- Blazing Rapier
	[GetSpellInfo(16381)] = 16381, -- Summon Rockwing Gargoyles
	[GetSpellInfo(2153)] = 2153, -- Handstitched Leather Pants
	[GetSpellInfo(3421)] = 3421, -- Crippling Poison II
	[GetSpellInfo(25121)] = 25121, -- Wizard Oil
	[GetSpellInfo(7258)] = 7258, -- Frost Protection Potion
	[GetSpellInfo(18831)] = 18831, -- Conjure Lily Root
	[GetSpellInfo(6441)] = 6441, -- Explosive Shells
	[GetSpellInfo(24418)] = 24418, -- Heavy Crocolisk Stew
	[GetSpellInfo(855)] = 855, -- Feeblemind III
	[GetSpellInfo(3372)] = 3372, -- Murloc Fin Soup
	[GetSpellInfo(17560)] = 17560, -- Transmute: Fire to Earth
	[GetSpellInfo(10507)] = 10507, -- Nightscape Headband
	[GetSpellInfo(21097)] = 21097, -- Manastorm
	[GetSpellInfo(24890)] = 24890, -- Create Signet of Beckoning: Air
	[GetSpellInfo(9937)] = 9937, -- Mithril Scale Bracers
	[GetSpellInfo(10516)] = 10516, -- Nightscape Shoulders
	[GetSpellInfo(9987)] = 9987, -- Bronze Battle Axe
	[GetSpellInfo(21648)] = 21648, -- Call to Ivus
	[GetSpellInfo(11437)] = 11437, -- Opening Chest
	[GetSpellInfo(18457)] = 18457, -- Robe of the Archmage
	[GetSpellInfo(2396)] = 2396, -- Green Linen Shirt
	[GetSpellInfo(5669)] = 5669, -- Peon Disguise
	[GetSpellInfo(3333)] = 3333, -- Silvered Bronze Gauntlets
	[GetSpellInfo(2657)] = 2657, -- Smelt Copper
	[GetSpellInfo(22717)] = 22717, -- Black War Steed
	[GetSpellInfo(27871)] = 27871, -- Lightwell
	[GetSpellInfo(21154)] = 21154, -- Might of Ragnaros
	[GetSpellInfo(7949)] = 7949, -- Summon Viper
	[GetSpellInfo(18541)] = 18541, -- Ritual of Doom Effect
	[GetSpellInfo(18987)] = 18987, -- Create Relic Bundle
	[GetSpellInfo(12699)] = 12699, -- Summon Screecher Spirit
	[GetSpellInfo(5159)] = 5159, -- Melt Ore
	[GetSpellInfo(24160)] = 24160, -- Syncretist's Sigil
	[GetSpellInfo(19063)] = 19063, -- Chimeric Boots
	[GetSpellInfo(3109)] = 3109, -- Presence of Death
	[GetSpellInfo(5781)] = 5781, -- Threatening Growl
	[GetSpellInfo(28480)] = 28480, -- Sylvan Vest
	[GetSpellInfo(8780)] = 8780, -- Hands of Darkness
	[GetSpellInfo(3450)] = 3450, -- Elixir of Fortitude
	[GetSpellInfo(17462)] = 17462, -- Red Skeletal Horse
	[GetSpellInfo(24967)] = 24967, -- Gong
	[GetSpellInfo(33)] = 33, -- Teleport Westfall
	[GetSpellInfo(28304)] = 28304, -- Copy of Healing Wave
	[GetSpellInfo(3918)] = 3918, -- Rough Blasting Powder
	[GetSpellInfo(9995)] = 9995, -- Blue Glittering Axe
	[GetSpellInfo(21180)] = 21180, -- Summon Thunderstrike
	[GetSpellInfo(25954)] = 25954, -- Sagefish Delight
	[GetSpellInfo(23531)] = 23531, -- Summon Tiny Green Dragon
	[GetSpellInfo(19054)] = 19054, -- Red Dragonscale Breastplate
	[GetSpellInfo(16153)] = 16153, -- Smelt Thorium
	[GetSpellInfo(6624)] = 6624, -- Free Action Potion
	[GetSpellInfo(10680)] = 10680, -- Summon Cockatiel
	[GetSpellInfo(27660)] = 27660, -- Big Bag of Enchantment
	[GetSpellInfo(17496)] = 17496, -- Crest of Retribution
	[GetSpellInfo(9979)] = 9979, -- Ornate Mithril Boots
	[GetSpellInfo(13912)] = 13912, -- Princess Summons Portal
	[GetSpellInfo(2831)] = 2831, -- Armor +8
	[GetSpellInfo(9065)] = 9065, -- Light Leather Bracers
	[GetSpellInfo(2670)] = 2670, -- Rough Bronze Cuirass
	[GetSpellInfo(24139)] = 24139, -- Darksoul Breastplate
	[GetSpellInfo(2539)] = 2539, -- Spiced Wolf Meat
	[GetSpellInfo(5316)] = 5316, -- Raptor Feather
	[GetSpellInfo(25150)] = 25150, -- Molten Rain
	[GetSpellInfo(24654)] = 24654, -- Blue Dragonscale Leggings
	[GetSpellInfo(24121)] = 24121, -- Primal Batskin Jerkin
	[GetSpellInfo(4221)] = 4221, -- Healing Tongue II
	[GetSpellInfo(3959)] = 3959, -- Discombobulator Ray
	[GetSpellInfo(19250)] = 19250, -- Placing Smokey's Explosives
	[GetSpellInfo(18417)] = 18417, -- Runecloth Gloves
	[GetSpellInfo(20702)] = 20702, -- Summon Treant Allies
	[GetSpellInfo(4062)] = 4062, -- Heavy Dynamite
	[GetSpellInfo(26428)] = 26428, -- Large Red Rocket Cluster
	[GetSpellInfo(20274)] = 20274, -- Capturing Termites
	[GetSpellInfo(11975)] = 11975, -- Arcane Explosion
	[GetSpellInfo(11438)] = 11438, -- Join Map Fragments
	[GetSpellInfo(3205)] = 3205, -- Sol M
	[GetSpellInfo(23392)] = 23392, -- Boulder
	[GetSpellInfo(16554)] = 16554, -- Toxic Bolt
	[GetSpellInfo(6518)] = 6518, -- Iridescent Hammer
	[GetSpellInfo(23662)] = 23662, -- Wisdom of the Timbermaw
	[GetSpellInfo(3511)] = 3511, -- Golden Scale Cuirass
	[GetSpellInfo(18647)] = 18647, -- Banish
	[GetSpellInfo(10007)] = 10007, -- Phantom Blade
	[GetSpellInfo(21939)] = 21939, -- Create Scepter of Celebras
	[GetSpellInfo(23667)] = 23667, -- Flarecore Leggings
	[GetSpellInfo(10558)] = 10558, -- Nightscape Boots
	[GetSpellInfo(10619)] = 10619, -- Dragonscale Gauntlets
	[GetSpellInfo(24163)] = 24163, -- Vodouisant's Vigilant Embrace
	[GetSpellInfo(10166)] = 10166, -- Khadgar's Unlocking
	[GetSpellInfo(8593)] = 8593, -- Symbol of Life
	[GetSpellInfo(7153)] = 7153, -- Guardian Cloak
	[GetSpellInfo(17181)] = 17181, -- Enchanted Leather
	[GetSpellInfo(22927)] = 22927, -- Hide of the Wild
	[GetSpellInfo(8243)] = 8243, -- Flash Bomb
	[GetSpellInfo(4097)] = 4097, -- Raptor Hide Belt
	[GetSpellInfo(24367)] = 24367, -- Living Action Potion
	[GetSpellInfo(12621)] = 12621, -- Mithril Gyro-Shot
	[GetSpellInfo(25839)] = 25839, -- Mass Healing
	[GetSpellInfo(23125)] = 23125, -- Orcish Orphan Whistle
	[GetSpellInfo(10715)] = 10715, -- Summon Blue Racer
	[GetSpellInfo(16613)] = 16613, -- Displacing Temporal Rift
	[GetSpellInfo(2548)] = 2548, -- Succulent Pork Ribs
	[GetSpellInfo(5161)] = 5161, -- Revive Dig Rat
	[GetSpellInfo(16502)] = 16502, -- Release Winna's Kitten
	[GetSpellInfo(785)] = 785, -- True Fulfillment
	[GetSpellInfo(16990)] = 16990, -- Arcanite Champion
	[GetSpellInfo(25292)] = 25292, -- Holy Light
	[GetSpellInfo(27552)] = 27552, -- Cupid's Arrow
	[GetSpellInfo(10396)] = 10396, -- Healing Wave
	[GetSpellInfo(9143)] = 9143, -- Bomb
	[GetSpellInfo(9269)] = 9269, -- Gnomish Universal Remote
	[GetSpellInfo(9900)] = 9900, -- Sharpen Blade IV
	[GetSpellInfo(8770)] = 8770, -- Robe of Power
	[GetSpellInfo(7488)] = 7488, -- Call Slavering Worg
	[GetSpellInfo(26234)] = 26234, -- Submerge Visual
	[GetSpellInfo(18405)] = 18405, -- Runecloth Bag
	[GetSpellInfo(12189)] = 12189, -- Summon Echeyakee
	[GetSpellInfo(6529)] = 6529, -- Opening Benedict's Chest
	[GetSpellInfo(17618)] = 17618, -- Summon Risen Lackey
	[GetSpellInfo(29334)] = 29334, -- Toasted Smorc
	[GetSpellInfo(12077)] = 12077, -- Simple Black Dress
	[GetSpellInfo(16984)] = 16984, -- Volcanic Hammer
	[GetSpellInfo(16967)] = 16967, -- Inlaid Thorium Hammer
	[GetSpellInfo(23675)] = 23675, -- Minigun
	[GetSpellInfo(16590)] = 16590, -- Summon Zombie
	[GetSpellInfo(11605)] = 11605, -- Slam
	[GetSpellInfo(17680)] = 17680, -- Spirit Spawn-out
	[GetSpellInfo(24846)] = 24846, -- Spitfire Bracers
	[GetSpellInfo(14227)] = 14227, -- Signing
	[GetSpellInfo(10346)] = 10346, -- Machine Gun
	[GetSpellInfo(19091)] = 19091, -- Runic Leather Pants
	[GetSpellInfo(6278)] = 6278, -- Creeping Mold
	[GetSpellInfo(24891)] = 24891, -- Create Signet of Beckoning: Earth
	[GetSpellInfo(3842)] = 3842, -- Handstitched Linen Britches
	[GetSpellInfo(23650)] = 23650, -- Ebon Hand
	[GetSpellInfo(7098)] = 7098, -- Curse of Mending
	[GetSpellInfo(28205)] = 28205, -- Glacial Gloves
	[GetSpellInfo(24122)] = 24122, -- Primal Batskin Gloves
	[GetSpellInfo(3233)] = 3233, -- Evil Eye
	[GetSpellInfo(24140)] = 24140, -- Darksoul Leggings
	[GetSpellInfo(17551)] = 17551, -- Stonescale Oil
	[GetSpellInfo(18969)] = 18969, -- Taelan Death
	[GetSpellInfo(10560)] = 10560, -- Big Voodoo Pants
	[GetSpellInfo(3436)] = 3436, -- Wandering Plague
	[GetSpellInfo(16869)] = 16869, -- Ice Tomb
	[GetSpellInfo(12716)] = 12716, -- Goblin Mortar
	[GetSpellInfo(10674)] = 10674, -- Summon Cornish Rex
	[GetSpellInfo(26279)] = 26279, -- Stormshroud Gloves
	[GetSpellInfo(15647)] = 15647, -- Summon Common Kitten
	[GetSpellInfo(21945)] = 21945, -- Green Holiday Shirt
	[GetSpellInfo(19788)] = 19788, -- Dense Blasting Powder
	[GetSpellInfo(12599)] = 12599, -- Mithril Casing
	[GetSpellInfo(7892)] = 7892, -- Stylish Blue Shirt
	[GetSpellInfo(2737)] = 2737, -- Copper Mace
	[GetSpellInfo(24314)] = 24314, -- Threatening Gaze
	[GetSpellInfo(8912)] = 8912, -- Forge Verigan's Fist
	[GetSpellInfo(26299)] = 26299, -- Create Cluster Rocket Launcher
	[GetSpellInfo(14887)] = 14887, -- Shadow Bolt Volley
	[GetSpellInfo(455)] = 455, -- Replenish Spirit
	[GetSpellInfo(25659)] = 25659, -- Dirge's Kickin' Chimaerok Chops
	[GetSpellInfo(24940)] = 24940, -- Black Whelp Tunic
	[GetSpellInfo(11534)] = 11534, -- Leper Cure!
	[GetSpellInfo(19067)] = 19067, -- Stormshroud Pants
	[GetSpellInfo(9921)] = 9921, -- Solid Weightstone
	[GetSpellInfo(18401)] = 18401, -- Bolt of Runecloth
	[GetSpellInfo(5395)] = 5395, -- Death Capsule
	[GetSpellInfo(16729)] = 16729, -- Lionheart Helm
	[GetSpellInfo(25722)] = 25722, -- Rumsey Rum Dark
	[GetSpellInfo(9457)] = 9457, -- Tharnariun's Heal
	[GetSpellInfo(17952)] = 17952, -- Create Firestone (Greater)
	[GetSpellInfo(445)] = 445, -- Teleport Darkshire
	[GetSpellInfo(7257)] = 7257, -- Fire Protection Potion
	[GetSpellInfo(17950)] = 17950, -- Shadow Portal
	[GetSpellInfo(10570)] = 10570, -- Tough Scorpid Helm
	[GetSpellInfo(6115)] = 6115, -- Far Sight (PT)
	[GetSpellInfo(6894)] = 6894, -- Death Bed
	[GetSpellInfo(14380)] = 14380, -- Truesilver Rod
	[GetSpellInfo(6252)] = 6252, -- Southsea Cannon Fire
	[GetSpellInfo(3121)] = 3121, -- Kev
	[GetSpellInfo(17465)] = 17465, -- Green Skeletal Warhorse
	[GetSpellInfo(7992)] = 7992, -- Slowing Poison
	[GetSpellInfo(12151)] = 12151, -- Summon Atal'ai Skeleton
	[GetSpellInfo(2162)] = 2162, -- Embossed Leather Cloak
	[GetSpellInfo(24124)] = 24124, -- Blood Tiger Breastplate
	[GetSpellInfo(8682)] = 8682, -- Fake Shot
	[GetSpellInfo(10546)] = 10546, -- Wild Leather Helmet
	[GetSpellInfo(23151)] = 23151, -- Balance of Light and Shadow
	[GetSpellInfo(10216)] = 10216, -- Flamestrike
	[GetSpellInfo(27608)] = 27608, -- Flash Heal
	[GetSpellInfo(17169)] = 17169, -- Summon Carrion Scarab
	[GetSpellInfo(8277)] = 8277, -- Voodoo Hex
	[GetSpellInfo(134)] = 134, -- Fire Shield
	[GetSpellInfo(14379)] = 14379, -- Golden Rod
	[GetSpellInfo(5137)] = 5137, -- Call of the Grave
	[GetSpellInfo(22761)] = 22761, -- Runn Tum Tuber Surprise
	[GetSpellInfo(23636)] = 23636, -- Dark Iron Helm
	[GetSpellInfo(19943)] = 19943, -- Flash of Light
	[GetSpellInfo(18702)] = 18702, -- Curse of the Darkmaster
	[GetSpellInfo(26425)] = 26425, -- Red Rocket Cluster
	[GetSpellInfo(16531)] = 16531, -- Summon Frail Skeleton
	[GetSpellInfo(9814)] = 9814, -- Barbaric Iron Helm
	[GetSpellInfo(16663)] = 16663, -- Imperial Plate Chest
	[GetSpellInfo(3297)] = 3297, -- Mighty Iron Hammer
	[GetSpellInfo(17231)] = 17231, -- Summon Illusory Wraith
	[GetSpellInfo(18424)] = 18424, -- Frostweave Pants
	[GetSpellInfo(3321)] = 3321, -- Copper Chain Vest
	[GetSpellInfo(6692)] = 6692, -- Robes of Arcana
	[GetSpellInfo(12061)] = 12061, -- Orange Mageweave Shirt
	[GetSpellInfo(17570)] = 17570, -- Greater Stoneshield Potion
	[GetSpellInfo(4239)] = 4239, -- Activating Defenses
	[GetSpellInfo(25004)] = 25004, -- Throw Nightmare Object
	[GetSpellInfo(11420)] = 11420, -- Portal: Thunder Bluff
	[GetSpellInfo(23067)] = 23067, -- Blue Firework
	[GetSpellInfo(19072)] = 19072, -- Runic Leather Belt
	[GetSpellInfo(17820)] = 17820, -- Veil of Shadow
	[GetSpellInfo(8322)] = 8322, -- Moonglow Vest
	[GetSpellInfo(18404)] = 18404, -- Frostweave Robe
	[GetSpellInfo(10459)] = 10459, -- Sacrifice Spinneret
	[GetSpellInfo(25316)] = 25316, -- Prayer of Healing
	[GetSpellInfo(6957)] = 6957, -- Frostmane Strength
	[GetSpellInfo(6897)] = 6897, -- Blue Ram
	[GetSpellInfo(3941)] = 3941, -- Small Bronze Bomb
	[GetSpellInfo(16168)] = 16168, -- Flame Buffet
	[GetSpellInfo(9636)] = 9636, -- Summon Swamp Spirit
	[GetSpellInfo(6695)] = 6695, -- Black Silk Pack
	[GetSpellInfo(12620)] = 12620, -- Sniper Scope
	[GetSpellInfo(21425)] = 21425, -- Ryson's Eye in the Sky
	[GetSpellInfo(12624)] = 12624, -- Mithril Mechanical Dragonling
	[GetSpellInfo(27662)] = 27662, -- Throw Cupid's Dart
	[GetSpellInfo(9513)] = 9513, -- Thistle Tea
	[GetSpellInfo(19800)] = 19800, -- Thorium Shells
	[GetSpellInfo(9985)] = 9985, -- Bronze Warhammer
	[GetSpellInfo(23680)] = 23680, -- Portals Deck
	[GetSpellInfo(28220)] = 28220, -- Polar Gloves
	[GetSpellInfo(3969)] = 3969, -- Mechanical Dragonling
	[GetSpellInfo(17574)] = 17574, -- Greater Fire Protection Potion
	[GetSpellInfo(16994)] = 16994, -- Arcanite Reaper
	[GetSpellInfo(7149)] = 7149, -- Barbaric Leggings
	[GetSpellInfo(16597)] = 16597, -- Curse of Shahram
	[GetSpellInfo(3561)] = 3561, -- Teleport: Stormwind
	[GetSpellInfo(7623)] = 7623, -- Brown Linen Robe
	[GetSpellInfo(23243)] = 23243, -- Swift Orange Raptor
	[GetSpellInfo(17527)] = 17527, -- Mighty Rage Potion
	[GetSpellInfo(6620)] = 6620, -- Place Toxic Fogger
	[GetSpellInfo(2546)] = 2546, -- Dry Pork Ribs
	[GetSpellInfo(11480)] = 11480, -- Transmute: Mithril to Truesilver
	[GetSpellInfo(19814)] = 19814, -- Masterwork Target Dummy
	[GetSpellInfo(8793)] = 8793, -- Crimson Silk Shoulders
	[GetSpellInfo(10344)] = 10344, -- Armor +32
	[GetSpellInfo(12046)] = 12046, -- Simple Kilt
	[GetSpellInfo(16639)] = 16639, -- Dense Grinding Stone
	[GetSpellInfo(9268)] = 9268, -- Teleport to Darnassus - Event
	[GetSpellInfo(29116)] = 29116, -- Toast Smorc
	[GetSpellInfo(16742)] = 16742, -- Enchanted Thorium Helm
	[GetSpellInfo(26063)] = 26063, -- Ouro Submerge Visual
	[GetSpellInfo(21161)] = 21161, -- Sulfuron Hammer
	[GetSpellInfo(11451)] = 11451, -- Oil of Immolation
	[GetSpellInfo(19830)] = 19830, -- Arcanite Dragonling
	[GetSpellInfo(3332)] = 3332, -- Slow Poison
	[GetSpellInfo(17553)] = 17553, -- Superior Mana Potion
	[GetSpellInfo(3954)] = 3954, -- Moonsight Rifle
	[GetSpellInfo(3767)] = 3767, -- Hillman's Belt
	[GetSpellInfo(9196)] = 9196, -- Dusky Leather Armor
	[GetSpellInfo(20568)] = 20568, -- Ragnaros Emerge
	[GetSpellInfo(18453)] = 18453, -- Felcloth Shoulders
	[GetSpellInfo(15296)] = 15296, -- Dark Iron Plate
	[GetSpellInfo(7935)] = 7935, -- Strong Anti-Venom
	[GetSpellInfo(16980)] = 16980, -- Rune Edge
	[GetSpellInfo(10096)] = 10096, -- Shrink
	[GetSpellInfo(18559)] = 18559, -- Demon Pick
	[GetSpellInfo(7761)] = 7761, -- Shared Bonds
	[GetSpellInfo(23000)] = 23000, -- Ez-Thro Dynamite
	[GetSpellInfo(18450)] = 18450, -- Wizardweave Turban
	[GetSpellInfo(3204)] = 3204, -- Sapper Explode
	[GetSpellInfo(9783)] = 9783, -- Mithril Spurs
	[GetSpellInfo(9194)] = 9194, -- Heavy Leather Ammo Pouch
	[GetSpellInfo(3961)] = 3961, -- Gyrochronatom
	[GetSpellInfo(8532)] = 8532, -- Aquadynamic Fish Lens
	[GetSpellInfo(7994)] = 7994, -- Nullify Mana
	[GetSpellInfo(8001)] = 8001, -- Placing Pendant
	[GetSpellInfo(8352)] = 8352, -- Adjust Attitude
	[GetSpellInfo(12064)] = 12064, -- Orange Martial Shirt
	[GetSpellInfo(7395)] = 7395, -- Deadmines Dynamite
	[GetSpellInfo(16731)] = 16731, -- Runic Breastplate
	[GetSpellInfo(3363)] = 3363, -- Summon Riding Gryphon
	[GetSpellInfo(12421)] = 12421, -- Mithril Frag Bomb
	[GetSpellInfo(16960)] = 16960, -- Thorium Greatsword
	[GetSpellInfo(22661)] = 22661, -- Enervate
	[GetSpellInfo(10702)] = 10702, -- Summon Island Frog
	[GetSpellInfo(11760)] = 11760, -- Hyena Sample
	[GetSpellInfo(12808)] = 12808, -- Getting Tide Pool Sample #4
	[GetSpellInfo(30081)] = 30081, -- Retching Plague
	[GetSpellInfo(11410)] = 11410, -- Whirling Barrage
	[GetSpellInfo(28463)] = 28463, -- Ironvine Belt
	[GetSpellInfo(3505)] = 3505, -- Golden Scale Shoulders
	[GetSpellInfo(21537)] = 21537, -- Planting Ryson's Beacon
	[GetSpellInfo(12607)] = 12607, -- Catseye Ultra Goggles
	[GetSpellInfo(22795)] = 22795, -- Core Marksman Rifle
	[GetSpellInfo(6310)] = 6310, -- Divining Scroll Spell
	[GetSpellInfo(11730)] = 11730, -- Create Healthstone (Major)
	[GetSpellInfo(3563)] = 3563, -- Teleport: Undercity
	[GetSpellInfo(23246)] = 23246, -- Purple Skeletal Warhorse
	[GetSpellInfo(18455)] = 18455, -- Bottomless Bag
	[GetSpellInfo(7821)] = 7821, -- Transform Victim
	[GetSpellInfo(11513)] = 11513, -- Empty Phial
	[GetSpellInfo(3915)] = 3915, -- Brown Linen Shirt
	[GetSpellInfo(2602)] = 2602, -- Fire Shield IV
	[GetSpellInfo(6418)] = 6418, -- Crispy Lizard Tail
	[GetSpellInfo(15495)] = 15495, -- Explosive Shot
	[GetSpellInfo(3296)] = 3296, -- Heavy Bronze Mace
	[GetSpellInfo(6535)] = 6535, -- Lightning Cloud
	[GetSpellInfo(29480)] = 29480, -- Fortitude of the Scourge
	[GetSpellInfo(12049)] = 12049, -- Black Mageweave Leggings
	[GetSpellInfo(26167)] = 26167, -- Colossal Smash
	[GetSpellInfo(9058)] = 9058, -- Handstitched Leather Cloak
	[GetSpellInfo(3753)] = 3753, -- Handstitched Leather Belt
	[GetSpellInfo(20737)] = 20737, -- Summon Karang's Banner
	[GetSpellInfo(24960)] = 24960, -- Honor Points +50
	[GetSpellInfo(2673)] = 2673, -- Silvered Bronze Breastplate
	[GetSpellInfo(6354)] = 6354, -- Venom's Bane
	[GetSpellInfo(21953)] = 21953, -- The Feast of Winter Veil
	[GetSpellInfo(22790)] = 22790, -- Kreeg's Stout Beatdown
	[GetSpellInfo(9916)] = 9916, -- Steel Breastplate
	[GetSpellInfo(8901)] = 8901, -- Gas Bomb
	[GetSpellInfo(9059)] = 9059, -- Handstitched Leather Bracers
	[GetSpellInfo(16069)] = 16069, -- Nefarius Attack 001
	[GetSpellInfo(15628)] = 15628, -- Pet Bombling
	[GetSpellInfo(26381)] = 26381, -- Burrow
	[GetSpellInfo(22721)] = 22721, -- Black War Raptor
	[GetSpellInfo(16995)] = 16995, -- Heartseeker
	[GetSpellInfo(9935)] = 9935, -- Steel Plate Helm
	[GetSpellInfo(27794)] = 27794, -- Cleave
	[GetSpellInfo(2389)] = 2389, -- Red Linen Robe
	[GetSpellInfo(23489)] = 23489, -- Ultrasafe Transporter - Gadgetzan
	[GetSpellInfo(9795)] = 9795, -- Talvash's Necklace Repair
	[GetSpellInfo(21403)] = 21403, -- Ryson's All Seeing Eye
	[GetSpellInfo(12086)] = 12086, -- Shadoweave Mask
	[GetSpellInfo(23061)] = 23061, -- Fix Ritual Node
	[GetSpellInfo(28474)] = 28474, -- Bramblewood Belt
	[GetSpellInfo(16643)] = 16643, -- Thorium Belt
	[GetSpellInfo(24897)] = 24897, -- Create Scepter of Beckoning: Earth
	[GetSpellInfo(22922)] = 22922, -- Mongoose Boots
	[GetSpellInfo(1090)] = 1090, -- Sleep
	[GetSpellInfo(9145)] = 9145, -- Fletcher's Gloves
	[GetSpellInfo(10531)] = 10531, -- Big Voodoo Mask
	[GetSpellInfo(6199)] = 6199, -- Nostalgia
	[GetSpellInfo(19068)] = 19068, -- Warbear Harness
	[GetSpellInfo(25793)] = 25793, -- Demon Summoning Torch
	[GetSpellInfo(7057)] = 7057, -- Haunting Spirits
	[GetSpellInfo(7489)] = 7489, -- Call Lupine Horror
	[GetSpellInfo(15207)] = 15207, -- Lightning Bolt
	[GetSpellInfo(22594)] = 22594, -- Frost Mantle of the Dawn
	[GetSpellInfo(23042)] = 23042, -- Call Benediction
	[GetSpellInfo(16659)] = 16659, -- Radiant Circlet
	[GetSpellInfo(15906)] = 15906, -- Dragonbreath Chili
	[GetSpellInfo(10544)] = 10544, -- Wild Leather Vest
	[GetSpellInfo(24961)] = 24961, -- Honor Points +82
	[GetSpellInfo(9220)] = 9220, -- "Plucky" Resumes Chicken Form
	[GetSpellInfo(24258)] = 24258, -- Quest - Troll Hero Summon Visual
	[GetSpellInfo(2667)] = 2667, -- Runed Copper Breastplate
	[GetSpellInfo(25311)] = 25311, -- Corruption
	[GetSpellInfo(26137)] = 26137, -- Rotate Trigger
	[GetSpellInfo(8772)] = 8772, -- Crimson Silk Belt
	[GetSpellInfo(19098)] = 19098, -- Wicked Leather Armor
	[GetSpellInfo(14810)] = 14810, -- Greater Mystic Wand
	[GetSpellInfo(15118)] = 15118, -- Place Threshadon Carcass
	[GetSpellInfo(23069)] = 23069, -- EZ-Thro Dynamite II
	[GetSpellInfo(7633)] = 7633, -- Blue Linen Robe
	[GetSpellInfo(10718)] = 10718, -- Summon Green Water Snake
	[GetSpellInfo(19076)] = 19076, -- Volcanic Breastplate
	[GetSpellInfo(19089)] = 19089, -- Blue Dragonscale Shoulders
	[GetSpellInfo(26421)] = 26421, -- Large Green Rocket
	[GetSpellInfo(11449)] = 11449, -- Elixir of Agility
	[GetSpellInfo(20648)] = 20648, -- Medium Leather
	[GetSpellInfo(23811)] = 23811, -- Summon Jubling
	[GetSpellInfo(25719)] = 25719, -- Bind Draconic For Dummies
	[GetSpellInfo(8604)] = 8604, -- Herb Baked Egg
	[GetSpellInfo(28354)] = 28354, -- Exorcise Atiesh
	[GetSpellInfo(21358)] = 21358, -- Aqual Quintessence - Dowse Molten Core Rune
	[GetSpellInfo(12717)] = 12717, -- Goblin Mining Helmet
	[GetSpellInfo(1540)] = 1540, -- Volley
	[GetSpellInfo(2674)] = 2674, -- Heavy Sharpening Stone
	[GetSpellInfo(2832)] = 2832, -- Armor +16
	[GetSpellInfo(3932)] = 3932, -- Target Dummy
	[GetSpellInfo(24357)] = 24357, -- Bloodvine Lens
	[GetSpellInfo(18245)] = 18245, -- Lobster Stew
	[GetSpellInfo(9172)] = 9172, -- Lift Seal
	[GetSpellInfo(7639)] = 7639, -- Blue Overalls
	[GetSpellInfo(22724)] = 22724, -- Black War Wolf
	[GetSpellInfo(23428)] = 23428, -- Summon Albino Snapjaw
	[GetSpellInfo(3937)] = 3937, -- Large Copper Bomb
	[GetSpellInfo(21371)] = 21371, -- Planting Mulverick's Beacon
	[GetSpellInfo(15855)] = 15855, -- Roast Raptor
	[GetSpellInfo(26298)] = 26298, -- Create Firework Rocket Launcher
	[GetSpellInfo(20006)] = 20006, -- Unholy Curse
	[GetSpellInfo(2169)] = 2169, -- Dark Leather Tunic
	[GetSpellInfo(19086)] = 19086, -- Ironfeather Breastplate
	[GetSpellInfo(7106)] = 7106, -- Dark Restore
	[GetSpellInfo(16646)] = 16646, -- Imperial Plate Shoulders
	[GetSpellInfo(29059)] = 29059, -- Skeletal Steed
	[GetSpellInfo(18412)] = 18412, -- Cindercloth Gloves
	[GetSpellInfo(18441)] = 18441, -- Ghostweave Pants
	[GetSpellInfo(8552)] = 8552, -- Curse of Weakness
	[GetSpellInfo(7795)] = 7795, -- Runed Silver Rod
	[GetSpellInfo(9157)] = 9157, -- Create Mage's Robe
	[GetSpellInfo(18438)] = 18438, -- Runecloth Pants
	[GetSpellInfo(3773)] = 3773, -- Guardian Armor
	[GetSpellInfo(3965)] = 3965, -- Advanced Target Dummy
	[GetSpellInfo(3922)] = 3922, -- Handful of Copper Bolts
	[GetSpellInfo(9980)] = 9980, -- Ornate Mithril Helm
	[GetSpellInfo(18247)] = 18247, -- Baked Salmon
	[GetSpellInfo(15935)] = 15935, -- Crispy Bat Wing
	[GetSpellInfo(3650)] = 3650, -- Sling Mud
	[GetSpellInfo(12594)] = 12594, -- Fire Goggles
	[GetSpellInfo(1096)] = 1096, -- Firebolt IV
	[GetSpellInfo(9092)] = 9092, -- Flesh Eating Worm
	[GetSpellInfo(6270)] = 6270, -- Serpentine Cleansing
	[GetSpellInfo(3770)] = 3770, -- Toughened Leather Gloves
	[GetSpellInfo(15633)] = 15633, -- Lil' Smoky
	[GetSpellInfo(11450)] = 11450, -- Elixir of Greater Defense
	[GetSpellInfo(18375)] = 18375, -- Aynasha's Arrow
	[GetSpellInfo(3850)] = 3850, -- Heavy Woolen Pants
	[GetSpellInfo(11397)] = 11397, -- Diseased Shot
	[GetSpellInfo(28223)] = 28223, -- Icy Scale Gauntlets
	[GetSpellInfo(11461)] = 11461, -- Arcane Elixir
	[GetSpellInfo(23238)] = 23238, -- Swift Brown Ram
	[GetSpellInfo(7955)] = 7955, -- Deviate Scale Belt
	[GetSpellInfo(12069)] = 12069, -- Cindercloth Robe
	[GetSpellInfo(19064)] = 19064, -- Heavy Scorpid Gauntlets
	[GetSpellInfo(22926)] = 22926, -- Chromatic Cloak
	[GetSpellInfo(4132)] = 4132, -- Banish Thundering Exile
	[GetSpellInfo(6458)] = 6458, -- Ornate Spyglass
	[GetSpellInfo(25158)] = 25158, -- Time Stop
	[GetSpellInfo(7954)] = 7954, -- Deviate Scale Gloves
	[GetSpellInfo(11457)] = 11457, -- Superior Healing Potion
	[GetSpellInfo(8774)] = 8774, -- Green Silken Shoulders
	[GetSpellInfo(9079)] = 9079, -- Create Rift
	[GetSpellInfo(28487)] = 28487, -- Summon Terky
	[GetSpellInfo(14891)] = 14891, -- Smelt Dark Iron
	[GetSpellInfo(26134)] = 26134, -- Eye Beam
	[GetSpellInfo(12564)] = 12564, -- Summon Treasure Horde Visual
	[GetSpellInfo(19080)] = 19080, -- Warbear Woolies
	[GetSpellInfo(16)] = 16, -- Fear (NYI)
	[GetSpellInfo(23431)] = 23431, -- Summon Leatherback Snapjaw
	[GetSpellInfo(19720)] = 19720, -- Combine Pendants
	[GetSpellInfo(9926)] = 9926, -- Heavy Mithril Shoulder
	[GetSpellInfo(12512)] = 12512, -- Kalaran Conjures Torch
	[GetSpellInfo(25953)] = 25953, -- Summon Blue Qiraji Battle Tank
	[GetSpellInfo(28739)] = 28739, -- Summon Mr. Wiggles
	[GetSpellInfo(9052)] = 9052, -- Fill Deino's Flask
	[GetSpellInfo(8394)] = 8394, -- Striped Frostsaber
	[GetSpellInfo(21884)] = 21884, -- Collect Orange Crystal Liquid
	[GetSpellInfo(16649)] = 16649, -- Imperial Plate Bracers
	[GetSpellInfo(18115)] = 18115, -- Viewing Room Student Transform - Effect
	[GetSpellInfo(1538)] = 1538, -- Charging
	[GetSpellInfo(10566)] = 10566, -- Wild Leather Boots
	[GetSpellInfo(2665)] = 2665, -- Coarse Sharpening Stone
	[GetSpellInfo(5244)] = 5244, -- Kodo Hide Bag
	[GetSpellInfo(15066)] = 15066, -- Create PX83-Enigmatron
	[GetSpellInfo(5252)] = 5252, -- Voidwalker Guardian
	[GetSpellInfo(3779)] = 3779, -- Barbaric Belt
	[GetSpellInfo(4977)] = 4977, -- Cleanse Thunderhorn Well
	[GetSpellInfo(10673)] = 10673, -- Summon Bombay
	[GetSpellInfo(10720)] = 10720, -- Summon Scarlet Snake
	[GetSpellInfo(22967)] = 22967, -- Smelt Elementium
	[GetSpellInfo(2152)] = 2152, -- Light Armor Kit
	[GetSpellInfo(2156)] = 2156, -- Light Winter Cloak
	[GetSpellInfo(15973)] = 15973, -- Searing Golden Blade
	[GetSpellInfo(19069)] = 19069, -- Plant Magic Beans
	[GetSpellInfo(5809)] = 5809, -- Create Scrying Bowl
	[GetSpellInfo(23096)] = 23096, -- Alarm-O-Bot
	[GetSpellInfo(12554)] = 12554, -- Summon Treasure Horde
	[GetSpellInfo(16970)] = 16970, -- Dawn's Edge
	[GetSpellInfo(10499)] = 10499, -- Nightscape Tunic
	[GetSpellInfo(3938)] = 3938, -- Bronze Tube
	[GetSpellInfo(12806)] = 12806, -- Getting Tide Pool Sample #3
	[GetSpellInfo(17481)] = 17481, -- Deathcharger
	[GetSpellInfo(6654)] = 6654, -- Brown Wolf
	[GetSpellInfo(849)] = 849, -- Elemental Armor
	[GetSpellInfo(23240)] = 23240, -- Swift White Ram
	[GetSpellInfo(13702)] = 13702, -- Runed Truesilver Rod
	[GetSpellInfo(27720)] = 27720, -- Buttermilk Delight
	[GetSpellInfo(10542)] = 10542, -- Tough Scorpid Gloves
	[GetSpellInfo(24892)] = 24892, -- Create Signet of Beckoning: Water
	[GetSpellInfo(11963)] = 11963, -- Enfeeble
	[GetSpellInfo(11476)] = 11476, -- Elixir of Shadow Power
	[GetSpellInfo(3771)] = 3771, -- Barbaric Gloves
	[GetSpellInfo(2402)] = 2402, -- Woolen Cape
}

local function updateFrame(casterID, spellID)
	for frame in pairs(LunaUF.Units.frameList) do
		if frame.unitRealType ~= "player" and frame.unitGUID == casterID and LunaUF.db.profile.units[frame.unitRealType].castBar.enabled then
			if spellID then
				Cast:EventStopCast(frame, event, frame.unit, nil, spellID)
			else
				Cast:UpdateCurrentCast(frame)
			end
		end
	end
end

local function combatlogEvent()
	local _, event, _, casterID, _, _, _, targetID, _, dstFlags, _, spellID, name, _, extra_spell_id, _, _, resisted, blocked, absorbed = CombatLogGetCurrentEventInfo()
	local name, rank, icon, castTime = GetSpellInfo(castTimeDB[name])

	if event ~= "SPELL_MISSED" and interruptIDs[name] and currentCasts[targetID] then
		spellID = currentCasts[targetID].spellID
		currentCasts[targetID] = nil
		updateFrame(targetID, spellID)
		return
	end

	if event == "SWING_DAMAGE" or event == "ENVIRONMENTAL_DAMAGE" or event == "RANGE_DAMAGE" or event == "SPELL_DAMAGE" then
		local cast = currentCasts[targetID]
		if (not cast and targetID ~= UnitGUID("player")) or resisted or blocked or absorbed then return end
		if bit.band(dstFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then -- is player
			if targetID ~= UnitGUID("player") then
				if GetTime() > cast.endTime then
					currentCasts[targetID] = nil
					return
				end
				if cast.channeled then
					cast.endTime = cast.endTime - math.min(cast.delay, (GetTime() - cast.startTime))
				else
					cast.endTime = cast.endTime + math.min(cast.delay, (GetTime() - cast.startTime))
				end
				if cast.delay > 200 then
					cast.delay = cast.delay - 200
				end
				updateFrame(targetID)
			elseif _G["LUFUnitplayer"].castBar and _G["LUFUnitplayer"].castBar.bar.spellName == GetSpellInfo(19434) then
				local delay = math.min(AimedDelay, GetTime() - _G["LUFUnitplayer"].castBar.bar.startTime)
				Cast:UpdateDelay(_G["LUFUnitplayer"], 19434, "", nil , (_G["LUFUnitplayer"].castBar.bar.startTime + delay) * 1000, (_G["LUFUnitplayer"].castBar.bar.endTime + delay) * 1000)
				if AimedDelay > 0.2 then
					AimedDelay = AimedDelay - 0.2
				end
			end
		end
		return
	elseif event == "SPELL_INTERRUPT" and currentCasts[casterID] then
		currentCasts[casterID] = nil
		updateFrame(casterID, extra_spell_id)
	elseif event == "SPELL_CAST_START" then
		if casterID == UnitGUID("player") and name == GetSpellInfo(19434) then
			AimedDelay = 1
			Cast:UpdateCast(_G["LUFUnitplayer"], "player", nil, name, nil, icon, GetTime()*1000, GetTime()*1000 + 3000, nil, nil, spellID)
			return
		elseif casterID == UnitGUID("player") and name == GetSpellInfo(2643) then
			Cast:UpdateCast(_G["LUFUnitplayer"], "player", nil, name, nil, icon, GetTime()*1000, GetTime()*1000 + 500, nil, nil, spellID)
			return
		end
		if castTime and castTime > 0 then
			castTime = castTime / 1000
			currentCasts[casterID] = {
				["spellID"] = spellID,
				["name"] = name,
				["icon"] = icon,
				["startTime"] = GetTime(),
				["endTime"] = castTime + GetTime(),
				["delay"] = 1000,
			}
			updateFrame(casterID)
		end
	elseif event == "SPELL_CAST_SUCCESS" then
		local castTime = channelIDs[name]
		if castTime then
			currentCasts[casterID] = {
				["spellID"] = spellID,
				["name"] = name,
				["icon"] = icon,
				["startTime"] = GetTime(),
				["endTime"] = castTime + GetTime(),
				["channeled"] = true,
				["delay"] = 1000,
			}
			updateFrame(casterID)
		elseif currentCasts[casterID] then
			if currentCasts[casterID].endTime > (GetTime() * 1000) then
				updateFrame(casterID, currentCasts[casterID].spellID)
			end
			currentCasts[casterID] = nil
		end
	end
end

function Cast:OnEnable(frame)
	if( not frame.castBar ) then
		frame.castBar = CreateFrame("Frame", nil, frame)
		frame.castBar.bar = LunaUF.Units:CreateBar(frame)
		frame.castBar.bar:SetFrameLevel(2)
		frame.castBar.background = frame.castBar.bar.background
		frame.castBar.bar.parent = frame
		
		frame.castBar.icon = frame.castBar.bar:CreateTexture(nil, "ARTWORK")
	end

	if frame.unitRealType == "player" then
		frame:RegisterUnitEvent("UNIT_SPELLCAST_START", self, "EventUpdateCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self, "EventStopCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self, "EventStopCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self, "EventInterruptCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self, "EventDelayCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", self, "EventCastSucceeded")
		
		frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self, "EventUpdateChannel")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self, "EventStopCast")
		--frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_INTERRUPTED", self, "EventInterruptCast")
		frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self, "EventDelayChannel")
	end

	frame:RegisterUpdateFunc(self, "UpdateCurrentCast")
end

function Cast:OnLayoutApplied(frame, config)
	if( not frame.visibility.castBar ) then return end
	
	-- Set textures
	frame.castBar.bar:SetStatusBarTexture(LunaUF.Layout:LoadMedia(SML.MediaType.STATUSBAR, LunaUF.db.profile.units[frame.unitType].castBar.statusbar))
	frame.castBar.bar:GetStatusBarTexture():SetHorizTile(false)
	frame.castBar.bar:SetStatusBarColor(0, 0, 0, 0)
	frame.castBar.background:SetVertexColor(0, 0, 0, 0)
	frame.castBar.background:SetHorizTile(false)
	
	-- Setup fill
	frame.castBar.bar:SetOrientation(config.castBar.vertical and "VERTICAL" or "HORIZONTAL")
	frame.castBar.bar:SetReverseFill(config.castBar.reverse and true or false)

	-- Setup the main bar + icon
	frame.castBar.bar:ClearAllPoints()
	frame.castBar.bar:SetHeight(frame.castBar:GetHeight())
	frame.castBar.bar:SetValue(0)
	frame.castBar.bar:SetMinMaxValues(0, 1)
	
	-- Use the entire bars width and show the icon
	if( config.castBar.icon == "HIDE" ) then
		frame.castBar.bar:SetWidth(frame.castBar:GetWidth())
		frame.castBar.bar:SetAllPoints(frame.castBar)
		frame.castBar.icon:Hide()
	-- Shift the bar to the side and show an icon
	else
		frame.castBar.bar:SetWidth(frame.castBar:GetWidth() - frame.castBar:GetHeight())
		frame.castBar.icon:ClearAllPoints()
		frame.castBar.icon:SetWidth(frame.castBar:GetHeight())
		frame.castBar.icon:SetHeight(frame.castBar:GetHeight())
		frame.castBar.icon:Show()

		if( config.castBar.icon == "LEFT" ) then
			frame.castBar.bar:SetPoint("TOPLEFT", frame.castBar, "TOPLEFT", frame.castBar:GetHeight() + 1, 0)
			frame.castBar.icon:SetPoint("TOPRIGHT", frame.castBar.bar, "TOPLEFT", -1, 0)
		else
			frame.castBar.bar:SetPoint("TOPLEFT", frame.castBar, "TOPLEFT", 1, 0)
			frame.castBar.icon:SetPoint("TOPLEFT", frame.castBar.bar, "TOPRIGHT", 0, 0)
		end
	end

	if( config.castBar.autoHide and not CastingInfo() and not ChannelInfo() ) then
		LunaUF.Layout:SetBarVisibility(frame, "castBar", false)
	else
		LunaUF.Layout:SetBarVisibility(frame, "castBar", true)
	end
end

function Cast:OnDisable(frame, unit)
	frame:UnregisterAll(self)

	if( frame.castBar ) then
		frame.castBar.bar:Hide()
	end
end

-- Easy coloring
local function setBarColor(self, r, g, b)
	self.parent:SetBlockColor(self, "castBar", r, g, b)
end

-- Cast OnUpdates
local function fadeOnUpdate(self, elapsed)
	self.fadeElapsed = self.fadeElapsed - elapsed
	
	if( self.fadeElapsed <= 0 ) then
		self.fadeElapsed = nil
		self:Hide()
		
		local frame = self:GetParent()
		if( LunaUF.db.profile.units[frame.unitType].castBar.autoHide ) then
			LunaUF.Layout:SetBarVisibility(frame, "castBar", false)
		end
	else
		local alpha = self.fadeElapsed / self.fadeStart
		self:SetAlpha(alpha)
	end
end

local function castOnUpdate(self, elapsed)
	local time = GetTime()
	self.elapsed = self.elapsed + elapsed
	self.lastUpdate = time
	
	if( self.elapsed >= self.endSeconds ) then
		self.elapsed = 0
		self.endSeconds = 0
	end

	self:SetValue(self.elapsed)

	-- Cast finished, do a quick fade
	if( self.elapsed >= self.endSeconds ) then
		if self:GetParent().unitGUID then
			currentCasts[self:GetParent().unitGUID] = nil
		end
		self.spellName = nil
		self.fadeElapsed = FADE_TIME
		self.fadeStart = FADE_TIME
		self:SetScript("OnUpdate", fadeOnUpdate)
	end
end

local function channelOnUpdate(self, elapsed)
	local time = GetTime()
	self.elapsed = self.elapsed - elapsed

	if( self.elapsed <= 0 ) then
		self.elapsed = 0
		self.endSeconds = 0
	end

	self:SetValue(self.elapsed)

	-- Channel finished, do a quick fade
	if( self.elapsed <= 0 ) then
		currentCasts[self:GetParent().unitGUID] = nil
		self.spellName = nil
		self.fadeElapsed = FADE_TIME
		self.fadeStart = FADE_TIME
		self:SetScript("OnUpdate", fadeOnUpdate)
	end
end

function Cast:UpdateCurrentCast(frame)
	if( CastingInfo() and frame.unitRealType == "player" ) then
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = CastingInfo()
		self:UpdateCast(frame, frame.unit, false, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
	elseif( ChannelInfo() and frame.unitRealType == "player" ) then
		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = ChannelInfo()
		self:UpdateCast(frame, frame.unit, true, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
	elseif frame.unitRealType ~= "player" and currentCasts[frame.unitGUID] and currentCasts[frame.unitGUID].endTime > GetTime() and not UnitIsDeadOrGhost(frame.unit) then
		local cast = currentCasts[frame.unitGUID]
		self:UpdateCast(frame, frame.unit, cast.channeled, cast.name, "", cast.icon, cast.startTime * 1000, cast.endTime * 1000, nil, nil, cast.spellID)
	else
		if( LunaUF.db.profile.units[frame.unitRealType].castBar.autoHide ) then
			LunaUF.Layout:SetBarVisibility(frame, "castBar", false)
		end

		setBarColor(frame.castBar.bar, 0, 0, 0)
		
		frame.castBar.bar.spellName = nil
		frame.castBar.bar:Hide()
	end
end

-- Cast updated/changed
function Cast:EventUpdateCast(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = CastingInfo()
	self:UpdateCast(frame, frame.unit, false, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
end

function Cast:EventDelayCast(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = CastingInfo()
	self:UpdateDelay(frame, name, text, texture, startTime, endTime)
end

-- Channel updated/changed
function Cast:EventUpdateChannel(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = ChannelInfo()
	self:UpdateCast(frame, frame.unit, true, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
end

function Cast:EventDelayChannel(frame)
	local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = ChannelInfo()
	self:UpdateDelay(frame, name, text, texture, startTime, endTime)
end

-- Cast finished
function Cast:EventStopCast(frame, event, unit, castID, spellID)
	local cast = frame.castBar.bar
	if( cast.spellID ~= spellID or ( event == "UNIT_SPELLCAST_FAILED" and cast.isChannelled ) ) then return end

	if( LunaUF.db.profile.units[frame.unitType].castBar.autoHide ) then
		LunaUF.Layout:SetBarVisibility(frame, "castBar", true)
	end

--	cast.spellName = nil
	cast.fadeElapsed = FADE_TIME
	cast.fadeStart = FADE_TIME
	cast:SetScript("OnUpdate", fadeOnUpdate)
	cast:SetMinMaxValues(0, 1)
	cast:SetValue(1)
	cast:Show()
end

-- Cast interrupted
function Cast:EventInterruptCast(frame, event, unit, castID, spellID)
	local cast = frame.castBar.bar
	if( spellID and cast.spellID ~= spellID ) then return end

	if( LunaUF.db.profile.units[frame.unitType].castBar.autoHide ) then
		LunaUF.Layout:SetBarVisibility(frame, "castBar", true)
	end

	updateFrame(UnitGUID(frame.unit), spellID)
	currentCasts[UnitGUID(frame.unit)] = nil

	cast.spellID = nil
	cast.fadeElapsed = FADE_TIME + 0.20
	cast.fadeStart = cast.fadeElapsed
	cast:SetScript("OnUpdate", fadeOnUpdate)
	cast:SetMinMaxValues(0, 1)
	cast:SetValue(1)
	cast:Show()
end

-- Cast succeeded
function Cast:EventCastSucceeded(frame, unit, spell)
	local cast = frame.castBar.bar
end

function Cast:UpdateDelay(frame, spell, displayName, icon, startTime, endTime)
	if( not spell or not frame.castBar or not frame.castBar.bar.startTime ) then return end
	local cast = frame.castBar.bar
	startTime = startTime / 1000
	endTime = endTime / 1000
	
	-- For a channel, delay is a negative value so using plus is fine here
	local delay = startTime - cast.startTime
	if( not cast.isChannelled ) then
		cast.endSeconds = cast.endSeconds + delay
		cast:SetMinMaxValues(0, cast.endSeconds)
	else
		cast.elapsed = cast.elapsed + delay
	end

	cast.pushback = cast.pushback + delay
	cast.lastUpdate = GetTime()
	cast.startTime = startTime
	cast.endTime = endTime
end

-- Update the actual bar
function Cast:UpdateCast(frame, unit, channelled, spell, displayName, icon, startTime, endTime, isTradeSkill, notInterruptible, spellID)
	if( not spell or not frame.castBar ) then return end
	local cast = frame.castBar.bar
	if( LunaUF.db.profile.units[frame.unitType].castBar.autoHide ) then
		LunaUF.Layout:SetBarVisibility(frame, "castBar", true)
	end

	-- Set spell icon
	if( LunaUF.db.profile.units[frame.unitType].castBar.icon ~= "HIDE" ) then
		frame.castBar.icon:SetTexture(icon)
		frame.castBar.icon:Show()
	end
		
	-- Setup cast info
	cast.isChannelled = channelled
	cast.startTime = startTime / 1000
	cast.endTime = endTime / 1000
	cast.endSeconds = cast.endTime - cast.startTime
	cast.elapsed = cast.isChannelled and (cast.endTime - GetTime()) or (GetTime() - cast.startTime)
	cast.spellName = spell
	cast.spellID = spellID
	cast.pushback = 0
	cast.lastUpdate = cast.startTime
	cast:SetMinMaxValues(0, cast.endSeconds)
	cast:SetValue(cast.elapsed)
	cast:SetAlpha(1) --LunaUF.db.profile.bars.alpha)
	cast:Show()
	
	if( cast.isChannelled ) then
		cast:SetScript("OnUpdate", channelOnUpdate)
	else
		cast:SetScript("OnUpdate", castOnUpdate)
	end
	
	if( cast.isChannelled ) then
		setBarColor(cast, LunaUF.db.profile.colors.channel.r, LunaUF.db.profile.colors.channel.g, LunaUF.db.profile.colors.channel.b)
	else
		setBarColor(cast, LunaUF.db.profile.colors.cast.r, LunaUF.db.profile.colors.cast.g, LunaUF.db.profile.colors.cast.b)
	end
end

LunaUF.castMonitor = CreateFrame("Frame")
LunaUF.castMonitor:SetScript("OnEvent", combatlogEvent)
LunaUF.castMonitor:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")