# Gallifrey's Fish Farm 产品升级方案 v1.0

> 战略定位：从技术 Demo 升级为可运营的挂机养成游戏
> 评估日期：2026-03-27
> 负责人：Claude (P10 视角)

---

## 一、现状诊断

### 1.1 核心问题

| 维度 | 现状 | 评分 | 市场标准 |
|------|------|------|----------|
| 战斗文案 | 仅有简单的技能提示 | 0/10 | 丰富的战斗叙事 |
| 游戏引导 | 完全缺失 | 0/10 | 5-7步新手引导 |
| 内容量 | 12鱼/4Boss/10成就 | 4/10 | 50+鱼/15+Boss/40+成就 |
| 成长深度 | 钓鱼→战斗→转生 | 6/10 | 多维度成长线 |
| 中期目标 | 无 | 0/10 | 周常/活动/挑战 |
| 社交元素 | 无 | 0/10 | 排行榜/分享 |

### 1.2 竞品对标

- **放置奇兵**：丰富英雄系统、公会战、PVP竞技场
- **一念逍遥**：修仙挂机、多维度成长、社交系统
- **问道手游**：剧情引导、师徒系统、帮派玩法

---

## 二、Phase 1: 基础体验优化

### 2.1 新手引导系统

#### 设计目标
- 新玩家 3 分钟内理解核心玩法
- 渐进式功能解锁，避免信息过载
- 明确的短期/中期目标

#### 技术架构

```dart
// lib/services/tutorial_service.dart

/// 引导步骤
enum TutorialStep {
  welcome,           // 欢迎界面
  firstFishing,      // 第一次钓鱼
  viewCollection,    // 查看图鉴
  firstBattle,       // 第一次战斗
  upgradeBuilding,   // 升级建筑
  completed,         // 引导完成
}

/// 引导管理器
class TutorialManager {
  TutorialStep currentStep;
  Map<String, bool> unlockedFeatures;

  // 功能解锁条件
  static const unlockConditions = {
    'fishing': TutorialStep.welcome,
    'collection': TutorialStep.firstFishing,
    'battle': TutorialStep.viewCollection,
    'buildings': TutorialStep.firstBattle,
    'prestige': TutorialStep.completed,  // 引导完成后解锁
  };

  /// 检查功能是否解锁
  bool isFeatureUnlocked(String feature);

  /// 完成当前步骤，进入下一步
  void completeStep();

  /// 获取当前引导提示
  TutorialHint getCurrentHint();
}

/// 引导提示
class TutorialHint {
  final String title;
  final String description;
  final String targetWidget;  // 高亮的目标组件
  final String action;        // 建议操作
}
```

#### 引导流程

```
Step 1: 欢迎界面
┌─────────────────────────────────────┐
│  🎣 欢迎来到加拉弗雷钓鱼农场！        │
│                                     │
│  在这里，你将经营自己的钓鱼帝国       │
│                                     │
│  [开始冒险]                         │
└─────────────────────────────────────┘

Step 2: 第一次钓鱼
┌─────────────────────────────────────┐
│  👆 点击 [钓鱼] 按钮开始钓鱼         │
│                                     │
│  ┌─────┐                           │
│  │ 🎣  │  ← 高亮此按钮              │
│  │钓鱼 │                           │
│  └─────┘                           │
└─────────────────────────────────────┘

Step 3: 查看图鉴
┌─────────────────────────────────────┐
│  🎉 恭喜钓到第一条鱼！               │
│                                     │
│  点击 [图鉴] 查看你钓到的鱼宠        │
└─────────────────────────────────────┘

Step 4: 第一次战斗
┌─────────────────────────────────────┐
│  ⚔️ 你的鱼宠已经准备好了！           │
│                                     │
│  点击 [战斗] 挑战第一个Boss          │
└─────────────────────────────────────┘

Step 5: 升级建筑
┌─────────────────────────────────────┐
│  🏗️ 用金币升级建筑可以增加收益       │
│                                     │
│  点击 [建筑] 查看可升级的建筑        │
└─────────────────────────────────────┘
```

### 2.2 战斗文案引擎

#### 设计目标
- 战斗过程有叙事感
- Boss有个性台词
- 战斗结果有情感反馈

#### 技术架构

```dart
// lib/models/battle_narrative.dart

/// Boss 战斗配置
class BossBattleConfig {
  final String bossId;

  // 开场白（随机选一条）
  final List<String> introLines;

  // 攻击台词
  final List<String> attackLines;

  // 受击台词
  final List<String> hitLines;

  // 低血量台词
  final List<String> lowHpLines;

  // 死亡台词
  final List<String> deathLines;

  // 胜利（玩家失败）台词
  final List<String> victoryLines;
}

/// 战斗叙事生成器
class BattleNarrator {
  static String getIntro(Boss boss);
  static String getAttackLine(Boss boss);
  static String getHitLine(Boss boss);
  static String getLowHpLine(Boss boss);
  static String getDeathLine(Boss boss);
  static String getVictoryLine(Boss boss);
  static String getDefeatLine(Boss boss);

  // 战斗过程描述
  static String describeAttack(Fish attacker, Boss target, int damage);
  static String describeSkillActivation(Fish fish, FishSkill skill);
  static String describeCombo(int comboCount);
}
```

#### Boss 文案示例

```dart
// 螃蟹将军
static const crabGeneral = BossBattleConfig(
  bossId: 'crab_general',
  introLines: [
    '🦀 "哼，又来了一个不自量力的家伙！"',
    '🦀 "我的钳子已经饥渴难耐了！"',
    '🦀 "想挑战我？先过我这一关！"',
  ],
  attackLines: [
    '🦀 螃蟹将军挥舞巨钳，横扫而来！',
    '🦀 "尝尝我的蟹钳风暴！"',
    '🦀 螃蟹将军猛地夹击！',
  ],
  hitLines: [
    '🦀 "嘶...这一击有点疼！"',
    '🦀 "你还挺能打的嘛！"',
  ],
  lowHpLines: [
    '🦀 "不可能...我怎么会输给这种对手！"',
    '🦀 螃蟹将军的钳子开始颤抖...',
  ],
  deathLines: [
    '🦀 "这...不可能...我的钳子..."',
    '🦀 螃蟹将军倒下了，掉落了一些金币和材料...',
  ],
  victoryLines: [
    '🦀 "哈哈哈！这就是实力的差距！"',
    '🦀 "下次再来挑战吧，如果你还敢的话！"',
  ],
);

// 海龙王
static const dragonKing = BossBattleConfig(
  bossId: 'dragon_king',
  introLines: [
    '🐉 "凡人，你竟敢打扰本座的沉眠？"',
    '🐉 "我已统治这片海域千年，你算什么东西？"',
    '🐉 "来吧，让我看看你的能耐！"',
  ],
  attackLines: [
    '🐉 海龙王张开巨口，喷出灼热的龙息！',
    '🐉 "龙之吐息，焚尽一切！"',
    '🐉 海龙王召唤海啸，卷向你的鱼群！',
  ],
  hitLines: [
    '🐉 "嗯？这一击...有点意思。"',
    '🐉 "本座承认，你不是普通的对手。"',
  ],
  lowHpLines: [
    '🐉 "不可能...凡人怎么可能伤到本座！"',
    '🐉 海龙王的鳞片开始脱落，眼中闪烁着怒火...',
  ],
  deathLines: [
    '🐉 "这...这是命运吗...本座...不甘心..."',
    '🐉 海龙王化作一道金光消散，留下了传说中的神器碎片...',
  ],
  victoryLines: [
    '🐉 "正如我所料，你还不配挑战本座。"',
    '🐉 "回去修炼个几百年再来吧，凡人。"',
  ],
);
```

### 2.3 目标提示系统

```dart
// lib/services/goal_service.dart

/// 目标类型
enum GoalType {
  daily,      // 每日目标
  weekly,     // 每周目标
  milestone,  // 里程碑
  tutorial,   // 新手引导目标
}

/// 目标定义
class Goal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final int targetValue;
  final int currentValue;
  final List<Reward> rewards;
  final bool isCompleted;

  String get progressText => '$currentValue / $targetValue';
  double get progress => currentValue / targetValue;
}

/// 目标管理器
class GoalManager {
  List<Goal> activeGoals;

  // 新手目标
  static const tutorialGoals = [
    Goal(
      id: 'catch_10_fish',
      title: '小试牛刀',
      description: '钓到 10 条鱼',
      type: GoalType.tutorial,
      targetValue: 10,
      rewards: [CoinReward(100)],
    ),
    Goal(
      id: 'defeat_crab',
      title: '首战告捷',
      description: '击败螃蟹将军',
      type: GoalType.tutorial,
      targetValue: 1,
      rewards: [CoinReward(200), FishFoodReward(10)],
    ),
    Goal(
      id: 'own_rare_fish',
      title: '稀有收藏',
      description: '拥有一条稀有品质的鱼',
      type: GoalType.tutorial,
      targetValue: 1,
      rewards: [CoinReward(300)],
    ),
  ];

  // 里程碑目标
  static const milestoneGoals = [
    Goal(
      id: 'catch_100_fish',
      title: '钓鱼达人',
      description: '累计钓到 100 条鱼',
      type: GoalType.milestone,
      targetValue: 100,
      rewards: [CoinReward(1000), RareFishReward(1)],
    ),
    Goal(
      id: 'defeat_all_bosses',
      title: 'Boss克星',
      description: '击败所有Boss',
      type: GoalType.milestone,
      targetValue: 12,  // 升级后
      rewards: [CoinReward(10000), LegendaryFishReward(1)],
    ),
  ];
}
```

---

## 三、Phase 2: 内容扩充

### 3.1 鱼类扩充 (12 → 36)

按稀有度分布：
- 普通 (Common): 9种 → 45% 概率
- 稀有 (Rare): 9种 → 30% 概率
- 史诗 (Epic): 9种 → 20% 概率
- 传说 (Legendary): 9种 → 5% 概率

#### 新增鱼类设计

```dart
// 普通 - 淡水鱼
FishTemplate(name: '鲤鱼', emoji: '🐟', rarity: Rarity.common, baseIncome: 1, baseValue: 8),
FishTemplate(name: '草鱼', emoji: '🐟', rarity: Rarity.common, baseIncome: 1, baseValue: 10),
FishTemplate(name: '鲶鱼', emoji: '🐟', rarity: Rarity.common, baseIncome: 2, baseValue: 12),
FishTemplate(name: '泥鳅', emoji: '🐟', rarity: Rarity.common, baseIncome: 1, baseValue: 6),
FishTemplate(name: '青鱼', emoji: '🐟', rarity: Rarity.common, baseIncome: 1, baseValue: 9),
// ... 共9种

// 稀有 - 海洋鱼
FishTemplate(name: '海豚', emoji: '🐬', rarity: Rarity.rare, baseIncome: 5, baseValue: 50),
FishTemplate(name: '鲸鱼', emoji: '🐋', rarity: Rarity.rare, baseIncome: 8, baseValue: 80),
FishTemplate(name: '鲨鱼', emoji: '🦈', rarity: Rarity.rare, baseIncome: 6, baseValue: 60),
FishTemplate(name: '剑鱼', emoji: '🐠', rarity: Rarity.rare, baseIncome: 7, baseValue: 70),
FishTemplate(name: '海龟', emoji: '🐢', rarity: Rarity.rare, baseIncome: 4, baseValue: 55),
// ... 共9种

// 史诗 - 深海生物
FishTemplate(name: '章鱼', emoji: '🐙', rarity: Rarity.epic, baseIncome: 15, baseValue: 200),
FishTemplate(name: '螃蟹', emoji: '🦀', rarity: Rarity.epic, baseIncome: 12, baseValue: 150),
FishTemplate(name: '龙虾', emoji: '🦞', rarity: Rarity.epic, baseIncome: 18, baseValue: 250),
FishTemplate(name: '水母', emoji: '🪼', rarity: Rarity.epic, baseIncome: 14, baseValue: 180),
FishTemplate(name: '乌贼', emoji: '🦑', rarity: Rarity.epic, baseIncome: 16, baseValue: 220),
// ... 共9种

// 传说 - 神话生物
FishTemplate(name: '美人鱼', emoji: '🧜‍♀️', rarity: Rarity.legendary, baseIncome: 50, baseValue: 1000),
FishTemplate(name: '龙王', emoji: '🐉', rarity: Rarity.legendary, baseIncome: 100, baseValue: 2000),
FishTemplate(name: '黄金鱼', emoji: '✨', rarity: Rarity.legendary, baseIncome: 80, baseValue: 1500),
FishTemplate(name: '凤凰鱼', emoji: '🔥', rarity: Rarity.legendary, baseIncome: 70, baseValue: 1200),
FishTemplate(name: '冰霜鱼', emoji: '❄️', rarity: Rarity.legendary, baseIncome: 75, baseValue: 1300),
// ... 共9种
```

### 3.2 Boss 扩充 (4 → 12)

分为三个难度层级：

#### Tier 1: 初级 Boss (推荐战力 100-500)

| Boss | HP | 攻击 | 防御 | 战力 | 奖励 |
|------|-----|------|------|------|------|
| 🦀 螃蟹将军 | 500 | 20 | 5 | 100 | 100金币 + 稀有鱼苗 |
| 🦐 虾兵统领 | 800 | 25 | 8 | 200 | 200金币 + 材料 |
| 🐚 贝壳守卫 | 1200 | 30 | 15 | 350 | 300金币 + 稀有鱼苗x2 |
| 🐡 河豚队长 | 1800 | 40 | 10 | 500 | 400金币 + 材料 |

#### Tier 2: 中级 Boss (推荐战力 500-2000)

| Boss | HP | 攻击 | 防御 | 战力 | 奖励 |
|------|-----|------|------|------|------|
| 🦈 鲨鱼海盗 | 2000 | 50 | 15 | 500 | 500金币 + 史诗鱼苗 |
| 🐙 章鱼魔王 | 5000 | 70 | 25 | 1000 | 1500金币 + 史诗鱼苗x2 |
| 🐋 鲸鱼领主 | 8000 | 100 | 30 | 1500 | 2000金币 + 材料 |
| 🐢 千年龟仙 | 10000 | 60 | 50 | 2000 | 2500金币 + 史诗鱼苗 |

#### Tier 3: 高级 Boss (推荐战力 2000+)

| Boss | HP | 攻击 | 防御 | 战力 | 奖励 |
|------|-----|------|------|------|------|
| 🐙 深海霸主 | 20000 | 150 | 40 | 3000 | 5000金币 + 传说鱼苗 |
| 🦑 炼狱乌贼 | 30000 | 180 | 35 | 4000 | 8000金币 + 神器碎片 |
| 🧜‍♀️ 海妖女王 | 40000 | 200 | 50 | 5000 | 10000金币 + 传说鱼苗 |
| 🐉 海龙王 | 50000 | 250 | 60 | 8000 | 20000金币 + 传说鱼苗 + 神器 |

### 3.3 成就扩充 (10 → 40)

#### 钓鱼成就线 (10个)

```dart
Achievement(id: 'catch_1', name: '初出茅庐', description: '钓到第一条鱼', targetValue: 1, rewardCoins: 50),
Achievement(id: 'catch_10', name: '小试牛刀', description: '钓到10条鱼', targetValue: 10, rewardCoins: 100),
Achievement(id: 'catch_50', name: '渐入佳境', description: '钓到50条鱼', targetValue: 50, rewardCoins: 300),
Achievement(id: 'catch_100', name: '钓鱼达人', description: '钓到100条鱼', targetValue: 100, rewardCoins: 500),
Achievement(id: 'catch_500', name: '钓鱼高手', description: '钓到500条鱼', targetValue: 500, rewardCoins: 2000),
Achievement(id: 'catch_1000', name: '钓鱼大师', description: '钓到1000条鱼', targetValue: 1000, rewardCoins: 5000),
Achievement(id: 'catch_5000', name: '钓鱼宗师', description: '钓到5000条鱼', targetValue: 5000, rewardCoins: 20000),
Achievement(id: 'catch_legendary_1', name: '传说猎人', description: '钓到1条传说鱼', targetValue: 1, rewardCoins: 1000),
Achievement(id: 'catch_legendary_10', name: '传说收藏家', description: '钓到10条传说鱼', targetValue: 10, rewardCoins: 10000),
Achievement(id: 'catch_all_types', name: '图鉴大师', description: '收集所有种类的鱼', targetValue: 36, rewardCoins: 50000),
```

#### 战斗成就线 (10个)

```dart
Achievement(id: 'boss_1', name: '初战告捷', description: '击败第一个Boss', targetValue: 1, rewardCoins: 100),
Achievement(id: 'boss_5', name: 'Boss猎人', description: '击败5个Boss', targetValue: 5, rewardCoins: 500),
Achievement(id: 'boss_10', name: 'Boss克星', description: '击败10个Boss', targetValue: 10, rewardCoins: 2000),
Achievement(id: 'boss_all', name: '海王', description: '击败所有Boss', targetValue: 12, rewardCoins: 10000),
Achievement(id: 'boss_tier3', name: '深渊征服者', description: '击败所有Tier 3 Boss', targetValue: 4, rewardCoins: 5000),
Achievement(id: 'boss_no_damage', name: '无伤通关', description: '无伤击败任意Boss', targetValue: 1, rewardCoins: 1000),
Achievement(id: 'boss_speed', name: '速通大师', description: '10秒内击败任意Boss', targetValue: 1, rewardCoins: 2000),
Achievement(id: 'combo_50', name: '连击大师', description: '单场战斗达成50连击', targetValue: 50, rewardCoins: 500),
Achievement(id: 'boss_solo', name: '独孤求败', description: '用1条鱼击败Boss', targetValue: 1, rewardCoins: 3000),
Achievement(id: 'boss_low_power', name: '以弱胜强', description: '以低于推荐战力击败Boss', targetValue: 1, rewardCoins: 2000),
```

#### 经济成就线 (10个)

```dart
Achievement(id: 'coins_1000', name: '小富翁', description: '累计获得1000金币', targetValue: 1000, rewardCoins: 100),
Achievement(id: 'coins_10000', name: '小财主', description: '累计获得10000金币', targetValue: 10000, rewardCoins: 500),
Achievement(id: 'coins_100000', name: '大富翁', description: '累计获得100000金币', targetValue: 100000, rewardCoins: 2000),
Achievement(id: 'coins_1000000', name: '百万富翁', description: '累计获得1000000金币', targetValue: 1000000, rewardCoins: 10000),
Achievement(id: 'income_10', name: '小本生意', description: '达到10金币/秒收入', targetValue: 10, rewardCoins: 200),
Achievement(id: 'income_100', name: '生意兴隆', description: '达到100金币/秒收入', targetValue: 100, rewardCoins: 1000),
Achievement(id: 'income_1000', name: '财源滚滚', description: '达到1000金币/秒收入', targetValue: 1000, rewardCoins: 5000),
Achievement(id: 'sell_100', name: '鱼贩子', description: '出售100条鱼', targetValue: 100, rewardCoins: 300),
Achievement(id: 'sell_legendary', name: '挥金如土', description: '出售一条传说鱼', targetValue: 1, rewardCoins: 500),
Achievement(id: 'upgrade_all', name: '基建狂魔', description: '所有建筑升到10级', targetValue: 10, rewardCoins: 5000),
```

#### 收集成就线 (10个)

```dart
Achievement(id: 'fish_10', name: '小小收藏家', description: '拥有10条鱼宠', targetValue: 10, rewardCoins: 200),
Achievement(id: 'fish_50', name: '收藏家', description: '拥有50条鱼宠', targetValue: 50, rewardCoins: 1000),
Achievement(id: 'fish_100', name: '大收藏家', description: '拥有100条鱼宠', targetValue: 100, rewardCoins: 5000),
Achievement(id: 'rare_5', name: '稀有收藏家', description: '拥有5条稀有鱼', targetValue: 5, rewardCoins: 500),
Achievement(id: 'rare_20', name: '稀有猎人', description: '拥有20条稀有鱼', targetValue: 20, rewardCoins: 2000),
Achievement(id: 'epic_5', name: '史诗收藏家', description: '拥有5条史诗鱼', targetValue: 5, rewardCoins: 2000),
Achievement(id: 'epic_10', name: '史诗猎人', description: '拥有10条史诗鱼', targetValue: 10, rewardCoins: 5000),
Achievement(id: 'legendary_1', name: '传说收藏家', description: '拥有1条传说鱼', targetValue: 1, rewardCoins: 5000),
Achievement(id: 'legendary_5', name: '传说猎人', description: '拥有5条传说鱼', targetValue: 5, rewardCoins: 20000),
Achievement(id: 'legendary_all', name: '神话收藏家', description: '收集所有传说鱼', targetValue: 9, rewardCoins: 100000),
```

---

## 四、Phase 3: 深度玩法

### 4.1 随机事件系统

```dart
// lib/models/game_event.dart (扩展)

/// 随机事件类型
enum RandomEventType {
  merchant,     // 神秘商人
  treasure,     // 宝箱
  whirlpool,    // 漩涡
  fishSwarm,    // 鱼群
  bossInvasion, // Boss入侵
}

/// 随机事件
class RandomEvent {
  final String id;
  final RandomEventType type;
  final String title;
  final String description;
  final String emoji;
  final Duration duration;
  final EventChoice? choice;

  bool isExpired() => DateTime.now().isAfter(expireTime);
}

/// 事件选择
class EventChoice {
  final String option1;
  final String option2;
  final EventResult result1;
  final EventResult result2;
}

/// 事件结果
class EventResult {
  final String description;
  final List<Reward> rewards;
  final List<String> penalties;  // 可能的惩罚
}
```

#### 随机事件示例

```dart
// 神秘商人
RandomEvent(
  id: 'mysterious_merchant',
  type: RandomEventType.merchant,
  title: '神秘商人',
  description: '一位神秘的商人出现在你的渔场...',
  emoji: '🧙',
  duration: Duration(minutes: 5),
  choice: EventChoice(
    option1: '购买稀有鱼苗 (100金币)',
    option2: '离开',
    result1: EventResult(
      description: '商人神秘地笑了，递给你一条稀有鱼苗...',
      rewards: [RareFishReward(1)],
    ),
    result2: EventResult(
      description: '商人摇摇头，消失在迷雾中...',
    ),
  ),
),

// 宝箱
RandomEvent(
  id: 'treasure_chest',
  type: RandomEventType.treasure,
  title: '发现宝箱',
  description: '你在海边发现了一个古老的宝箱！',
  emoji: '📦',
  duration: Duration(minutes: 2),
  choice: EventChoice(
    option1: '打开宝箱',
    option2: '忽略',
    result1: EventResult(
      description: '宝箱打开了！里面闪烁着金光...',
      rewards: [CoinReward(500), MaterialReward(10)],
      penalties: ['宝箱是陷阱！失去50金币'],
    ),
    result2: EventResult(
      description: '你决定不冒险，继续钓鱼...',
    ),
  ),
),
```

### 4.2 每周挑战系统

```dart
// lib/services/weekly_challenge.dart

/// 每周挑战
class WeeklyChallenge {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final ChallengeDifficulty difficulty;
  final List<ChallengeTask> tasks;
  final List<Reward> completionRewards;

  double get progress => tasks.fold(0, (sum, t) => sum + t.progress) / tasks.length;
}

/// 挑战任务
class ChallengeTask {
  final String description;
  final int targetValue;
  final int currentValue;

  double get progress => currentValue / targetValue;
}

/// 挑战难度
enum ChallengeDifficulty {
  easy,    // 简单，奖励一般
  normal,  // 普通，奖励中等
  hard,    // 困难，奖励丰厚
  extreme, // 极限，奖励顶级
}
```

### 4.3 排行榜系统

```dart
// lib/services/leaderboard_service.dart

/// 排行榜类型
enum LeaderboardType {
  totalCoins,      // 总金币
  fishCaught,      // 钓鱼数量
  bossDefeated,    // Boss击败数
  achievementScore,// 成就积分
  collectionScore, // 收集积分
}

/// 排行榜条目
class LeaderboardEntry {
  final String playerName;
  final int score;
  final int rank;
  final DateTime updatedAt;
}

/// 本地排行榜（可扩展为在线）
class LocalLeaderboard {
  Map<LeaderboardType, List<LeaderboardEntry>> boards;

  void updateScore(LeaderboardType type, int score);
  List<LeaderboardEntry> getTopEntries(LeaderboardType type, int limit);
}
```

---

## 五、实施计划

### 5.1 时间表

| 阶段 | 任务 | 预计时间 | 优先级 |
|------|------|----------|--------|
| Phase 1 | 新手引导系统 | 2天 | P0 |
| Phase 1 | 战斗文案引擎 | 1天 | P0 |
| Phase 1 | 目标提示系统 | 1天 | P1 |
| Phase 2 | 鱼类扩充 | 1天 | P0 |
| Phase 2 | Boss扩充 | 1天 | P0 |
| Phase 2 | 成就扩充 | 1天 | P1 |
| Phase 2 | 装备扩充 | 1天 | P2 |
| Phase 3 | 随机事件系统 | 2天 | P1 |
| Phase 3 | 每周挑战 | 1天 | P2 |
| Phase 3 | 排行榜 | 1天 | P2 |

### 5.2 文件变更清单

**新增文件：**
- `lib/services/tutorial_service.dart` - 新手引导
- `lib/models/battle_narrative.dart` - 战斗文案
- `lib/services/goal_service.dart` - 目标系统
- `lib/models/random_event.dart` - 随机事件
- `lib/services/weekly_challenge.dart` - 每周挑战
- `lib/services/leaderboard_service.dart` - 排行榜
- `lib/widgets/tutorial_overlay.dart` - 引导UI组件
- `lib/widgets/goal_panel.dart` - 目标面板

**修改文件：**
- `lib/main.dart` - 添加引导入口
- `lib/screens/world_screen.dart` - 集成引导、目标提示
- `lib/providers/battle_provider.dart` - 集成战斗文案
- `lib/utils/fish_data.dart` - 扩充鱼类
- `lib/models/boss.dart` - 扩充Boss + 文案配置
- `lib/models/achievement.dart` - 扩充成就

---

## 六、验收标准

### Phase 1 验收
- [ ] 新玩家首次进入有引导流程
- [ ] 功能按引导步骤解锁
- [ ] 战斗有开场白、攻击台词、结束文案
- [ ] 界面有当前目标提示

### Phase 2 验收
- [ ] 鱼类达到36种
- [ ] Boss达到12个
- [ ] 成就达到40个
- [ ] 装备模板达到30个

### Phase 3 验收
- [ ] 随机事件正常触发
- [ ] 每周挑战可以参与
- [ ] 排行榜可以查看

---

**文档版本：** v1.0
**最后更新：** 2026-03-27
**作者：** Claude (P10 视角)
