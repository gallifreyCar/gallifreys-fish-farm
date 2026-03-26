/// 战斗文案引擎
library;

import 'dart:math';
import '../models/boss.dart';
import '../models/fish.dart';

/// Boss 战斗文案配置
class BossBattleNarrative {
  final String bossId;

  /// 开场白（随机选一条）
  final List<String> introLines;

  /// 攻击台词
  final List<String> attackLines;

  /// 受击台词
  final List<String> hitLines;

  /// 低血量台词（HP < 30%）
  final List<String> lowHpLines;

  /// 死亡台词
  final List<String> deathLines;

  /// 胜利（玩家失败）台词
  final List<String> victoryLines;

  /// 技能台词（如果有特殊技能）
  final Map<String, List<String>> skillLines;

  const BossBattleNarrative({
    required this.bossId,
    this.introLines = const [],
    this.attackLines = const [],
    this.hitLines = const [],
    this.lowHpLines = const [],
    this.deathLines = const [],
    this.victoryLines = const [],
    this.skillLines = const {},
  });
}

/// 战斗叙事生成器
class BattleNarrator {
  static final Random _random = Random();

  /// 所有 Boss 文案配置
  static const Map<String, BossBattleNarrative> bossNarratives = {
    // ========== Tier 1: 初级 Boss ==========

    // 螃蟹将军
    'crab_general': BossBattleNarrative(
      bossId: 'crab_general',
      introLines: [
        '🦀 "哼，又来了一个不自量力的家伙！"',
        '🦀 "我的钳子已经饥渴难耐了！"',
        '🦀 "想挑战我？先过我这一关！"',
        '🦀 螃蟹将军挥舞着巨大的钳子，发出咔咔的响声...',
      ],
      attackLines: [
        '🦀 螃蟹将军挥舞巨钳，横扫而来！',
        '🦀 "尝尝我的蟹钳风暴！"',
        '🦀 螃蟹将军猛地夹击！',
        '🦀 "看我的双钳连击！"',
        '🦀 巨大的钳子向你砸来！',
      ],
      hitLines: [
        '🦀 "嘶...这一击有点疼！"',
        '🦀 "你还挺能打的嘛！"',
        '🦀 "哼，这点伤害不算什么！"',
        '🦀 螃蟹将军的壳上留下了裂痕...',
      ],
      lowHpLines: [
        '🦀 "不可能...我怎么会输给这种对手！"',
        '🦀 螃蟹将军的钳子开始颤抖...',
        '🦀 "你们这些小鱼...竟然能伤到我！"',
      ],
      deathLines: [
        '🦀 "这...不可能...我的钳子..."',
        '🦀 螃蟹将军倒下了，掉落了一些金币和材料...',
        '🦀 "下次...我一定会回来的..."',
      ],
      victoryLines: [
        '🦀 "哈哈哈！这就是实力的差距！"',
        '🦀 "下次再来挑战吧，如果你还敢的话！"',
        '🦀 "太弱了，回去练练再来吧！"',
      ],
    ),

    // 虾兵统领
    'shrimp_commander': BossBattleNarrative(
      bossId: 'shrimp_commander',
      introLines: [
        '🦐 "报告！发现入侵者！全军准备！"',
        '🦐 "想过去？先问问我手里的长枪！"',
        '🦐 虾兵统领举起长枪，身后是整齐的虾兵方阵...',
      ],
      attackLines: [
        '🦐 "全军突击！"',
        '🦐 虾兵统领的长枪刺出！',
        '🦐 "包围他们！"',
        '🦐 一队虾兵发起冲锋！',
      ],
      hitLines: [
        '🦐 "伤亡报告...还能坚持！"',
        '🦐 "这...这是什么力量！"',
        '🦐 "援军！我们需要援军！"',
      ],
      lowHpLines: [
        '🦐 "将军...我们快撑不住了..."',
        '🦐 虾兵统领的盔甲已经破碎...',
        '🦐 "撤退...全军撤退！"',
      ],
      deathLines: [
        '🦐 "将军...我尽力了..."',
        '🦐 虾兵统领倒下，虾兵们四散奔逃...',
        '🦐 "这就是...败北的滋味吗..."',
      ],
      victoryLines: [
        '🦐 "报告！敌军已被击溃！"',
        '🦐 "哈！小小的挑战者而已！"',
        '🦐 "继续巡逻！"',
      ],
    ),

    // 贝壳守卫
    'shell_guardian': BossBattleNarrative(
      bossId: 'shell_guardian',
      introLines: [
        '🐚 "......"',
        '🐚 贝壳守卫缓缓张开，露出里面闪亮的珍珠...',
        '🐚 "入侵者...退去..."',
      ],
      attackLines: [
        '🐚 贝壳守卫释放出一道水波！',
        '🐚 "水...刃..."',
        '🐚 珍珠发出耀眼的光芒！',
        '🐚 贝壳猛地合拢，发出巨大的声响！',
      ],
      hitLines: [
        '🐚 "......"',
        '🐚 贝壳上出现了裂纹...',
        '🐚 "痛..."',
      ],
      lowHpLines: [
        '🐚 "珍珠...要碎了..."',
        '🐚 贝壳守卫的光芒开始黯淡...',
        '🐚 "保护...珍珠..."',
      ],
      deathLines: [
        '🐚 贝壳守卫碎裂，珍珠滚落出来...',
        '🐚 "保重..."',
        '🐚 守卫消失了，留下了一堆宝物...',
      ],
      victoryLines: [
        '🐚 "入侵者...已清除..."',
        '🐚 贝壳守卫缓缓合上...',
        '🐚 "珍珠...安全..."',
      ],
    ),

    // 河豚队长
    'pufferfish_captain': BossBattleNarrative(
      bossId: 'pufferfish_captain',
      introLines: [
        '🐡 "别看我小，我可厉害了！"',
        '🐡 "嘿嘿，让我来教教你什么叫真正的战斗！"',
        '🐡 河豚队长鼓起身体，浑身都是刺...',
      ],
      attackLines: [
        '🐡 "毒刺攻击！"',
        '🐡 河豚队长喷射毒液！',
        '🐡 "看我变大！"',
        '🐡 一根尖刺飞向你！',
      ],
      hitLines: [
        '🐡 "哎哟！别打我！"',
        '🐡 "好疼好疼！我要生气了！"',
        '🐡 "你们欺负小鱼！"',
      ],
      lowHpLines: [
        '🐡 "我...我不行了..."',
        '🐡 河豚队长开始泄气...',
        '🐡 "救命...救命..."',
      ],
      deathLines: [
        '🐡 "下次...我要变大再来..."',
        '🐡 河豚队长泄气了，变成普通大小飘走...',
        '🐡 "你们等着..."',
      ],
      victoryLines: [
        '🐡 "哈哈哈！我赢了！"',
        '🐡 "小看我的下场！"',
        '🐡 "快滚快滚！"',
      ],
    ),

    // ========== Tier 2: 中级 Boss ==========

    // 鲨鱼海盗
    'shark_pirate': BossBattleNarrative(
      bossId: 'shark_pirate',
      introLines: [
        '🦈 "哈哈哈！又有猎物上门了！"',
        '🦈 "我是这片海域的海盗王！你算什么东西？"',
        '🦈 鲨鱼海盗拔出弯刀，眼中闪烁着贪婪的光芒...',
      ],
      attackLines: [
        '🦈 "鲨鱼撕咬！"',
        '🦈 弯刀划破水面！',
        '🦈 "尝尝海盗的厉害！"',
        '🦈 "大海啸！"',
        '🦈 鲨鱼海盗召唤海浪！',
      ],
      hitLines: [
        '🦈 "哼，这点伤算什么！"',
        '🦈 "你们这些小鱼小虾！"',
        '🦈 "我可是海盗王！"',
      ],
      lowHpLines: [
        '🦈 "不可能...我怎么会输！"',
        '🦈 鲨鱼海盗的眼罩掉落，露出伤痕累累的眼睛...',
        '🦈 "我的宝藏...我的荣耀..."',
      ],
      deathLines: [
        '🦈 "我的海盗生涯...到此为止了吗..."',
        '🦈 鲨鱼海盗的弯刀落地，他缓缓沉入海底...',
        '🦈 "记住...我才是...真正的海盗王..."',
      ],
      victoryLines: [
        '🦈 "哈哈哈！不堪一击！"',
        '🦈 "你的金币归我了！"',
        '🦈 "回去练个几十年再来吧！"',
      ],
    ),

    // 章鱼魔王
    'octopus_demon': BossBattleNarrative(
      bossId: 'octopus_demon',
      introLines: [
        '🐙 "欢迎来到我的领域，渺小的生物..."',
        '🐙 "我有八只手，你只有两只，你觉得你能赢？"',
        '🐙 章鱼魔王的八条触手在水中舞动，散发着诡异的紫光...',
      ],
      attackLines: [
        '🐙 "触手风暴！"',
        '🐙 "毒墨喷射！"',
        '🐙 章鱼魔王用三条触手同时攻击！',
        '🐙 "深渊之握！"',
        '🐙 墨汁弥漫整个战场！',
      ],
      hitLines: [
        '🐙 "嘶...不错，但还不够！"',
        '🐙 "我的触手会再生的！"',
        '🐙 "你砍得断一只，砍不断八只！"',
      ],
      lowHpLines: [
        '🐙 "不可能...我是深渊的主人..."',
        '🐙 章鱼魔王的触手开始断裂...',
        '🐙 "你们这些蝼蚁..."',
      ],
      deathLines: [
        '🐙 "深渊...在召唤我..."',
        '🐙 章鱼魔王的身体化作黑烟消散...',
        '🐙 "我会回来的...从深渊中归来..."',
      ],
      victoryLines: [
        '🐙 "哈哈哈！力量悬殊！"',
        '🐙 "我的触手，不是你能对付的！"',
        '🐙 "回到海底去吧，失败者！"',
      ],
    ),

    // 鲸鱼领主
    'whale_lord': BossBattleNarrative(
      bossId: 'whale_lord',
      introLines: [
        '🐋 "......"',
        '🐋 巨大的身影遮蔽了阳光，鲸鱼领主缓缓游来...',
        '🐋 "你...打扰了我的沉眠..."',
      ],
      attackLines: [
        '🐋 "巨浪冲击！"',
        '🐋 鲸鱼领主的尾巴掀起滔天巨浪！',
        '🐋 "深海之歌！"',
        '🐋 一道声波穿透水面！',
        '🐋 "挤压！"',
      ],
      hitLines: [
        '🐋 "......"',
        '🐋 "有些...疼痛..."',
        '🐋 "你...有些实力..."',
      ],
      lowHpLines: [
        '🐋 "我...老了..."',
        '🐋 鲸鱼领主的动作变得迟缓...',
        '🐋 "也许...该休息了..."',
      ],
      deathLines: [
        '🐋 "谢谢你...让我解脱..."',
        '🐋 鲸鱼领主化作无数光点消散...',
        '🐋 "大海...在召唤我..."',
      ],
      victoryLines: [
        '🐋 "回去吧...孩子..."',
        '🐋 "你还太年轻..."',
        '🐋 鲸鱼领主缓缓游走...',
      ],
    ),

    // 千年龟仙
    'ancient_turtle': BossBattleNarrative(
      bossId: 'ancient_turtle',
      introLines: [
        '🐢 "年轻人，你知道你面对的是什么吗？"',
        '🐢 "我在这片海域已经生活了一千年..."',
        '🐢 千年龟仙缓缓睁开眼睛，眼神深邃如星空...',
      ],
      attackLines: [
        '🐢 "龟派气功！"',
        '🐢 千年龟仙的壳旋转起来！',
        '🐢 "水之护盾！"',
        '🐢 "千年智慧，千年力量！"',
        '🐢 一道能量波从龟壳发出！',
      ],
      hitLines: [
        '🐢 "不错...你有些天赋..."',
        '🐢 "但是还不够！"',
        '乌龟的壳上留下了一道痕迹...',
      ],
      lowHpLines: [
        '🐢 "千年...终于要结束了吗..."',
        '🐢 千年龟仙的眼中流下了泪水...',
        '🐢 "也许...是时候传承了..."',
      ],
      deathLines: [
        '🐢 "我等这一刻...已经等了很久..."',
        '🐢 千年龟仙将力量注入一颗珍珠...',
        '🐢 "拿着它...继承我的意志..."',
      ],
      victoryLines: [
        '🐢 "年轻人，回去修炼吧..."',
        '🐢 "你还差得远呢..."',
        '🐢 千年龟仙闭上眼睛，继续沉睡...',
      ],
    ),

    // ========== Tier 3: 高级 Boss ==========

    // 深海霸主
    'deep_sea_overlord': BossBattleNarrative(
      bossId: 'deep_sea_overlord',
      introLines: [
        '🦑 "欢迎来到深渊...在这里，没有光，没有希望..."',
        '🦑 "我已经在这片黑暗中等待了万年..."',
        '🦑 深海霸主的身影如同噩梦，无数眼睛闪烁着诡异的光芒...',
      ],
      attackLines: [
        '🦑 "深渊凝视！"',
        '🦑 "触手地狱！"',
        '🦑 无数触手从黑暗中伸出！',
        '🦑 "绝望之墨！"',
        '🦑 "你知道深渊里有什么吗？"',
      ],
      hitLines: [
        '🦑 "这点伤害...我在深渊中承受过无数倍！"',
        '🦑 "你无法理解...深渊的力量！"',
        '🦑 "光明的攻击...对我无效！"',
      ],
      lowHpLines: [
        '🦑 "不...我不能再回到那个地方..."',
        '🦑 深海霸主的身体开始崩解...',
        '🦑 "深渊在呼唤我...它在呼唤我..."',
      ],
      deathLines: [
        '🦑 "终于...我解脱了..."',
        '🦑 深海霸主化作黑色的烟雾消散...',
        '🦑 "谢谢你...终结我的噩梦..."',
      ],
      victoryLines: [
        '🦑 "深渊...会吞噬一切！"',
        '🦑 "你就是下一个深渊的居民！"',
        '🦑 "黑暗...降临！"',
      ],
    ),

    // 炼狱乌贼
    'inferno_squid': BossBattleNarrative(
      bossId: 'inferno_squid',
      introLines: [
        '🦑 "嘎嘎嘎...我闻到了恐惧的味道！"',
        '🦑 "欢迎来到炼狱！这里没有怜悯！"',
        '🦑 炼狱乌贼周身燃烧着蓝色的火焰，触手上流淌着岩浆...',
      ],
      attackLines: [
        '🦑 "地狱火！"',
        '🦑 "岩浆喷射！"',
        '🦑 炼狱乌贼召唤火雨！',
        '🦑 "燃烧吧！燃烧吧！"',
        '🦑 触手带着烈焰横扫！',
      ],
      hitLines: [
        '🦑 "火...只会让我更强大！"',
        '🦑 "哈哈哈！这点攻击对我来说是养分！"',
        '🦑 "你以为你能熄灭炼狱之火？"',
      ],
      lowHpLines: [
        '🦑 "不...火焰不能熄灭！"',
        '🦑 炼狱乌贼身上的火焰开始闪烁...',
        '🦑 "我的怒火...永不熄灭！"',
      ],
      deathLines: [
        '🦑 "火焰...熄灭了..."',
        '🦑 炼狱乌贼化作灰烬飘散...',
        '🦑 "我会...从地狱归来..."',
      ],
      victoryLines: [
        '🦑 "哈哈哈！化为灰烬吧！"',
        '🦑 "炼狱等待着你！"',
        '🦑 "你的灵魂...是我的燃料！"',
      ],
    ),

    // 海妖女王
    'siren_queen': BossBattleNarrative(
      bossId: 'siren_queen',
      introLines: [
        '🧜‍♀️ "啊...又一个迷失的灵魂..."',
        '🧜‍♀️ "来吧，让我用歌声带你走向永恒的安宁..."',
        '🧜‍♀️ 海妖女王的声音如同天籁，却又带着致命的诱惑...',
      ],
      attackLines: [
        '🧜‍♀️ "倾听我的歌声~"',
        '🧜‍♀️ "沉溺之歌！"',
        '🧜‍♀️ 海妖女王的声音让敌人陷入迷惑！',
        '🧜‍♀️ "波涛之舞！"',
        '🧜‍♀️ "来吧，靠近我..."',
      ],
      hitLines: [
        '🧜‍♀️ "嘶...你的意志比想象中强大..."',
        '🧜‍♀️ "但还是...不够！"',
        '🧜‍♀️ "我不允许...任何人伤害我的容颜！"',
      ],
      lowHpLines: [
        '🧜‍♀️ "我的歌声...无法挽救我吗..."',
        '🧜‍♀️ 海妖女王的眼中流下了珍珠般的眼泪...',
        '🧜‍♀️ "我只是...想找人陪伴..."',
      ],
      deathLines: [
        '🧜‍♀️ "终于...可以安息了..."',
        '🧜‍♀️ 海妖女王的身体化作泡沫消散...',
        '🧜‍♀️ "谢谢你...结束我的诅咒..."',
      ],
      victoryLines: [
        '🧜‍♀️ "永远留在我身边吧~"',
        '🧜‍♀️ "你的灵魂...现在属于我了~"',
        '🧜‍♀️ 海妖女王微笑着，眼神冰冷...',
      ],
    ),

    // 海龙王
    'dragon_king': BossBattleNarrative(
      bossId: 'dragon_king',
      introLines: [
        '🐉 "凡人，你竟敢打扰本座的沉眠？"',
        '🐉 "我已统治这片海域千年，你算什么东西？"',
        '🐉 "来吧，让我看看你的能耐！"',
        '🐉 海龙王张开巨翼，龙鳞在水中闪烁着金光...',
      ],
      attackLines: [
        '🐉 "龙之吐息！"',
        '🐉 海龙王喷出灼热的龙息！',
        '🐉 "海啸之怒！"',
        '🐉 "雷霆万钧！"',
        '🐉 龙爪撕裂水面！',
        '🐉 "跪下！在本座面前！"',
      ],
      hitLines: [
        '🐉 "嗯？这一击...有点意思。"',
        '🐉 "本座承认，你不是普通的对手。"',
        '🐉 "能在龙鳞上留下痕迹的，你是第一个！"',
        '🐉 "凡人...你激怒我了！"',
      ],
      lowHpLines: [
        '🐉 "不可能...凡人怎么可能伤到本座！"',
        '🐉 海龙王的鳞片开始脱落，眼中闪烁着怒火...',
        '🐉 "我的荣耀...我的传说..."',
        '🐉 "不...我不会输给一个凡人！"',
      ],
      deathLines: [
        '🐉 "这...这是命运吗...本座...不甘心..."',
        '🐉 海龙王化作一道金光消散，留下了传说中的神器碎片...',
        '🐉 "你...超越了本座...新的海王..."',
        '🐉 "继承我的力量...守护这片海域..."',
      ],
      victoryLines: [
        '🐉 "正如我所料，你还不够格挑战本座。"',
        '🐉 "回去修炼个几百年再来吧，凡人。"',
        '🐉 "这就是神与凡人的差距！"',
        '🐉 海龙王傲然转身，潜入深海...',
      ],
    ),
  };

  /// 获取开场白
  static String getIntro(Boss boss) {
    final narrative = bossNarratives[boss.id];
    if (narrative == null || narrative.introLines.isEmpty) {
      return '${boss.emoji} ${boss.name} 出现了！';
    }
    return _pickRandom(narrative.introLines);
  }

  /// 获取攻击台词
  static String getAttackLine(Boss boss) {
    final narrative = bossNarratives[boss.id];
    if (narrative == null || narrative.attackLines.isEmpty) {
      return '${boss.emoji} 发动攻击！';
    }
    return _pickRandom(narrative.attackLines);
  }

  /// 获取受击台词
  static String getHitLine(Boss boss) {
    final narrative = bossNarratives[boss.id];
    if (narrative == null || narrative.hitLines.isEmpty) {
      return '${boss.emoji} 受到了伤害！';
    }
    return _pickRandom(narrative.hitLines);
  }

  /// 获取低血量台词
  static String getLowHpLine(Boss boss) {
    final narrative = bossNarratives[boss.id];
    if (narrative == null || narrative.lowHpLines.isEmpty) {
      return '${boss.emoji} 已经摇摇欲坠！';
    }
    return _pickRandom(narrative.lowHpLines);
  }

  /// 获取死亡台词
  static String getDeathLine(Boss boss) {
    final narrative = bossNarratives[boss.id];
    if (narrative == null || narrative.deathLines.isEmpty) {
      return '${boss.emoji} ${boss.name} 被击败了！';
    }
    return _pickRandom(narrative.deathLines);
  }

  /// 获取胜利台词
  static String getVictoryLine(Boss boss) {
    final narrative = bossNarratives[boss.id];
    if (narrative == null || narrative.victoryLines.isEmpty) {
      return '${boss.emoji} 获得了胜利！';
    }
    return _pickRandom(narrative.victoryLines);
  }

  /// 描述普通攻击
  static String describeAttack(Fish attacker, Boss target, int damage) {
    final templates = [
      '${attacker.emoji} 冲向 ${target.emoji}，造成 $damage 点伤害！',
      '${attacker.emoji} 发起攻击！${target.emoji} 受到 $damage 点伤害！',
      '${attacker.emoji} 的攻击命中！造成 $damage 点伤害！',
    ];
    return _pickRandom(templates);
  }

  /// 描述技能激活
  static String describeSkillActivation(Fish fish, int damage, [String? customMessage]) {
    if (customMessage != null) return customMessage;

    final skill = fish.skill;
    if (skill == null) return '';

    switch (skill.type) {
      case SkillType.criticalStrike:
        return '💥 ${fish.emoji} 暴击！造成 $damage 点伤害！';
      case SkillType.lifesteal:
        final heal = (damage * skill.value).round();
        return '🩸 ${fish.emoji} 吸血！恢复 $heal 点生命！';
      case SkillType.rage:
        return '🔥 ${fish.emoji} 狂暴！伤害提升！';
      case SkillType.multiAttack:
        return '⚔️ ${fish.emoji} 连击！额外攻击！';
      case SkillType.heal:
        return '💚 ${fish.emoji} 自愈！';
      case SkillType.dodge:
        return '✨ ${fish.emoji} 完美闪避！';
      case SkillType.shield:
        return '🛡️ ${fish.emoji} 护盾抵挡！';
      case SkillType.counterAttack:
        return '↩️ ${fish.emoji} 反击！';
    }
  }

  /// 描述连击
  static String describeCombo(int comboCount) {
    if (comboCount < 10) return '';
    if (comboCount < 30) return '⚡ 连击 x$comboCount！';
    if (comboCount < 50) return '🔥 超级连击 x$comboCount！';
    return '💥 疯狂连击 x$comboCount！！';
  }

  /// 描述战斗开始
  static String describeBattleStart(Boss boss, List<Fish> team) {
    final teamCount = team.length;
    final teamPower = team.fold<int>(0, (sum, f) => sum + f.power);

    return '${boss.emoji} ${boss.name} 出现了！\n'
           '你的队伍：$teamCount 条鱼宠，总战力 $teamPower\n'
           '推荐战力：${boss.requiredPower}';
  }

  /// 描述战斗胜利
  static String describeVictory(Boss boss, int totalDamage, int maxCombo) {
    return '🎉 胜利！\n'
           '${getDeathLine(boss)}\n'
           '总伤害：$totalDamage\n'
           '最高连击：$maxCombo';
  }

  /// 描述战斗失败
  static String describeDefeat(Boss boss) {
    return '💔 战斗失败...\n'
           '${getVictoryLine(boss)}\n'
           '让你的鱼宠休息一下再来挑战吧！';
  }

  /// 随机选择
  static String _pickRandom(List<String> list) {
    if (list.isEmpty) return '';
    return list[_random.nextInt(list.length)];
  }
}
