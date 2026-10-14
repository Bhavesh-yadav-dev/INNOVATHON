Pocketly – Flutter Build Prompt
A complete, copy-ready prompt for building the Pocketly finance app in Flutter with clean architecture. Items marked [Assumption] are my defaults, so change them if they are wrong.

1. Role and goal
   You are a senior Flutter engineer. Build Pocketly, a personal money-tracking app, in Flutter (stable channel, Dart 3, null safety) using Clean Architecture. The user's only input is a .csv bank or transaction statement uploaded from the app. Everything the user sees (totals, counts, categories, merchants, dates, chart slices, labels derived from data) must be computed dynamically from that file. Nothing numeric or data-derived may be hard-coded. The app does not parse the CSV: it sends the file directly to a backend API and renders what the API returns.
   If the user does not upload a new file, the app must show the previous data from the last successful upload (persisted on the device). Before reading any code, ask me about anything that is unclear.
2. Screens and behaviour
   2.1 Home page
   • App bar: a round profile icon button on the left (pink circle) that opens a settings bottom sheet (Profile, Currency, Notifications, Theme, Log out). Next to it is the brand: a yellow starburst and the text Pocketly.
   • Heading: two-tone title with "Money" in thin gray and "Overview" in bold ink.
   • 2 × 2 stat cards, each tappable:
   ◦ Money received (yellow card)
   ◦ Total spend (black card)
   ◦ Net cash flow (black card)
   ◦ Transactions count (pink card)
   • Detail Analysis button: a wide, centered yellow pill with an arrow icon that opens the Analysis page.
   • Upload card at the bottom: a black rounded card with a yellow circle upload icon, titled Upload transaction statement. The subtitle shows the loaded file name and import time, or ".csv format · tap to choose a file" when nothing is loaded. Tapping opens the file picker, restricted to .csv. The app uploads the file unchanged to the backend, shows a loading state, and on success saves the response locally and opens the Analysis page.
   2.2 Analysis page ("Your Analysis")
   • App bar: a round back button and the title Your Analysis with the starburst.
   • The same 2 × 2 stat cards as Home, with the same colors.
   • Section heading: "Spending" (thin) and "by category" (bold).
   • Donut pie chart of spending by category:
   ◦ The centre shows "Total spend" and the amount. When a slice is selected it shows that category's name and amount.
   ◦ Tapping a slice makes it pop out by 9 px.
   ◦ A legend of tappable chips sits below the chart and does the same as tapping a slice.
   ◦ Show at most 6 slices. If there are more categories, merge the smallest into "Other".
   • Detail panel (black rounded card) under the chart: "Paid for <Category> · xx.x%" followed by the merchants and the amount paid to each. When nothing is selected it shows the hint "Tap a slice to see all its transactions."
   • Transactions popup (opens when a slice or chip is tapped):
   ◦ A translucent frosted-glass bottom sheet over a blurred, dimmed backdrop.
   ◦ Header: category name, total, and number of transactions, plus a round × button. Tapping outside also closes it.
   ◦ A scrollable list of every transaction in that category, newest first. Each row has a yellow circle with the merchant's initial, the merchant name, the date and time plus payment method, and the amount shown negative on the right.
   • Empty state: if no data has ever been uploaded, show zeros, an empty chart ring, and the message "Upload a .csv statement to get started." Do not show sample data.
   2.3 Not in version 1
   A time-period menu (weekly, monthly, yearly, all) and a Top 5 Senders and Recipients section were designed and then removed. Do not build them now, but keep the domain layer open so they can be added later as new use cases.
3. Design system and complete color visualization
   The look is neon yellow, black, white and soft pink, with starburst shapes, big rounded corners and two-tone light/bold headings. Define every color once in a theme class (for example an AppColors ThemeExtension). Widgets must never contain hex values.
   3.1 Core palette
   Token
   Light
   Dark
   Used for
   yellow
   #EEF52B
   #EEF52B
   Money received card, CTA, upload icon, avatars, active chip, selected row
   pink
   #FF9F9F
   #FF9F9F
   Transactions card, profile button
   red
   #FF4A1C
   #FF4A1C
   Negative net cash flow, 4th pie slice
   ink
   #0A0A0A
   #FFFFFF
   Main text, 2nd pie slice
   background
   #FFFFFF
   #0A0A0A
   Page background
   blackCard
   #0A0A0A
   #1C1C1E
   Total spend, Net cash flow, upload card, detail panel
   mute
   #8E8E93
   #8E8E93
   Thin part of two-tone headings, secondary text
   buttonGray
   #EFEFF1
   #232325
   Round back button, chips
   line
   #E3E3E6
   #333333
   Dividers
   sheet
   #FFFFFF
   #1C1C1E
   Settings sheet
   onYellow / onPink
   #0A0A0A
   #0A0A0A
   Text on yellow and pink
   onBlack
   #FFFFFF
   #FFFFFF
   Text on black cards
   negativeOnPink
   #B3200A
   #B3200A
   Negative net value on the pink card
   3.2 Card color map
   Card
   Background
   Text
   Starburst
   Money received
   yellow
   onYellow
   ink (black)
   Total spend
   blackCard
   onBlack
   yellow
   Net cash flow
   blackCard
   onBlack, value yellow when positive and red when negative
   yellow
   Transactions
   pink
   onPink
   white
   3.3 Pie palette (assigned by slice index, never by category name)
4. #EEF52B (yellow)
5. ink (#0A0A0A in light mode, #FFFFFF in dark mode)
6. #FF9F9F (pink)
7. #FF4A1C (red)
8. #8E8E93 (gray)
9. #D9D9DE (light gray)
   Slices have a 3 px stroke in the background color to separate them.
   3.4 Glass popup and overlays
   • Popup panel: white at 60 % opacity in light mode, #1C1C1E at 62 % in dark mode, with a 1 px border (white at 50 % or 12 %), a backdrop blur of 24 and saturation 1.6, and top corners of 32.
   • Backdrop behind the popup: black at 30 % with a blur of 10.
   • Toast / snackbar: black background, yellow text, fully rounded pill.
   3.5 Shapes, type and spacing
   • Starburst: a 16-point star drawn with a CustomPainter or ClipPath (32 points alternating between 50 % and 38 % of the radius).
   • Corners: cards 28, pills fully rounded, circle buttons 48 px, bottom sheets 32 on top.
   • Font: Outfit via google_fonts (fallback: system sans-serif). Weights 300, 600 and 700. Heading 40 px with -1 letter spacing, card value 26 bold, card label 14, body 15.
   • Spacing: page padding 16, grid gap 12, vertical section gap 18. Centre the content with a max width of 430 on wide screens.
   • Press feedback: tappable cards and buttons scale to 0.96 when pressed.
   • Accessibility: minimum tap target 48 × 48, semantic labels on icon buttons, text contrast at least 4.5:1.
10. Dynamic variables and data model
    Every value below comes from the CSV or is derived from it. Put them in domain entities (immutable, Equatable).
    Entity
    Fields
    TransactionEntity
    id, name (merchant or description), date (nullable DateTime), dateText (raw text from the file), amount (signed double: positive received, negative spent), category, method (nullable)
    StatementEntity
    fileName, importedAt, transactions (list)
    SummaryEntity
    moneyReceived, totalSpend, netCashFlow, transactionCount
    CategorySpendEntity
    category, total, percent, transactions (newest first), merchantTotals (map of merchant to amount)
    Derived rules:
    • moneyReceived = sum of positive amounts. totalSpend = sum of the absolute value of negative amounts. netCashFlow = received minus spend. transactionCount = number of rows kept.
    • percent = category total ÷ total spend × 100.
    • Slice index decides the color. The slice angle comes from percent.
    • Currency symbol, number formatting and date formatting come from a settings value (default USD, intl formatting), not from string literals.
    4.1 Backend API contract
    The app never reads or parses CSV content. It uploads the picked .csv file unchanged and renders the JSON the backend returns. [Assumption] The paths and field names below are a proposal, so replace them with the real contract once the backend team confirms it.
    Item
    Value
    Base URL
    From environment config (AppConfig.apiBaseUrl), never hard-coded in widgets
    Upload
    POST /statements/import, multipart/form-data, field file (the .csv)
    Success response
    200 JSON with fileName, importedAt (ISO 8601) and transactions[]
    Transaction fields
    id, name, date (ISO 8601 or null), dateText, amount (signed number), category, method (nullable)
    Errors
    400 unreadable or invalid CSV, 413 file too large, 5xx server error; body { "message": "..." }
    Timeouts
    30 s to send and 30 s to receive, with a cancel option while uploading
    • The app maps the JSON to TransactionModel and then to TransactionEntity.
    • A negative amount is spent and a positive amount is received. The backend applies any debit or credit column rules.
    • The picker is limited to .csv, and the app checks the file size ([Assumption] 5 MB maximum) before uploading.
    • On any error the app shows the backend's message (or a generic one) and leaves the saved data untouched.
    4.2 Persistence rule
11. On a successful import, replace the locally cached statement with the new API response [Assumption: replace, not merge; the app caches the response in Hive].
12. On app start, load the cached statement before drawing the first frame, so the previous numbers appear immediately.
13. A failed upload or network error never overwrites or clears the cache.
14. If there is no cached data, show the empty state from section 2.2.
15. Architecture (Clean Architecture)
    Dependency rule: presentation → domain ← data. The domain layer is pure Dart and imports no Flutter, no packages for storage, no packages for file picking or networking.
    lib/
    ├── main.dart
    ├── app.dart # MaterialApp, theme, named routes
    ├── core/
    │ ├── config/app_config.dart # API base URL, timeouts, max file size
    │ ├── di/injection.dart # get_it setup
    │ ├── error/failures.dart # network, server, invalid file, cache failures
    │ ├── network/api_client.dart # dio wrapper, multipart upload
    │ ├── routes/app_routes.dart # route names and onGenerateRoute (Navigator)
    │ ├── usecase/usecase.dart # base UseCase<Type, Params>
    │ ├── theme/app_colors.dart # all color tokens (light and dark)
    │ ├── theme/app_theme.dart
    │ ├── constants/app_sizes.dart # radii, spacing, font sizes
    │ └── utils/formatters.dart # money, date, percent
    ├── features/
    │ └── statement/
    │ ├── domain/
    │ │ ├── entities/ # transaction, statement, summary, category_spend
    │ │ ├── repositories/statement_repository.dart # abstract
    │ │ └── usecases/
    │ │ ├── import_statement.dart
    │ │ ├── get_saved_statement.dart
    │ │ ├── get_summary.dart
    │ │ ├── get_category_breakdown.dart
    │ │ └── get_category_transactions.dart
    │ ├── data/
    │ │ ├── models/ # transaction_model, statement_model (JSON mapping)
    │ │ ├── datasources/
    │ │ │ ├── file_picker_datasource.dart # pick a .csv file
    │ │ │ ├── statement_remote_datasource.dart # upload to the backend API
    │ │ │ └── statement_local_datasource.dart # cache the last response (Hive)
    │ │ └── repositories/statement_repository_impl.dart
    │ └── presentation/
    │ ├── bloc/ # statement_bloc, analysis_cubit (state, event)
    │ ├── pages/ # home_page.dart, analysis_page.dart
    │ └── widgets/ # stat_card, starburst, donut_chart, category_chip,
    │ # transactions_sheet, upload_card, settings_sheet
    test/ # mirrors lib/
    [Assumption] Stack: flutter_bloc for state, get_it for dependency injection, Flutter's built-in Navigator with named routes for navigation (no router package), file_picker for picking the CSV, dio for the multipart upload, hive / hive_flutter for the local cache, equatable, fpdart (Either<Failure, T>), google_fonts, intl.
    Rules:
    • Use cases return Either<Failure, T>. Repositories are abstract in domain and implemented in data.
    • Widgets contain no business logic. They read state from the bloc or cubit only.
    • The pie chart is drawn from CategorySpendEntity values only. No chart numbers appear in widget code.
    • All HTTP code lives in api_client.dart and statement_remote_datasource.dart, so the backend can change without touching other layers.
    • Use const constructors wherever possible. Keep the analyzer at zero warnings and run dart format.
16. README.md (required deliverable)
    Create a README.md at the project root that documents all information about the variables and files. It must contain:
17. Overview: what Pocketly does and a screenshot placeholder for each screen.
18. Setup: Flutter version, flutter pub get, how to run, how to test.
19. Architecture: a short diagram of the three layers and the data flow from "user picks a .csv" to "cards and chart update".
20. Folder and file guide: every file under lib/ with a one-line purpose and its layer.
21. Variable dictionary: a table for every entity field and every important state variable, with columns name, type, layer, where it comes from, where it is used.
22. API contract: endpoint, multipart request, response fields, error codes, and a sample response.
23. Color tokens: a table copied from section 3, with the exact hex values and where each is used.
24. Persistence: how the previous statement is saved, loaded and replaced.
25. Error handling: every Failure type and the message the user sees.
26. How to extend: how to add the period filter or the Top 5 section later.
    Also add Dart doc comments (///) to every public class and field. Update the README whenever a file or variable is added or renamed.
27. Tests and quality
    • Unit tests for the API response models (valid response, missing fields, empty list) and for the remote data source with a mocked HTTP client (success, timeout, 4xx, 5xx).
    • Unit tests for each use case and for the summary and category calculations.
    • Bloc tests for: first launch with no data, launch with saved data, successful import, failed import that keeps old data.
    • One widget test for the stat card colors and one for the transactions sheet scrolling.
    • Support light and dark mode, and phones from 320 px wide up.
28. Order of work
29. Ask me any open questions.
30. Create the project, folder structure, theme and color tokens.
31. Domain layer: entities, repository contract, use cases.
32. Data layer: API client, file picker data source, response models, local cache, repository.
33. Presentation: Home page, Analysis page, donut chart, transactions sheet.
34. Tests, then the README.md.
35. Open questions to confirm
36. What are the real base URL, upload path, multipart field name and JSON response shape of the backend (section 4.1 is only a proposal)?
37. Does the backend also store the last statement so the app can fetch it, or should the app rely only on its local cache?
38. Is authentication needed on the upload request (a token or API key)?
39. Are you happy with the rest of the stack in section 5 (Bloc, get_it, Hive)?
