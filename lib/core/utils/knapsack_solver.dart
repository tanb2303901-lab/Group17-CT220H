import 'dart:math';

class KnapsackItem {
  final String id;
  final String title;
  final double amount;
  final int importanceScore;
  final dynamic originalObject;

  KnapsackItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.importanceScore,
    required this.originalObject,
  });
}

class KnapsackResult {
  final List<KnapsackItem> itemsToCut;
  final double totalSavings;
  final String impactLevel; // Thấp, Trung bình, Cao

  KnapsackResult({
    required this.itemsToCut,
    required this.totalSavings,
    required this.impactLevel,
  });
}

class KnapsackSolver {
  static KnapsackResult solve({
    required List<KnapsackItem> items,
    required double targetSavings,
  }) {
    if (targetSavings <= 0) {
      return KnapsackResult(
        itemsToCut: [],
        totalSavings: 0.0,
        impactLevel: 'Thấp',
      );
    }

    double totalAmount = items.fold(0.0, (sum, item) => sum + item.amount);
    int totalImportance = items.fold(0, (sum, item) => sum + item.importanceScore);

    // Case 1: Target is greater than or equal to total expenses.
    // Must cut everything to get as close as possible.
    if (targetSavings >= totalAmount) {
      return KnapsackResult(
        itemsToCut: List.from(items),
        totalSavings: totalAmount,
        impactLevel: totalImportance > 0 ? 'Cao' : 'Thấp',
      );
    }

    // Capacity for items we KEEP: W = totalAmount - targetSavings
    double rawCapacity = totalAmount - targetSavings;
    if (rawCapacity < 0) rawCapacity = 0;

    int n = items.length;
    if (n == 0) {
      return KnapsackResult(
        itemsToCut: [],
        totalSavings: 0.0,
        impactLevel: 'Thấp',
      );
    }

    // Scale weights to prevent huge DP table size.
    // We scale rawCapacity to fit under maxCapacity (2000).
    const double maxCapacity = 2000.0;
    double scalingFactor = 1.0;
    if (rawCapacity > maxCapacity) {
      scalingFactor = rawCapacity / maxCapacity;
    }

    int capacity = (rawCapacity / scalingFactor).floor();
    List<int> weights = items.map((item) => (item.amount / scalingFactor).ceil()).toList();
    
    // Map importance score (1-5) to exponentially higher values 
    // so that cutting a high importance item is heavily penalized compared to many low importance items.
    List<int> values = items.map((item) {
      switch (item.importanceScore) {
        case 1: return 1;
        case 2: return 10;
        case 3: return 100;
        case 4: return 1000;
        case 5: return 10000;
        default: return 1;
      }
    }).toList();

    // dp[i][w] = max importance score using first i items and capacity w
    List<List<int>> dp = List.generate(
      n + 1,
      (_) => List.filled(capacity + 1, 0),
    );

    for (int i = 1; i <= n; i++) {
      int weight = weights[i - 1];
      int value = values[i - 1];
      for (int w = 0; w <= capacity; w++) {
        if (weight <= w) {
          dp[i][w] = max(dp[i - 1][w], dp[i - 1][w - weight] + value);
        } else {
          dp[i][w] = dp[i - 1][w];
        }
      }
    }

    // Trace back to find which items were KEPT (y_i = 1)
    List<bool> keptFlags = List.filled(n, false);
    int w = capacity;
    for (int i = n; i > 0; i--) {
      if (dp[i][w] != dp[i - 1][w]) {
        keptFlags[i - 1] = true;
        w -= weights[i - 1];
      }
    }

    // Items to CUT (x_i = 1) are those that were NOT kept (keptFlags[i] == false)
    List<KnapsackItem> itemsToCut = [];
    double totalSavings = 0.0;
    int cutImportance = 0;

    for (int i = 0; i < n; i++) {
      if (!keptFlags[i]) {
        itemsToCut.add(items[i]);
        totalSavings += items[i].amount;
        cutImportance += items[i].importanceScore;
      }
    }

    // Calculate Impact Level: Ratio of cut importance to total importance
    String impactLevel = 'Thấp';
    if (totalImportance > 0) {
      double ratio = cutImportance / totalImportance;
      if (ratio >= 0.50) {
        impactLevel = 'Cao';
      } else if (ratio >= 0.20) {
        impactLevel = 'Trung bình';
      } else {
        impactLevel = 'Thấp';
      }
    }

    return KnapsackResult(
      itemsToCut: itemsToCut,
      totalSavings: totalSavings,
      impactLevel: impactLevel,
    );
  }
}
