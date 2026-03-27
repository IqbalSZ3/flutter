# FinTrack — Personal Finance App

Android-only personal finance app built with Flutter. Tracks expenses/income, manages BNPL installments (ShopeePay, GoPay Later, TikTok Pay Later), subscriptions, savings goals, and provides daily/monthly analysis. Cloud-first with Firebase, IDR currency only.

## Tech Stack

- **Flutter 3.41.5** (stable), Dart SDK ^3.11.3, Android only (minSdk 23)
- **State management**: BLoC (`flutter_bloc ^9.1.1`)
- **Backend**: Firebase (Auth + Firestore) — project ID: `management-money-c5594`
- **Auth**: `google_sign_in ^7.2.0` (v7 singleton API) + `firebase_auth ^6.3.0`
- **Navigation**: `go_router ^17.1.0` with `StatefulShellRoute.indexedStack`
- **DI**: `get_it ^9.2.1` (user-scoped registration pattern)
- **Charts**: `fl_chart ^1.2.0`
- **Fonts**: `google_fonts ^8.0.2` (Plus Jakarta Sans headings, DM Sans body, Space Grotesk amounts)
- **Localization**: Custom map-based system in `core/locale/app_strings.dart` (EN/ID)

## Architecture

Feature-first Clean Architecture. Each feature has `data/`, `domain/`, `presentation/` layers.

```
lib/
├── app/              # App shell, routes, root widget
├── core/
│   ├── constants/    # Categories, Firestore paths
│   ├── enums/        # TransactionType, SavingsPeriod, InstallmentProvider, etc.
│   ├── errors/       # Failure classes
│   ├── locale/       # LocaleCubit + AppStrings translation map
│   ├── theme/        # AppColors, AppTypography, AppSpacing, AppTheme (Material 3 dark)
│   └── utils/        # CurrencyFormatter (IDR), DateUtils
├── di/               # GetIt injection container
├── features/
│   ├── auth/         # Google Sign-In → Firebase Auth
│   ├── transactions/ # Expense + Income CRUD with categories
│   ├── analysis/     # Daily + Monthly charts (pie, line)
│   ├── installments/ # BNPL management with flat interest calculation
│   ├── subscriptions/# Subscription tracking with renewal dates
│   ├── savings/      # Savings goals with flexible periods
│   ├── bills/        # Combined installments + subscriptions tab
│   ├── home/         # Dashboard screen
│   └── settings/     # Language, categories, sign out
└── main.dart
```

## Key Patterns & Conventions

- **Firestore paths**: All user data under `users/{uid}/` — see `core/constants/firestore_paths.dart`
- **User-scoped DI**: `registerUserDependencies(uid)` in `di/injection_container.dart` — unregisters old deps, registers new ones on auth change
- **google_sign_in v7**: Uses `GoogleSignIn.instance` singleton. Must call `initialize(serverClientId:)` before `authenticate()`. Only `idToken` available (no `accessToken` for auth). Configured in `main.dart`.
- **Translation**: `context.tr('key')` extension from `core/locale/app_strings.dart`. Uses `context.read<LocaleCubit>()`. Rebuilds via `BlocBuilder<LocaleCubit, Locale>` wrapping `MaterialApp.router` in `app.dart`.
- **Currency**: Always `int` (IDR, no decimals). Format with `CurrencyFormatter.format()`.
- **Installment calculation**: Flat interest method (Indonesian BNPL standard) — see `InstallmentModel.calculate()` factory.
- **Theme**: Material 3 dark mode, emerald green (#00C9A7) primary, deep purple (#7C5CFC) secondary.
- **`withOpacity` deprecated**: Use `withValues(alpha: 0.1)` instead of `withOpacity(0.1)`.
- **Wildcard params**: Use `(_, _, _)` not `(_, __, ___)` — linter warns `unnecessary_underscores`.
- **Firestore Timestamps**: Convert `DateTime` ↔ `Timestamp` in model `toMap()`/`fromMap()`.

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Status**: User was told to publish these rules but may not have done so. If Firestore reads/writes fail silently, check rules first.

## Features Status

### Completed
- [x] Firebase Auth with Google Sign-In (v7 API)
- [x] Transaction CRUD (expense/income) with pre-defined + custom categories
- [x] Daily analysis with pie chart (expense breakdown)
- [x] Monthly analysis with line chart (spending trend) + pie charts
- [x] Installment management with flat interest auto-calculation
- [x] Installment detail screen with payment schedule + mark as paid
- [x] Subscription management with renewal tracking
- [x] Bills screen (combined installments + subscriptions tabs)
- [x] Dashboard with balance card, quick stats, upcoming payments, recent transactions
- [x] Settings screen (language, categories view, savings placeholder, sign out with confirmation)
- [x] Dark theme with Material 3
- [x] LocaleCubit for locale state + `flutter_localizations` configured in MaterialApp

### Work in Progress
- [ ] **Localization (EN/ID)**: Translation system created (`AppStrings` + `context.tr()`), ~140 string keys defined. **Batch 1 done** (app_shell, login, dashboard, analysis, bills screens translated). **Remaining**: transaction screens, installment screens, subscription screen, settings screen need `context.tr()` calls applied.

### Not Yet Built
- [ ] Savings goals screens (add/detail) — only BLoC + repository + model exist
- [ ] Category management screen (add/edit/delete custom categories)
- [ ] Notification scheduling (installment due dates, subscription renewals)
- [ ] Edit/delete transaction
- [ ] Edit/delete installment/subscription
- [ ] Data export
- [ ] Shimmer loading states

## Known Issues

1. **Firestore security rules may not be published** — if streams error silently, installments/subscriptions show loading forever. Installment stream has `onError` fallback added, but root cause is missing rules.
2. **Login screen overflow** — `_FeatureRow` Row can overflow by ~1.6px on narrow screens. Needs `Flexible`/`Expanded` wrapping.
3. **Analysis monthly data stale on first view** — Fixed by re-dispatching `AnalysisMonthChanged` on tab switch (`_onTabChanged` in analysis_screen.dart). If still stale, may need stream-based approach instead of one-shot fetch.
4. **`build.gradle.kts` minSdk reverts** — A linter/tool keeps reverting `minSdk = 23` back to `flutter.minSdkVersion`. If build fails with desugaring error, check `android/app/build.gradle.kts` and set `minSdk = 23` + `isCoreLibraryDesugaringEnabled = true`.
5. **Kotlin incremental cache corruption** — If build fails with `Daemon compilation failed: null` / `Storage already registered`, run `flutter clean` then rebuild.

## Build & Run

```bash
# Run on connected Android device
flutter run -d <device_id>

# Clean build (fixes most build errors)
flutter clean && flutter pub get && flutter run -d <device_id>

# List devices
flutter devices

# Check for analysis issues
flutter analyze
```

## Firebase Setup

- Project: `management-money-c5594`
- `google-services.json` in `android/app/`
- Web client ID (for serverClientId): `478855430524-lkaaaiiolnkoik4r9sujjquh9gutson1.apps.googleusercontent.com`
- SHA-1 fingerprint added to Firebase Console for Google Sign-In
- Firestore in production mode (requires security rules to be published)

## Android Build Config

- `android/app/build.gradle.kts` requires:
  - `minSdk = 23` (not `flutter.minSdkVersion`)
  - `isCoreLibraryDesugaringEnabled = true` in `compileOptions`
  - `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` in `dependencies`
  - `id("com.google.gms.google-services")` plugin
