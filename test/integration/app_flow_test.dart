// test/integration/app_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_discount_calculator/features/main_navigation/presentation/screens/main_navigation_screen.dart';
import 'package:smart_discount_calculator/core/services/data_service.dart';
import 'package:smart_discount_calculator/core/constants/app_strings.dart';

void main() {
  group('End-to-End App Flow Integration Tests', () {
    setUp(() async {
      // Mock persistence
      SharedPreferences.setMockInitialValues({});
      // Initialize service and clear state
      await dataService.init();
      dataService.clear();
    });

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('Full Add and Delete Item Flow', (WidgetTester tester) async {
      // 0. Set larger surface size to avoid overflow on small test screens
      tester.view.physicalSize = const Size(1024, 2048);
      tester.view.devicePixelRatio = 1.0;

      // 1. Launch the app
      await tester.pumpWidget(const MaterialApp(home: MainNavigationScreen()));
      await settle(tester);

      // 2. Verify we start on Shopping List (since selectedIndex is 1 by default)
      expect(find.text(AppStrings.calcTitle), findsOneWidget);

      // Verify we are on Shopping List screen (empty state)
      expect(find.text(AppStrings.listEmptyMsg), findsOneWidget);

      // 4. Open Add Item Modal
      await tester.tap(find.byIcon(Icons.add));
      await settle(tester);
      expect(find.text(AppStrings.modalAddItem), findsOneWidget);

      // 5. Fill the form
      // Select Category (Labels are Uppercase in CategorySelector)
      await tester.tap(find.text('GROCERY'));
      await tester.pump();

      // Enter Name (TextField index 0)
      await tester.enterText(find.byType(TextField).at(0), 'Whole Bread');

      // Enter Quantity (TextField index 1)
      await tester.enterText(find.byType(TextField).at(1), '1');

      // Enter Price (TextField index 2 for Flat Amount)
      await tester.enterText(find.byType(TextField).at(2), '60');
      await tester.pump();
      await settle(tester);

      // 6. Add Item
      await tester.tap(find.text(AppStrings.modalBtnAdd));
      await settle(tester); // Wait for modal to close

      // 7. Verify item is in list
      expect(find.text('Whole Bread'), findsOneWidget);
      // Summary shows the final total value
      expect(find.textContaining('60'), findsAtLeastNWidgets(1));

      // 8. Delete the item
      await tester.tap(find.byIcon(Icons.delete_outline));
      await settle(tester);

      // Confirm delete dialog
      expect(find.text(AppStrings.dialogConfirmDelete), findsOneWidget);
      await tester.tap(find.text(AppStrings.listBtnYesDelete));
      await settle(tester);

      // 9. Verify list is empty again
      expect(find.text('Whole Bread'), findsNothing);
      expect(find.text(AppStrings.listEmptyMsg), findsOneWidget);

      // Reset view size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
