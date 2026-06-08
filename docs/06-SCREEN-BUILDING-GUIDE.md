# 📱 BabyMon — Screen Building Guide

**Purpose:** Copy-paste standard for every new CRUD screen in BabyMon.  
**Audience:** AI agents and future developers.  
**Last Updated:** June 5, 2026

---

## 1. Standard Widget Pattern

Every data screen uses `ConsumerStatefulWidget` + `ConsumerState`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/presentation/providers/auth_provider.dart'; // ← NOT core/providers

class MyFeatureScreen extends ConsumerStatefulWidget {
  const MyFeatureScreen({super.key});
  @override
  ConsumerState<MyFeatureScreen> createState() => _MyFeatureScreenState();
}

class _MyFeatureScreenState extends ConsumerState<MyFeatureScreen> {
  // ... state variables, methods, build
}
```

---

## 2. State Variables

```dart
String? _babyMonId;           // Required: loaded from secure storage
List<Map<String, dynamic>> _items = [];  // List of data from API
bool _isLoading = true;       // Controls loading spinner
```

---

## 3. initState & _loadData Pattern

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
}

Future<void> _loadData() async {
  final api = ref.read(apiClientProvider);
  final id = await api.getSelectedBabyMonId();
  if (id == null) {
    if (mounted) setState(() => _isLoading = false);  // ← CRITICAL: stop spinner
    return;
  }
  _babyMonId = id;
  await _fetchItems();
}
```

---

## 4. Loading State

```dart
body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _babyMonId == null
        ? _buildNoBabyMonState()            // ← "Create BabyMon" CTA
        : _items.isEmpty
            ? _buildEmptyState()
            : _buildDataList()
```

---

## 5. No BabyMon State

```dart
Widget _buildNoBabyMonState() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text('Welcome to BabyMon!', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create BabyMon'),
            onPressed: () => GoRouter.of(context).go('/create-baby-mon'),
          ),
        ],
      ),
    ),
  );
}
```

---

## 6. Empty State

```dart
Widget _buildEmptyState() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text('No items yet', style: TextStyle(color: Colors.grey)),
        Text('Tap + to add'),
      ],
    ),
  );
}
```

---

## 7. Data State — ListView with Cards

```dart
Widget _buildDataList() {
  return RefreshIndicator(
    onRefresh: _fetchItems,
    child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Dismissible(
          key: Key(item['id'] ?? index.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _deleteItem(item['id'], index),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                child: const Icon(Icons.star, color: Colors.amber),
              ),
              title: Text(item['title'] ?? ''),
              subtitle: Text(DateFormat.yMMMd().format(DateTime.parse(item['createdAt']))),
            ),
          ),
        );
      },
    ),
  );
}
```

---

## 8. Pull-to-Refresh

```dart
Future<void> _fetchItems() async {
  if (mounted) setState(() => _isLoading = true);
  try {
    final response = await ref.read(apiClientProvider).getSomething(_babyMonId!);
    if (mounted) setState(() {
      _items = response.data as List;
      _isLoading = false;
    });
  } catch (e) {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## 9. Swipe-to-Delete

```dart
Future<void> _deleteItem(String id, int index) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete'),
      content: const Text('Are you sure?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref.read(apiClientProvider).deleteSomething(id);
    if (mounted) setState(() => _items.removeAt(index));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
  } catch (e) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}
```

---

## 10. FAB + Bottom Sheet (Creation Dialog)

```dart
FloatingActionButton(
  onPressed: _showCreateDialog,
  child: const Icon(Icons.add),
)

void _showCreateDialog() {
  final titleController = TextEditingController();
  bool isSaving = false;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, ...),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: ...),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (titleController.text.isEmpty) return;
                setDialogState(() => isSaving = true);
                try {
                  await ref.read(apiClientProvider).createSomething(_babyMonId!, {
                    'title': titleController.text,
                  });
                  await _fetchItems();
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

## 11. API Call Pattern

```dart
// For typed methods (preferred):
final response = await ref.read(apiClientProvider).getSomething(_babyMonId!);
_items = response.data as List;

// For generic fallback:
final response = await ref.read(apiClientProvider).get('/users/me');
// NOTE: generic methods auto-prepend /api — do NOT include /api in path
```

---

## 12. Navigation

| Method | Use Case | File |
|--------|----------|------|
| `GoRouter.of(context).go('/path')` | Top-level routes (settings, create-baby-mon) | `app_router.dart` |
| `Navigator.push(context, MaterialPageRoute(...))` | Sub-screens pushed from within tabs | Any screen |
| `GoRouter.of(context).pop()` | Pop from pushed Navigator routes | Pushed screens only |

---

## 13. Provider Import Rule

```dart
// ✅ CORRECT:
import 'package:baby_mon/presentation/providers/auth_provider.dart';

// ❌ WRONG (deprecated — causes duplicate providers):
import 'package:baby_mon/core/providers.dart';
```

---

## 14. Doc Comment Template

```dart
/// [ScreenName]: [One-line description of what this screen does]
///
/// [2-3 sentences explaining the UI, data flow, and key widgets]
///
/// API: GET/POST/DELETE /api/endpoint-path
/// Integration points: [list of screens or features this connects to]
class MyScreen extends ConsumerStatefulWidget {
```

---

## 15. `_loadInProgress` Re-entrancy Guard (STANDARD for ALL IndexedStack screens)

Every IndexedStack screen MUST use a boolean gate to prevent concurrent load calls from stacking. This is no longer optional — it is required for all tab screens:

```dart
bool _loadInProgress = false;

Future<void> _loadAll() async {
  if (_loadInProgress) return;  // ← prevent re-entrant calls
  _loadInProgress = true;
  try {
    // ... all API calls ...
  } finally {
    if (mounted) setState(() => _loadInProgress = false);
  }
}
```

This is critical for IndexedStack screens where Riverpod provider rebuilds can trigger multiple simultaneous loads. All 7 tab screens should implement this guard.

---

## 16. Metric/Imperial Toggle + Auto-Unit Pattern

Feeding and Health screens use a `SegmentedButton<bool>` toggle at the top of creation forms:

```dart
bool _isMetric = true; // Default: Metric

String get _unit {
  if (_isMetric) {
    switch (_type) {
      case FeedType.BREAST_MILK:
      case FeedType.FORMULA: return 'ml';
      case FeedType.SOLID_FOOD: return 'g';
      default: return '';
    }
  } else {
    switch (_type) {
      case FeedType.BREAST_MILK:
      case FeedType.FORMULA: return 'fl oz';
      case FeedType.SOLID_FOOD: return 'oz';
      default: return '';
    }
  }
}
```

**Key rules:**
- Unit is displayed as `suffixText` in the value field (e.g., `Amount (ml)`) — NOT as an editable field
- Metric is the default (`isMetric = true`)
- Health screen unit mapping: Weight→kg/lbs, Height→cm/ft-in, Head Circumference→cm/in, Body Temperature→°C/°F
- Toggle changes trigger `setState()` to rebuild with new unit labels

---

## 17. Age-Based Stage Label Computation

The Dashboard computes age-appropriate stage names from `_referenceDate` (extracted from `getBabyMon()`):

```dart
String get _stageLabel {
  switch (_stageStartType) {
    case 'CONCEIVED': return 'Fetus';
    case 'IDEA': return 'Planning';
    case 'BORN':
    default:
      if (_referenceDate == null) return 'Born';
      final ageInDays = DateTime.now().difference(_referenceDate!).inDays;
      if (ageInDays <= 28) return 'Neonate';
      if (ageInDays <= 365) return 'Infant';
      if (ageInDays <= 1095) return 'Toddler';
      if (ageInDays <= 1825) return 'Preschooler';
      return 'Child';
  }
}
```

**Stage age ranges:**
| Stage | Age Range |
|-------|----------|
| Fetus | Conception → Birth (CONCEIVED) |
| Neonate | 0–28 days |
| Infant | 1–12 months (29–365 days) |
| Toddler | 1–3 years (366–1095 days) |
| Preschooler | 3–5 years (1096–1825 days) |
| Child | 5+ years |

---

## 18. AppBar BabyMon Selector (Shared in main_screen.dart)

The BabyMon selector has moved from individual screens into a shared AppBar in `main_screen.dart`. Individual tab screens do **not** have their own BabyMon selector — they receive the active BabyMon ID via `appRefreshProvider` rebuilds.

When switching BabyMons:
- `main_screen.dart` bumps `appRefreshProvider` (a counter StateProvider)
- All IndexedStack screens `ref.listen` on `appRefreshProvider` to reload with the new ID
- Use `_fetchItems()` (called via listener) rather than re-running `_loadData()` fully

---

## 19. Compact Dashboard Sizing

Dashboard uses compact visual styling:
- Body padding: `edgeInsets.all(12)` (was 16)
- Stage emoji fontSize: 36 (was 48)
- XP card: `vertical: 10, horizontal: 14`
- ExpansionTile: `dense: true, visualDensity: VisualDensity.compact`
- Stat cards: `vertical: 8`, smaller emoji/text
- Single FAB (quick actions only — no create button)
- Bold text: `w800/w900` weights on card text to maintain readability despite compact sizing

---

## 20. Badge Display Pattern

```dart
// Show ALL locked badges — no "+N" truncation
List<Widget> _buildLockedBatch(List<Map<String, dynamic>> badges) {
  final locked = badges.where((b) => b['unlocked'] != true).toList();
  return locked.map((b) => _badgeChip(b)).toList();
}
```

Badge count format:
- Header: `"X unlocked / Y locked"` (global)
- Per-category: `"unlocked/total"` in trailing widget

---

## 21. Adding a New Screen — Checklist

- [ ] Use `ConsumerStatefulWidget` + `ConsumerState`
- [ ] Import `apiClientProvider` from `presentation/providers/auth_provider.dart`
- [ ] Add `_babyMonId`, `_isLoading`, data list state variables
- [ ] Implement `_loadData()` with null guard + `setState(() => _isLoading = false)`
- [ ] Build method: loading → no BabyMon → empty → data states
- [ ] Add pull-to-refresh on data list
- [ ] Add swipe-to-delete with confirmation
- [ ] Add FAB with bottom sheet creation dialog
- [ ] All async operations wrapped in try/catch
- [ ] `if (mounted)` before `ScaffoldMessenger` or `Navigator` calls
- [ ] Add doc comment
- [ ] Register in `app_router.dart` (if top-level) or `main_screen.dart` (if tab)