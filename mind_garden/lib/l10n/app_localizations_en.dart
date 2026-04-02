// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mind Garden';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Close';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonStart => 'Let\'s begin';

  @override
  String get commonAdd => 'Add';

  @override
  String get mainOnboardingWelcomeTitle => 'Welcome to Mind Garden';

  @override
  String get mainOnboardingWelcomeDescription => 'Weeds are your unconscious thoughts. Transform them into beautiful flowers every day until your garden blooms and your life becomes a mindful here and now.';

  @override
  String get mainOnboardingAddWeedsTitle => 'Add weeds';

  @override
  String get mainOnboardingAddWeedsDescription => 'On the main screen, tap “Add weed”. A weed will appear to represent a thought you want to work through.';

  @override
  String get mainOnboardingWorkWithEmotionTitle => 'Work with emotion';

  @override
  String get mainOnboardingWorkWithEmotionDescription => 'Tap a weed to move forward and replace it with a beautiful memory. After saving, you will see it in your garden.';

  @override
  String get mainOnboardingCareGardenTitle => 'Take care of your garden';

  @override
  String get mainOnboardingCareGardenDescription => 'The garden shows flowers added within the last 24 hours. Keep your garden full and your mind calm.';

  @override
  String get mainOnboardingManageFlowersTitle => 'Manage your flowers';

  @override
  String get mainOnboardingManageFlowersDescription => 'Use the panel on the left to browse or delete your flowers.';

  @override
  String get mainHomeAddWeed => 'Add weed';

  @override
  String get mainDialogLimitReachedTitle => 'Limit reached';

  @override
  String get mainDialogLimitReachedMessage => 'Work on no more than five thoughts at once.';

  @override
  String get mainDialogAttentionTitle => 'Attention';

  @override
  String get mainDialogAttentionMessage => 'Focus on one thought at a time. Wait 10 seconds before tapping again.';

  @override
  String get flowersAddMemoryTitle => 'Plant a mindful thought';

  @override
  String get flowersAddMemoryGallery => 'Gallery';

  @override
  String get flowersAddMemoryCamera => 'Camera';

  @override
  String get flowersAddMemoryAdjustPhoto => 'Adjust photo';

  @override
  String get flowersAddMemoryCustomPhoto => 'Add your own photo';

  @override
  String get flowersAddMemoryDescriptionHint => 'Describe your thought...';

  @override
  String get flowersAddMemorySaveThought => 'Save thought';

  @override
  String get flowersTypeSunflower => 'Sunflower';

  @override
  String get flowersTypeRose => 'Rose';

  @override
  String get flowersTypeLavender => 'Lavender';

  @override
  String get flowersTypeTulip => 'Tulip';

  @override
  String get flowersTypeCustom => 'Another flower';

  @override
  String get holyGardenMemoryTitle => 'Memory';

  @override
  String get holyGardenEmptyRecentFlowers => 'No flowers from the last 24 hours';

  @override
  String get dbPageMemoryTitle => 'Memory';

  @override
  String get dbPageEmptyState => 'No saved data';

  @override
  String get dbPageAddFavoriteMemoriesHint => 'Add your favorite memories...';
}
