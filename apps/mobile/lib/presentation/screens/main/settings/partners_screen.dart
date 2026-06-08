import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/core/providers.dart';

/// E3 — Partner Invite & Co-Parent Sync: Manage shared access to baby tracking.
class PartnersScreen extends ConsumerStatefulWidget {
  const PartnersScreen({super.key});

  @override
  ConsumerState<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends ConsumerState<PartnersScreen> {
  String? _babyMonId;
  List<Map<String, dynamic>> _partners = [];
  bool _isLoading = true;
  final List<String> _roles = ['PARENT', 'GUARDIAN', 'GRANDPARENT'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) _loadData();
    });
  }

  Future<void> _loadData() async {
    final api = ref.read(apiClientProvider);
    final id = await api.getSelectedBabyMonId();
    if (id == null || id.isEmpty) {
      if (id != null && id.isEmpty) await api.setSelectedBabyMonId(null);
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    _babyMonId = id;
    await _fetchPartners();
  }

  Future<void> _fetchPartners() async {
    if (_babyMonId == null) return;
    if (mounted) setState(() => _isLoading = true);
    try {
      final response = await ref.read(apiClientProvider).getPartners(_babyMonId!);
      if (mounted) setState(() { _partners = (response.data as List).cast<Map<String, dynamic>>(); _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partners feature coming soon')));
      }
    }
  }

  Future<void> _invitePartner(String email, String role) async {
    if (_babyMonId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No BabyMon found')));
      return;
    }
    try {
      await ref.read(apiClientProvider).invitePartner(_babyMonId!, email, role);
      await _fetchPartners();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation sent!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partners feature coming soon')));
    }
  }

  Future<void> _respondToInvitation(String partnerId, String status) async {
    try {
      await ref.read(apiClientProvider).respondToInvitation(partnerId, status);
      await _fetchPartners();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status == 'ACCEPTED' ? 'Partner accepted!' : 'Invitation declined')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partners feature coming soon')));
    }
  }

  Future<void> _removePartner(String partnerId, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(title: const Text('Remove Partner'), content: const Text('Are you sure?'), actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
      ]),
    );
    if (confirmed != true) return;
    try {
      await ref.read(apiClientProvider).removePartner(partnerId);
      if (mounted) setState(() => _partners.removeAt(index));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partner removed')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _statusColor(String status) {
    switch (status) { case 'ACCEPTED': return Colors.green; case 'PENDING': return Colors.orange; case 'DECLINED': return Colors.grey; default: return Colors.grey; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partners')),
      body: _isLoading ? const Center(child: CircularProgressIndicator())
          : _partners.isEmpty ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.group_add, size: 64, color: Colors.grey), SizedBox(height: 16), Text('No partners yet', style: TextStyle(color: Colors.grey)), Text('Tap + to invite a co-parent')]))
          : RefreshIndicator(
              onRefresh: _fetchPartners,
              child: ListView.builder(
                padding: const EdgeInsets.all(16), itemCount: _partners.length,
                itemBuilder: (context, index) {
                  final partner = _partners[index];
                  final status = partner['status']?.toString() ?? 'PENDING';
                  final user = partner['user'] as Map<String, dynamic>?;
                  return Dismissible(
                    key: Key(partner['id'] ?? index.toString()), direction: DismissDirection.endToStart,
                    background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
                    onDismissed: (_) => _removePartner(partner['id'], index),
                    child: Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
                      leading: CircleAvatar(backgroundColor: _statusColor(status).withOpacity(0.2), child: Icon(status == 'ACCEPTED' ? Icons.check : (status == 'PENDING' ? Icons.hourglass_top : Icons.close), color: _statusColor(status))),
                      title: Text(user?['name'] ?? user?['email'] ?? 'Unknown'),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (user?['email'] != null) Text(user!['email']),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: _statusColor(status).withOpacity(0.3))), child: Text(status, style: TextStyle(fontSize: 11, color: _statusColor(status)))),
                          const SizedBox(width: 8),
                          Text(partner['role'] ?? 'PARENT', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ]),
                      ]),
                      trailing: status == 'PENDING' ? PopupMenuButton<String>(icon: const Icon(Icons.more_vert), onSelected: (action) => _respondToInvitation(partner['id'], action), itemBuilder: (ctx) => [const PopupMenuItem(value: 'ACCEPTED', child: Text('Accept')), const PopupMenuItem(value: 'DECLINED', child: Text('Decline'))]) : null,
                      isThreeLine: true,
                    )),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showInviteDialog(), child: const Icon(Icons.person_add)),
    );
  }

  void _showInviteDialog() {
    final emailController = TextEditingController();
    String selectedRole = 'PARENT';
    bool isSaving = false;
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Invite Partner', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 16),
        TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', hintText: 'partner@email.com', prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        SegmentedButton<String>(segments: _roles.map((r) => ButtonSegment(value: r, label: Text(r[0].toUpperCase() + r.substring(1).toLowerCase()))).toList(), selected: {selectedRole}, onSelectionChanged: (s) => setDialogState(() => selectedRole = s.first)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isSaving ? null : () async { if (emailController.text.isEmpty) return; setDialogState(() => isSaving = true); await _invitePartner(emailController.text, selectedRole); if (ctx.mounted) Navigator.pop(ctx); },
          child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Send Invite'),
        ),
        const SizedBox(height: 16),
      ]),
    )));
  }
}