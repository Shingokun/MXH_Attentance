/// Bộ lọc danh sách chiến dịch (`CAM-01`).
enum CampaignListFilter {
  all,
  active,
  inactive,
  running,
  upcoming,
  ended,
}

extension CampaignListFilterX on CampaignListFilter {
  String get label => switch (this) {
        CampaignListFilter.all => 'Tất cả',
        CampaignListFilter.active => 'Đang bật',
        CampaignListFilter.inactive => 'Đã tắt',
        CampaignListFilter.running => 'Đang diễn ra',
        CampaignListFilter.upcoming => 'Sắp tới',
        CampaignListFilter.ended => 'Đã kết thúc',
      };
}
