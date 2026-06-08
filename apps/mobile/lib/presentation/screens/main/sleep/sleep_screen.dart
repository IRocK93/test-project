import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';

/// E2 — Sleep Tracking: Record and review baby sleep sessions.
///
/// Displays sleep logs with date navigation (left/right arrows), a daily summary
/// card (total sleep, naps count, average quality), and a timeline of individual
/// sessions. Automatically classifies entries as "Nap" (<4h, daytime) or
/// "Night sleep" (>=4h or overnight). Each session shows start→end time with
/// duration and quality indicator dots (GREAT/GOOD/FAIR/POOR).
/// Supports creating logs with start/end time pickers + "Still sleeping" toggle,
/// swipe-to-delete, and pull-to-refresh. Accessible from HealthScreen nav card
/// and as a dedicated tab in MainScreen.
///
/// API: GET/POST/PATCH/DELETE /api/baby-mons/:id/sleep-logs
/// Integration points: MainScreen (6th tab), HealthScreen (nav card)
class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({super.key});

  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends ConsumerState<SleepScreen> {
  /// The currently selected BabyMon ID from secure storage
  String? _babyMonId;

  /// All sleep logs fetched from the backend
  List<Map<String, dynamic>> _sleepLogs = [];

  /// Whether data is currently loading
  bool _isLoading = true;

  /// The date being viewed in the date navigator
  DateTime _selectedDate = DateTime.now();

  /// Available quality levels for sleep tracking
  final List<String> _qualities = ['GREAT', 'GOOD', 'FAIR', 'POOR'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) _loadData();
    });
  }

  /// Loads the BabyMon ID and fetches sleep logs
  Future<void> _loadData() async {
    final api = ref.read(apiClientProvider);
    final id = await api.getSelectedBabyMonId();
    if (id == null || id.isEmpty) {
      if (id != null && id.isEmpty) await api.setSelectedBabyMonId(null);
      setState(() => _isLoading = false);
      return;
    }
    _babyMonId = id;
    await _fetchSleepLogs();
  }

  /// Fetches all sleep logs from the backend
  Future<void> _fetchSleepLogs() async {
    if (_babyMonId == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await ref.read(apiClientProvider).getSleepLogs(_babyMonId!);
      final items = (response.data is List) ? response.data : ((response.data as Map)['items'] as List?) ?? [];
      setState(() {
        _sleepLogs = items.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Deletes a sleep log entry with user confirmation
  Future<bool> _deleteLog(String id, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Sleep Log'),
        content: const Text('Remove this sleep record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    try {
      await ref.read(apiClientProvider).deleteSleepLog(_babyMonId!, id);
      setState(() => _sleepLogs.removeAt(index));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sleep log deleted')),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      return false;
    }
  }

  /// Filters logs to the currently selected date
  List<Map<String, dynamic>> _logsForSelectedDate() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _sleepLogs.where((log) {
      final startStr = log['startTime']?.toString() ?? '';
      return startStr.startsWith(dateStr);
    }).toList();
  }

  /// Calculates daily sleep summary: total minutes, number of naps, and average quality
  Map<String, dynamic> _dailySummary() {
    final logs = _logsForSelectedDate();
    int totalMinutes = 0;
    int naps = 0;
    final qualityScores = <String, int>{'GREAT': 4, 'GOOD': 3, 'FAIR': 2, 'POOR': 1};

    for (final log in logs) {
      final start = DateTime.tryParse(log['startTime']?.toString() ?? '');
      final end = DateTime.tryParse(log['endTime']?.toString() ?? '');
      if (start != null && end != null) {
        totalMinutes += end.difference(start).inMinutes;
      }
      // Detect nap: shorter than 4 hours and started between 6 AM and 8 PM
      if (start != null && end != null) {
        final duration = end.difference(start);
        if (duration.inHours < 4 && start.hour >= 6 && start.hour < 20) {
          naps++;
        }
      }
    }

    final avgQuality = logs.isNotEmpty
        ? logs.map((l) => qualityScores[l['quality']?.toString() ?? 'GOOD'] ?? 3)
            .reduce((a, b) => a + b) / logs.length
        : 0.0;

    return {'totalMinutes': totalMinutes, 'naps': naps, 'avgQuality': avgQuality, 'count': logs.length};
  }

  /// Auto-detects if a sleep session is a "Nap" or "Night sleep"
  String _sleepTypeLabel(Map<String, dynamic> log) {
    final start = DateTime.tryParse(log['startTime']?.toString() ?? '');
    final end = DateTime.tryParse(log['endTime']?.toString() ?? '');
    if (start == null || end == null) return 'Sleep';
    final duration = end.difference(start);
    if (duration.inHours >= 4) return 'Night sleep';
    if (start.hour >= 20 || start.hour < 6) return 'Night sleep';
    return 'Nap';
  }

  /// Returns a color for a quality level
  Color _qualityColor(String quality) {
    switch (quality) {
      case 'GREAT': return Colors.green;
      case 'GOOD': return Colors.lightGreen;
      case 'FAIR': return Colors.orange;
      case 'POOR': return Colors.red;
      default: return Colors.grey;
    }
  }

  /// Formats a duration between start and end times
  String _formatDuration(String? startStr, String? endStr) {
    final start = DateTime.tryParse(startStr ?? '');
    final end = DateTime.tryParse(endStr ?? '');
    if (start == null || end == null) return '';
    final duration = end.difference(start);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }

  /// Formats time from an ISO datetime string
  String _formatTime(String? isoStr) {
    final dt = DateTime.tryParse(isoStr ?? '');
    if (dt == null) return '';
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final logs = _logsForSelectedDate();
    final summary = _dailySummary();

    return Scaffold(
      appBar: AppBar(title: const Text('Sleep')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date navigator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        }),
                      ),
                      Text(
                        _selectedDate.day == DateTime.now().day &&
                                _selectedDate.month == DateTime.now().month &&
                                _selectedDate.year == DateTime.now().year
                            ? 'Today - ${DateFormat('MMM d').format(_selectedDate)}'
                            : DateFormat('EEEE, MMM d').format(_selectedDate),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        }),
                      ),
                    ],
                  ),
                ),

                // Daily summary card
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summaryStat('${summary['totalMinutes'] ~/ 60}h ${summary['totalMinutes'] % 60}m', 'Total'),
                        _summaryStat('${summary['naps']}', 'Naps'),
                        _summaryStat(_qualityLabel(summary['avgQuality']), 'Avg'),
                        _summaryStat('${summary['count']}', 'Entries'),
                      ],
                    ),
                  ),
                ),

                // Sleep log list
                Expanded(
                  child: logs.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bedtime, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No sleep logs for this day', style: TextStyle(color: Colors.grey)),
                              Text('Tap + to log sleep'),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchSleepLogs,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              final type = _sleepTypeLabel(log);
                              return Dismissible(
                                key: Key(log['id'] ?? index.toString()),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) => _deleteLog(log['id'], _sleepLogs.indexOf(log)),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Colors.red,
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.indigo.withOpacity(0.2),
                                      child: const Icon(Icons.bedtime, color: Colors.indigo),
                                    ),
                                    title: Text(type),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${_formatTime(log['startTime']?.toString())} → ${_formatTime(log['endTime']?.toString())} (${_formatDuration(log['startTime']?.toString(), log['endTime']?.toString())})'),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            ..._qualities.map((q) => Padding(
                                              padding: const EdgeInsets.only(right: 4),
                                              child: Icon(
                                                Icons.circle,
                                                size: 10,
                                                color: log['quality'] == q ? _qualityColor(q) : Colors.grey.withOpacity(0.2),
                                              ),
                                            )),
                                          ],
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                    trailing: log['notes'] != null && log['notes'].toString().isNotEmpty
                                        ? Icon(Icons.notes, size: 16, color: Colors.grey.withOpacity(0.5))
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'sleep_fab',
        onPressed: () => _showAddSleepDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Converts quality string to numeric value for API (1-5)
  int _qualityNumber(String quality) {
    switch (quality) {
      case 'GREAT': return 5;
      case 'GOOD': return 4;
      case 'FAIR': return 2;
      case 'POOR': return 1;
      default: return 3;
    }
  }

  /// Returns a human-readable quality label from a numeric score
  String _qualityLabel(double score) {
    if (score >= 3.5) return 'Great';
    if (score >= 2.5) return 'Good';
    if (score >= 1.5) return 'Fair';
    if (score >= 0.5) return 'Poor';
    return 'N/A';
  }

  /// Builds a summary statistic widget for the daily summary card
  Widget _summaryStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  /// Shows a bottom sheet dialog for creating a new sleep log
  void _showAddSleepDialog() {
    if (_babyMonId == null) return;
    final now = DateTime.now();
    DateTime sleepDate = _selectedDate;  // Use the date being viewed as default
    DateTime startTime = DateTime(sleepDate.year, sleepDate.month, sleepDate.day, now.hour, 0);
    DateTime? endTime = DateTime(sleepDate.year, sleepDate.month, sleepDate.day, now.hour, 0);
    String selectedQuality = 'GOOD';
    final notesController = TextEditingController();
    bool isStillSleeping = false;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Log Sleep', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              // Date picker
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(DateFormat('EEE, MMM d, yyyy').format(sleepDate)),
                onTap: () async {
                  final picked = await showDatePicker(context: ctx, initialDate: sleepDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)));
                  if (picked != null) {
                    setDialogState(() {
                      sleepDate = picked;
                      startTime = DateTime(picked.year, picked.month, picked.day, startTime.hour, startTime.minute);
                      if (endTime != null) {
                        endTime = DateTime(picked.year, picked.month, picked.day, endTime!.hour, endTime!.minute);
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              // Start time picker
              ListTile(
                leading: const Icon(Icons.bedtime_outlined),
                title: const Text('Start time'),
                subtitle: Text(DateFormat('hh:mm a').format(startTime)),
                onTap: () async {
                  final picked = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(startTime));
                  if (picked != null) {
                    setDialogState(() {
                      startTime = DateTime(sleepDate.year, sleepDate.month, sleepDate.day, picked.hour, picked.minute);
                    });
                  }
                },
              ),
              // End time picker or "Still sleeping" toggle
              SwitchListTile(
                secondary: const Icon(Icons.wb_sunny_outlined),
                title: const Text('Still sleeping'),
                value: isStillSleeping,
                onChanged: (v) => setDialogState(() {
                  isStillSleeping = v;
                  if (v) endTime = null;
                }),
              ),
              if (!isStillSleeping)
                ListTile(
                  leading: const Icon(Icons.wb_sunny),
                  title: const Text('End time'),
                  subtitle: Text(DateFormat('hh:mm a').format(endTime!)),
                  onTap: () async {
                    final picked = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(endTime!));
                    if (picked != null) {
                      setDialogState(() {
                        endTime = DateTime(endTime!.year, endTime!.month, endTime!.day, picked.hour, picked.minute);
                      });
                    }
                  },
                ),
              const SizedBox(height: 12),
              // Quality selector
              Wrap(
                spacing: 8,
                children: _qualities.map((q) => ChoiceChip(
                  label: Text(q[0] + q.substring(1).toLowerCase()),
                  selected: selectedQuality == q,
                  selectedColor: _qualityColor(q).withOpacity(0.3),
                  onSelected: (_) => setDialogState(() => selectedQuality = q),
                )).toList(),
              ),
              const SizedBox(height: 12),
              // Notes input
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Save button
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  setDialogState(() => isSaving = true);
                  try {
                    final effectiveEnd = isStillSleeping ? startTime.add(const Duration(minutes: 1)) : endTime;
                    // Auto-detect type: NAP if < 4h and daytime (6am-8pm), otherwise NIGHT
                    final duration = effectiveEnd != null ? effectiveEnd.difference(startTime) : const Duration(hours: 1);
                    final autoType = (duration.inHours < 4 && startTime.hour >= 6 && startTime.hour < 20) ? 'NAP' : 'NIGHT';
                    final data = <String, dynamic>{
                      'type': autoType,
                      'startTime': startTime.toIso8601String(),
                      'endTime': (effectiveEnd ?? DateTime.now()).toIso8601String(),
                      'quality': _qualityNumber(selectedQuality),
                      'notes': notesController.text.isNotEmpty ? notesController.text : null,
                    };
                    if (_babyMonId == null) return;
                    await ref.read(apiClientProvider).createSleepLog(_babyMonId!, data);
                    await _fetchSleepLogs();
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    setDialogState(() => isSaving = false);
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}