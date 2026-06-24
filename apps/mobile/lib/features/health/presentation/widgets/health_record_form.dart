import 'package:flutter/material.dart';
import '../../domain/entities/health_record.dart';

enum HealthCategory { CHECKUP, VACCINE, MEDICATION, MEASUREMENT, OTHER }

class HealthRecordForm extends StatefulWidget {
  final String babyMonId;
  final Future<void> Function(HealthRecord) onSubmit;

  const HealthRecordForm({super.key, required this.babyMonId, required this.onSubmit});
  @override
  State<HealthRecordForm> createState() => _HealthRecordFormState();
}

class _HealthRecordFormState extends State<HealthRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  HealthCategory _category = HealthCategory.CHECKUP;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _valueCtrl.dispose();
    _unitCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (p != null) setState(() => _date = p);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final record = HealthRecord(
        id: '',
        category: _category.name,
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        value: double.tryParse(_valueCtrl.text),
        unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        happenedAt: _date,
      );
      await widget.onSubmit(record);
    } finally { if (mounted) setState(() => _saving = false); }
  }

  InputDecoration _deco(String label) => InputDecoration(
    labelText: label, labelStyle: TextStyle(color: Colors.grey[400]),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple)),
    filled: true, fillColor: const Color(0xFF2A2A2A),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey, child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Log Health Record', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<HealthCategory>(
            value: _category, dropdownColor: const Color(0xFF1E1E1E), style: const TextStyle(color: Colors.white),
            decoration: _deco('Category'),
            items: HealthCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _titleCtrl, style: const TextStyle(color: Colors.white),
            decoration: _deco('Title (optional)')),
          const SizedBox(height: 12),
          TextFormField(controller: _valueCtrl, style: const TextStyle(color: Colors.white),
            decoration: _deco('Value'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextFormField(controller: _unitCtrl, style: const TextStyle(color: Colors.white),
            decoration: _deco('Unit (optional)')),
          const SizedBox(height: 12),
          InkWell(onTap: _pickDate, child: InputDecorator(decoration: _deco('Date'),
            child: Text(_date.day.toString() + '/' + _date.month.toString() + '/' + _date.year.toString(), style: const TextStyle(color: Colors.white))),
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _notesCtrl, style: const TextStyle(color: Colors.white),
            decoration: _deco('Notes (optional)'), maxLines: 2),
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
