import 'package:flutter_test/flutter_test.dart';
import 'package:uts_aplikasi_rekomendasi_destinasi_wisata_kuliner_lokal/main.dart';

void main() {
  testWidgets('App smoke test - loads LokaNusantaraApp', (WidgetTester tester) async {
    await tester.pumpWidget(const LokaNusantaraApp());
    expect(find.byType(LokaNusantaraApp), findsOneWidget);
  });
}
