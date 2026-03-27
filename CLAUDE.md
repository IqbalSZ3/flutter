# FinTrack — Personal Finance App

Android-only personal finance tracker built with Flutter. Focuses on the Indonesian market: IDR currency only, supports BNPL installment tracking (ShopeePay, GoPay Later, TikTok Pay Later), subscription management, savings goals, and daily/monthly spending analysis. Cloud-first with Firebase.

---

## Tech Stack

| Layer | Library | Version |
|-------|---------|---------|
| Framework | Flutter (Android only) | 3.41.5 stable |
| Language | Dart SDK | ^3.11.3 |
| State management | `flutter_bloc` | ^9.1.1 |
| Backend | Firebase (Auth + Firestore) | project: `management-money-c5594` |
| Auth | `google_sign_in` + `firebase_auth` | ^7.2.0 / ^6.3.0 |
| Navigation | `go_router` | ^17.1.0 |
| DI | `get_it` | ^9.2.1 |
| Charts | `fl_chart` | ^1.2.0 |
| Image caching | `cached_network_image` | ^3.4.1 |
| Fonts | `google_fonts` | ^8.0.2 |
| Localization | Custom map-based (EN/ID) | — |

Other dependencies in `pubspec.yaml`: `bloc`, `connectivity_plus`, `equatable`, `firebase_core`, `flutter_local_notifications`, `freezed_annotation`, `intl`, `json_annotation`, `shimmer`.

---

## Architecture

**Feature-first Clean Architecture.** Each feature follows `data/ → domain/ → presentation/` layering.

```
lib/
├── app/
│   ├── app.dart              # Root widget, auth-gated BlocProvider tree
│   ├── app_shell.dart        # Bottom nav shell (StatefulShellRoute)
│   └── routes.dart           # GoRouter config (all named routes)
├── core/
│   ├── constants/            # AppCategories (pre-defined), FirestorePaths
│   ├── enums/                # TransactionType, InstallmentProvider, SavingsPeriod, etc.
│   ├── errors/
│   │   ├── failures.dart     # Failure base classes (ServerFailure, AuthFailure, etc.)
│   │   └── error_mapper.dart # Maps raw exceptions → user-friendly strings
│   ├── locale/               # LocaleCubit, AppStrings (translation map), context.tr()
│   ├── theme/                # AppColors, AppTypography, AppSpacing, AppTheme
│   └── utils/                # CurrencyFormatter (IDR), DateUtils
├── di/
│   └── injection_container.dart  # GetIt setup — global + user-scoped deps
├── features/
│   ├── auth/                 # Google Sign-In flow
│   ├── transactions/         # Expense/Income CRUD + categories
│   ├── analysis/             # Daily (pie) + Monthly (line + pie) charts
│   ├── installments/         # BNPL tracker with flat-interest calculator
│   ├── subscriptions/        # Subscription tracker with renewal dates
│   ├── savings/              # Savings goals (BLoC + repo only, no screens yet)
│   ├── bills/                # Combined installments + subscriptions tab
│   ├── home/                 # Dashboard screen
│   └── settings/             # Language toggle, categories, sign out
└── main.dart                 # Firebase init, GoogleSignIn.instance.initialize()
```

---

## Key Patterns & Conventions

### State Management (BLoC)
- One BLoC per feature. Events are `sealed`-style abstract classes with `Equatable`.
- Firestore streams are subscribed in `_onStarted` handler and cancelled in `close()`.
- Internal events (e.g. `_TransactionDataReceived`) are private with `_` prefix.
- **Never** call `add()` from inside a BLoC handler without checking if `isClosed`.

### Dependency Injection (GetIt)
- `initDependencies()` — called once at startup for Firebase + auth singletons.
- `registerUserDependencies(uid)` — called on every successful auth; unregisters old user deps first.
- `_tryUnregister<T>()` — safe unregistration helper (checks `isRegistered` first).
- **All user-scoped repos/BLoCs** (Transactions, Installments, Subscriptions, Savings, Analysis, Category) are registered here with the user's `uid`.

### Firestore
- All user data lives under `users/{uid}/` — see `FirestorePaths` constants.
- Models implement `fromFirestore(DocumentSnapshot)` + `toFirestore()` (returns `Map<String, dynamic>`).
- `DateTime` ↔ `Timestamp` conversion is done inside model methods, not in BLoC/repo.
- `watchTransactions()` applies `.limit(100)` — latest 100 transactions only (pagination).
- `watchInstallments()` applies `.orderBy('isCompleted')` server-side, then secondary sort by `nextDueDate` client-side (nulls handled as `DateTime(2099)`).

### Error Handling
- `ErrorMapper.toUserMessage(e)` in `core/errors/error_mapper.dart` — always use this before emitting error states to avoid leaking stack traces to users.
- Matches Firebase error codes: `permission-denied`, `unavailable`, `network-request-failed`, `unauthenticated`, etc.
- All BLoCs already use `ErrorMapper`. Do not use `e.toString()` directly in `emit(XxxError(...))`.

### Navigation (GoRouter)
- Routes are static constants in `AppRoutes`.
- Object passing uses `state.extra` with `is` type check (not force cast): `if (extra is! MyModel) return errorScaffold`.
- Auth redirect is handled in `GoRouter.redirect` callback — no need for manual pushes on auth change.

### UI Conventions
- **Currency**: `int` (IDR, no decimals). Display with `CurrencyFormatter.format()` or `formatCompact()`.
- **`withOpacity` is deprecated**: Use `color.withValues(alpha: 0.x)` instead.
- **Wildcard params**: Use `(_, _, _)` not `(_, __, ___)` (linter: `unnecessary_underscores`).
- **Computationally expensive StatelessWidgets** (sort, fold, map on large data): Convert to `StatefulWidget` and cache in `didUpdateWidget` — see `_ExpensePieChart` and `_SpendingTrendChart` in `analysis_screen.dart` as reference.
- **Network images**: Always use `CachedNetworkImageProvider` (not plain `NetworkImage`) for any user-uploaded photos.
- **No `print()`**: Use proper error handling/`ErrorMapper`. All print() removed from production code.

### Localization
- `context.tr('key')` extension — reads from `LocaleCubit` via `context.read`.
- ~140 string keys defined in `AppStrings` (EN + ID maps).
- Locale state: `LocaleCubit` wraps a `Locale` value; rebuilt via `BlocBuilder<LocaleCubit, Locale>` in `app.dart`.

### Installment Calculation
- **Flat interest method** (Indonesian BNPL standard) — see `InstallmentModel.calculate()`.
- Formula: `monthlyInterest = totalAmount * annualRate / 100 / 12`, `monthlyPayment = ceil(principal/tenure) + monthlyInterest`.
- Zero interest supported (just splits principal evenly).

---

## Firebase Setup

- **Project ID**: `management-money-c5594`
- **`google-services.json`**: in `android/app/` (do not commit to public repos)
- **Web client ID** (for `serverClientId` in `main.dart`): `478855430524-lkaaaiiolnkoik4r9sujjquh9gutson1.apps.googleusercontent.com`
- **SHA-1**: Added to Firebase Console (required for Google Sign-In)
- **Firestore mode**: Production (security rules must be published — see below)

### Firestore Security Rules
Publish these in Firebase Console → Firestore → Rules:
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
> ⚠️ **If rules are not published**, all Firestore reads/writes silently fail. Streams show "loading" forever. This is the #1 thing to check if data doesn't appear.

---

## Android Build Config

File: `android/app/build.gradle.kts`

Critical settings that must be present:
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true  // required for java.time APIs
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

> ⚠️ `minSdk` is currently set to `flutter.minSdkVersion` (which may resolve below 23). If build fails with a desugaring error, manually set `minSdk = 23` in `defaultConfig`.

> ⚠️ `release { signingConfig = signingConfigs.getByName("debug") }` — **must be replaced with a real keystore before Play Store submission.**

---

## Features Status

### ✅ Completed
- Firebase Auth with Google Sign-In (v7 API — `GoogleSignIn.instance.authenticate()`)
- Transaction CRUD (expense/income) with pre-defined + custom categories
- Daily analysis — pie chart (expense breakdown by category)
- Monthly analysis — line chart (spending trend) + pie charts (income + expense breakdown)
- Installment management — flat interest auto-calculation, payment schedule, mark as paid
- Installment detail screen with full payment schedule
- Subscription management — renewal date tracking
- Bills screen — combined installments + subscriptions in tabs
- Dashboard — balance card, quick stats, upcoming payments, recent transactions (last 5)
- Settings screen — language toggle (EN/ID), categories list, sign out with confirmation dialog
- Dark theme (Material 3) — emerald green primary (#00C9A7), deep purple secondary (#7C5CFC)
- Localization infrastructure — `LocaleCubit`, `AppStrings`, `context.tr()` extension

### 🔄 Work in Progress

#### Localization (EN/ID)
~140 string keys defined in `AppStrings`. Status by screen:
- ✅ `app_shell`, `login_screen`, `dashboard_screen`, `analysis_screen`, `bills_screen` — translated
- ❌ `transaction screens` (list, add), `installment screens` (add, detail), `add_subscription_screen`, `settings_screen` — hardcoded strings still need replacing with `context.tr()`

### ❌ Not Yet Built (Next Steps)
- **Savings goals screens** — `SavingsBloc` + `SavingsRepository` + `SavingsGoalModel` exist, but no UI (add/detail screens). Wire up in `settings_screen.dart` or create standalone tab.
- **Edit/delete transaction** — only Add exists. Need edit screen + swipe-to-delete in `TransactionListScreen`.
- **Edit/delete installment / subscription** — only Add and Detail exist.
- **Category management screen** — add/edit/delete custom categories. `CategoryBloc` exists. Settings screen has a placeholder tap handler.
- **Notification scheduling** — `flutter_local_notifications` is in pubspec but unused. Need to schedule: installment due dates, subscription renewals.
- **Data export** — CSV/PDF export of transactions.
- **Shimmer loading states** — `shimmer` package is in pubspec but unused. Replace `CircularProgressIndicator` screens with shimmer skeletons.
- **Offline support** — currently requires internet. No local cache (Hive/SQLite). Firestore offline persistence could be enabled as a quick win.
- **Firebase Crashlytics** — no crash reporting. Add before production.

---

## Performance Optimizations Done

These were applied to prepare the app for production (branch `claude/analyze-android-performance-UDpsE`):

1. **Pagination** (`transaction_repository_impl.dart`) — `watchTransactions` now applies `.limit(100)`. Prevents loading unbounded records. `limit` param is configurable (default 100).
2. **Google icon offline** (`login_screen.dart`) — Replaced `Image.network(gstatic.com/...)` with local `_GoogleIcon` widget (white circle + blue "G"). No network call on auth screen.
3. **CachedNetworkImageProvider** (`dashboard_screen.dart`, `settings_screen.dart`) — Profile photo uses cache; no re-download on every rebuild.
4. **Chart computation cache** (`analysis_screen.dart`) — `_ExpensePieChart` and `_SpendingTrendChart` converted to `StatefulWidget`. Sort/fold/reduce computed once in `initState` + `didUpdateWidget`, not on every `build()`.
5. **Server-side ordering** (`installment_repository_impl.dart`) — Added `.orderBy('isCompleted')` to Firestore query; Firestore pre-sorts active installments before completed ones.
6. **No print() in release** — Removed all `print()` statements from blocs and repositories.
7. **ErrorMapper** (`core/errors/error_mapper.dart`) — All BLoC error handlers now use `ErrorMapper.toUserMessage(e)` instead of `e.toString()`.
8. **Safe router cast** (`routes.dart`) — `installmentDetail` route uses `is!` type guard instead of force `as` cast.

---

## Known Issues & Gotchas

| # | Issue | Location | Workaround |
|---|-------|----------|------------|
| 1 | **Firestore rules not published** | Firebase Console | Publish rules (see above). Without this, all streams silently fail. |
| 2 | **Release APK uses debug signing** | `build.gradle.kts:39` | Must create a release keystore before Play Store submission. |
| 3 | **`minSdk` keeps reverting** | `build.gradle.kts:29` | A linter reverts `minSdk = 23` to `flutter.minSdkVersion`. If build fails, manually set `minSdk = 23`. |
| 4 | **Login screen overflow** | `login_screen.dart` | `_FeatureRow` Row can overflow ~1.6px on narrow screens. Wrap text with `Flexible`. |
| 5 | **Analysis monthly data stale on first view** | `analysis_screen.dart` | Mitigated by re-dispatching `AnalysisMonthChanged` on tab switch. May need stream-based approach if issue recurs. |
| 6 | **Kotlin incremental cache corruption** | Android build | Run `flutter clean && flutter pub get` if build fails with `Daemon compilation failed: null` / `Storage already registered`. |
| 7 | **`isCompleted` orderBy Firestore index** | `installment_repository_impl.dart` | Firestore auto-creates single-field indexes; if stream errors on first run, check Logcat for index creation link. |
| 8 | **No offline support** | All features | App shows empty/loading on no network. Quick fix: enable Firestore offline persistence in `main.dart` via `FirebaseFirestore.instance.settings`. |
| 9 | **Auth try/catch in `auth_repository_impl.dart`** | `auth_repository_impl.dart` | The `catch(e) { rethrow; }` block is a no-op. Can be simplified by removing the try/catch entirely. Minor cleanup. |

---

## Build & Run

```bash
# Run on connected Android device
flutter run -d <device_id>

# List available devices
flutter devices

# Clean build (fixes most build/cache errors)
flutter clean && flutter pub get && flutter run -d <device_id>

# Check for Dart analysis issues before committing
flutter analyze

# Run in release mode (uses debug signing — see Known Issues)
flutter run --release -d <device_id>
```

---

## Git Branch

Active development branch: `claude/analyze-android-performance-UDpsE`

Commit `3ec0e84` — performance optimizations (8 fixes applied, see section above).
