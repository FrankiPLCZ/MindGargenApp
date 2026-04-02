import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mind Garden'**
  String get appTitle;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin'**
  String get commonStart;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @mainOnboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mind Garden'**
  String get mainOnboardingWelcomeTitle;

  /// No description provided for @mainOnboardingWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Weeds are your unconscious thoughts. Transform them into beautiful flowers every day until your garden blooms and your life becomes a mindful here and now.'**
  String get mainOnboardingWelcomeDescription;

  /// No description provided for @mainOnboardingAddWeedsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add weeds'**
  String get mainOnboardingAddWeedsTitle;

  /// No description provided for @mainOnboardingAddWeedsDescription.
  ///
  /// In en, this message translates to:
  /// **'On the main screen, tap “Add weed”. A weed will appear to represent a thought you want to work through.'**
  String get mainOnboardingAddWeedsDescription;

  /// No description provided for @mainOnboardingWorkWithEmotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Work with emotion'**
  String get mainOnboardingWorkWithEmotionTitle;

  /// No description provided for @mainOnboardingWorkWithEmotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap a weed to move forward and replace it with a beautiful memory. After saving, you will see it in your garden.'**
  String get mainOnboardingWorkWithEmotionDescription;

  /// No description provided for @mainOnboardingCareGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Take care of your garden'**
  String get mainOnboardingCareGardenTitle;

  /// No description provided for @mainOnboardingCareGardenDescription.
  ///
  /// In en, this message translates to:
  /// **'The garden shows flowers added within the last 24 hours. Keep your garden full and your mind calm.'**
  String get mainOnboardingCareGardenDescription;

  /// No description provided for @mainOnboardingManageFlowersTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your flowers'**
  String get mainOnboardingManageFlowersTitle;

  /// No description provided for @mainOnboardingManageFlowersDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the panel on the left to browse or delete your flowers.'**
  String get mainOnboardingManageFlowersDescription;

  /// No description provided for @mainHomeAddWeed.
  ///
  /// In en, this message translates to:
  /// **'Add weed'**
  String get mainHomeAddWeed;

  /// No description provided for @mainDialogLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit reached'**
  String get mainDialogLimitReachedTitle;

  /// No description provided for @mainDialogLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'Work on no more than five thoughts at once.'**
  String get mainDialogLimitReachedMessage;

  /// No description provided for @mainDialogAttentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get mainDialogAttentionTitle;

  /// No description provided for @mainDialogAttentionMessage.
  ///
  /// In en, this message translates to:
  /// **'Focus on one thought at a time. Wait 10 seconds before tapping again.'**
  String get mainDialogAttentionMessage;

  /// No description provided for @flowersAddMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant a mindful thought'**
  String get flowersAddMemoryTitle;

  /// No description provided for @flowersAddMemoryGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get flowersAddMemoryGallery;

  /// No description provided for @flowersAddMemoryCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get flowersAddMemoryCamera;

  /// No description provided for @flowersAddMemoryAdjustPhoto.
  ///
  /// In en, this message translates to:
  /// **'Adjust photo'**
  String get flowersAddMemoryAdjustPhoto;

  /// No description provided for @flowersAddMemoryCustomPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add your own photo'**
  String get flowersAddMemoryCustomPhoto;

  /// No description provided for @flowersAddMemoryDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your thought...'**
  String get flowersAddMemoryDescriptionHint;

  /// No description provided for @flowersAddMemorySaveThought.
  ///
  /// In en, this message translates to:
  /// **'Save thought'**
  String get flowersAddMemorySaveThought;

  /// No description provided for @flowersTypeSunflower.
  ///
  /// In en, this message translates to:
  /// **'Sunflower'**
  String get flowersTypeSunflower;

  /// No description provided for @flowersTypeRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get flowersTypeRose;

  /// No description provided for @flowersTypeLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get flowersTypeLavender;

  /// No description provided for @flowersTypeTulip.
  ///
  /// In en, this message translates to:
  /// **'Tulip'**
  String get flowersTypeTulip;

  /// No description provided for @flowersTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Another flower'**
  String get flowersTypeCustom;

  /// No description provided for @holyGardenMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get holyGardenMemoryTitle;

  /// No description provided for @holyGardenEmptyRecentFlowers.
  ///
  /// In en, this message translates to:
  /// **'No flowers from the last 24 hours'**
  String get holyGardenEmptyRecentFlowers;

  /// No description provided for @dbPageMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get dbPageMemoryTitle;

  /// No description provided for @dbPageEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No saved data'**
  String get dbPageEmptyState;

  /// No description provided for @dbPageAddFavoriteMemoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Add your favorite memories...'**
  String get dbPageAddFavoriteMemoriesHint;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pl': return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
