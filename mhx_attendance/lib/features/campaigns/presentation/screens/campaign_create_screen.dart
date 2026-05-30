import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../campaign_routes.dart';
import '../providers/campaign_providers.dart';
import '../widgets/campaign_form_fields.dart';

class CampaignCreateScreen extends ConsumerStatefulWidget {
  const CampaignCreateScreen({super.key});

  @override
  ConsumerState<CampaignCreateScreen> createState() =>
      _CampaignCreateScreenState();
}

class _CampaignCreateScreenState extends ConsumerState<CampaignCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController(text: 'MHX');
  final _nameController = TextEditingController();
  final _yearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      _showError(AppStrings.campaignDatesRequired);
      return;
    }

    final year = parseCampaignYear(_yearController.text);
    if (year == null) {
      _showError(AppStrings.campaignYearInvalid);
      return;
    }

    try {
      final campaign =
          await ref.read(campaignControllerProvider.notifier).createCampaign(
                code: _codeController.text,
                name: _nameController.text,
                year: year,
                startDate: _startDate!,
                endDate: _endDate!,
              );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.campaignCreated(campaign.id))),
      );
      context.go(CampaignRoutes.detail(campaign.id));
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(campaignControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.campaignCreateTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CampaignFormFields(
              codeController: _codeController,
              nameController: _nameController,
              yearController: _yearController,
              startDate: _startDate,
              endDate: _endDate,
              onPickStartDate: () async {
                final picked =
                    await pickCampaignDate(context, initial: _startDate);
                if (picked != null) setState(() => _startDate = picked);
              },
              onPickEndDate: () async {
                final picked = await pickCampaignDate(
                  context,
                  initial: _endDate ?? _startDate,
                  firstDate: _startDate,
                );
                if (picked != null) setState(() => _endDate = picked);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSaving ? null : _submit,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AppStrings.campaignSave),
            ),
          ],
        ),
      ),
    );
  }
}
