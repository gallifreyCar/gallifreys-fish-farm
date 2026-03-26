import '../models/fish.dart';

/// 游戏常量配置
class GameConstants {
  // 钓鱼相关
  static const int baseFishingIntervalSeconds = 5;  // 基础钓鱼间隔
  static const int offlineIncomeCapHours = 8;        // 离线收益上限（小时）

  // 稀有度颜色
  static const rarityColors = {
    Rarity.common: 0xFF9E9E9E,    // 灰色
    Rarity.rare: 0xFF2196F3,      // 蓝色
    Rarity.epic: 0xFF9C27B0,      // 紫色
    Rarity.legendary: 0xFFFFD700, // 金色
  };

  // 稀有度名称
  static const rarityNames = {
    Rarity.common: '普通',
    Rarity.rare: '稀有',
    Rarity.epic: '史诗',
    Rarity.legendary: '传说',
  };

  // 工作类型名称和图标
  static const jobNames = {
    JobType.idle: '闲置',
    JobType.fishing: '钓鱼助手',
    JobType.farming: '种田',
    JobType.mining: '挖矿',
    JobType.shop: '看店',
  };

  static const jobEmojis = {
    JobType.idle: '😴',
    JobType.fishing: '🎣',
    JobType.farming: '🌾',
    JobType.mining: '⛏️',
    JobType.shop: '🏪',
  };
}
