import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'locale_cubit.dart';

/// Simple map-based translation system for EN/ID
class AppStrings {
  AppStrings._();

  static String get(String key, String lang) {
    return _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
  }

  static const Map<String, Map<String, String>> _strings = {
    // ── App Shell / Navigation ──
    'nav_home': {'en': 'Home', 'id': 'Beranda'},
    'nav_analysis': {'en': 'Analysis', 'id': 'Analisis'},
    'nav_bills': {'en': 'Bills', 'id': 'Tagihan'},
    'nav_settings': {'en': 'Settings', 'id': 'Pengaturan'},

    // ── Login Screen ──
    'app_name': {'en': 'FinTrack', 'id': 'FinTrack'},
    'login_tagline': {'en': 'Take control of your finances', 'id': 'Kendalikan keuangan Anda'},
    'login_feature_1': {'en': 'Track expenses & income', 'id': 'Lacak pengeluaran & pemasukan'},
    'login_feature_2': {'en': 'Manage installments & subscriptions', 'id': 'Kelola cicilan & langganan'},
    'login_feature_3': {'en': 'Set savings goals & analyze spending', 'id': 'Atur target tabungan & analisis pengeluaran'},
    'login_continue_google': {'en': 'Continue with Google', 'id': 'Lanjutkan dengan Google'},

    // ── Dashboard Screen ──
    'greeting_morning': {'en': 'Good morning', 'id': 'Selamat pagi'},
    'greeting_afternoon': {'en': 'Good afternoon', 'id': 'Selamat siang'},
    'greeting_evening': {'en': 'Good evening', 'id': 'Selamat malam'},
    'total_balance': {'en': 'Total Balance', 'id': 'Total Saldo'},
    'income': {'en': 'Income', 'id': 'Pemasukan'},
    'expense': {'en': 'Expense', 'id': 'Pengeluaran'},
    'upcoming_payments': {'en': 'Upcoming Payments', 'id': 'Pembayaran Mendatang'},
    'no_upcoming_payments': {'en': 'No upcoming payments', 'id': 'Tidak ada pembayaran mendatang'},
    'recent_transactions': {'en': 'Recent Transactions', 'id': 'Transaksi Terbaru'},
    'no_transactions_yet': {'en': 'No transactions yet', 'id': 'Belum ada transaksi'},
    'see_all': {'en': 'See all', 'id': 'Lihat semua'},
    'savings': {'en': 'Savings', 'id': 'Tabungan'},
    'bills_due': {'en': 'Bills Due', 'id': 'Tagihan Jatuh Tempo'},
    'subs': {'en': 'Subs', 'id': 'Langganan'},

    // ── Transaction List Screen ──
    'all_transactions': {'en': 'All Transactions', 'id': 'Semua Transaksi'},
    'tap_to_add_first': {'en': 'Tap + to add your first transaction', 'id': 'Ketuk + untuk menambah transaksi pertama'},
    'filter_all': {'en': 'All', 'id': 'Semua'},
    'filter_expense': {'en': 'Expense', 'id': 'Pengeluaran'},
    'filter_income': {'en': 'Income', 'id': 'Pemasukan'},

    // ── Add Transaction Screen ──
    'add_transaction': {'en': 'Add Transaction', 'id': 'Tambah Transaksi'},
    'how_much_spend': {'en': 'How much did you spend?', 'id': 'Berapa yang kamu keluarkan?'},
    'how_much_earn': {'en': 'How much did you earn?', 'id': 'Berapa yang kamu dapatkan?'},
    'category': {'en': 'Category', 'id': 'Kategori'},
    'date': {'en': 'Date', 'id': 'Tanggal'},
    'notes_optional': {'en': 'Notes (optional)', 'id': 'Catatan (opsional)'},
    'add_a_note': {'en': 'Add a note...', 'id': 'Tambah catatan...'},
    'save_transaction': {'en': 'Save Transaction', 'id': 'Simpan Transaksi'},
    'error_enter_amount': {'en': 'Please enter an amount', 'id': 'Silakan masukkan jumlah'},
    'error_valid_amount': {'en': 'Please enter a valid amount', 'id': 'Silakan masukkan jumlah yang valid'},
    'error_select_category': {'en': 'Please select a category', 'id': 'Silakan pilih kategori'},
    'today': {'en': 'Today', 'id': 'Hari ini'},
    'yesterday': {'en': 'Yesterday', 'id': 'Kemarin'},

    // ── Analysis Screen ──
    'analysis': {'en': 'Analysis', 'id': 'Analisis'},
    'daily': {'en': 'Daily', 'id': 'Harian'},
    'monthly': {'en': 'Monthly', 'id': 'Bulanan'},
    'expense_breakdown': {'en': 'Expense Breakdown', 'id': 'Rincian Pengeluaran'},
    'income_breakdown': {'en': 'Income Breakdown', 'id': 'Rincian Pemasukan'},
    'no_expenses_today': {'en': 'No expenses today', 'id': 'Tidak ada pengeluaran hari ini'},
    'spending_trend': {'en': 'Spending Trend', 'id': 'Tren Pengeluaran'},
    'no_transactions_this_month': {'en': 'No transactions this month', 'id': 'Tidak ada transaksi bulan ini'},
    'month_jan': {'en': 'Jan', 'id': 'Jan'},
    'month_feb': {'en': 'Feb', 'id': 'Feb'},
    'month_mar': {'en': 'Mar', 'id': 'Mar'},
    'month_apr': {'en': 'Apr', 'id': 'Apr'},
    'month_may': {'en': 'May', 'id': 'Mei'},
    'month_jun': {'en': 'Jun', 'id': 'Jun'},
    'month_jul': {'en': 'Jul', 'id': 'Jul'},
    'month_aug': {'en': 'Aug', 'id': 'Agu'},
    'month_sep': {'en': 'Sep', 'id': 'Sep'},
    'month_oct': {'en': 'Oct', 'id': 'Okt'},
    'month_nov': {'en': 'Nov', 'id': 'Nov'},
    'month_dec': {'en': 'Dec', 'id': 'Des'},

    // ── Bills Screen ──
    'bills': {'en': 'Bills', 'id': 'Tagihan'},
    'installments': {'en': 'Installments', 'id': 'Cicilan'},
    'subscriptions': {'en': 'Subscriptions', 'id': 'Langganan'},
    'monthly_total': {'en': 'Monthly Total', 'id': 'Total Bulanan'},
    'monthly_cost': {'en': 'Monthly Cost', 'id': 'Biaya Bulanan'},
    'no_installments': {'en': 'No installments', 'id': 'Belum ada cicilan'},
    'no_subscriptions': {'en': 'No subscriptions', 'id': 'Belum ada langganan'},
    'add_installment': {'en': 'Add Installment', 'id': 'Tambah Cicilan'},
    'add_subscription': {'en': 'Add Subscription', 'id': 'Tambah Langganan'},
    'per_month': {'en': '/month', 'id': '/bulan'},
    'payments': {'en': 'payments', 'id': 'pembayaran'},
    'due_today': {'en': 'Due today', 'id': 'Jatuh tempo hari ini'},
    'renews_in_days': {'en': 'Renews in {days} days', 'id': 'Perpanjang dalam {days} hari'},

    // ── Add Installment Screen ──
    'provider': {'en': 'Provider', 'id': 'Penyedia'},
    'item_name': {'en': 'Item Name', 'id': 'Nama Barang'},
    'item_name_hint': {'en': 'e.g. iPhone 15', 'id': 'contoh: iPhone 15'},
    'total_amount_idr': {'en': 'Total Amount (IDR)', 'id': 'Total Harga (IDR)'},
    'tenure_months': {'en': 'Tenure (months)', 'id': 'Tenor (bulan)'},
    'interest_per_year': {'en': 'Interest (% / year)', 'id': 'Bunga (% / tahun)'},
    'due_day_of_month': {'en': 'Due Day of Month (1-28)', 'id': 'Tanggal Jatuh Tempo (1-28)'},
    'payment_preview': {'en': 'Payment Preview', 'id': 'Preview Pembayaran'},
    'monthly_payment': {'en': 'Monthly Payment', 'id': 'Cicilan per Bulan'},
    'total_interest': {'en': 'Total Interest', 'id': 'Total Bunga'},
    'total_payable': {'en': 'Total Payable', 'id': 'Total Bayar'},
    'duration': {'en': 'Duration', 'id': 'Durasi'},
    'save_installment': {'en': 'Save Installment', 'id': 'Simpan Cicilan'},
    'error_enter_name': {'en': 'Please enter a name', 'id': 'Silakan masukkan nama'},
    'error_fill_amount_tenure': {'en': 'Please fill in amount and tenure', 'id': 'Silakan isi jumlah dan tenor'},
    'months': {'en': 'months', 'id': 'bulan'},

    // ── Installment Detail Screen ──
    'remaining_balance': {'en': 'Remaining Balance', 'id': 'Sisa Tagihan'},
    'total_amount': {'en': 'Total Amount', 'id': 'Total Harga'},
    'interest_rate': {'en': 'Interest Rate', 'id': 'Suku Bunga'},
    'per_year': {'en': '% / year', 'id': '% / tahun'},
    'due_day': {'en': 'Due Day', 'id': 'Tanggal Jatuh Tempo'},
    'every_day': {'en': 'Every {day}th', 'id': 'Setiap tanggal {day}'},
    'mark_payment_paid': {'en': 'Mark Payment #{number} as Paid', 'id': 'Tandai Pembayaran #{number} Lunas'},
    'payment_schedule': {'en': 'Payment Schedule', 'id': 'Jadwal Pembayaran'},
    'payment_number': {'en': 'Payment #{number}', 'id': 'Pembayaran #{number}'},

    // ── Add Subscription Screen ──
    'service_name': {'en': 'Service Name', 'id': 'Nama Layanan'},
    'service_name_hint': {'en': 'e.g. YouTube Premium, Netflix', 'id': 'contoh: YouTube Premium, Netflix'},
    'amount_idr': {'en': 'Amount (IDR)', 'id': 'Jumlah (IDR)'},
    'billing_cycle': {'en': 'Billing Cycle', 'id': 'Siklus Tagihan'},
    'yearly': {'en': 'Yearly', 'id': 'Tahunan'},
    'next_renewal_date': {'en': 'Next Renewal Date', 'id': 'Tanggal Perpanjangan'},
    'remind_me_days': {'en': 'Remind me (days before)', 'id': 'Ingatkan saya (hari sebelumnya)'},
    'save_subscription': {'en': 'Save Subscription', 'id': 'Simpan Langganan'},
    'error_enter_valid_amount': {'en': 'Please enter a valid amount', 'id': 'Silakan masukkan jumlah yang valid'},

    // ── Settings Screen ──
    'settings': {'en': 'Settings', 'id': 'Pengaturan'},
    'general': {'en': 'General', 'id': 'Umum'},
    'language': {'en': 'Language', 'id': 'Bahasa'},
    'categories': {'en': 'Categories', 'id': 'Kategori'},
    'manage_categories': {'en': 'Manage expense & income categories', 'id': 'Kelola kategori pengeluaran & pemasukan'},
    'savings_goals': {'en': 'Savings Goals', 'id': 'Target Tabungan'},
    'savings_goals_subtitle': {'en': 'Set and track your savings targets', 'id': 'Atur dan lacak target tabungan Anda'},
    'account': {'en': 'Account', 'id': 'Akun'},
    'sign_out': {'en': 'Sign Out', 'id': 'Keluar'},
    'sign_out_subtitle': {'en': 'Sign out of your account', 'id': 'Keluar dari akun Anda'},
    'sign_out_confirm': {'en': 'Are you sure you want to sign out?', 'id': 'Apakah Anda yakin ingin keluar?'},
    'cancel': {'en': 'Cancel', 'id': 'Batal'},
    'save': {'en': 'Save', 'id': 'Simpan'},
    'language_set_en': {'en': 'Language set to English', 'id': 'Bahasa diubah ke English'},
    'language_set_id': {'en': 'Language changed to Indonesian', 'id': 'Bahasa diubah ke Indonesia'},
    'expense_categories': {'en': 'Expense Categories', 'id': 'Kategori Pengeluaran'},
    'income_categories': {'en': 'Income Categories', 'id': 'Kategori Pemasukan'},
    'custom_categories_soon': {'en': 'Custom categories coming soon', 'id': 'Kategori kustom segera hadir'},
    'savings_goals_title': {'en': 'Savings Goals', 'id': 'Target Tabungan'},
    'savings_goals_description': {
      'en': 'Track your savings progress toward your goals.\nThis feature is coming soon!',
      'id': 'Lacak progres tabungan menuju target Anda.\nFitur ini segera hadir!',
    },
    'user': {'en': 'User', 'id': 'Pengguna'},

    // ── Category names ──
    'cat_food': {'en': 'Food & Drinks', 'id': 'Makan & Minum'},
    'cat_transport': {'en': 'Transport', 'id': 'Transport'},
    'cat_shopping': {'en': 'Shopping', 'id': 'Belanja'},
    'cat_bills': {'en': 'Bills', 'id': 'Tagihan'},
    'cat_entertainment': {'en': 'Entertainment', 'id': 'Hiburan'},
    'cat_health': {'en': 'Health', 'id': 'Kesehatan'},
    'cat_education': {'en': 'Education', 'id': 'Pendidikan'},
    'cat_others': {'en': 'Others', 'id': 'Lainnya'},
    'cat_salary': {'en': 'Salary', 'id': 'Gaji'},
    'cat_freelance': {'en': 'Freelance', 'id': 'Freelance'},
    'cat_investment': {'en': 'Investment', 'id': 'Investasi'},
    'cat_bonus': {'en': 'Bonus', 'id': 'Bonus'},

    // ── Shared ──
    'loading': {'en': 'Loading...', 'id': 'Memuat...'},
    'delete': {'en': 'Delete', 'id': 'Hapus'},
    'confirm': {'en': 'Confirm', 'id': 'Konfirmasi'},
    'active': {'en': 'active', 'id': 'aktif'},
    'completed': {'en': 'Completed', 'id': 'Selesai'},
    'remaining': {'en': 'Remaining', 'id': 'Sisa'},
    'of': {'en': 'of', 'id': 'dari'},
    'suggested': {'en': 'Suggested', 'id': 'Disarankan'},
    'days': {'en': 'days', 'id': 'hari'},

    // ── Savings Goals Screens ──
    'no_savings_goals': {'en': 'No savings goals yet', 'id': 'Belum ada target tabungan'},
    'no_savings_goals_subtitle': {'en': 'Tap the button below to create\nyour first savings goal', 'id': 'Ketuk tombol di bawah untuk membuat\ntarget tabungan pertama Anda'},
    'add_savings_goal': {'en': 'Add Goal', 'id': 'Tambah Target'},
    'savings_overview': {'en': 'Savings Overview', 'id': 'Ringkasan Tabungan'},
    'total_saved': {'en': 'Saved', 'id': 'Tersimpan'},
    'total_target': {'en': 'Target', 'id': 'Target'},
    'goals_count': {'en': 'Goals', 'id': 'Target'},
    'of_target': {'en': 'of target', 'id': 'dari target'},
    'active_goals': {'en': 'Active Goals', 'id': 'Target Aktif'},
    'completed_goals': {'en': 'Completed', 'id': 'Selesai'},
    'period_weekly': {'en': 'Weekly', 'id': 'Mingguan'},
    'period_monthly': {'en': 'Monthly', 'id': 'Bulanan'},
    'period_yearly': {'en': 'Yearly', 'id': 'Tahunan'},
    'period_custom': {'en': 'Custom', 'id': 'Kustom'},
    // Add savings goal screen
    'goal_name': {'en': 'Goal Name', 'id': 'Nama Target'},
    'goal_name_hint': {'en': 'e.g. New Laptop, Emergency Fund', 'id': 'contoh: Laptop Baru, Dana Darurat'},
    'target_amount_idr': {'en': 'Target Amount (IDR)', 'id': 'Jumlah Target (IDR)'},
    'saving_period': {'en': 'Saving Period', 'id': 'Periode Menabung'},
    'target_date': {'en': 'Target Date', 'id': 'Tanggal Target'},
    'suggested_saving': {'en': 'Suggested saving per period', 'id': 'Saran tabungan per periode'},
    'save_savings_goal': {'en': 'Create Goal', 'id': 'Buat Target'},
    // Savings goal detail screen
    'amount_saved': {'en': 'Amount Saved', 'id': 'Jumlah Tersimpan'},
    'days_left': {'en': 'Days Left', 'id': 'Sisa Hari'},
    'deadline_passed': {'en': 'Deadline passed', 'id': 'Deadline terlewati'},
    'save_per_period': {'en': 'Save Per Period', 'id': 'Tabungan Per Periode'},
    'add_savings': {'en': 'Add Money', 'id': 'Tambah Tabungan'},
    'goal_completed_congrats': {'en': 'Goal achieved! Congratulations! 🎉', 'id': 'Target tercapai! Selamat! 🎉'},
    'confirm_top_up': {'en': 'Confirm', 'id': 'Konfirmasi'},
    'delete_goal': {'en': 'Delete Goal', 'id': 'Hapus Target'},
    'delete_goal_confirm': {'en': 'Are you sure you want to delete this savings goal?', 'id': 'Apakah Anda yakin ingin menghapus target tabungan ini?'},
  };

  /// Get month name by index (1-12)
  static String monthName(int month, String lang) {
    const keys = [
      'month_jan', 'month_feb', 'month_mar', 'month_apr',
      'month_may', 'month_jun', 'month_jul', 'month_aug',
      'month_sep', 'month_oct', 'month_nov', 'month_dec',
    ];
    return get(keys[month - 1], lang);
  }
}

/// Extension for easy access: context.tr('key')
extension AppStringsContext on BuildContext {
  String tr(String key) {
    final lang = read<LocaleCubit>().state.languageCode;
    return AppStrings.get(key, lang);
  }

  String get lang => read<LocaleCubit>().state.languageCode;
}
