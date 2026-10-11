# Servio

Servio je sistem za naplatu i vođenje narudžbi u restoranu (POS). Konobari primaju narudžbe na Android telefonu,
kuhinja i šank ih odmah vide na svojim ekranima, a administrator u desktop aplikaciji upravlja menijem,
uposlenicima, stolovima, rezervacijama, plaćanjima i poslovnim izvještajima.

| Dio | Tehnologija | Koristi |
|---|---|---|
| **Mobilna aplikacija** (`frontend/servio_mobile`) | Flutter, Android | Konobari |
| **Desktop aplikacija** (`frontend/servio_desktop`) | Flutter, Windows / macOS | Kuhinja, šank, administrator |
| **API** (`backend/Servio.API`) | ASP.NET Core (.NET 10), REST + SignalR | Obje aplikacije |
| **Worker** (`backend/Servio.Worker`) | .NET 10 worker servis | Šalje e-mailove iz RabbitMQ reda |
| **Baza / poruke** | PostgreSQL 17, RabbitMQ 4.1 | API i worker |

---

## Korisnički podaci za pristup

Svi demo računi koriste lozinku **`test`**.

| Kontekst | Korisničko ime | Lozinka | Uloga |
|---|---|---|---|
| Desktop verzija (administracija) | `desktop` | `test` | Admin |
| Mobilna verzija (konobar) | `mobile` | `test` | Waiter |
| Ekran kuhinje (desktop verzija) | `kitchen` | `test` | Kitchen |
| Ekran šanka (desktop verzija) | `bar` | `test` | Bar |
| Ostali konobari | `waiter`, `waiter2` | `test` | Waiter |
| Drugi administrator | `admin` | `test` | Admin |
| Deaktiviran račun (prijava nije moguća) | `waiter3` | `test` | Waiter |

**PayPal (sandbox):** osim gotovinom, gosti mogu platiti putem PayPala. Na PayPal stranici prijavite se sandbox
računom kupca **`buyerGermany@personal.paypal.com`** / **`paypal1234`**. Ne koristi se pravi novac.
PayPal ne podržava sve valute (npr. BAM/KM); ako je valuta restorana takva, aplikacija nudi samo gotovinu i
objašnjava zašto.

---

## Pokretanje od nule

### 1. Preduslovi

| Za pokretanje | Potrebno je |
|---|---|
| Backend (API, worker, baza, RabbitMQ) | [Docker Desktop](https://www.docker.com/products/docker-desktop/) |
| Mobilna aplikacija | [Flutter 3.47](https://docs.flutter.dev/get-started/install) (stable) sa Android SDK-om i emulatorom ili telefonom |
| Desktop aplikacija na Windowsu | Flutter 3.47 i Visual Studio 2022 sa workloadom **Desktop development with C++** |
| Desktop aplikacija na macOS-u (opcionalno) | Flutter 3.47 i Xcode |

Umjesto toga mogu se koristiti gotovi buildovi (Android APK i Windows EXE) iz GitHub Release-a
(vidjeti [Release buildovi](#5-release-buildovi)); tada je potreban samo Docker.

### 2. Konfiguracija (`.env`)

Sva konfiguracija (baza, RabbitMQ, JWT, PayPal, SMTP, port API-ja) nalazi se u **jednoj `.env` datoteci** u
korijenu repozitorija. Ništa nije hardkodirano u kodu niti u `appsettings.json`.

Umjesto stvarne `.env` datoteke repozitorij sadrži **`.env-tajne.zip`**. Raspakujte je u korijen repozitorija
pomoću šifre koja je dostavljena uz predaju rada:

```bash
# iz korijena repozitorija
unzip .env-tajne.zip        # traži šifru i kreira .env pored docker-compose.yml
```

Na Windowsu: desni klik na datoteku → *Extract All*, unesite šifru i raspakujte u korijen repozitorija
(tako da se `.env` nalazi pored `docker-compose.yml`, a ne u podfolderu).

### 3. Pokretanje backenda

```bash
docker compose up -d --build
```

Ovo builda i pokreće četiri kontejnera: `servio-db`, `servio-rabbitmq`, `servio-api` i `servio-worker`.
Pri prvom pokretanju API kreira bazu i puni je demo podacima (meni sa slikama, stolovi, uposlenici,
rezervacije i oko tri mjeseca historije narudžbi za izvještaje). To traje oko 15 sekundi.

| Servis | Adresa |
|---|---|
| API | http://localhost:5050 |
| RabbitMQ management | http://localhost:15672 (korisnik i lozinka iz `.env`) |
| PostgreSQL | `localhost:5440` (baza, korisnik i lozinka iz `.env`) |

Provjera da API radi:

```bash
docker compose ps                       # sva četiri kontejnera "Up" / "healthy"
docker compose logs servio-api | tail   # pri prvom pokretanju završava sa "Database seeded"
```

### 4. Pokretanje aplikacija

Adresa API-ja se zadaje pri pokretanju sa `--dart-define=API_BASE_URL=...` i čita preko
`String.fromEnvironment('API_BASE_URL')`. Navedene adrese su ujedno i zadane vrijednosti, pa rade i bez parametra.

**Mobilna aplikacija (Android emulator):**

```bash
cd frontend/servio_mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5050
```

`10.0.2.2` je adresa računara gledano iz Android emulatora. Na stvarnom telefonu koristite adresu računara u
istoj mreži, npr. `--dart-define=API_BASE_URL=http://192.168.1.20:5050`.

**Desktop aplikacija (Windows):**

```bash
cd frontend/servio_desktop
flutter pub get
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5050
```

Na macOS-u koristite `-d macos`.

### 5. Release buildovi

GitHub Release sadrži jednu arhivu, `servio-build-GGGG-MM-DD.zip`, sa:

* `app-release.apk` – instalira se na Android emulator ili telefon (prevucite datoteku na emulator).
  Spaja se na `http://10.0.2.2:5050`.
* `Release/` – Windows desktop aplikacija; pokrenite `servio_desktop.exe`. Spaja se na `http://localhost:5050`.

Za oba je potrebno da backend (korak 3) radi.

Samostalni build:

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

### 6. Zaustavljanje i resetovanje

```bash
docker compose down        # zaustavlja, podaci ostaju
docker compose down -v     # zaustavlja i briše bazu; sljedeće pokretanje ponovo puni demo podatke
```

---

## Šta isprobati

Aplikacije su po zadanim postavkama na engleskom jeziku; jezik se mijenja na ekranu za prijavu ili u
*Settings* (*Postavke*). U nastavku su nazivi navedeni na engleskom, a u zagradi na bosanskom.

**Konobar (mobilna, `mobile` / `test`)**

1. Pri prvom pokretanju prikazuje se vodič za konobare; može se ponovo otvoriti u *Settings* (*Postavke*).
2. Odaberite slobodan sto, unesite broj gostiju i dodajte stavke. Nakon svake stavke Servio predlaže šta se
   obično naručuje uz nju i objašnjava zašto (sistem preporuke).
3. Otvorite korpu, dodajte napomenu na stavku i pošaljite narudžbu kuhinji i šanku
   (*Send Order* / *Pošalji narudžbu*).
4. Kada kuhinja ili šank označe narudžbu spremnom, konobar odmah dobija obavijest. Označite je posluženom u
   *Active Tables* (*Aktivni stolovi*), zatim naplatite: odaberite napojnicu, pa gotovinu (uz izračun kusura)
   ili PayPal.
5. Prikažite račun; ranije narudžbe i njihovi računi nalaze se u *Order History* (*Historija narudžbi*).

**Kuhinja / šank (desktop, `kitchen` ili `bar` / `test`)**

* Nove narudžbe se pojavljuju uživo; *Start Preparing* (*Započni pripremu*) → *Mark as Ready*
  (*Označi spremnim*) obavještava konobara.

**Administrator (desktop, `desktop` / `test`)**

* *Kitchen View* / *Bar View* (*Pregled kuhinje* / *Pregled šanka*): praćenje stanica (samo pregled).
* *Admin Panel* (*Administracija*): meni (sa slikama i dnevnom dostupnošću), uposlenici, stolovi,
  rezervacije (sa e-mailovima potvrde), narudžbe i plaćanja (računi, PayPal povrat novca), šifarnici,
  obavijesti i postavke.
* *Tables → Assign waiters* (*Stolovi → Dodijeli konobare*): prevlačenjem se stolovi dodjeljuju konobaru koji
  ih poslužuje u toj smjeni. Konobar može primati narudžbe samo za svoje i nedodijeljene stolove.
* *Reports* (*Izvještaji*): današnje brojke, analiza perioda sa grafikonima te izvještaji **prodaje** i
  **uposlenika** u PDF formatu.

**Jezici:** svaki korisnik može birati između **engleskog** i **bosanskog** jezika. Izbor se pamti u
korisničkom računu, pa ga koriste i obavijesti, e-mailovi, računi i PDF izvještaji.
Cijene u meniju uključuju PDV od 17%; na računu su prikazani osnovica i PDV.

---

## Struktura projekta

```
backend/
  Servio.API/        REST API, SignalR hub (uživo ažuriranja i obavijesti), autentifikacija, Swagger (Development)
  Servio.Services/   poslovna logika, EF Core, migracije, seed podaci, sistem preporuke, PayPal, PDF izvještaji, prijevodi
  Servio.Model/      requestovi, responsovi, enumi, search objekti
  Servio.Worker/     zaseban servis: čita e-mail poruke iz RabbitMQ-a i šalje ih preko SMTP-a
frontend/
  servio_shared/     API klijent, modeli, provideri, tema, prijevodi (lib/l10n) – koriste ga obje aplikacije
  servio_mobile/     aplikacija za konobare (Android)
  servio_desktop/    aplikacija za kuhinju, šank i administraciju (Windows / macOS)
docs/database-design.md      dijagram i tabele baze podataka
recommender-dokumentacija.md opis sistema preporuke
docker-compose.yml           svi backend servisi
.env-tajne.zip               konfiguracijska datoteka .env (zaštićena šifrom)
```

## Rješavanje problema

| Problem | Rješenje |
|---|---|
| Aplikacija javlja da ne može dohvatiti server | Provjerite da `docker compose ps` prikazuje `servio-api` kao Up i da aplikacija koristi ispravnu adresu (`10.0.2.2` u Android emulatoru, `localhost` na desktopu). |
| Port je već zauzet | Promijenite `API_PORT` ili `DB_HOST_PORT` u `.env`, a novi port API-ja proslijedite sa `--dart-define`. Port 5000 se ne koristi jer ga macOS koristi za AirPlay. |
| PayPal stranica se ne učitava u emulatoru | Emulator treba pristup internetu; PayPal sandbox radi na `sandbox.paypal.com`. |
| E-mailovi ne stižu | Provjerite SMTP vrijednosti u `.env` i `docker compose logs servio-worker`. |
| U logu `servio-api` pri prvom pokretanju piše `Failed executing DbCommand ... __EFMigrationsHistory` | Očekivano: EF Core prvo provjerava tabelu migracija koja na praznoj bazi još ne postoji, zatim je kreira i primjenjuje migracije. Log nakon toga završava sa `Database seeded`. |
| Ponovni početak sa svježim demo podacima | `docker compose down -v` pa `docker compose up -d --build`. |
