import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/feed_log.dart';
const _measurementUnitsKey = 'measurement_units_pref';
enum FeedMethod { BOTTLE, BREAST, SPOON, CUP }
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
  FeedType _type = FeedType.formula;
  FeedMethod? _method = FeedMethod.BOTTLE;
  String? _side;
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _isMetric = true;
  bool _isPiece = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUnitPref());
  }
  Future<void> _loadUnitPref() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_measurementUnitsKey);
    if (mounted) setState(() => _isMetric = val != 'imperial');
  }
  @override
  void dispose() {
    _amountCtrl.dispose();
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
  String get _unit {
    if (_type == FeedType.solid && _isPiece) return 'piece';
    if (_isMetric) {
      switch (_type) {
        case FeedType.breastmilk:
        case FeedType.formula:
          return 'ml';
        case FeedType.solid:
          return 'g';
      }
    } else {
      switch (_type) {
        case FeedType.breastmilk:
        case FeedType.formula:
          return 'fl oz';
        case FeedType.solid:
          return 'oz';
      }
    }
  }
  bool get _showAmount => true;
  bool get _showBreast => _type == FeedType.breastmilk;
  bool get _showDuration => _showBreast || _type == FeedType.solid;
  void _onTypeChanged(FeedType? v) {
    if (v != null) setState(() {
      _type = v;
      _isPiece = false;
      if (v == FeedType.breastmilk) _method = FeedMethod.BREAST;
      else if (v == FeedType.formula) _method = FeedMethod.BOTTLE;
      else if (v == FeedType.solid) _method = FeedMethod.SPOON;
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
        id: '',
        type: _type.apiKey,
        amount: _showAmount ? double.tryParse(_amountCtrl.text) : null,
        unit: _unit,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          happenedAt: _date,
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
    if (_type != FeedType.solid) return const SizedBox.shrink();
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Unit: ', style: TextStyle(color: Colors.grey)),
      SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, label: Text('Weight'), icon: Icon(Icons.scale, size: 14)),
          ButtonSegment(value: true, label: Text('Piece'), icon: Icon(Icons.circle, size: 14)),
        ],
        selected: {_isPiece},
        onSelectionChanged: (v) => setState(() => _isPiece = v.first),
        style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.deepPurple.withValues(alpha: 0.3) : null)),
      ),
    ]);
  }
  String _labelForType(FeedType t) {
    switch (t) {
      case FeedType.breastmilk: return '🤱 Breastmilk';
      case FeedType.formula: return '🍼 Formula';
      case FeedType.solid: return '🥄 Solid';
    }
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
          _buildPieceToggle(),
          const SizedBox(height: 12),
          DropdownButtonFormField<FeedType>(
            value: _type, dropdownColor: const Color(0xFF1E1E1E), style: const TextStyle(color: Colors.white),
            decoration: _inputDeco('Type'),
            items: FeedType.values.map((t) => DropdownMenuItem(value: t, child: Text(_labelForType(t)))).toList(),
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