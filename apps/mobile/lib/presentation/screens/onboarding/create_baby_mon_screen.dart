import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/presentation/providers/auth_provider.dart';
import 'package:baby_mon/core/constants/api_constants.dart';

class CreateBabyMonScreen extends ConsumerStatefulWidget {
  const CreateBabyMonScreen({super.key});

  @override
  ConsumerState<CreateBabyMonScreen> createState() => _CreateBabyMonScreenState();
}

class _CreateBabyMonScreenState extends ConsumerState<CreateBabyMonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialMoveController = TextEditingController();

  String _stageType = 'BORN';
  DateTime? _birthDate;
  DateTime? _conceptionDate;
  DateTime? _ideaDate;
  String _gender = 'MONIOUS';
  List<String> _selectedTraits = [];
  bool _isLoading = false;

  final List<String> _traits = ['Curious', 'Peaceful', 'Playful', 'Gentle', 'Adventurous', 'Creative'];

  @override
  void dispose() {
    _nameController.dispose();
    _specialMoveController.dispose();
    super.dispose();
  }

  String? _validateDate() {
    if (_stageType == 'BORN' && _birthDate == null) return 'Please select a birth date';
    if (_stageType == 'CONCEIVED' && _conceptionDate == null) return 'Please select a conception date';
    if (_stageType == 'IDEA' && _ideaDate == null) return 'Please select a planning date';
    return null;
  }

  Future<void> _createBabyMon() async {
    if (!_formKey.currentState!.validate()) return;

    final dateError = _validateDate();
    if (dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dateError)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{
        'name': _nameController.text,
        'stageStartType': _stageType,
        'gender': _gender,
        'traits': _selectedTraits,
        if (_specialMoveController.text.isNotEmpty) 'specialMove': _specialMoveController.text,
      };

      // Always send the relevant date based on stage
      if (_stageType == 'BORN' && _birthDate != null) {
        data['birthDate'] = DateFormat('yyyy-MM-dd').format(_birthDate!);
      } else if (_stageType == 'CONCEIVED' && _conceptionDate != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(_conceptionDate!);
        data['conceptionDate'] = dateStr;
        // Backend also requires lmpDate for CONCEIVED stage
        data['lmpDate'] = dateStr;
      } else if (_stageType == 'IDEA' && _ideaDate != null) {
        data['ideaDate'] = DateFormat('yyyy-MM-dd').format(_ideaDate!);
      }

      final response = await ref.read(apiClientProvider).post('/baby-mons', data: data);
      await ref.read(apiClientProvider).setSelectedBabyMonId(response.data['id']);
      // Bump the global refresh counter so all tab screens reload
      ref.read(appRefreshProvider.notifier).state++;

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      String message = 'Failed to create BabyMon';
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          message = 'Server error. Please try again.';
        } else if (e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map) {
            final msg = data['message'];
            if (msg is List) {
              message = msg.join(', ');
            } else if (msg is String) {
              message = msg;
            }
          }
        } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
          message = 'Cannot connect to server. Please check your connection.';
        } else {
          message = 'Request failed. Please try again.';
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? initial, Function(DateTime) onSelect, {bool allowFuture = false}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2020),
      lastDate: allowFuture ? now.add(const Duration(days: 280)) : now,
      helpText: allowFuture ? 'Select expected date' : null,
    );
    if (picked != null) {
      onSelect(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create BabyMon'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('What\'s your BabyMon\'s name?', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Enter name', prefixIcon: Icon(Icons.child_care)),
                validator: (v) => v?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 24),
              Text('Current Stage', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'IDEA', label: Text('Planning')),
                  ButtonSegment(value: 'CONCEIVED', label: Text('Expecting')),
                  ButtonSegment(value: 'BORN', label: Text('Born')),
                ],
                selected: {_stageType},
                onSelectionChanged: (s) => setState(() => _stageType = s.first),
              ),
              const SizedBox(height: 16),
              if (_stageType == 'BORN')
                _buildDateSelector('Birth Date', _birthDate, (d) => setState(() => _birthDate = d)),
              if (_stageType == 'CONCEIVED')
                _buildDateSelector('Expected Date', _conceptionDate, (d) => setState(() => _conceptionDate = d), allowFuture: true),
              if (_stageType == 'IDEA')
                _buildDateSelector('When did you start planning?', _ideaDate, (d) => setState(() => _ideaDate = d)),
              const SizedBox(height: 24),
              Text('Gender', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'MONIOUS', label: Text('Monious')),
                  ButtonSegment(value: 'MONIESE', label: Text('Moniese')),
                  ButtonSegment(value: 'MO', label: Text('Mo')),
                ],
                selected: {_gender},
                onSelectionChanged: (s) => setState(() => _gender = s.first),
              ),
              const SizedBox(height: 24),
              Text('Traits (up to 3)', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._traits.map((trait) {
                    final selected = _selectedTraits.contains(trait);
                    return FilterChip(
                      label: Text(trait),
                      selected: selected,
                      onSelected: (s) {
                        setState(() {
                          if (s && _selectedTraits.length < 3) {
                            _selectedTraits.add(trait);
                          } else if (!s) {
                            _selectedTraits.remove(trait);
                          }
                        });
                      },
                    );
                  }),
                  // Show selected custom traits as removable chips
                  ..._selectedTraits
                      .where((t) => !_traits.contains(t))
                      .map((customTrait) => FilterChip(
                            label: Text(customTrait),
                            selected: true,
                            onSelected: (_) {
                              setState(() => _selectedTraits.remove(customTrait));
                            },
                          )),
                  // Custom trait input chip
                  if (_selectedTraits.length < 3)
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: const Text('Custom'),
                      onPressed: () => _showCustomTraitDialog(),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Special Move (optional)', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _specialMoveController,
                decoration: const InputDecoration(hintText: 'A unique thing about your BabyMon'),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _createBabyMon,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create BabyMon'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomTraitDialog() {
    final traitController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Trait'),
        content: TextField(
          controller: traitController,
          decoration: const InputDecoration(hintText: 'e.g., Brave, Silly, Kind'),
          maxLength: 20,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final trait = traitController.text.trim();
              if (trait.isNotEmpty) {
                setState(() => _selectedTraits.add(trait));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, Function(DateTime) onSelect, {bool allowFuture = false}) {
    return InkWell(
      onTap: () => _selectDate(context, date, onSelect, allowFuture: allowFuture),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today)),
        child: Text(date != null ? DateFormat.yMMMd().format(date) : 'Select date'),
      ),
    );
  }
}
