import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
class PartnersScreen extends ConsumerStatefulWidget {
  const PartnersScreen({super.key});
  @override
  ConsumerState<PartnersScreen> createState() => _PartnersScreenState();
}
class _PartnersScreenState extends ConsumerState<PartnersScreen> {
  String? _babyMonId;
  List<Map<String, dynamic>> _partners = [];
  bool _isLoading = true;
  DateTime? _lastDataRefresh;
  static const _refreshCooldown = Duration(seconds: 10);
  final List<String> _roles = ['PARENT', 'GUARDIAN', 'GRANDPARENT'];

  String _roleLabel(String role) {
    switch (role) {
      case 'PARENT': return context.l10n.parentRole;
      case 'GUARDIAN': return context.l10n.guardianRole;
      case 'GRANDPARENT': return context.l10n.grandparentRole;
      default: return role;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ACCEPTED': return context.l10n.accepted;
      case 'PENDING': return context.l10n.pending;
      case 'DECLINED': return context.l10n.declined;
      default: return status;
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    ref.listenManual(appRefreshProvider, (prev, next) {
      if (prev != next) _loadData();
    });
  }
  Future<void> _loadData({bool force = false}) async {
    if (!force && _lastDataRefresh != null && _babyMonId != null) {
      final elapsed = DateTime.now().difference(_lastDataRefresh!);
      if (elapsed < _refreshCooldown) return;
    }
    final api = ref.read(apiClientProvider);
    final id = await api.getSelectedBabyMonId();
    if (id == null || id.isEmpty) {
      if (id != null && id.isEmpty) await api.setSelectedBabyMonId(null);
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    _babyMonId = id;
    await _fetchPartners();
    _lastDataRefresh = DateTime.now();
  }
  Future<void> _fetchPartners() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_babyMonId == null) return;
    if (mounted) setState(() => _isLoading = true);
    try {
      final response = await ref.read(apiClientProvider).getPartners(_babyMonId!);
      if (mounted) {
        final raw = response.data;
        setState(() {
          _partners = raw is List ? List<Map<String, dynamic>>.from(raw) : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
    }
  }
  Future<void> _invitePartner(String email, String role) async {
    final messenger = ScaffoldMessenger.of(context);
    final noBabyMonText = context.l10n.noBabyMonFound;
    final invitationSentText = context.l10n.invitationSent;
    if (_babyMonId == null) {
      messenger.showSnackBar(SnackBar(content: Text(noBabyMonText)));
      return;
    }
    try {
      await ref.read(apiClientProvider).invitePartner(_babyMonId!, email, role);
      await _fetchPartners();
      messenger.showSnackBar(SnackBar(content: Text(invitationSentText)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
    }
  }
  Future<void> _respondToInvitation(String partnerId, String status) async {
    final messenger = ScaffoldMessenger.of(context);
    final partnerAcceptedText = context.l10n.partnerAccepted;
    final invitationDeclinedText = context.l10n.invitationDeclined;
    try {
      await ref.read(apiClientProvider).respondToInvitation(partnerId, status);
      await _fetchPartners();
      messenger.showSnackBar(SnackBar(content: Text(status == 'ACCEPTED' ? partnerAcceptedText : invitationDeclinedText)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
    }
  }
  Future<void> _removePartner(String partnerId, int index) async {
    final messenger = ScaffoldMessenger.of(context);
    final partnerRemovedText = context.l10n.partnerRemoved;
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: context.l10n.removePartnerTitle,
      message: context.l10n.areYouSure,
      confirmLabel: context.l10n.removeLabel,
    );
    if (confirmed != true) return;
    try {
      await ref.read(apiClientProvider).removePartner(_babyMonId ?? '', partnerId);
      if (mounted) setState(() => _partners.removeAt(index));
      messenger.showSnackBar(SnackBar(content: Text(partnerRemovedText)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
    }
  }
  Color _statusColor(String status) {
    switch (status) { case 'ACCEPTED': return AppColors.success; case 'PENDING': return AppColors.warning; case 'DECLINED': return AppColors.textCaption; default: return AppColors.textCaption; }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScreenHeader(title: context.l10n.partners),
      body: PremiumBackground(
        child: _isLoading ? PremiumLoading.spinner()
            : _partners.isEmpty ? PremiumEmptyState(icon: PhosphorIconsLight.userPlus,        title: context.l10n.noPartnersYet, subtitle: context.l10n.tapToInvite, actionLabel: context.l10n.invitePartnerTitle, onAction: _showInviteDialog)
            : RefreshIndicator(
              onRefresh: _fetchPartners,
              child: ListView.builder(
                padding: const EdgeInsets.all(DesignTokens.spaceMd), itemCount: _partners.length,
                itemBuilder: (context, index) {
                  final partner = _partners[index];
                  final status = parseString(partner['status']) ?? 'PENDING';
                  final user = parseJsonMap(partner['user']);
                  return ScrollStagger(
                    index: index,
                    child: Dismissible(
                      key: Key(parseString(partner['id']) ?? index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        padding: const EdgeInsetsDirectional.only(end: 20),
                        color: AppColors.error,
                        child: const Icon(PhosphorIconsLight.trash, color: AppColors.textOnPrimary),
                      ),
                      onDismissed: (_) => _removePartner(parseString(partner['id']) ?? '', index),
                      child: PremiumCard(
                        margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _statusColor(status).withValues(alpha: 0.2),
                            child: Icon(
                              status == 'ACCEPTED'
                                  ? PhosphorIconsLight.check
                                  : (status == 'PENDING' ? PhosphorIconsLight.hourglass : PhosphorIconsLight.x),
                              color: _statusColor(status),
                            ),
                          ),
                          title: Text(
                            parseString(user?['name']) ?? parseString(user?['email']) ?? context.l10n.unknownPartner,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (user?['email'] != null)
                                Text(
                                  parseString(user!['email']) ?? '',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _statusColor(status).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      _statusLabel(status),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _statusColor(status),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    parseString(partner['role']) ?? context.l10n.parentRole,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textCaption,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: status == 'PENDING'
                              ? PopupMenuButton<String>(
                                  icon: const Icon(PhosphorIconsLight.dotsThreeVertical),
                                  onSelected: (action) =>
                                      _respondToInvitation(parseString(partner['id']) ?? '', action),
                                  itemBuilder: (ctx) => [
                                    PopupMenuItem(
                                      value: 'ACCEPTED',
                                      child: Text(context.l10n.accept),
                                    ),
                                    PopupMenuItem(
                                      value: 'DECLINED',
                                      child: Text(context.l10n.decline),
                                    ),
                                  ],
                                )
                              : null,
                          isThreeLine: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      floatingActionButton: FadeScaleIn(
        child: FloatingActionButton(
          heroTag: 'add_partner',
          backgroundColor: context.colorScheme.primary,
          foregroundColor: context.colorScheme.onPrimary,
          onPressed: _showInviteDialog,
          child: const Icon(PhosphorIconsLight.userPlus),
        ),
      ),
    );
  }
  void _showInviteDialog() {
    final emailController = TextEditingController();
    String selectedRole = 'PARENT';
    bool isSaving = false;
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => Padding(
      padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, start: 16, end: 16, top: 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(context.l10n.invitePartnerTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 16),
        TextField(controller: emailController, decoration: InputDecoration(labelText: context.l10n.emailLabel, hintText: context.l10n.partnerEmailHint,                        prefixIcon: const Icon(PhosphorIconsLight.envelope)), keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        SegmentedButton<String>(segments: _roles.map((r) => ButtonSegment(value: r, label: Text(_roleLabel(r)))).toList(), selected: {selectedRole}, onSelectionChanged: (s) => setDialogState(() => selectedRole = s.first)),
        const SizedBox(height: 16),
        ThemeButton(
          text: context.l10n.sendInviteLabel,
          onPressed: () async { if (emailController.text.isEmpty) return; setDialogState(() => isSaving = true); await _invitePartner(emailController.text, selectedRole); if (ctx.mounted) Navigator.pop(ctx); },
          isLoading: isSaving,
          fullWidth: true,                semanticLabel: context.l10n.sendPartnerInvitationSemantic,
        ),
        const SizedBox(height: 16),
      ]),
    )));
  }
}
