import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/campaign.dart';

class CampaignFormFields extends StatelessWidget {
  const CampaignFormFields({
    super.key,
    required this.nameController,
    required this.yearController,
    required this.startDate,
    required this.endDate,
    required this.onPickStartDate,
    required this.onPickEndDate,
    this.codeController,
    this.lockYear = false,
    this.lockCode = false,
  });

  final TextEditingController nameController;
  final TextEditingController? codeController;
  final TextEditingController yearController;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final bool lockYear;
  final bool lockCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (codeController != null) ...[
          TextFormField(
            controller: codeController,
            decoration: const InputDecoration(
              labelText: AppStrings.campaignCodeLabel,
              hintText: AppStrings.campaignCodeHint,
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            readOnly: lockCode,
            enabled: !lockCode,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              LengthLimitingTextInputFormatter(8),
            ],
            validator: (v) {
              if (lockCode) return null;
              if (Campaign.normalizeCode(v ?? '') == null) {
                return AppStrings.campaignCodeInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: AppStrings.campaignNameLabel,
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? AppStrings.campaignNameRequired : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: yearController,
          decoration: InputDecoration(
            labelText: AppStrings.campaignYearLabel,
            border: const OutlineInputBorder(),
            helperText: lockYear ? AppStrings.campaignYearLocked : null,
          ),
          keyboardType: TextInputType.number,
          readOnly: lockYear,
          enabled: !lockYear,
          validator: (v) {
            if (lockYear) return null;
            final year = int.tryParse(v ?? '');
            if (year == null || year < 2000 || year > 2100) {
              return AppStrings.campaignYearInvalid;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _DateField(
          label: AppStrings.campaignStartDateLabel,
          date: startDate,
          onTap: onPickStartDate,
        ),
        const SizedBox(height: 16),
        _DateField(
          label: AppStrings.campaignEndDateLabel,
          date: endDate,
          onTap: onPickEndDate,
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? AppStrings.campaignPickDate
        : _formatDate(date!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(text),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}

Future<DateTime?> pickCampaignDate(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initial ?? now,
    firstDate: firstDate ?? DateTime(2000),
    lastDate: lastDate ?? DateTime(2100),
  );
}

int? parseCampaignYear(String text) => int.tryParse(text.trim());
