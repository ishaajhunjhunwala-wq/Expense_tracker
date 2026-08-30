# Campus QuickSplit — GDG App Dev Round 2 (Phase 1)

**Frictionless, local-first peer expense tracker for students.**

No phone-number signup, no cloud sync, no network dependency — just fast,
ad-hoc expense splitting for auto rides, group subscriptions, food bills, and
printout costs.

<!--
  📸 SCREENSHOTS — add your photos here before submitting!
  Drop images into the /screenshots folder (already created in this repo)
  and reference them like this:

  | Dashboard | Add Expense | Activity Log |
  |---|---|---|
  | ![Dashboard](screenshots/dashboard.png) | ![Add Expense](screenshots/add_expense.png) | ![Activity Log](screenshots/activity_log.png) |
-->

## ✅ Phase 1 requirements — where each one lives

| Requirement | Implementation |
|---|---|
| Standard Equal Distribution | `AddExpenseScreen` logs description, amount, category, payer, split group → `ExpenseProvider.addExpense` divides the total equally (`Expense.perPersonShare`) |
| Aggregated Balance View | `DashboardScreen` — total spend card + per-member net balance (`ExpenseProvider.balances`) |
| Activity Log | `ActivityLogScreen` — reverse-chronological list with category icons (`ExpenseTile`) and formatted timestamps |
| Input Sanitization | Validated twice: Flutter form validators in `AddExpenseScreen`, **and** re-checked in `ExpenseProvider.addExpense` (empty fields, amount ≤ 0, empty split group, invalid payer/member) |
| Logic Separation | All state and business logic lives in `ExpenseProvider` (`ChangeNotifier` + `provider` package). Widgets only read/watch it — controllers are properly `dispose()`d, no logic leaks into the UI layer |

## 🏗️ Project structure

```
lib/
├── main.dart                     # App entry point, theme, ChangeNotifierProvider
├── models/
│   ├── participant.dart          # Participant model
│   └── expense.dart              # Expense model + ExpenseCategory enum
├── providers/
│   └── expense_provider.dart     # All business logic + validation (single source of truth)
├── screens/
│   ├── home_screen.dart          # Bottom nav shell (Dashboard / Activity)
│   ├── dashboard_screen.dart     # Aggregated Balance View
│   ├── activity_log_screen.dart  # Time-ordered transaction stream
│   ├── add_expense_screen.dart   # Expense entry form + validation
│   └── participants_screen.dart  # Add/remove group members
└── widgets/
    ├── balance_tile.dart         # Per-member balance row
    └── expense_tile.dart         # Per-expense activity row
```

## 🚀 Run it — with zero local installs

You do **not** need to install Flutter, Android Studio, or anything else on
your own machine. Two options:

### Option A — GitHub Actions builds the APK for you (recommended)

This repo already includes `.github/workflows/build.yml`. As soon as you
push this code to GitHub:

1. Go to your repo's **Actions** tab.
2. Wait for the **"Build Campus QuickSplit"** workflow to finish (a few
   minutes) — it runs entirely on GitHub's cloud runners.
3. Open the finished run → scroll to **Artifacts** → download
   `campus-quicksplit-apk` (installable `.apk`) and/or
   `campus-quicksplit-web` (a static web build).
4. Install the APK on any Android phone/emulator to record your demo, or
   host/unzip the web build and open `index.html` in a browser.

### Option B — GitHub Codespaces (free cloud dev environment)

1. On your repo page, click **Code → Codespaces → Create codespace on main**.
2. This spins up a full Linux VM in your browser (nothing installs on your
   PC). Inside its terminal, run:
   ```bash
   sudo snap install flutter --classic   # or use the Flutter devcontainer feature
   flutter doctor
   flutter pub get
   flutter run -d chrome                 # runs the app in-browser inside Codespaces
   ```
3. Codespaces forwards the port so you can view/interact with the running
   app directly from your browser tab — perfect for screen-recording your demo.

## 📦 Deploying this to GitHub without installing anything locally

1. **Create the repo:** go to [github.com/new](https://github.com/new),
   name it `campus-quicksplit`, keep it public, create it (don't add a
   README — this project already has one).
2. **Upload the code via the browser:**
   - On the new repo's page, click **"uploading an existing file"**.
   - Drag the *entire unzipped project folder* (including the hidden
     `.github` folder — you may need to upload it as a second batch, since
     some browsers hide dotfiles from drag-and-drop; you can also use
     **Add file → Upload files** and select all files including `.github/workflows/build.yml`).
   - Commit directly to `main`.
3. **Let Actions build your APK:** open the **Actions** tab — the workflow
   triggers automatically on that push. Download the APK artifact once green.
4. **Record your demo:**
   - Sideload the APK onto any Android phone (or use a free browser-based
     Android emulator like [Appetize.io](https://appetize.io) — upload the
     APK there and screen-record it running), **or**
   - Use the web build artifact and record it running in any browser.
5. **Upload the demo video to Google Drive**, set sharing to
   "Anyone with the link," and copy the link.
6. **Submit:** paste your GitHub repo link and Google Drive demo link into
   the form: https://forms.gle/3385jSjSiFRTyE7R9

## 🧠 Design notes

- **Local-first, no auth:** participants are just names — zero onboarding
  friction for a one-off group.
- **Provider pattern:** `ExpenseProvider` is the single mutable state
  container; UI widgets are stateless/read-only wherever possible.
- **Defense-in-depth validation:** every rule enforced in the UI form is
  re-verified inside `ExpenseProvider`, so bad data can never enter state
  regardless of which screen calls it.
- **Extensible for Phase 2/3:** the model layer (`Expense`, `Participant`)
  and provider are structured to support unequal splits, persistence, and
  multi-group support without a rewrite.

## 🛠️ Tech stack

- Flutter (Material 3)
- `provider` for state management
- `intl` for timestamp formatting
