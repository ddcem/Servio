import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'servio_localizations_bs.dart';
import 'servio_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ServioLocalizations
/// returned by `ServioLocalizations.of(context)`.
///
/// Applications need to include `ServioLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/servio_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ServioLocalizations.localizationsDelegates,
///   supportedLocales: ServioLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the ServioLocalizations.supportedLocales
/// property.
abstract class ServioLocalizations {
  ServioLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ServioLocalizations of(BuildContext context) {
    return Localizations.of<ServioLocalizations>(context, ServioLocalizations)!;
  }

  static const LocalizationsDelegate<ServioLocalizations> delegate =
      _ServioLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bs'),
    Locale('en'),
  ];

  /// No description provided for @assignWaiters.
  ///
  /// In en, this message translates to:
  /// **'Assign waiters'**
  String get assignWaiters;

  /// No description provided for @tableAssignments.
  ///
  /// In en, this message translates to:
  /// **'Table Assignments'**
  String get tableAssignments;

  /// No description provided for @tableAssignmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag each table to the waiter who serves it this shift'**
  String get tableAssignmentsSubtitle;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @unassignedHint.
  ///
  /// In en, this message translates to:
  /// **'Any waiter can serve these tables'**
  String get unassignedHint;

  /// No description provided for @tableCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 table} other{{count} tables}}'**
  String tableCount(int count);

  /// No description provided for @tablesAndSeats.
  ///
  /// In en, this message translates to:
  /// **'{tables} · {seats}'**
  String tablesAndSeats(String tables, String seats);

  /// No description provided for @dropTablesHere.
  ///
  /// In en, this message translates to:
  /// **'Drop tables here'**
  String get dropTablesHere;

  /// No description provided for @moveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to…'**
  String get moveTo;

  /// No description provided for @addAllOfArea.
  ///
  /// In en, this message translates to:
  /// **'Add all of {area}'**
  String addAllOfArea(String area);

  /// No description provided for @unassignAll.
  ///
  /// In en, this message translates to:
  /// **'Unassign all'**
  String get unassignAll;

  /// No description provided for @columnMenu.
  ///
  /// In en, this message translates to:
  /// **'Column actions'**
  String get columnMenu;

  /// No description provided for @clearAllAssignments.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllAssignments;

  /// No description provided for @clearAllQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear the whole plan?'**
  String get clearAllQuestion;

  /// No description provided for @clearAllMessage.
  ///
  /// In en, this message translates to:
  /// **'All tables become free for every waiter. Open orders stay with their waiters.'**
  String get clearAllMessage;

  /// No description provided for @assignmentMoved.
  ///
  /// In en, this message translates to:
  /// **'Table {number} → {waiter}'**
  String assignmentMoved(int number, String waiter);

  /// No description provided for @tablesMoved.
  ///
  /// In en, this message translates to:
  /// **'{tables} → {waiter}'**
  String tablesMoved(String tables, String waiter);

  /// No description provided for @assignmentFreed.
  ///
  /// In en, this message translates to:
  /// **'Table {number} is free for every waiter.'**
  String assignmentFreed(int number);

  /// No description provided for @planCleared.
  ///
  /// In en, this message translates to:
  /// **'The plan was cleared. Every waiter can serve every table.'**
  String get planCleared;

  /// No description provided for @noActiveWaiters.
  ///
  /// In en, this message translates to:
  /// **'There are no active waiters. Add one under Employees.'**
  String get noActiveWaiters;

  /// No description provided for @openOrderMovesHint.
  ///
  /// In en, this message translates to:
  /// **'A table with an open order moves together with the order.'**
  String get openOrderMovesHint;

  /// No description provided for @myTables.
  ///
  /// In en, this message translates to:
  /// **'My tables'**
  String get myTables;

  /// No description provided for @allTables.
  ///
  /// In en, this message translates to:
  /// **'All tables'**
  String get allTables;

  /// No description provided for @yourTable.
  ///
  /// In en, this message translates to:
  /// **'Your table'**
  String get yourTable;

  /// No description provided for @tableServedBy.
  ///
  /// In en, this message translates to:
  /// **'Table {number} is served by {name}. Ask the admin to reassign it if you need to take it over.'**
  String tableServedBy(int number, String name);

  /// No description provided for @noTablesAssignedToYou.
  ///
  /// In en, this message translates to:
  /// **'No tables are assigned to you right now. Ask the admin, or show all tables.'**
  String get noTablesAssignedToYou;

  /// No description provided for @menuManagement.
  ///
  /// In en, this message translates to:
  /// **'Menu Management'**
  String get menuManagement;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @tables.
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get tables;

  /// No description provided for @reservations.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get reservations;

  /// No description provided for @ordersAndPayments.
  ///
  /// In en, this message translates to:
  /// **'Orders & Payments'**
  String get ordersAndPayments;

  /// No description provided for @referenceData.
  ///
  /// In en, this message translates to:
  /// **'Reference Data'**
  String get referenceData;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @notificationLine.
  ///
  /// In en, this message translates to:
  /// **'{title}: {body}'**
  String notificationLine(String title, String body);

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @systemManagement.
  ///
  /// In en, this message translates to:
  /// **'System Management'**
  String get systemManagement;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// No description provided for @loggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Logged in as {role}'**
  String loggedInAs(String role);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @anyDate.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get anyDate;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String dateRange(String from, String to);

  /// No description provided for @clearDates.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get clearDates;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Spicy'**
  String get tagHint;

  /// No description provided for @areaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Garden'**
  String get areaHint;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @deleteNameQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteNameQuestion(String name);

  /// No description provided for @accountRemovedPermanently.
  ///
  /// In en, this message translates to:
  /// **'The account is removed permanently. This cannot be undone.'**
  String get accountRemovedPermanently;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s account was deleted.'**
  String accountDeleted(String name);

  /// No description provided for @employeeManagement.
  ///
  /// In en, this message translates to:
  /// **'Employee Management'**
  String get employeeManagement;

  /// No description provided for @manageStaff.
  ///
  /// In en, this message translates to:
  /// **'Manage staff members'**
  String get manageStaff;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get addEmployee;

  /// No description provided for @searchEmployees.
  ///
  /// In en, this message translates to:
  /// **'Search by name, username or email'**
  String get searchEmployees;

  /// No description provided for @noEmployeesMatch.
  ///
  /// In en, this message translates to:
  /// **'No employees match the filters.'**
  String get noEmployeesMatch;

  /// No description provided for @usernameAndEmail.
  ///
  /// In en, this message translates to:
  /// **'@{username} · {email}'**
  String usernameAndEmail(String username, String email);

  /// No description provided for @neverLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Never logged in'**
  String get neverLoggedIn;

  /// No description provided for @lastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last login {time}'**
  String lastLogin(String time);

  /// No description provided for @deleteEmployee.
  ///
  /// In en, this message translates to:
  /// **'Delete employee'**
  String get deleteEmployee;

  /// No description provided for @cannotDeleteOwnAccount.
  ///
  /// In en, this message translates to:
  /// **'You cannot delete your own account.'**
  String get cannotDeleteOwnAccount;

  /// No description provided for @employeeHasActivity.
  ///
  /// In en, this message translates to:
  /// **'Has orders, reservations or payments in the system. Deactivate the account instead.'**
  String get employeeHasActivity;

  /// No description provided for @editEmployee.
  ///
  /// In en, this message translates to:
  /// **'Edit employee'**
  String get editEmployee;

  /// No description provided for @addEmployeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add employee'**
  String get addEmployeeTitle;

  /// No description provided for @accountUpdated.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s account was updated.'**
  String accountUpdated(String name);

  /// No description provided for @employeeAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} was added as {role}.'**
  String employeeAdded(String name, String role);

  /// No description provided for @usernameHelper.
  ///
  /// In en, this message translates to:
  /// **'Used to log in, e.g. john.smith'**
  String get usernameHelper;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @cannotChangeOwnRole.
  ///
  /// In en, this message translates to:
  /// **'You cannot change your own role'**
  String get cannotChangeOwnRole;

  /// No description provided for @roleHelper.
  ///
  /// In en, this message translates to:
  /// **'The role decides which app and screens the employee can use'**
  String get roleHelper;

  /// No description provided for @roleRequired.
  ///
  /// In en, this message translates to:
  /// **'Role is required.'**
  String get roleRequired;

  /// No description provided for @cannotDeactivateOwnAccount.
  ///
  /// In en, this message translates to:
  /// **'You cannot deactivate your own account'**
  String get cannotDeactivateOwnAccount;

  /// No description provided for @inactiveCannotLogIn.
  ///
  /// In en, this message translates to:
  /// **'Inactive employees cannot log in'**
  String get inactiveCannotLogIn;

  /// No description provided for @loggedOutEverywhere.
  ///
  /// In en, this message translates to:
  /// **'The employee is logged out on all devices after the change'**
  String get loggedOutEverywhere;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The image is larger than 2 MB. Choose a smaller JPEG, PNG or WebP image.'**
  String get imageTooLarge;

  /// No description provided for @savedButImageFailed.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was saved, but the image was not: {error}'**
  String savedButImageFailed(String name, String error);

  /// No description provided for @itemUpdated.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was updated.'**
  String itemUpdated(String name);

  /// No description provided for @itemAddedToMenu.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was added to the menu.'**
  String itemAddedToMenu(String name);

  /// No description provided for @editMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Edit menu item'**
  String get editMenuItem;

  /// No description provided for @addMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Add menu item'**
  String get addMenuItem;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeImage;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get addImage;

  /// No description provided for @nameHintDish.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ribeye Steak'**
  String get nameHintDish;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 300 g grilled ribeye with herb butter'**
  String get descriptionHint;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @categoryWithStation.
  ///
  /// In en, this message translates to:
  /// **'{name} ({station})'**
  String categoryWithStation(String name, String station);

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category is required.'**
  String get categoryRequired;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add a new category'**
  String get addNewCategory;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get newTag;

  /// No description provided for @availableToday.
  ///
  /// In en, this message translates to:
  /// **'Available today'**
  String get availableToday;

  /// No description provided for @unavailableHidden.
  ///
  /// In en, this message translates to:
  /// **'Unavailable items are hidden from the waiters\' menu'**
  String get unavailableHidden;

  /// No description provided for @addEntity.
  ///
  /// In en, this message translates to:
  /// **'Add {entity}'**
  String addEntity(String entity);

  /// No description provided for @editEntity.
  ///
  /// In en, this message translates to:
  /// **'Edit {entity}'**
  String editEntity(String entity);

  /// No description provided for @entityAdded.
  ///
  /// In en, this message translates to:
  /// **'{entity} \"{name}\" was added.'**
  String entityAdded(String entity, String name);

  /// No description provided for @entityUpdated.
  ///
  /// In en, this message translates to:
  /// **'{entity} \"{name}\" was updated.'**
  String entityUpdated(String entity, String name);

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @categoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Category \"{name}\" was added.'**
  String categoryAdded(String name);

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category \"{name}\" was updated.'**
  String categoryUpdated(String name);

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Main Course'**
  String get categoryNameHint;

  /// No description provided for @courseType.
  ///
  /// In en, this message translates to:
  /// **'Course type'**
  String get courseType;

  /// No description provided for @courseTypeHelper.
  ///
  /// In en, this message translates to:
  /// **'Used by the recommender to complete a meal'**
  String get courseTypeHelper;

  /// No description provided for @courseTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Course type is required.'**
  String get courseTypeRequired;

  /// No description provided for @preparedAt.
  ///
  /// In en, this message translates to:
  /// **'Prepared at'**
  String get preparedAt;

  /// No description provided for @preparedAtHelper.
  ///
  /// In en, this message translates to:
  /// **'Items of this category are sent to this station'**
  String get preparedAtHelper;

  /// No description provided for @stationRequired.
  ///
  /// In en, this message translates to:
  /// **'Preparation station is required.'**
  String get stationRequired;

  /// No description provided for @sortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort order'**
  String get sortOrder;

  /// No description provided for @sortOrderHelper.
  ///
  /// In en, this message translates to:
  /// **'Lower numbers are shown first in the menu'**
  String get sortOrderHelper;

  /// No description provided for @editCurrency.
  ///
  /// In en, this message translates to:
  /// **'Edit currency'**
  String get editCurrency;

  /// No description provided for @addCurrency.
  ///
  /// In en, this message translates to:
  /// **'Add currency'**
  String get addCurrency;

  /// No description provided for @currencyAdded.
  ///
  /// In en, this message translates to:
  /// **'Currency {code} was added.'**
  String currencyAdded(String code);

  /// No description provided for @currencyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Currency {code} was updated.'**
  String currencyUpdated(String code);

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @codeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. EUR'**
  String get codeHint;

  /// No description provided for @codeLocked.
  ///
  /// In en, this message translates to:
  /// **'The code cannot change while orders or the settings use this currency'**
  String get codeLocked;

  /// No description provided for @currencyCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Currency code must be exactly 3 uppercase letters (ISO 4217), e.g. EUR.'**
  String get currencyCodeInvalid;

  /// No description provided for @currencyNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Euro'**
  String get currencyNameHint;

  /// No description provided for @symbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get symbol;

  /// No description provided for @reservationDate.
  ///
  /// In en, this message translates to:
  /// **'Reservation date'**
  String get reservationDate;

  /// No description provided for @arrivalTime.
  ///
  /// In en, this message translates to:
  /// **'Arrival time'**
  String get arrivalTime;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @startMustBeFuture.
  ///
  /// In en, this message translates to:
  /// **'Start time must be in the future.'**
  String get startMustBeFuture;

  /// No description provided for @editReservation.
  ///
  /// In en, this message translates to:
  /// **'Edit reservation'**
  String get editReservation;

  /// No description provided for @newReservation.
  ///
  /// In en, this message translates to:
  /// **'New reservation'**
  String get newReservation;

  /// No description provided for @reservationUpdated.
  ///
  /// In en, this message translates to:
  /// **'The reservation for {name} was updated.'**
  String reservationUpdated(String name);

  /// No description provided for @reservationCreated.
  ///
  /// In en, this message translates to:
  /// **'Reservation for {name} at table {table} on {time} was created. Confirm it to notify the guest.'**
  String reservationCreated(String name, int table, String time);

  /// No description provided for @guestName.
  ///
  /// In en, this message translates to:
  /// **'Guest name'**
  String get guestName;

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guests;

  /// No description provided for @partySize.
  ///
  /// In en, this message translates to:
  /// **'Party size'**
  String get partySize;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @guestGetsEmail.
  ///
  /// In en, this message translates to:
  /// **'The guest gets a confirmation email'**
  String get guestGetsEmail;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @tableChecksHelper.
  ///
  /// In en, this message translates to:
  /// **'Overlapping reservations and capacity are checked when saving'**
  String get tableChecksHelper;

  /// No description provided for @tableOption.
  ///
  /// In en, this message translates to:
  /// **'Table {number} · {seats} · {area}'**
  String tableOption(int number, String seats, String area);

  /// No description provided for @tableRequired.
  ///
  /// In en, this message translates to:
  /// **'Table is required.'**
  String get tableRequired;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @reservationNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Birthday, needs a high chair'**
  String get reservationNoteHint;

  /// No description provided for @editTable.
  ///
  /// In en, this message translates to:
  /// **'Edit table {number}'**
  String editTable(int number);

  /// No description provided for @addTable.
  ///
  /// In en, this message translates to:
  /// **'Add table'**
  String get addTable;

  /// No description provided for @tableAdded.
  ///
  /// In en, this message translates to:
  /// **'Table {number} ({seats}, {area}) was added.'**
  String tableAdded(int number, String seats, String area);

  /// No description provided for @tableUpdated.
  ///
  /// In en, this message translates to:
  /// **'Table {number} ({seats}, {area}) was updated.'**
  String tableUpdated(int number, String seats, String area);

  /// No description provided for @tableNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Table number'**
  String get tableNumberLabel;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @seats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seats;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @areaRequired.
  ///
  /// In en, this message translates to:
  /// **'Area is required.'**
  String get areaRequired;

  /// No description provided for @addNewArea.
  ///
  /// In en, this message translates to:
  /// **'Add a new area'**
  String get addNewArea;

  /// No description provided for @inUse.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get inUse;

  /// No description provided for @notInUseHelper.
  ///
  /// In en, this message translates to:
  /// **'Tables not in use cannot be ordered at or reserved'**
  String get notInUseHelper;

  /// No description provided for @availableAgain.
  ///
  /// In en, this message translates to:
  /// **'{name} is available again today.'**
  String availableAgain(String name);

  /// No description provided for @nowHidden.
  ///
  /// In en, this message translates to:
  /// **'{name} is now hidden from the waiters\' menu.'**
  String nowHidden(String name);

  /// No description provided for @removeItemQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"?'**
  String removeItemQuestion(String name);

  /// No description provided for @removeItemMessage.
  ///
  /// In en, this message translates to:
  /// **'The item disappears from the menu. Past orders keep it, so sales reports stay correct.'**
  String get removeItemMessage;

  /// No description provided for @itemRemoved.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was removed from the menu.'**
  String itemRemoved(String name);

  /// No description provided for @manageMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage menu items and availability'**
  String get manageMenuSubtitle;

  /// No description provided for @addCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a menu category first (Reference Data → Categories).'**
  String get addCategoryFirst;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableLabel;

  /// No description provided for @noMenuItemsMatch.
  ///
  /// In en, this message translates to:
  /// **'No menu items match the filters.'**
  String get noMenuItemsMatch;

  /// No description provided for @columnItem.
  ///
  /// In en, this message translates to:
  /// **'ITEM'**
  String get columnItem;

  /// No description provided for @columnCategory.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get columnCategory;

  /// No description provided for @columnPrice.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get columnPrice;

  /// No description provided for @columnType.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get columnType;

  /// No description provided for @columnOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'ORDER'**
  String get columnOrderNumber;

  /// No description provided for @columnOpened.
  ///
  /// In en, this message translates to:
  /// **'OPENED'**
  String get columnOpened;

  /// No description provided for @columnTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get columnTotal;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'food'**
  String get food;

  /// No description provided for @drinkWord.
  ///
  /// In en, this message translates to:
  /// **'drink'**
  String get drinkWord;

  /// No description provided for @columnAvailableToday.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE TODAY'**
  String get columnAvailableToday;

  /// No description provided for @columnActions.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get columnActions;

  /// No description provided for @removeFromMenu.
  ///
  /// In en, this message translates to:
  /// **'Remove from menu'**
  String get removeFromMenu;

  /// No description provided for @allMarkedRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications are marked as read.'**
  String get allMarkedRead;

  /// No description provided for @youAreAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up'**
  String get youAreAllCaughtUp;

  /// No description provided for @ordersOpenedBetween.
  ///
  /// In en, this message translates to:
  /// **'Orders opened between'**
  String get ordersOpenedBetween;

  /// No description provided for @ordersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every bill with its items, kitchen/bar tickets, payments and refunds'**
  String get ordersSubtitle;

  /// No description provided for @orderNumberOrTable.
  ///
  /// In en, this message translates to:
  /// **'Order number or table'**
  String get orderNumberOrTable;

  /// No description provided for @noOrdersMatch.
  ///
  /// In en, this message translates to:
  /// **'No orders match the filters.'**
  String get noOrdersMatch;

  /// No description provided for @cancelOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Cancel order {order}'**
  String cancelOrderNumber(String order);

  /// No description provided for @cancelOrderTicketsMessage.
  ///
  /// In en, this message translates to:
  /// **'Tickets that were not started are cancelled and the kitchen and bar are notified.'**
  String get cancelOrderTicketsMessage;

  /// No description provided for @orderCancelledFor.
  ///
  /// In en, this message translates to:
  /// **'Order {order} for table {table} was cancelled.'**
  String orderCancelledFor(String order, int table);

  /// No description provided for @orderNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Order {order}'**
  String orderNumberTitle(String order);

  /// No description provided for @orderDetailsLine.
  ///
  /// In en, this message translates to:
  /// **'Table {table} · {guests} · {waiter} · opened {time}'**
  String orderDetailsLine(int table, String guests, String waiter, String time);

  /// No description provided for @cancelledReason.
  ///
  /// In en, this message translates to:
  /// **'Cancelled: {reason}'**
  String cancelledReason(String reason);

  /// No description provided for @kitchenAndBarTickets.
  ///
  /// In en, this message translates to:
  /// **'Kitchen and bar tickets'**
  String get kitchenAndBarTickets;

  /// No description provided for @ticketLine.
  ///
  /// In en, this message translates to:
  /// **'{ticket} · {station} · {status}'**
  String ticketLine(String ticket, String station, String status);

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet.'**
  String get noPaymentsYet;

  /// No description provided for @paymentLine.
  ///
  /// In en, this message translates to:
  /// **'{method} · {amount}'**
  String paymentLine(String method, String amount);

  /// No description provided for @paymentLineWithTip.
  ///
  /// In en, this message translates to:
  /// **'{method} · {amount} (incl. {tip} tip)'**
  String paymentLineWithTip(String method, String amount, String tip);

  /// No description provided for @refundUpTo.
  ///
  /// In en, this message translates to:
  /// **'Refund up to {amount}'**
  String refundUpTo(String amount);

  /// No description provided for @nothingToRefund.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to refund on this payment.'**
  String get nothingToRefund;

  /// No description provided for @paymentProcessedLine.
  ///
  /// In en, this message translates to:
  /// **'{name} · {time}'**
  String paymentProcessedLine(String name, String time);

  /// No description provided for @cashReceivedLine.
  ///
  /// In en, this message translates to:
  /// **' · received {received}, change {change}'**
  String cashReceivedLine(String received, String change);

  /// No description provided for @refundedLine.
  ///
  /// In en, this message translates to:
  /// **'↩ {amount} refunded by {name} on {time} – {reason}'**
  String refundedLine(String amount, String name, String time, String reason);

  /// No description provided for @orderMustBePaid.
  ///
  /// In en, this message translates to:
  /// **'Items are already being prepared or were served, so the order has to be paid.'**
  String get orderMustBePaid;

  /// No description provided for @refundPayment.
  ///
  /// In en, this message translates to:
  /// **'Refund payment'**
  String get refundPayment;

  /// No description provided for @refundAmountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Refund {amount}?'**
  String refundAmountQuestion(String amount);

  /// No description provided for @refundPayPalMessage.
  ///
  /// In en, this message translates to:
  /// **'The money is returned to the guest\'s PayPal account. This cannot be undone.'**
  String get refundPayPalMessage;

  /// No description provided for @refundCashMessage.
  ///
  /// In en, this message translates to:
  /// **'Give the cash back to the guest. This cannot be undone.'**
  String get refundCashMessage;

  /// No description provided for @refundCompleted.
  ///
  /// In en, this message translates to:
  /// **'Refund of {amount} for order {order} was completed.'**
  String refundCompleted(String amount, String order);

  /// No description provided for @refundIntro.
  ///
  /// In en, this message translates to:
  /// **'{method} payment of {amount}. Up to {refundable} can still be refunded.'**
  String refundIntro(String method, String amount, String refundable);

  /// No description provided for @atMost.
  ///
  /// In en, this message translates to:
  /// **'At most {amount}'**
  String atMost(String amount);

  /// No description provided for @refundAmount.
  ///
  /// In en, this message translates to:
  /// **'Refund amount'**
  String get refundAmount;

  /// No description provided for @refundReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Steak was overcooked'**
  String get refundReasonHint;

  /// No description provided for @referenceDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lists used by the menu, tables and payments'**
  String get referenceDataSubtitle;

  /// No description provided for @menuCategories.
  ///
  /// In en, this message translates to:
  /// **'Menu categories'**
  String get menuCategories;

  /// No description provided for @itemTags.
  ///
  /// In en, this message translates to:
  /// **'Item tags'**
  String get itemTags;

  /// No description provided for @tableAreas.
  ///
  /// In en, this message translates to:
  /// **'Table areas'**
  String get tableAreas;

  /// No description provided for @currencies.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get currencies;

  /// No description provided for @systemLists.
  ///
  /// In en, this message translates to:
  /// **'System lists'**
  String get systemLists;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get searchCategories;

  /// No description provided for @columnName.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get columnName;

  /// No description provided for @columnCourse.
  ///
  /// In en, this message translates to:
  /// **'COURSE'**
  String get columnCourse;

  /// No description provided for @columnPreparedAt.
  ///
  /// In en, this message translates to:
  /// **'PREPARED AT'**
  String get columnPreparedAt;

  /// No description provided for @columnOrder.
  ///
  /// In en, this message translates to:
  /// **'ORDER'**
  String get columnOrder;

  /// No description provided for @columnItems.
  ///
  /// In en, this message translates to:
  /// **'ITEMS'**
  String get columnItems;

  /// No description provided for @categoryInUse.
  ///
  /// In en, this message translates to:
  /// **'Used by {count, plural, =1{1 menu item} other{{count} menu items}}, including removed items kept for order history.'**
  String categoryInUse(int count);

  /// No description provided for @searchTags.
  ///
  /// In en, this message translates to:
  /// **'Search tags'**
  String get searchTags;

  /// No description provided for @columnMenuItems.
  ///
  /// In en, this message translates to:
  /// **'MENU ITEMS'**
  String get columnMenuItems;

  /// No description provided for @tagInUse.
  ///
  /// In en, this message translates to:
  /// **'Used by {count, plural, =1{1 menu item} other{{count} menu items}}. Remove it from those items first.'**
  String tagInUse(int count);

  /// No description provided for @searchAreas.
  ///
  /// In en, this message translates to:
  /// **'Search areas'**
  String get searchAreas;

  /// No description provided for @columnTables.
  ///
  /// In en, this message translates to:
  /// **'TABLES'**
  String get columnTables;

  /// No description provided for @areaInUse.
  ///
  /// In en, this message translates to:
  /// **'Has {count, plural, =1{1 table} other{{count} tables}}. Move or delete them first.'**
  String areaInUse(int count);

  /// No description provided for @searchCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Search currencies'**
  String get searchCurrencies;

  /// No description provided for @columnCode.
  ///
  /// In en, this message translates to:
  /// **'CODE'**
  String get columnCode;

  /// No description provided for @columnSymbol.
  ///
  /// In en, this message translates to:
  /// **'SYMBOL'**
  String get columnSymbol;

  /// No description provided for @columnInUse.
  ///
  /// In en, this message translates to:
  /// **'IN USE'**
  String get columnInUse;

  /// No description provided for @currencyInUse.
  ///
  /// In en, this message translates to:
  /// **'Used by the restaurant settings or by existing orders.'**
  String get currencyInUse;

  /// No description provided for @deleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteQuestion(String name);

  /// No description provided for @removedPermanently.
  ///
  /// In en, this message translates to:
  /// **'It is removed permanently.'**
  String get removedPermanently;

  /// No description provided for @entityDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was deleted.'**
  String entityDeleted(String name);

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found.'**
  String get nothingFound;

  /// No description provided for @systemListsInfo.
  ///
  /// In en, this message translates to:
  /// **'These lists are fixed. Roles decide what each employee may do, stations decide where orders are sent, and payment methods are tied to the cash and PayPal flows, so renaming or deleting them would break those features.'**
  String get systemListsInfo;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @preparationStations.
  ///
  /// In en, this message translates to:
  /// **'Preparation stations'**
  String get preparationStations;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethods;

  /// No description provided for @entityCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get entityCategory;

  /// No description provided for @entityTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get entityTag;

  /// No description provided for @entityArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get entityArea;

  /// No description provided for @entityCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get entityCurrency;

  /// No description provided for @addCategoryButton.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategoryButton;

  /// No description provided for @addTagButton.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTagButton;

  /// No description provided for @addAreaButton.
  ///
  /// In en, this message translates to:
  /// **'Add area'**
  String get addAreaButton;

  /// No description provided for @addCurrencyButton.
  ///
  /// In en, this message translates to:
  /// **'Add currency'**
  String get addCurrencyButton;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Report period'**
  String get reportPeriod;

  /// No description provided for @reportSaved.
  ///
  /// In en, this message translates to:
  /// **'The report was saved to {path}.'**
  String reportSaved(String path);

  /// No description provided for @reportSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The report could not be saved: {error}'**
  String reportSaveFailed(String error);

  /// No description provided for @salesAndAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Sales & Analytics'**
  String get salesAndAnalytics;

  /// No description provided for @salesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track performance and revenue metrics'**
  String get salesSubtitle;

  /// No description provided for @salesReport.
  ///
  /// In en, this message translates to:
  /// **'Sales report'**
  String get salesReport;

  /// No description provided for @staffReport.
  ///
  /// In en, this message translates to:
  /// **'Staff report'**
  String get staffReport;

  /// No description provided for @periodAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Period analysis'**
  String get periodAnalysis;

  /// No description provided for @lastDays.
  ///
  /// In en, this message translates to:
  /// **'Last {count} days'**
  String lastDays(int count);

  /// No description provided for @sameAs.
  ///
  /// In en, this message translates to:
  /// **'Same as {when}'**
  String sameAs(String when);

  /// No description provided for @firstSalesComparedTo.
  ///
  /// In en, this message translates to:
  /// **'First sales compared to {when}'**
  String firstSalesComparedTo(String when);

  /// No description provided for @percentFrom.
  ///
  /// In en, this message translates to:
  /// **'{change}% from {when}'**
  String percentFrom(String change, String when);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get yesterday;

  /// No description provided for @todaysRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s revenue'**
  String get todaysRevenue;

  /// No description provided for @kpiGuests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get kpiGuests;

  /// No description provided for @paidOrders.
  ///
  /// In en, this message translates to:
  /// **'Paid orders'**
  String get paidOrders;

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'{count} active now'**
  String activeNow(int count);

  /// No description provided for @averageBill.
  ///
  /// In en, this message translates to:
  /// **'Average bill'**
  String get averageBill;

  /// No description provided for @tablesServed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 table served} other{{count} tables served}}'**
  String tablesServed(int count);

  /// No description provided for @popularItemsToday.
  ///
  /// In en, this message translates to:
  /// **'Popular items today'**
  String get popularItemsToday;

  /// No description provided for @noSalesToday.
  ///
  /// In en, this message translates to:
  /// **'No sales yet today.'**
  String get noSalesToday;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @netRevenueAfterRefunds.
  ///
  /// In en, this message translates to:
  /// **'Net revenue (after refunds)'**
  String get netRevenueAfterRefunds;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @refunds.
  ///
  /// In en, this message translates to:
  /// **'Refunds'**
  String get refunds;

  /// No description provided for @cancelledOrders.
  ///
  /// In en, this message translates to:
  /// **'Cancelled orders'**
  String get cancelledOrders;

  /// No description provided for @dailyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Daily revenue'**
  String get dailyRevenue;

  /// No description provided for @bestSellingItems.
  ///
  /// In en, this message translates to:
  /// **'Best-selling items'**
  String get bestSellingItems;

  /// No description provided for @leastSellingItems.
  ///
  /// In en, this message translates to:
  /// **'Least-selling items'**
  String get leastSellingItems;

  /// No description provided for @promotionCandidates.
  ///
  /// In en, this message translates to:
  /// **'Candidates for a promotion or removal'**
  String get promotionCandidates;

  /// No description provided for @salesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Sales by category'**
  String get salesByCategory;

  /// No description provided for @soldAndRevenue.
  ///
  /// In en, this message translates to:
  /// **'{count} sold · {revenue}'**
  String soldAndRevenue(int count, String revenue);

  /// No description provided for @paymentsByMethod.
  ///
  /// In en, this message translates to:
  /// **'Payments by method'**
  String get paymentsByMethod;

  /// No description provided for @paymentsAndAmount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment} other{{count} payments}} · {amount}'**
  String paymentsAndAmount(int count, String amount);

  /// No description provided for @staffPerformance.
  ///
  /// In en, this message translates to:
  /// **'Staff performance'**
  String get staffPerformance;

  /// No description provided for @columnWaiter.
  ///
  /// In en, this message translates to:
  /// **'WAITER'**
  String get columnWaiter;

  /// No description provided for @columnOrders.
  ///
  /// In en, this message translates to:
  /// **'ORDERS'**
  String get columnOrders;

  /// No description provided for @columnRevenue.
  ///
  /// In en, this message translates to:
  /// **'REVENUE'**
  String get columnRevenue;

  /// No description provided for @columnAvgBill.
  ///
  /// In en, this message translates to:
  /// **'AVG. BILL'**
  String get columnAvgBill;

  /// No description provided for @columnTips.
  ///
  /// In en, this message translates to:
  /// **'TIPS'**
  String get columnTips;

  /// No description provided for @columnSuggestionsAccepted.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTIONS ACCEPTED'**
  String get columnSuggestionsAccepted;

  /// No description provided for @nameInactive.
  ///
  /// In en, this message translates to:
  /// **'{name} (inactive)'**
  String nameInactive(String name);

  /// No description provided for @percentOf.
  ///
  /// In en, this message translates to:
  /// **'{percent} of {total}'**
  String percentOf(String percent, int total);

  /// No description provided for @stationTickets.
  ///
  /// In en, this message translates to:
  /// **'{station}: {count, plural, =1{1 ticket} other{{count} tickets}}'**
  String stationTickets(String station, int count);

  /// No description provided for @minutesToReady.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min to ready'**
  String minutesToReady(String minutes);

  /// No description provided for @reportPdfTooltip.
  ///
  /// In en, this message translates to:
  /// **'{label} (PDF) for the selected period'**
  String reportPdfTooltip(String label);

  /// No description provided for @saveAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Save as PDF'**
  String get saveAsPdf;

  /// No description provided for @soldAndCategory.
  ///
  /// In en, this message translates to:
  /// **'{count} sold · {category}'**
  String soldAndCategory(int count, String category);

  /// No description provided for @chartTooltip.
  ///
  /// In en, this message translates to:
  /// **'{date}\n{amount} · {orders}'**
  String chartTooltip(String date, String amount, String orders);

  /// No description provided for @orderCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order} other{{count} orders}}'**
  String orderCount(int count);

  /// No description provided for @reservationsBetween.
  ///
  /// In en, this message translates to:
  /// **'Reservations between'**
  String get reservationsBetween;

  /// No description provided for @cancelReservation.
  ///
  /// In en, this message translates to:
  /// **'Cancel reservation'**
  String get cancelReservation;

  /// No description provided for @cancelReservationMessage.
  ///
  /// In en, this message translates to:
  /// **'Cancel {name}\'s reservation for {time}? Waiters are notified.'**
  String cancelReservationMessage(String name, String time);

  /// No description provided for @cancelReservationEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Cancel {name}\'s reservation for {time}? The guest gets an email and waiters are notified.'**
  String cancelReservationEmailMessage(String name, String time);

  /// No description provided for @reservationCancelledFor.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s reservation was cancelled.'**
  String reservationCancelledFor(String name);

  /// No description provided for @reservationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book tables and follow each reservation through its statuses'**
  String get reservationsSubtitle;

  /// No description provided for @newReservationButton.
  ///
  /// In en, this message translates to:
  /// **'New Reservation'**
  String get newReservationButton;

  /// No description provided for @guestNameOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Guest name or phone'**
  String get guestNameOrPhone;

  /// No description provided for @noReservationsMatch.
  ///
  /// In en, this message translates to:
  /// **'No reservations match the filters.'**
  String get noReservationsMatch;

  /// No description provided for @columnGuest.
  ///
  /// In en, this message translates to:
  /// **'GUEST'**
  String get columnGuest;

  /// No description provided for @columnWhen.
  ///
  /// In en, this message translates to:
  /// **'WHEN'**
  String get columnWhen;

  /// No description provided for @columnTable.
  ///
  /// In en, this message translates to:
  /// **'TABLE'**
  String get columnTable;

  /// No description provided for @columnGuests.
  ///
  /// In en, this message translates to:
  /// **'GUESTS'**
  String get columnGuests;

  /// No description provided for @columnStatus.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get columnStatus;

  /// No description provided for @timeRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String timeRange(String start, String end);

  /// No description provided for @confirmEmailsGuest.
  ///
  /// In en, this message translates to:
  /// **'Confirm (emails the guest)'**
  String get confirmEmailsGuest;

  /// No description provided for @reservationConfirmedFor.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s reservation is confirmed.'**
  String reservationConfirmedFor(String name);

  /// No description provided for @guestsArrived.
  ///
  /// In en, this message translates to:
  /// **'Guests arrived'**
  String get guestsArrived;

  /// No description provided for @arrivedTooEarly.
  ///
  /// In en, this message translates to:
  /// **'Guests can be marked as arrived from 30 minutes before the reservation.'**
  String get arrivedTooEarly;

  /// No description provided for @guestArrived.
  ///
  /// In en, this message translates to:
  /// **'{name} has arrived; reservation completed.'**
  String guestArrived(String name);

  /// No description provided for @noShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get noShow;

  /// No description provided for @noShowTooEarly.
  ///
  /// In en, this message translates to:
  /// **'A no-show can be recorded 15 minutes after the reservation starts.'**
  String get noShowTooEarly;

  /// No description provided for @markedNoShow.
  ///
  /// In en, this message translates to:
  /// **'{name} was marked as a no-show.'**
  String markedNoShow(String name);

  /// No description provided for @tableAndGuests.
  ///
  /// In en, this message translates to:
  /// **'Table {table} · {guests}'**
  String tableAndGuests(int table, String guests);

  /// No description provided for @createdByOn.
  ///
  /// In en, this message translates to:
  /// **'Created by {name} on {time}'**
  String createdByOn(String name, String time);

  /// No description provided for @createdAs.
  ///
  /// In en, this message translates to:
  /// **'Created as {status}'**
  String createdAs(String status);

  /// No description provided for @statusChange.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String statusChange(String from, String to);

  /// No description provided for @saveSettingsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Save settings?'**
  String get saveSettingsQuestion;

  /// No description provided for @saveSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'New orders use the new VAT rate and currency. Open orders keep the values they were opened with.'**
  String get saveSettingsMessage;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved: {name}, {currency}, VAT {rate}%.'**
  String settingsSaved(String name, String currency, String rate);

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @configurePreferences.
  ///
  /// In en, this message translates to:
  /// **'Configure restaurant preferences'**
  String get configurePreferences;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @restaurantName.
  ///
  /// In en, this message translates to:
  /// **'Restaurant name'**
  String get restaurantName;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currencyHelper.
  ///
  /// In en, this message translates to:
  /// **'PayPal payments are charged in this currency'**
  String get currencyHelper;

  /// No description provided for @currencyOption.
  ///
  /// In en, this message translates to:
  /// **'{code} ({symbol}) – {name}'**
  String currencyOption(String code, String symbol, String name);

  /// No description provided for @currencyRequired.
  ///
  /// In en, this message translates to:
  /// **'Currency is required.'**
  String get currencyRequired;

  /// No description provided for @addNewCurrency.
  ///
  /// In en, this message translates to:
  /// **'Add a new currency'**
  String get addNewCurrency;

  /// No description provided for @vatRatePercent.
  ///
  /// In en, this message translates to:
  /// **'VAT rate (%)'**
  String get vatRatePercent;

  /// No description provided for @vatRateHelper.
  ///
  /// In en, this message translates to:
  /// **'Included in menu prices; receipts show how much of the total is VAT'**
  String get vatRateHelper;

  /// No description provided for @vatRate.
  ///
  /// In en, this message translates to:
  /// **'VAT rate'**
  String get vatRate;

  /// No description provided for @lastChanged.
  ///
  /// In en, this message translates to:
  /// **'Last changed {time}'**
  String lastChanged(String time);

  /// No description provided for @lastChangedBy.
  ///
  /// In en, this message translates to:
  /// **'Last changed {time} by {name}'**
  String lastChangedBy(String time, String name);

  /// No description provided for @myPreferences.
  ///
  /// In en, this message translates to:
  /// **'My preferences'**
  String get myPreferences;

  /// No description provided for @myPreferencesHint.
  ///
  /// In en, this message translates to:
  /// **'Only for your account. Notifications and PDF reports use this language too.'**
  String get myPreferencesHint;

  /// No description provided for @deleteTableQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete table {number}?'**
  String deleteTableQuestion(int number);

  /// No description provided for @tableRemovedPermanently.
  ///
  /// In en, this message translates to:
  /// **'The table is removed permanently.'**
  String get tableRemovedPermanently;

  /// No description provided for @tableDeleted.
  ///
  /// In en, this message translates to:
  /// **'Table {number} was deleted.'**
  String tableDeleted(int number);

  /// No description provided for @tablesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seating plan with live status'**
  String get tablesSubtitle;

  /// No description provided for @addAreaFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a table area first (Reference Data → Table areas).'**
  String get addAreaFirst;

  /// No description provided for @addTableButton.
  ///
  /// In en, this message translates to:
  /// **'Add Table'**
  String get addTableButton;

  /// No description provided for @noTablesMatch.
  ///
  /// In en, this message translates to:
  /// **'No tables match the filters.'**
  String get noTablesMatch;

  /// No description provided for @columnArea.
  ///
  /// In en, this message translates to:
  /// **'AREA'**
  String get columnArea;

  /// No description provided for @columnSeats.
  ///
  /// In en, this message translates to:
  /// **'SEATS'**
  String get columnSeats;

  /// No description provided for @columnCurrentBill.
  ///
  /// In en, this message translates to:
  /// **'CURRENT BILL'**
  String get columnCurrentBill;

  /// No description provided for @columnNextReservation.
  ///
  /// In en, this message translates to:
  /// **'NEXT RESERVATION'**
  String get columnNextReservation;

  /// No description provided for @tableNotInUse.
  ///
  /// In en, this message translates to:
  /// **'Table {number} (not in use)'**
  String tableNotInUse(int number);

  /// No description provided for @billAndGuests.
  ///
  /// In en, this message translates to:
  /// **'{amount} · {guests}'**
  String billAndGuests(String amount, String guests);

  /// No description provided for @reservationTimeAndGuest.
  ///
  /// In en, this message translates to:
  /// **'{time} · {name}'**
  String reservationTimeAndGuest(String time, String name);

  /// No description provided for @deleteTable.
  ///
  /// In en, this message translates to:
  /// **'Delete table'**
  String get deleteTable;

  /// No description provided for @tableHasHistory.
  ///
  /// In en, this message translates to:
  /// **'The table has orders or reservations in its history. Mark it as not in use instead.'**
  String get tableHasHistory;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @chooseView.
  ///
  /// In en, this message translates to:
  /// **'Choose what you\'d like to view'**
  String get chooseView;

  /// No description provided for @kitchenView.
  ///
  /// In en, this message translates to:
  /// **'Kitchen View'**
  String get kitchenView;

  /// No description provided for @monitorFood.
  ///
  /// In en, this message translates to:
  /// **'Monitor food orders'**
  String get monitorFood;

  /// No description provided for @barView.
  ///
  /// In en, this message translates to:
  /// **'Bar View'**
  String get barView;

  /// No description provided for @monitorDrinks.
  ///
  /// In en, this message translates to:
  /// **'Monitor drink orders'**
  String get monitorDrinks;

  /// No description provided for @manageSystem.
  ///
  /// In en, this message translates to:
  /// **'Manage system'**
  String get manageSystem;

  /// No description provided for @staffLogin.
  ///
  /// In en, this message translates to:
  /// **'Staff Login'**
  String get staffLogin;

  /// No description provided for @demoAccounts.
  ///
  /// In en, this message translates to:
  /// **'Demo accounts (password: test)'**
  String get demoAccounts;

  /// No description provided for @demoDesktop.
  ///
  /// In en, this message translates to:
  /// **'• desktop – admin panel'**
  String get demoDesktop;

  /// No description provided for @demoKitchen.
  ///
  /// In en, this message translates to:
  /// **'• kitchen – kitchen display'**
  String get demoKitchen;

  /// No description provided for @demoBar.
  ///
  /// In en, this message translates to:
  /// **'• bar – bar display'**
  String get demoBar;

  /// No description provided for @ticketBeingPrepared.
  ///
  /// In en, this message translates to:
  /// **'Ticket {ticket} for table {table} is being prepared.'**
  String ticketBeingPrepared(String ticket, int table);

  /// No description provided for @ticketReadyNotified.
  ///
  /// In en, this message translates to:
  /// **'Ticket {ticket} is ready. {waiter} has been notified.'**
  String ticketReadyNotified(String ticket, String waiter);

  /// No description provided for @kitchenDisplay.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Display'**
  String get kitchenDisplay;

  /// No description provided for @barDisplay.
  ///
  /// In en, this message translates to:
  /// **'Bar Display'**
  String get barDisplay;

  /// No description provided for @activeOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active order} other{{count} active orders}}'**
  String activeOrdersCount(int count);

  /// No description provided for @viewOnly.
  ///
  /// In en, this message translates to:
  /// **'View only'**
  String get viewOnly;

  /// No description provided for @noPendingFood.
  ///
  /// In en, this message translates to:
  /// **'No pending food orders'**
  String get noPendingFood;

  /// No description provided for @noPendingDrinks.
  ///
  /// In en, this message translates to:
  /// **'No pending drink orders'**
  String get noPendingDrinks;

  /// No description provided for @ticketTitle.
  ///
  /// In en, this message translates to:
  /// **'Order {ticket}'**
  String ticketTitle(String ticket);

  /// No description provided for @quantityPrefix.
  ///
  /// In en, this message translates to:
  /// **'x{quantity}'**
  String quantityPrefix(int quantity);

  /// No description provided for @startPreparing.
  ///
  /// In en, this message translates to:
  /// **'Start Preparing'**
  String get startPreparing;

  /// No description provided for @markAsReady.
  ///
  /// In en, this message translates to:
  /// **'Mark as Ready'**
  String get markAsReady;

  /// No description provided for @completeOrder.
  ///
  /// In en, this message translates to:
  /// **'Complete Order'**
  String get completeOrder;

  /// No description provided for @summaryNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get summaryNew;

  /// No description provided for @summaryPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get summaryPreparing;

  /// No description provided for @longestWait.
  ///
  /// In en, this message translates to:
  /// **'Longest wait'**
  String get longestWait;

  /// No description provided for @avgTimeToReadyToday.
  ///
  /// In en, this message translates to:
  /// **'Avg. time to ready today'**
  String get avgTimeToReadyToday;

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesValue(String minutes);

  /// No description provided for @completedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get completedToday;

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'{role} staff'**
  String roleStaff(String role);

  /// No description provided for @backToDashboardShort.
  ///
  /// In en, this message translates to:
  /// **'Back to dashboard'**
  String get backToDashboardShort;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String resultsCount(int count);

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {pages}'**
  String pageOf(int page, int pages);

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @tableNumber.
  ///
  /// In en, this message translates to:
  /// **'Table {number}'**
  String tableNumber(int number);

  /// No description provided for @tableAndOrder.
  ///
  /// In en, this message translates to:
  /// **'Table {number} · {order}'**
  String tableAndOrder(int number, String order);

  /// No description provided for @guestCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guest} other{{count} guests}}'**
  String guestCount(int count);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get logoutQuestion;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @enterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to continue'**
  String get enterCredentials;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @languageHint.
  ///
  /// In en, this message translates to:
  /// **'Notifications, emails and receipts use this language too.'**
  String get languageHint;

  /// No description provided for @payPal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get payPal;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @tipPercent.
  ///
  /// In en, this message translates to:
  /// **'Tip ({percent}%)'**
  String tipPercent(String percent);

  /// No description provided for @cashReceived.
  ///
  /// In en, this message translates to:
  /// **'Cash received'**
  String get cashReceived;

  /// No description provided for @reasonText.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String reasonText(String reason);

  /// No description provided for @quantityTimesPrice.
  ///
  /// In en, this message translates to:
  /// **'{price} × {quantity}'**
  String quantityTimesPrice(String price, int quantity);

  /// No description provided for @itemTimesQuantity.
  ///
  /// In en, this message translates to:
  /// **'{name} × {quantity}'**
  String itemTimesQuantity(String name, int quantity);

  /// No description provided for @passwordChangedLogIn.
  ///
  /// In en, this message translates to:
  /// **'Your password was changed. You can log in now.'**
  String get passwordChangedLogIn;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from the email and choose a new password.'**
  String get resetEnterCode;

  /// No description provided for @resetEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address of your account. We will send you a 6-digit code.'**
  String get resetEnterEmail;

  /// No description provided for @resetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset code'**
  String get resetCode;

  /// No description provided for @resetCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'The reset code has 6 digits.'**
  String get resetCodeInvalid;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters, with a letter and a number'**
  String get passwordHint;

  /// No description provided for @repeatNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get repeatNewPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @sendNewCode.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get sendNewCode;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @waiterLogin.
  ///
  /// In en, this message translates to:
  /// **'Waiter Login'**
  String get waiterLogin;

  /// No description provided for @demoAccount.
  ///
  /// In en, this message translates to:
  /// **'Demo account: '**
  String get demoAccount;

  /// No description provided for @activeTables.
  ///
  /// In en, this message translates to:
  /// **'Active Tables'**
  String get activeTables;

  /// No description provided for @tablesWithOrders.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 table with orders} other{{count} tables with orders}}'**
  String tablesWithOrders(int count);

  /// No description provided for @noOpenOrders.
  ///
  /// In en, this message translates to:
  /// **'You have no open orders.'**
  String get noOpenOrders;

  /// No description provided for @itemAddedInRound.
  ///
  /// In en, this message translates to:
  /// **'{name} added ({count} in this round)'**
  String itemAddedInRound(String name, int count);

  /// No description provided for @itemAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added.'**
  String itemAdded(String name);

  /// No description provided for @sendOrderQuestion.
  ///
  /// In en, this message translates to:
  /// **'Send order?'**
  String get sendOrderQuestion;

  /// No description provided for @sendOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'Send {items} ({total}) for table {table} to the kitchen and bar? Items cannot be removed once preparation starts.'**
  String sendOrderMessage(String items, String total, int table);

  /// No description provided for @sendOrder.
  ///
  /// In en, this message translates to:
  /// **'Send Order'**
  String get sendOrder;

  /// No description provided for @orderSentTo.
  ///
  /// In en, this message translates to:
  /// **'Order sent to the {stations}.'**
  String orderSentTo(String stations);

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @discardRoundQuestion.
  ///
  /// In en, this message translates to:
  /// **'Discard this round?'**
  String get discardRoundQuestion;

  /// No description provided for @discardRoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The {items} in the cart have not been sent yet.'**
  String discardRoundMessage(String items);

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @guestsAndItems.
  ///
  /// In en, this message translates to:
  /// **'{guests} · {items}'**
  String guestsAndItems(String guests, String items);

  /// No description provided for @addingToOrder.
  ///
  /// In en, this message translates to:
  /// **'Adding to {order} · {items}'**
  String addingToOrder(String order, String items);

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @searchMenu.
  ///
  /// In en, this message translates to:
  /// **'Search the menu'**
  String get searchMenu;

  /// No description provided for @currentOrder.
  ///
  /// In en, this message translates to:
  /// **'Current order'**
  String get currentOrder;

  /// No description provided for @searchByNameOrDescription.
  ///
  /// In en, this message translates to:
  /// **'Search by name or description'**
  String get searchByNameOrDescription;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get sending;

  /// No description provided for @reviewTotal.
  ///
  /// In en, this message translates to:
  /// **'Review · {total}'**
  String reviewTotal(String total);

  /// No description provided for @favoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your starred and most sold items · Updates based on your sales'**
  String get favoritesSubtitle;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet. Tap the star on any item to pin it here; your best sellers appear automatically.'**
  String get noFavorites;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found.'**
  String get noItemsFound;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get soldOut;

  /// No description provided for @soldCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sold'**
  String soldCount(int count);

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get allCaughtUp;

  /// No description provided for @unreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String unreadCount(int count);

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications.'**
  String get noNotifications;

  /// No description provided for @guideTablesTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Tables'**
  String get guideTablesTitle;

  /// No description provided for @guideTablesText.
  ///
  /// In en, this message translates to:
  /// **'Choose from available tables with capacity and status tracking. Green means available, red means occupied.'**
  String get guideTablesText;

  /// No description provided for @guideOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Take Orders'**
  String get guideOrdersTitle;

  /// No description provided for @guideOrdersText.
  ///
  /// In en, this message translates to:
  /// **'Browse the menu by category. Your favorites and best sellers are one tap away, and items sold out today are greyed out.'**
  String get guideOrdersText;

  /// No description provided for @guideSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Suggestions'**
  String get guideSuggestionsTitle;

  /// No description provided for @guideSuggestionsText.
  ///
  /// In en, this message translates to:
  /// **'After you add an item, Servio suggests what usually goes with it, based on what guests order together.'**
  String get guideSuggestionsText;

  /// No description provided for @guidePaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Serve & Get Paid'**
  String get guidePaymentTitle;

  /// No description provided for @guidePaymentText.
  ///
  /// In en, this message translates to:
  /// **'You are notified when the kitchen or bar has an order ready. Take payment in cash or through PayPal, with a tip.'**
  String get guidePaymentText;

  /// No description provided for @waiterGuide.
  ///
  /// In en, this message translates to:
  /// **'Waiter Guide'**
  String get waiterGuide;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @seatCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 seat} other{{count} seats}}'**
  String seatCount(int count);

  /// No description provided for @upsellSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Upsell Suggestion'**
  String get upsellSuggestion;

  /// No description provided for @guideUpsellQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would your guest like a drink with that?'**
  String get guideUpsellQuestion;

  /// No description provided for @addWithPlus.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get addWithPlus;

  /// No description provided for @guestsAndWaiter.
  ///
  /// In en, this message translates to:
  /// **'{guests} · {waiter}'**
  String guestsAndWaiter(String guests, String waiter);

  /// No description provided for @openedAt.
  ///
  /// In en, this message translates to:
  /// **'Opened {time}'**
  String openedAt(String time);

  /// No description provided for @closedAt.
  ///
  /// In en, this message translates to:
  /// **' · closed {time}'**
  String closedAt(String time);

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get amountPaid;

  /// No description provided for @refundOn.
  ///
  /// In en, this message translates to:
  /// **'Refund {date}'**
  String refundOn(String date);

  /// No description provided for @takenBy.
  ///
  /// In en, this message translates to:
  /// **'Taken by'**
  String get takenBy;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View receipt'**
  String get viewReceipt;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @yourClosedOrders.
  ///
  /// In en, this message translates to:
  /// **'Your closed orders'**
  String get yourClosedOrders;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders here yet.'**
  String get noOrdersYet;

  /// No description provided for @historyLine.
  ///
  /// In en, this message translates to:
  /// **'{date} · {items} · {guests}'**
  String historyLine(String date, String items, String guests);

  /// No description provided for @takePaymentQuestion.
  ///
  /// In en, this message translates to:
  /// **'Take payment?'**
  String get takePaymentQuestion;

  /// No description provided for @cashPaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'Record a cash payment of {amount} for table {table}?'**
  String cashPaymentMessage(String amount, int table);

  /// No description provided for @cashPaymentWithTipMessage.
  ///
  /// In en, this message translates to:
  /// **'Record a cash payment of {amount} including a {tip} tip for table {table}?'**
  String cashPaymentWithTipMessage(String amount, String tip, int table);

  /// No description provided for @giveChange.
  ///
  /// In en, this message translates to:
  /// **'Give {change} change.'**
  String giveChange(String change);

  /// No description provided for @cardPaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'Charge {amount} for table {table} through PayPal?'**
  String cardPaymentMessage(String amount, int table);

  /// No description provided for @cardPaymentWithTipMessage.
  ///
  /// In en, this message translates to:
  /// **'Charge {amount} including a {tip} tip for table {table} through PayPal?'**
  String cardPaymentWithTipMessage(String amount, String tip, int table);

  /// No description provided for @payPalCancelled.
  ///
  /// In en, this message translates to:
  /// **'The PayPal payment was cancelled. No money was taken.'**
  String get payPalCancelled;

  /// No description provided for @paymentNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment not confirmed'**
  String get paymentNotConfirmed;

  /// No description provided for @tablePaid.
  ///
  /// In en, this message translates to:
  /// **'Table {number} paid'**
  String tablePaid(int number);

  /// No description provided for @paidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get paidBy;

  /// No description provided for @processPayment.
  ///
  /// In en, this message translates to:
  /// **'Process Payment'**
  String get processPayment;

  /// No description provided for @stillBeingPrepared.
  ///
  /// In en, this message translates to:
  /// **'Some items are still being prepared. The bill can be paid once everything is ready.'**
  String get stillBeingPrepared;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @bill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get bill;

  /// No description provided for @totalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to pay'**
  String get totalToPay;

  /// No description provided for @tipAmount.
  ///
  /// In en, this message translates to:
  /// **'Tip Amount'**
  String get tipAmount;

  /// No description provided for @plusTip.
  ///
  /// In en, this message translates to:
  /// **'+ {tip} tip'**
  String plusTip(String tip);

  /// No description provided for @payPalSecurePage.
  ///
  /// In en, this message translates to:
  /// **'The guest pays on PayPal\'s secure page with their PayPal account.'**
  String get payPalSecurePage;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @completeCashPayment.
  ///
  /// In en, this message translates to:
  /// **'Complete Cash Payment'**
  String get completeCashPayment;

  /// No description provided for @enterCashReceived.
  ///
  /// In en, this message translates to:
  /// **'Enter Cash Received'**
  String get enterCashReceived;

  /// No description provided for @payWithPayPal.
  ///
  /// In en, this message translates to:
  /// **'Pay with PayPal'**
  String get payWithPayPal;

  /// No description provided for @cashReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Received'**
  String get cashReceivedTitle;

  /// No description provided for @stillMissing.
  ///
  /// In en, this message translates to:
  /// **'Still missing'**
  String get stillMissing;

  /// No description provided for @exact.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get exact;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @cancelPayment.
  ///
  /// In en, this message translates to:
  /// **'Cancel payment'**
  String get cancelPayment;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Your profile was saved.'**
  String get profileSaved;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Your password was changed.'**
  String get passwordChanged;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'Only orders that the kitchen and bar have not started can be cancelled. Why is it cancelled?'**
  String get cancelOrderMessage;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'The order was cancelled.'**
  String get orderCancelled;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @orderAndWaiter.
  ///
  /// In en, this message translates to:
  /// **'{order} · {waiter}'**
  String orderAndWaiter(String order, String waiter);

  /// No description provided for @welcomeName.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeName(String name);

  /// No description provided for @myActiveTables.
  ///
  /// In en, this message translates to:
  /// **'My active tables'**
  String get myActiveTables;

  /// No description provided for @myProfileMenu.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfileMenu;

  /// No description provided for @tableStatus.
  ///
  /// In en, this message translates to:
  /// **'Table Status'**
  String get tableStatus;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @occupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupied;

  /// No description provided for @reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// No description provided for @badgeAvailable.
  ///
  /// In en, this message translates to:
  /// **'AVAIL'**
  String get badgeAvailable;

  /// No description provided for @badgeOccupied.
  ///
  /// In en, this message translates to:
  /// **'OCC'**
  String get badgeOccupied;

  /// No description provided for @badgeReserved.
  ///
  /// In en, this message translates to:
  /// **'RES'**
  String get badgeReserved;

  /// No description provided for @allAreas.
  ///
  /// In en, this message translates to:
  /// **'All areas'**
  String get allAreas;

  /// No description provided for @noTablesInUse.
  ///
  /// In en, this message translates to:
  /// **'No tables are in use.'**
  String get noTablesInUse;

  /// No description provided for @maxSeats.
  ///
  /// In en, this message translates to:
  /// **'Max: {count}'**
  String maxSeats(int count);

  /// No description provided for @nowSeated.
  ///
  /// In en, this message translates to:
  /// **'Now: {count}'**
  String nowSeated(int count);

  /// No description provided for @reservationAt.
  ///
  /// In en, this message translates to:
  /// **'{time} · {guests}'**
  String reservationAt(String time, String guests);

  /// No description provided for @reservedFor.
  ///
  /// In en, this message translates to:
  /// **'Reserved for {name} at {time} ({guests}).'**
  String reservedFor(String name, String time, String guests);

  /// No description provided for @howManyGuests.
  ///
  /// In en, this message translates to:
  /// **'How many guests?'**
  String get howManyGuests;

  /// No description provided for @fewerGuests.
  ///
  /// In en, this message translates to:
  /// **'Fewer guests'**
  String get fewerGuests;

  /// No description provided for @moreGuests.
  ///
  /// In en, this message translates to:
  /// **'More guests'**
  String get moreGuests;

  /// No description provided for @tableSeats.
  ///
  /// In en, this message translates to:
  /// **'The table seats {count}.'**
  String tableSeats(int count);

  /// No description provided for @startOrder.
  ///
  /// In en, this message translates to:
  /// **'Start order'**
  String get startOrder;

  /// No description provided for @currentOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Order'**
  String get currentOrderTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'The cart is empty. Tap menu items to add them.'**
  String get cartEmpty;

  /// No description provided for @priceEach.
  ///
  /// In en, this message translates to:
  /// **'{price} each'**
  String priceEach(String price);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @oneLess.
  ///
  /// In en, this message translates to:
  /// **'One less'**
  String get oneLess;

  /// No description provided for @oneMore.
  ///
  /// In en, this message translates to:
  /// **'One more'**
  String get oneMore;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @alreadyOnOrder.
  ///
  /// In en, this message translates to:
  /// **'Already on {order}'**
  String alreadyOnOrder(String order);

  /// No description provided for @thisRound.
  ///
  /// In en, this message translates to:
  /// **'This round'**
  String get thisRound;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noteFor.
  ///
  /// In en, this message translates to:
  /// **'Note for {name}'**
  String noteFor(String name);

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. no onions, well done'**
  String get noteHint;

  /// No description provided for @stationOrderServed.
  ///
  /// In en, this message translates to:
  /// **'{station} order for table {table} served.'**
  String stationOrderServed(String station, int table);

  /// No description provided for @orderCardLine.
  ///
  /// In en, this message translates to:
  /// **'{items} · {order} · since {time}'**
  String orderCardLine(String items, String order, String time);

  /// No description provided for @stationOrderReady.
  ///
  /// In en, this message translates to:
  /// **'{station} order is ready'**
  String stationOrderReady(String station);

  /// No description provided for @markServed.
  ///
  /// In en, this message translates to:
  /// **'Mark served'**
  String get markServed;

  /// No description provided for @addItems.
  ///
  /// In en, this message translates to:
  /// **'Add Items'**
  String get addItems;

  /// No description provided for @upsellDrinkQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would your guest like a drink with the {name}?'**
  String upsellDrinkQuestion(String name);

  /// No description provided for @upsellOftenAdd.
  ///
  /// In en, this message translates to:
  /// **'Guests who order {name} often add:'**
  String upsellOftenAdd(String name);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Servio'**
  String get appName;

  /// No description provided for @cannotUseApp.
  ///
  /// In en, this message translates to:
  /// **'The {role} account cannot use this app.'**
  String cannotUseApp(String role);

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(int minutes);

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'today {time}'**
  String todayAt(String time);

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{label} is required.'**
  String fieldRequired(String label);

  /// No description provided for @fieldLengthBetween.
  ///
  /// In en, this message translates to:
  /// **'{label} must be between {min} and {max} characters long.'**
  String fieldLengthBetween(String label, int min, int max);

  /// No description provided for @fieldLengthMax.
  ///
  /// In en, this message translates to:
  /// **'{label} can be at most {max} characters long.'**
  String fieldLengthMax(String label, int max);

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address, e.g. name@example.com.'**
  String get emailInvalid;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required.'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number with 6 to 19 digits, optionally starting with +, e.g. +387 61 123 456.'**
  String get phoneInvalid;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required.'**
  String get usernameRequired;

  /// No description provided for @usernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Username must be 3 to 50 characters and may contain only letters, digits, dots and underscores.'**
  String get usernameInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get passwordRequired;

  /// No description provided for @passwordInvalid.
  ///
  /// In en, this message translates to:
  /// **'Password must be 8 to 100 characters long and contain at least one letter and one digit.'**
  String get passwordInvalid;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @numberInvalid.
  ///
  /// In en, this message translates to:
  /// **'{label} must be a number, e.g. 12.50.'**
  String numberInvalid(String label);

  /// No description provided for @numberBetween.
  ///
  /// In en, this message translates to:
  /// **'{label} must be between {min} and {max}.'**
  String numberBetween(String label, String min, String max);

  /// No description provided for @wholeNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'{label} must be a whole number.'**
  String wholeNumberInvalid(String label);

  /// No description provided for @courseAppetizer.
  ///
  /// In en, this message translates to:
  /// **'Appetizer'**
  String get courseAppetizer;

  /// No description provided for @courseMainCourse.
  ///
  /// In en, this message translates to:
  /// **'Main course'**
  String get courseMainCourse;

  /// No description provided for @courseSide.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get courseSide;

  /// No description provided for @courseDessert.
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get courseDessert;

  /// No description provided for @courseDrink.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get courseDrink;

  /// No description provided for @reservationPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get reservationPending;

  /// No description provided for @reservationConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get reservationConfirmed;

  /// No description provided for @reservationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get reservationCompleted;

  /// No description provided for @reservationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get reservationCancelled;

  /// No description provided for @reservationNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get reservationNoShow;

  /// No description provided for @ticketNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get ticketNew;

  /// No description provided for @ticketPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get ticketPreparing;

  /// No description provided for @ticketReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ticketReady;

  /// No description provided for @ticketServed.
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get ticketServed;

  /// No description provided for @ticketCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ticketCancelled;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentPending;

  /// No description provided for @paymentPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentPaid;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get paymentFailed;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get paymentCancelled;

  /// No description provided for @paymentPartiallyRefunded.
  ///
  /// In en, this message translates to:
  /// **'Partially refunded'**
  String get paymentPartiallyRefunded;

  /// No description provided for @paymentRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get paymentRefunded;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleWaiter.
  ///
  /// In en, this message translates to:
  /// **'Waiter'**
  String get roleWaiter;

  /// No description provided for @roleKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get roleKitchen;

  /// No description provided for @roleBar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get roleBar;

  /// No description provided for @methodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get methodCash;

  /// No description provided for @serverUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server at {url}. Check that the API is running.'**
  String serverUnreachable(String url);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancelIt.
  ///
  /// In en, this message translates to:
  /// **'Cancel it'**
  String get cancelIt;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Guest changed their mind'**
  String get reasonHint;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason.'**
  String get reasonRequired;

  /// No description provided for @reasonLength.
  ///
  /// In en, this message translates to:
  /// **'Reason must be between 3 and 500 characters long.'**
  String get reasonLength;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested record was not found.'**
  String get errorNotFound;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on the server. Please try again.'**
  String get errorServer;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @vatIncluded.
  ///
  /// In en, this message translates to:
  /// **'Includes {rate}% VAT: {tax} · base {base}'**
  String vatIncluded(String rate, String tax, String base);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageBosnian.
  ///
  /// In en, this message translates to:
  /// **'Bosnian'**
  String get languageBosnian;
}

class _ServioLocalizationsDelegate
    extends LocalizationsDelegate<ServioLocalizations> {
  const _ServioLocalizationsDelegate();

  @override
  Future<ServioLocalizations> load(Locale locale) {
    return SynchronousFuture<ServioLocalizations>(
      lookupServioLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ServioLocalizationsDelegate old) => false;
}

ServioLocalizations lookupServioLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bs':
      return ServioLocalizationsBs();
    case 'en':
      return ServioLocalizationsEn();
  }

  throw FlutterError(
    'ServioLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
