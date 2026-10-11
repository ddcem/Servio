// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'servio_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class ServioLocalizationsBs extends ServioLocalizations {
  ServioLocalizationsBs([String locale = 'bs']) : super(locale);

  @override
  String get assignWaiters => 'Dodijeli konobare';

  @override
  String get tableAssignments => 'Raspored stolova';

  @override
  String get tableAssignmentsSubtitle =>
      'Prevucite svaki sto konobaru koji ga poslužuje u ovoj smjeni';

  @override
  String get unassigned => 'Nedodijeljeno';

  @override
  String get unassignedHint => 'Ove stolove može posluživati bilo koji konobar';

  @override
  String tableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stolova',
      few: '$count stola',
      one: '$count sto',
    );
    return '$_temp0';
  }

  @override
  String tablesAndSeats(String tables, String seats) {
    return '$tables · $seats';
  }

  @override
  String get dropTablesHere => 'Ispustite stolove ovdje';

  @override
  String get moveTo => 'Premjesti kod…';

  @override
  String addAllOfArea(String area) {
    return 'Dodaj sve: $area';
  }

  @override
  String get unassignAll => 'Ukloni sve';

  @override
  String get columnMenu => 'Akcije kolone';

  @override
  String get clearAllAssignments => 'Obriši raspored';

  @override
  String get clearAllQuestion => 'Obrisati cijeli raspored?';

  @override
  String get clearAllMessage =>
      'Svi stolovi postaju slobodni za sve konobare. Otvorene narudžbe ostaju kod svojih konobara.';

  @override
  String assignmentMoved(int number, String waiter) {
    return 'Sto $number → $waiter';
  }

  @override
  String tablesMoved(String tables, String waiter) {
    return '$tables → $waiter';
  }

  @override
  String assignmentFreed(int number) {
    return 'Sto $number je slobodan za sve konobare.';
  }

  @override
  String get planCleared =>
      'Raspored je obrisan. Svaki konobar može posluživati svaki sto.';

  @override
  String get noActiveWaiters =>
      'Nema aktivnih konobara. Dodajte ih u Uposlenici.';

  @override
  String get openOrderMovesHint =>
      'Sto s otvorenom narudžbom prelazi zajedno s narudžbom.';

  @override
  String get myTables => 'Moji stolovi';

  @override
  String get allTables => 'Svi stolovi';

  @override
  String get yourTable => 'Vaš sto';

  @override
  String tableServedBy(int number, String name) {
    return 'Sto $number poslužuje $name. Zamolite administratora da ga dodijeli vama ako ga trebate preuzeti.';
  }

  @override
  String get noTablesAssignedToYou =>
      'Trenutno vam nije dodijeljen nijedan sto. Obratite se administratoru ili prikažite sve stolove.';

  @override
  String get menuManagement => 'Upravljanje menijem';

  @override
  String get employees => 'Uposlenici';

  @override
  String get tables => 'Stolovi';

  @override
  String get reservations => 'Rezervacije';

  @override
  String get ordersAndPayments => 'Narudžbe i plaćanja';

  @override
  String get referenceData => 'Šifarnici';

  @override
  String get reports => 'Izvještaji';

  @override
  String notificationLine(String title, String body) {
    return '$title: $body';
  }

  @override
  String get adminPanel => 'Administracija';

  @override
  String get systemManagement => 'Upravljanje sistemom';

  @override
  String get backToDashboard => 'Nazad na početnu';

  @override
  String loggedInAs(String role) {
    return 'Prijavljeni kao: $role';
  }

  @override
  String get edit => 'Uredi';

  @override
  String get delete => 'Obriši';

  @override
  String get cancel => 'Otkaži';

  @override
  String get active => 'Aktivan';

  @override
  String get inactive => 'Neaktivan';

  @override
  String get role => 'Uloga';

  @override
  String get name => 'Naziv';

  @override
  String get price => 'Cijena';

  @override
  String get category => 'Kategorija';

  @override
  String get area => 'Prostor';

  @override
  String get open => 'Otvoreno';

  @override
  String get from => 'Od';

  @override
  String get to => 'Do';

  @override
  String get anyDate => 'Bilo koji datum';

  @override
  String dateRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get clearDates => 'Obriši datume';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Ne';

  @override
  String get show => 'Prikaži';

  @override
  String get read => 'Pročitano';

  @override
  String get markAsRead => 'Označi kao pročitano';

  @override
  String get tag => 'Oznaka';

  @override
  String get tags => 'Oznake';

  @override
  String get tagHint => 'npr. Ljuto';

  @override
  String get areaHint => 'npr. Bašta';

  @override
  String get items => 'Artikli';

  @override
  String get payments => 'Plaćanja';

  @override
  String get history => 'Historija';

  @override
  String get phone => 'Telefon';

  @override
  String get date => 'Datum';

  @override
  String get note => 'Napomena';

  @override
  String get refund => 'Povrat';

  @override
  String get print => 'Štampaj';

  @override
  String deleteNameQuestion(String name) {
    return 'Obrisati: $name?';
  }

  @override
  String get accountRemovedPermanently =>
      'Račun se trajno briše. Ovo se ne može poništiti.';

  @override
  String accountDeleted(String name) {
    return 'Račun korisnika $name je obrisan.';
  }

  @override
  String get employeeManagement => 'Upravljanje uposlenicima';

  @override
  String get manageStaff => 'Upravljajte osobljem';

  @override
  String get addEmployee => 'Dodaj uposlenika';

  @override
  String get searchEmployees =>
      'Pretraga po imenu, korisničkom imenu ili emailu';

  @override
  String get noEmployeesMatch => 'Nijedan uposlenik ne odgovara filterima.';

  @override
  String usernameAndEmail(String username, String email) {
    return '@$username · $email';
  }

  @override
  String get neverLoggedIn => 'Nikad se nije prijavio';

  @override
  String lastLogin(String time) {
    return 'Posljednja prijava $time';
  }

  @override
  String get deleteEmployee => 'Obriši uposlenika';

  @override
  String get cannotDeleteOwnAccount => 'Ne možete obrisati vlastiti račun.';

  @override
  String get employeeHasActivity =>
      'Ima narudžbe, rezervacije ili plaćanja u sistemu. Umjesto toga deaktivirajte račun.';

  @override
  String get editEmployee => 'Uredi uposlenika';

  @override
  String get addEmployeeTitle => 'Dodaj uposlenika';

  @override
  String accountUpdated(String name) {
    return 'Račun korisnika $name je ažuriran.';
  }

  @override
  String employeeAdded(String name, String role) {
    return '$name je dodan/a s ulogom „$role“.';
  }

  @override
  String get usernameHelper => 'Koristi se za prijavu, npr. marko.markovic';

  @override
  String get emailHint => 'ime@primjer.com';

  @override
  String get cannotChangeOwnRole => 'Ne možete promijeniti vlastitu ulogu';

  @override
  String get roleHelper =>
      'Uloga određuje koju aplikaciju i ekrane uposlenik može koristiti';

  @override
  String get roleRequired => 'Uloga je obavezna.';

  @override
  String get cannotDeactivateOwnAccount =>
      'Ne možete deaktivirati vlastiti račun';

  @override
  String get inactiveCannotLogIn => 'Neaktivni uposlenici se ne mogu prijaviti';

  @override
  String get loggedOutEverywhere =>
      'Uposlenik se nakon promjene odjavljuje na svim uređajima';

  @override
  String get repeatPassword => 'Ponovite lozinku';

  @override
  String get images => 'Slike';

  @override
  String get imageTooLarge =>
      'Slika je veća od 2 MB. Odaberite manju JPEG, PNG ili WebP sliku.';

  @override
  String savedButImageFailed(String name, String error) {
    return '„$name“ je spremljeno, ali slika nije: $error';
  }

  @override
  String itemUpdated(String name) {
    return '„$name“ je ažurirano.';
  }

  @override
  String itemAddedToMenu(String name) {
    return '„$name“ je dodano u meni.';
  }

  @override
  String get editMenuItem => 'Uredi artikal';

  @override
  String get addMenuItem => 'Dodaj artikal';

  @override
  String get changeImage => 'Promijeni';

  @override
  String get addImage => 'Dodaj sliku';

  @override
  String get nameHintDish => 'npr. Ćevapi';

  @override
  String get descriptionOptional => 'Opis (opcionalno)';

  @override
  String get descriptionHint => 'npr. 10 komada u somunu s lukom';

  @override
  String get description => 'Opis';

  @override
  String categoryWithStation(String name, String station) {
    return '$name ($station)';
  }

  @override
  String get categoryRequired => 'Kategorija je obavezna.';

  @override
  String get addNewCategory => 'Dodaj novu kategoriju';

  @override
  String get newTag => 'Nova oznaka';

  @override
  String get availableToday => 'Danas dostupno';

  @override
  String get unavailableHidden =>
      'Nedostupni artikli su sakriveni iz menija konobara';

  @override
  String addEntity(String entity) {
    return 'Dodaj: $entity';
  }

  @override
  String editEntity(String entity) {
    return 'Uredi: $entity';
  }

  @override
  String entityAdded(String entity, String name) {
    return '$entity „$name“ – dodano.';
  }

  @override
  String entityUpdated(String entity, String name) {
    return '$entity „$name“ – ažurirano.';
  }

  @override
  String get editCategory => 'Uredi kategoriju';

  @override
  String get addCategory => 'Dodaj kategoriju';

  @override
  String categoryAdded(String name) {
    return 'Kategorija „$name“ je dodana.';
  }

  @override
  String categoryUpdated(String name) {
    return 'Kategorija „$name“ je ažurirana.';
  }

  @override
  String get categoryNameHint => 'npr. Glavna jela';

  @override
  String get courseType => 'Vrsta jela';

  @override
  String get courseTypeHelper =>
      'Sistem preporuka koristi ovo za upotpunjavanje obroka';

  @override
  String get courseTypeRequired => 'Vrsta jela je obavezna.';

  @override
  String get preparedAt => 'Priprema se u';

  @override
  String get preparedAtHelper =>
      'Artikli ove kategorije šalju se na ovo mjesto pripreme';

  @override
  String get stationRequired => 'Mjesto pripreme je obavezno.';

  @override
  String get sortOrder => 'Redoslijed';

  @override
  String get sortOrderHelper => 'Manji brojevi se prikazuju prvi u meniju';

  @override
  String get editCurrency => 'Uredi valutu';

  @override
  String get addCurrency => 'Dodaj valutu';

  @override
  String currencyAdded(String code) {
    return 'Valuta $code je dodana.';
  }

  @override
  String currencyUpdated(String code) {
    return 'Valuta $code je ažurirana.';
  }

  @override
  String get code => 'Kod';

  @override
  String get codeHint => 'npr. BAM';

  @override
  String get codeLocked =>
      'Kod se ne može mijenjati dok ovu valutu koriste narudžbe ili postavke';

  @override
  String get currencyCodeInvalid =>
      'Kod valute mora imati tačno 3 velika slova (ISO 4217), npr. BAM.';

  @override
  String get currencyNameHint => 'npr. Konvertibilna marka';

  @override
  String get symbol => 'Simbol';

  @override
  String get reservationDate => 'Datum rezervacije';

  @override
  String get arrivalTime => 'Vrijeme dolaska';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get startMustBeFuture => 'Vrijeme početka mora biti u budućnosti.';

  @override
  String get editReservation => 'Uredi rezervaciju';

  @override
  String get newReservation => 'Nova rezervacija';

  @override
  String reservationUpdated(String name) {
    return 'Rezervacija za $name je ažurirana.';
  }

  @override
  String reservationCreated(String name, int table, String time) {
    return 'Rezervacija za $name za stolom $table u $time je kreirana. Potvrdite je da gost dobije obavijest.';
  }

  @override
  String get guestName => 'Ime gosta';

  @override
  String get guests => 'Broj osoba';

  @override
  String get partySize => 'Broj osoba';

  @override
  String get emailOptional => 'Email (opcionalno)';

  @override
  String get guestGetsEmail => 'Gost dobija email s potvrdom';

  @override
  String get duration => 'Trajanje';

  @override
  String get tableChecksHelper =>
      'Preklapanja rezervacija i kapacitet provjeravaju se pri spremanju';

  @override
  String tableOption(int number, String seats, String area) {
    return 'Sto $number · $seats · $area';
  }

  @override
  String get tableRequired => 'Sto je obavezan.';

  @override
  String get noteOptional => 'Napomena (opcionalno)';

  @override
  String get reservationNoteHint => 'npr. Rođendan, potrebna dječja stolica';

  @override
  String editTable(int number) {
    return 'Uredi sto $number';
  }

  @override
  String get addTable => 'Dodaj sto';

  @override
  String tableAdded(int number, String seats, String area) {
    return 'Sto $number ($seats, $area) je dodan.';
  }

  @override
  String tableUpdated(int number, String seats, String area) {
    return 'Sto $number ($seats, $area) je ažuriran.';
  }

  @override
  String get tableNumberLabel => 'Broj stola';

  @override
  String get number => 'Broj';

  @override
  String get seats => 'Mjesta';

  @override
  String get capacity => 'Kapacitet';

  @override
  String get areaRequired => 'Prostor je obavezan.';

  @override
  String get addNewArea => 'Dodaj novi prostor';

  @override
  String get inUse => 'U upotrebi';

  @override
  String get notInUseHelper =>
      'Za stolove koji nisu u upotrebi ne mogu se primati narudžbe ni rezervacije';

  @override
  String availableAgain(String name) {
    return '$name je danas ponovo dostupno.';
  }

  @override
  String nowHidden(String name) {
    return '$name je sada sakriveno iz menija konobara.';
  }

  @override
  String removeItemQuestion(String name) {
    return 'Ukloniti „$name“?';
  }

  @override
  String get removeItemMessage =>
      'Artikal nestaje iz menija. Prethodne narudžbe ga zadržavaju, pa izvještaji o prodaji ostaju tačni.';

  @override
  String itemRemoved(String name) {
    return '„$name“ je uklonjeno iz menija.';
  }

  @override
  String get manageMenuSubtitle => 'Upravljajte artiklima i dostupnošću';

  @override
  String get addCategoryFirst =>
      'Prvo dodajte kategoriju menija (Šifarnici → Kategorije).';

  @override
  String get addItem => 'Dodaj artikal';

  @override
  String get unavailable => 'Nedostupno';

  @override
  String get availableLabel => 'Dostupno';

  @override
  String get noMenuItemsMatch => 'Nijedan artikal ne odgovara filterima.';

  @override
  String get columnItem => 'ARTIKAL';

  @override
  String get columnCategory => 'KATEGORIJA';

  @override
  String get columnPrice => 'CIJENA';

  @override
  String get columnType => 'VRSTA';

  @override
  String get columnOrderNumber => 'NARUDŽBA';

  @override
  String get columnOpened => 'OTVORENA';

  @override
  String get columnTotal => 'UKUPNO';

  @override
  String get food => 'hrana';

  @override
  String get drinkWord => 'piće';

  @override
  String get columnAvailableToday => 'DANAS DOSTUPNO';

  @override
  String get columnActions => 'AKCIJE';

  @override
  String get removeFromMenu => 'Ukloni iz menija';

  @override
  String get allMarkedRead => 'Sve obavijesti su označene kao pročitane.';

  @override
  String get youAreAllCaughtUp => 'Sve je pročitano';

  @override
  String get ordersOpenedBetween => 'Narudžbe otvorene između';

  @override
  String get ordersSubtitle =>
      'Svaki račun s artiklima, bonovima za kuhinju/šank, plaćanjima i povratima';

  @override
  String get orderNumberOrTable => 'Broj narudžbe ili stola';

  @override
  String get noOrdersMatch => 'Nijedna narudžba ne odgovara filterima.';

  @override
  String cancelOrderNumber(String order) {
    return 'Otkaži narudžbu $order';
  }

  @override
  String get cancelOrderTicketsMessage =>
      'Bonovi koji nisu započeti se otkazuju, a kuhinja i šank dobijaju obavijest.';

  @override
  String orderCancelledFor(String order, int table) {
    return 'Narudžba $order za sto $table je otkazana.';
  }

  @override
  String orderNumberTitle(String order) {
    return 'Narudžba $order';
  }

  @override
  String orderDetailsLine(
    int table,
    String guests,
    String waiter,
    String time,
  ) {
    return 'Sto $table · $guests · $waiter · otvoreno $time';
  }

  @override
  String cancelledReason(String reason) {
    return 'Otkazano: $reason';
  }

  @override
  String get kitchenAndBarTickets => 'Bonovi za kuhinju i šank';

  @override
  String ticketLine(String ticket, String station, String status) {
    return '$ticket · $station · $status';
  }

  @override
  String get noPaymentsYet => 'Još nema plaćanja.';

  @override
  String paymentLine(String method, String amount) {
    return '$method · $amount';
  }

  @override
  String paymentLineWithTip(String method, String amount, String tip) {
    return '$method · $amount (uklj. napojnicu $tip)';
  }

  @override
  String refundUpTo(String amount) {
    return 'Povrat do $amount';
  }

  @override
  String get nothingToRefund => 'Na ovom plaćanju više nema ništa za vratiti.';

  @override
  String paymentProcessedLine(String name, String time) {
    return '$name · $time';
  }

  @override
  String cashReceivedLine(String received, String change) {
    return ' · primljeno $received, kusur $change';
  }

  @override
  String refundedLine(String amount, String name, String time, String reason) {
    return '↩ $amount vratio/la $name, $time – $reason';
  }

  @override
  String get orderMustBePaid =>
      'Artikli se već pripremaju ili su posluženi, pa se narudžba mora platiti.';

  @override
  String get refundPayment => 'Povrat plaćanja';

  @override
  String refundAmountQuestion(String amount) {
    return 'Vratiti $amount?';
  }

  @override
  String get refundPayPalMessage =>
      'Novac se vraća na gostov PayPal račun. Ovo se ne može poništiti.';

  @override
  String get refundCashMessage =>
      'Vratite gotovinu gostu. Ovo se ne može poništiti.';

  @override
  String refundCompleted(String amount, String order) {
    return 'Povrat od $amount za narudžbu $order je izvršen.';
  }

  @override
  String refundIntro(String method, String amount, String refundable) {
    return 'Plaćanje ($method) od $amount. Može se vratiti još do $refundable.';
  }

  @override
  String atMost(String amount) {
    return 'Najviše $amount';
  }

  @override
  String get refundAmount => 'Iznos povrata';

  @override
  String get refundReasonHint => 'npr. Odrezak je bio prepečen';

  @override
  String get referenceDataSubtitle =>
      'Liste koje koriste meni, stolovi i plaćanja';

  @override
  String get menuCategories => 'Kategorije menija';

  @override
  String get itemTags => 'Oznake artikala';

  @override
  String get tableAreas => 'Prostori';

  @override
  String get currencies => 'Valute';

  @override
  String get systemLists => 'Sistemske liste';

  @override
  String get searchCategories => 'Pretraži kategorije';

  @override
  String get columnName => 'NAZIV';

  @override
  String get columnCourse => 'VRSTA';

  @override
  String get columnPreparedAt => 'PRIPREMA';

  @override
  String get columnOrder => 'REDOSLIJED';

  @override
  String get columnItems => 'ARTIKLI';

  @override
  String categoryInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artikala',
      few: '$count artikla',
      one: '$count artikal',
    );
    return 'Koristi $_temp0, uključujući uklonjene artikle sačuvane zbog historije narudžbi.';
  }

  @override
  String get searchTags => 'Pretraži oznake';

  @override
  String get columnMenuItems => 'ARTIKLI';

  @override
  String tagInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artikala',
      few: '$count artikla',
      one: '$count artikal',
    );
    return 'Koristi $_temp0. Prvo je uklonite s tih artikala.';
  }

  @override
  String get searchAreas => 'Pretraži prostore';

  @override
  String get columnTables => 'STOLOVI';

  @override
  String areaInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stolova',
      few: '$count stola',
      one: '$count sto',
    );
    return 'Ima $_temp0. Prvo ih premjestite ili obrišite.';
  }

  @override
  String get searchCurrencies => 'Pretraži valute';

  @override
  String get columnCode => 'KOD';

  @override
  String get columnSymbol => 'SIMBOL';

  @override
  String get columnInUse => 'U UPOTREBI';

  @override
  String get currencyInUse =>
      'Koriste je postavke restorana ili postojeće narudžbe.';

  @override
  String deleteQuestion(String name) {
    return 'Obrisati „$name“?';
  }

  @override
  String get removedPermanently => 'Trajno se briše.';

  @override
  String entityDeleted(String name) {
    return '„$name“ je obrisano.';
  }

  @override
  String get nothingFound => 'Ništa nije pronađeno.';

  @override
  String get systemListsInfo =>
      'Ove liste su fiksne. Uloge određuju šta svaki uposlenik smije raditi, mjesta pripreme određuju gdje se šalju narudžbe, a načini plaćanja su vezani za gotovinsko i PayPal plaćanje, pa bi preimenovanje ili brisanje pokvarilo te funkcije.';

  @override
  String get roles => 'Uloge';

  @override
  String get preparationStations => 'Mjesta pripreme';

  @override
  String get paymentMethods => 'Načini plaćanja';

  @override
  String get entityCategory => 'Kategorija';

  @override
  String get entityTag => 'Oznaka';

  @override
  String get entityArea => 'Prostor';

  @override
  String get entityCurrency => 'Valuta';

  @override
  String get addCategoryButton => 'Dodaj kategoriju';

  @override
  String get addTagButton => 'Dodaj oznaku';

  @override
  String get addAreaButton => 'Dodaj prostor';

  @override
  String get addCurrencyButton => 'Dodaj valutu';

  @override
  String get reportPeriod => 'Period izvještaja';

  @override
  String reportSaved(String path) {
    return 'Izvještaj je spremljen u $path.';
  }

  @override
  String reportSaveFailed(String error) {
    return 'Izvještaj nije moguće spremiti: $error';
  }

  @override
  String get salesAndAnalytics => 'Prodaja i analitika';

  @override
  String get salesSubtitle => 'Pratite učinak i prihode';

  @override
  String get salesReport => 'Izvještaj o prodaji';

  @override
  String get staffReport => 'Izvještaj o osoblju';

  @override
  String get periodAnalysis => 'Analiza perioda';

  @override
  String lastDays(int count) {
    return 'Posljednjih $count dana';
  }

  @override
  String sameAs(String when) {
    return 'Isto kao $when';
  }

  @override
  String firstSalesComparedTo(String when) {
    return 'Prva prodaja u odnosu na $when';
  }

  @override
  String percentFrom(String change, String when) {
    return '$change% u odnosu na $when';
  }

  @override
  String get yesterday => 'jučer';

  @override
  String get todaysRevenue => 'Današnji prihod';

  @override
  String get kpiGuests => 'Gosti';

  @override
  String get paidOrders => 'Plaćene narudžbe';

  @override
  String activeNow(int count) {
    return 'trenutno aktivnih: $count';
  }

  @override
  String get averageBill => 'Prosječan račun';

  @override
  String tablesServed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count usluženih stolova',
      few: '$count uslužena stola',
      one: '$count usluženi sto',
    );
    return '$_temp0';
  }

  @override
  String get popularItemsToday => 'Današnji najpopularniji artikli';

  @override
  String get noSalesToday => 'Danas još nema prodaje.';

  @override
  String get revenue => 'Prihod';

  @override
  String get netRevenueAfterRefunds => 'Neto prihod (nakon povrata)';

  @override
  String get tips => 'Napojnice';

  @override
  String get refunds => 'Povrati';

  @override
  String get cancelledOrders => 'Otkazane narudžbe';

  @override
  String get dailyRevenue => 'Dnevni prihod';

  @override
  String get bestSellingItems => 'Najprodavaniji artikli';

  @override
  String get leastSellingItems => 'Najmanje prodavani artikli';

  @override
  String get promotionCandidates => 'Kandidati za akciju ili uklanjanje';

  @override
  String get salesByCategory => 'Prodaja po kategorijama';

  @override
  String soldAndRevenue(int count, String revenue) {
    return 'prodano: $count · $revenue';
  }

  @override
  String get paymentsByMethod => 'Plaćanja po načinu';

  @override
  String paymentsAndAmount(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plaćanja',
      few: '$count plaćanja',
      one: '$count plaćanje',
    );
    return '$_temp0 · $amount';
  }

  @override
  String get staffPerformance => 'Učinak osoblja';

  @override
  String get columnWaiter => 'KONOBAR';

  @override
  String get columnOrders => 'NARUDŽBE';

  @override
  String get columnRevenue => 'PRIHOD';

  @override
  String get columnAvgBill => 'PROSJ. RAČUN';

  @override
  String get columnTips => 'NAPOJNICE';

  @override
  String get columnSuggestionsAccepted => 'PRIHVAĆENI PRIJEDLOZI';

  @override
  String nameInactive(String name) {
    return '$name (neaktivan)';
  }

  @override
  String percentOf(String percent, int total) {
    return '$percent od $total';
  }

  @override
  String stationTickets(String station, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bonova',
      few: '$count bona',
      one: '$count bon',
    );
    return '$station: $_temp0';
  }

  @override
  String minutesToReady(String minutes) {
    return '$minutes min do spremnosti';
  }

  @override
  String reportPdfTooltip(String label) {
    return '$label (PDF) za odabrani period';
  }

  @override
  String get saveAsPdf => 'Spremi kao PDF';

  @override
  String soldAndCategory(int count, String category) {
    return 'prodano: $count · $category';
  }

  @override
  String chartTooltip(String date, String amount, String orders) {
    return '$date\n$amount · $orders';
  }

  @override
  String orderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count narudžbi',
      few: '$count narudžbe',
      one: '$count narudžba',
    );
    return '$_temp0';
  }

  @override
  String get reservationsBetween => 'Rezervacije između';

  @override
  String get cancelReservation => 'Otkaži rezervaciju';

  @override
  String cancelReservationMessage(String name, String time) {
    return 'Otkazati rezervaciju za $name u $time? Konobari dobijaju obavijest.';
  }

  @override
  String cancelReservationEmailMessage(String name, String time) {
    return 'Otkazati rezervaciju za $name u $time? Gost dobija email, a konobari obavijest.';
  }

  @override
  String reservationCancelledFor(String name) {
    return 'Rezervacija za $name je otkazana.';
  }

  @override
  String get reservationsSubtitle =>
      'Rezervišite stolove i pratite status svake rezervacije';

  @override
  String get newReservationButton => 'Nova rezervacija';

  @override
  String get guestNameOrPhone => 'Ime ili telefon gosta';

  @override
  String get noReservationsMatch =>
      'Nijedna rezervacija ne odgovara filterima.';

  @override
  String get columnGuest => 'GOST';

  @override
  String get columnWhen => 'TERMIN';

  @override
  String get columnTable => 'STO';

  @override
  String get columnGuests => 'OSOBA';

  @override
  String get columnStatus => 'STATUS';

  @override
  String timeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get confirmEmailsGuest => 'Potvrdi (gost dobija email)';

  @override
  String reservationConfirmedFor(String name) {
    return 'Rezervacija za $name je potvrđena.';
  }

  @override
  String get guestsArrived => 'Gosti su stigli';

  @override
  String get arrivedTooEarly =>
      'Gosti se mogu označiti kao pristigli od 30 minuta prije rezervacije.';

  @override
  String guestArrived(String name) {
    return '$name je stigao/la; rezervacija je završena.';
  }

  @override
  String get noShow => 'Nije došao';

  @override
  String get noShowTooEarly =>
      'Nedolazak se može evidentirati 15 minuta nakon početka rezervacije.';

  @override
  String markedNoShow(String name) {
    return '$name je označen/a kao da nije došao/la.';
  }

  @override
  String tableAndGuests(int table, String guests) {
    return 'Sto $table · $guests';
  }

  @override
  String createdByOn(String name, String time) {
    return 'Kreirao/la $name, $time';
  }

  @override
  String createdAs(String status) {
    return 'Kreirano sa statusom „$status“';
  }

  @override
  String statusChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get saveSettingsQuestion => 'Spremiti postavke?';

  @override
  String get saveSettingsMessage =>
      'Nove narudžbe koriste novu stopu PDV-a i valutu. Otvorene narudžbe zadržavaju vrijednosti s kojima su otvorene.';

  @override
  String get saveSettings => 'Spremi postavke';

  @override
  String settingsSaved(String name, String currency, String rate) {
    return 'Postavke spremljene: $name, $currency, PDV $rate%.';
  }

  @override
  String get systemSettings => 'Postavke sistema';

  @override
  String get configurePreferences => 'Podesite postavke restorana';

  @override
  String get generalSettings => 'Opće postavke';

  @override
  String get restaurantName => 'Naziv restorana';

  @override
  String get currency => 'Valuta';

  @override
  String get currencyHelper => 'PayPal plaćanja se naplaćuju u ovoj valuti';

  @override
  String currencyOption(String code, String symbol, String name) {
    return '$code ($symbol) – $name';
  }

  @override
  String get currencyRequired => 'Valuta je obavezna.';

  @override
  String get addNewCurrency => 'Dodaj novu valutu';

  @override
  String get vatRatePercent => 'Stopa PDV-a (%)';

  @override
  String get vatRateHelper =>
      'Uključen u cijene; računi prikazuju koliki dio ukupnog iznosa je PDV';

  @override
  String get vatRate => 'Stopa PDV-a';

  @override
  String lastChanged(String time) {
    return 'Posljednja izmjena $time';
  }

  @override
  String lastChangedBy(String time, String name) {
    return 'Posljednja izmjena $time, $name';
  }

  @override
  String get myPreferences => 'Moje postavke';

  @override
  String get myPreferencesHint =>
      'Samo za vaš račun. Obavijesti i PDF izvještaji također koriste ovaj jezik.';

  @override
  String deleteTableQuestion(int number) {
    return 'Obrisati sto $number?';
  }

  @override
  String get tableRemovedPermanently => 'Sto se trajno briše.';

  @override
  String tableDeleted(int number) {
    return 'Sto $number je obrisan.';
  }

  @override
  String get tablesSubtitle => 'Raspored stolova sa statusom uživo';

  @override
  String get addAreaFirst => 'Prvo dodajte prostor (Šifarnici → Prostori).';

  @override
  String get addTableButton => 'Dodaj sto';

  @override
  String get noTablesMatch => 'Nijedan sto ne odgovara filterima.';

  @override
  String get columnArea => 'PROSTOR';

  @override
  String get columnSeats => 'MJESTA';

  @override
  String get columnCurrentBill => 'TRENUTNI RAČUN';

  @override
  String get columnNextReservation => 'SLJEDEĆA REZERVACIJA';

  @override
  String tableNotInUse(int number) {
    return 'Sto $number (nije u upotrebi)';
  }

  @override
  String billAndGuests(String amount, String guests) {
    return '$amount · $guests';
  }

  @override
  String reservationTimeAndGuest(String time, String name) {
    return '$time · $name';
  }

  @override
  String get deleteTable => 'Obriši sto';

  @override
  String get tableHasHistory =>
      'Sto ima narudžbe ili rezervacije u historiji. Umjesto toga ga označite da nije u upotrebi.';

  @override
  String get adminDashboard => 'Administratorska ploča';

  @override
  String get chooseView => 'Odaberite šta želite pregledati';

  @override
  String get kitchenView => 'Pregled kuhinje';

  @override
  String get monitorFood => 'Pratite narudžbe hrane';

  @override
  String get barView => 'Pregled šanka';

  @override
  String get monitorDrinks => 'Pratite narudžbe pića';

  @override
  String get manageSystem => 'Upravljajte sistemom';

  @override
  String get staffLogin => 'Prijava osoblja';

  @override
  String get demoAccounts => 'Demo računi (lozinka: test)';

  @override
  String get demoDesktop => '• desktop – administracija';

  @override
  String get demoKitchen => '• kitchen – ekran kuhinje';

  @override
  String get demoBar => '• bar – ekran šanka';

  @override
  String ticketBeingPrepared(String ticket, int table) {
    return 'Bon $ticket za sto $table je u pripremi.';
  }

  @override
  String ticketReadyNotified(String ticket, String waiter) {
    return 'Bon $ticket je spreman. $waiter je dobio/la obavijest.';
  }

  @override
  String get kitchenDisplay => 'Ekran kuhinje';

  @override
  String get barDisplay => 'Ekran šanka';

  @override
  String activeOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktivnih narudžbi',
      few: '$count aktivne narudžbe',
      one: '$count aktivna narudžba',
    );
    return '$_temp0';
  }

  @override
  String get viewOnly => 'Samo pregled';

  @override
  String get noPendingFood => 'Nema narudžbi hrane na čekanju';

  @override
  String get noPendingDrinks => 'Nema narudžbi pića na čekanju';

  @override
  String ticketTitle(String ticket) {
    return 'Narudžba $ticket';
  }

  @override
  String quantityPrefix(int quantity) {
    return 'x$quantity';
  }

  @override
  String get startPreparing => 'Započni pripremu';

  @override
  String get markAsReady => 'Označi spremnim';

  @override
  String get completeOrder => 'Završi narudžbu';

  @override
  String get summaryNew => 'Novo';

  @override
  String get summaryPreparing => 'U pripremi';

  @override
  String get longestWait => 'Najduže čekanje';

  @override
  String get avgTimeToReadyToday => 'Prosj. vrijeme pripreme danas';

  @override
  String minutesValue(String minutes) {
    return '$minutes min';
  }

  @override
  String get completedToday => 'Danas završeno';

  @override
  String roleStaff(String role) {
    return 'Osoblje: $role';
  }

  @override
  String get backToDashboardShort => 'Nazad na početnu';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rezultata',
      few: '$count rezultata',
      one: '$count rezultat',
    );
    return '$_temp0';
  }

  @override
  String get previousPage => 'Prethodna stranica';

  @override
  String pageOf(int page, int pages) {
    return 'Stranica $page od $pages';
  }

  @override
  String get nextPage => 'Sljedeća stranica';

  @override
  String get table => 'Sto';

  @override
  String tableNumber(int number) {
    return 'Sto $number';
  }

  @override
  String tableAndOrder(int number, String order) {
    return 'Sto $number · $order';
  }

  @override
  String guestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gostiju',
      few: '$count gosta',
      one: '$count gost',
    );
    return '$_temp0';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artikala',
      few: '$count artikla',
      one: '$count artikal',
    );
    return '$_temp0';
  }

  @override
  String get total => 'Ukupno';

  @override
  String get payment => 'Plaćanje';

  @override
  String get paid => 'Plaćeno';

  @override
  String get cancelled => 'Otkazano';

  @override
  String get status => 'Status';

  @override
  String get save => 'Spremi';

  @override
  String get close => 'Zatvori';

  @override
  String get more => 'Više';

  @override
  String get loadMore => 'Učitaj još';

  @override
  String get logout => 'Odjava';

  @override
  String get logoutQuestion => 'Želite li se odjaviti?';

  @override
  String get email => 'Email';

  @override
  String get username => 'Korisničko ime';

  @override
  String get password => 'Lozinka';

  @override
  String get showPassword => 'Prikaži lozinku';

  @override
  String get hidePassword => 'Sakrij lozinku';

  @override
  String get login => 'Prijava';

  @override
  String get enterCredentials => 'Unesite podatke za prijavu';

  @override
  String get notifications => 'Obavijesti';

  @override
  String get settings => 'Postavke';

  @override
  String get account => 'Korisnički račun';

  @override
  String get help => 'Pomoć';

  @override
  String get languageHint =>
      'Obavijesti, emailovi i računi također koriste ovaj jezik.';

  @override
  String get payPal => 'PayPal';

  @override
  String get receipt => 'Račun';

  @override
  String get done => 'Gotovo';

  @override
  String get change => 'Kusur';

  @override
  String get amount => 'Iznos';

  @override
  String get tip => 'Napojnica';

  @override
  String tipPercent(String percent) {
    return 'Napojnica ($percent%)';
  }

  @override
  String get cashReceived => 'Primljena gotovina';

  @override
  String reasonText(String reason) {
    return 'Razlog: $reason';
  }

  @override
  String quantityTimesPrice(String price, int quantity) {
    return '$price × $quantity';
  }

  @override
  String itemTimesQuantity(String name, int quantity) {
    return '$name × $quantity';
  }

  @override
  String get passwordChangedLogIn =>
      'Lozinka je promijenjena. Sada se možete prijaviti.';

  @override
  String get resetPassword => 'Resetovanje lozinke';

  @override
  String get resetEnterCode =>
      'Unesite kod iz emaila i odaberite novu lozinku.';

  @override
  String get resetEnterEmail =>
      'Unesite email adresu svog računa. Poslat ćemo vam šestocifreni kod.';

  @override
  String get resetCode => 'Kod za resetovanje';

  @override
  String get resetCodeInvalid => 'Kod za resetovanje ima 6 cifara.';

  @override
  String get newPassword => 'Nova lozinka';

  @override
  String get passwordHint => 'Najmanje 8 znakova, sa slovom i brojem';

  @override
  String get repeatNewPassword => 'Ponovite novu lozinku';

  @override
  String get changePassword => 'Promijeni lozinku';

  @override
  String get sendCode => 'Pošalji kod';

  @override
  String get sendNewCode => 'Pošalji novi kod';

  @override
  String get forgotPassword => 'Zaboravljena lozinka?';

  @override
  String get currentPassword => 'Trenutna lozinka';

  @override
  String get waiterLogin => 'Prijava konobara';

  @override
  String get demoAccount => 'Demo račun: ';

  @override
  String get activeTables => 'Aktivni stolovi';

  @override
  String tablesWithOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stolova s narudžbama',
      few: '$count stola s narudžbama',
      one: '$count sto s narudžbom',
    );
    return '$_temp0';
  }

  @override
  String get noOpenOrders => 'Nemate otvorenih narudžbi.';

  @override
  String itemAddedInRound(String name, int count) {
    return '$name dodano ($count u ovoj turi)';
  }

  @override
  String itemAdded(String name) {
    return '$name dodano.';
  }

  @override
  String get sendOrderQuestion => 'Poslati narudžbu?';

  @override
  String sendOrderMessage(String items, String total, int table) {
    return 'Poslati $items ($total) za sto $table u kuhinju i na šank? Artikli se ne mogu ukloniti kada priprema počne.';
  }

  @override
  String get sendOrder => 'Pošalji narudžbu';

  @override
  String orderSentTo(String stations) {
    return 'Narudžba poslana: $stations.';
  }

  @override
  String get and => 'i';

  @override
  String get discardRoundQuestion => 'Odbaciti ovu turu?';

  @override
  String discardRoundMessage(String items) {
    return 'Artikli u korpi ($items) još nisu poslani.';
  }

  @override
  String get discard => 'Odbaci';

  @override
  String guestsAndItems(String guests, String items) {
    return '$guests · $items';
  }

  @override
  String addingToOrder(String order, String items) {
    return 'Dodavanje u $order · $items';
  }

  @override
  String get closeSearch => 'Zatvori pretragu';

  @override
  String get searchMenu => 'Pretraži meni';

  @override
  String get currentOrder => 'Trenutna narudžba';

  @override
  String get searchByNameOrDescription => 'Pretraga po nazivu ili opisu';

  @override
  String get favorites => 'Favoriti';

  @override
  String get sending => 'Slanje…';

  @override
  String reviewTotal(String total) {
    return 'Pregled · $total';
  }

  @override
  String get favoritesSubtitle =>
      'Vaši označeni i najprodavaniji artikli · Ažurira se prema vašoj prodaji';

  @override
  String get noFavorites =>
      'Još nema favorita. Dodirnite zvjezdicu na artiklu da ga dodate ovdje; vaši najprodavaniji artikli pojavljuju se automatski.';

  @override
  String get noItemsFound => 'Nema pronađenih artikala.';

  @override
  String get removeFromFavorites => 'Ukloni iz favorita';

  @override
  String get addToFavorites => 'Dodaj u favorite';

  @override
  String get soldOut => 'Rasprodano';

  @override
  String soldCount(int count) {
    return 'prodano: $count';
  }

  @override
  String get allCaughtUp => 'Sve je pročitano';

  @override
  String unreadCount(int count) {
    return 'nepročitano: $count';
  }

  @override
  String get markAllAsRead => 'Označi sve kao pročitano';

  @override
  String get all => 'Sve';

  @override
  String get unread => 'Nepročitano';

  @override
  String get noNotifications => 'Nema obavijesti.';

  @override
  String get guideTablesTitle => 'Odaberite sto';

  @override
  String get guideTablesText =>
      'Birajte među slobodnim stolovima uz pregled kapaciteta i statusa. Zeleno znači slobodno, crveno zauzeto.';

  @override
  String get guideOrdersTitle => 'Primajte narudžbe';

  @override
  String get guideOrdersText =>
      'Pregledajte meni po kategorijama. Favoriti i najprodavaniji artikli su na jedan dodir, a artikli kojih danas nema su posivljeni.';

  @override
  String get guideSuggestionsTitle => 'Pametni prijedlozi';

  @override
  String get guideSuggestionsText =>
      'Kada dodate artikal, Servio predlaže šta obično ide uz njega, na osnovu onoga što gosti naručuju zajedno.';

  @override
  String get guidePaymentTitle => 'Poslužite i naplatite';

  @override
  String get guidePaymentText =>
      'Dobit ćete obavijest kada kuhinja ili šank pripreme narudžbu. Naplatite gotovinom ili putem PayPala, uz napojnicu.';

  @override
  String get waiterGuide => 'Vodič za konobare';

  @override
  String get skip => 'Preskoči';

  @override
  String get getStarted => 'Započni';

  @override
  String get next => 'Dalje';

  @override
  String seatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mjesta',
      few: '$count mjesta',
      one: '$count mjesto',
    );
    return '$_temp0';
  }

  @override
  String get upsellSuggestion => 'Prijedlog za dodatnu prodaju';

  @override
  String get guideUpsellQuestion => 'Želi li gost piće uz to?';

  @override
  String get addWithPlus => '+ Dodaj';

  @override
  String guestsAndWaiter(String guests, String waiter) {
    return '$guests · $waiter';
  }

  @override
  String openedAt(String time) {
    return 'Otvoreno $time';
  }

  @override
  String closedAt(String time) {
    return ' · zatvoreno $time';
  }

  @override
  String get amountPaid => 'Plaćeni iznos';

  @override
  String refundOn(String date) {
    return 'Povrat $date';
  }

  @override
  String get takenBy => 'Naplatio';

  @override
  String get viewReceipt => 'Prikaži račun';

  @override
  String get orderHistory => 'Historija narudžbi';

  @override
  String get yourClosedOrders => 'Vaše zatvorene narudžbe';

  @override
  String get noOrdersYet => 'Ovdje još nema narudžbi.';

  @override
  String historyLine(String date, String items, String guests) {
    return '$date · $items · $guests';
  }

  @override
  String get takePaymentQuestion => 'Naplatiti?';

  @override
  String cashPaymentMessage(String amount, int table) {
    return 'Evidentirati gotovinsko plaćanje od $amount za sto $table?';
  }

  @override
  String cashPaymentWithTipMessage(String amount, String tip, int table) {
    return 'Evidentirati gotovinsko plaćanje od $amount, uključujući napojnicu od $tip, za sto $table?';
  }

  @override
  String giveChange(String change) {
    return 'Vratite kusur od $change.';
  }

  @override
  String cardPaymentMessage(String amount, int table) {
    return 'Naplatiti $amount za sto $table putem PayPala?';
  }

  @override
  String cardPaymentWithTipMessage(String amount, String tip, int table) {
    return 'Naplatiti $amount, uključujući napojnicu od $tip, za sto $table putem PayPala?';
  }

  @override
  String get payPalCancelled =>
      'PayPal plaćanje je otkazano. Novac nije naplaćen.';

  @override
  String get paymentNotConfirmed => 'Plaćanje nije potvrđeno';

  @override
  String tablePaid(int number) {
    return 'Sto $number plaćen';
  }

  @override
  String get paidBy => 'Način plaćanja';

  @override
  String get processPayment => 'Naplata';

  @override
  String get stillBeingPrepared =>
      'Neki artikli su još u pripremi. Račun se može platiti kada sve bude spremno.';

  @override
  String get totalAmount => 'Ukupan iznos';

  @override
  String get orderSummary => 'Pregled narudžbe';

  @override
  String get bill => 'Račun';

  @override
  String get totalToPay => 'Ukupno za platiti';

  @override
  String get tipAmount => 'Napojnica';

  @override
  String plusTip(String tip) {
    return '+ $tip napojnica';
  }

  @override
  String get payPalSecurePage =>
      'Gost plaća na sigurnoj PayPal stranici svojim PayPal računom.';

  @override
  String get selectPaymentMethod => 'Odaberite način plaćanja';

  @override
  String get completeCashPayment => 'Završi gotovinsko plaćanje';

  @override
  String get enterCashReceived => 'Unesite primljenu gotovinu';

  @override
  String get payWithPayPal => 'Plati putem PayPala';

  @override
  String get cashReceivedTitle => 'Primljena gotovina';

  @override
  String get stillMissing => 'Još nedostaje';

  @override
  String get exact => 'Tačno';

  @override
  String get clear => 'Obriši';

  @override
  String get cancelPayment => 'Otkaži plaćanje';

  @override
  String get profileSaved => 'Profil je spremljen.';

  @override
  String get takePhoto => 'Fotografiši';

  @override
  String get chooseFromGallery => 'Odaberi iz galerije';

  @override
  String get removePhoto => 'Ukloni fotografiju';

  @override
  String get passwordChanged => 'Lozinka je promijenjena.';

  @override
  String get myProfile => 'Moj profil';

  @override
  String get changePhoto => 'Promijeni fotografiju';

  @override
  String get firstName => 'Ime';

  @override
  String get lastName => 'Prezime';

  @override
  String get phoneOptional => 'Telefon (opcionalno)';

  @override
  String get saveChanges => 'Spremi promjene';

  @override
  String get cancelOrder => 'Otkaži narudžbu';

  @override
  String get cancelOrderMessage =>
      'Mogu se otkazati samo narudžbe koje kuhinja i šank još nisu počeli pripremati. Zašto se otkazuje?';

  @override
  String get orderCancelled => 'Narudžba je otkazana.';

  @override
  String get order => 'Narudžba';

  @override
  String orderAndWaiter(String order, String waiter) {
    return '$order · $waiter';
  }

  @override
  String welcomeName(String name) {
    return 'Dobrodošli, $name';
  }

  @override
  String get myActiveTables => 'Moji aktivni stolovi';

  @override
  String get myProfileMenu => 'Moj profil';

  @override
  String get tableStatus => 'Status stolova';

  @override
  String get available => 'Slobodan';

  @override
  String get occupied => 'Zauzet';

  @override
  String get reserved => 'Rezervisan';

  @override
  String get badgeAvailable => 'SLOB';

  @override
  String get badgeOccupied => 'ZAU';

  @override
  String get badgeReserved => 'REZ';

  @override
  String get allAreas => 'Svi prostori';

  @override
  String get noTablesInUse => 'Nijedan sto nije u upotrebi.';

  @override
  String maxSeats(int count) {
    return 'Maks.: $count';
  }

  @override
  String nowSeated(int count) {
    return 'Sada: $count';
  }

  @override
  String reservationAt(String time, String guests) {
    return '$time · $guests';
  }

  @override
  String reservedFor(String name, String time, String guests) {
    return 'Rezervisano za $name u $time ($guests).';
  }

  @override
  String get howManyGuests => 'Koliko gostiju?';

  @override
  String get fewerGuests => 'Manje gostiju';

  @override
  String get moreGuests => 'Više gostiju';

  @override
  String tableSeats(int count) {
    return 'Broj mjesta za stolom: $count.';
  }

  @override
  String get startOrder => 'Započni narudžbu';

  @override
  String get currentOrderTitle => 'Trenutna narudžba';

  @override
  String get cartEmpty =>
      'Korpa je prazna. Dodirnite artikle u meniju da ih dodate.';

  @override
  String priceEach(String price) {
    return '$price po komadu';
  }

  @override
  String get remove => 'Ukloni';

  @override
  String get oneLess => 'Jedan manje';

  @override
  String get oneMore => 'Jedan više';

  @override
  String get addNote => 'Dodaj napomenu';

  @override
  String alreadyOnOrder(String order) {
    return 'Već na $order';
  }

  @override
  String get thisRound => 'Ova tura';

  @override
  String get clearAll => 'Obriši sve';

  @override
  String noteFor(String name) {
    return 'Napomena za $name';
  }

  @override
  String get noteHint => 'npr. bez luka, dobro pečeno';

  @override
  String stationOrderServed(String station, int table) {
    return '$station: narudžba za sto $table je poslužena.';
  }

  @override
  String orderCardLine(String items, String order, String time) {
    return '$items · $order · od $time';
  }

  @override
  String stationOrderReady(String station) {
    return '$station: narudžba je spremna';
  }

  @override
  String get markServed => 'Označi posluženo';

  @override
  String get addItems => 'Dodaj artikle';

  @override
  String upsellDrinkQuestion(String name) {
    return 'Želi li gost piće uz $name?';
  }

  @override
  String upsellOftenAdd(String name) {
    return 'Gosti koji naruče $name često dodaju:';
  }

  @override
  String get add => 'Dodaj';

  @override
  String get notNow => 'Ne sada';

  @override
  String get appName => 'Servio';

  @override
  String cannotUseApp(String role) {
    return 'Račun s ulogom „$role“ ne može koristiti ovu aplikaciju.';
  }

  @override
  String get sessionExpired => 'Vaša sesija je istekla. Prijavite se ponovo.';

  @override
  String get justNow => 'upravo sada';

  @override
  String minutesAgo(int minutes) {
    return 'prije $minutes min';
  }

  @override
  String todayAt(String time) {
    return 'danas u $time';
  }

  @override
  String fieldRequired(String label) {
    return 'Polje „$label“ je obavezno.';
  }

  @override
  String fieldLengthBetween(String label, int min, int max) {
    return 'Polje „$label“ mora imati između $min i $max znakova.';
  }

  @override
  String fieldLengthMax(String label, int max) {
    return 'Polje „$label“ može imati najviše $max znakova.';
  }

  @override
  String get emailRequired => 'Email je obavezan.';

  @override
  String get emailInvalid =>
      'Unesite ispravnu email adresu, npr. ime@primjer.com.';

  @override
  String get phoneRequired => 'Broj telefona je obavezan.';

  @override
  String get phoneInvalid =>
      'Unesite broj telefona sa 6 do 19 cifara, po želji s + na početku, npr. +387 61 123 456.';

  @override
  String get usernameRequired => 'Korisničko ime je obavezno.';

  @override
  String get usernameInvalid =>
      'Korisničko ime mora imati 3 do 50 znakova i smije sadržavati samo slova, cifre, tačke i donje crte.';

  @override
  String get passwordRequired => 'Lozinka je obavezna.';

  @override
  String get passwordInvalid =>
      'Lozinka mora imati 8 do 100 znakova i sadržavati barem jedno slovo i jednu cifru.';

  @override
  String get passwordsDoNotMatch => 'Lozinke se ne podudaraju.';

  @override
  String numberInvalid(String label) {
    return 'Polje „$label“ mora biti broj, npr. 12,50.';
  }

  @override
  String numberBetween(String label, String min, String max) {
    return 'Polje „$label“ mora biti između $min i $max.';
  }

  @override
  String wholeNumberInvalid(String label) {
    return 'Polje „$label“ mora biti cijeli broj.';
  }

  @override
  String get courseAppetizer => 'Predjelo';

  @override
  String get courseMainCourse => 'Glavno jelo';

  @override
  String get courseSide => 'Prilog';

  @override
  String get courseDessert => 'Desert';

  @override
  String get courseDrink => 'Piće';

  @override
  String get reservationPending => 'Na čekanju';

  @override
  String get reservationConfirmed => 'Potvrđena';

  @override
  String get reservationCompleted => 'Završena';

  @override
  String get reservationCancelled => 'Otkazana';

  @override
  String get reservationNoShow => 'Gost nije došao';

  @override
  String get ticketNew => 'Novo';

  @override
  String get ticketPreparing => 'U pripremi';

  @override
  String get ticketReady => 'Spremno';

  @override
  String get ticketServed => 'Posluženo';

  @override
  String get ticketCancelled => 'Otkazano';

  @override
  String get paymentPending => 'Na čekanju';

  @override
  String get paymentPaid => 'Plaćeno';

  @override
  String get paymentFailed => 'Neuspjelo';

  @override
  String get paymentCancelled => 'Otkazano';

  @override
  String get paymentPartiallyRefunded => 'Djelimično vraćeno';

  @override
  String get paymentRefunded => 'Vraćeno';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleWaiter => 'Konobar';

  @override
  String get roleKitchen => 'Kuhinja';

  @override
  String get roleBar => 'Šank';

  @override
  String get methodCash => 'Gotovina';

  @override
  String serverUnreachable(String url) {
    return 'Server na adresi $url nije dostupan. Provjerite da li je API pokrenut.';
  }

  @override
  String get confirm => 'Potvrdi';

  @override
  String get back => 'Nazad';

  @override
  String get cancelIt => 'Otkaži';

  @override
  String get reason => 'Razlog';

  @override
  String get reasonHint => 'npr. Gost se predomislio';

  @override
  String get reasonRequired => 'Unesite razlog.';

  @override
  String get reasonLength => 'Razlog mora imati između 3 i 500 znakova.';

  @override
  String get errorForbidden => 'Nemate dozvolu za ovu radnju.';

  @override
  String get errorNotFound => 'Traženi zapis nije pronađen.';

  @override
  String get errorServer => 'Nešto nije u redu na serveru. Pokušajte ponovo.';

  @override
  String get errorGeneric => 'Nešto nije u redu. Pokušajte ponovo.';

  @override
  String get tryAgain => 'Pokušaj ponovo';

  @override
  String vatIncluded(String rate, String tax, String base) {
    return 'Uključen PDV $rate%: $tax · osnovica $base';
  }

  @override
  String get language => 'Jezik';

  @override
  String get languageEnglish => 'Engleski';

  @override
  String get languageBosnian => 'Bosanski';
}
