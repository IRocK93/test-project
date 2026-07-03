import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/feed_log.dart';
const _measurementUnitsKey = 'measurement_units_pref';
enum FeedMethod { bottle, breast, spoon, cup }
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
  FeedMethod? _method = FeedMethod.bottle;
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
    if (v != null) {
      setState(() {
      _type = v;
      _isPiece = false;
      if (v == FeedType.breastmilk) {
        _method = FeedMethod.breast;
      } else if (v == FeedType.formula) {
        _method = FeedMethod.bottle;
      } else if (v == FeedType.solid) {
        _method = FeedMethod.spoon;
      } else {
        _method = FeedMethod.cup;
      }
    });
    }
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
      Text('${context.l10n.feedUnitLabel}: ', style: const TextStyle(color: Colors.grey)),
      SegmentedButton<bool>(
        segments: [
          ButtonSegment(value: false, label: Text(context.l10n.weightLabel), icon: const Icon(Icons.scale, size: 14)),
          ButtonSegment(value: true, label: Text(context.l10n.pieceLabel), icon: const Icon(Icons.circle, size: 14)),
        ],
        selected: {_isPiece},
        onSelectionChanged: (v) => setState(() => _isPiece = v.first),
        style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.deepPurple.withValues(alpha: 0.3) : null)),
      ),
    ]);
  }
  String _labelForType(FeedType t) {
    switch (t) {
      case FeedType.breastmilk: return '🤱 ${context.l10n.breastmilkLabel}';
      case FeedType.formula: return '🍼 ${context.l10n.formula}';
      case FeedType.solid: return '🥄 ${context.l10n.solidFood}';
    }
  }
  String _methodLabel(FeedMethod m) {
    switch (m) {
      case FeedMethod.bottle: return context.l10n.feedMethodBottle;
      case FeedMethod.breast: return context.l10n.feedMethodBreast;
      case FeedMethod.spoon: return context.l10n.feedMethodSpoon;
      case FeedMethod.cup: return context.l10n.feedMethodCup;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(context).viewInsets.bottom, start: 16, end: 16, top: 16),
      child: Form(
        key: _formKey, child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(context.l10n.logFeed, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 12),
          _buildPieceToggle(),
          const SizedBox(height: 12),
          DropdownButtonFormField<FeedType>(
            initialValue: _type, dropdownColor: const Color(0xFF1E1E1E), style: const TextStyle(color: Colors.white),
            decoration: _inputDeco(context.l10n.feedTypeLabel),
            items: FeedType.values.map((t) => DropdownMenuItem(value: t, child: Text(_labelForType(t)))).toList(),
            onChanged: _onTypeChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<FeedMethod>(
            initialValue: _method, dropdownColor: const Color(0xFF1E1E1E), style: const TextStyle(color: Colors.white),
            decoration: _inputDeco(context.l10n.feedMethodLabel),
            items: FeedMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(_methodLabel(m)))).toList(),
            onChanged: (v) => setState(() => _method = v),
          ),
          if (_showAmount) ...[
            const SizedBox(height: 12),
            TextFormField(controller: _amountCtrl, style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('${context.l10n.feedAmountLabel} ($_unit)'), keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? context.l10n.feedRequired : null),
          ],
          if (_showDuration) ...[
            const SizedBox(height: 12),
            TextFormField(controller: _durationCtrl, style: const TextStyle(color: Colors.white),
              decoration: _inputDeco(context.l10n.feedDurationLabel), keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? context.l10n.feedRequired : null),
          ],
          if (_showBreast) ...[
            const SizedBox(height: 12), Row(
              children: [context.l10n.feedLeftSide, context.l10n.feedRightSide].map((s) => Expanded(
                child: RadioListTile<String>(title: Text(s, style: const TextStyle(color: Colors.white)),
                  // ignore: deprecated_member_use
                  value: s.toLowerCase(), groupValue: _side,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => _side = v),
                  activeColor: Colors.deepPurple, contentPadding: EdgeInsets.zero),
              )).toList()),
          ],
          const SizedBox(height: 12),
          InkWell(onTap: _pickDate, child: InputDecorator(decoration: _inputDeco(context.l10n.feedDateLabel),
            child: Text('${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(color: Colors.white))),
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _notesCtrl, style: const TextStyle(color: Colors.white),
            decoration: _inputDeco(context.l10n.notesOptionalLabel), maxLines: 2),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(context.l10n.save, style: const TextStyle(fontSize: 16))),
          const SizedBox(height: 16),
        ]),
      ),
    ),
    );
  }
}