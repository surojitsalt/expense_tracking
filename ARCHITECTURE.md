# Architecture

A Flutter expense-tracking app built with **Clean Architecture** (data / domain / presentation per feature), **BLoC** for state management, **GetIt** for dependency injection, and **sqflite** for local persistence.

---

## High-level structure

```
lib/
├── main.dart                  # bootstrap: init DI, run app
├── app.dart                   # MultiBlocProvider + MaterialApp + named routes
│
├── core/
│   ├── di/
│   │   └── injection_container.dart   # GetIt service locator wiring
│   ├── database/
│   │   └── database_helper.dart       # sqflite schema + generic CRUD
│   ├── theme/
│   │   ├── app_theme.dart             # Material3 ThemeData (Google Fonts: Inter)
│   │   └── expense_tracker_app_colors.dart  # ThemeExtension: income/expense/savings palette
│   └── widgets/                       # cross-feature reusable widgets
│       ├── amount_input_field.dart
│       ├── category_chip_selector.dart
│       └── record_card.dart
│
├── navigation/
│   └── app_drawer.dart                # drawer + pushReplacementNamed routing
│
└── features/
    ├── income/
    │   ├── domain/   { income_model, income_repository, income_usecase }
    │   ├── data/     { income_repository_impl }
    │   └── presentation/ { income_bloc, income_source (screen) }
    ├── expense/      # same shape as income
    ├── savings/      # same shape, plus withdrawal_{model,repository,usecase,impl}
    ├── reports/
    │   ├── bloc/         { report_bloc }            # aggregator over all features
    │   └── presentation/ { report, piechart }
    └── settings/
        ├── domain/        { currency_model }
        ├── data/          { settings_service (shared_preferences) }
        └── presentation/  { settings_bloc, settings_screen }
```

**~39 Dart files, ~3,700 LOC.** No `test/` directory yet.

---

## Bootstrap flow

1. [main.dart](lib/main.dart) calls `WidgetsFlutterBinding.ensureInitialized()`, then `initDependencies()`, then `runApp()`.
2. [injection_container.dart](lib/core/di/injection_container.dart) registers in order: SettingsService → DatabaseHelper → Repositories → UseCases → BLoCs. SettingsBloc is created eagerly and immediately dispatches `LoadSettings()` so currency is available before the first frame.
3. [app.dart](lib/app.dart) builds `MultiBlocProvider` with five BLoCs (Settings, Income, Expense, Savings, Report) all resolved via `sl<T>()`, and registers named routes. **Initial route: `/income`**.

---

## Dependency injection

`GetIt` service locator. See [lib/core/di/injection_container.dart](lib/core/di/injection_container.dart).

| Lifetime         | What                                              |
|------------------|---------------------------------------------------|
| `lazySingleton`  | `SettingsService`, `DatabaseHelper`, all repositories, all use cases |
| `factory`        | All BLoCs (fresh instance per `sl<T>()` resolve) — but `app.dart` resolves each only once at startup, so in practice they're singletons too |

**Note:** `DatabaseHelper` is itself a singleton (private constructor + static `.instance`), so the GetIt registration `() => DatabaseHelper.instance` is redundant but harmless.

---

## Persistence

### SQLite — [lib/core/database/database_helper.dart](lib/core/database/database_helper.dart)

Database: `antigravity_expense.db`, **version 2**.

Tables:

| Table                  | Columns                                                        | Notes                          |
|------------------------|----------------------------------------------------------------|--------------------------------|
| `income_records`       | id, amount, category, description?, date, created_at           |                                |
| `expense_records`      | id, amount, category, description?, date, created_at           |                                |
| `savings_records`      | id, amount, category, description?, date, created_at           |                                |
| `savings_withdrawals`  | id, amount, description?, date, created_at                     | added in v2 migration          |
| `custom_categories`    | id, name, type, **UNIQUE(name, type)**                         | shared by all three feature types |

- **No ORM** — raw SQL via sqflite, wrapped by a thin generic CRUD layer (`insert`, `queryAll`, `queryById`, `queryByDateRange`, `update`, `delete`).
- **No foreign keys** between feature tables; they're effectively independent ledgers.
- **No transactions exposed** — multi-table writes (e.g. the Income→Savings cross-write) are not atomic.

### Shared Preferences — [lib/features/settings/data/settings_service.dart](lib/features/settings/data/settings_service.dart)

Stores `currency_code` only (default `'INR'`). Settings is the one feature that does **not** use sqflite.

---

## Feature anatomy (Clean Architecture)

Every feature except Reports follows this layering:

```
domain/        ← pure Dart, no Flutter, no sqflite
  *_model.dart        # Equatable value object with toMap/fromMap/copyWith
  *_repository.dart   # abstract interface
  *_usecase.dart      # thin orchestration + basic validation (amount > 0)

data/          ← depends on domain + sqflite
  *_repository_impl.dart  # implements the interface, talks to DatabaseHelper

presentation/  ← depends on domain (NOT data)
  *_bloc.dart    # Events / States / Bloc
  *_screen.dart  # Widget tree
```

### Feature inventory

| Feature  | Bloc events                                                   | Default categories                                          | Theme color |
|----------|---------------------------------------------------------------|-------------------------------------------------------------|-------------|
| Income   | Load, Add, Delete, LoadCustomCategories, AddCustomCategory     | Salary, Freelance, Consultancy, Savings                     | green       |
| Expense  | same shape                                                     | Transport, Food, Vegetable, Savings, Medicine, Doctor visit | blue        |
| Savings  | same shape                                                     | (configurable, with Withdrawn semantics for negatives)      | orange      |
| Reports  | LoadReport, FilterReportByDate, AddSavingsWithdrawal           | —                                                           | grey        |
| Settings | LoadSettings, ChangeCurrency                                   | —                                                           | —           |

`LoadCustomCategories` is defined on Income/Expense/Savings BLoCs but **never dispatched** (categories piggyback on the main `Load*` event). Safe to remove.

### Reports is the exception

[lib/features/reports/bloc/report_bloc.dart](lib/features/reports/bloc/report_bloc.dart) has **no domain or data layer of its own**. It aggregates by composing the other four use cases (Income, Expense, Savings, SavingsWithdrawal):

- `LoadReport` fetches everything and computes per-bucket totals.
- `FilterReportByDate` reaches *through* the use cases to `.repository.getXByDateRange(...)` — this is an abstraction leak; either expose the date-range method on the use case, or inject repositories directly.
- Derived state on `ReportLoaded`:
  ```
  netSavings = totalIncome - totalExpense - totalWithdrawals
  inHandCash = totalWithdrawals
  ```
  Note: `totalSavings` (sum of `savings_records.amount`) is computed but **not used** in `netSavings`. The "true" savings number comes from the income/expense/withdrawal trio.

---

## Cross-feature couplings

There are exactly two cross-feature dependencies. Both deserve attention:

1. **IncomeBloc → SavingsUseCase** ([income_bloc.dart:104-121](lib/features/income/presentation/income_bloc.dart#L104-L121))
   When an income row is tagged `category == 'Savings'`, the BLoC also writes a `SavingsModel(amount: -event.income.amount, category: 'Withdrawn')` into `savings_records`. This is *business logic embedded in a BLoC* and the negative-amount semantics are subtle — worth either extracting into a domain service or commenting why it's modeled this way.

2. **ReportBloc → all four use cases** ([report_bloc.dart](lib/features/reports/bloc/report_bloc.dart))
   Pure read-side aggregation; clean fan-in.

All screens additionally `read<SettingsBloc>()` to format the currency symbol — including the reusable `RecordCard` and `AmountInputField` widgets, which implicitly require a `SettingsBloc` ancestor.

---

## State management conventions

- **`flutter_bloc` + `Equatable`** (no `freezed`, no sealed classes).
- Every feature defines `abstract class XxxEvent extends Equatable` / `XxxState extends Equatable` with `props` overrides.
- State lifecycle: `Initial → Loading → Loaded | Error`.
- Loaded states bundle everything the screen needs (records + total + custom categories) to avoid multiple subscriptions.
- Add/Delete handlers don't emit incremental updates — they call `add(LoadX())` to refetch. Simple and correct, slightly chatty.

---

## Navigation

Drawer-based, named-route navigation. See [lib/navigation/app_drawer.dart](lib/navigation/app_drawer.dart).

| Route       | Screen                  |
|-------------|-------------------------|
| `/income`   | `IncomeSourceScreen`    |
| `/expense`  | `ExpenseDetailsScreen`  |
| `/savings`  | `SavingsDetailsScreen`  |
| `/reports`  | `ReportScreen`          |
| `/chart`    | `PieChartScreen`        |
| `/settings` | `SettingsScreen`        |

Drawer uses `pushReplacementNamed`, so there is **no back stack** between top-level screens — navigation is exclusively via the drawer.

---

## Theming

[lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) — Material3, Google Fonts `Inter`, ColorScheme seeded from green.

[lib/core/theme/expense_tracker_app_colors.dart](lib/core/theme/expense_tracker_app_colors.dart) — `ThemeExtension<ExpenseTrackerAppColors>` exposing:

| Property        | Color    |
|-----------------|----------|
| `income`        | #66BB6A  |
| `incomeLight`   | tint     |
| `expense`       | #42A5F5  |
| `expenseLight`  | tint     |
| `savings`       | #FFA726  |
| `savingsLight`  | tint     |

Accessed via `Theme.of(context).extension<ExpenseTrackerAppColors>()!`. Screens override their AppBar background to their feature color.

---

## Reusable widgets

[lib/core/widgets/](lib/core/widgets/)

| Widget                  | Purpose                                                              |
|-------------------------|----------------------------------------------------------------------|
| `AmountInputField`      | Currency-prefixed `TextFormField`; restricts input to `^\d+\.?\d{0,2}`; validates `> 0`. Reads currency from `SettingsBloc`. |
| `CategoryChipSelector`  | `ChoiceChip` row for default + custom categories, plus an `ActionChip` to add a new one. |
| `RecordCard`            | Card with leading category avatar, formatted amount, date, and a delete callback. Reads currency from `SettingsBloc`. |

---

## Packages

| Package              | Purpose                          |
|----------------------|----------------------------------|
| `flutter_bloc`       | State management                 |
| `equatable`          | Value equality for events/states |
| `get_it`             | Service locator (DI)             |
| `sqflite` + `path`   | SQLite persistence               |
| `shared_preferences` | Settings persistence             |
| `fl_chart`           | Pie chart on `/chart`            |
| `intl`               | Date formatting                  |
| `google_fonts`       | Inter font                       |

---

## Known rough edges

See the PR review for details, but in summary:

1. **Income→Savings cross-write** stores a negative `'Withdrawn'` row in `savings_records`, reducing `totalSavings` when you log savings-income. Either semantics-by-design (needs a comment) or a bug.
2. **No DB transaction wrapper**, so the cross-write above can produce orphans on failure.
3. **`ReportBloc` reaches through use cases to repositories** — either expose date-range on the use case or inject the repository directly.
4. **`TextEditingController`s leak** in every Add bottom sheet (income/expense/savings) — not disposed when the sheet closes.
5. **No `test/` directory.** The clean-architecture seams make unit-testing repositories and use cases straightforward; worth seeding at least one BLoC test per feature.
6. **`LoadCustomCategories` event is dead** in the three ledger BLoCs.
