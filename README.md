# Pocketly

Pocketly is a Flutter money dashboard. The user selects a CSV statement; the app forwards that file unchanged to the import API and renders only normalized transactions returned by the API. No sample financial data is used and no state-management framework is used: the screen has local `StatefulWidget` variables only.

## Setup

Requires Flutter stable with Dart 3.11 or later.

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://api.example.com --dart-define=API_UPLOAD_PATH=/statements/import
flutter test
```

Screenshot placeholders: `docs/home.png`, `docs/analysis.png`, and `docs/transactions.png`. The current development defaults are the existing API address and `/api/v1/upload/csv`; supply the confirmed endpoint through the `--dart-define` values above.

## Architecture and dynamic data flow

```
CSV selected → StatementApi multipart POST → StatementEntity / TransactionEntity
                                                   ↓
                    StatementCalculations → SummaryEntity / CategorySpendEntity
                                                   ↓
                         Stateful PocketlyPage → cards, chart, chips, sheet
```

The domain layer is pure Dart. The data layer owns HTTP and JSON mapping. Presentation has only short-lived local values: `_statement` (`StatementEntity?`, successful import), `_isUploading` (`bool`, upload progress), `_showAnalysis` (`bool`, local navigation), and `_selectedIndex` (`int?`, selected chart slice).

## File guide

| File | Layer | Purpose |
| --- | --- | --- |
| `lib/main.dart` | app | Starts Pocketly and configures themes. |
| `lib/core/theme/app_theme.dart` | core | Shared color tokens and Material themes. |
| `domain/entities/transaction_entity.dart` | domain | Immutable transaction fields: `id`, `name`, `date`, `dateText`, `amount`, `category`, `method`. |
| `domain/entities/statement_entity.dart` | domain | `fileName`, `importedAt`, and transactions. |
| `domain/entities/statement_calculations.dart` | domain | Dynamic summary, category, and merchant calculations. |
| `data/statement_api.dart` | data | Configurable CSV multipart request, response mapping, errors, and last-statement cache. |
| `presentation/pages/pocketly_page.dart` | presentation | Dashboard, chart, bottom sheet, and settings UI. |

The feature paths above start at `lib/features/statement/`. The existing `lib/features/file_upload/` files are legacy uploader code and not imported by Pocketly.

## Variables and rules

`moneyReceived` is the sum of positive amounts; `totalSpend` is the absolute sum of negatives; `netCashFlow` is received less spend; and `transactionCount` is the returned row count. A category has dynamic `total`, `percent`, newest-first `transactions`, and `merchantTotals`. Every card, pie angle, legend label, detail amount, and transaction row is calculated from these values.

## API contract

`POST {API_BASE_URL}{API_UPLOAD_PATH}` as `multipart/form-data`, field `file`, accepts a `.csv` under 5 MB. Flutter never reads or parses the selected file.

```json
{"fileName":"statement.csv","importedAt":"2026-10-14T10:00:00Z","transactions":[{"id":"tx-1","name":"Merchant","date":"2026-10-12T00:00:00Z","dateText":"12/10/2026","amount":-42.5,"category":"Food","method":"Card"}]}
```

Positive amounts are received and negatives are spend. A 4xx/5xx body can use `{ "message": "…" }`, which is presented to the user. Other handled failures are files over 5 MB, unavailable network, and invalid JSON.

## Color tokens

| Token | Hex | Use |
| --- | --- | --- |
| yellow | `#EEF52B` | received card, CTA, active choice |
| pink | `#FF9F9F` | transactions/profile |
| red | `#FF4A1C` | negative flow/pie slice |
| ink | `#0A0A0A` | text/light black cards |
| muted | `#8E8E93` | secondary text/pie slice |
| buttonGray | `#EFEFF1` | back button/chips |
| line | `#E3E3E6` | empty chart ring |
| darkCard | `#1C1C1E` | dark cards/sheets |

## Persistence, errors, and extension

The last successful normalized API response (never the original CSV) is saved to the device temporary application area and loaded at launch. A successful import replaces it; failed imports never clear or overwrite it.

For a period filter, add a pure domain calculation with transactions and a date range. For Top 5 senders/recipients, group signed transactions in another domain calculation; neither change needs HTTP or chart edits.
