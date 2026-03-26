# 🐟 Gallifrey's Fish Farm | 加利弗雷鱼农场

[English](#english) | [中文](#中文)

---

## 中文

### 🎮 游戏简介

一款开源的宠物钓鱼挂机游戏，灵感来自开罗游戏（如合战忍者村）。使用 Flutter 开发，支持 Web 和 iOS 平台。

### ✨ 核心玩法

```
🎣 挂机钓鱼 → 🐟 收集鱼宠 → 💼 鱼宠工作赚钱 → ⚔️ 战斗打Boss → 🏗️ 建设鱼村 → 🎣 钓更好的鱼
```

### 🎯 游戏特色

| 功能 | 描述 |
|------|------|
| 🌊 **俯视鱼村场景** | 看到鱼宠在海边、村庄、山区真实移动和工作 |
| ⚔️ **横版自动战斗** | 类似合战忍者村，鱼宠自动攻击Boss |
| 🏗️ **建筑系统** | 解锁和升级码头、商店、农田、矿场、训练场、神殿 |
| 👹 **Boss系统** | 挑战螃蟹将军、鲨鱼海盗、章鱼魔王、海龙王 |
| 📈 **养成系统** | 喂食升级鱼宠，提升战斗力 |
| 💾 **自动存档** | 本地存档，支持离线收益 |

### 📱 运行方式

```bash
# 克隆仓库
git clone https://github.com/gallifreyCar/gallifreys-fish-farm.git
cd gallifreys-fish-farm

# 安装依赖
flutter pub get

# Web版运行
flutter run -d chrome

# iOS模拟器运行
flutter run -d ios

# 构建Web版
flutter build web
```

### 🛠️ 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart
- **状态管理**: Riverpod
- **本地存储**: SharedPreferences
- **平台**: Web / iOS

### 📁 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── fish.dart            # 鱼宠模型（含战斗属性）
│   ├── player.dart          # 玩家模型
│   ├── building.dart        # 建筑模型
│   ├── boss.dart            # Boss模型
│   └── battle.dart          # 战斗模型
├── providers/                # 状态管理
│   ├── game_provider.dart   # 游戏核心逻辑
│   ├── world_provider.dart  # 场景管理
│   └── battle_provider.dart # 战斗管理
├── screens/                  # 页面
│   └── world_screen.dart    # 主场景
├── widgets/                  # 组件
│   ├── world_renderer.dart  # 场景渲染器
│   └── battle_arena.dart    # 战斗竞技场
└── services/                 # 服务
    └── save_service.dart    # 存档服务
```

### 🐟 鱼宠系统

鱼宠有4种稀有度：

| 稀有度 | 颜色 | 基础战力 |
|--------|------|----------|
| 普通 | 灰色 | 较低 |
| 稀有 | 蓝色 | 中等 |
| 史诗 | 紫色 | 较高 |
| 传说 | 金色 | 最高 |

每条鱼都有独特的属性：
- ❤️ 生命值 (HP)
- ⚔️ 攻击力
- 🛡️ 防御力
- 💨 移动速度

### 🏗️ 建筑系统

| 建筑 | 功能 | 解锁费用 |
|------|------|----------|
| 🎣 钓鱼码头 | 增加钓鱼产出 | 免费 |
| 🏪 杂货铺 | 产出金币 | 100金币 |
| 🌾 鱼食田 | 产出鱼食 | 200金币 |
| ⛏️ 珍珠矿 | 产出材料 | 500金币 |
| ⚔️ 训练场 | 提升鱼宠属性 | 1000金币 |
| 🏛️ 召唤神殿 | 召唤稀有鱼 | 2000金币 |

### 👹 Boss列表

| Boss | 生命值 | 攻击力 | 推荐战力 |
|------|--------|--------|----------|
| 🦀 螃蟹将军 | 500 | 20 | 100 |
| 🦈 鲨鱼海盗 | 2000 | 50 | 500 |
| 🐙 章鱼魔王 | 8000 | 100 | 1500 |
| 🐉 海龙王 | 30000 | 200 | 5000 |

### 📜 开源协议

MIT License - 欢迎贡献代码！

---

## English

### 🎮 Game Introduction

An open-source idle fishing pet game inspired by Kairosoft games (like Ninja Village). Built with Flutter, supporting Web and iOS platforms.

### ✨ Core Gameplay Loop

```
🎣 Idle Fishing → 🐟 Collect Fish Pets → 💼 Assign Jobs → ⚔️ Battle Bosses → 🏗️ Build Village → 🎣 Catch Better Fish
```

### 🎯 Game Features

| Feature | Description |
|---------|-------------|
| 🌊 **Top-down Village View** | Watch your fish pets move and work in seaside, village, and mountain areas |
| ⚔️ **Side-scrolling Auto-Battle** | Similar to Ninja Village, fish pets automatically attack bosses |
| 🏗️ **Building System** | Unlock and upgrade docks, shops, farms, mines, training grounds, and temples |
| 👹 **Boss System** | Challenge the Crab General, Shark Pirate, Octopus Demon, and Dragon King |
| 📈 **Pet Development** | Feed and level up fish pets to boost combat power |
| 💾 **Auto-Save** | Local save with offline income support |

### 📱 How to Run

```bash
# Clone repository
git clone https://github.com/gallifreyCar/gallifreys-fish-farm.git
cd gallifreys-fish-farm

# Install dependencies
flutter pub get

# Run on Web
flutter run -d chrome

# Run on iOS Simulator
flutter run -d ios

# Build for Web
flutter build web
```

### 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Riverpod
- **Local Storage**: SharedPreferences
- **Platforms**: Web / iOS

### 🐟 Fish Pet System

Fish pets come in 4 rarities:

| Rarity | Color | Base Power |
|--------|-------|------------|
| Common | Gray | Low |
| Rare | Blue | Medium |
| Epic | Purple | High |
| Legendary | Gold | Highest |

Each fish has unique stats:
- ❤️ HP (Health Points)
- ⚔️ Attack
- 🛡️ Defense
- 💨 Speed

### 🏗️ Building System

| Building | Function | Unlock Cost |
|----------|----------|-------------|
| 🎣 Fishing Dock | Increase fishing output | Free |
| 🏪 Shop | Generate coins | 100 coins |
| 🌾 Farm | Generate fish food | 200 coins |
| ⛏️ Mine | Generate materials | 500 coins |
| ⚔️ Training Ground | Boost fish stats | 1000 coins |
| 🏛️ Temple | Summon rare fish | 2000 coins |

### 👹 Boss List

| Boss | HP | Attack | Recommended Power |
|------|-----|--------|-------------------|
| 🦀 Crab General | 500 | 20 | 100 |
| 🦈 Shark Pirate | 2000 | 50 | 500 |
| 🐙 Octopus Demon | 8000 | 100 | 1500 |
| 🐉 Dragon King | 30000 | 200 | 5000 |

### 📜 License

MIT License - Contributions welcome!

---

Made with 💙 by [gallifreyCar](https://github.com/gallifreyCar)
