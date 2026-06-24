import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/widgets/premium_double_bezel.dart';

/// Achievements / badge section with collapsible categories.
class DashboardBadgeSection extends StatelessWidget {
  final List<Map<String, dynamic>> badgeDefinitions;
  final List badges;

  const DashboardBadgeSection({
    super.key,
    required this.badgeDefinitions,
    required this.badges,
  });

  List<Map<String, dynamic>> get _badgesByCategory {
    if (badgeDefinitions.isEmpty) return [];
    final u = badges.map((b) => parseString(b['badgeType']) ?? '').toSet();
    return badgeDefinitions
        .map((def) => {
              ...def,
              'unlocked': u.contains(parseString(def['badgeType']) ?? ''),
              'category': parseString(def['category']) ?? 'Other',
            })
        .toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedBadges {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final b in _badgesByCategory) {
      map.putIfAbsent(parseString(b['category']) ?? '', () => []).add(b);
    }
    return map;
  }

  int get _totalUnlocked => badges.length;
  int get _totalBadges => badgeDefinitions.length;

  Color _tierColor(String t) {
    switch (t) {
      case 'DIAMOND': return const Color(0xFFB366FF);
      case 'GOLD': return const Color(0xFFD4A017);
      case 'SILVER': return const Color(0xFF8E8E93);
      default: return const Color(0xFFCD7F32);
    }
  }

  IconData _categoryIcon(String c) {
    switch (c) {
      case 'milestones': return PhosphorIconsLight.trophy;
      case 'feeding': return PhosphorIconsLight.bowlFood;
      case 'sleep': return PhosphorIconsLight.moon;
      case 'health': return PhosphorIconsLight.heart;
      case 'growth': return PhosphorIconsLight.scales;
      case 'parenting': return PhosphorIconsLight.users;
      case 'progression': return PhosphorIconsLight.lightning;
      default: return PhosphorIconsLight.trophy;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (badgeDefinitions.isEmpty) {
      return PremiumDoubleBezel(
        outerRadius: DesignTokens.radius2xl,
        gap: 5.0,
        outerColor: context.colorScheme.primary.withValues(alpha: 0.06),
        child: Row(
          children: [
            Icon(PhosphorIconsLight.trophy,
                color: context.colorScheme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Badges ($_totalUnlocked unlocked)',
                style: TextStyle(
                  fontSize: DesignTokens.fontMd,
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    const catOrder = [
      'milestones', 'feeding', 'sleep', 'health',
      'growth', 'parenting', 'progression', 'traits',
    ];
    final sorted = <String, List<Map<String, dynamic>>>{};
    for (final c in catOrder) {
      if (_groupedBadges.containsKey(c)) sorted[c] = _groupedBadges[c]!;
    }
    for (final c in _groupedBadges.keys) {
      if (!sorted.containsKey(c)) sorted[c] = _groupedBadges[c]!;
    }

    return PremiumDoubleBezel(
      outerRadius: DesignTokens.radius2xl,
      gap: 5.0,
      outerColor: context.colorScheme.primary.withValues(alpha: 0.06),
      child: Material(
        type: MaterialType.transparency,
        child: ExpansionTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          tilePadding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLg, vertical: DesignTokens.spaceSm),
          childrenPadding: const EdgeInsets.fromLTRB(
              DesignTokens.spaceSm, 0, DesignTokens.spaceSm, DesignTokens.spaceSm),
          initiallyExpanded: false,
          title: Row(
            children: [
              Icon(PhosphorIconsLight.trophy, size: 18, color: context.colorScheme.primary),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: DesignTokens.fontLg,
                    fontWeight: FontWeight.w800,
                    color: context.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Text(
                '$_totalUnlocked / $_totalBadges',
                style: TextStyle(
                  fontSize: DesignTokens.fontSm2,
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          children: [
            for (final entry in sorted.entries)
              _badgeCategoryTile(context, entry.key, entry.value),
          ],
        ),
      ),
    );
  }

  Widget _badgeCategoryTile(BuildContext context, String cat, List<Map<String, dynamic>> catBadges) {
    final unlocked = catBadges.where((b) => b['unlocked'] == true).length;
    final total = catBadges.length;
    return Material(
      type: MaterialType.transparency,
      child: ExpansionTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        tilePadding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceSm, vertical: 0),
        childrenPadding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
        initiallyExpanded: false,
        title: Row(
          children: [
            Icon(_categoryIcon(cat), size: 16, color: context.colorScheme.onSurfaceVariant),
            const SizedBox(width: DesignTokens.spaceSm),
            Expanded(
              child: Text(
                '${cat[0].toUpperCase()}${cat.substring(1)}',
                style: TextStyle(
                  fontSize: DesignTokens.fontSm2,
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Text(
              '$unlocked/$total',
              style: TextStyle(
                fontSize: DesignTokens.fontSm,
                fontWeight: FontWeight.w700,
                color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        children: [_badgeGrid(context, catBadges)],
      ),
    );
  }

  Widget _badgeGrid(BuildContext context, List<Map<String, dynamic>> catBadges) {
    final sorted = [...catBadges]..sort((a, b) {
        final au = a['unlocked'] == true ? 0 : 1;
        final bu = b['unlocked'] == true ? 0 : 1;
        return au.compareTo(bu);
      });
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
      child: Wrap(
        spacing: DesignTokens.spaceSm,
        runSpacing: DesignTokens.spaceSm,
        children: sorted.map((b) => _badgeChip(context, b)).toList(),
      ),
    );
  }

  Widget _badgeChip(BuildContext context, Map<String, dynamic> b) {
    final u = b['unlocked'] == true;
    final n = parseString(b['name']) ?? '';
    final t = parseString(b['tier']) ?? 'BRONZE';
    final iconPath = parseString(b['iconPath']) ?? parseString(b['icon']);
    return Semantics(
      label: '$n${u ? ', ${t.toLowerCase()} tier' : ', locked'}',
      button: true,
      child: GestureDetector(
      onTap: () => _showBadgeDetail(context, b),
      child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: u
                ? _tierColor(t).withValues(alpha: DesignTokens.opacitySubtle)
                : context.colorScheme.surface,
            border: Border.all(
              color: u ? _tierColor(t) : context.colorScheme.outline,
              width: u ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: u && iconPath != null
              ? ClipOval(child: Image.asset(iconPath, width: 32, height: 32, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Text(
                  n.isNotEmpty ? n[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w800, color: _tierColor(t)),
                )))
              : Text(n.isNotEmpty ? n[0].toUpperCase() : '?', style: TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w800, color: u ? _tierColor(t) : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
          ),          ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, Map<String, dynamic> b) {
    final u = b['unlocked'] == true;
    final t = parseString(b['tier']) ?? 'BRONZE';
    final xp = parseInt(b['xpValue']) ?? 10;
    final iconPath = parseString(b['iconPath']) ?? parseString(b['icon']);
    final tierColor = _tierColor(t);

    if (!u) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusLg)),
          title: Row(children: [
            Icon(PhosphorIconsLight.lock, color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(parseString(b['name']) ?? '', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [_tierChip(t), const SizedBox(width: 8), Text('$xp XP', style: TextStyle(color: context.colorScheme.tertiary, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 12),
            Text(parseString(b['description']) ?? '', style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            Text('Keep tracking to unlock!', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontStyle: FontStyle.italic)),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: TextStyle(color: context.colorScheme.onSurfaceVariant)))],
        ),
      );
      return;
    }

    // Celebratory transparent overlay for unlocked badges
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Stack(
        children: [
          GestureDetector(onTap: () => Navigator.pop(ctx)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: tierColor.withValues(alpha: 0.4), blurRadius: 32, spreadRadius: 4),
                      BoxShadow(color: tierColor.withValues(alpha: 0.15), blurRadius: 64, spreadRadius: 8),
                    ],
                  ),
                  child: ClipOval(
                    child: iconPath != null
                        ? Image.asset(iconPath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(PhosphorIconsLight.trophy, color: tierColor, size: 80))
                        : Icon(PhosphorIconsLight.trophy, color: tierColor, size: 80),
                  ),
                ),
                const SizedBox(height: 24),
                Text(parseString(b['name']) ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, fontFamily: 'Syne', color: tierColor, height: 1.1, letterSpacing: -0.5)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _tierChip(t),
                  const SizedBox(width: 10),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.25), borderRadius: BorderRadius.circular(DesignTokens.radiusFull)), child: Text('+$xp XP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF66BB6A)))),
                ]),
                const SizedBox(height: 20),
                Container(constraints: const BoxConstraints(maxWidth: 300), child: Text(parseString(b['description']) ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.75), height: 1.5))),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tierChip(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _tierColor(t).withValues(alpha: DesignTokens.opacitySubtle),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      child: Text(
        t[0] + t.substring(1).toLowerCase(),
        style: TextStyle(
          fontSize: DesignTokens.fontSm,
          fontWeight: FontWeight.w600,
          color: _tierColor(t),
        ),
      ),
    );
  }
}
