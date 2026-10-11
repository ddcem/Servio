# Servio

Servio is a restaurant point-of-sale system. Waiters take orders on an Android phone, the kitchen and the bar
see them instantly on their displays, and the admin manages the menu, staff, tables, reservations, payments
and business reports in a desktop app.

| Part | Technology | Used by |
|---|---|---|
| **Mobile app** (`frontend/servio_mobile`) | Flutter, Android | Waiters |
| **Desktop app** (`frontend/servio_desktop`) | Flutter, Windows / macOS | Kitchen, bar, admin |
| **API** (`backend/Servio.API`) | ASP.NET Core (.NET 10), REST + SignalR | Both apps |
| **Worker** (`backend/Servio.Worker`) | .NET 10 worker service | Sends emails from the RabbitMQ queue |
| **Database / messaging** | PostgreSQL 17, RabbitMQ 4.1 | API and worker |

---

## Login credentials

All demo accounts use the password **`test`**.

| Context | Username | Password | Role |
|---|---|---|---|
| Desktop app (admin panel) | `desktop` | `test` | Admin |
| Mobile app (waiter) | `mobile` | `test` | Waiter |
| Kitchen display (desktop app) | `kitchen` | `test` | Kitchen |
| Bar display (desktop app) | `bar` | `test` | Bar |
| Other waiters | `waiter`, `waiter2` | `test` | Waiter |
| Second admin | `admin` | `test` | Admin |
| Deactivated account (cannot log in) | `waiter3` | `test` | Waiter |

**PayPal (sandbox):** besides cash, guests pay through PayPal. On the PayPal page, log in with the sandbox buyer account
**`buyerGermany@personal.paypal.com`** / **`paypal1234`**. No real money is used. PayPal does not accept every currency
(for example BAM/KM); for such a restaurant currency the app offers cash only and explains why.

---

## Running Servio from scratch

### 1. Requirements

| To run | You need |
|---|---|
| Backend (API, worker, database, RabbitMQ) | [Docker Desktop](https://www.docker.com/products/docker-desktop/) |
| Mobile app | [Flutter 3.47](https://docs.flutter.dev/get-started/install) (stable) with the Android SDK and an emulator or phone |
| Desktop app on Windows | Flutter 3.47 and Visual Studio 2022 with the **Desktop development with C++** workload |
| Desktop app on macOS (optional) | Flutter 3.47 and Xcode |

Alternatively, the ready-made builds (Android APK and Windows EXE) are attached to the GitHub Release
(see [Release builds](#5-release-builds)); then only Docker is needed.

### 2. Configuration (`.env`)

All configuration (database, RabbitMQ, JWT, PayPal, SMTP, API port) lives in **one `.env` file** in the
repository root. Nothing is hard-coded in the code or in `appsettings.json`.

The repository contains **`.env-tajne.zip`** instead of the real `.env`. Extract it into the repository root
with the password provided together with the submission:

```bash
# from the repository root
unzip .env-tajne.zip        # asks for the password, creates .env next to docker-compose.yml
```

On Windows: right-click the file → *Extract All*, enter the password, and extract into the repository root.

### 3. Start the backend

```bash
docker compose up -d --build
```

This builds and starts four containers: `servio-db`, `servio-rabbitmq`, `servio-api` and `servio-worker`.
On the first start the API creates the database and fills it with demo data (menu with images, tables,
staff, reservations and about six weeks of order history for the reports). This takes about 15 seconds.

| Service | Address |
|---|---|
| API | http://localhost:5050 |
| RabbitMQ management | http://localhost:15672 (user and password from `.env`) |
| PostgreSQL | `localhost:5440` (database, user and password from `.env`) |

Check that the API is running:

```bash
docker compose ps                       # all four containers "Up" / "healthy"
docker compose logs servio-api | tail   # ends with "Database seeded" on the first start
```

### 4. Start the apps

The API address is passed at start-up with `--dart-define=API_BASE_URL=...` and read with
`String.fromEnvironment('API_BASE_URL')`. The defaults below work without the flag.

**Mobile app (Android emulator):**

```bash
cd frontend/servio_mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5050
```

`10.0.2.2` is the host computer as seen from the Android emulator. On a real phone, use the computer's
address on the same Wi-Fi network instead, e.g. `--dart-define=API_BASE_URL=http://192.168.1.20:5050`.

**Desktop app (Windows):**

```bash
cd frontend/servio_desktop
flutter pub get
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5050
```

On macOS use `-d macos`.

### 5. Release builds

The GitHub Release contains one archive, `servio-build-YYYY-MM-DD.zip`, with:

* `app-release.apk` – install on an Android emulator or phone (drag the file onto the emulator).
  It connects to `http://10.0.2.2:5050`.
* `Release/` – the Windows desktop app; run `servio_desktop.exe`. It connects to `http://localhost:5050`.

The backend (step 3) must be running for both.

To build them yourself:

```bash
cd frontend/servio_mobile
flutter clean
flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:5050
# -> build/app/outputs/flutter-apk/app-release.apk

cd ../servio_desktop
flutter clean
flutter build windows --release --dart-define=API_BASE_URL=http://localhost:5050
# -> build/windows/x64/runner/Release/
```

### 6. Stopping and resetting

```bash
docker compose down        # stop, keep the data
docker compose down -v     # stop and delete the database; the next start seeds fresh demo data
```

---

## What to try

**Waiter (mobile, `mobile` / `test`)**

1. The waiter guide appears on the first start; it can be reopened in *Settings*.
2. Tap a free table, choose the number of guests and add items. After each item Servio suggests what usually
   goes with it and explains why (the recommender).
3. Open the cart, add a note to an item and send the order to the kitchen and bar.
4. When the kitchen or bar marks the order ready, the waiter is notified instantly. Mark it served in
   *Active Tables*, then take payment: choose a tip, then cash (with change calculation) or PayPal.
5. Show the receipt, and find past orders and their receipts under *Order history*.

**Kitchen / bar (desktop, `kitchen` or `bar` / `test`)**

* New orders appear live; *Start Preparing* → *Mark as Ready* notifies the waiter.

**Admin (desktop, `desktop` / `test`)**

* *Kitchen View* / *Bar View*: watch the stations (view only).
* *Admin Panel*: menu (with images and daily availability), employees, tables, reservations (with
  confirmation emails), orders and payments (receipts, PayPal refunds), reference data, notifications and settings.
* *Tables → Assign waiters*: drag tables to the waiter who serves them this shift. A waiter can only take orders
  at their own tables and at unassigned ones.
* *Reports*: today's figures, period analysis with charts, and the **Sales** and **Staff** reports as PDF.

**Languages:** every user can switch between **English** and **Bosnian** (login screen or *Settings*).
The choice is saved in the account, so notifications, emails, receipts and PDF reports use it too.
Menu prices include 17% VAT; receipts show the base amount and the VAT.

---

## Project structure

```
backend/
  Servio.API/        REST API, SignalR hub (live updates and notifications), authentication, Swagger (Development)
  Servio.Services/   business logic, EF Core, migrations, seed data, recommender, PayPal, PDF reports, translations
  Servio.Model/      requests, responses, enums, search objects
  Servio.Worker/     separate service: reads email jobs from RabbitMQ and sends them over SMTP
frontend/
  servio_shared/     API client, models, providers, theme, translations (lib/l10n) – used by both apps
  servio_mobile/     waiter app (Android)
  servio_desktop/    kitchen, bar and admin app (Windows / macOS)
docs/database-design.md      database diagram and tables
recommender-dokumentacija.md how the recommender works
docker-compose.yml           all backend services
.env-tajne.zip               the .env configuration file (password protected)
```

## Tests

End-to-end tests drive the real apps against the running backend:

```bash
cd frontend/servio_mobile
flutter test integration_test/waiter_flow_test.dart -d <android-device-id>   # see: flutter devices

cd ../servio_desktop
flutter test integration_test/screens_test.dart -d windows      # or -d macos
```

## Troubleshooting

| Problem | Fix |
|---|---|
| The app says it cannot reach the server | Check that `docker compose ps` shows `servio-api` as Up, and that the app uses the right address (`10.0.2.2` in the Android emulator, `localhost` on the desktop). |
| A port is already in use | Change `API_PORT` or `DB_HOST_PORT` in `.env`, then pass the new API port with `--dart-define`. Port 5000 is avoided because macOS uses it for AirPlay. |
| PayPal page does not load in the emulator | The emulator needs internet access; PayPal sandbox runs at `sandbox.paypal.com`. |
| No emails arrive | Check the SMTP values in `.env` and `docker compose logs servio-worker`. |
| Start over with fresh demo data | `docker compose down -v` and `docker compose up -d --build`. |
