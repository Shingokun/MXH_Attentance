import 'package:cloud_firestore/cloud_firestore.dart';

/// Document `campaigns/{campaignId}` — PK = `{code}-{year}` (vd. `MHX-2026`, `TET-2026`).
class Campaign {
  const Campaign({
    required this.id,
    required this.name,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdBy,
    this.code,
    this.createdAt,
  });

  final String id;
  final String name;
  final int year;
  /// Mã viết tắt (vd. MHX, TET) — denorm từ [id].
  final String? code;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String createdBy;
  final DateTime? createdAt;

  static final RegExp _codePattern = RegExp(r'^[A-Z0-9]{2,8}$');

  /// Chuẩn hoá mã viết tắt: 2–8 ký tự A–Z, 0–9.
  static String? normalizeCode(String raw) {
    final c = raw.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (c.length < 2 || c.length > 8 || !_codePattern.hasMatch(c)) return null;
    return c;
  }

  static String composeId({required String code, required int year}) {
    final normalized = normalizeCode(code);
    if (normalized == null) {
      throw ArgumentError('Mã chiến dịch không hợp lệ: $code');
    }
    return '$normalized-$year';
  }

  bool get isUpcoming => DateTime.now().isBefore(startDate);

  bool get isEnded => DateTime.now().isAfter(endDate);

  bool get isRunning =>
      !isUpcoming && !isEnded && isActive;

  factory Campaign.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Campaign(
      id: doc.id,
      name: data['name'] as String? ?? '',
      year: (data['year'] as num?)?.toInt() ?? 0,
      startDate: _readDate(data['start_date']),
      endDate: _readDate(data['end_date']),
      isActive: data['is_active'] as bool? ?? false,
      createdBy: data['created_by'] as String? ?? '',
      code: data['code'] as String? ?? _codeFromId(doc.id),
      createdAt: _readDateOrNull(data['created_at']),
    );
  }

  static String? _codeFromId(String id) {
    final lastDash = id.lastIndexOf('-');
    if (lastDash <= 0) return null;
    final yearPart = id.substring(lastDash + 1);
    if (int.tryParse(yearPart) == null) return null;
    return id.substring(0, lastDash);
  }

  Map<String, dynamic> toFirestore({required String createdBy}) {
    return {
      'name': name,
      'year': year,
      if (code != null) 'code': code,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    throw FormatException('Invalid date field: $value');
  }

  static DateTime? _readDateOrNull(dynamic value) {
    if (value == null) return null;
    return _readDate(value);
  }
}
