import 'package:flutter_test/flutter_test.dart';

import 'package:dengueshield_bd/services/dengue_scraper.dart';

void main() {
  test('fallback dengue data is marked as sample data', () {
    expect(DengueData.fallback.isSample, isTrue);
    expect(DengueData.fallback.isLive, isFalse);
  });

  test('cached dengue data preserves reported values', () {
    const data = DengueData(
      totalCasesThisYear: 1200,
      totalDeathsThisYear: 8,
      casesThisWeek: 45,
      source: 'DGHS',
      isLive: true,
    );

    final cached = DengueData.fromCache(data.toJson());

    expect(cached.totalCasesThisYear, 1200);
    expect(cached.totalDeathsThisYear, 8);
    expect(cached.casesThisWeek, 45);
    expect(cached.source, 'DGHS');
    expect(cached.isLive, isFalse);
    expect(cached.isSample, isFalse);
  });
}
