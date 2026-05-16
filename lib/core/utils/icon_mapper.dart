import 'package:flutter/material.dart';

IconData mapCategoryIcon(String iconName) {
  switch (iconName) {
    case 'cpu':
      return Icons.memory_rounded;
    case 'shopping-bag':
      return Icons.shopping_bag_outlined;
    case 'watch':
      return Icons.watch_outlined;
    case 'activity':
      return Icons.sports_basketball_outlined;
    case 'home':
      return Icons.home_outlined;
    default:
      return Icons.category_outlined;
  }
}
