import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/constants/api_constants.dart';
import 'package:baby_mon/core/providers.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  String? _babyMonId;
  List _entries = [];
  List _proposals = [];
  String _selectedFilter = 'ALL';
  bool _isLoading = false;

  final List<String> _filters = ['ALL', 'MILESTONE', 'FEED_LOG', 'HEALTH_RECORD', 'SYSTEM'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAndFetch());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) _initAndFetch();
    });
  }

  Future<void> _initAndFetch() async {
    final api = ref.read(apiClientProvider);
    final id = await api.getSelectedBabyMonId();
    if (id == null || id.isEmpty) {
      if (id != null && id.isEmpty) await api.setSelectedBabyMonId(null);
      setState(() => _isLoading = false);
      return;
    }
    _babyMonId = id;
    await _fetchJournal();
  }

  Future<void> _fetchJournal() async {
    final id = _babyMonId;
    if (id == null) return;
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final journalRes = await api.getJournal(id, type: _selectedFilter == 'ALL' ? null : _selectedFilter);
      final proposalsRes = await api.getProposals(id);
      setState(() {
        _entries = (journalRes.data['entries'] as List?) ?? [];
        _proposals = (proposalsRes.data is List) ? proposalsRes.data : ((proposalsRes.data as Map)['items'] as List?) ?? [];
        _isLoading = false;
      });
    } catch (e) {
      // Backend endpoint not yet implemented — quietly show empty state
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFilteredJournal(String type) async {
    final id = _babyMonId;
    if (id == null) return;
    setState(() {
      _selectedFilter = type;
      _isLoading = true;
    });
    try {
      final api = ref.read(apiClientProvider);
      final journalRes = await api.getJournal(id, type: type == 'ALL' ? null : type);
      setState(() {
        _entries = (journalRes.data['entries'] as List?) ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _respondToProposal(String proposalId, bool accept) async {
    try {
      final api = ref.read(apiClientProvider);
      final id = _babyMonId;
      if (id == null) return;
      await api.respondToProposal(id, proposalId, accept, null);
      await _fetchJournal();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showEntryActions(Map<String, dynamic> entry, int index) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Entry Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Entry'),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('Delete Entry'),
                    content: const Text('Are you sure?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(dCtx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  try {
                    await ref.read(apiClientProvider).delete('/api/journal-entries/${entry['id']}');
                    setState(() => _entries.removeAt(index));
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry deleted')));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _iconForEntryType(String entryType) {
    switch (entryType) {
      case 'MILESTONE': return Icons.stars;
      case 'FEED_LOG': return Icons.restaurant;
      case 'HEALTH_RECORD': return Icons.medical_services;
      case 'SYSTEM': return Icons.info;
      default: return Icons.event;
    }
  }

  Color _colorForEntryType(String entryType) {
    switch (entryType) {
      case 'MILESTONE': return Colors.amber;
      case 'FEED_LOG': return Colors.orange;
      case 'HEALTH_RECORD': return Colors.green;
      case 'SYSTEM': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journey Journal')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchJournal,
              child: CustomScrollView(
                slivers: [
                  // Filter chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(f == 'ALL' ? 'All' : f.split('_').map((w) => w[0] + w.substring(1).toLowerCase()).join(' ')),
                              selected: _selectedFilter == f,
                              onSelected: (_) => _fetchFilteredJournal(f),
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ),

                  // Proposals section
                  if (_proposals.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pending Approvals', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ..._proposals.map((p) => Card(
                              color: Colors.orange.shade50,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.pending_actions, color: Colors.orange),
                                title: Text('${p['proposalType']} - ${p['entryType']}'),
                                subtitle: Text('From: ${p['proposer']?['name'] ?? 'Unknown'}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      onPressed: () => _respondToProposal(p['id'], true),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _respondToProposal(p['id'], false),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),

                  // Entries list
                  if (_entries.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.book, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('Your journey is just starting', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final entry = _entries[index];
                            final entryType = entry['entryType'] ?? '';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _colorForEntryType(entryType).withOpacity(0.2),
                                  child: Icon(_iconForEntryType(entryType), color: _colorForEntryType(entryType)),
                                ),
                                title: Text(entry['title'] ?? entryType),
                                subtitle: Text(
                                  DateFormat.yMMMd().format(
                                    DateTime.parse(entry['happenedAt'] ?? entry['createdAt']),
                                  ),
                                ),
                                trailing: entry['syncStatus'] == 'PENDING'
                                    ? const Icon(Icons.cloud_upload, color: Colors.orange, size: 16)
                                    : null,
                                onLongPress: () => _showEntryActions(entry, index),
                              ),
                            );
                          },
                          childCount: _entries.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}