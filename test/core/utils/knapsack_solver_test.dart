import 'package:flutter_test/flutter_test.dart';
import 'package:beesaving/core/utils/knapsack_solver.dart';

void main() {
  group('KnapsackSolver Unit Tests', () {
    test('Should return empty cuts when target is 0 or negative', () {
      final items = [
        KnapsackItem(
          id: '1',
          title: 'Ăn tối',
          amount: 200000,
          importanceScore: 4,
          originalObject: null,
        ),
        KnapsackItem(
          id: '2',
          title: 'Cà phê',
          amount: 50000,
          importanceScore: 1,
          originalObject: null,
        ),
      ];

      final result1 = KnapsackSolver.solve(items: items, targetSavings: 0);
      expect(result1.itemsToCut, isEmpty);
      expect(result1.totalSavings, 0.0);
      expect(result1.impactLevel, 'Thấp');

      final result2 = KnapsackSolver.solve(items: items, targetSavings: -100);
      expect(result2.itemsToCut, isEmpty);
      expect(result2.totalSavings, 0.0);
      expect(result2.impactLevel, 'Thấp');
    });

    test('Should cut all items when target exceeds total expense amount', () {
      final items = [
        KnapsackItem(
          id: '1',
          title: 'Tiền nhà',
          amount: 4500000,
          importanceScore: 5,
          originalObject: null,
        ),
        KnapsackItem(
          id: '2',
          title: 'Ăn uống',
          amount: 1500000,
          importanceScore: 4,
          originalObject: null,
        ),
      ];

      final result = KnapsackSolver.solve(items: items, targetSavings: 7000000);
      expect(result.itemsToCut.length, equals(2));
      expect(result.totalSavings, equals(6000000.0));
      expect(result.impactLevel, equals('Cao'));
    });

    test('Should find mathematically optimal cuts with low importance impact', () {
      // Setup identical to example:
      // Total amount: 1450. Target: 120.
      // 1. Rent: 1000, imp 5
      // 2. Food: 300, imp 4
      // 3. Coffee: 50, imp 1
      // 4. Movie: 100, imp 2
      //
      // Options to save >= 120:
      // Option A: Cut Coffee (50) + Movie (100). Savings = 150, Cut Importance = 3.
      // Option B: Cut Food (300). Savings = 300, Cut Importance = 4.
      // Solver should pick Option A because it has lower impact (3 < 4).
      final items = [
        KnapsackItem(
          id: '1',
          title: 'Rent',
          amount: 1000,
          importanceScore: 5,
          originalObject: 'Rent',
        ),
        KnapsackItem(
          id: '2',
          title: 'Food',
          amount: 300,
          importanceScore: 4,
          originalObject: 'Food',
        ),
        KnapsackItem(
          id: '3',
          title: 'Coffee',
          amount: 50,
          importanceScore: 1,
          originalObject: 'Coffee',
        ),
        KnapsackItem(
          id: '4',
          title: 'Movie',
          amount: 100,
          importanceScore: 2,
          originalObject: 'Movie',
        ),
      ];

      final result = KnapsackSolver.solve(items: items, targetSavings: 120);

      // Verify coffee and movie are recommended for cutting
      final cutTitles = result.itemsToCut
          .map((item) => item.originalObject as String)
          .toList();
      expect(cutTitles, containsAll(['Coffee', 'Movie']));
      expect(cutTitles, isNot(contains('Food')));
      expect(cutTitles, isNot(contains('Rent')));
      expect(result.totalSavings, equals(150.0));
      expect(
        result.impactLevel,
        equals('Trung bình'),
      ); // cut importance = 3, total = 12. Ratio = 0.25 (>=0.20 and <0.50 => Medium/Trung bình)
    });

    test(
      'Should handle large monetary numbers (VND scale) without OOM and execute fast',
      () {
        final items = [
          KnapsackItem(
            id: '1',
            title: 'Tiền nhà',
            amount: 5000000,
            importanceScore: 5,
            originalObject: null,
          ),
          KnapsackItem(
            id: '2',
            title: 'Ăn uống',
            amount: 3000000,
            importanceScore: 4,
            originalObject: null,
          ),
          KnapsackItem(
            id: '3',
            title: 'Điện nước',
            amount: 1000000,
            importanceScore: 5,
            originalObject: null,
          ),
          KnapsackItem(
            id: '4',
            title: 'Xem phim',
            amount: 300000,
            importanceScore: 1,
            originalObject: null,
          ),
          KnapsackItem(
            id: '5',
            title: 'Trà sữa',
            amount: 200000,
            importanceScore: 1,
            originalObject: null,
          ),
          KnapsackItem(
            id: '6',
            title: 'Mua sắm',
            amount: 1500000,
            importanceScore: 2,
            originalObject: null,
          ),
        ];

        final stopwatch = Stopwatch()..start();
        final result = KnapsackSolver.solve(
          items: items,
          targetSavings: 800000,
        );
        stopwatch.stop();

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(50),
        ); // Must execute in under 50ms (usually 1-2ms)
        expect(result.totalSavings, greaterThanOrEqualTo(800000.0));

        // Checking that it did not recommend cutting 'Tiền nhà' or 'Ăn uống' or 'Điện nước'
        final cutTitles = result.itemsToCut.map((item) => item.title).toList();
        expect(cutTitles, isNot(contains('Tiền nhà')));
        expect(cutTitles, isNot(contains('Ăn uống')));
        expect(cutTitles, isNot(contains('Điện nước')));
        expect(
          cutTitles.any((t) => ['Xem phim', 'Trà sữa', 'Mua sắm'].contains(t)),
          isTrue,
        );
      },
    );
  });
}
