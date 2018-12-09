if( GetLocale() ~= "zhCN" ) then return end
local L = {
["FONT_LIST"] = {"HDZB_35"},
["DEFAULT_FONT"] = "HDZB_35",
["Loaded. The ride never ends!"] = "已加载，旅途永无止尽！",
["Mobhealth2/Mobinfo2 found. Please consider MobHealth3 for a better experience."] = "发现Mobhealth2/Mobinfo2插件，您可以考虑使用MobHealth3以获得更好的体验",
["Test"] = "测试",
["cmd_config"] = "config",
["Toggle config mode on and off."] = "切换设置模式",
["cmd_reset"] = "reset",
["Resets your current settings."] = "重置设置",
["Entering config mode."] = "Luna框架: 进入设置模式",
["Exiting config mode."] = "Luna框架: 退出设置模式",
["cmd_menu"] = "menu",
["Show/hide the options menu."] = "显示/隐藏选项界面",
["Health bar"] = "生命条",
["Power bar"] = "能量条",
["Empty Bar"] = "Empty Bar",
["General"] = "常用",
["Player"] = "玩家",
["Pet"] = "宠物",
["Pet Target"] = "宠物目标",
["Target"] = "目标",
["ToT"] = "目标的目标",
["ToToT"] = "目标的目标的目标",
["Party"] = "小队",
["Party Target"] = "小队目标",
["Party Pet"] = "小队宠物",
["Raid"] = "团队",
["Clickcasting"] = "点击施法",
["Colors"] = "颜色",
["Config Mode"] = "设置模式",
["Current profile has been reset."] = "当前配置已被重置",
["Portrait"] = "头像",
["Auras"] = "光环",
["Tags"] = "标签",
["Range"] = "范围",
["Incheal"] = "接受治疗",
["Combo points"] = "连击点数",
["Indicators"] = "指示器",
["Borders"] = "	边",
["(%a+) is now the loot master."] = "(.+)现在负责拾取并分配所有战利品",
["Cast bar"] = "施法条",
["Hearthstone"] = "炉石",
["Rough Copper Bomb"] = "劣质铜壳炸弹",
["Large Copper Bomb"] = "大型铜壳炸弹",
["Small Bronze Bomb"] = "小型青铜炸弹",
["Big Bronze Bomb"] = "重磅青铜炸弹",
["Iron Grenade"] = "铁皮手雷",
["Big Iron Bomb"] = "重磅铁制炸弹",
["Mithril Frag Bomb"] = "秘银破片炸弹",
["Hi-Explosive Bomb"] = "高爆炸弹",
["Thorium Grenade"] = "瑟银手榴弹",
["Dark Iron Bomb"] = "黑铁炸弹",
["Arcane Bomb"] = "奥术炸弹",
["Sleep"] = "催眠术",
["Reckless Charge"] = "无畏冲锋",
["Dark Mending"] = "黑暗治疗", -- 19775, Flamewaker Priest, 火妖祭司
["First Aid"] = "急救",
["Linen Bandage"] = "亚麻绷带",
["Heavy Linen Bandage"] = "厚亚麻绷带",
["Wool Bandage"] = "绒线绷带",
["Heavy Wool Bandage"] = "厚绒线绷带",
["Silk Bandage"] = "丝质绷带",
["Heavy Silk Bandage"] = "厚丝质绷带",
["Mageweave Bandage"] = "魔纹绷带",
["Heavy Mageweave Bandage"] = "厚魔纹绷带",
["Runecloth Bandage"] = "符文布绷带",
["Heavy Runecloth Bandage"] = "厚符文布绷带",
["Feral Charge Effect"] = "野性冲锋效果", --19675
["Inferno Effect"] = "地狱火效果", --22703
["Explode"] = "爆炸",
["Shadow Flame"] = "暗影烈焰", --22539, Firemaw/Ebonroc/Flamegor/Nefarian, 费尔默/埃博诺克/弗莱格尔/奈法利安
["Wing Buffet"] = "龙翼打击", --23339, Firemaw/Ebonroc/Flamegor, 费尔默/埃博诺克/弗莱格尔
["Bellowing Roar"] = "低沉咆哮", --18431, Onyxia, 奥妮克希亚, 22686, Nefarian, 奈法利安
["Unstable Concoction"] = "不稳定化合物",
["Intense Pain"] = "剧烈痛楚", --22478, Zevrim Thornhoof, 瑟雷姆·刺蹄, 厄运之槌
["Combat text"] = "战斗信息",
["PRIEST"] = "牧师",
["WARRIOR"] = "战士",
["HUNTER"] = "猎人",
["SHAMAN"] = "萨满",
["ROGUE"] = "盗贼",
["MAGE"] = "法师",
["WARLOCK"] = "术士",
["PALADIN"] = "圣骑士",
["DRUID"] = "德鲁伊",
["tapped"] = "被他人标记",
["red"] = "红",
["green"] = "绿",
["static"] = "静态",
["yellow"] = "黄",
["inc"] = "接受治疗",
["MANAUSAGE"] = "法力消耗",
["enemyUnattack"] = "不能攻击",
["enemyCivilian"] = "平民",
["hostile"] = "敌对",
["friendly"] = "友善",
["neutral"] = "中立",
["offline"] = "离线",
["MANA"] = "法力",
["RAGE"] = "怒气",
["FOCUS"] = "集中",
["ENERGY"] = "能量",
["HAPPINESS"] = "快乐",
["channel"] = "引导",
["cast"] = "施法",
["normal"] = "正常",
["rested"] = "已休息",
["Classcolors"] = "职业颜色",
["Healthcolors"] = "生命颜色",
["Powercolors"] = "能量颜色",
["Castcolors"] = "施法颜色",
["Font"] = "字体",
["Textures"] = "纹理",
["Bar Texture"] = "条形纹理",
["Stretch Textures"] = "拉伸纹理",
["Aura Border"] = "光环边框",
["TOPLEFT"] = "左上",
["TOP"] = "顶部",
["TOPRIGHT"] = "右上",
["RIGHT"] = "右",
["BOTTOMRIGHT"] = "右下",
["BOTTOM"] = "底部",
["BOTTOMLEFT"] = "左下",
["LEFT"] = "左",
["CENTER"] = "居中",
["raidTarget"] = "团队目标",
["class"] = "职业",
["Class Gradient"] = "Class Gradient",
["masterLoot"] = "队长分配",
["leader"] = "队长标志",
["elite"] = "精英",
["KOS indicator"] = "杀死视线指示器",
["pvp"] = "PvP",
["pvprank"] = "PvP等级",
["ready"] = "准备就绪",
["status"] = "交战状态",
["happiness"] = "快乐度",
["rezz"] = "复活",
["none"] = "无",
["Tooltips"] = "提示",
["Enable Tooltips"] = "启用提示",
["Tooltips hidden in combat"] = "战斗中隐藏提示",
["Low Health Indicator"] = "健康指标低",
["Low Health Limit"] = "低生命限制",
["In Range and Above Limit"] = "范围和上限",
["Out of Range and Below Limit"] = "超出范围和下限",
["In Range and Below Limit"] = "范围在上限以上",
["Bar transparency"] = "条形透明度",
["Alpha"] = "透明度",
["Background alpha"] = "背景透明度",
["Blizzard frames"] = "暴雪框架",
["Emphasize"] = "注重",
["Buffs"] = "增益",
["Debuffs"] = "减益",
["Weaponbuffs"] = "武器增益",
["Enable"] = "启用",
["Height"] = "高度",
["Width"] = "宽度",
["Scale"] = "缩放",
["Left"] = "左",
["Right"] = "右",
["Middle"] = "中",
["npc"] = "NPC",
["both"] = "玩家和NPC",
["colortype"] = "颜色类型",
["colorreaction"] = "颜色变化",
["never"] = "从不",
["Invert"] = "反转颜色",
["Vertical"] = "垂直增长",
["Reverse"] = "相反",
["hide"] = "隐藏",
["Icon"] = "图标",
["Healing prediction"] = "治疗预测",
["Type"] = "类型",
["Side"] = "位置",
["healthBar"] = "生命条",
["powerBar"] = "怒气/能量/法力条",
["emptyBar"] = "空白条",
["Hide when not Mana"] = "没有法力时隐藏",
["castBar"] = "施法条",
["Barorder"] = "排序",
["Growth"] = "增长方向",
["portrait"] = "头像",
["comboPoints"] = "连击点数",
["XP/Rep bar"] = "经验/荣誉条",
["xpBar"] = "经验/荣誉条",
["Level"] = "等级",
["done"] = "完成",
["druidBar"] = "德鲁伊条",
["totemBar"] = "图腾条",
["Click me"] = "点我",
["Cast on mouse down"] = "以鼠标向下投射",
["Xpcolors"] = "经验颜色",
["Add"] = "增加",
["Reset All Colors"] = "重置所有颜色",
["Totem Bar"] = "图腾条",
["Druid Bar"] = "德鲁伊条",
["Highlight"] = "高亮",
["On targeting"] = "作为目标时",
["On mouseover"] = "鼠标悬停时",
["On dispellable debuff"] = "当减益可被驱散时",
["Combat fader"] = "非战斗淡出",
["Status tracker"] = "状态追踪器",
["High Priestess Mar'li"] = "高阶祭司玛尔里",
["Gehennas"] = "基赫纳斯",
["Flamewaker Elite"] = "火妖精英",
["Flamewaker Priest"] = "火妖祭司",
["Great Heal"] = "强效治疗术", --25807, Princess Yauj, 亚尔基公主
["Sweep"] = "横扫", --26103, Ouro, 奥罗
["Sand Blast"] = "沙尘爆裂", --26102, Ouro, 奥罗
["Emperor Vek'lor"] = "维克尼拉斯大帝",
["Gothik the Harvester"] = "收割者戈提克",
["Unyielding Pain"] = "不灭痛楚", --57381（未测试）, Lady Blaumeux, 女公爵布劳缪克丝
["Condemnation"] = "谴责", --57377（未测试）, Sir Zeliek, 瑟里耶克爵士
["Holy Bolt"] = "神圣之箭", --57376、57465（未测试），Sir Zeliek, 瑟里耶克爵士
["Polarity Shift"] = "极性转化", --28089, Thaddius, 塔迪乌斯
["Ball Lightning"] = "闪电球", --28299, Thaddius, 塔迪乌斯
["Destroy Egg"] = "摧毁蛋", --19873, Razorgore, 狂野的拉佐格尔
["Fireball Volley"] = "连珠火球", --22425, Razorgore, 狂野的拉佐格尔
["Flame Breath"] = "火息术", --23461, Vaelastrasz, 堕落的瓦拉斯塔兹
["Time Lapse"] = "时间流逝", --23310, 23312, Chromaggus, 克洛玛古斯
["Incinerate"] = "焚烧", --23308, 23309, Chromaggus, 克洛玛古斯
["Ignite Flesh"] = "点燃躯体", --23315, 23316, Chromaggus, 克洛玛古斯
["Frost Burn"] = "冰霜灼烧", --23187, 23187, Chromaggus, 克洛玛古斯
["Corrosive Acid"] = "腐蚀酸液", --23314, 23319, Chromaggus, 克洛玛古斯
["Dominate Mind"] = "统御意志",
["Demon Portal"] = "恶魔之门",
["Eye Beam"] = "眼棱", --26134, 32950, Eye of C'Thun, 克苏恩之眼
["Locust Swarm"] = "虫群",
["Meteor"] = "流星", --28884, Thane Korth'azz, 库尔塔兹领主
["Starfire Stun"] = "星火晕迷", --16922
["Polymorph: Pig"] = "变形术：猪",
["Polymorph: Turtle"] = "变形术：龟",
["Counterspell - Silenced"] = "法术反制 - 沉默",
["Kick - Silenced"] = "脚踢 - 沉默",
["Shield Bash - Silenced"] = "盾击 - 沉默",
["Eye Beam"] = "眼棱",
["Energy / mp5 ticker"] = "能量/5秒回蓝计时",
["Show Mana Usage"] = "显示法力使用",
["Auratracker"] = "光环追踪",
["Enable debuffs"] = "启用减益",
["Show dispellable debuffs"] = "显示可驱散减益",
["Only debuffs you can dispel"] = "仅你可驱散的减益",
["Show aggro"] = "显示仇恨目标",
["Aggrocolor"] = "仇恨目标颜色",
["Track heal over time"] = "追踪持续治疗",
["Colors instead of icons for buffs"] = "用颜色代替图标（增益颜色）",
["Colors instead of icons for debuffs"] = "用颜色代替图标（减益颜色）",
["Buffs to track"] = "需要追踪的增益",
["Debuffs to track"] = "需要追踪的减益",
["Buffcolor"] = "增益颜色",
["Invert display"] = "反转显示",
["Debuffcolor"] = "减益颜色",
["Feigned"] = "假死",
["Feign Death"] = "假死",
["Dead"] = "死亡",
["Size"] = "大小",
["Big Size"] = "大尺寸",
["Limit"] = "限制",
["Partyoptions"] = "小队选项",
["Show party in raid"] = "在团队中显示小队",
["Player in party"] = "在小队中显示玩家",
["Padding"] = "填充间距",
["Sort by"] = "排序方式",
["Name"] = "名字",
["Group"] = "队伍",
["Sort direction"] = "排序方向",
["Ascending"] = "递增",
["Descending"] = "递减",
["Growth direction"] = "偏移方向",
["DOWN"] = "下",
["UP"] = "上",
["Raidoptions"] = "团队选项",
["Party in raidframes"] = "团队中显示小队",
["Always show"] = "总是显示",
["Interlock raidframes"] = "连锁框架",
["Class"] = "职业",
["Mode"] = "方式",
["Enable pet group"] = "启用宠物分组",
["Enable raidgroup titles"] = "启用分组标题",
["XP Bar"] = "经验条",
["Frame background"] = "框架背景",
["Color"] = "颜色",
["Enable Border Color"] = "启用边框颜色",
["Enable Timer Text"] = "启用倒计时文字",
["Small font size"] = "小字体",
["Big font size"] = "大字体",
["Enable Timer Spin"] = "启用倒计时旋转",
["Returns plain name of the unit"] = "单位全名",
["Returns the first x letters of the name (1-12)"] = "名字的前X个字符",
["Returns shortened names (Marshall Williams = M. Williams)"] = "名字缩写 (Marshall Williams = M. Williams)",
["Guildname"] = "公会名",
["Guildrank"] = "公会等级",
["Current level, returns ?? for bosses and players too high"] = "当前等级，Boss和高等级玩家显示??",
["Returns \"Boss\" for bosses and Level+10+ for players too high"] = "Boss和等级差10级以上的玩家显示为“Boss”",
["Class of the unit"] = "单位职业",
["Returns Class for players and Creaturetype for NPCs"] = "玩家职业/NPC类型",
["\"rare\" if the creature is rare or rareelite"] = "稀有怪显示“稀有”",
["\"elite\" if the creature is elite or rareelite"] = "精英显示“精英”",
["Shows elite, rare, boss, etc..."] = "显示精英、稀有、Boss…",
["\"E\", \"R\", \"RE\" for the respective classification"] = "精英、稀有、稀有精英分别显示“E”、“R”、“RE”",
["Race if available"] = "种族（可用时）",
["Shows race when if player, creaturetype when npc"] = "玩家职业/NPC类型",
["Creature type (Bat, Wolf , etc..)"] = "生物类型（蝙蝠、狼…）",
["Gender"] = "性别",
["Current druid form of friendly unit"] = "友方德鲁伊形态",
["Returns (civ) when civilian"] = "平民显示“(平)”",
["(civ)"] = "(平)",
["Displays \"PvP\" if flagged for it"] = "若开启PvP则显示“PVP”",
["PvP title"] = "PvP军衔",
["Numeric PvP rank"] = "PvP等级数字",
["Horde or Alliance"] = "联盟或部落",
["Returns (i) if the player is on your ignore list"] = "屏蔽列表中的玩家显示(屏)",
["(i)"] = "(屏)",
["Server name"] = "服务器名",
["\"Dead\", \"Ghost\" or \"Offline\""] = "“死亡”、“鬼魂”或“离线”",
["Pet happiness as 'unhappy','content' or 'happy'"] = "宠物喜悦程度，“不高兴”、“满足”或“快乐”",
["Current subgroup of the raid"] = "小队在团队中编号",
["(c) when in combat"] = "战斗中的单位显示“(战)”",
["(c)"] = "(战)",
["Loyalty level of your pet"] = "你的宠物的忠诚度水平",
["The same as \"healerhealth\" but displays name on full health"] = "与“healerhealth”相同但满生命时显示名字",
["Returns the same as \"smart:healmishp\" on friendly units and hp/maxhp on enemies"] = "友方单位与“smart:healmishp”相同，敌方单位显示生命/最大生命",
["Returns missing hp with healing factored in. Shows status when needed (\"Dead\", \"Offline\", \"Ghost\")"] = "计算治疗后的缺失生命，死亡、离线、鬼魂时显示状态",
["Combo Points"] = "连击点数",
["The classic hp display (hp/maxhp and \"Dead\" if dead etc)"] = "经典生命显示（生命/最大生命或“死亡”)",
["Like [smarthealth] but shortened when over 10K"] = "类似“smarthealth”，超过10K时缩略",
["Current hp and heal in one number (green when heal is incoming)"] = "当前生命和治疗总和（受到治疗时为绿色）",
["Current hp"] = "当前生命值",
["Current hp shortened when over 10K"] = "当前生命，超过10K时缩略",
["Current maximum hp"] = "当前最大生命值",
["Current maximum hp shortened when over 10K"] = "当前生命最大值，超过10K时缩略",
["Like [ssmarthealth] but without maximum hp"] = "类似“ssmarthealth”，但没有最大的生命值",
["Current missing hp"] = "当前缺失生命值",
["Missing hp after incoming heal (green when heal is incoming)"] = "接受治疗后的缺失生命（受到治疗时为绿色）",
["HP percent"] = "生命百分比",
["Current mana/rage/energy etc"] = "当前法力/怒气/能量",
["Current mana/rage/energy etc shortened when over 10K"] = "当前法力/怒气/能量，超过10K时缩略",
["Maximum mana/rage/energy etc"] = "最大法力/怒气/能量",
["Maximum mana/rage/energy etc shortened when over 10K"] = "最大法力/怒气/能量，超过10K时缩略",
["Missing mana/rage/energy"] = "缺失法力/怒气/能量",
["Mana/rage/energy percent"] = "法力/怒气/能量百分比",
["Returns current mana even in druid form"] = "德鲁伊变形时显示当前法力值",
["Returns current maximum mana even in druid form"] = "德鲁伊变形时显示最大法力值",
["Returns missing mana even in druid form"] = "德鲁伊变形时显示缺失法力值",
["Returns mana percentage even in druid form"] = "德鲁伊变形时显示法力值百分比",
["Value of incoming heal"] = "即将受到的治疗量",
["Number of incoming heals"] = "即将受到的治疗次数",
["Red when in combat"] = "战斗中显示为红色",
["White for unflagged units, green for flagged friendlies and red for flagged enemies"] = "非PvP单位白色，友方PvP单位绿色，敌方PvP单位红色",
["Red for enemies, yellow for neutrals, and green for friendlies"] = "敌方单位红色，中立单位黄色，友方单位绿色",
["Colors based on your level vs the level of the unit. (grey,green,yellow and red)"] = "颜色基于你和目标单位等级差（灰，绿，黄，红）",
["Red if the unit is targeted by an enemy"] = "被敌方单位作为目标时显示红色",
["Classcolor of the unit"] = "职业颜色",
["Color based on health (red = dead)"] = "基于生命的颜色（死亡时为红色）",
["Custom color in hexadecimal (rrggbb)"] = "自定义十六进制颜色（rrggbb）",
["Resets the color to white"] = "重置颜色为白色",
["Adds a line break"] = "换行符",
["Number of people in your group targeting this unit"] = "你队伍中目标为该单位的人数",
["Colored version of numtargeting"] = "彩色版的numtargeting",
["Tag listing"] = "标签列表",
["INFO TAGS"] = "信息标签",
["HEALTH AND POWER TAGS"] = "生命和怒气/能量/法力条",
["COLOR TAGS"] = "颜色标签",
["Mouseover"] = "鼠标悬停",
["Mouseover in 3D world"] = "在3D世界中启用鼠标悬停",
["Warsong Gulch"] = "战歌峡谷",
["Arathi Basin"] = "阿拉希盆地",
["Alterac Valley"] = "奥特兰克山谷",
["Polling Rate"] = "轮询频率",
["you"] = "你",
["You"] = "你",
["Enable Combatlog based Range"] = "启用基于战斗记录的范围",
["Globally disable castbars of others"] = "禁用所有投射条",
["Combat alpha"] = "战斗透明度",
["Non combat alpha"] = "非战斗透明度",
["Speedy Fade"] = "快速褪色",
["#invalidTag#"] = "#无效标签#",
["LeftButton"] = "鼠标左键",
["RightButton"] = "鼠标右键",
["MiddleButton"] = "鼠标中键",
["Button4"] = "鼠标按键4",
["Button5"] = "鼠标按键5",
["target"] = "目标",
["menu"] = "菜单",
["Do you really want to reset to default for your current profile?"] = "你确定要重置你的当前设置么",
["Do you really want to reset all colors?"] = "你真的要重置所有的颜色吗",
["rare"] = "稀有",
["Ghost"] = "鬼魂",
["Offline"] = "离线",
["form_cat"] = "猎豹",
["form_bear"] = "熊",
["form_moonkin"] = "枭兽",
["form_aquatic"] = "水生",
["form_travel"] = "旅行",
["male"] = "男",
["female"] = "女",
["unhappy"] = "不高兴",
["happy"] = "快乐",
["content"] = "满足",
["worldboss"] = "首领",
["rareelite"] = "稀有精英",
["Reckoning Stacks"] = "清算条",
["reckStacks"] = "清算条",
["Position"] = "位置",
["Profiles"] = "剖面",
["New Profile"] = "新的配置文件",
["Select Profile"] = "选择配置文件",
["Copy Settings for new Profile from *"] = "复制新配置文件的设置 *",
["Reset current Profile"] = "重置当前配置文件",
["Delete current Profile"] = "删除当前配置文件",
["* Copying from the active profile is not possible"] = "* 从活动配置文件复制是不可能的",
["Switched to Profile: "] = "切换到配置文件: ",
["Profile Switcher"] = "配置文件切换器",
["Solo"] = "独奏",
["5man"] = "5人队",
["10man"] = "10人队",
["20man"] = "20人队",
["40man"] = "40人队",
["OK"] = "好",
["Cancel"] = "取消",
["Do you really want to delete your current profile?"] = "真的要删除你当前的个人资料吗",
["The profile has been deleted and the default profile has been selected."] = "配置文件已被删除，并且已选择默认配置文件。",
["CHAT_MSG_COMBAT_HITS"] = "(.+)击中.+造成.+伤害。",
["CHAT_MSG_COMBAT_CRITS"] = "(.+)对.+造成.+致命一击伤害。",
["CHAT_MSG_COMBAT_CREATURE_VS_HITS"] = ".+击中(.+)造成.+伤害。",
["CHAT_MSG_COMBAT_CREATURE_VS_CRITS"] = ".+的致命一击对(.+)造成.+伤害。",
["CHAT_MSG_COMBAT_CREATURE_VS_CRITS2"] = ".+对.+造成(.+)致命一击伤害。",
["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE1"] = ".+的.+击中(.+)造成.+伤害",
["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE2"] = ".+的.+致命一击对(.+)造成.+伤害",
["CHAT_MSG_SPELL_CREATURE_VS_DAMAGE3"] = ".+的.+被(.+)抵抗了",
["CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF"] = "(.+)的.+",
["CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE"] = "(.+)的.+击中.+造成.+伤害",
["CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE2"] = "(.+)的.+致命一击对(.+)造成.+伤害",
["CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS"] = "(.+)获得%d+点生命值（.+的.+）",
["CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"] = "(.+)受到了.+的影响",
["CHAT_MSG_SPELL_PERIODIC_DAMAGE"] = "(.+)受到了%d+.+",
["CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS1"] = ".+获得%d+点生命值（(.+)的.+）",
["CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS2"] = "(.+)获得了.+",
["CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES1"] = ".+发起了攻击。(.+)招架住了。",
["CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES2"] = ".+发起了攻击。(.+)闪躲开了。",
["CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES3"] = ".+发起了攻击。(.+)格挡住了。",
["CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES4"] = ".+没有击中(.+)。",
["CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF1"] = ".+的.+为(.+)恢复了.+生命值",
["CHAT_MSG_COMBAT_SELF_HITS"] = "(你击中.+造成.+伤害。)",
["CHAT_MSG_COMBAT_SELF_CRITS"] = "(你对.+造成.+致命一击伤害。)",
["CHAT_MSG_COMBAT_FRIENDLY_DEATH"] = "你死了",
["CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS"] = ".+击中(.+)造成.+伤害。",
["CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS"] = ".+的致命一击对(你)造成.+伤害。",
["CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"] = ".+的.+击中(.+)造成.+伤害",
["CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE"] = ".+的.+致命一击对(.+)造成.+伤害",
["Shadow Wing Lair"] = "影翼巢穴",
["Halls of Strife"] = "征战大厅",
}

local LunaUF = select(2, ...)
LunaUF.L = setmetatable(L, {__index = LunaUF.L})