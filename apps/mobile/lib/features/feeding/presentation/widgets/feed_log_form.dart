import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/feed_log.dart';
import '../providers/feeding_provider.dart';
import '../../../../presentation/screens/main/settings/settings_screen.dart';

class FeedLogForm extends ConsumerStatefulWidget {
  final String babyMonId;
  final Future<void> Function(FeedLog) onSubmit;

  const FeedLogForm({super.key, required this.babyMonId, required this.onSubmit});
  @override
  ConsumerState<FeedLogForm> createState() => _FeedLogFormState();
}

class _FeedLogFormState extends ConsumerState<FeedLogForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  FeedType _type = FeedType.FORMULA;
  FeedMethod? _method = FeedMethod.BOTTLE;
  String? _side;
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _isMetric = true;
  bool _isPiece = false; // for solid: piece vs weight

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUnitPref());
  }

  Future<void> _loadUnitPref() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(measurementUnitsKey);
    if (mounted) setState(() => _isMetric = val != 'imperial');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Auto-compute unit based on feed type and metric/imperial preference
  String get _unit {
    if (_type == FeedType.SOLID_FOOD && _isPiece) return 'piece';
    if (_isMetric) {
      switch (_type) {
        case FeedType.BREAST_MILK:
        case FeedType.FORMULA:
          return 'ml';
        case FeedType.SOLID_FOOD:
          return 'g';
        default:
          return '';
      }
    } else {
      switch (_type) {
        case FeedType.BREAST_MILK:
        case FeedType.FORMULA:
          return 'fl oz';
        case FeedType.SOLID_FOOD:
          return 'oz';
        default:
          return '';
      }
    }
  }

  bool get _showAmount => _type == FeedType.FORMULA || _type == FeedType.BREAST_MILK || _type == FeedType.SOLID_FOOD;
  bool get _showBreast => _type == FeedType.BREAST_MILK;
  bool get _showDuration => _showBreast || _type == FeedType.SOLID_FOOD;

  void _onTypeChanged(FeedType? v) {
    if (v != null) setState(() {
      _type = v;
      _isPiece = false;
      if (v == FeedType.BREAST_MILK) _method = FeedMethod.BREAST;
      else if (v == FeedType.FORMULA) _method = FeedMethod.BOTTLE;
      else if (v == FeedType.SOLID_FOOD) _method = FeedMethod.SPOON;
      else _method = FeedMethod.CUP;
    });
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (p != null) setState(() => _date = p);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final log = FeedLog(
        id: '', babyMonId: widget.babyMonId, type: _type, method: _method,
        amountMl: _showAmount ? double.tryParse(_amountCtrl.text) : null,
        durationMinutes: _showDuration ? int.tryParse(_durationCtrl.text) : null,
        side: _showBreast ? _side : null,
        loggedAt: _date, notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      await widget.onSubmit(log);
    } finally { if (mounted) setState(() => _saving = false); }
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label, labelStyle: TextStyle(color: Colors.grey[400]),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple)),
    filled: true, fillColor: const Color(0xFF2A2A2A),
  );

  Widget _buildPieceToggle() {
    if (_type != FeedType.SOLID_FOOD) return const SizedBox.shrink();
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Unit: ', style: TextStyle(color: Colors.grey)),
      SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, label: Text('Weight'), icon: Icon(Icons.scale, size: 14)),
          ButtonSegment(value: true, label: Text('Piece'), icon: Icon(Icons.circle, size: 14)),
        ],
        selected: {_isPiece},
        onSelectionChanged: (v) => setState(() => _isPiece = v.first),
        style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.deepPurple.withOpacity(0.3) : null)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey, child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Log Feeding', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 12),
          // Piece/Wt toggle for solid only
          _buildPieceToggle(),
          const SizedBox(height: 12),
          DropdownButtonFormField<FeedType>(
            value: _type, dropdownColor: const Color(0xFF1E1E1E), style: const TextStyle(color: Colors.white),
            decoration: _inputDeco('Type'),
            items: FeedType.values.map((t) => DropdownMenuItem(value: t, child: Text('${t.typeEmoji} ${t.name}'))).toList(),
            onChanged: _onTypeChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<FeedMethod>(
            value: _method, dropdownColor: const Color(0xFF1E1E1E), style: const TextStyle(color: Colors.white),
            decoration: _inputDeco('Method'),
            items: FeedMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
            onChanged: (v) => setState(() => _method = v),
          ),
          if (_showAmount) ...[
            const SizedBox(height: 12),
            TextFormField(controller: _amountCtrl, style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Amount ($_unit)'), keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
          ],
          if (_showDuration) ...[
            const SizedBox(height: 12),
            TextFormField(controller: _durationCtrl, style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Duration (min)'), keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
          ],
          if (_showBreast) ...[
            const SizedBox(height: 12), Row(
              children: ['Left', 'Right'].map((s) => Expanded(
                child: RadioListTile<String>(title: Text(s, style: const TextStyle(color: Colors.white)),
                  value: s.toLowerCase(), groupValue: _side,
                  onChanged: (v) => setState(() => _side = v),
                  activeColor: Colors.deepPurple, contentPadding: EdgeInsets.zero),
              )).toList()),
          ],
          const SizedBox(height: 12),
          InkWell(onTap: _pickDate, child: InputDecorator(decoration: _inputDeco('Date'),
            child: Text('${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(color: Colors.white))),
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _notesCtrl, style: const TextStyle(color: Colors.white),
            decoration: _inputDeco('Notes (optional)'), maxLines: 2),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save', style: TextStyle(fontSize: 16))),
          const SizedBox(height: 16),
        ]),
      ),
    ),
    );
  }
}