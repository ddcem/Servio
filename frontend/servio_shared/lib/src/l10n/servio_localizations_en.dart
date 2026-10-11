// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'servio_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ServioLocalizationsEn extends ServioLocalizations {
  ServioLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get assignWaiters => 'Assign waiters';

  @override
  String get tableAssignments => 'Table Assignments';

  @override
  String get tableAssignmentsSubtitle =>
      'Drag each table to the waiter who serves it this shift';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get unassignedHint => 'Any waiter can serve these tables';

  @override
  String tableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables',
      one: '1 table',
    );
    return '$_temp0';
  }

  @override
  String tablesAndSeats(String tables, String seats) {
    return '$tables · $seats';
  }

  @override
  String get dropTablesHere => 'Drop tables here';

  @override
  String get moveTo => 'Move to…';

  @override
  String addAllOfArea(String area) {
    return 'Add all of $area';
  }

  @override
  String get unassignAll => 'Unassign all';

  @override
  String get columnMenu => 'Column actions';

  @override
  String get clearAllAssignments => 'Clear all';

  @override
  String get clearAllQuestion => 'Clear the whole plan?';

  @override
  String get clearAllMessage =>
      'All tables become free for every waiter. Open orders stay with their waiters.';

  @override
  String assignmentMoved(int number, String waiter) {
    return 'Table $number → $waiter';
  }

  @override
  String tablesMoved(String tables, String waiter) {
    return '$tables → $waiter';
  }

  @override
  String assignmentFreed(int number) {
    return 'Table $number is free for every waiter.';
  }

  @override
  String get planCleared =>
      'The plan was cleared. Every waiter can serve every table.';

  @override
  String get noActiveWaiters =>
      'There are no active waiters. Add one under Employees.';

  @override
  String get openOrderMovesHint =>
      'A table with an open order moves together with the order.';

  @override
  String get myTables => 'My tables';

  @override
  String get allTables => 'All tables';

  @override
  String get yourTable => 'Your table';

  @override
  String tableServedBy(int number, String name) {
    return 'Table $number is served by $name. Ask the admin to reassign it if you need to take it over.';
  }

  @override
  String get noTablesAssignedToYou =>
      'No tables are assigned to you right now. Ask the admin, or show all tables.';

  @override
  String get menuManagement => 'Menu Management';

  @override
  String get employees => 'Employees';

  @override
  String get tables => 'Tables';

  @override
  String get reservations => 'Reservations';

  @override
  String get ordersAndPayments => 'Orders & Payments';

  @override
  String get referenceData => 'Reference Data';

  @override
  String get reports => 'Reports';

  @override
  String notificationLine(String title, String body) {
    return '$title: $body';
  }

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get systemManagement => 'System Management';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String loggedInAs(String role) {
    return 'Logged in as $role';
  }

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get role => 'Role';

  @override
  String get name => 'Name';

  @override
  String get price => 'Price';

  @override
  String get category => 'Category';

  @override
  String get area => 'Area';

  @override
  String get open => 'Open';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get anyDate => 'Any date';

  @override
  String dateRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get clearDates => 'Clear dates';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get show => 'Show';

  @override
  String get read => 'Read';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get tag => 'Tag';

  @override
  String get tags => 'Tags';

  @override
  String get tagHint => 'e.g. Spicy';

  @override
  String get areaHint => 'e.g. Garden';

  @override
  String get items => 'Items';

  @override
  String get payments => 'Payments';

  @override
  String get history => 'History';

  @override
  String get phone => 'Phone';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note';

  @override
  String get refund => 'Refund';

  @override
  String get print => 'Print';

  @override
  String deleteNameQuestion(String name) {
    return 'Delete $name?';
  }

  @override
  String get accountRemovedPermanently =>
      'The account is removed permanently. This cannot be undone.';

  @override
  String accountDeleted(String name) {
    return '$name\'s account was deleted.';
  }

  @override
  String get employeeManagement => 'Employee Management';

  @override
  String get manageStaff => 'Manage staff members';

  @override
  String get addEmployee => 'Add Employee';

  @override
  String get searchEmployees => 'Search by name, username or email';

  @override
  String get noEmployeesMatch => 'No employees match the filters.';

  @override
  String usernameAndEmail(String username, String email) {
    return '@$username · $email';
  }

  @override
  String get neverLoggedIn => 'Never logged in';

  @override
  String lastLogin(String time) {
    return 'Last login $time';
  }

  @override
  String get deleteEmployee => 'Delete employee';

  @override
  String get cannotDeleteOwnAccount => 'You cannot delete your own account.';

  @override
  String get employeeHasActivity =>
      'Has orders, reservations or payments in the system. Deactivate the account instead.';

  @override
  String get editEmployee => 'Edit employee';

  @override
  String get addEmployeeTitle => 'Add employee';

  @override
  String accountUpdated(String name) {
    return '$name\'s account was updated.';
  }

  @override
  String employeeAdded(String name, String role) {
    return '$name was added as $role.';
  }

  @override
  String get usernameHelper => 'Used to log in, e.g. john.smith';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get cannotChangeOwnRole => 'You cannot change your own role';

  @override
  String get roleHelper =>
      'The role decides which app and screens the employee can use';

  @override
  String get roleRequired => 'Role is required.';

  @override
  String get cannotDeactivateOwnAccount =>
      'You cannot deactivate your own account';

  @override
  String get inactiveCannotLogIn => 'Inactive employees cannot log in';

  @override
  String get loggedOutEverywhere =>
      'The employee is logged out on all devices after the change';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get images => 'Images';

  @override
  String get imageTooLarge =>
      'The image is larger than 2 MB. Choose a smaller JPEG, PNG or WebP image.';

  @override
  String savedButImageFailed(String name, String error) {
    return '\"$name\" was saved, but the image was not: $error';
  }

  @override
  String itemUpdated(String name) {
    return '\"$name\" was updated.';
  }

  @override
  String itemAddedToMenu(String name) {
    return '\"$name\" was added to the menu.';
  }

  @override
  String get editMenuItem => 'Edit menu item';

  @override
  String get addMenuItem => 'Add menu item';

  @override
  String get changeImage => 'Change';

  @override
  String get addImage => 'Add image';

  @override
  String get nameHintDish => 'e.g. Ribeye Steak';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get descriptionHint => 'e.g. 300 g grilled ribeye with herb butter';

  @override
  String get description => 'Description';

  @override
  String categoryWithStation(String name, String station) {
    return '$name ($station)';
  }

  @override
  String get categoryRequired => 'Category is required.';

  @override
  String get addNewCategory => 'Add a new category';

  @override
  String get newTag => 'New tag';

  @override
  String get availableToday => 'Available today';

  @override
  String get unavailableHidden =>
      'Unavailable items are hidden from the waiters\' menu';

  @override
  String addEntity(String entity) {
    return 'Add $entity';
  }

  @override
  String editEntity(String entity) {
    return 'Edit $entity';
  }

  @override
  String entityAdded(String entity, String name) {
    return '$entity \"$name\" was added.';
  }

  @override
  String entityUpdated(String entity, String name) {
    return '$entity \"$name\" was updated.';
  }

  @override
  String get editCategory => 'Edit category';

  @override
  String get addCategory => 'Add category';

  @override
  String categoryAdded(String name) {
    return 'Category \"$name\" was added.';
  }

  @override
  String categoryUpdated(String name) {
    return 'Category \"$name\" was updated.';
  }

  @override
  String get categoryNameHint => 'e.g. Main Course';

  @override
  String get courseType => 'Course type';

  @override
  String get courseTypeHelper => 'Used by the recommender to complete a meal';

  @override
  String get courseTypeRequired => 'Course type is required.';

  @override
  String get preparedAt => 'Prepared at';

  @override
  String get preparedAtHelper =>
      'Items of this category are sent to this station';

  @override
  String get stationRequired => 'Preparation station is required.';

  @override
  String get sortOrder => 'Sort order';

  @override
  String get sortOrderHelper => 'Lower numbers are shown first in the menu';

  @override
  String get editCurrency => 'Edit currency';

  @override
  String get addCurrency => 'Add currency';

  @override
  String currencyAdded(String code) {
    return 'Currency $code was added.';
  }

  @override
  String currencyUpdated(String code) {
    return 'Currency $code was updated.';
  }

  @override
  String get code => 'Code';

  @override
  String get codeHint => 'e.g. EUR';

  @override
  String get codeLocked =>
      'The code cannot change while orders or the settings use this currency';

  @override
  String get currencyCodeInvalid =>
      'Currency code must be exactly 3 uppercase letters (ISO 4217), e.g. EUR.';

  @override
  String get currencyNameHint => 'e.g. Euro';

  @override
  String get symbol => 'Symbol';

  @override
  String get reservationDate => 'Reservation date';

  @override
  String get arrivalTime => 'Arrival time';

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
  String get startMustBeFuture => 'Start time must be in the future.';

  @override
  String get editReservation => 'Edit reservation';

  @override
  String get newReservation => 'New reservation';

  @override
  String reservationUpdated(String name) {
    return 'The reservation for $name was updated.';
  }

  @override
  String reservationCreated(String name, int table, String time) {
    return 'Reservation for $name at table $table on $time was created. Confirm it to notify the guest.';
  }

  @override
  String get guestName => 'Guest name';

  @override
  String get guests => 'Guests';

  @override
  String get partySize => 'Party size';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get guestGetsEmail => 'The guest gets a confirmation email';

  @override
  String get duration => 'Duration';

  @override
  String get tableChecksHelper =>
      'Overlapping reservations and capacity are checked when saving';

  @override
  String tableOption(int number, String seats, String area) {
    return 'Table $number · $seats · $area';
  }

  @override
  String get tableRequired => 'Table is required.';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get reservationNoteHint => 'e.g. Birthday, needs a high chair';

  @override
  String editTable(int number) {
    return 'Edit table $number';
  }

  @override
  String get addTable => 'Add table';

  @override
  String tableAdded(int number, String seats, String area) {
    return 'Table $number ($seats, $area) was added.';
  }

  @override
  String tableUpdated(int number, String seats, String area) {
    return 'Table $number ($seats, $area) was updated.';
  }

  @override
  String get tableNumberLabel => 'Table number';

  @override
  String get number => 'Number';

  @override
  String get seats => 'Seats';

  @override
  String get capacity => 'Capacity';

  @override
  String get areaRequired => 'Area is required.';

  @override
  String get addNewArea => 'Add a new area';

  @override
  String get inUse => 'In use';

  @override
  String get notInUseHelper =>
      'Tables not in use cannot be ordered at or reserved';

  @override
  String availableAgain(String name) {
    return '$name is available again today.';
  }

  @override
  String nowHidden(String name) {
    return '$name is now hidden from the waiters\' menu.';
  }

  @override
  String removeItemQuestion(String name) {
    return 'Remove \"$name\"?';
  }

  @override
  String get removeItemMessage =>
      'The item disappears from the menu. Past orders keep it, so sales reports stay correct.';

  @override
  String itemRemoved(String name) {
    return '\"$name\" was removed from the menu.';
  }

  @override
  String get manageMenuSubtitle => 'Manage menu items and availability';

  @override
  String get addCategoryFirst =>
      'Add a menu category first (Reference Data → Categories).';

  @override
  String get addItem => 'Add Item';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get availableLabel => 'Available';

  @override
  String get noMenuItemsMatch => 'No menu items match the filters.';

  @override
  String get columnItem => 'ITEM';

  @override
  String get columnCategory => 'CATEGORY';

  @override
  String get columnPrice => 'PRICE';

  @override
  String get columnType => 'TYPE';

  @override
  String get columnOrderNumber => 'ORDER';

  @override
  String get columnOpened => 'OPENED';

  @override
  String get columnTotal => 'TOTAL';

  @override
  String get food => 'food';

  @override
  String get drinkWord => 'drink';

  @override
  String get columnAvailableToday => 'AVAILABLE TODAY';

  @override
  String get columnActions => 'ACTIONS';

  @override
  String get removeFromMenu => 'Remove from menu';

  @override
  String get allMarkedRead => 'All notifications are marked as read.';

  @override
  String get youAreAllCaughtUp => 'You are all caught up';

  @override
  String get ordersOpenedBetween => 'Orders opened between';

  @override
  String get ordersSubtitle =>
      'Every bill with its items, kitchen/bar tickets, payments and refunds';

  @override
  String get orderNumberOrTable => 'Order number or table';

  @override
  String get noOrdersMatch => 'No orders match the filters.';

  @override
  String cancelOrderNumber(String order) {
    return 'Cancel order $order';
  }

  @override
  String get cancelOrderTicketsMessage =>
      'Tickets that were not started are cancelled and the kitchen and bar are notified.';

  @override
  String orderCancelledFor(String order, int table) {
    return 'Order $order for table $table was cancelled.';
  }

  @override
  String orderNumberTitle(String order) {
    return 'Order $order';
  }

  @override
  String orderDetailsLine(
    int table,
    String guests,
    String waiter,
    String time,
  ) {
    return 'Table $table · $guests · $waiter · opened $time';
  }

  @override
  String cancelledReason(String reason) {
    return 'Cancelled: $reason';
  }

  @override
  String get kitchenAndBarTickets => 'Kitchen and bar tickets';

  @override
  String ticketLine(String ticket, String station, String status) {
    return '$ticket · $station · $status';
  }

  @override
  String get noPaymentsYet => 'No payments yet.';

  @override
  String paymentLine(String method, String amount) {
    return '$method · $amount';
  }

  @override
  String paymentLineWithTip(String method, String amount, String tip) {
    return '$method · $amount (incl. $tip tip)';
  }

  @override
  String refundUpTo(String amount) {
    return 'Refund up to $amount';
  }

  @override
  String get nothingToRefund => 'Nothing left to refund on this payment.';

  @override
  String paymentProcessedLine(String name, String time) {
    return '$name · $time';
  }

  @override
  String cashReceivedLine(String received, String change) {
    return ' · received $received, change $change';
  }

  @override
  String refundedLine(String amount, String name, String time, String reason) {
    return '↩ $amount refunded by $name on $time – $reason';
  }

  @override
  String get orderMustBePaid =>
      'Items are already being prepared or were served, so the order has to be paid.';

  @override
  String get refundPayment => 'Refund payment';

  @override
  String refundAmountQuestion(String amount) {
    return 'Refund $amount?';
  }

  @override
  String get refundPayPalMessage =>
      'The money is returned to the guest\'s PayPal account. This cannot be undone.';

  @override
  String get refundCashMessage =>
      'Give the cash back to the guest. This cannot be undone.';

  @override
  String refundCompleted(String amount, String order) {
    return 'Refund of $amount for order $order was completed.';
  }

  @override
  String refundIntro(String method, String amount, String refundable) {
    return '$method payment of $amount. Up to $refundable can still be refunded.';
  }

  @override
  String atMost(String amount) {
    return 'At most $amount';
  }

  @override
  String get refundAmount => 'Refund amount';

  @override
  String get refundReasonHint => 'e.g. Steak was overcooked';

  @override
  String get referenceDataSubtitle =>
      'Lists used by the menu, tables and payments';

  @override
  String get menuCategories => 'Menu categories';

  @override
  String get itemTags => 'Item tags';

  @override
  String get tableAreas => 'Table areas';

  @override
  String get currencies => 'Currencies';

  @override
  String get systemLists => 'System lists';

  @override
  String get searchCategories => 'Search categories';

  @override
  String get columnName => 'NAME';

  @override
  String get columnCourse => 'COURSE';

  @override
  String get columnPreparedAt => 'PREPARED AT';

  @override
  String get columnOrder => 'ORDER';

  @override
  String get columnItems => 'ITEMS';

  @override
  String categoryInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count menu items',
      one: '1 menu item',
    );
    return 'Used by $_temp0, including removed items kept for order history.';
  }

  @override
  String get searchTags => 'Search tags';

  @override
  String get columnMenuItems => 'MENU ITEMS';

  @override
  String tagInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count menu items',
      one: '1 menu item',
    );
    return 'Used by $_temp0. Remove it from those items first.';
  }

  @override
  String get searchAreas => 'Search areas';

  @override
  String get columnTables => 'TABLES';

  @override
  String areaInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables',
      one: '1 table',
    );
    return 'Has $_temp0. Move or delete them first.';
  }

  @override
  String get searchCurrencies => 'Search currencies';

  @override
  String get columnCode => 'CODE';

  @override
  String get columnSymbol => 'SYMBOL';

  @override
  String get columnInUse => 'IN USE';

  @override
  String get currencyInUse =>
      'Used by the restaurant settings or by existing orders.';

  @override
  String deleteQuestion(String name) {
    return 'Delete $name?';
  }

  @override
  String get removedPermanently => 'It is removed permanently.';

  @override
  String entityDeleted(String name) {
    return '\"$name\" was deleted.';
  }

  @override
  String get nothingFound => 'Nothing found.';

  @override
  String get systemListsInfo =>
      'These lists are fixed. Roles decide what each employee may do, stations decide where orders are sent, and payment methods are tied to the cash and PayPal flows, so renaming or deleting them would break those features.';

  @override
  String get roles => 'Roles';

  @override
  String get preparationStations => 'Preparation stations';

  @override
  String get paymentMethods => 'Payment methods';

  @override
  String get entityCategory => 'Category';

  @override
  String get entityTag => 'Tag';

  @override
  String get entityArea => 'Area';

  @override
  String get entityCurrency => 'Currency';

  @override
  String get addCategoryButton => 'Add category';

  @override
  String get addTagButton => 'Add tag';

  @override
  String get addAreaButton => 'Add area';

  @override
  String get addCurrencyButton => 'Add currency';

  @override
  String get reportPeriod => 'Report period';

  @override
  String reportSaved(String path) {
    return 'The report was saved to $path.';
  }

  @override
  String reportSaveFailed(String error) {
    return 'The report could not be saved: $error';
  }

  @override
  String get salesAndAnalytics => 'Sales & Analytics';

  @override
  String get salesSubtitle => 'Track performance and revenue metrics';

  @override
  String get salesReport => 'Sales report';

  @override
  String get staffReport => 'Staff report';

  @override
  String get periodAnalysis => 'Period analysis';

  @override
  String lastDays(int count) {
    return 'Last $count days';
  }

  @override
  String sameAs(String when) {
    return 'Same as $when';
  }

  @override
  String firstSalesComparedTo(String when) {
    return 'First sales compared to $when';
  }

  @override
  String percentFrom(String change, String when) {
    return '$change% from $when';
  }

  @override
  String get yesterday => 'yesterday';

  @override
  String get todaysRevenue => 'Today\'s revenue';

  @override
  String get kpiGuests => 'Guests';

  @override
  String get paidOrders => 'Paid orders';

  @override
  String activeNow(int count) {
    return '$count active now';
  }

  @override
  String get averageBill => 'Average bill';

  @override
  String tablesServed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables served',
      one: '1 table served',
    );
    return '$_temp0';
  }

  @override
  String get popularItemsToday => 'Popular items today';

  @override
  String get noSalesToday => 'No sales yet today.';

  @override
  String get revenue => 'Revenue';

  @override
  String get netRevenueAfterRefunds => 'Net revenue (after refunds)';

  @override
  String get tips => 'Tips';

  @override
  String get refunds => 'Refunds';

  @override
  String get cancelledOrders => 'Cancelled orders';

  @override
  String get dailyRevenue => 'Daily revenue';

  @override
  String get bestSellingItems => 'Best-selling items';

  @override
  String get leastSellingItems => 'Least-selling items';

  @override
  String get promotionCandidates => 'Candidates for a promotion or removal';

  @override
  String get salesByCategory => 'Sales by category';

  @override
  String soldAndRevenue(int count, String revenue) {
    return '$count sold · $revenue';
  }

  @override
  String get paymentsByMethod => 'Payments by method';

  @override
  String paymentsAndAmount(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '1 payment',
    );
    return '$_temp0 · $amount';
  }

  @override
  String get staffPerformance => 'Staff performance';

  @override
  String get columnWaiter => 'WAITER';

  @override
  String get columnOrders => 'ORDERS';

  @override
  String get columnRevenue => 'REVENUE';

  @override
  String get columnAvgBill => 'AVG. BILL';

  @override
  String get columnTips => 'TIPS';

  @override
  String get columnSuggestionsAccepted => 'SUGGESTIONS ACCEPTED';

  @override
  String nameInactive(String name) {
    return '$name (inactive)';
  }

  @override
  String percentOf(String percent, int total) {
    return '$percent of $total';
  }

  @override
  String stationTickets(String station, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets',
      one: '1 ticket',
    );
    return '$station: $_temp0';
  }

  @override
  String minutesToReady(String minutes) {
    return '$minutes min to ready';
  }

  @override
  String reportPdfTooltip(String label) {
    return '$label (PDF) for the selected period';
  }

  @override
  String get saveAsPdf => 'Save as PDF';

  @override
  String soldAndCategory(int count, String category) {
    return '$count sold · $category';
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
      other: '$count orders',
      one: '1 order',
    );
    return '$_temp0';
  }

  @override
  String get reservationsBetween => 'Reservations between';

  @override
  String get cancelReservation => 'Cancel reservation';

  @override
  String cancelReservationMessage(String name, String time) {
    return 'Cancel $name\'s reservation for $time? Waiters are notified.';
  }

  @override
  String cancelReservationEmailMessage(String name, String time) {
    return 'Cancel $name\'s reservation for $time? The guest gets an email and waiters are notified.';
  }

  @override
  String reservationCancelledFor(String name) {
    return '$name\'s reservation was cancelled.';
  }

  @override
  String get reservationsSubtitle =>
      'Book tables and follow each reservation through its statuses';

  @override
  String get newReservationButton => 'New Reservation';

  @override
  String get guestNameOrPhone => 'Guest name or phone';

  @override
  String get noReservationsMatch => 'No reservations match the filters.';

  @override
  String get columnGuest => 'GUEST';

  @override
  String get columnWhen => 'WHEN';

  @override
  String get columnTable => 'TABLE';

  @override
  String get columnGuests => 'GUESTS';

  @override
  String get columnStatus => 'STATUS';

  @override
  String timeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get confirmEmailsGuest => 'Confirm (emails the guest)';

  @override
  String reservationConfirmedFor(String name) {
    return '$name\'s reservation is confirmed.';
  }

  @override
  String get guestsArrived => 'Guests arrived';

  @override
  String get arrivedTooEarly =>
      'Guests can be marked as arrived from 30 minutes before the reservation.';

  @override
  String guestArrived(String name) {
    return '$name has arrived; reservation completed.';
  }

  @override
  String get noShow => 'No-show';

  @override
  String get noShowTooEarly =>
      'A no-show can be recorded 15 minutes after the reservation starts.';

  @override
  String markedNoShow(String name) {
    return '$name was marked as a no-show.';
  }

  @override
  String tableAndGuests(int table, String guests) {
    return 'Table $table · $guests';
  }

  @override
  String createdByOn(String name, String time) {
    return 'Created by $name on $time';
  }

  @override
  String createdAs(String status) {
    return 'Created as $status';
  }

  @override
  String statusChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get saveSettingsQuestion => 'Save settings?';

  @override
  String get saveSettingsMessage =>
      'New orders use the new VAT rate and currency. Open orders keep the values they were opened with.';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String settingsSaved(String name, String currency, String rate) {
    return 'Settings saved: $name, $currency, VAT $rate%.';
  }

  @override
  String get systemSettings => 'System Settings';

  @override
  String get configurePreferences => 'Configure restaurant preferences';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get restaurantName => 'Restaurant name';

  @override
  String get currency => 'Currency';

  @override
  String get currencyHelper => 'PayPal payments are charged in this currency';

  @override
  String currencyOption(String code, String symbol, String name) {
    return '$code ($symbol) – $name';
  }

  @override
  String get currencyRequired => 'Currency is required.';

  @override
  String get addNewCurrency => 'Add a new currency';

  @override
  String get vatRatePercent => 'VAT rate (%)';

  @override
  String get vatRateHelper =>
      'Included in menu prices; receipts show how much of the total is VAT';

  @override
  String get vatRate => 'VAT rate';

  @override
  String lastChanged(String time) {
    return 'Last changed $time';
  }

  @override
  String lastChangedBy(String time, String name) {
    return 'Last changed $time by $name';
  }

  @override
  String get myPreferences => 'My preferences';

  @override
  String get myPreferencesHint =>
      'Only for your account. Notifications and PDF reports use this language too.';

  @override
  String deleteTableQuestion(int number) {
    return 'Delete table $number?';
  }

  @override
  String get tableRemovedPermanently => 'The table is removed permanently.';

  @override
  String tableDeleted(int number) {
    return 'Table $number was deleted.';
  }

  @override
  String get tablesSubtitle => 'Seating plan with live status';

  @override
  String get addAreaFirst =>
      'Add a table area first (Reference Data → Table areas).';

  @override
  String get addTableButton => 'Add Table';

  @override
  String get noTablesMatch => 'No tables match the filters.';

  @override
  String get columnArea => 'AREA';

  @override
  String get columnSeats => 'SEATS';

  @override
  String get columnCurrentBill => 'CURRENT BILL';

  @override
  String get columnNextReservation => 'NEXT RESERVATION';

  @override
  String tableNotInUse(int number) {
    return 'Table $number (not in use)';
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
  String get deleteTable => 'Delete table';

  @override
  String get tableHasHistory =>
      'The table has orders or reservations in its history. Mark it as not in use instead.';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get chooseView => 'Choose what you\'d like to view';

  @override
  String get kitchenView => 'Kitchen View';

  @override
  String get monitorFood => 'Monitor food orders';

  @override
  String get barView => 'Bar View';

  @override
  String get monitorDrinks => 'Monitor drink orders';

  @override
  String get manageSystem => 'Manage system';

  @override
  String get staffLogin => 'Staff Login';

  @override
  String get demoAccounts => 'Demo accounts (password: test)';

  @override
  String get demoDesktop => '• desktop – admin panel';

  @override
  String get demoKitchen => '• kitchen – kitchen display';

  @override
  String get demoBar => '• bar – bar display';

  @override
  String ticketBeingPrepared(String ticket, int table) {
    return 'Ticket $ticket for table $table is being prepared.';
  }

  @override
  String ticketReadyNotified(String ticket, String waiter) {
    return 'Ticket $ticket is ready. $waiter has been notified.';
  }

  @override
  String get kitchenDisplay => 'Kitchen Display';

  @override
  String get barDisplay => 'Bar Display';

  @override
  String activeOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active orders',
      one: '1 active order',
    );
    return '$_temp0';
  }

  @override
  String get viewOnly => 'View only';

  @override
  String get noPendingFood => 'No pending food orders';

  @override
  String get noPendingDrinks => 'No pending drink orders';

  @override
  String ticketTitle(String ticket) {
    return 'Order $ticket';
  }

  @override
  String quantityPrefix(int quantity) {
    return 'x$quantity';
  }

  @override
  String get startPreparing => 'Start Preparing';

  @override
  String get markAsReady => 'Mark as Ready';

  @override
  String get completeOrder => 'Complete Order';

  @override
  String get summaryNew => 'New';

  @override
  String get summaryPreparing => 'Preparing';

  @override
  String get longestWait => 'Longest wait';

  @override
  String get avgTimeToReadyToday => 'Avg. time to ready today';

  @override
  String minutesValue(String minutes) {
    return '$minutes min';
  }

  @override
  String get completedToday => 'Completed today';

  @override
  String roleStaff(String role) {
    return '$role staff';
  }

  @override
  String get backToDashboardShort => 'Back to dashboard';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get previousPage => 'Previous page';

  @override
  String pageOf(int page, int pages) {
    return 'Page $page of $pages';
  }

  @override
  String get nextPage => 'Next page';

  @override
  String get table => 'Table';

  @override
  String tableNumber(int number) {
    return 'Table $number';
  }

  @override
  String tableAndOrder(int number, String order) {
    return 'Table $number · $order';
  }

  @override
  String guestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get total => 'Total';

  @override
  String get payment => 'Payment';

  @override
  String get paid => 'Paid';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get status => 'Status';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get more => 'More';

  @override
  String get loadMore => 'Load more';

  @override
  String get logout => 'Logout';

  @override
  String get logoutQuestion => 'Do you want to log out?';

  @override
  String get email => 'Email';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get login => 'Login';

  @override
  String get enterCredentials => 'Enter your credentials to continue';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get help => 'Help';

  @override
  String get languageHint =>
      'Notifications, emails and receipts use this language too.';

  @override
  String get payPal => 'PayPal';

  @override
  String get receipt => 'Receipt';

  @override
  String get done => 'Done';

  @override
  String get change => 'Change';

  @override
  String get amount => 'Amount';

  @override
  String get tip => 'Tip';

  @override
  String tipPercent(String percent) {
    return 'Tip ($percent%)';
  }

  @override
  String get cashReceived => 'Cash received';

  @override
  String reasonText(String reason) {
    return 'Reason: $reason';
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
      'Your password was changed. You can log in now.';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetEnterCode =>
      'Enter the code from the email and choose a new password.';

  @override
  String get resetEnterEmail =>
      'Enter the email address of your account. We will send you a 6-digit code.';

  @override
  String get resetCode => 'Reset code';

  @override
  String get resetCodeInvalid => 'The reset code has 6 digits.';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordHint =>
      'At least 8 characters, with a letter and a number';

  @override
  String get repeatNewPassword => 'Repeat new password';

  @override
  String get changePassword => 'Change password';

  @override
  String get sendCode => 'Send code';

  @override
  String get sendNewCode => 'Send a new code';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get currentPassword => 'Current password';

  @override
  String get waiterLogin => 'Waiter Login';

  @override
  String get demoAccount => 'Demo account: ';

  @override
  String get activeTables => 'Active Tables';

  @override
  String tablesWithOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables with orders',
      one: '1 table with orders',
    );
    return '$_temp0';
  }

  @override
  String get noOpenOrders => 'You have no open orders.';

  @override
  String itemAddedInRound(String name, int count) {
    return '$name added ($count in this round)';
  }

  @override
  String itemAdded(String name) {
    return '$name added.';
  }

  @override
  String get sendOrderQuestion => 'Send order?';

  @override
  String sendOrderMessage(String items, String total, int table) {
    return 'Send $items ($total) for table $table to the kitchen and bar? Items cannot be removed once preparation starts.';
  }

  @override
  String get sendOrder => 'Send Order';

  @override
  String orderSentTo(String stations) {
    return 'Order sent to the $stations.';
  }

  @override
  String get and => 'and';

  @override
  String get discardRoundQuestion => 'Discard this round?';

  @override
  String discardRoundMessage(String items) {
    return 'The $items in the cart have not been sent yet.';
  }

  @override
  String get discard => 'Discard';

  @override
  String guestsAndItems(String guests, String items) {
    return '$guests · $items';
  }

  @override
  String addingToOrder(String order, String items) {
    return 'Adding to $order · $items';
  }

  @override
  String get closeSearch => 'Close search';

  @override
  String get searchMenu => 'Search the menu';

  @override
  String get currentOrder => 'Current order';

  @override
  String get searchByNameOrDescription => 'Search by name or description';

  @override
  String get favorites => 'Favorites';

  @override
  String get sending => 'Sending…';

  @override
  String reviewTotal(String total) {
    return 'Review · $total';
  }

  @override
  String get favoritesSubtitle =>
      'Your starred and most sold items · Updates based on your sales';

  @override
  String get noFavorites =>
      'No favorites yet. Tap the star on any item to pin it here; your best sellers appear automatically.';

  @override
  String get noItemsFound => 'No items found.';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get soldOut => 'Sold out';

  @override
  String soldCount(int count) {
    return '$count sold';
  }

  @override
  String get allCaughtUp => 'All caught up';

  @override
  String unreadCount(int count) {
    return '$count unread';
  }

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get all => 'All';

  @override
  String get unread => 'Unread';

  @override
  String get noNotifications => 'No notifications.';

  @override
  String get guideTablesTitle => 'Select Tables';

  @override
  String get guideTablesText =>
      'Choose from available tables with capacity and status tracking. Green means available, red means occupied.';

  @override
  String get guideOrdersTitle => 'Take Orders';

  @override
  String get guideOrdersText =>
      'Browse the menu by category. Your favorites and best sellers are one tap away, and items sold out today are greyed out.';

  @override
  String get guideSuggestionsTitle => 'Smart Suggestions';

  @override
  String get guideSuggestionsText =>
      'After you add an item, Servio suggests what usually goes with it, based on what guests order together.';

  @override
  String get guidePaymentTitle => 'Serve & Get Paid';

  @override
  String get guidePaymentText =>
      'You are notified when the kitchen or bar has an order ready. Take payment in cash or through PayPal, with a tip.';

  @override
  String get waiterGuide => 'Waiter Guide';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String seatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '1 seat',
    );
    return '$_temp0';
  }

  @override
  String get upsellSuggestion => 'Upsell Suggestion';

  @override
  String get guideUpsellQuestion => 'Would your guest like a drink with that?';

  @override
  String get addWithPlus => '+ Add';

  @override
  String guestsAndWaiter(String guests, String waiter) {
    return '$guests · $waiter';
  }

  @override
  String openedAt(String time) {
    return 'Opened $time';
  }

  @override
  String closedAt(String time) {
    return ' · closed $time';
  }

  @override
  String get amountPaid => 'Amount paid';

  @override
  String refundOn(String date) {
    return 'Refund $date';
  }

  @override
  String get takenBy => 'Taken by';

  @override
  String get viewReceipt => 'View receipt';

  @override
  String get orderHistory => 'Order History';

  @override
  String get yourClosedOrders => 'Your closed orders';

  @override
  String get noOrdersYet => 'No orders here yet.';

  @override
  String historyLine(String date, String items, String guests) {
    return '$date · $items · $guests';
  }

  @override
  String get takePaymentQuestion => 'Take payment?';

  @override
  String cashPaymentMessage(String amount, int table) {
    return 'Record a cash payment of $amount for table $table?';
  }

  @override
  String cashPaymentWithTipMessage(String amount, String tip, int table) {
    return 'Record a cash payment of $amount including a $tip tip for table $table?';
  }

  @override
  String giveChange(String change) {
    return 'Give $change change.';
  }

  @override
  String cardPaymentMessage(String amount, int table) {
    return 'Charge $amount for table $table through PayPal?';
  }

  @override
  String cardPaymentWithTipMessage(String amount, String tip, int table) {
    return 'Charge $amount including a $tip tip for table $table through PayPal?';
  }

  @override
  String get payPalCancelled =>
      'The PayPal payment was cancelled. No money was taken.';

  @override
  String get paymentNotConfirmed => 'Payment not confirmed';

  @override
  String tablePaid(int number) {
    return 'Table $number paid';
  }

  @override
  String get paidBy => 'Paid by';

  @override
  String get processPayment => 'Process Payment';

  @override
  String get stillBeingPrepared =>
      'Some items are still being prepared. The bill can be paid once everything is ready.';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get bill => 'Bill';

  @override
  String get totalToPay => 'Total to pay';

  @override
  String get tipAmount => 'Tip Amount';

  @override
  String plusTip(String tip) {
    return '+ $tip tip';
  }

  @override
  String get payPalSecurePage =>
      'The guest pays on PayPal\'s secure page with their PayPal account.';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get completeCashPayment => 'Complete Cash Payment';

  @override
  String get enterCashReceived => 'Enter Cash Received';

  @override
  String get payWithPayPal => 'Pay with PayPal';

  @override
  String get cashReceivedTitle => 'Cash Received';

  @override
  String get stillMissing => 'Still missing';

  @override
  String get exact => 'Exact';

  @override
  String get clear => 'Clear';

  @override
  String get cancelPayment => 'Cancel payment';

  @override
  String get profileSaved => 'Your profile was saved.';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get passwordChanged => 'Your password was changed.';

  @override
  String get myProfile => 'My Profile';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get cancelOrder => 'Cancel order';

  @override
  String get cancelOrderMessage =>
      'Only orders that the kitchen and bar have not started can be cancelled. Why is it cancelled?';

  @override
  String get orderCancelled => 'The order was cancelled.';

  @override
  String get order => 'Order';

  @override
  String orderAndWaiter(String order, String waiter) {
    return '$order · $waiter';
  }

  @override
  String welcomeName(String name) {
    return 'Welcome, $name';
  }

  @override
  String get myActiveTables => 'My active tables';

  @override
  String get myProfileMenu => 'My profile';

  @override
  String get tableStatus => 'Table Status';

  @override
  String get available => 'Available';

  @override
  String get occupied => 'Occupied';

  @override
  String get reserved => 'Reserved';

  @override
  String get badgeAvailable => 'AVAIL';

  @override
  String get badgeOccupied => 'OCC';

  @override
  String get badgeReserved => 'RES';

  @override
  String get allAreas => 'All areas';

  @override
  String get noTablesInUse => 'No tables are in use.';

  @override
  String maxSeats(int count) {
    return 'Max: $count';
  }

  @override
  String nowSeated(int count) {
    return 'Now: $count';
  }

  @override
  String reservationAt(String time, String guests) {
    return '$time · $guests';
  }

  @override
  String reservedFor(String name, String time, String guests) {
    return 'Reserved for $name at $time ($guests).';
  }

  @override
  String get howManyGuests => 'How many guests?';

  @override
  String get fewerGuests => 'Fewer guests';

  @override
  String get moreGuests => 'More guests';

  @override
  String tableSeats(int count) {
    return 'The table seats $count.';
  }

  @override
  String get startOrder => 'Start order';

  @override
  String get currentOrderTitle => 'Current Order';

  @override
  String get cartEmpty => 'The cart is empty. Tap menu items to add them.';

  @override
  String priceEach(String price) {
    return '$price each';
  }

  @override
  String get remove => 'Remove';

  @override
  String get oneLess => 'One less';

  @override
  String get oneMore => 'One more';

  @override
  String get addNote => 'Add note';

  @override
  String alreadyOnOrder(String order) {
    return 'Already on $order';
  }

  @override
  String get thisRound => 'This round';

  @override
  String get clearAll => 'Clear All';

  @override
  String noteFor(String name) {
    return 'Note for $name';
  }

  @override
  String get noteHint => 'e.g. no onions, well done';

  @override
  String stationOrderServed(String station, int table) {
    return '$station order for table $table served.';
  }

  @override
  String orderCardLine(String items, String order, String time) {
    return '$items · $order · since $time';
  }

  @override
  String stationOrderReady(String station) {
    return '$station order is ready';
  }

  @override
  String get markServed => 'Mark served';

  @override
  String get addItems => 'Add Items';

  @override
  String upsellDrinkQuestion(String name) {
    return 'Would your guest like a drink with the $name?';
  }

  @override
  String upsellOftenAdd(String name) {
    return 'Guests who order $name often add:';
  }

  @override
  String get add => 'Add';

  @override
  String get notNow => 'Not Now';

  @override
  String get appName => 'Servio';

  @override
  String cannotUseApp(String role) {
    return 'The $role account cannot use this app.';
  }

  @override
  String get sessionExpired => 'Your session has expired. Please log in again.';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String todayAt(String time) {
    return 'today $time';
  }

  @override
  String fieldRequired(String label) {
    return '$label is required.';
  }

  @override
  String fieldLengthBetween(String label, int min, int max) {
    return '$label must be between $min and $max characters long.';
  }

  @override
  String fieldLengthMax(String label, int max) {
    return '$label can be at most $max characters long.';
  }

  @override
  String get emailRequired => 'Email is required.';

  @override
  String get emailInvalid =>
      'Enter a valid email address, e.g. name@example.com.';

  @override
  String get phoneRequired => 'Phone number is required.';

  @override
  String get phoneInvalid =>
      'Enter a phone number with 6 to 19 digits, optionally starting with +, e.g. +387 61 123 456.';

  @override
  String get usernameRequired => 'Username is required.';

  @override
  String get usernameInvalid =>
      'Username must be 3 to 50 characters and may contain only letters, digits, dots and underscores.';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String get passwordInvalid =>
      'Password must be 8 to 100 characters long and contain at least one letter and one digit.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String numberInvalid(String label) {
    return '$label must be a number, e.g. 12.50.';
  }

  @override
  String numberBetween(String label, String min, String max) {
    return '$label must be between $min and $max.';
  }

  @override
  String wholeNumberInvalid(String label) {
    return '$label must be a whole number.';
  }

  @override
  String get courseAppetizer => 'Appetizer';

  @override
  String get courseMainCourse => 'Main course';

  @override
  String get courseSide => 'Side';

  @override
  String get courseDessert => 'Dessert';

  @override
  String get courseDrink => 'Drink';

  @override
  String get reservationPending => 'Pending';

  @override
  String get reservationConfirmed => 'Confirmed';

  @override
  String get reservationCompleted => 'Completed';

  @override
  String get reservationCancelled => 'Cancelled';

  @override
  String get reservationNoShow => 'No-show';

  @override
  String get ticketNew => 'New';

  @override
  String get ticketPreparing => 'Preparing';

  @override
  String get ticketReady => 'Ready';

  @override
  String get ticketServed => 'Served';

  @override
  String get ticketCancelled => 'Cancelled';

  @override
  String get paymentPending => 'Pending';

  @override
  String get paymentPaid => 'Paid';

  @override
  String get paymentFailed => 'Failed';

  @override
  String get paymentCancelled => 'Cancelled';

  @override
  String get paymentPartiallyRefunded => 'Partially refunded';

  @override
  String get paymentRefunded => 'Refunded';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleWaiter => 'Waiter';

  @override
  String get roleKitchen => 'Kitchen';

  @override
  String get roleBar => 'Bar';

  @override
  String get methodCash => 'Cash';

  @override
  String serverUnreachable(String url) {
    return 'Cannot reach the server at $url. Check that the API is running.';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get cancelIt => 'Cancel it';

  @override
  String get reason => 'Reason';

  @override
  String get reasonHint => 'e.g. Guest changed their mind';

  @override
  String get reasonRequired => 'Please enter a reason.';

  @override
  String get reasonLength =>
      'Reason must be between 3 and 500 characters long.';

  @override
  String get errorForbidden => 'You do not have permission for this action.';

  @override
  String get errorNotFound => 'The requested record was not found.';

  @override
  String get errorServer =>
      'Something went wrong on the server. Please try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String vatIncluded(String rate, String tax, String base) {
    return 'Includes $rate% VAT: $tax · base $base';
  }

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBosnian => 'Bosnian';
}
