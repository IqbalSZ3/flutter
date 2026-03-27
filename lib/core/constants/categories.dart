import 'package:flutter/material.dart';

class DefaultCategory {
  final String id;
  final String nameEn;
  final String nameId;
  final IconData icon;
  final bool isExpense;

  const DefaultCategory({
    required this.id,
    required this.nameEn,
    required this.nameId,
    required this.icon,
    required this.isExpense,
  });
}

class DefaultCategories {
  DefaultCategories._();

  static const List<DefaultCategory> expenses = [
    DefaultCategory(
      id: 'food',
      nameEn: 'Food & Drinks',
      nameId: 'Makan & Minum',
      icon: Icons.restaurant_rounded,
      isExpense: true,
    ),
    DefaultCategory(
      id: 'transport',
      nameEn: 'Transportation',
      nameId: 'Transport',
      icon: Icons.directions_car_rounded,
      isExpense: true,
    ),
    DefaultCategory(
      id: 'shopping',
      nameEn: 'Shopping',
      nameId: 'Belanja',
      icon: Icons.shopping_bag_rounded,
      isExpense: true,
    ),
    DefaultCategory(
      id: 'bills',
      nameEn: 'Bills & Utilities',
      nameId: 'Tagihan',
      icon: Icons.receipt_long_rounded,
      isExpense: true,
    ),
    DefaultCategory(
      id: 'entertainment',
      nameEn: 'Entertainment',
      nameId: 'Hiburan',
      icon: Icons.movie_rounded,
      isExpense: true,
    ),
    DefaultCategory(
      id: 'health',
      nameEn: 'Health',
      nameId: 'Kesehatan',
      icon: Icons.local_hospital_rounded,
      isExpense: true,
    ),
    DefaultCategory(
      id: 'education',
      nameEn: 'Education',
      nameId: 'Pendidikan',
      icon: Icons.school_rounded,
      isExpense: true,
    ),
    DefaultCategory(
      id: 'other_expense',
      nameEn: 'Others',
      nameId: 'Lainnya',
      icon: Icons.more_horiz_rounded,
      isExpense: true,
    ),
  ];

  static const List<DefaultCategory> income = [
    DefaultCategory(
      id: 'salary',
      nameEn: 'Salary',
      nameId: 'Gaji',
      icon: Icons.account_balance_wallet_rounded,
      isExpense: false,
    ),
    DefaultCategory(
      id: 'freelance',
      nameEn: 'Freelance',
      nameId: 'Freelance',
      icon: Icons.laptop_rounded,
      isExpense: false,
    ),
    DefaultCategory(
      id: 'investment',
      nameEn: 'Investment',
      nameId: 'Investasi',
      icon: Icons.trending_up_rounded,
      isExpense: false,
    ),
    DefaultCategory(
      id: 'bonus',
      nameEn: 'Bonus',
      nameId: 'Bonus',
      icon: Icons.card_giftcard_rounded,
      isExpense: false,
    ),
    DefaultCategory(
      id: 'other_income',
      nameEn: 'Others',
      nameId: 'Lainnya',
      icon: Icons.more_horiz_rounded,
      isExpense: false,
    ),
  ];

  static List<DefaultCategory> get all => [...expenses, ...income];
}
