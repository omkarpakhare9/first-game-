import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ArenaClashApp());
}

class ArenaClashApp extends StatelessWidget {
  const ArenaClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arena Clash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0E0E1A),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class Champion {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final double baseAtk;
  final double baseHp;
  final double atkSpeed; // attacks per second
  final String skillName;
  final String skillDescription;
  final double skillCooldown;
  final double skillValue;
  final bool skillIsHeal;

  const Champion({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.baseAtk,
    required this.baseHp,
    required this.atkSpeed,
    required this.skillName,
    required this.skillDescription,
    required this.skillCooldown,
    required this.skillValue,
    this.skillIsHeal = false,
  });
}

const List<Champion> kChampions = [
  Champion(
    name: 'Vanguard',
    description: 'Balanced fighter with reliable damage and survivability.',
    icon: Icons.shield,
    color: Colors.lightBlueAccent,
    baseAtk: 12,
    baseHp: 150,
    atkSpeed: 1.1,
    skillName: 'Power Strike',
    skillDescription: 'Deal a solid burst of bonus damage.',
    skillCooldown: 6.0,
    skillValue: 45,
  ),
  Champion(
    name: 'Berserker',
    description: 'Glass cannon. Hits hard and fast, but fragile.',
    icon: Icons.whatshot,
    color: Colors.redAccent,
    baseAtk: 18,
    baseHp: 110,
    atkSpeed: 1.4,
    skillName: 'Rampage',
    skillDescription: 'Unleash a huge damage spike on a longer cooldown.',
    skillCooldown: 8.0,
    skillValue: 75,
  ),
  Champion(
    name: 'Sentinel',
    description: 'Tanky defender. Slow but hard to kill, and self-heals.',
    icon: Icons.security,
    color: Colors.greenAccent,
    baseAtk: 9,
    baseHp: 220,
    atkSpeed: 0.9,
    skillName: 'Second Wind',
    skillDescription: 'Instantly restore a chunk of your own HP.',
    skillCooldown: 9.0,
    skillValue: 60,
    skillIsHeal: true,
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.shield_moon, size: 72, color: Colors.amberAccent),
              const SizedBox(height: 12),
              const Text(
                'ARENA CLASH',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose your champion',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: kChampions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final champion = kChampions[index];
                    return _ChampionCard(
                      champion: champion,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GameScreen(champion: champion),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChampionCard extends StatelessWidget {
  final Champion champion;
  final VoidCallback onTap;

  const _ChampionCard({required this.champion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF171728),
          border: Border.all(color: champion.color.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: champion.color.withOpacity(0.15),
              child: Icon(champion.icon, color: champion.color, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    champion.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    champion.description,
                    style: const TextStyle(color: Colors.white60, fontSize: 12.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${champion.skillName}: ${champion.skillDescription}',
                    style: TextStyle(color: champion.color, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

enum EnemyType { minion, tower }

class Enemy {
  final EnemyType type;
  double pos; // 0.0 (player base) .. 1.0 (enemy base)
  double hp;
  final double maxHp;
  final double atk;
  final double atkSpeed; // attacks per second
  double atkCd = 0;
  final double range;

  Enemy({
    required this.type,
    required this.pos,
    required this.hp,
    required this.maxHp,
    required this.atk,
    required this.atkSpeed,
    required this.range,
  });
}

class GameScreen extends StatefulWidget {
  final Champion champion;

  const GameScreen({super.key, required this.champion});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Tuning constants
  static const double heroSpeed = 0.05; // lane fraction per second
  static const double minionSpeed = 0.045;
  static const double engageRange = 0.045;
  static const double towerPos = 0.9;
  static const double minionSpawnPos = 0.82;

  Champion get champion => widget.champion;

  // Hero state
  double heroPos = 0.06;
  late double heroHp;
  late double heroMaxHp;
  double heroAtkCd = 0;
  int atkLevel = 1;
  int hpLevel = 1;

  double get heroAtk => champion.baseAtk + (atkLevel - 1) * 6;
  double get heroAtkSpeed => champion.atkSpeed;
  double get heroRange => engageRange;

  // Meta state
  int gold = 0;
  int wave = 1;
  int kills = 0;
  bool victory = false;
  bool respawning = false;
  double respawnTimer = 0;

  // Skill (values come from the selected champion)
  double skillCd = 0;
  double get skillMaxCd => champion.skillCooldown;
  double get skillDamage => champion.skillValue;

  // Enemies
  Enemy? current; // active enemy currently in combat with hero
  Enemy? approaching; // minion walking toward hero, not yet engaged
  late Enemy tower;
  double spawnTimer = 3.0;

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    heroMaxHp = champion.baseHp;
    heroHp = champion.baseHp;
    tower = Enemy(
      type: EnemyType.tower,
      pos: towerPos,
      hp: 500,
      maxHp: 500,
      atk: 14,
      atkSpeed: 0.6,
      range: engageRange,
    );
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick(0.016));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int _upgradeCost(int level) => 20 + level * 15;

  void _tick(double dt) {
    if (!mounted || victory) return;

    setState(() {
      if (respawning) {
        respawnTimer -= dt;
        if (respawnTimer <= 0) {
          respawning = false;
          heroHp = heroMaxHp;
        }
        return;
      }

      if (skillCd > 0) {
        skillCd = max(0, skillCd - dt);
      }

      if (current != null) {
        _resolveCombat(dt);
      } else {
        _resolveMovement(dt);
      }
    });
  }

  void _resolveCombat(double dt) {
    final enemy = current!;
    enemy.atkCd -= dt;
    heroAtkCd -= dt;

    if (heroAtkCd <= 0) {
      enemy.hp -= heroAtk;
      heroAtkCd = 1 / heroAtkSpeed;
      if (enemy.hp <= 0) {
        _onEnemyDefeated(enemy);
        return;
      }
    }

    if (enemy.atkCd <= 0) {
      heroHp -= enemy.atk;
      enemy.atkCd = 1 / enemy.atkSpeed;
      if (heroHp <= 0) {
        heroHp = 0;
        respawning = true;
        respawnTimer = 3.0;
      }
    }
  }

  void _resolveMovement(double dt) {
    // Hero pushes forward if not blocked by the tower's engage line.
    if (heroPos < towerPos - engageRange) {
      heroPos = min(heroPos + heroSpeed * dt, towerPos - engageRange);
    }

    // Approaching minion (if any) walks toward the hero.
    if (approaching != null) {
      final m = approaching!;
      m.pos = max(heroPos, m.pos - minionSpeed * dt);
      if ((m.pos - heroPos).abs() <= engageRange) {
        current = m;
        approaching = null;
        return;
      }
    } else {
      spawnTimer -= dt;
      if (spawnTimer <= 0) {
        _spawnMinion();
        spawnTimer = max(2.0, 5.0 - wave * 0.15);
      }
    }

    // If hero reached the tower's engage line and no minion is in the way, fight the tower.
    if (approaching == null && heroPos >= towerPos - engageRange - 0.001) {
      current = tower;
    }
  }

  void _spawnMinion() {
    approaching = Enemy(
      type: EnemyType.minion,
      pos: minionSpawnPos,
      hp: 30 + wave * 9.0,
      maxHp: 30 + wave * 9.0,
      atk: 5 + wave * 1.4,
      atkSpeed: 0.8,
      range: engageRange,
    );
  }

  void _onEnemyDefeated(Enemy enemy) {
    if (enemy.type == EnemyType.minion) {
      gold += 10 + wave * 2;
      kills += 1;
      current = null;
      if (kills % 5 == 0) {
        wave += 1;
      }
    } else {
      victory = true;
      current = null;
    }
  }

  void _useSkill() {
    if (skillCd > 0 || respawning) return;
    if (!champion.skillIsHeal && current == null) return;

    setState(() {
      skillCd = skillMaxCd;
      if (champion.skillIsHeal) {
        heroHp = min(heroHp + skillDamage, heroMaxHp);
      } else {
        current!.hp -= skillDamage;
        if (current!.hp <= 0) {
          _onEnemyDefeated(current!);
        }
      }
    });
  }

  void _upgradeAtk() {
    final cost = _upgradeCost(atkLevel);
    if (gold < cost) return;
    setState(() {
      gold -= cost;
      atkLevel += 1;
    });
  }

  void _upgradeHp() {
    final cost = _upgradeCost(hpLevel);
    if (gold < cost) return;
    setState(() {
      gold -= cost;
      hpLevel += 1;
      heroMaxHp = champion.baseHp + (hpLevel - 1) * 35;
      heroHp = min(heroHp + 35, heroMaxHp);
    });
  }

  void _restart() {
    setState(() {
      heroPos = 0.06;
      atkLevel = 1;
      hpLevel = 1;
      heroMaxHp = champion.baseHp;
      heroHp = champion.baseHp;
      heroAtkCd = 0;
      gold = 0;
      wave = 1;
      kills = 0;
      victory = false;
      respawning = false;
      respawnTimer = 0;
      skillCd = 0;
      current = null;
      approaching = null;
      spawnTimer = 3.0;
      tower = Enemy(
        type: EnemyType.tower,
        pos: towerPos,
        hp: 500,
        maxHp: 500,
        atk: 14,
        atkSpeed: 0.6,
        range: engageRange,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final enemyOnField = current ?? approaching;

    return Scaffold(
      appBar: AppBar(
        title: Text('Arena Clash — ${champion.name}'),
        backgroundColor: const Color(0xFF171728),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatsBar(),
            Expanded(child: _buildLane(enemyOnField)),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF171728),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statChip(Icons.filter_hdr, 'Wave $wave'),
          _statChip(Icons.monetization_on, '$gold'),
          _statChip(Icons.local_fire_department, '$kills kills'),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.amberAccent),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildLane(Enemy? enemyOnField) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF14203B), Color(0xFF2A1735)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth - 60;
          final laneY = constraints.maxHeight / 2;

          return Stack(
            children: [
              // Lane line
              Positioned(
                left: 30,
                right: 30,
                top: laneY,
                child: Container(height: 4, color: Colors.white24),
              ),
              // Player base
              Positioned(
                left: 4,
                top: laneY - 18,
                child: const Icon(Icons.home, color: Colors.blueAccent, size: 36),
              ),
              // Enemy tower
              Positioned(
                left: 30 + towerPos * trackWidth - 18,
                top: laneY - 46,
                child: Column(
                  children: [
                    _healthBar(tower.hp, tower.maxHp, Colors.purpleAccent, width: 46),
                    const SizedBox(height: 4),
                    const Icon(Icons.fort, color: Colors.purpleAccent, size: 40),
                  ],
                ),
              ),
              // Enemy minion / whatever is currently approaching or fighting
              if (enemyOnField != null && enemyOnField.type == EnemyType.minion)
                Positioned(
                  left: 30 + enemyOnField.pos * trackWidth - 14,
                  top: laneY - 40,
                  child: Column(
                    children: [
                      _healthBar(enemyOnField.hp, enemyOnField.maxHp, Colors.redAccent, width: 32),
                      const SizedBox(height: 4),
                      const Icon(Icons.pest_control, color: Colors.redAccent, size: 28),
                    ],
                  ),
                ),
              // Hero
              Positioned(
                left: 30 + heroPos * trackWidth - 16,
                top: laneY - 44,
                child: Column(
                  children: [
                    _healthBar(heroHp, heroMaxHp, champion.color, width: 36),
                    const SizedBox(height: 4),
                    Icon(
                      respawning ? Icons.hourglass_bottom : champion.icon,
                      color: respawning ? Colors.white38 : champion.color,
                      size: 32,
                    ),
                  ],
                ),
              ),
              if (respawning)
                Positioned(
                  left: 30 + heroPos * trackWidth - 30,
                  top: laneY + 24,
                  child: Text(
                    'Respawning ${respawnTimer.toStringAsFixed(1)}s',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              if (victory)
                _buildVictoryOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _healthBar(double hp, double maxHp, Color color, {double width = 36}) {
    final ratio = (hp / maxHp).clamp(0.0, 1.0);
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: ratio,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildVictoryOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 64),
              const SizedBox(height: 12),
              const Text(
                'TOWER DESTROYED!',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Kills: $kills   Gold earned: $gold',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _restart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Play Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    final skillReady = skillCd <= 0 &&
        !respawning &&
        (champion.skillIsHeal || current != null);
    final atkCost = _upgradeCost(atkLevel);
    final hpCost = _upgradeCost(hpLevel);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      color: const Color(0xFF171728),
      child: Row(
        children: [
          Expanded(
            child: _controlButton(
              label: skillCd > 0 ? '${champion.skillName} ${skillCd.toStringAsFixed(1)}s' : champion.skillName,
              icon: champion.skillIsHeal ? Icons.healing : Icons.flash_on,
              enabled: skillReady,
              onTap: _useSkill,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _controlButton(
              label: 'ATK +  ($atkCost g)',
              icon: Icons.arrow_upward,
              enabled: gold >= atkCost,
              onTap: _upgradeAtk,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _controlButton(
              label: 'HP +  ($hpCost g)',
              icon: Icons.favorite,
              enabled: gold >= hpCost,
              onTap: _upgradeHp,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required String label,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color.withOpacity(0.85) : Colors.white12,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: enabled ? Colors.black : Colors.white38),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: enabled ? Colors.black : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
