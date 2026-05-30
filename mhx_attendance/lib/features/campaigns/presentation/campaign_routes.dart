abstract final class CampaignRoutes {
  static const list = '/campaigns';
  static const create = '/campaigns/new';
  static const select = '/campaigns/select';

  static String detail(String campaignId) => '/campaigns/$campaignId';

  static bool isCampaignPath(String location) =>
      location == list ||
      location == create ||
      location == select ||
      location.startsWith('$list/');
}
