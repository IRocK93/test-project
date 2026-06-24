import 'package:flutter/material.dart';
// ignore_for_file: unused_element
import '../../domain/entities/milestone.dart';

class MilestoneForm extends StatefulWidget {
  final String babyMonId;
  final Future<void> Function(Milestone milestone) onSubmit;

  const MilestoneForm({super.key, required this.babyMonId, required this.onSubmit});

  @override
  State<MilestoneForm> createState() => _MilestoneFormState();
}

class _MilestoneFormState extends State<MilestoneForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = '';
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final milestone = Milestone(
        id: '', // assigned by backend
        // babyMonId removed,
        title: _titleController.text.trim(),
        notes: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        happenedAt: _date,
      );
      await widget.onSubmit(milestone);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Milestone', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Title *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Category'),
                items: ["Motor","Cognitive","Language","Social","Physical","Emotional","Health","Sleep","Feeding","Play","Development","Diaper"].map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _inputDeco('Date'),
                  child: Text(
                    '${_date.day}/${_date.month}/${_date.year}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Description (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Milestone', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _emoji(String c) {
    switch (c) {
      case "SLEEP": return '😴';
      case "FEEDING": return '🍼';
      case "DIAPER": return '🧷';
      case "PLAY": return '🎮';
      case "DEVELOPMENT": return '🧠';
      case "HEALTH": return '💊';
      default: return '🌟';
    }
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple)),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
    );
  }
}
