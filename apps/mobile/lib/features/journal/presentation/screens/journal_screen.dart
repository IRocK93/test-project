import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/core.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/mixins/mixins.dart';
import 'package:baby_mon/core/utils/error_handler.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen>
    with DataScreenMixin<JournalScreen> {
  @override
  bool get autoInit => true;

  @override
  int? get listenToTabRefresh => 4;

  @override
  Duration? get refreshCooldown => const Duration(seconds: 10);

  List _entries = [];
  List _proposals = [];
  String _selectedFilterKey = 'ALL';
  final Map<String, int> _filterCounts = {'ALL': 0};

  // Filter definitions with display labels and stable keys.
  static const List<_FilterSpec> _filters = [
    _FilterSpec('All', 'ALL'),
    _FilterSpec('Milestones', 'MILESTONE'),
    _FilterSpec('Feeding', 'FEED_LOG'),
    _FilterSpec('Health', 'HEALTH_RECORD'),
    _FilterSpec('System', 'SYSTEM'),
  ];

  @override
  Future<void> fetchData() async {
    final api = ref.read(apiClientProvider);
    final journalRes = await api.getJournal(
      babyMonId!,
      type: _selectedFilterKey == 'ALL' ? null : _selectedFilterKey,
    );
    final proposalsRes = await api.getProposals(babyMonId!);
    _entries = parseList(journalRes.data['entries']);
    _proposals = parseItems(proposalsRes.data);
    // Refresh the unfiltered count for the "All" chip badge.
    if (_selectedFilterKey != 'ALL') {
      _refreshAllCount();
    } else {
      _filterCounts['ALL'] = _entries.length;
    }
  }

  Future<void> _refreshAllCount() async {
    if (babyMonId == null) return;
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.getJournal(babyMonId!);
      if (mounted) {
        setState(() {
          _filterCounts['ALL'] =
              parseList(res.data['entries']).length;
        });
      }
    } catch (e) {
      debugPrint('Failed to refresh filter counts: $e');
    }
  }

  Future<void> _selectFilter(String key) async {
    if (key == _selectedFilterKey) return;
    setState(() => _selectedFilterKey = key);
    await loadData();
  }

  Future<void> _respondToProposal(
      String proposalId, bool accept) async {
    final messenger = ScaffoldMessenger.of(context);
    if (babyMonId == null) return;
    try {
      await ref
          .read(apiClientProvider)
          .respondToProposal(babyMonId!, proposalId, accept, null);
      await loadData();
    } catch (e) {
      if (mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e))),
      );
      }
    }
  }

  Future<void> _deleteEntry(Map<String, dynamic> entry) async {
    final messenger = ScaffoldMessenger.of(context);
    final id = entry['id']?.toString();
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This entry will be removed from your journal.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(apiClientProvider)
          .delete('/api/journal-entries/$id');
      await loadData();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Entry deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not delete. Please try again.'),
          ),
        );
      }
    }
  }

  // ── Date grouping ──
  List<MapEntry<String, List<Map<String, dynamic>>>> _groupEntriesByDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: now.weekday - 1));

    final groups = <String, List<Map<String, dynamic>>>{
      'TODAY': [],
      'YESTERDAY': [],
      'THIS WEEK': [],
    };
    final monthlyGroups = <String, List<Map<String, dynamic>>>{};

    for (final raw in _entries) {
      final entry = parseJsonMap(raw) ?? <String, dynamic>{};
      final dateStr = entry['happenedAt'] ?? entry['createdAt'];
      if (dateStr == null) continue;
      // Server timestamps are UTC; convert to local so the day bucket
      // reflects the user's clock, not the server's.
      final date = DateTime.tryParse(dateStr.toString())?.toLocal();
      if (date == null) continue;
      final d = DateTime(date.year, date.month, date.day);

      if (d == today) {
        groups['TODAY']!.add(entry);
      } else if (d == yesterday) {
        groups['YESTERDAY']!.add(entry);
      } else if (d.isAfter(weekStart) && d.isBefore(today)) {
        groups['THIS WEEK']!.add(entry);
      } else {
        final key = DateFormat('MMMM yyyy').format(d).toUpperCase();
        monthlyGroups.putIfAbsent(key, () => []).add(entry);
      }
    }

    final ordered = <MapEntry<String, List<Map<String, dynamic>>>>[];
    for (final key in ['TODAY', 'YESTERDAY', 'THIS WEEK']) {
      final items = groups[key]!;
      if (items.isNotEmpty) {
        items.sort((a, b) => _entryDate(b).compareTo(_entryDate(a)));
        ordered.add(MapEntry(key, items));
      }
    }
    final monthKeys = monthlyGroups.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    for (final key in monthKeys) {
      final items = monthlyGroups[key]!;
      items.sort((a, b) => _entryDate(b).compareTo(_entryDate(a)));
      ordered.add(MapEntry(key, items));
    }
    return ordered;
  }

  DateTime _entryDate(Map<String, dynamic> entry) {
    final dateStr = entry['happenedAt'] ?? entry['createdAt'];
    // The server returns ISO-8601 timestamps in UTC. Convert to local time
    // so day-bucketing (`d == today`) matches the user's wall clock.
    return (DateTime.tryParse(dateStr?.toString() ?? '') ?? DateTime.now())
        .toLocal();
  }

  String _formatTime(DateTime d) => DateFormat.jm().format(d);

  String _entrySubtitle(Map<String, dynamic> entry) {
    final type = JournalEntryType.fromString(entry['entryType']?.toString());
    if (type == JournalEntryType.feedLog) {
      final value = entry['value'];
      final unit = entry['unit'];
      if (value != null) {
        return unit != null ? '$value $unit' : '$value';
      }
    }
    if (type == JournalEntryType.healthRecord) {
      final value = entry['value'];
      final unit = entry['unit'];
      if (value != null) {
        return unit != null ? '$value $unit' : '$value';
      }
    }
    if (type == JournalEntryType.milestone) {
      final notes = entry['notes']?.toString();
      if (notes != null && notes.isNotEmpty) return notes;
    }
    return type.label;
  }

  String _entryTitle(Map<String, dynamic> entry) {
    final explicit = entry['title']?.toString();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    return JournalEntryType.fromString(entry['entryType']?.toString())
        .label;
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final loading = isLoading && _entries.isEmpty && _proposals.isEmpty;
    final groups = _groupEntriesByDate();

    return Scaffold(
      appBar: ScreenHeader(
        title: 'Journey Journal',
        onBack: () => popOrGoHome(context),
      ),
      body: PremiumBackground(
        child: loading
            ? buildLoading()
            : !hasBabyMon
                ? buildNoBabyMon()
                : RefreshIndicator(
                onRefresh: onRefresh,
                child: CustomScrollView(
                  slivers: [
                    // ── Pending Approvals Banner ──
                    if (_proposals.isNotEmpty)
                      SliverToBoxAdapter(
                        child: PendingApprovalBanner(
                          count: _proposals.length,
                          onReview: () => _showProposalsSheet(),
                        ),
                      ),

                    // ── Filter Chips ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          DesignTokens.spaceLg,
                          DesignTokens.spaceMd,
                          DesignTokens.spaceLg,
                          DesignTokens.spaceSm,
                        ),
                        child: SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final f = _filters[i];
                              final selected =
                                  _selectedFilterKey == f.key;
                              return _FilterPill(
                                label: f.label,
                                count: _filterCounts[f.key] ?? 0,
                                selected: selected,
                                onTap: () => _selectFilter(f.key),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // ── Empty State ──
                    if (_entries.isEmpty)
                      SliverFillRemaining(
                        child: PremiumEmptyState(
                          icon: PhosphorIconsLight.bookOpen,
                          title: 'Your journal is empty',
                          subtitle:
                              'Milestones, feedings, and health records '
                              'you add will appear here.',
                          actionLabel: 'Add a milestone',
                          onAction: () => context.go('/home'),
                        ),
                      )
                    else
                      // ── Grouped Entries ──
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final group = groups[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DateGroupHeader(label: group.key),
                                ...group.value.map(
                                  (entry) => _JournalEntryTile(
                                    entry: entry,
                                    title: _entryTitle(entry),
                                    subtitle: _entrySubtitle(entry),
                                    time: _formatTime(_entryDate(entry)),
                                    onDelete: () => _deleteEntry(entry),
                                  ),
                                ),
                              ],
                            );
                          },
                          childCount: groups.length,
                        ),
                      ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: DesignTokens.space4xl),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showProposalsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignTokens.spaceLg,
            DesignTokens.spaceLg,
            DesignTokens.spaceLg,
            DesignTokens.spaceLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pending Approvals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Review changes from your partner before they appear in '
                'the journal.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              ..._proposals.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: DesignTokens.spaceMd,
                      ),
                      child: _ProposalRow(
                        proposal: parseJsonMap(e.value) ?? <String, dynamic>{},
                        onAccept: () {
                          Navigator.pop(ctx);
                          _respondToProposal(
                              e.value['id']?.toString() ?? '', true);
                        },
                        onDecline: () {
                          Navigator.pop(ctx);
                          _respondToProposal(
                              e.value['id']?.toString() ?? '', false);
                        },
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Local sub-widgets
// ═══════════════════════════════════════════════

class _FilterSpec {
  final String label;
  final String key;
  const _FilterSpec(this.label, this.key);
}

class _FilterPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Semantics(
        label: label,
        button: true,
        child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.glassDark
                    : AppColors.surface),
            borderRadius:
                BorderRadius.circular(DesignTokens.radiusFull),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : AppColors.border),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected
                      ? AppColors.primaryDark
                      : null,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '($count)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textCaption,
                  ),
                ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _JournalEntryTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback onDelete;

  const _JournalEntryTile({
    required this.entry,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final type =
        JournalEntryType.fromString(entry['entryType']?.toString());
    final isPending = entry['syncStatus'] == 'PENDING';

    return Padding(
      // Mirror the row's outer margin so the swipe background aligns
      // edge-to-edge with the rounded card.
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
        vertical: DesignTokens.spaceXs,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Dismissible(
          key: ValueKey(entry['id'] ?? '${title}_$time'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            // Trigger the existing confirm dialog flow. The row is
            // optimistically removed when the dialog confirms.
            onDelete();
            return false;
          },
          background: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),              child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIconsLight.trash, color: AppColors.textOnPrimary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          child: JournalEntryRow(
            type: type,
            title: title,
            subtitle: subtitle,
            trailingTime: time,
            isPendingSync: isPending,
            onTap: () {
              // Future: open entry detail screen.
            },
            onMore: onDelete,
          ),
        ),
      ),
    );
  }
}

class _ProposalRow extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _ProposalRow({
    required this.proposal,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final proposer =
        proposal['proposer']?['name']?.toString() ?? 'Your partner';
    final entryType = proposal['entryType']?.toString() ?? '';
    final summary = entryType.isEmpty
        ? 'Change proposed'
        : '$entryType change proposed';
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.glassDark
            : AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                PhosphorIconsLight.hourglass,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: Text(
                  summary,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'From: $proposer',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onDecline,
                icon: const Icon(PhosphorIconsLight.x, size: 18),
                label: const Text('Decline'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onAccept,
                icon: const Icon(PhosphorIconsLight.check, size: 18),
                label: const Text('Accept'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
