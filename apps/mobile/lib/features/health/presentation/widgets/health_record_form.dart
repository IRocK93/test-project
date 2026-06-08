import 'package:flutter/material.dart';
import '../../domain/entities/health_record.dart';

class HealthRecordForm extends StatefulWidget {
  final String babyMonId;
  final Future<void> Function(HealthRecord) onSubmit;

  const HealthRecordForm({super.key, required this.babyMonId, required this.onSubmit});
  @override
  State<HealthRecordForm> createState() => _HealthRecordFormState();
}

class _HealthRecordFormState extends State<HealthRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _doctorCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  HealthRecordType _type = HealthRecordType.CHECKUP;
  HealthRecordStatus _status = HealthRecordStatus.SCHEDULED;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _doctorCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (p != null) setState(() => _date = p);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final record = HealthRecord(
        id: '', babyMonId: widget.babyMonId, type: _type, status: _status,
        date: _date, notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        doctorName: _doctorCtrl.text.trim().isEmpty ? null : _doctorCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        createdAt: DateTime.now(),
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
      child: Form(key: _formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Health Record', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 16),
        DropdownButtonFormField<HealthRecordType>(
          value: _type, dropdownColor: const Color(0xFF1E1E1E), style: const TextStyle(color: Colors.white),
          decoration: _deco('Type'),
          items: HealthRecordType.values.map((t) => DropdownMenuItem(value: t, child: Text('${t.typeEmoji} ${t.name}'))).toList(),
          onChanged: (v) => setState(() => _type = v!),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<HealthRecordStatus>(
          value: _status, dropdownColor: const Color(0xFF1E1E1E), style: const TextStyle(color: Colors.white),
          decoration: _deco('Status'),
          items: HealthRecordStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
          onChanged: (v) => setState(() => _status = v!),
        ),
        const SizedBox(height: 12),
        InkWell(onTap: _pickDate, child: InputDecorator(decoration: _deco('Date'),
          child: Text('${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(color: Colors.white)))),
        const SizedBox(height: 12),
        TextFormField(controller: _doctorCtrl, style: const TextStyle(color: Colors.white),
          decoration: _deco('Doctor name (optional)')),
        const SizedBox(height: 12),
        TextFormField(controller: _locationCtrl, style: const TextStyle(color: Colors.white),
          decoration: _deco('Location (optional)')),
        const SizedBox(height: 12),
        TextFormField(controller: _notesCtrl, style: const TextStyle(color: Colors.white),
          decoration: _deco('Notes (optional)'), maxLines: 3),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 16)),
          child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Save', style: TextStyle(fontSize: 16))),
        const SizedBox(height: 16),
      ]))),
    );
  }
}
