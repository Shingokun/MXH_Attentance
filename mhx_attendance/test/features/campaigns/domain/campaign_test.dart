import 'package:flutter_test/flutter_test.dart';
import 'package:mhx_attendance/features/campaigns/domain/campaign.dart';
import 'package:mhx_attendance/features/campaigns/domain/campaign_neighborhood.dart';

void main() {
  group('Campaign', () {
    test('normalizeCode accepts valid codes', () {
      expect(Campaign.normalizeCode('mhx'), 'MHX');
      expect(Campaign.normalizeCode('TET'), 'TET');
      expect(Campaign.normalizeCode(' he2 '), 'HE2');
    });

    test('normalizeCode rejects invalid codes', () {
      expect(Campaign.normalizeCode('A'), isNull);
      expect(Campaign.normalizeCode(''), isNull);
      expect(Campaign.normalizeCode('TOOLONGCODE'), isNull);
    });

    test('composeId builds code-year id', () {
      expect(
        Campaign.composeId(code: 'MHX', year: 2026),
        'MHX-2026',
      );
      expect(
        Campaign.composeId(code: 'TET', year: 2026),
        'TET-2026',
      );
    });

    test('same year allows different codes', () {
      expect(
        Campaign.composeId(code: 'MHX', year: 2026),
        isNot(Campaign.composeId(code: 'TET', year: 2026)),
      );
    });
  });

  group('CampaignNeighborhood', () {
    test('composeId joins campaign and neighborhood', () {
      expect(
        CampaignNeighborhood.composeId(
          campaignId: 'TET-2026',
          neighborhoodId: 'KP03',
        ),
        'TET-2026_KP03',
      );
    });
  });
}
