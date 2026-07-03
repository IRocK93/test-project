import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
    Locale('it'),
    Locale('pt'),
    Locale('zh')
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutAiCompanion.
  ///
  /// In en, this message translates to:
  /// **'About the AI Companion'**
  String get aboutAiCompanion;

  /// No description provided for @aboutAiCompanionDialog.
  ///
  /// In en, this message translates to:
  /// **'The AI Companion runs entirely on your device. Nothing you type is sent to the cloud. Responses are generated locally and are not reviewed by humans. Always consult your healthcare provider for medical decisions.'**
  String get aboutAiCompanionDialog;

  /// No description provided for @aboutAiCompanionDialogText.
  ///
  /// In en, this message translates to:
  /// **'The AI Companion runs entirely on your device using a small language model. No data leaves your phone.\n\nResponses are grounded in parenting and child development content.\n\nThe AI Companion is not a substitute for professional medical advice. Always consult your healthcare provider for medical concerns.'**
  String get aboutAiCompanionDialogText;

  /// No description provided for @aboutAiCompanionTooltip.
  ///
  /// In en, this message translates to:
  /// **'About the AI Companion'**
  String get aboutAiCompanionTooltip;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @acceptLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptLabel;

  /// No description provided for @acceptMedicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Accept medical disclaimer'**
  String get acceptMedicalDisclaimer;

  /// No description provided for @acceptPrivacyPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get acceptPrivacyPrefix;

  /// No description provided for @acceptTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get acceptTermsPrefix;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @achieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved!'**
  String get achieved;

  /// No description provided for @achievedMilestoneSemantic.
  ///
  /// In en, this message translates to:
  /// **'Achieved: {title}'**
  String achievedMilestoneSemantic(Object title);

  /// No description provided for @achievedMilestones.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get achievedMilestones;

  /// No description provided for @achievedSemantic.
  ///
  /// In en, this message translates to:
  /// **'Achieved:'**
  String get achievedSemantic;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @activeBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Active BabyMon'**
  String get activeBabyMon;

  /// No description provided for @activeModel.
  ///
  /// In en, this message translates to:
  /// **'Active Model'**
  String get activeModel;

  /// No description provided for @activityPrompt.
  ///
  /// In en, this message translates to:
  /// **'Activity Prompt'**
  String get activityPrompt;

  /// No description provided for @activitySaved.
  ///
  /// In en, this message translates to:
  /// **'Activity saved! +XP earned'**
  String get activitySaved;

  /// No description provided for @activitySavedXP.
  ///
  /// In en, this message translates to:
  /// **'Activity saved! +XP earned'**
  String get activitySavedXP;

  /// No description provided for @addActivity.
  ///
  /// In en, this message translates to:
  /// **'Add Activity'**
  String get addActivity;

  /// No description provided for @addAllergy.
  ///
  /// In en, this message translates to:
  /// **'Add Allergy'**
  String get addAllergy;

  /// No description provided for @addAllergyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Allergy'**
  String get addAllergyTitle;

  /// No description provided for @addBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Add BabyMon'**
  String get addBabyMon;

  /// No description provided for @addCustom.
  ///
  /// In en, this message translates to:
  /// **'Add custom'**
  String get addCustom;

  /// No description provided for @addCustomTrait.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Trait'**
  String get addCustomTrait;

  /// No description provided for @addCustomTraitTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Trait'**
  String get addCustomTraitTitle;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @addEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEventTitle;

  /// No description provided for @addEventTitleParam.
  ///
  /// In en, this message translates to:
  /// **'Add {category}'**
  String addEventTitleParam(Object category);

  /// No description provided for @addFeedingTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Feeding'**
  String get addFeedingTitle;

  /// No description provided for @addGrowthRecordAction.
  ///
  /// In en, this message translates to:
  /// **'Add growth record'**
  String get addGrowthRecordAction;

  /// No description provided for @addGrowthRecordSemantic.
  ///
  /// In en, this message translates to:
  /// **'Add growth record'**
  String get addGrowthRecordSemantic;

  /// No description provided for @addHealthActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a measurement, allergy, or clinic visit'**
  String get addHealthActionsTooltip;

  /// No description provided for @addHealthRecordHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add a measurement, allergy, or clinic visit.'**
  String get addHealthRecordHint;

  /// No description provided for @addItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Add {item}'**
  String addItemLabel(Object item);

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get addMeasurement;

  /// No description provided for @addMeasurementTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get addMeasurementTitle;

  /// No description provided for @addMedicalContact.
  ///
  /// In en, this message translates to:
  /// **'Add Medical Contact'**
  String get addMedicalContact;

  /// No description provided for @addMedicalTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Medical Team'**
  String get addMedicalTeamTitle;

  /// No description provided for @addMilestone.
  ///
  /// In en, this message translates to:
  /// **'Add Milestone'**
  String get addMilestone;

  /// No description provided for @addMilestoneAction.
  ///
  /// In en, this message translates to:
  /// **'Add a milestone'**
  String get addMilestoneAction;

  /// No description provided for @addMilestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Milestone'**
  String get addMilestoneTitle;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// No description provided for @addRecordAction.
  ///
  /// In en, this message translates to:
  /// **'Add record'**
  String get addRecordAction;

  /// No description provided for @addRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Add {metric} Record'**
  String addRecordTitle(Object metric);

  /// No description provided for @addSleepLogAction.
  ///
  /// In en, this message translates to:
  /// **'Add sleep log'**
  String get addSleepLogAction;

  /// No description provided for @addSleepLogSemantic.
  ///
  /// In en, this message translates to:
  /// **'Add sleep log'**
  String get addSleepLogSemantic;

  /// No description provided for @addStage.
  ///
  /// In en, this message translates to:
  /// **'Add Stage'**
  String get addStage;

  /// No description provided for @adviceFeed.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get adviceFeed;

  /// No description provided for @adviceTab.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get adviceTab;

  /// No description provided for @ageConsent.
  ///
  /// In en, this message translates to:
  /// **'I confirm I am at least 18 years old'**
  String get ageConsent;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @aiCompanionReady.
  ///
  /// In en, this message translates to:
  /// **'Your AI Companion is ready.'**
  String get aiCompanionReady;

  /// No description provided for @aiCompanionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI Companion unavailable. Using parenting content cards instead.'**
  String get aiCompanionUnavailable;

  /// No description provided for @aiModelLabel.
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get aiModelLabel;

  /// No description provided for @aiModelSection.
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get aiModelSection;

  /// No description provided for @aiNotDoctorWarning.
  ///
  /// In en, this message translates to:
  /// **'Our AI Companion runs on your device...but it is not a doctor. It doesn\'t have a medical license, and it never will. It\'s a helpful companion that can answer questions and provide general parenting guidance.'**
  String get aiNotDoctorWarning;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @allChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'All changes saved'**
  String get allChangesSaved;

  /// No description provided for @allDomains.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allDomains;

  /// No description provided for @allEntries.
  ///
  /// In en, this message translates to:
  /// **'All Entries'**
  String get allEntries;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @allMilestones.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allMilestones;

  /// No description provided for @allRecords.
  ///
  /// In en, this message translates to:
  /// **'All records'**
  String get allRecords;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @allergiesCleared.
  ///
  /// In en, this message translates to:
  /// **'allergies cleared'**
  String get allergiesCleared;

  /// No description provided for @allergyAdded.
  ///
  /// In en, this message translates to:
  /// **'Allergy added!'**
  String get allergyAdded;

  /// No description provided for @allergyCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Allergy'**
  String get allergyCategoryLabel;

  /// No description provided for @allergyEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Allergy'**
  String get allergyEventLabel;

  /// No description provided for @allergyEventRecorded.
  ///
  /// In en, this message translates to:
  /// **'Allergy event recorded!'**
  String get allergyEventRecorded;

  /// No description provided for @allergyName.
  ///
  /// In en, this message translates to:
  /// **'Allergy Name'**
  String get allergyName;

  /// No description provided for @allergyNameField.
  ///
  /// In en, this message translates to:
  /// **'Allergy name'**
  String get allergyNameField;

  /// No description provided for @allergyNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Allergy name'**
  String get allergyNameFieldLabel;

  /// No description provided for @allergySelected.
  ///
  /// In en, this message translates to:
  /// **'Allergy: {value}'**
  String allergySelected(Object value);

  /// No description provided for @allergySeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get allergySeverity;

  /// No description provided for @allergyTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Allergy: Tap to select'**
  String get allergyTapToSelect;

  /// No description provided for @allergyTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get allergyTreatment;

  /// No description provided for @allergyTriggers.
  ///
  /// In en, this message translates to:
  /// **'Triggers'**
  String get allergyTriggers;

  /// No description provided for @almostReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Almost ready...'**
  String get almostReadyMessage;

  /// No description provided for @alwaysCheckPediatrician.
  ///
  /// In en, this message translates to:
  /// **'Always check with your pediatrician before making medical decisions.'**
  String get alwaysCheckPediatrician;

  /// No description provided for @amberColor.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get amberColor;

  /// No description provided for @annualCheckup.
  ///
  /// In en, this message translates to:
  /// **'Annual Checkup'**
  String get annualCheckup;

  /// No description provided for @annualCheckupHint.
  ///
  /// In en, this message translates to:
  /// **'Annual Checkup'**
  String get annualCheckupHint;

  /// Tagline shown on splash and login screens
  ///
  /// In en, this message translates to:
  /// **'Smart Evolving Parenting Companion'**
  String get appTagline;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BabyMon'**
  String get appTitle;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @applyLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyLabel;

  /// No description provided for @askCompanion.
  ///
  /// In en, this message translates to:
  /// **'Ask the Companion'**
  String get askCompanion;

  /// No description provided for @askCompanionHint.
  ///
  /// In en, this message translates to:
  /// **'Ask BabyMon Companion...'**
  String get askCompanionHint;

  /// No description provided for @askCompanionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Ask the Companion'**
  String get askCompanionTooltip;

  /// No description provided for @askEnas.
  ///
  /// In en, this message translates to:
  /// **'Ask Enas'**
  String get askEnas;

  /// No description provided for @attendingStaff.
  ///
  /// In en, this message translates to:
  /// **'Attending Staff'**
  String get attendingStaff;

  /// No description provided for @attendingStaffLabel.
  ///
  /// In en, this message translates to:
  /// **'Attending Staff'**
  String get attendingStaffLabel;

  /// No description provided for @availableToDownload.
  ///
  /// In en, this message translates to:
  /// **'Available to Download'**
  String get availableToDownload;

  /// No description provided for @averageLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get averageLabel;

  /// No description provided for @avgSleep.
  ///
  /// In en, this message translates to:
  /// **'Average Sleep'**
  String get avgSleep;

  /// No description provided for @babyFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get babyFallbackName;

  /// No description provided for @babyMonData.
  ///
  /// In en, this message translates to:
  /// **'BabyMon Data'**
  String get babyMonData;

  /// No description provided for @babyMonDeleted.
  ///
  /// In en, this message translates to:
  /// **'BabyMon permanently deleted'**
  String get babyMonDeleted;

  /// No description provided for @babyMonProfile.
  ///
  /// In en, this message translates to:
  /// **'BabyMon Profile'**
  String get babyMonProfile;

  /// No description provided for @babyMonSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'BabyMon save failed'**
  String get babyMonSaveFailed;

  /// No description provided for @babyMonSaveFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'BabyMon save failed'**
  String get babyMonSaveFailedMessage;

  /// No description provided for @babyMonVersion.
  ///
  /// In en, this message translates to:
  /// **'BabyMon v1.0.0'**
  String get babyMonVersion;

  /// No description provided for @babyName.
  ///
  /// In en, this message translates to:
  /// **'Baby Name'**
  String get babyName;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @backToAlbum.
  ///
  /// In en, this message translates to:
  /// **'Back to album'**
  String get backToAlbum;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @backupPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Backup & Privacy'**
  String get backupPrivacy;

  /// No description provided for @badgeCategoryFeeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get badgeCategoryFeeding;

  /// No description provided for @badgeCategoryGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get badgeCategoryGrowth;

  /// No description provided for @badgeCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get badgeCategoryHealth;

  /// No description provided for @badgeCategoryMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get badgeCategoryMilestones;

  /// No description provided for @badgeCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get badgeCategoryOther;

  /// No description provided for @badgeCategoryParenting.
  ///
  /// In en, this message translates to:
  /// **'Parenting'**
  String get badgeCategoryParenting;

  /// No description provided for @badgeCategoryProgression.
  ///
  /// In en, this message translates to:
  /// **'Progression'**
  String get badgeCategoryProgression;

  /// No description provided for @badgeCategorySleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get badgeCategorySleep;

  /// No description provided for @badgeCategoryTraits.
  ///
  /// In en, this message translates to:
  /// **'Traits'**
  String get badgeCategoryTraits;

  /// No description provided for @badgeLocked.
  ///
  /// In en, this message translates to:
  /// **'locked'**
  String get badgeLocked;

  /// No description provided for @badgeTierBronze.
  ///
  /// In en, this message translates to:
  /// **'BRONZE'**
  String get badgeTierBronze;

  /// No description provided for @badgeTierDiamond.
  ///
  /// In en, this message translates to:
  /// **'DIAMOND'**
  String get badgeTierDiamond;

  /// No description provided for @badgeTierGold.
  ///
  /// In en, this message translates to:
  /// **'GOLD'**
  String get badgeTierGold;

  /// No description provided for @badgeTierSilver.
  ///
  /// In en, this message translates to:
  /// **'SILVER'**
  String get badgeTierSilver;

  /// No description provided for @badgesCountFormat.
  ///
  /// In en, this message translates to:
  /// **'Badges ({count} unlocked)'**
  String badgesCountFormat(Object count);

  /// No description provided for @badgesEarned.
  ///
  /// In en, this message translates to:
  /// **'Badges Earned'**
  String get badgesEarned;

  /// No description provided for @badgesUnlockedCount.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} / {total}'**
  String badgesUnlockedCount(Object unlocked, Object total, Object count);

  /// No description provided for @basicMode.
  ///
  /// In en, this message translates to:
  /// **'Basic mode'**
  String get basicMode;

  /// No description provided for @basicModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Content cards only, no on-device AI'**
  String get basicModeDesc;

  /// No description provided for @beautifulSurprise.
  ///
  /// In en, this message translates to:
  /// **'A beautiful surprise'**
  String get beautifulSurprise;

  /// No description provided for @becauseYourLittleOne.
  ///
  /// In en, this message translates to:
  /// **'Because your little one matters most'**
  String get becauseYourLittleOne;

  /// No description provided for @bedtimeRitual.
  ///
  /// In en, this message translates to:
  /// **'BEDTIME RITUAL'**
  String get bedtimeRitual;

  /// No description provided for @beginJourneySemantic.
  ///
  /// In en, this message translates to:
  /// **'Begin your BabyMon journey'**
  String get beginJourneySemantic;

  /// No description provided for @beginStorySemantic.
  ///
  /// In en, this message translates to:
  /// **'Begin your story'**
  String get beginStorySemantic;

  /// No description provided for @beginYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Begin your BabyMon journey'**
  String get beginYourJourney;

  /// No description provided for @beginYourStory.
  ///
  /// In en, this message translates to:
  /// **'Begin your story'**
  String get beginYourStory;

  /// No description provided for @betterQuality.
  ///
  /// In en, this message translates to:
  /// **'Better Quality'**
  String get betterQuality;

  /// No description provided for @betterQualityPremium.
  ///
  /// In en, this message translates to:
  /// **'Better Quality requires a Premium subscription.'**
  String get betterQualityPremium;

  /// No description provided for @betterQualityPremiumMessage.
  ///
  /// In en, this message translates to:
  /// **'Better Quality requires a Premium subscription.'**
  String get betterQualityPremiumMessage;

  /// No description provided for @biologicalFatherLabel.
  ///
  /// In en, this message translates to:
  /// **'Biological Father'**
  String get biologicalFatherLabel;

  /// No description provided for @biologicalMotherLabel.
  ///
  /// In en, this message translates to:
  /// **'Biological Mother'**
  String get biologicalMotherLabel;

  /// No description provided for @biometricEnablePrompt.
  ///
  /// In en, this message translates to:
  /// **'Would you like to use biometrics for faster sign-in next time?'**
  String get biometricEnablePrompt;

  /// No description provided for @biometricEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get biometricEnableTitle;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in with biometrics'**
  String get biometricLogin;

  /// No description provided for @biometricLoginDesc.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face to sign in'**
  String get biometricLoginDesc;

  /// No description provided for @biometricLoginSetting.
  ///
  /// In en, this message translates to:
  /// **'Biometric login'**
  String get biometricLoginSetting;

  /// No description provided for @biometricPrompt.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to log in to BabyMon'**
  String get biometricPrompt;

  /// No description provided for @biometricsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available'**
  String get biometricsNotAvailable;

  /// No description provided for @biometricsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to continue'**
  String get biometricsPrompt;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @bloodTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodTypeLabel;

  /// No description provided for @blueColor.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blueColor;

  /// No description provided for @bodyTempCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Temp'**
  String get bodyTempCategoryLabel;

  /// No description provided for @bodyTempLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Temp'**
  String get bodyTempLabel;

  /// No description provided for @bookmarkCardsHint.
  ///
  /// In en, this message translates to:
  /// **'Bookmark advice cards from the Advice tab to build your personal parenting library.'**
  String get bookmarkCardsHint;

  /// No description provided for @bookmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Bookmark advice cards from the Advice tab to save them here for quick reference.'**
  String get bookmarkHint;

  /// No description provided for @bookmarkHintDetail.
  ///
  /// In en, this message translates to:
  /// **'Bookmark advice cards from the Advice tab to save them here for quick reference.'**
  String get bookmarkHintDetail;

  /// No description provided for @born.
  ///
  /// In en, this message translates to:
  /// **'Born'**
  String get born;

  /// No description provided for @bornStageDesc.
  ///
  /// In en, this message translates to:
  /// **'A gentle arrival.\nThe world welcomed them.'**
  String get bornStageDesc;

  /// No description provided for @bornStageSubtext.
  ///
  /// In en, this message translates to:
  /// **'Your BabyMon is already in the wild.\nWhen did you first meet?'**
  String get bornStageSubtext;

  /// No description provided for @bottleSubtype.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get bottleSubtype;

  /// No description provided for @bowelCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Bowel Movement'**
  String get bowelCategoryLabel;

  /// No description provided for @bowelMovementLabel.
  ///
  /// In en, this message translates to:
  /// **'Bowel Movement'**
  String get bowelMovementLabel;

  /// No description provided for @boy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get boy;

  /// No description provided for @breastShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Breast'**
  String get breastShortLabel;

  /// No description provided for @breastfeeding.
  ///
  /// In en, this message translates to:
  /// **'Breastfeeding'**
  String get breastfeeding;

  /// No description provided for @breastmilkLabel.
  ///
  /// In en, this message translates to:
  /// **'Breastmilk'**
  String get breastmilkLabel;

  /// No description provided for @brownColor.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get brownColor;

  /// No description provided for @callDoctor.
  ///
  /// In en, this message translates to:
  /// **'Call Doctor'**
  String get callDoctor;

  /// No description provided for @callDoctorRightAway.
  ///
  /// In en, this message translates to:
  /// **'Call your doctor right away if you notice anything concerning about your baby\'s health.'**
  String get callDoctorRightAway;

  /// No description provided for @callEmergencyImmediately.
  ///
  /// In en, this message translates to:
  /// **'In an emergency, call 911 immediately. Don\'t wait. Don\'t hesitate.'**
  String get callEmergencyImmediately;

  /// No description provided for @cameraAction.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraAction;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// No description provided for @cannotConnectServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server. Please check your connection.'**
  String get cannotConnectServer;

  /// No description provided for @changeChartRange.
  ///
  /// In en, this message translates to:
  /// **'Change chart range'**
  String get changeChartRange;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changesPending.
  ///
  /// In en, this message translates to:
  /// **'changes pending'**
  String get changesPending;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @chatEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'I\'m powered by an on-device AI that runs entirely on your phone. Your questions and your child\'s data never leave your device.'**
  String get chatEmptySubtitle;

  /// No description provided for @checkEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Check email verification'**
  String get checkEmailVerification;

  /// No description provided for @checkInbox.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and click the verification link'**
  String get checkInbox;

  /// No description provided for @checkToAccept.
  ///
  /// In en, this message translates to:
  /// **'Check the box to accept'**
  String get checkToAccept;

  /// No description provided for @checkVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check verification status.'**
  String get checkVerificationFailed;

  /// No description provided for @checkingIntegrity.
  ///
  /// In en, this message translates to:
  /// **'Checking file integrity'**
  String get checkingIntegrity;

  /// No description provided for @childStage.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get childStage;

  /// No description provided for @chooseConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency (choose one)'**
  String get chooseConsistency;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @clay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get clay;

  /// No description provided for @clearAllAllergies.
  ///
  /// In en, this message translates to:
  /// **'Clear all allergies'**
  String get clearAllAllergies;

  /// No description provided for @clearAllAllergiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Removes all allergy profiles and events'**
  String get clearAllAllergiesDesc;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @clearAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all data. This action cannot be undone.'**
  String get clearAllDataConfirm;

  /// No description provided for @clearAllEvents.
  ///
  /// In en, this message translates to:
  /// **'Clear all allergy events'**
  String get clearAllEvents;

  /// No description provided for @clearAllEventsDesc.
  ///
  /// In en, this message translates to:
  /// **'Removes events but keeps allergy profiles'**
  String get clearAllEventsDesc;

  /// No description provided for @clearAllergiesEvents.
  ///
  /// In en, this message translates to:
  /// **'Clear allergies & events'**
  String get clearAllergiesEvents;

  /// No description provided for @clearAllergiesEventsDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove allergy records for this BabyMon'**
  String get clearAllergiesEventsDesc;

  /// No description provided for @clearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// No description provided for @clinicCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinicCategoryLabel;

  /// No description provided for @clinicLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinicLabel;

  /// No description provided for @clinicalGuide.
  ///
  /// In en, this message translates to:
  /// **'Clinical Guide'**
  String get clinicalGuide;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @closeMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get closeMenu;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @cognitive.
  ///
  /// In en, this message translates to:
  /// **'Cognitive'**
  String get cognitive;

  /// No description provided for @cognitiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Cognitive'**
  String get cognitiveLabel;

  /// No description provided for @collapseAdvice.
  ///
  /// In en, this message translates to:
  /// **'Collapse advice'**
  String get collapseAdvice;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @colorOf.
  ///
  /// In en, this message translates to:
  /// **'Color: {value}'**
  String colorOf(Object value);

  /// No description provided for @comingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoonLabel;

  /// No description provided for @companion.
  ///
  /// In en, this message translates to:
  /// **'AI Companion'**
  String get companion;

  /// No description provided for @companionTitle.
  ///
  /// In en, this message translates to:
  /// **'Companion'**
  String get companionTitle;

  /// No description provided for @companionWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BabyMon!'**
  String get companionWelcome;

  /// No description provided for @comparePlans.
  ///
  /// In en, this message translates to:
  /// **'Compare plans & upgrade'**
  String get comparePlans;

  /// No description provided for @comparedToWho.
  ///
  /// In en, this message translates to:
  /// **'Compared to WHO standards'**
  String get comparedToWho;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @completedRoutineSemantic.
  ///
  /// In en, this message translates to:
  /// **'Completed: {activity}'**
  String completedRoutineSemantic(Object activity);

  /// No description provided for @completedSemantic.
  ///
  /// In en, this message translates to:
  /// **'Completed:'**
  String get completedSemantic;

  /// No description provided for @completedSteps.
  ///
  /// In en, this message translates to:
  /// **'steps done'**
  String get completedSteps;

  /// No description provided for @conceived.
  ///
  /// In en, this message translates to:
  /// **'Conceived'**
  String get conceived;

  /// No description provided for @conceptionDate.
  ///
  /// In en, this message translates to:
  /// **'Conception Date'**
  String get conceptionDate;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteDefault.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get confirmDeleteDefault;

  /// No description provided for @confirmDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this {item}? This action cannot be undone.'**
  String confirmDeleteItem(Object item);

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @consistencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Consistency (choose one)'**
  String get consistencyLabel;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactName;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact us at support@babymon.app'**
  String get contactSupport;

  /// No description provided for @contactSupportMessage.
  ///
  /// In en, this message translates to:
  /// **'Contact us at support@babymon.app'**
  String get contactSupportMessage;

  /// No description provided for @contentCardsOnly.
  ///
  /// In en, this message translates to:
  /// **'Content cards only, no on-device AI'**
  String get contentCardsOnly;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @continueNextStep.
  ///
  /// In en, this message translates to:
  /// **'Continue to next step'**
  String get continueNextStep;

  /// No description provided for @couldNotClear.
  ///
  /// In en, this message translates to:
  /// **'Could not clear. Please try again.'**
  String get couldNotClear;

  /// No description provided for @couldNotDelete.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Please try again.'**
  String get couldNotDelete;

  /// No description provided for @couldNotLoadAdvice.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load advice'**
  String get couldNotLoadAdvice;

  /// No description provided for @couldNotLoadAdviceMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load advice'**
  String get couldNotLoadAdviceMessage;

  /// No description provided for @couldNotLoadModel.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load model. Switched to Basic mode.'**
  String get couldNotLoadModel;

  /// No description provided for @couldNotLoadModelMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load model. Switched to Basic mode.'**
  String get couldNotLoadModelMessage;

  /// No description provided for @couldNotLoadModelSwitched.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load model. Switched to Basic mode.'**
  String get couldNotLoadModelSwitched;

  /// No description provided for @couldNotStartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Could not start checkout. Please try again.'**
  String get couldNotStartCheckout;

  /// No description provided for @couldNotStartCheckoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not start checkout. Please try again.'**
  String get couldNotStartCheckoutMessage;

  /// No description provided for @couldNotUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Could not upgrade. Please try again.'**
  String get couldNotUpgrade;

  /// No description provided for @couldNotUpgradeMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not upgrade. Please try again.'**
  String get couldNotUpgradeMessage;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join BabyMon today'**
  String get createAccountSubtitle;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @createBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Create BabyMon'**
  String get createBabyMon;

  /// No description provided for @createBabyMonFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a BabyMon first'**
  String get createBabyMonFirst;

  /// No description provided for @createBabyMonPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create your first BabyMon to start tracking milestones, feedings, and more.'**
  String get createBabyMonPrompt;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get currentLevel;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @currentPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get currentPlanLabel;

  /// No description provided for @customTraitHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Brave, Silly, Stubborn'**
  String get customTraitHint;

  /// No description provided for @customTraitHintText.
  ///
  /// In en, this message translates to:
  /// **'e.g., Brave, Silly, Kind'**
  String get customTraitHintText;

  /// No description provided for @dailyBrief.
  ///
  /// In en, this message translates to:
  /// **'Daily Brief'**
  String get dailyBrief;

  /// No description provided for @dailyRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Routine'**
  String get dailyRoutineTitle;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @dataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data has been cleared'**
  String get dataCleared;

  /// No description provided for @dataConsent.
  ///
  /// In en, this message translates to:
  /// **'I consent to the processing of child health and development data'**
  String get dataConsent;

  /// No description provided for @dataConsentText.
  ///
  /// In en, this message translates to:
  /// **'I consent to processing of child health & development data'**
  String get dataConsentText;

  /// No description provided for @dataStaysOnDeviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Nothing you type is sent to the cloud. The AI model runs locally on your phone. Your conversations and personal data remain private.'**
  String get dataStaysOnDeviceDesc;

  /// No description provided for @dataStaysOnDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Data Stays On Your Device'**
  String get dataStaysOnDeviceTitle;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @dateOfBirthHelp.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get dateOfBirthHelp;

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// No description provided for @dayAbbr.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get dayAbbr;

  /// No description provided for @daysOld.
  ///
  /// In en, this message translates to:
  /// **'{days} days old'**
  String daysOld(int days);

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemaining(int days);

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysUnit;

  /// No description provided for @daysUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysUnitLabel;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @declineDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Decline disclaimer and go back'**
  String get declineDisclaimer;

  /// No description provided for @declineLabel.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineLabel;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @decreaseValue.
  ///
  /// In en, this message translates to:
  /// **'Decrease value'**
  String get decreaseValue;

  /// No description provided for @decreaseValueSemantic.
  ///
  /// In en, this message translates to:
  /// **'Decrease value'**
  String get decreaseValueSemantic;

  /// No description provided for @deeperReasoningLabel.
  ///
  /// In en, this message translates to:
  /// **'Deeper reasoning, nuanced advice'**
  String get deeperReasoningLabel;

  /// No description provided for @deeperReasoningNuanced.
  ///
  /// In en, this message translates to:
  /// **'Deeper reasoning, nuanced advice'**
  String get deeperReasoningNuanced;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all associated data.'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Delete BabyMon'**
  String get deleteBabyMon;

  /// No description provided for @deleteBabyMonConfirm.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All data for this BabyMon will be permanently deleted.'**
  String get deleteBabyMonConfirm;

  /// No description provided for @deleteBabyMonDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove all data'**
  String get deleteBabyMonDesc;

  /// No description provided for @deleteConfirmText.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteConfirmText;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get deleteConfirmation;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get deleteEntryTitle;

  /// No description provided for @deleteEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEventLabel;

  /// No description provided for @deleteEventMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this allergy event? (The allergy itself will remain)'**
  String get deleteEventMessage;

  /// No description provided for @deleteEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEventTitle;

  /// No description provided for @deleteFeedLogConfirm.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteFeedLogConfirm;

  /// No description provided for @deleteFeedLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Feed Log'**
  String get deleteFeedLogTitle;

  /// No description provided for @deleteGrowthRecordMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this measurement?'**
  String get deleteGrowthRecordMessage;

  /// No description provided for @deleteGrowthRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Growth Record'**
  String get deleteGrowthRecordTitle;

  /// No description provided for @deleteGrowthSpotMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {value} {unit}?'**
  String deleteGrowthSpotMessage(Object value, Object unit);

  /// No description provided for @deleteHealthRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Health Record?'**
  String get deleteHealthRecordTitle;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @deleteMilestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Milestone?'**
  String get deleteMilestoneTitle;

  /// No description provided for @deleteModel.
  ///
  /// In en, this message translates to:
  /// **'Delete Model'**
  String get deleteModel;

  /// No description provided for @deleteModelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this model? The downloaded file will be freed.'**
  String get deleteModelConfirm;

  /// No description provided for @deleteModelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Delete this model? The downloaded file will be freed.'**
  String get deleteModelConfirmBody;

  /// No description provided for @deleteModelConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this model? The downloaded file will be freed.'**
  String get deleteModelConfirmMessage;

  /// No description provided for @deleteModelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Model'**
  String get deleteModelConfirmTitle;

  /// No description provided for @deleteModelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete model'**
  String get deleteModelTooltip;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @deletePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhotoTitle;

  /// No description provided for @deleteRecordLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecordLabel;

  /// No description provided for @deleteRecordMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this health record?'**
  String get deleteRecordMessage;

  /// No description provided for @deleteRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecordTitle;

  /// No description provided for @deleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get deleteWarning;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @developmentGuide.
  ///
  /// In en, this message translates to:
  /// **'Development Guide'**
  String get developmentGuide;

  /// No description provided for @developmentalMilestones.
  ///
  /// In en, this message translates to:
  /// **'DEVELOPMENTAL MILESTONES'**
  String get developmentalMilestones;

  /// No description provided for @deviceNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Your device does not support on-device AI. Using parenting content cards instead (no internet required).'**
  String get deviceNotSupported;

  /// No description provided for @deviceNotSupportedCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your device does not support on-device AI. Using parenting content cards instead (no internet required).'**
  String get deviceNotSupportedCompanion;

  /// No description provided for @deviceNotSupportedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your device does not support on-device AI. Using parenting content cards instead (no internet required).'**
  String get deviceNotSupportedMessage;

  /// No description provided for @diaperChangeCategory.
  ///
  /// In en, this message translates to:
  /// **'Diaper Change'**
  String get diaperChangeCategory;

  /// No description provided for @diaperType.
  ///
  /// In en, this message translates to:
  /// **'Diaper Type'**
  String get diaperType;

  /// No description provided for @diaperTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Diaper Type'**
  String get diaperTypeLabel;

  /// No description provided for @diapersFilter.
  ///
  /// In en, this message translates to:
  /// **'Diapers'**
  String get diapersFilter;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @discoverActions.
  ///
  /// In en, this message translates to:
  /// **'Discover actions'**
  String get discoverActions;

  /// No description provided for @discoverComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Discover features: Tips, community content, stage-based insights, and more!'**
  String get discoverComingSoon;

  /// No description provided for @discoverNotifyMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when Discover launches!'**
  String get discoverNotifyMessage;

  /// No description provided for @dismissLabel.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissLabel;

  /// No description provided for @dismissPhoto.
  ///
  /// In en, this message translates to:
  /// **'Dismiss photo'**
  String get dismissPhoto;

  /// No description provided for @doctorVisit.
  ///
  /// In en, this message translates to:
  /// **'Doctor Visit'**
  String get doctorVisit;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @downloadAction.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadAction;

  /// No description provided for @downloadAiModel.
  ///
  /// In en, this message translates to:
  /// **'Download AI Model'**
  String get downloadAiModel;

  /// No description provided for @downloadAiModelDesc.
  ///
  /// In en, this message translates to:
  /// **'The AI Companion needs to download a language model ({size}) to provide personalized guidance on your device.'**
  String downloadAiModelDesc(Object size);

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download Complete!'**
  String get downloadComplete;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download Failed'**
  String get downloadFailed;

  /// No description provided for @downloadModel.
  ///
  /// In en, this message translates to:
  /// **'Download Model'**
  String get downloadModel;

  /// No description provided for @downloadModelBelow.
  ///
  /// In en, this message translates to:
  /// **'Download a model below to enable on-device AI.'**
  String get downloadModelBelow;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @downloadingAiModel.
  ///
  /// In en, this message translates to:
  /// **'Downloading AI model...'**
  String get downloadingAiModel;

  /// No description provided for @drSmithHint.
  ///
  /// In en, this message translates to:
  /// **'Dr. Smith'**
  String get drSmithHint;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueDate;

  /// No description provided for @dueNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Due now!'**
  String get dueNowLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration: {minutes} minutes'**
  String durationMinutes(Object minutes);

  /// No description provided for @editFeedingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Feeding'**
  String get editFeedingTitle;

  /// No description provided for @editMilestone.
  ///
  /// In en, this message translates to:
  /// **'Edit Milestone'**
  String get editMilestone;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {metric} Record'**
  String editRecordTitle(Object metric);

  /// Title for the edit sleep log dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Sleep'**
  String get editSleepTitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'partner@email.com'**
  String get emailHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not yet verified. Please check your inbox.'**
  String get emailNotVerified;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email. Please try again.'**
  String get emailSendFailed;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get emailSent;

  /// No description provided for @emailSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Check your inbox.'**
  String get emailSentSuccess;

  /// No description provided for @emergencyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'If this is a medical emergency, stop using this app and call 911 or your local emergency number immediately.'**
  String get emergencyDisclaimer;

  /// No description provided for @emergencyResponseFull.
  ///
  /// In en, this message translates to:
  /// **'**MEDICAL EMERGENCY**\n\nBased on what you\'ve described, this may be a medical emergency.\n\n**Please stop using this app immediately and call 911 (or your local emergency number) right now.**\n\nIf you are outside the US, here are emergency numbers:\n• UK: 999\n• EU: 112\n• Australia: 000\n• India: 112\n• Japan: 119\n• UAE: 998\n\n**The AI Companion is NOT a substitute for emergency medical services. It cannot diagnose or treat medical emergencies.**'**
  String get emergencyResponseFull;

  /// No description provided for @emergencyWarning.
  ///
  /// In en, this message translates to:
  /// **'**MEDICAL EMERGENCY**\n\nBased on what you\'ve described, this could be serious. Please stop using this app and contact emergency services or your doctor immediately.'**
  String get emergencyWarning;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTime;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get enterCode;

  /// No description provided for @enterCustomAllergy.
  ///
  /// In en, this message translates to:
  /// **'Enter custom allergy'**
  String get enterCustomAllergy;

  /// No description provided for @enterCustomAllergyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter custom allergy'**
  String get enterCustomAllergyHint;

  /// No description provided for @enterCustomVaccine.
  ///
  /// In en, this message translates to:
  /// **'Enter custom vaccine'**
  String get enterCustomVaccine;

  /// No description provided for @enterCustomVaccineHint.
  ///
  /// In en, this message translates to:
  /// **'Enter custom vaccine'**
  String get enterCustomVaccineHint;

  /// No description provided for @enterNameButton.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterNameButton;

  /// No description provided for @enterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a name...'**
  String get enterNameHint;

  /// No description provided for @entriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get entriesLabel;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeleted;

  /// No description provided for @erVisit.
  ///
  /// In en, this message translates to:
  /// **'e.g. ER Visit'**
  String get erVisit;

  /// No description provided for @erVisitHint.
  ///
  /// In en, this message translates to:
  /// **'ER Visit'**
  String get erVisitHint;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'This account has been deleted.'**
  String get errorAccountDeleted;

  /// No description provided for @errorAppleNoIdentityToken.
  ///
  /// In en, this message translates to:
  /// **'No identity token received from Apple.'**
  String get errorAppleNoIdentityToken;

  /// No description provided for @errorAppleSignInUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In is not available on this device.'**
  String get errorAppleSignInUnavailable;

  /// No description provided for @errorBabyMonNotFound.
  ///
  /// In en, this message translates to:
  /// **'BabyMon not found.'**
  String get errorBabyMonNotFound;

  /// No description provided for @errorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your input.'**
  String get errorBadRequest;

  /// No description provided for @errorCannotInviteSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot invite yourself.'**
  String get errorCannotInviteSelf;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'This already exists. Please use a different value.'**
  String get errorConflict;

  /// No description provided for @errorConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server.'**
  String get errorConnectionFailed;

  /// No description provided for @errorConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please check your internet.'**
  String get errorConnectionTimeout;

  /// No description provided for @errorDatabase.
  ///
  /// In en, this message translates to:
  /// **'A database error occurred. Please try again.'**
  String get errorDatabase;

  /// No description provided for @errorDownloading.
  ///
  /// In en, this message translates to:
  /// **'Error downloading model'**
  String get errorDownloading;

  /// No description provided for @errorDuplicateEmail.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get errorDuplicateEmail;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use.'**
  String get errorEmailInUse;

  /// No description provided for @errorFacebookNoAccessToken.
  ///
  /// In en, this message translates to:
  /// **'No access token received from Facebook.'**
  String get errorFacebookNoAccessToken;

  /// No description provided for @errorFeedLogNotFound.
  ///
  /// In en, this message translates to:
  /// **'Feed log not found.'**
  String get errorFeedLogNotFound;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get errorForbidden;

  /// No description provided for @errorGeneratingResponse.
  ///
  /// In en, this message translates to:
  /// **'[Error generating response. Please try again.]'**
  String get errorGeneratingResponse;

  /// No description provided for @errorHealthRecordNotFound.
  ///
  /// In en, this message translates to:
  /// **'Health record not found.'**
  String get errorHealthRecordNotFound;

  /// No description provided for @errorInternal.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorInternal;

  /// No description provided for @errorInvalidOperation.
  ///
  /// In en, this message translates to:
  /// **'Invalid operation. Please try again.'**
  String get errorInvalidOperation;

  /// No description provided for @errorInvalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid password.'**
  String get errorInvalidPassword;

  /// No description provided for @errorInvalidToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid token. Please log in again.'**
  String get errorInvalidToken;

  /// No description provided for @errorInvitationAlreadyProcessed.
  ///
  /// In en, this message translates to:
  /// **'Invitation already processed.'**
  String get errorInvitationAlreadyProcessed;

  /// No description provided for @errorInvitationExpired.
  ///
  /// In en, this message translates to:
  /// **'Invitation has expired.'**
  String get errorInvitationExpired;

  /// No description provided for @errorInvitationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invitation not found.'**
  String get errorInvitationNotFound;

  /// No description provided for @errorLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached the limit for this feature.'**
  String get errorLimitReached;

  /// No description provided for @errorLinkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Link not found.'**
  String get errorLinkNotFound;

  /// No description provided for @errorMilestoneNotFound.
  ///
  /// In en, this message translates to:
  /// **'Milestone not found.'**
  String get errorMilestoneNotFound;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found. The feature may not be available yet.'**
  String get errorNotFound;

  /// No description provided for @errorOAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please use social login for this account.'**
  String get errorOAuthRequired;

  /// No description provided for @errorPromoCodeAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'You have already used this promo code.'**
  String get errorPromoCodeAlreadyUsed;

  /// No description provided for @errorPromoCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This promo code has expired.'**
  String get errorPromoCodeExpired;

  /// No description provided for @errorPromoCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid promo code.'**
  String get errorPromoCodeInvalid;

  /// No description provided for @errorPromoCodeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'This promo code has reached its usage limit.'**
  String get errorPromoCodeLimitReached;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment.'**
  String get errorRateLimited;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorTokenExpired;

  /// No description provided for @errorTrialExpired.
  ///
  /// In en, this message translates to:
  /// **'Your free trial has expired. Please upgrade.'**
  String get errorTrialExpired;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @errorUpgradeRequired.
  ///
  /// In en, this message translates to:
  /// **'This feature requires a Premium subscription.'**
  String get errorUpgradeRequired;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get errorUserNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your input.'**
  String get errorValidation;

  /// No description provided for @etaDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'ETA: {days} days'**
  String etaDaysLabel(int days);

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @eventDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Event deleted'**
  String get eventDeletedMessage;

  /// No description provided for @eventsCleared.
  ///
  /// In en, this message translates to:
  /// **'events cleared'**
  String get eventsCleared;

  /// No description provided for @expandAdvice.
  ///
  /// In en, this message translates to:
  /// **'Expand to read full advice'**
  String get expandAdvice;

  /// No description provided for @expectedMilestones.
  ///
  /// In en, this message translates to:
  /// **'Expected Milestones'**
  String get expectedMilestones;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @expertAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Expert Advice'**
  String get expertAdviceTitle;

  /// No description provided for @expertAdviceUpgradeDesc.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium to get stage-specific expert advice from pediatricians and child development specialists.'**
  String get expertAdviceUpgradeDesc;

  /// No description provided for @exportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export complete'**
  String get exportComplete;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Download all records as JSON'**
  String get exportDataDesc;

  /// No description provided for @exportStarted.
  ///
  /// In en, this message translates to:
  /// **'Export started'**
  String get exportStarted;

  /// No description provided for @exportingData.
  ///
  /// In en, this message translates to:
  /// **'Exporting your data...'**
  String get exportingData;

  /// No description provided for @eyeColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Eye Color'**
  String get eyeColorLabel;

  /// No description provided for @facility.
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get facility;

  /// No description provided for @failedToAdd.
  ///
  /// In en, this message translates to:
  /// **'Failed to add'**
  String get failedToAdd;

  /// No description provided for @failedToAddMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to add'**
  String get failedToAddMessage;

  /// No description provided for @failedToCreateBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Failed to create BabyMon'**
  String get failedToCreateBabyMon;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @failedToLoadModel.
  ///
  /// In en, this message translates to:
  /// **'Failed to load AI model. Please try downloading it again.'**
  String get failedToLoadModel;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Please try again.'**
  String get failedToSave;

  /// No description provided for @failedToSaveMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Please try again.'**
  String get failedToSaveMessage;

  /// No description provided for @fairQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fairQualityLabel;

  /// No description provided for @familyLabel.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get familyLabel;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} — coming soon'**
  String featureComingSoon(Object feature);

  /// No description provided for @feedAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get feedAmount;

  /// No description provided for @feedAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get feedAmountLabel;

  /// No description provided for @feedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get feedDateLabel;

  /// No description provided for @feedDayTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get feedDayTotal;

  /// No description provided for @feedDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get feedDuration;

  /// No description provided for @feedDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (min)'**
  String get feedDurationLabel;

  /// No description provided for @feedLeftSide.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get feedLeftSide;

  /// No description provided for @feedLogSemantics.
  ///
  /// In en, this message translates to:
  /// **'{type}, {amount}, {date}'**
  String feedLogSemantics(Object type, Object amount, Object date);

  /// No description provided for @feedMethodBottle.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get feedMethodBottle;

  /// No description provided for @feedMethodBreast.
  ///
  /// In en, this message translates to:
  /// **'Breast'**
  String get feedMethodBreast;

  /// No description provided for @feedMethodCup.
  ///
  /// In en, this message translates to:
  /// **'Cup'**
  String get feedMethodCup;

  /// No description provided for @feedMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get feedMethodLabel;

  /// No description provided for @feedMethodSpoon.
  ///
  /// In en, this message translates to:
  /// **'Spoon'**
  String get feedMethodSpoon;

  /// No description provided for @feedRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get feedRequired;

  /// No description provided for @feedRightSide.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get feedRightSide;

  /// No description provided for @feedSelectedInfo.
  ///
  /// In en, this message translates to:
  /// **'Selected: {date} — tap for details'**
  String feedSelectedInfo(Object date, Object value);

  /// No description provided for @feedSummary.
  ///
  /// In en, this message translates to:
  /// **'Feeding Summary'**
  String get feedSummary;

  /// No description provided for @feedTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get feedTypeLabel;

  /// No description provided for @feedUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get feedUnit;

  /// No description provided for @feedUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get feedUnitLabel;

  /// No description provided for @feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// No description provided for @feedingCategory.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feedingCategory;

  /// No description provided for @feedingChartLabel.
  ///
  /// In en, this message translates to:
  /// **'Feeding Chart'**
  String get feedingChartLabel;

  /// No description provided for @feedingLogDeleted.
  ///
  /// In en, this message translates to:
  /// **'Feeding log deleted'**
  String get feedingLogDeleted;

  /// No description provided for @feedingLogDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Feeding log deleted'**
  String get feedingLogDeletedMessage;

  /// No description provided for @feedingMethod.
  ///
  /// In en, this message translates to:
  /// **'Feeding Method'**
  String get feedingMethod;

  /// No description provided for @feedingMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Feeding Method'**
  String get feedingMethodLabel;

  /// No description provided for @feedingUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get feedingUnitLabel;

  /// No description provided for @femaleGender.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get femaleGender;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in required fields'**
  String get fillRequiredFields;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterByDomain.
  ///
  /// In en, this message translates to:
  /// **'Filter by Domain'**
  String get filterByDomain;

  /// No description provided for @filterByType.
  ///
  /// In en, this message translates to:
  /// **'Filter by Type'**
  String get filterByType;

  /// No description provided for @fineMotor.
  ///
  /// In en, this message translates to:
  /// **'Fine Motor'**
  String get fineMotor;

  /// No description provided for @fineMotorLabel.
  ///
  /// In en, this message translates to:
  /// **'Fine Motor'**
  String get fineMotorLabel;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First Name *'**
  String get firstNameRequired;

  /// No description provided for @firstNameRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name *'**
  String get firstNameRequiredLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @formula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// No description provided for @formulaShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formulaShortLabel;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freePlan;

  /// No description provided for @fullDateLabel.
  ///
  /// In en, this message translates to:
  /// **'{day}, {date}'**
  String fullDateLabel(Object day, Object date);

  /// No description provided for @galleryAction.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryAction;

  /// No description provided for @gatheringBlankets.
  ///
  /// In en, this message translates to:
  /// **'Gathering tiny blankets...'**
  String get gatheringBlankets;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @generalGuide.
  ///
  /// In en, this message translates to:
  /// **'General Guide'**
  String get generalGuide;

  /// No description provided for @gentleArrival.
  ///
  /// In en, this message translates to:
  /// **'A gentle arrival'**
  String get gentleArrival;

  /// No description provided for @gentleReminder.
  ///
  /// In en, this message translates to:
  /// **'A Gentle Reminder'**
  String get gentleReminder;

  /// No description provided for @gentleReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'We love that you trust BabyMon. Your little one deserves the very best — and so do you. That\'s why we want to be completely transparent about how our AI Companion works.'**
  String get gentleReminderMessage;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @girl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get girl;

  /// No description provided for @glass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get glass;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @goBackSemantic.
  ///
  /// In en, this message translates to:
  /// **'Go back to previous step'**
  String get goBackSemantic;

  /// No description provided for @goodQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get goodQualityLabel;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @grayColor.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get grayColor;

  /// No description provided for @greatQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get greatQualityLabel;

  /// No description provided for @greenColor.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get greenColor;

  /// No description provided for @grossMotor.
  ///
  /// In en, this message translates to:
  /// **'Gross Motor'**
  String get grossMotor;

  /// No description provided for @grossMotorLabel.
  ///
  /// In en, this message translates to:
  /// **'Gross Motor'**
  String get grossMotorLabel;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @growthChart.
  ///
  /// In en, this message translates to:
  /// **'Growth Chart'**
  String get growthChart;

  /// No description provided for @growthChartSemantic.
  ///
  /// In en, this message translates to:
  /// **'Growth chart, {count} data points, {metric}, swipe to pan'**
  String growthChartSemantic(int count, Object metric);

  /// No description provided for @growthChartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Growth chart, {count} data points, {metric}, swipe to pan'**
  String growthChartSemantics(Object count, Object metric);

  /// No description provided for @growthFilter.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growthFilter;

  /// No description provided for @growthMeasurementCategory.
  ///
  /// In en, this message translates to:
  /// **'Growth Measurement'**
  String get growthMeasurementCategory;

  /// No description provided for @growthRecordDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this measurement?'**
  String get growthRecordDeleteMessage;

  /// No description provided for @growthRecordDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Growth Record'**
  String get growthRecordDeleteTitle;

  /// No description provided for @growthRecordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Growth record deleted'**
  String get growthRecordDeleted;

  /// No description provided for @growthRecordSpotDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {value} {unit}?'**
  String growthRecordSpotDeleteMessage(Object value, Object unit);

  /// No description provided for @growthRecordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Growth record updated'**
  String get growthRecordUpdated;

  /// No description provided for @growthShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growthShortLabel;

  /// No description provided for @growthShortcutLabel.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growthShortcutLabel;

  /// No description provided for @growthType.
  ///
  /// In en, this message translates to:
  /// **'Measurement Type'**
  String get growthType;

  /// No description provided for @growthUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get growthUnit;

  /// No description provided for @growthValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get growthValue;

  /// No description provided for @growthValueHintHeight.
  ///
  /// In en, this message translates to:
  /// **'e.g., 65'**
  String get growthValueHintHeight;

  /// No description provided for @growthValueHintWeight.
  ///
  /// In en, this message translates to:
  /// **'e.g., 7.5'**
  String get growthValueHintWeight;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get hasAccount;

  /// No description provided for @havePromoCode.
  ///
  /// In en, this message translates to:
  /// **'Have a promo code?'**
  String get havePromoCode;

  /// No description provided for @hazelColor.
  ///
  /// In en, this message translates to:
  /// **'Hazel'**
  String get hazelColor;

  /// No description provided for @headCircCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference'**
  String get headCircCategoryLabel;

  /// No description provided for @headCircumference.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference'**
  String get headCircumference;

  /// No description provided for @headLabel.
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get headLabel;

  /// No description provided for @headLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference'**
  String get headLabelShort;

  /// No description provided for @headWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Head (cm)'**
  String get headWithUnit;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @healthCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get healthCategory;

  /// No description provided for @healthEventDeleted.
  ///
  /// In en, this message translates to:
  /// **'Health event deleted'**
  String get healthEventDeleted;

  /// No description provided for @healthRecords.
  ///
  /// In en, this message translates to:
  /// **'Health Records'**
  String get healthRecords;

  /// No description provided for @heartfeltWish.
  ///
  /// In en, this message translates to:
  /// **'A heartfelt wish'**
  String get heartfeltWish;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @heightCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightCategoryLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @heightLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabelShort;

  /// No description provided for @heightValueCm.
  ///
  /// In en, this message translates to:
  /// **'Height: {height} cm'**
  String heightValueCm(Object height, Object value);

  /// No description provided for @heightWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String heightWithUnit(Object unit, Object value);

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @hideDetails.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get hideDetails;

  /// No description provided for @hospitalCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospitalCategoryLabel;

  /// No description provided for @hospitalLabel.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospitalLabel;

  /// No description provided for @hourLabel.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hourLabel;

  /// No description provided for @iAcceptThe.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get iAcceptThe;

  /// No description provided for @iConsentToDataProcessing.
  ///
  /// In en, this message translates to:
  /// **'I consent to processing of child health & development data'**
  String get iConsentToDataProcessing;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get iUnderstand;

  /// No description provided for @iUnderstandContinue.
  ///
  /// In en, this message translates to:
  /// **'I Understand — Continue'**
  String get iUnderstandContinue;

  /// No description provided for @iUnderstandThankYou.
  ///
  /// In en, this message translates to:
  /// **'I Understand — Thank You'**
  String get iUnderstandThankYou;

  /// No description provided for @idea.
  ///
  /// In en, this message translates to:
  /// **'Just an Idea'**
  String get idea;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperial;

  /// No description provided for @increaseValue.
  ///
  /// In en, this message translates to:
  /// **'Increase value'**
  String get increaseValue;

  /// No description provided for @increaseValueSemantic.
  ///
  /// In en, this message translates to:
  /// **'Increase value'**
  String get increaseValueSemantic;

  /// No description provided for @incubatingStage.
  ///
  /// In en, this message translates to:
  /// **'Incubating'**
  String get incubatingStage;

  /// No description provided for @incubatingStageDesc.
  ///
  /// In en, this message translates to:
  /// **'A beautiful surprise.\nThe journey began in stillness.'**
  String get incubatingStageDesc;

  /// No description provided for @incubatingStageSubtext.
  ///
  /// In en, this message translates to:
  /// **'Expecting a surprise!\nWhen is it due?'**
  String get incubatingStageSubtext;

  /// No description provided for @infantStage.
  ///
  /// In en, this message translates to:
  /// **'Infant'**
  String get infantStage;

  /// No description provided for @injuryCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Injury'**
  String get injuryCategoryLabel;

  /// No description provided for @injuryLabel.
  ///
  /// In en, this message translates to:
  /// **'Injury'**
  String get injuryLabel;

  /// No description provided for @instantAnswersFast.
  ///
  /// In en, this message translates to:
  /// **'Instant answers, fast download'**
  String get instantAnswersFast;

  /// No description provided for @instantAnswersLabel.
  ///
  /// In en, this message translates to:
  /// **'Instant answers, fast download'**
  String get instantAnswersLabel;

  /// No description provided for @invitationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get invitationDeclined;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent!'**
  String get invitationSent;

  /// No description provided for @invitationSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent!'**
  String get invitationSentMessage;

  /// No description provided for @invitePartner.
  ///
  /// In en, this message translates to:
  /// **'Invite Co-Parent'**
  String get invitePartner;

  /// No description provided for @invitePartnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite Partner'**
  String get invitePartnerTitle;

  /// No description provided for @isItNormalRefuseSolids.
  ///
  /// In en, this message translates to:
  /// **'Is it normal for my baby to refuse solids at 6 months?'**
  String get isItNormalRefuseSolids;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @journalEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your journal is empty'**
  String get journalEmpty;

  /// No description provided for @journalEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Milestones, feedings, and health records you add will appear here.'**
  String get journalEmptySubtitle;

  /// No description provided for @journalEntry.
  ///
  /// In en, this message translates to:
  /// **'Journal Entry'**
  String get journalEntry;

  /// No description provided for @journeyBegun.
  ///
  /// In en, this message translates to:
  /// **'The journey has begun'**
  String get journeyBegun;

  /// No description provided for @journeyJournal.
  ///
  /// In en, this message translates to:
  /// **'Journey Journal'**
  String get journeyJournal;

  /// No description provided for @keepCaringBadges.
  ///
  /// In en, this message translates to:
  /// **'Keep caring for your BabyMon to earn badges!'**
  String get keepCaringBadges;

  /// No description provided for @keepTracking.
  ///
  /// In en, this message translates to:
  /// **'Keep tracking to unlock!'**
  String get keepTracking;

  /// No description provided for @keepTrackingMoment.
  ///
  /// In en, this message translates to:
  /// **'Keep tracking -- every moment counts!'**
  String get keepTrackingMoment;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageComm.
  ///
  /// In en, this message translates to:
  /// **'Language & Communication'**
  String get languageComm;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageHebrew.
  ///
  /// In en, this message translates to:
  /// **'עברית'**
  String get languageHebrew;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @latestGrowthLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest Growth'**
  String get latestGrowthLabel;

  /// No description provided for @latestWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest Weight'**
  String get latestWeightLabel;

  /// No description provided for @latestWeightSemantic.
  ///
  /// In en, this message translates to:
  /// **'Latest weight: {weight}'**
  String latestWeightSemantic(Object weight);

  /// No description provided for @lb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get lb;

  /// No description provided for @levelFallback.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelFallback(Object level);

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelLabel;

  /// No description provided for @levelName1.
  ///
  /// In en, this message translates to:
  /// **'Little Seed'**
  String get levelName1;

  /// No description provided for @levelName10.
  ///
  /// In en, this message translates to:
  /// **'Crawler'**
  String get levelName10;

  /// No description provided for @levelName11.
  ///
  /// In en, this message translates to:
  /// **'Solid Feeder'**
  String get levelName11;

  /// No description provided for @levelName12.
  ///
  /// In en, this message translates to:
  /// **'Standing Strong'**
  String get levelName12;

  /// No description provided for @levelName13.
  ///
  /// In en, this message translates to:
  /// **'First Stepper'**
  String get levelName13;

  /// No description provided for @levelName14.
  ///
  /// In en, this message translates to:
  /// **'Wave Master'**
  String get levelName14;

  /// No description provided for @levelName15.
  ///
  /// In en, this message translates to:
  /// **'Clapper'**
  String get levelName15;

  /// No description provided for @levelName16.
  ///
  /// In en, this message translates to:
  /// **'Little Runner'**
  String get levelName16;

  /// No description provided for @levelName17.
  ///
  /// In en, this message translates to:
  /// **'Dancer'**
  String get levelName17;

  /// No description provided for @levelName18.
  ///
  /// In en, this message translates to:
  /// **'Climber'**
  String get levelName18;

  /// No description provided for @levelName19.
  ///
  /// In en, this message translates to:
  /// **'Singer'**
  String get levelName19;

  /// No description provided for @levelName2.
  ///
  /// In en, this message translates to:
  /// **'Tiny Gripper'**
  String get levelName2;

  /// No description provided for @levelName20.
  ///
  /// In en, this message translates to:
  /// **'Chatterbox'**
  String get levelName20;

  /// No description provided for @levelName21.
  ///
  /// In en, this message translates to:
  /// **'Helper'**
  String get levelName21;

  /// No description provided for @levelName22.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get levelName22;

  /// No description provided for @levelName23.
  ///
  /// In en, this message translates to:
  /// **'Joker'**
  String get levelName23;

  /// No description provided for @levelName24.
  ///
  /// In en, this message translates to:
  /// **'Problem Solver'**
  String get levelName24;

  /// No description provided for @levelName25.
  ///
  /// In en, this message translates to:
  /// **'Storyteller'**
  String get levelName25;

  /// No description provided for @levelName26.
  ///
  /// In en, this message translates to:
  /// **'Braveheart'**
  String get levelName26;

  /// No description provided for @levelName27.
  ///
  /// In en, this message translates to:
  /// **'Peacekeeper'**
  String get levelName27;

  /// No description provided for @levelName28.
  ///
  /// In en, this message translates to:
  /// **'Dreamer'**
  String get levelName28;

  /// No description provided for @levelName29.
  ///
  /// In en, this message translates to:
  /// **'Spark'**
  String get levelName29;

  /// No description provided for @levelName3.
  ///
  /// In en, this message translates to:
  /// **'Bright Eyes'**
  String get levelName3;

  /// No description provided for @levelName30.
  ///
  /// In en, this message translates to:
  /// **'Shining Light'**
  String get levelName30;

  /// No description provided for @levelName31.
  ///
  /// In en, this message translates to:
  /// **'Gentle Soul'**
  String get levelName31;

  /// No description provided for @levelName32.
  ///
  /// In en, this message translates to:
  /// **'Wild Spirit'**
  String get levelName32;

  /// No description provided for @levelName33.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get levelName33;

  /// No description provided for @levelName34.
  ///
  /// In en, this message translates to:
  /// **'Inventor'**
  String get levelName34;

  /// No description provided for @levelName35.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get levelName35;

  /// No description provided for @levelName36.
  ///
  /// In en, this message translates to:
  /// **'Philosopher'**
  String get levelName36;

  /// No description provided for @levelName37.
  ///
  /// In en, this message translates to:
  /// **'Magic Maker'**
  String get levelName37;

  /// No description provided for @levelName38.
  ///
  /// In en, this message translates to:
  /// **'Stargazer'**
  String get levelName38;

  /// No description provided for @levelName39.
  ///
  /// In en, this message translates to:
  /// **'Pathfinder'**
  String get levelName39;

  /// No description provided for @levelName4.
  ///
  /// In en, this message translates to:
  /// **'First Smiler'**
  String get levelName4;

  /// No description provided for @levelName40.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get levelName40;

  /// No description provided for @levelName41.
  ///
  /// In en, this message translates to:
  /// **'Visionary'**
  String get levelName41;

  /// No description provided for @levelName42.
  ///
  /// In en, this message translates to:
  /// **'Harmonizer'**
  String get levelName42;

  /// No description provided for @levelName43.
  ///
  /// In en, this message translates to:
  /// **'Alchemist'**
  String get levelName43;

  /// No description provided for @levelName44.
  ///
  /// In en, this message translates to:
  /// **'Sage'**
  String get levelName44;

  /// No description provided for @levelName45.
  ///
  /// In en, this message translates to:
  /// **'Elder'**
  String get levelName45;

  /// No description provided for @levelName46.
  ///
  /// In en, this message translates to:
  /// **'Mystic'**
  String get levelName46;

  /// No description provided for @levelName47.
  ///
  /// In en, this message translates to:
  /// **'Navigator'**
  String get levelName47;

  /// No description provided for @levelName48.
  ///
  /// In en, this message translates to:
  /// **'Oracle'**
  String get levelName48;

  /// No description provided for @levelName49.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get levelName49;

  /// No description provided for @levelName5.
  ///
  /// In en, this message translates to:
  /// **'Cozy Sleeper'**
  String get levelName5;

  /// No description provided for @levelName50.
  ///
  /// In en, this message translates to:
  /// **'LUMINARY'**
  String get levelName50;

  /// No description provided for @levelName6.
  ///
  /// In en, this message translates to:
  /// **'Happy Kicker'**
  String get levelName6;

  /// No description provided for @levelName7.
  ///
  /// In en, this message translates to:
  /// **'Little Explorer'**
  String get levelName7;

  /// No description provided for @levelName8.
  ///
  /// In en, this message translates to:
  /// **'Babbler'**
  String get levelName8;

  /// No description provided for @levelName9.
  ///
  /// In en, this message translates to:
  /// **'Rolling Wonder'**
  String get levelName9;

  /// No description provided for @levelShort.
  ///
  /// In en, this message translates to:
  /// **'Lv'**
  String get levelShort;

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'Level Up!'**
  String get levelUp;

  /// No description provided for @levelUpSemanticsFormat.
  ///
  /// In en, this message translates to:
  /// **'Level up! Your BabyMon is now {name}.'**
  String levelUpSemanticsFormat(Object name, Object level);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingBabyMonMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading your BabyMon...'**
  String get loadingBabyMonMessage;

  /// No description provided for @loadingDashboardMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading your dashboard...'**
  String get loadingDashboardMessage;

  /// No description provided for @localeUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update language'**
  String get localeUpdateFailed;

  /// No description provided for @localeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get localeUpdated;

  /// No description provided for @locationOnBody.
  ///
  /// In en, this message translates to:
  /// **'Location on body'**
  String get locationOnBody;

  /// No description provided for @logFeed.
  ///
  /// In en, this message translates to:
  /// **'Log Feeding'**
  String get logFeed;

  /// No description provided for @logFeedingAction.
  ///
  /// In en, this message translates to:
  /// **'Log feeding'**
  String get logFeedingAction;

  /// No description provided for @logGrowth.
  ///
  /// In en, this message translates to:
  /// **'Log Growth'**
  String get logGrowth;

  /// No description provided for @logHealth.
  ///
  /// In en, this message translates to:
  /// **'Log Health Record'**
  String get logHealth;

  /// No description provided for @logHealthRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Health Record'**
  String get logHealthRecordTitle;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutTitle;

  /// No description provided for @logSleep.
  ///
  /// In en, this message translates to:
  /// **'Log Sleep'**
  String get logSleep;

  /// Title for the add sleep log dialog
  ///
  /// In en, this message translates to:
  /// **'Log Sleep'**
  String get logSleepTitle;

  /// No description provided for @logged.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get logged;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLink;

  /// No description provided for @loginSemantic.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get loginSemantic;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue tracking your BabyMon\'s journey'**
  String get loginSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get loginTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutMessage;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitleLabel;

  /// No description provided for @luminaryLine1.
  ///
  /// In en, this message translates to:
  /// **'From a tiny seed to a shining soul.'**
  String get luminaryLine1;

  /// No description provided for @luminaryLine2.
  ///
  /// In en, this message translates to:
  /// **'You\'ve guided every step.'**
  String get luminaryLine2;

  /// No description provided for @luminaryLine3.
  ///
  /// In en, this message translates to:
  /// **'This is the work of an amazing parent.'**
  String get luminaryLine3;

  /// No description provided for @main.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get main;

  /// No description provided for @maleGender.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get maleGender;

  /// No description provided for @managePartners.
  ///
  /// In en, this message translates to:
  /// **'Manage Partners'**
  String get managePartners;

  /// No description provided for @managePartnersDesc.
  ///
  /// In en, this message translates to:
  /// **'Co-parents & guardians with access'**
  String get managePartnersDesc;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @markAchievedSemantic.
  ///
  /// In en, this message translates to:
  /// **'Mark achieved:'**
  String get markAchievedSemantic;

  /// No description provided for @markAchievedSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Mark achieved: {title}'**
  String markAchievedSemanticLabel(Object title);

  /// No description provided for @markCompleteSemantic.
  ///
  /// In en, this message translates to:
  /// **'Mark complete:'**
  String get markCompleteSemantic;

  /// No description provided for @markCompleteSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Mark complete: {activity}'**
  String markCompleteSemanticLabel(Object activity);

  /// No description provided for @masterLevel.
  ///
  /// In en, this message translates to:
  /// **'Master Level'**
  String get masterLevel;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @measurement.
  ///
  /// In en, this message translates to:
  /// **'Measurement'**
  String get measurement;

  /// No description provided for @measurementUnits.
  ///
  /// In en, this message translates to:
  /// **'Measurement units'**
  String get measurementUnits;

  /// No description provided for @medTeamShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Med Team'**
  String get medTeamShortLabel;

  /// No description provided for @medicalAiDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical & AI Disclaimer'**
  String get medicalAiDisclaimerTitle;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The AI Companion is not a substitute for professional medical advice. Always consult your healthcare provider.'**
  String get medicalDisclaimer;

  /// No description provided for @medicalDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get medicalDisclaimerTitle;

  /// No description provided for @medicalTeam.
  ///
  /// In en, this message translates to:
  /// **'Medical Team'**
  String get medicalTeam;

  /// No description provided for @medicalTeamAdded.
  ///
  /// In en, this message translates to:
  /// **'Medical team member added'**
  String get medicalTeamAdded;

  /// No description provided for @medicalTeamAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Medical team member added'**
  String get medicalTeamAddedMessage;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @middleName.
  ///
  /// In en, this message translates to:
  /// **'Middle Name'**
  String get middleName;

  /// No description provided for @middleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Middle Name'**
  String get middleNameLabel;

  /// No description provided for @mild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get mild;

  /// No description provided for @milestoneAchieved.
  ///
  /// In en, this message translates to:
  /// **'Milestone achieved!'**
  String get milestoneAchieved;

  /// No description provided for @milestoneAchievedNotification.
  ///
  /// In en, this message translates to:
  /// **'Milestone achieved!'**
  String get milestoneAchievedNotification;

  /// No description provided for @milestoneDate.
  ///
  /// In en, this message translates to:
  /// **'Date Achieved'**
  String get milestoneDate;

  /// No description provided for @milestoneDomain.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get milestoneDomain;

  /// No description provided for @milestoneNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get milestoneNotes;

  /// No description provided for @milestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestone Title'**
  String get milestoneTitle;

  /// No description provided for @milestoneUndone.
  ///
  /// In en, this message translates to:
  /// **'Milestone undone'**
  String get milestoneUndone;

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestones;

  /// No description provided for @milestonesTab.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestonesTab;

  /// No description provided for @minLabel.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minLabel;

  /// No description provided for @minOnWifi.
  ///
  /// In en, this message translates to:
  /// **'min on Wi-Fi'**
  String get minOnWifi;

  /// No description provided for @minOnWifiLabel.
  ///
  /// In en, this message translates to:
  /// **'min on Wi-Fi'**
  String get minOnWifiLabel;

  /// No description provided for @minutesUnit.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutesUnit;

  /// No description provided for @mjMessageStep0.
  ///
  /// In en, this message translates to:
  /// **'Every great journey begins with a single heartbeat.'**
  String get mjMessageStep0;

  /// No description provided for @mjMessageStep1.
  ///
  /// In en, this message translates to:
  /// **'Names carry stories. What will yours be called?'**
  String get mjMessageStep1;

  /// No description provided for @mjMessageStep2.
  ///
  /// In en, this message translates to:
  /// **'Every journey begins at a different point. When did yours begin?'**
  String get mjMessageStep2;

  /// No description provided for @mjMessageStep3.
  ///
  /// In en, this message translates to:
  /// **'Every BabyMon has a unique spirit. Let\'s discover yours.'**
  String get mjMessageStep3;

  /// No description provided for @mjMessageStep4.
  ///
  /// In en, this message translates to:
  /// **'You\'ve written the first page of your story together.\nAre you ready to begin?'**
  String get mjMessageStep4;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @moGender.
  ///
  /// In en, this message translates to:
  /// **'Mo'**
  String get moGender;

  /// No description provided for @moNeutralLabel.
  ///
  /// In en, this message translates to:
  /// **'Mo (Neutral)'**
  String get moNeutralLabel;

  /// No description provided for @modelDeleted.
  ///
  /// In en, this message translates to:
  /// **'model deleted'**
  String get modelDeleted;

  /// No description provided for @modelDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get modelDeletedMessage;

  /// No description provided for @modelDownload.
  ///
  /// In en, this message translates to:
  /// **'Model Download'**
  String get modelDownload;

  /// No description provided for @modelNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'AI model not loaded. Please download the model first.'**
  String get modelNotLoaded;

  /// No description provided for @modelRequired.
  ///
  /// In en, this message translates to:
  /// **'The AI Companion needs to download a language model to provide personalized guidance on your device.'**
  String get modelRequired;

  /// No description provided for @modelUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Model Update Available'**
  String get modelUpdateAvailable;

  /// No description provided for @modelsRunOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Models run entirely on your device. Nothing is sent to the cloud.'**
  String get modelsRunOnDevice;

  /// No description provided for @modelsRunOnDeviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Models run entirely on your device. Nothing is sent to external servers.'**
  String get modelsRunOnDeviceDesc;

  /// No description provided for @modelsStoredLocallyDesc.
  ///
  /// In en, this message translates to:
  /// **'Downloaded models are stored locally and can be deleted at any time.'**
  String get modelsStoredLocallyDesc;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @monieseFemaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Moniese (Female)'**
  String get monieseFemaleLabel;

  /// No description provided for @monieseGender.
  ///
  /// In en, this message translates to:
  /// **'Moniese'**
  String get monieseGender;

  /// No description provided for @moniousGender.
  ///
  /// In en, this message translates to:
  /// **'Monious'**
  String get moniousGender;

  /// No description provided for @moniousMaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Monious (Male)'**
  String get moniousMaleLabel;

  /// No description provided for @monthAbbr.
  ///
  /// In en, this message translates to:
  /// **'mo'**
  String get monthAbbr;

  /// No description provided for @monthsOld.
  ///
  /// In en, this message translates to:
  /// **'{months} months old'**
  String monthsOld(int months);

  /// No description provided for @monthsUnit.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get monthsUnit;

  /// No description provided for @monthsUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get monthsUnitLabel;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @moreFeatures.
  ///
  /// In en, this message translates to:
  /// **'More Features'**
  String get moreFeatures;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @moreSteps.
  ///
  /// In en, this message translates to:
  /// **'more steps'**
  String get moreSteps;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @mustAcceptPrivacy.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Privacy Policy'**
  String get mustAcceptPrivacy;

  /// No description provided for @mustAcceptTos.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms of Service'**
  String get mustAcceptTos;

  /// No description provided for @mustConsentData.
  ///
  /// In en, this message translates to:
  /// **'You must consent to data processing'**
  String get mustConsentData;

  /// No description provided for @nameHintDoctor.
  ///
  /// In en, this message translates to:
  /// **'Dr. Smith'**
  String get nameHintDoctor;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get nameOptional;

  /// No description provided for @nameOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get nameOptionalLabel;

  /// No description provided for @nameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name / Title'**
  String get nameTitle;

  /// No description provided for @nameTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Name / Title'**
  String get nameTitleLabel;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated!'**
  String get nameUpdated;

  /// No description provided for @nap.
  ///
  /// In en, this message translates to:
  /// **'Nap'**
  String get nap;

  /// No description provided for @napLabel.
  ///
  /// In en, this message translates to:
  /// **'Nap'**
  String get napLabel;

  /// No description provided for @navigateToLogin.
  ///
  /// In en, this message translates to:
  /// **'Navigate to login'**
  String get navigateToLogin;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help? Talk to support'**
  String get needHelp;

  /// No description provided for @needHelpLabel.
  ///
  /// In en, this message translates to:
  /// **'Need help? Talk to support'**
  String get needHelpLabel;

  /// No description provided for @needsEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Needs Evaluation'**
  String get needsEvaluation;

  /// No description provided for @neonateStage.
  ///
  /// In en, this message translates to:
  /// **'Neonate'**
  String get neonateStage;

  /// No description provided for @neutralGender.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutralGender;

  /// No description provided for @newLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}: {name}'**
  String newLevel(int level, Object name);

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @newerVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'A newer AI model is available. Update to get improved responses and new features.'**
  String get newerVersionAvailable;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @nextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextLabel;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @nightSleep.
  ///
  /// In en, this message translates to:
  /// **'Night Sleep'**
  String get nightSleep;

  /// No description provided for @nightSleepLabel.
  ///
  /// In en, this message translates to:
  /// **'Night sleep'**
  String get nightSleepLabel;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @noAdviceCards.
  ///
  /// In en, this message translates to:
  /// **'No advice cards yet'**
  String get noAdviceCards;

  /// No description provided for @noAiModelInstalled.
  ///
  /// In en, this message translates to:
  /// **'No AI model installed'**
  String get noAiModelInstalled;

  /// No description provided for @noBabyMonForCompanion.
  ///
  /// In en, this message translates to:
  /// **'Create your first BabyMon to access AI-powered parenting guidance.'**
  String get noBabyMonForCompanion;

  /// No description provided for @noBabyMonFound.
  ///
  /// In en, this message translates to:
  /// **'No BabyMon found'**
  String get noBabyMonFound;

  /// No description provided for @noBabyMonFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No BabyMon found'**
  String get noBabyMonFoundMessage;

  /// No description provided for @noBabyMonSelected.
  ///
  /// In en, this message translates to:
  /// **'No BabyMon selected'**
  String get noBabyMonSelected;

  /// No description provided for @noBabyMonToExport.
  ///
  /// In en, this message translates to:
  /// **'No BabyMon to export'**
  String get noBabyMonToExport;

  /// No description provided for @noBabyMonsToDelete.
  ///
  /// In en, this message translates to:
  /// **'No BabyMons to delete'**
  String get noBabyMonsToDelete;

  /// No description provided for @noBadges.
  ///
  /// In en, this message translates to:
  /// **'No badges yet'**
  String get noBadges;

  /// No description provided for @noBadgesYetLabel.
  ///
  /// In en, this message translates to:
  /// **'No badges yet'**
  String get noBadgesYetLabel;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noDateFallback.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDateFallback;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntries;

  /// No description provided for @noFeedingLogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to log your first feeding.'**
  String get noFeedingLogsSubtitle;

  /// No description provided for @noFeedingLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'No feeding logs yet'**
  String get noFeedingLogsTitle;

  /// No description provided for @noHealthRecordsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add a measurement, allergy, or clinic visit.'**
  String get noHealthRecordsSubtitle;

  /// No description provided for @noHealthRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'No health records yet'**
  String get noHealthRecordsTitle;

  /// No description provided for @noHealthRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No health records yet'**
  String get noHealthRecordsYet;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @noItemSelected.
  ///
  /// In en, this message translates to:
  /// **'No {item} selected'**
  String noItemSelected(Object item);

  /// No description provided for @noItemYet.
  ///
  /// In en, this message translates to:
  /// **'No {item} yet'**
  String noItemYet(Object item);

  /// No description provided for @noMilestones.
  ///
  /// In en, this message translates to:
  /// **'No milestones recorded yet'**
  String get noMilestones;

  /// No description provided for @noMilestonesInCategory.
  ///
  /// In en, this message translates to:
  /// **'No milestones in this category'**
  String get noMilestonesInCategory;

  /// No description provided for @noPartnersYet.
  ///
  /// In en, this message translates to:
  /// **'No partners yet'**
  String get noPartnersYet;

  /// No description provided for @noPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotos;

  /// No description provided for @noSavedCards.
  ///
  /// In en, this message translates to:
  /// **'No saved cards yet'**
  String get noSavedCards;

  /// No description provided for @noTimeFallback.
  ///
  /// In en, this message translates to:
  /// **'--:--'**
  String get noTimeFallback;

  /// No description provided for @noValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get noValidEmail;

  /// No description provided for @noneRecorded.
  ///
  /// In en, this message translates to:
  /// **'None recorded'**
  String get noneRecorded;

  /// No description provided for @notAvailableAbbr.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailableAbbr;

  /// No description provided for @notForEmergenciesDesc.
  ///
  /// In en, this message translates to:
  /// **'In a medical emergency, stop using this app and call 911 or your local emergency number immediately. Do not rely on the AI Companion in emergency situations.'**
  String get notForEmergenciesDesc;

  /// No description provided for @notForEmergenciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Not for Emergencies'**
  String get notForEmergenciesTitle;

  /// No description provided for @notMedicalDeviceDesc.
  ///
  /// In en, this message translates to:
  /// **'The AI Companion is not a medical device. It does not diagnose, treat, or provide medical advice. Always consult a qualified healthcare provider for medical decisions.'**
  String get notMedicalDeviceDesc;

  /// No description provided for @notMedicalDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Not a Medical Device'**
  String get notMedicalDeviceTitle;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @notSelectedSemantic.
  ///
  /// In en, this message translates to:
  /// **'not selected'**
  String get notSelectedSemantic;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @noteOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning weigh-in'**
  String get noteOptionalHint;

  /// No description provided for @notesOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptionalLabel;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationPreferences;

  /// No description provided for @notificationPreferencesDesc.
  ///
  /// In en, this message translates to:
  /// **'Push, milestone reminders, partner activity'**
  String get notificationPreferencesDesc;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications coming soon'**
  String get notificationsComingSoon;

  /// No description provided for @notificationsComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications coming soon'**
  String get notificationsComingSoonMessage;

  /// No description provided for @notifyMeWhenReady.
  ///
  /// In en, this message translates to:
  /// **'Notify me when ready'**
  String get notifyMeWhenReady;

  /// No description provided for @ofTotal.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofTotal;

  /// No description provided for @older.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get older;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @onDeviceAiNoReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Responses are generated by a small AI model running entirely on your device. They are not reviewed by humans. Verify important information independently.'**
  String get onDeviceAiNoReviewDesc;

  /// No description provided for @onDeviceAiNoReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'On-Device AI, Not Reviewed'**
  String get onDeviceAiNoReviewTitle;

  /// No description provided for @onDeviceAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Your On-Device\nAI Companion'**
  String get onDeviceAiTitle;

  /// No description provided for @openProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Open profile settings'**
  String get openProfileSettings;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @otherCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherCategoryLabel;

  /// No description provided for @otherOption.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherOption;

  /// No description provided for @outcomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get outcomeLabel;

  /// No description provided for @oz.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get oz;

  /// No description provided for @parentContactNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent Contact #'**
  String get parentContactNumberLabel;

  /// No description provided for @parentGuardianNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent/Guardian Name'**
  String get parentGuardianNameLabel;

  /// No description provided for @parentLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parentLabel;

  /// No description provided for @parentingCoachOnDevice.
  ///
  /// In en, this message translates to:
  /// **'A parenting coach that runs entirely on your phone.\nNothing leaves your device.'**
  String get parentingCoachOnDevice;

  /// No description provided for @parentingCoachSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A parenting coach that runs entirely on your phone.\nNothing leaves your device.'**
  String get parentingCoachSubtitle;

  /// No description provided for @partnerAccepted.
  ///
  /// In en, this message translates to:
  /// **'Partner accepted!'**
  String get partnerAccepted;

  /// No description provided for @partnerEmail.
  ///
  /// In en, this message translates to:
  /// **'Partner Email'**
  String get partnerEmail;

  /// No description provided for @partnerRemoved.
  ///
  /// In en, this message translates to:
  /// **'Partner removed'**
  String get partnerRemoved;

  /// No description provided for @partnerRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Partner removed'**
  String get partnerRemovedMessage;

  /// No description provided for @partners.
  ///
  /// In en, this message translates to:
  /// **'Co-Parents'**
  String get partners;

  /// No description provided for @passwordFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordFair;

  /// No description provided for @passwordGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordGood;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordMinLengthShort.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get passwordMinLengthShort;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters with uppercase, lowercase, and numbers'**
  String get passwordRequirements;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successful. Please login.'**
  String get passwordResetSuccess;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password Strength'**
  String get passwordStrength;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @paymentNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Payment is not configured yet. Please try again later.'**
  String get paymentNotConfigured;

  /// No description provided for @paymentNotConfiguredMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment is not configured yet. Please try again later.'**
  String get paymentNotConfiguredMessage;

  /// No description provided for @pediatricianHint.
  ///
  /// In en, this message translates to:
  /// **'Pediatrician'**
  String get pediatricianHint;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @pendingInvites.
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pendingInvites;

  /// No description provided for @pendingProposals.
  ///
  /// In en, this message translates to:
  /// **'Pending Proposals'**
  String get pendingProposals;

  /// No description provided for @percentile.
  ///
  /// In en, this message translates to:
  /// **'{p}th percentile'**
  String percentile(int p);

  /// No description provided for @permanentDeletion.
  ///
  /// In en, this message translates to:
  /// **'Permanent Deletion'**
  String get permanentDeletion;

  /// No description provided for @phaseDescGrowth.
  ///
  /// In en, this message translates to:
  /// **'On the move -- crawling, tasting, laughing out loud'**
  String get phaseDescGrowth;

  /// No description provided for @phaseDescPeak.
  ///
  /// In en, this message translates to:
  /// **'Limitless energy -- running, climbing, conquering'**
  String get phaseDescPeak;

  /// No description provided for @phaseDescSeed.
  ///
  /// In en, this message translates to:
  /// **'Newborn cocoon -- quiet, sacred, tiny miracles'**
  String get phaseDescSeed;

  /// No description provided for @phaseDescSprout.
  ///
  /// In en, this message translates to:
  /// **'Eyes wide open -- every sound, every touch, discovery'**
  String get phaseDescSprout;

  /// No description provided for @phaseDescStar.
  ///
  /// In en, this message translates to:
  /// **'Final climb -- bright, kind, curious, ready for the world'**
  String get phaseDescStar;

  /// No description provided for @phaseDescTree.
  ///
  /// In en, this message translates to:
  /// **'Standing tall -- walking, talking, becoming'**
  String get phaseDescTree;

  /// No description provided for @phaseEmblemGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get phaseEmblemGrowth;

  /// No description provided for @phaseEmblemPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get phaseEmblemPeak;

  /// No description provided for @phaseEmblemSeed.
  ///
  /// In en, this message translates to:
  /// **'Seed'**
  String get phaseEmblemSeed;

  /// No description provided for @phaseEmblemSprout.
  ///
  /// In en, this message translates to:
  /// **'Sprout'**
  String get phaseEmblemSprout;

  /// No description provided for @phaseEmblemStar.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get phaseEmblemStar;

  /// No description provided for @phaseEmblemTree.
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get phaseEmblemTree;

  /// No description provided for @phaseMilestone.
  ///
  /// In en, this message translates to:
  /// **'Phase Milestone'**
  String get phaseMilestone;

  /// No description provided for @photoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted'**
  String get photoDeleted;

  /// No description provided for @photoFromAlbum.
  ///
  /// In en, this message translates to:
  /// **'Photo from baby album'**
  String get photoFromAlbum;

  /// No description provided for @photoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded!'**
  String get photoUploaded;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get pickFromGallery;

  /// No description provided for @pieceLabel.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get pieceLabel;

  /// No description provided for @plan7DayHistory.
  ///
  /// In en, this message translates to:
  /// **'7-day history'**
  String get plan7DayHistory;

  /// No description provided for @planAiStageContent.
  ///
  /// In en, this message translates to:
  /// **'AI-powered stage content & tips'**
  String get planAiStageContent;

  /// No description provided for @planBadgeAnimations.
  ///
  /// In en, this message translates to:
  /// **'Badge animations & effects'**
  String get planBadgeAnimations;

  /// No description provided for @planEverythingInFree.
  ///
  /// In en, this message translates to:
  /// **'Everything in Free, plus:'**
  String get planEverythingInFree;

  /// No description provided for @planEvolutionNarratives.
  ///
  /// In en, this message translates to:
  /// **'Evolution narratives'**
  String get planEvolutionNarratives;

  /// No description provided for @planExportData.
  ///
  /// In en, this message translates to:
  /// **'Export your data'**
  String get planExportData;

  /// No description provided for @planLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planLabel;

  /// No description provided for @planMilestonesFeeding.
  ///
  /// In en, this message translates to:
  /// **'Milestones, feeding, health'**
  String get planMilestonesFeeding;

  /// No description provided for @planMultiBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Multiple BabyMon profiles'**
  String get planMultiBabyMon;

  /// No description provided for @planPhotoAlbum.
  ///
  /// In en, this message translates to:
  /// **'Photo album (S3 storage)'**
  String get planPhotoAlbum;

  /// No description provided for @planPricingFooter.
  ///
  /// In en, this message translates to:
  /// **'\$4.99/month, auto-renews. Cancel at least 24 hours before renewal.'**
  String get planPricingFooter;

  /// No description provided for @planPrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get planPrioritySupport;

  /// No description provided for @planPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get planPushNotifications;

  /// No description provided for @planStageDesc.
  ///
  /// In en, this message translates to:
  /// **'A heartfelt wish.\nLong before they existed,\nthey were loved.'**
  String get planStageDesc;

  /// No description provided for @planStageSubtext.
  ///
  /// In en, this message translates to:
  /// **'Wouldn\'t it be nice to catch\n1 or 2 little BabyMons?'**
  String get planStageSubtext;

  /// No description provided for @planUnlimitedHistory.
  ///
  /// In en, this message translates to:
  /// **'Unlimited history'**
  String get planUnlimitedHistory;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter an allergy name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterValidValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid measurement value'**
  String get pleaseEnterValidValue;

  /// No description provided for @pleaseEnterValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get pleaseEnterValue;

  /// No description provided for @pleaseSelectAmount.
  ///
  /// In en, this message translates to:
  /// **'Please select a feeding amount'**
  String get pleaseSelectAmount;

  /// No description provided for @pleaseSelectDob.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get pleaseSelectDob;

  /// No description provided for @plusXpFormat.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String plusXpFormat(Object xp);

  /// No description provided for @poorQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poorQualityLabel;

  /// No description provided for @poweredByEnasAi.
  ///
  /// In en, this message translates to:
  /// **'Powered by Enas AI'**
  String get poweredByEnasAi;

  /// No description provided for @poweredByOnDeviceAi.
  ///
  /// In en, this message translates to:
  /// **'I\'m powered by an on-device AI that runs entirely on your phone. Nothing you share leaves your device. Ask me anything about your baby\'s development, sleep, feeding, or health — but always consult your doctor for medical concerns.'**
  String get poweredByOnDeviceAi;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @premiumBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Companion chats'**
  String get premiumBenefit1;

  /// No description provided for @premiumBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Personalized weekly parenting briefs'**
  String get premiumBenefit2;

  /// No description provided for @premiumBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Stage-specific expert advice cards'**
  String get premiumBenefit3;

  /// No description provided for @premiumBenefit4.
  ///
  /// In en, this message translates to:
  /// **'Priority support & early features'**
  String get premiumBenefit4;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// No description provided for @premiumFeatureHeading.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeatureHeading;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPlan;

  /// No description provided for @premiumRequired.
  ///
  /// In en, this message translates to:
  /// **'Better Quality requires a Premium subscription.'**
  String get premiumRequired;

  /// No description provided for @preparingArrival.
  ///
  /// In en, this message translates to:
  /// **'Preparing a gentle arrival...'**
  String get preparingArrival;

  /// No description provided for @preparingDashboardMessage.
  ///
  /// In en, this message translates to:
  /// **'Preparing your dashboard...'**
  String get preparingDashboardMessage;

  /// No description provided for @preschoolerStage.
  ///
  /// In en, this message translates to:
  /// **'Preschooler'**
  String get preschoolerStage;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @priceNote.
  ///
  /// In en, this message translates to:
  /// **'\$4.99/month · Cancel anytime'**
  String get priceNote;

  /// No description provided for @privacyConsent.
  ///
  /// In en, this message translates to:
  /// **'I accept the Privacy Policy'**
  String get privacyConsent;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile save failed'**
  String get profileSaveFailed;

  /// No description provided for @profileSaveFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Profile save failed'**
  String get profileSaveFailedMessage;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @promoCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get promoCodeTitle;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @quickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStart;

  /// No description provided for @rangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get rangeLabel;

  /// No description provided for @readCarefullySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please read carefully before using the AI Companion'**
  String get readCarefullySubtitle;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reasonLabel;

  /// No description provided for @recommendedBadge.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get recommendedBadge;

  /// No description provided for @recordAllergyEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Allergy Event'**
  String get recordAllergyEventTitle;

  /// No description provided for @recordDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get recordDeletedMessage;

  /// No description provided for @recordedLabel.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recordedLabel;

  /// No description provided for @refreshingLabel.
  ///
  /// In en, this message translates to:
  /// **'Refreshing'**
  String get refreshingLabel;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerButton;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your BabyMon\'s milestones today'**
  String get registerSubtitle;

  /// No description provided for @remindMeLater.
  ///
  /// In en, this message translates to:
  /// **'Remind me later'**
  String get remindMeLater;

  /// No description provided for @removePhotoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this photo?'**
  String get removePhotoConfirm;

  /// No description provided for @renewalDate.
  ///
  /// In en, this message translates to:
  /// **'Renewal Date'**
  String get renewalDate;

  /// No description provided for @requestFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Request failed. Please try again.'**
  String get requestFailedRetry;

  /// No description provided for @requiresSubscription.
  ///
  /// In en, this message translates to:
  /// **'Better Quality requires a Premium subscription.'**
  String get requiresSubscription;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendEmail;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// No description provided for @resendVerificationEmailSemantic.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmailSemantic;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSemantic.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetPasswordSemantic;

  /// No description provided for @resetPasswordSemanticShort.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetPasswordSemanticShort;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a password reset link.'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get resetPasswordSuccess;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetZoom.
  ///
  /// In en, this message translates to:
  /// **'Reset zoom'**
  String get resetZoom;

  /// No description provided for @restorePurchaseHint.
  ///
  /// In en, this message translates to:
  /// **'To restore a purchase, go to your app store account settings and tap Restore.'**
  String get restorePurchaseHint;

  /// No description provided for @restorePurchaseMessage.
  ///
  /// In en, this message translates to:
  /// **'To restore a purchase, go to your app store account settings and tap Restore.'**
  String get restorePurchaseMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @retryDownload.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryDownload;

  /// No description provided for @reviewPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Review pending approvals'**
  String get reviewPendingApprovals;

  /// No description provided for @rolePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Pediatrician'**
  String get rolePhoneHint;

  /// No description provided for @rolePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Role / Phone'**
  String get rolePhoneLabel;

  /// No description provided for @routine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routine;

  /// No description provided for @routineComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Routine Coming Soon'**
  String get routineComingSoon;

  /// No description provided for @routineComingSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'We\'re creating a personalized routine for this stage. Check back soon!'**
  String get routineComingSoonDesc;

  /// No description provided for @routineTab.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routineTab;

  /// No description provided for @runsOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Runs entirely on your device'**
  String get runsOnDevice;

  /// No description provided for @safetyWarningAntiVax.
  ///
  /// In en, this message translates to:
  /// **'Content about vaccine safety may not be accurate. Vaccines are safe and effective. Consult your pediatrician.'**
  String get safetyWarningAntiVax;

  /// No description provided for @safetyWarningEmergency.
  ///
  /// In en, this message translates to:
  /// **'If this is a medical emergency, stop using this app and call 911 or your local emergency number immediately.'**
  String get safetyWarningEmergency;

  /// No description provided for @safetyWarningHallucination.
  ///
  /// In en, this message translates to:
  /// **'This response may reference features that don\'t exist in the app.'**
  String get safetyWarningHallucination;

  /// No description provided for @safetyWarningMedication.
  ///
  /// In en, this message translates to:
  /// **'The AI cannot provide medication dosage advice. Always consult your pediatrician before giving any medication.'**
  String get safetyWarningMedication;

  /// No description provided for @safetyWarningPrefix.
  ///
  /// In en, this message translates to:
  /// **'\n\n⚠️ '**
  String get safetyWarningPrefix;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAllergy.
  ///
  /// In en, this message translates to:
  /// **'Save allergy'**
  String get saveAllergy;

  /// No description provided for @saveAllergySemantic.
  ///
  /// In en, this message translates to:
  /// **'Save allergy'**
  String get saveAllergySemantic;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @saveFeedingLogSemantic.
  ///
  /// In en, this message translates to:
  /// **'Save feeding log'**
  String get saveFeedingLogSemantic;

  /// No description provided for @saveGrowthRecordSemantic.
  ///
  /// In en, this message translates to:
  /// **'Save growth record'**
  String get saveGrowthRecordSemantic;

  /// No description provided for @saveHealthEvent.
  ///
  /// In en, this message translates to:
  /// **'Save health event'**
  String get saveHealthEvent;

  /// No description provided for @saveHealthEventSemantic.
  ///
  /// In en, this message translates to:
  /// **'Save health event'**
  String get saveHealthEventSemantic;

  /// No description provided for @saveHealthMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Save health measurement'**
  String get saveHealthMeasurement;

  /// No description provided for @saveHealthMeasurementSemantic.
  ///
  /// In en, this message translates to:
  /// **'Save health measurement'**
  String get saveHealthMeasurementSemantic;

  /// No description provided for @saveHealthRecord.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveHealthRecord;

  /// No description provided for @saveMilestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Milestone'**
  String get saveMilestoneTitle;

  /// No description provided for @saveProfileChanges.
  ///
  /// In en, this message translates to:
  /// **'Save profile changes'**
  String get saveProfileChanges;

  /// No description provided for @saveProfileChangesSemantic.
  ///
  /// In en, this message translates to:
  /// **'Save profile changes'**
  String get saveProfileChangesSemantic;

  /// No description provided for @saveRecord.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveRecord;

  /// No description provided for @saveSleepChangesSemantic.
  ///
  /// In en, this message translates to:
  /// **'Save sleep changes'**
  String get saveSleepChangesSemantic;

  /// No description provided for @saveSleepLogSemantic.
  ///
  /// In en, this message translates to:
  /// **'Save sleep log'**
  String get saveSleepLogSemantic;

  /// No description provided for @savedCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Cards'**
  String get savedCardsTitle;

  /// No description provided for @savedCardsUpgradeDesc.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium to bookmark and save expert advice cards for quick access.'**
  String get savedCardsUpgradeDesc;

  /// No description provided for @savedTab.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTab;

  /// No description provided for @scrollToToday.
  ///
  /// In en, this message translates to:
  /// **'Scroll to today'**
  String get scrollToToday;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchAllergies.
  ///
  /// In en, this message translates to:
  /// **'Search allergies...'**
  String get searchAllergies;

  /// No description provided for @searchAllergiesHint.
  ///
  /// In en, this message translates to:
  /// **'Search allergies...'**
  String get searchAllergiesHint;

  /// No description provided for @searchVaccines.
  ///
  /// In en, this message translates to:
  /// **'Search vaccines...'**
  String get searchVaccines;

  /// No description provided for @searchVaccinesHint.
  ///
  /// In en, this message translates to:
  /// **'Search vaccines...'**
  String get searchVaccinesHint;

  /// No description provided for @selectBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Select BabyMon'**
  String get selectBabyMon;

  /// No description provided for @selectBloodType.
  ///
  /// In en, this message translates to:
  /// **'Select Blood Type'**
  String get selectBloodType;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Color: {color}'**
  String selectColor(Object color);

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectDateButton.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectDateButton;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @selectEyeColor.
  ///
  /// In en, this message translates to:
  /// **'Select Eye Color'**
  String get selectEyeColor;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @selectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select {type}'**
  String selectLabel(Object type);

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Range'**
  String get selectRangeTitle;

  /// No description provided for @selectSeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity: {severity}'**
  String selectSeverity(Object severity);

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @selectTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTimeTitle;

  /// No description provided for @selectedDateTapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Selected: {date} — tap for details'**
  String selectedDateTapForDetails(Object date);

  /// No description provided for @selectedItem.
  ///
  /// In en, this message translates to:
  /// **'{item}: {value}'**
  String selectedItem(Object item, Object value);

  /// No description provided for @selectedSemantic.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selectedSemantic;

  /// No description provided for @selectedTapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Selected: {date} — tap for details'**
  String selectedTapForDetails(Object date);

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send Invitation'**
  String get sendInvite;

  /// No description provided for @sendInviteAction.
  ///
  /// In en, this message translates to:
  /// **'Send Invite'**
  String get sendInviteAction;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @sendPasswordResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send password reset link'**
  String get sendPasswordResetLink;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @serverErrorPleaseRetry.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again.'**
  String get serverErrorPleaseRetry;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// No description provided for @severityLabel.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severityLabel;

  /// No description provided for @severityOf.
  ///
  /// In en, this message translates to:
  /// **'Severity: {value}'**
  String severityOf(Object value);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Share BabyMon'**
  String get shareBabyMon;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Shared via BabyMon'**
  String get shareText;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @showDetails.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get showDetails;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @signOutDevice.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device'**
  String get signOutDevice;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpLink;

  /// No description provided for @signUpSemantic.
  ///
  /// In en, this message translates to:
  /// **'Sign up for a new account'**
  String get signUpSemantic;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @skipUseBasic.
  ///
  /// In en, this message translates to:
  /// **'Skip for now — use basic mode'**
  String get skipUseBasic;

  /// No description provided for @skipUseBasicLabel.
  ///
  /// In en, this message translates to:
  /// **'Skip for now — use basic mode'**
  String get skipUseBasicLabel;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @sleepCategory.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepCategory;

  /// No description provided for @sleepDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep — {date}'**
  String sleepDialogTitle(Object date);

  /// No description provided for @sleepEnd.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get sleepEnd;

  /// No description provided for @sleepLogDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this sleep record?'**
  String get sleepLogDeleteMessage;

  /// No description provided for @sleepLogDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Sleep Log'**
  String get sleepLogDeleteTitle;

  /// No description provided for @sleepLogDeleted.
  ///
  /// In en, this message translates to:
  /// **'Sleep log deleted'**
  String get sleepLogDeleted;

  /// No description provided for @sleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get sleepQuality;

  /// No description provided for @sleepSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep — {date}'**
  String sleepSessionTitle(Object date);

  /// No description provided for @sleepSessionTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {hours}h {minutes}m | {count} sessions'**
  String sleepSessionTotal(int hours, int minutes, int count);

  /// No description provided for @sleepSessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get sleepSessions;

  /// No description provided for @sleepShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepShortLabel;

  /// No description provided for @sleepShortcutLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepShortcutLabel;

  /// No description provided for @sleepStart.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get sleepStart;

  /// No description provided for @sleepSummary.
  ///
  /// In en, this message translates to:
  /// **'Sleep Summary'**
  String get sleepSummary;

  /// Title for the 24-hour sleep timeline chart
  ///
  /// In en, this message translates to:
  /// **'24h Sleep Timeline'**
  String get sleepTimelineTitle;

  /// No description provided for @sleepTypeQuality.
  ///
  /// In en, this message translates to:
  /// **'{type} {start} to {end}, {duration}, quality: {quality}'**
  String sleepTypeQuality(Object type, Object start, Object end, Object duration, Object quality);

  /// No description provided for @smolm2_360m.
  ///
  /// In en, this message translates to:
  /// **'SmolLM2 360M'**
  String get smolm2_360m;

  /// No description provided for @smolm3_3b.
  ///
  /// In en, this message translates to:
  /// **'SmolLM3 3B'**
  String get smolm3_3b;

  /// No description provided for @socialEmotional.
  ///
  /// In en, this message translates to:
  /// **'Social & Emotional'**
  String get socialEmotional;

  /// No description provided for @socialLabel.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get socialLabel;

  /// No description provided for @socialLoginApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get socialLoginApple;

  /// No description provided for @socialLoginFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get socialLoginFacebook;

  /// No description provided for @socialLoginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get socialLoginGoogle;

  /// No description provided for @solidFood.
  ///
  /// In en, this message translates to:
  /// **'Solid Food'**
  String get solidFood;

  /// No description provided for @solidShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get solidShortLabel;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @specialGiftLabel.
  ///
  /// In en, this message translates to:
  /// **'Special gift'**
  String get specialGiftLabel;

  /// No description provided for @specialMove.
  ///
  /// In en, this message translates to:
  /// **'Special Move'**
  String get specialMove;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @spiritSpecialGiftHint.
  ///
  /// In en, this message translates to:
  /// **'Every BabyMon has a special gift. What\'s yours?'**
  String get spiritSpecialGiftHint;

  /// No description provided for @spiritTraitHint.
  ///
  /// In en, this message translates to:
  /// **'What words feel like them?'**
  String get spiritTraitHint;

  /// No description provided for @splashHeadline.
  ///
  /// In en, this message translates to:
  /// **'Every great journey\nbegins with a single heartbeat.'**
  String get splashHeadline;

  /// No description provided for @splashSubheadline.
  ///
  /// In en, this message translates to:
  /// **'Yours started the moment\nyou decided to welcome a new life.'**
  String get splashSubheadline;

  /// No description provided for @stageInsights.
  ///
  /// In en, this message translates to:
  /// **'Stage Insights'**
  String get stageInsights;

  /// No description provided for @stageLabel.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get stageLabel;

  /// No description provided for @stageType.
  ///
  /// In en, this message translates to:
  /// **'Stage Type'**
  String get stageType;

  /// No description provided for @startAlbum.
  ///
  /// In en, this message translates to:
  /// **'Start your baby album'**
  String get startAlbum;

  /// No description provided for @startDownload.
  ///
  /// In en, this message translates to:
  /// **'Start Download'**
  String get startDownload;

  /// No description provided for @stillSleeping.
  ///
  /// In en, this message translates to:
  /// **'Still sleeping'**
  String get stillSleeping;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @subscriptionActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subscriptionActive;

  /// No description provided for @subscriptionAndPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscription & Plan'**
  String get subscriptionAndPlan;

  /// No description provided for @subscriptionCancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling'**
  String get subscriptionCancelling;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @switchBabyMonHint.
  ///
  /// In en, this message translates to:
  /// **'Use the avatar in the top bar to switch'**
  String get switchBabyMonHint;

  /// No description provided for @switchToModel.
  ///
  /// In en, this message translates to:
  /// **'Switched to'**
  String get switchToModel;

  /// No description provided for @switchToModelMessage.
  ///
  /// In en, this message translates to:
  /// **'Switched to {model}'**
  String switchToModelMessage(Object model);

  /// No description provided for @switchedToBasic.
  ///
  /// In en, this message translates to:
  /// **'Switched to Basic mode'**
  String get switchedToBasic;

  /// No description provided for @switchedToBasicMessage.
  ///
  /// In en, this message translates to:
  /// **'Switched to Basic mode'**
  String get switchedToBasicMessage;

  /// No description provided for @switchedToModel.
  ///
  /// In en, this message translates to:
  /// **'Switched to {model}'**
  String switchedToModel(Object model);

  /// No description provided for @syncFailedTap.
  ///
  /// In en, this message translates to:
  /// **'Sync failed — tap to retry'**
  String get syncFailedTap;

  /// No description provided for @syncFailedTapRetry.
  ///
  /// In en, this message translates to:
  /// **'Sync failed — tap to retry'**
  String get syncFailedTapRetry;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Sync pending'**
  String get syncPending;

  /// No description provided for @syncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get syncStatus;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncingLabel.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncingLabel;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @takePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhotoAction;

  /// No description provided for @tapAnywhereToContinue.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to continue'**
  String get tapAnywhereToContinue;

  /// No description provided for @tapLabel.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get tapLabel;

  /// No description provided for @tapToAddFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first {item}'**
  String tapToAddFirstItem(Object item);

  /// No description provided for @tapToAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add photos'**
  String get tapToAddPhotos;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// No description provided for @tapToSelectItem.
  ///
  /// In en, this message translates to:
  /// **'{item}: Tap to select'**
  String tapToSelectItem(Object item);

  /// No description provided for @tapToSelectLabel.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelectLabel;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @tenMinWifiLabel.
  ///
  /// In en, this message translates to:
  /// **'~10 min on Wi‑Fi'**
  String get tenMinWifiLabel;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceLink;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// No description provided for @themeModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Light, dark, or follow system'**
  String get themeModeDesc;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisWeeksFocus.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK\'S FOCUS'**
  String get thisWeeksFocus;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @timeOfDayAfternoon.
  ///
  /// In en, this message translates to:
  /// **'afternoon'**
  String get timeOfDayAfternoon;

  /// No description provided for @timeOfDayEvening.
  ///
  /// In en, this message translates to:
  /// **'evening'**
  String get timeOfDayEvening;

  /// No description provided for @timeOfDayMorning.
  ///
  /// In en, this message translates to:
  /// **'morning'**
  String get timeOfDayMorning;

  /// No description provided for @timeOfDayNight.
  ///
  /// In en, this message translates to:
  /// **'night'**
  String get timeOfDayNight;

  /// No description provided for @tipOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'TIP OF THE DAY'**
  String get tipOfTheDay;

  /// No description provided for @titleOptional.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get titleOptional;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @todayDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Today - {date}'**
  String todayDateLabel(Object date);

  /// No description provided for @todayTab.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTab;

  /// No description provided for @todaysRoutine.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S ROUTINE'**
  String get todaysRoutine;

  /// No description provided for @todaysSchedule.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S SCHEDULE'**
  String get todaysSchedule;

  /// No description provided for @toddlerStage.
  ///
  /// In en, this message translates to:
  /// **'Toddler'**
  String get toddlerStage;

  /// No description provided for @togglePasswordVisibility.
  ///
  /// In en, this message translates to:
  /// **'Toggle password visibility'**
  String get togglePasswordVisibility;

  /// No description provided for @tosConsent.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Service'**
  String get tosConsent;

  /// No description provided for @totalFeeds.
  ///
  /// In en, this message translates to:
  /// **'Total Feeds'**
  String get totalFeeds;

  /// No description provided for @totalSleep.
  ///
  /// In en, this message translates to:
  /// **'Total Sleep'**
  String get totalSleep;

  /// No description provided for @trackMilestone.
  ///
  /// In en, this message translates to:
  /// **'Track Milestone'**
  String get trackMilestone;

  /// No description provided for @trackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track progress'**
  String get trackProgress;

  /// No description provided for @trackYourBabysProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your baby\'s progress'**
  String get trackYourBabysProgress;

  /// No description provided for @trackYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Track your parenting journey'**
  String get trackYourJourney;

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Log'**
  String get trackingTitle;

  /// No description provided for @traitAdventurous.
  ///
  /// In en, this message translates to:
  /// **'Adventurous'**
  String get traitAdventurous;

  /// No description provided for @traitCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get traitCreative;

  /// No description provided for @traitCurious.
  ///
  /// In en, this message translates to:
  /// **'Curious'**
  String get traitCurious;

  /// No description provided for @traitFlavorAdventurous.
  ///
  /// In en, this message translates to:
  /// **'Adventurous — ready to discover something new every day.'**
  String get traitFlavorAdventurous;

  /// No description provided for @traitFlavorCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative — seeing the world differently, beautifully.'**
  String get traitFlavorCreative;

  /// No description provided for @traitFlavorCurious.
  ///
  /// In en, this message translates to:
  /// **'Curious — always exploring the world with wide eyes.'**
  String get traitFlavorCurious;

  /// No description provided for @traitFlavorGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle — the softest touch, the kindest heart.'**
  String get traitFlavorGentle;

  /// No description provided for @traitFlavorPeaceful.
  ///
  /// In en, this message translates to:
  /// **'Peaceful — a calm presence that soothes everyone around them.'**
  String get traitFlavorPeaceful;

  /// No description provided for @traitFlavorPlayful.
  ///
  /// In en, this message translates to:
  /// **'Playful — finding joy in every tiny moment.'**
  String get traitFlavorPlayful;

  /// No description provided for @traitGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get traitGentle;

  /// No description provided for @traitHintText.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"Loves bath time\", \"Funny laugh\"'**
  String get traitHintText;

  /// No description provided for @traitPeaceful.
  ///
  /// In en, this message translates to:
  /// **'Peaceful'**
  String get traitPeaceful;

  /// No description provided for @traitPlayful.
  ///
  /// In en, this message translates to:
  /// **'Playful'**
  String get traitPlayful;

  /// No description provided for @traits.
  ///
  /// In en, this message translates to:
  /// **'Traits'**
  String get traits;

  /// No description provided for @traitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Traits'**
  String get traitsLabel;

  /// No description provided for @treatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get treatment;

  /// No description provided for @treatmentHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. EpiPen, Antihistamine, Avoidance'**
  String get treatmentHint;

  /// No description provided for @trendDown.
  ///
  /// In en, this message translates to:
  /// **'Trending down'**
  String get trendDown;

  /// No description provided for @trendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get trendStable;

  /// No description provided for @trendUp.
  ///
  /// In en, this message translates to:
  /// **'Trending up'**
  String get trendUp;

  /// No description provided for @trialActive.
  ///
  /// In en, this message translates to:
  /// **'Trial Active'**
  String get trialActive;

  /// No description provided for @trialDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left in trial'**
  String trialDaysLeft(int days);

  /// No description provided for @triggers.
  ///
  /// In en, this message translates to:
  /// **'Triggers'**
  String get triggers;

  /// No description provided for @triggersHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ingestion, Skin contact, Airborne'**
  String get triggersHint;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @twoMinWifiLabel.
  ///
  /// In en, this message translates to:
  /// **'~2 min on Wi‑Fi'**
  String get twoMinWifiLabel;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @unableToLoadCompanion.
  ///
  /// In en, this message translates to:
  /// **'Unable to load companion'**
  String get unableToLoadCompanion;

  /// No description provided for @unableToLoadMilestones.
  ///
  /// In en, this message translates to:
  /// **'Unable to load milestones'**
  String get unableToLoadMilestones;

  /// No description provided for @unableToLoadRoutine.
  ///
  /// In en, this message translates to:
  /// **'Unable to load routine'**
  String get unableToLoadRoutine;

  /// No description provided for @underDevelopment.
  ///
  /// In en, this message translates to:
  /// **'{feature} is under development.'**
  String underDevelopment(Object feature);

  /// No description provided for @understandAcceptCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I understand and accept these terms. I will use the AI Companion as a parenting guide only, not as medical advice.'**
  String get understandAcceptCheckbox;

  /// Imperial unit abbreviation for inches
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get unitInches;

  /// No description provided for @unknownLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownLabel;

  /// No description provided for @unlockAiCompanion.
  ///
  /// In en, this message translates to:
  /// **'Create your first BabyMon to unlock the AI Companion — personalised routines, milestones, and parenting guidance.'**
  String get unlockAiCompanion;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @upcomingVaccines.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Vaccines'**
  String get upcomingVaccines;

  /// No description provided for @updateAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'A newer AI model is available ({name} {version}).\n\nUpdating ensures you have the latest parenting guidance and improvements.\n\nDownload size: ~{size} MB'**
  String updateAvailableMessage(Object name, Object version, Object size);

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Model Update Available'**
  String get updateAvailableTitle;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated!'**
  String get updated;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @upgradeButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgradeButton;

  /// No description provided for @upgradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgradeLabel;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @upgradeToPremiumCTA.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremiumCTA;

  /// No description provided for @upgradeToPremiumUnlock.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremiumUnlock;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @useAsStartingPoint.
  ///
  /// In en, this message translates to:
  /// **'Use our parenting advice as a starting point — not as a replacement for professional care.'**
  String get useAsStartingPoint;

  /// No description provided for @useContentCards.
  ///
  /// In en, this message translates to:
  /// **'Use Content Cards'**
  String get useContentCards;

  /// No description provided for @usingOfflineConfig.
  ///
  /// In en, this message translates to:
  /// **'Using offline model configuration. Consider checking your connection for the latest model.'**
  String get usingOfflineConfig;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @vaccinationCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccinationCategoryLabel;

  /// No description provided for @vaccineName.
  ///
  /// In en, this message translates to:
  /// **'Vaccine name'**
  String get vaccineName;

  /// No description provided for @vaccineNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Name'**
  String get vaccineNameLabel;

  /// No description provided for @vaccineSelected.
  ///
  /// In en, this message translates to:
  /// **'Vaccine: {value}'**
  String vaccineSelected(Object value);

  /// No description provided for @vaccineTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Vaccine: Tap to select'**
  String get vaccineTapToSelect;

  /// No description provided for @venue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venue;

  /// No description provided for @venueLabel.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venueLabel;

  /// No description provided for @verificationCheckSemantic.
  ///
  /// In en, this message translates to:
  /// **'Check email verification'**
  String get verificationCheckSemantic;

  /// No description provided for @verificationCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code was sent to your email.'**
  String get verificationCodeSubtitle;

  /// No description provided for @verificationCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCodeTitle;

  /// No description provided for @verificationResendSemantic.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get verificationResendSemantic;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmail;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and click the verification link to continue.'**
  String get verifyEmailSubtitle;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @verifyingDownload.
  ///
  /// In en, this message translates to:
  /// **'Verifying download...'**
  String get verifyingDownload;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @viewFullRoutine.
  ///
  /// In en, this message translates to:
  /// **'view full routine'**
  String get viewFullRoutine;

  /// No description provided for @viewPhoto.
  ///
  /// In en, this message translates to:
  /// **'View photo'**
  String get viewPhoto;

  /// No description provided for @viewSleepDetails.
  ///
  /// In en, this message translates to:
  /// **'View sleep details for {date}'**
  String viewSleepDetails(Object date);

  /// No description provided for @viewSleepDetailsFor.
  ///
  /// In en, this message translates to:
  /// **'View sleep details for'**
  String get viewSleepDetailsFor;

  /// No description provided for @visualStyle.
  ///
  /// In en, this message translates to:
  /// **'Visual Style'**
  String get visualStyle;

  /// No description provided for @visualStyleClay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get visualStyleClay;

  /// No description provided for @visualStyleDesc.
  ///
  /// In en, this message translates to:
  /// **'Glass or Clay theme'**
  String get visualStyleDesc;

  /// No description provided for @visualStyleGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get visualStyleGlass;

  /// No description provided for @warmingIncubator.
  ///
  /// In en, this message translates to:
  /// **'Warming the incubator...'**
  String get warmingIncubator;

  /// No description provided for @warningMedicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Warning: Medical disclaimer'**
  String get warningMedicalDisclaimer;

  /// No description provided for @wasThisHelpful.
  ///
  /// In en, this message translates to:
  /// **'Was this helpful?'**
  String get wasThisHelpful;

  /// No description provided for @weavingTheNest.
  ///
  /// In en, this message translates to:
  /// **'Weaving the nest...'**
  String get weavingTheNest;

  /// No description provided for @weekAbbr.
  ///
  /// In en, this message translates to:
  /// **'wk'**
  String get weekAbbr;

  /// No description provided for @weekLabel.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get weekLabel;

  /// No description provided for @weekdayFr.
  ///
  /// In en, this message translates to:
  /// **'Fr'**
  String get weekdayFr;

  /// No description provided for @weekdayMo.
  ///
  /// In en, this message translates to:
  /// **'Mo'**
  String get weekdayMo;

  /// No description provided for @weekdaySa.
  ///
  /// In en, this message translates to:
  /// **'Sa'**
  String get weekdaySa;

  /// No description provided for @weekdaySu.
  ///
  /// In en, this message translates to:
  /// **'Su'**
  String get weekdaySu;

  /// No description provided for @weekdayTh.
  ///
  /// In en, this message translates to:
  /// **'Th'**
  String get weekdayTh;

  /// No description provided for @weekdayTu.
  ///
  /// In en, this message translates to:
  /// **'Tu'**
  String get weekdayTu;

  /// No description provided for @weekdayWe.
  ///
  /// In en, this message translates to:
  /// **'We'**
  String get weekdayWe;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// No description provided for @weeksOld.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks old'**
  String weeksOld(int weeks);

  /// No description provided for @weeksUnit.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeksUnit;

  /// No description provided for @weeksUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeksUnitLabel;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @weightCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightCategoryLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @weightLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabelShort;

  /// No description provided for @weightValueKg.
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight} kg'**
  String weightValueKg(Object weight, Object value);

  /// No description provided for @weightWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String weightWithUnit(Object unit, Object value);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @welcomeBackMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBackMessage;

  /// No description provided for @welcomeChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get welcomeChooseLanguage;

  /// No description provided for @welcomeToBabymon.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BabyMon!'**
  String get welcomeToBabymon;

  /// No description provided for @wetSubtype.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get wetSubtype;

  /// No description provided for @whatIsYourBabysName.
  ///
  /// In en, this message translates to:
  /// **'What\'s your baby\'s name?'**
  String get whatIsYourBabysName;

  /// No description provided for @whatShouldMyBabySleep.
  ///
  /// In en, this message translates to:
  /// **'What should my 4-month-old\'s sleep schedule look like?'**
  String get whatShouldMyBabySleep;

  /// No description provided for @whatsComing.
  ///
  /// In en, this message translates to:
  /// **'What\'s coming'**
  String get whatsComing;

  /// No description provided for @whenConcernedFever.
  ///
  /// In en, this message translates to:
  /// **'When should I be concerned about a fever?'**
  String get whenConcernedFever;

  /// No description provided for @writingLullaby.
  ///
  /// In en, this message translates to:
  /// **'Writing the first lullaby...'**
  String get writingLullaby;

  /// No description provided for @writingNextPage.
  ///
  /// In en, this message translates to:
  /// **'Writing the next page...'**
  String get writingNextPage;

  /// No description provided for @xpEarned.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpEarned(int xp);

  /// No description provided for @xpFormat.
  ///
  /// In en, this message translates to:
  /// **'{current} / {needed} XP'**
  String xpFormat(Object current, Object needed, Object xp);

  /// No description provided for @xpProgress.
  ///
  /// In en, this message translates to:
  /// **'XP Progress'**
  String get xpProgress;

  /// No description provided for @xpShort.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xpShort;

  /// No description provided for @yearAbbr.
  ///
  /// In en, this message translates to:
  /// **'yr'**
  String get yearAbbr;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @youAreDoingAmazing.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing an amazing job.\nWe just want to make sure you have the full picture.'**
  String get youAreDoingAmazing;

  /// No description provided for @youAreResponsibleDesc.
  ///
  /// In en, this message translates to:
  /// **'You must independently verify any AI Companion advice with a qualified healthcare professional before acting on it.'**
  String get youAreResponsibleDesc;

  /// No description provided for @youAreResponsibleTitle.
  ///
  /// In en, this message translates to:
  /// **'You Are Responsible'**
  String get youAreResponsibleTitle;

  /// No description provided for @yourBaby.
  ///
  /// In en, this message translates to:
  /// **'Your baby'**
  String get yourBaby;

  /// No description provided for @yourBabyLower.
  ///
  /// In en, this message translates to:
  /// **'your baby'**
  String get yourBabyLower;

  /// No description provided for @yourOnDeviceAiCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your On-Device\nAI Companion'**
  String get yourOnDeviceAiCompanion;

  /// No description provided for @yourParentingCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your Parenting Companion'**
  String get yourParentingCompanion;

  /// No description provided for @zodiacLabel.
  ///
  /// In en, this message translates to:
  /// **'Zodiac'**
  String get zodiacLabel;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// Label for Italian language option
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @durationMinutesFormat.
  ///
  /// In en, this message translates to:
  /// **'Duration: {minutes} minutes'**
  String durationMinutesFormat(int minutes);

  /// No description provided for @weightKgFormat.
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight} kg'**
  String weightKgFormat(String weight);

  /// No description provided for @heightCmFormat.
  ///
  /// In en, this message translates to:
  /// **'Height: {height} cm'**
  String heightCmFormat(String height);

  /// No description provided for @breastLabel.
  ///
  /// In en, this message translates to:
  /// **'Breast'**
  String get breastLabel;

  /// No description provided for @bottleLabel.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get bottleLabel;

  /// No description provided for @solidLabel.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get solidLabel;

  /// No description provided for @pumpedLabel.
  ///
  /// In en, this message translates to:
  /// **'Pumped'**
  String get pumpedLabel;

  /// No description provided for @wetLabel.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get wetLabel;

  /// No description provided for @dirtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get dirtyLabel;

  /// No description provided for @bothLabel.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get bothLabel;

  /// No description provided for @feedingFilter.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feedingFilter;

  /// No description provided for @sleepFilter.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepFilter;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get titleRequired;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @requiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredValidation;

  /// No description provided for @discoverDescription.
  ///
  /// In en, this message translates to:
  /// **'New features, tips, and community content coming your way.'**
  String get discoverDescription;

  /// No description provided for @stayTunedTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay tuned!'**
  String get stayTunedTitle;

  /// No description provided for @stayTunedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re working on something special'**
  String get stayTunedSubtitle;

  /// No description provided for @notifyAction.
  ///
  /// In en, this message translates to:
  /// **'Notify'**
  String get notifyAction;

  /// No description provided for @whatsComingTooltip.
  ///
  /// In en, this message translates to:
  /// **'What\'s coming'**
  String get whatsComingTooltip;

  /// No description provided for @chooseFreePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Free'**
  String get chooseFreePlan;

  /// No description provided for @compareFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare features'**
  String get compareFeaturesTitle;

  /// No description provided for @chooseYourPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get chooseYourPlanTitle;

  /// No description provided for @planSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start free. Upgrade anytime. Cancel in two taps.'**
  String get planSubtitle;

  /// No description provided for @freePlanLabel.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get freePlanLabel;

  /// No description provided for @securedByStripe.
  ///
  /// In en, this message translates to:
  /// **'Secured by Stripe'**
  String get securedByStripe;

  /// No description provided for @moneyBackGuarantee.
  ///
  /// In en, this message translates to:
  /// **'30-day money-back guarantee · Cancel anytime through your app store settings. Auto-renews at \$4.99/month unless cancelled 24 hours before renewal.'**
  String get moneyBackGuarantee;

  /// No description provided for @restorePurchasesLink.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchasesLink;

  /// No description provided for @termsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get termsLink;

  /// No description provided for @privacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyLink;

  /// No description provided for @childrenLink.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get childrenLink;

  /// No description provided for @freePlanBanner.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get freePlanBanner;

  /// No description provided for @premiumPlanBanner.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPlanBanner;

  /// No description provided for @renewsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Renews monthly'**
  String get renewsMonthly;

  /// No description provided for @freeForever.
  ///
  /// In en, this message translates to:
  /// **'Free forever'**
  String get freeForever;

  /// No description provided for @reviewButton.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewButton;

  /// No description provided for @noPartnersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to invite a co-parent'**
  String get noPartnersSubtitle;

  /// No description provided for @partnerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'partner@email.com'**
  String get partnerEmailHint;

  /// No description provided for @specialMoveHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"Loves bath time\", \"Funny laugh\"'**
  String get specialMoveHint;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @severityFormat.
  ///
  /// In en, this message translates to:
  /// **'Severity: {severity}'**
  String severityFormat(String severity);

  /// No description provided for @colorFormat.
  ///
  /// In en, this message translates to:
  /// **'Color: {color}'**
  String colorFormat(String color);

  /// No description provided for @vaccineFormat.
  ///
  /// In en, this message translates to:
  /// **'Vaccine: {vaccine}'**
  String vaccineFormat(String vaccine, Object dose);

  /// No description provided for @consistencyFormat.
  ///
  /// In en, this message translates to:
  /// **'Consistency: {consistency}'**
  String consistencyFormat(String consistency);

  /// No description provided for @venueFormat.
  ///
  /// In en, this message translates to:
  /// **'Venue: {venue}'**
  String venueFormat(String venue);

  /// No description provided for @pendingApprovalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review changes from your partner before they appear in the journal.'**
  String get pendingApprovalsSubtitle;

  /// No description provided for @changeProposed.
  ///
  /// In en, this message translates to:
  /// **'Change proposed'**
  String get changeProposed;

  /// No description provided for @fromProposerFormat.
  ///
  /// In en, this message translates to:
  /// **'From: {proposer}'**
  String fromProposerFormat(String proposer);

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get comingSoonTag;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plansTitle;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get chooseYourPlan;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Enter a name...'**
  String get nameHint;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'What\'s your baby\'s name?'**
  String get whatsYourBabyName;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPlanLabel;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Compare features'**
  String get compareFeatures;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Notify'**
  String get notifyWhenReady;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'{days}d left'**
  String daysLeft(Object days);

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Renews monthly'**
  String get renewMonthly;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremiumLabel;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Choose Free'**
  String get chooseFreeLabel;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Send Invite'**
  String get sendInviteLabel;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Conceived'**
  String get conceivedLabel;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Born'**
  String get bornLabel;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'e.g. \"Loves bath time\", \"Funny laugh\"'**
  String get specialGiftHint;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'e.g., Brave, Silly, Kind'**
  String get traitHint;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'forever'**
  String get periodForever;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get periodMonth;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get planFreeTierName;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get planPremiumTierName;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Basic tracking (milestones, feeding, health)'**
  String get freePlanFeature1;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Export your data anytime'**
  String get freePlanFeature2;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'1 BabyMon profile'**
  String get freePlanFeature3;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'7-day history'**
  String get freePlanFeature4;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get freePlanFeature5;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Offline entry creation'**
  String get freePlanFeature6;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'AI stage content'**
  String get premiumFeature1;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Unlimited history'**
  String get premiumFeature2;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Multi-BabyMon'**
  String get premiumFeature3;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get premiumFeature4;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Badge animations'**
  String get premiumFeature5;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Evolution narratives'**
  String get premiumFeature6;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Photo album'**
  String get premiumFeature7;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get monthAbbreviation;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'forever'**
  String get foreverLabel;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidCode;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'To restore a purchase, go to your app store account settings and tap Restore.'**
  String get appStoreSettings;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Contact us at support@babymon.app'**
  String get supportEmail;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Tap + to invite a co-parent'**
  String get tapToInvite;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownPartner;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parentRole;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Amount ({unit})'**
  String amountWithUnit(Object unit);

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get feedingAmountLabel;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Save feeding log'**
  String get saveFeedingSemantic;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Log Feed'**
  String get logFeedTitle;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get pendingApprovals;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromPartner;

  /// Auto-generated localization key
  ///
  /// In en, this message translates to:
  /// **'Your partner'**
  String get yourPartner;

  /// No description provided for @joinToday.
  ///
  /// In en, this message translates to:
  /// **'Join BabyMon today'**
  String get joinToday;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @signUpWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Apple'**
  String get signUpWithApple;

  /// No description provided for @signUpWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Facebook'**
  String get signUpWithFacebook;

  /// No description provided for @tapToSetAmount.
  ///
  /// In en, this message translates to:
  /// **'Tap to set amount'**
  String get tapToSetAmount;

  /// No description provided for @vaccinePrefix.
  ///
  /// In en, this message translates to:
  /// **'Vaccine:'**
  String get vaccinePrefix;

  /// No description provided for @allergyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Allergy:'**
  String get allergyPrefix;

  /// No description provided for @consistencyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Consistency:'**
  String get consistencyPrefix;

  /// No description provided for @monieseLabel.
  ///
  /// In en, this message translates to:
  /// **'Moniese'**
  String get monieseLabel;

  /// No description provided for @moniousLabel.
  ///
  /// In en, this message translates to:
  /// **'Monious'**
  String get moniousLabel;

  /// No description provided for @removePartnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Partner'**
  String get removePartnerTitle;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @removeLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeLabel;

  /// No description provided for @saveActivity.
  ///
  /// In en, this message translates to:
  /// **'Save Activity'**
  String get saveActivity;

  /// No description provided for @severityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get severityMild;

  /// No description provided for @severityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get severityModerate;

  /// No description provided for @severitySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severitySevere;

  /// No description provided for @severityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get severityCritical;

  /// No description provided for @colorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colorBrown;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @colorWhiteClay.
  ///
  /// In en, this message translates to:
  /// **'White / Clay'**
  String get colorWhiteClay;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @stoolWateryDiarrhea.
  ///
  /// In en, this message translates to:
  /// **'Watery (Diarrhea)'**
  String get stoolWateryDiarrhea;

  /// No description provided for @stoolLoose.
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get stoolLoose;

  /// No description provided for @stoolMushy.
  ///
  /// In en, this message translates to:
  /// **'Mushy'**
  String get stoolMushy;

  /// No description provided for @stoolSoftFormed.
  ///
  /// In en, this message translates to:
  /// **'Soft & Formed'**
  String get stoolSoftFormed;

  /// No description provided for @stoolNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get stoolNormal;

  /// No description provided for @stoolFirm.
  ///
  /// In en, this message translates to:
  /// **'Firm'**
  String get stoolFirm;

  /// No description provided for @stoolHardPellets.
  ///
  /// In en, this message translates to:
  /// **'Hard Pellets'**
  String get stoolHardPellets;

  /// No description provided for @stoolConstipated.
  ///
  /// In en, this message translates to:
  /// **'Constipated'**
  String get stoolConstipated;

  /// No description provided for @allergySeverityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get allergySeverityMild;

  /// No description provided for @allergySeverityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get allergySeverityModerate;

  /// No description provided for @allergySeveritySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get allergySeveritySevere;

  /// No description provided for @allergySeverityLifeThreatening.
  ///
  /// In en, this message translates to:
  /// **'Life-Threatening'**
  String get allergySeverityLifeThreatening;

  /// No description provided for @explanationPeanuts.
  ///
  /// In en, this message translates to:
  /// **'Legume allergy, often severe, can cause anaphylaxis'**
  String get explanationPeanuts;

  /// No description provided for @explanationTreeNuts.
  ///
  /// In en, this message translates to:
  /// **'Almonds, walnuts, cashews — often lifelong'**
  String get explanationTreeNuts;

  /// No description provided for @explanationMilkDairy.
  ///
  /// In en, this message translates to:
  /// **'Cow milk protein allergy, common in infants'**
  String get explanationMilkDairy;

  /// No description provided for @explanationEggs.
  ///
  /// In en, this message translates to:
  /// **'Often outgrown by school age'**
  String get explanationEggs;

  /// No description provided for @explanationSoy.
  ///
  /// In en, this message translates to:
  /// **'Soybean allergy, common in formula-fed babies'**
  String get explanationSoy;

  /// No description provided for @explanationWheat.
  ///
  /// In en, this message translates to:
  /// **'Protein allergy, distinct from celiac disease'**
  String get explanationWheat;

  /// No description provided for @explanationFish.
  ///
  /// In en, this message translates to:
  /// **'Often lifelong, salmon and cod most common'**
  String get explanationFish;

  /// No description provided for @explanationShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shrimp, crab, lobster — usually permanent'**
  String get explanationShellfish;

  /// No description provided for @explanationSesame.
  ///
  /// In en, this message translates to:
  /// **'Seed allergy, found in tahini, hummus, oils'**
  String get explanationSesame;

  /// No description provided for @explanationPollen.
  ///
  /// In en, this message translates to:
  /// **'Seasonal allergic rhinitis, sneezing, itchy eyes'**
  String get explanationPollen;

  /// No description provided for @explanationDustMites.
  ///
  /// In en, this message translates to:
  /// **'Year-round indoor allergen in bedding and carpets'**
  String get explanationDustMites;

  /// No description provided for @explanationMold.
  ///
  /// In en, this message translates to:
  /// **'Damp areas, outdoor or indoor — triggers asthma'**
  String get explanationMold;

  /// No description provided for @explanationPetDander.
  ///
  /// In en, this message translates to:
  /// **'Cats and dogs, skin flakes cause reactions'**
  String get explanationPetDander;

  /// No description provided for @explanationInsectStings.
  ///
  /// In en, this message translates to:
  /// **'Bees, wasps, hornets — can cause severe reactions'**
  String get explanationInsectStings;

  /// No description provided for @explanationLatex.
  ///
  /// In en, this message translates to:
  /// **'Rubber allergy, common in medical settings'**
  String get explanationLatex;

  /// No description provided for @explanationPenicillin.
  ///
  /// In en, this message translates to:
  /// **'Common antibiotic allergy, can cause hives or rash'**
  String get explanationPenicillin;

  /// No description provided for @explanationNSAIDs.
  ///
  /// In en, this message translates to:
  /// **'Ibuprofen, aspirin type anti-inflammatory drugs'**
  String get explanationNSAIDs;

  /// No description provided for @explanationSulfaDrugs.
  ///
  /// In en, this message translates to:
  /// **'Sulfonamide antibiotics, distinct from sulfites'**
  String get explanationSulfaDrugs;

  /// No description provided for @vaccineOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get vaccineOther;

  /// No description provided for @vaccineHepB.
  ///
  /// In en, this message translates to:
  /// **'Hepatitis B (HepB)'**
  String get vaccineHepB;

  /// No description provided for @vaccineRotavirus.
  ///
  /// In en, this message translates to:
  /// **'Rotavirus (RV)'**
  String get vaccineRotavirus;

  /// No description provided for @vaccineDTaP.
  ///
  /// In en, this message translates to:
  /// **'DTaP'**
  String get vaccineDTaP;

  /// No description provided for @vaccineHib.
  ///
  /// In en, this message translates to:
  /// **'Hib'**
  String get vaccineHib;

  /// No description provided for @vaccinePCV13.
  ///
  /// In en, this message translates to:
  /// **'Pneumococcal (PCV13)'**
  String get vaccinePCV13;

  /// No description provided for @vaccineIPV.
  ///
  /// In en, this message translates to:
  /// **'Polio (IPV)'**
  String get vaccineIPV;

  /// No description provided for @vaccineFlu.
  ///
  /// In en, this message translates to:
  /// **'Influenza (Flu)'**
  String get vaccineFlu;

  /// No description provided for @vaccineMMR.
  ///
  /// In en, this message translates to:
  /// **'MMR'**
  String get vaccineMMR;

  /// No description provided for @vaccineVaricella.
  ///
  /// In en, this message translates to:
  /// **'Varicella (Chickenpox)'**
  String get vaccineVaricella;

  /// No description provided for @vaccineHepA.
  ///
  /// In en, this message translates to:
  /// **'Hepatitis A (HepA)'**
  String get vaccineHepA;

  /// No description provided for @vaccineMenACWY.
  ///
  /// In en, this message translates to:
  /// **'Meningococcal (MenACWY)'**
  String get vaccineMenACWY;

  /// No description provided for @vaccineCOVID.
  ///
  /// In en, this message translates to:
  /// **'COVID-19'**
  String get vaccineCOVID;

  /// No description provided for @vaccineHPV.
  ///
  /// In en, this message translates to:
  /// **'HPV'**
  String get vaccineHPV;

  /// No description provided for @vaccineTdap.
  ///
  /// In en, this message translates to:
  /// **'Tdap'**
  String get vaccineTdap;

  /// No description provided for @vaccineRSV.
  ///
  /// In en, this message translates to:
  /// **'RSV'**
  String get vaccineRSV;

  /// No description provided for @allergyOtherOption.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get allergyOtherOption;

  /// No description provided for @allergyPeanutsOption.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get allergyPeanutsOption;

  /// No description provided for @allergyTreeNutsOption.
  ///
  /// In en, this message translates to:
  /// **'Tree Nuts'**
  String get allergyTreeNutsOption;

  /// No description provided for @allergyMilkDairyOption.
  ///
  /// In en, this message translates to:
  /// **'Milk (Dairy)'**
  String get allergyMilkDairyOption;

  /// No description provided for @allergyEggsOption.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get allergyEggsOption;

  /// No description provided for @allergySoyOption.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergySoyOption;

  /// No description provided for @allergyWheatOption.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get allergyWheatOption;

  /// No description provided for @allergyFishOption.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get allergyFishOption;

  /// No description provided for @allergyShellfishOption.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get allergyShellfishOption;

  /// No description provided for @allergySesameOption.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get allergySesameOption;

  /// No description provided for @allergyPollenOption.
  ///
  /// In en, this message translates to:
  /// **'Pollen (Hay Fever)'**
  String get allergyPollenOption;

  /// No description provided for @allergyDustMitesOption.
  ///
  /// In en, this message translates to:
  /// **'Dust Mites'**
  String get allergyDustMitesOption;

  /// No description provided for @allergyMoldOption.
  ///
  /// In en, this message translates to:
  /// **'Mold'**
  String get allergyMoldOption;

  /// No description provided for @allergyPetDanderOption.
  ///
  /// In en, this message translates to:
  /// **'Pet Dander'**
  String get allergyPetDanderOption;

  /// No description provided for @allergyInsectStingsOption.
  ///
  /// In en, this message translates to:
  /// **'Insect Stings'**
  String get allergyInsectStingsOption;

  /// No description provided for @allergyLatexOption.
  ///
  /// In en, this message translates to:
  /// **'Latex'**
  String get allergyLatexOption;

  /// No description provided for @allergyPenicillinOption.
  ///
  /// In en, this message translates to:
  /// **'Penicillin'**
  String get allergyPenicillinOption;

  /// No description provided for @allergyNSAIDsOption.
  ///
  /// In en, this message translates to:
  /// **'NSAIDs'**
  String get allergyNSAIDsOption;

  /// No description provided for @allergySulfaDrugsOption.
  ///
  /// In en, this message translates to:
  /// **'Sulfa Drugs'**
  String get allergySulfaDrugsOption;

  /// No description provided for @stoolTypeWatery.
  ///
  /// In en, this message translates to:
  /// **'Watery (Diarrhea)'**
  String get stoolTypeWatery;

  /// No description provided for @stoolTypeLoose.
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get stoolTypeLoose;

  /// No description provided for @stoolTypeMushy.
  ///
  /// In en, this message translates to:
  /// **'Mushy'**
  String get stoolTypeMushy;

  /// No description provided for @stoolTypeSoftFormed.
  ///
  /// In en, this message translates to:
  /// **'Soft & Formed'**
  String get stoolTypeSoftFormed;

  /// No description provided for @stoolTypeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get stoolTypeNormal;

  /// No description provided for @stoolTypeFirm.
  ///
  /// In en, this message translates to:
  /// **'Firm'**
  String get stoolTypeFirm;

  /// No description provided for @stoolTypeHardPellets.
  ///
  /// In en, this message translates to:
  /// **'Hard Pellets'**
  String get stoolTypeHardPellets;

  /// No description provided for @stoolTypeConstipated.
  ///
  /// In en, this message translates to:
  /// **'Constipated'**
  String get stoolTypeConstipated;

  /// No description provided for @allergyExplanationPeanuts.
  ///
  /// In en, this message translates to:
  /// **'Legume allergy, often severe, can cause anaphylaxis'**
  String get allergyExplanationPeanuts;

  /// No description provided for @allergyExplanationTreeNuts.
  ///
  /// In en, this message translates to:
  /// **'Almonds, walnuts, cashews — often lifelong'**
  String get allergyExplanationTreeNuts;

  /// No description provided for @allergyExplanationMilkDairy.
  ///
  /// In en, this message translates to:
  /// **'Cow milk protein allergy, common in infants'**
  String get allergyExplanationMilkDairy;

  /// No description provided for @allergyExplanationEggs.
  ///
  /// In en, this message translates to:
  /// **'Often outgrown by school age'**
  String get allergyExplanationEggs;

  /// No description provided for @allergyExplanationSoy.
  ///
  /// In en, this message translates to:
  /// **'Soybean allergy, common in formula-fed babies'**
  String get allergyExplanationSoy;

  /// No description provided for @allergyExplanationWheat.
  ///
  /// In en, this message translates to:
  /// **'Protein allergy, distinct from celiac disease'**
  String get allergyExplanationWheat;

  /// No description provided for @allergyExplanationFish.
  ///
  /// In en, this message translates to:
  /// **'Often lifelong, salmon and cod most common'**
  String get allergyExplanationFish;

  /// No description provided for @allergyExplanationShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shrimp, crab, lobster — usually permanent'**
  String get allergyExplanationShellfish;

  /// No description provided for @allergyExplanationSesame.
  ///
  /// In en, this message translates to:
  /// **'Seed allergy, found in tahini, hummus, oils'**
  String get allergyExplanationSesame;

  /// No description provided for @allergyExplanationPollen.
  ///
  /// In en, this message translates to:
  /// **'Seasonal allergic rhinitis, sneezing, itchy eyes'**
  String get allergyExplanationPollen;

  /// No description provided for @allergyExplanationDustMites.
  ///
  /// In en, this message translates to:
  /// **'Year-round indoor allergen in bedding and carpets'**
  String get allergyExplanationDustMites;

  /// No description provided for @allergyExplanationMold.
  ///
  /// In en, this message translates to:
  /// **'Damp areas, outdoor or indoor — triggers asthma'**
  String get allergyExplanationMold;

  /// No description provided for @allergyExplanationPetDander.
  ///
  /// In en, this message translates to:
  /// **'Cats and dogs, skin flakes cause reactions'**
  String get allergyExplanationPetDander;

  /// No description provided for @allergyExplanationInsectStings.
  ///
  /// In en, this message translates to:
  /// **'Bees, wasps, hornets — can cause severe reactions'**
  String get allergyExplanationInsectStings;

  /// No description provided for @allergyExplanationLatex.
  ///
  /// In en, this message translates to:
  /// **'Rubber allergy, common in medical settings'**
  String get allergyExplanationLatex;

  /// No description provided for @allergyExplanationPenicillin.
  ///
  /// In en, this message translates to:
  /// **'Common antibiotic allergy, can cause hives or rash'**
  String get allergyExplanationPenicillin;

  /// No description provided for @allergyExplanationNSAIDs.
  ///
  /// In en, this message translates to:
  /// **'Ibuprofen, aspirin type anti-inflammatory drugs'**
  String get allergyExplanationNSAIDs;

  /// No description provided for @allergyExplanationSulfaDrugs.
  ///
  /// In en, this message translates to:
  /// **'Sulfonamide antibiotics, distinct from sulfites'**
  String get allergyExplanationSulfaDrugs;

  /// No description provided for @severityPrefix.
  ///
  /// In en, this message translates to:
  /// **'Severity:'**
  String get severityPrefix;

  /// No description provided for @colorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Color:'**
  String get colorPrefix;

  /// No description provided for @venuePrefix.
  ///
  /// In en, this message translates to:
  /// **'Venue:'**
  String get venuePrefix;

  /// No description provided for @milestoneTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. First smile'**
  String get milestoneTitleHint;

  /// No description provided for @sendPasswordResetLinkSemantic.
  ///
  /// In en, this message translates to:
  /// **'Send password reset link'**
  String get sendPasswordResetLinkSemantic;

  /// No description provided for @sendPartnerInvitationSemantic.
  ///
  /// In en, this message translates to:
  /// **'Send partner invitation'**
  String get sendPartnerInvitationSemantic;

  /// XP value label with amount
  ///
  /// In en, this message translates to:
  /// **'+{value} XP'**
  String xpValueLabel(int value);

  /// No description provided for @errorAllergyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Allergy not found.'**
  String get errorAllergyNotFound;

  /// No description provided for @errorAllergyEventNotFound.
  ///
  /// In en, this message translates to:
  /// **'Allergy event not found.'**
  String get errorAllergyEventNotFound;

  /// No description provided for @errorAllergyAlreadyCured.
  ///
  /// In en, this message translates to:
  /// **'Allergy is already marked as cured.'**
  String get errorAllergyAlreadyCured;

  /// No description provided for @errorAllergyAlreadyActive.
  ///
  /// In en, this message translates to:
  /// **'Allergy is already active.'**
  String get errorAllergyAlreadyActive;

  /// No description provided for @errorGrowthRecordNotFound.
  ///
  /// In en, this message translates to:
  /// **'Growth record not found.'**
  String get errorGrowthRecordNotFound;

  /// No description provided for @errorGrowthRecordUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can manage growth records.'**
  String get errorGrowthRecordUnauthorized;

  /// No description provided for @errorSleepLogNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sleep log not found.'**
  String get errorSleepLogNotFound;

  /// No description provided for @errorSleepLogUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this sleep log.'**
  String get errorSleepLogUnauthorized;

  /// No description provided for @errorMediaNotFound.
  ///
  /// In en, this message translates to:
  /// **'Media not found.'**
  String get errorMediaNotFound;

  /// No description provided for @errorMediaUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can manage media.'**
  String get errorMediaUnauthorized;

  /// No description provided for @errorMediaInvalidType.
  ///
  /// In en, this message translates to:
  /// **'Invalid file type. Allowed: JPEG, PNG, GIF, WebP, MP4, MOV.'**
  String get errorMediaInvalidType;

  /// No description provided for @errorMediaTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File too large. Maximum size is 50MB.'**
  String get errorMediaTooLarge;

  /// No description provided for @errorCompanionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Companion content not found.'**
  String get errorCompanionNotFound;

  /// No description provided for @errorCompanionUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access companion content.'**
  String get errorCompanionUnauthorized;

  /// No description provided for @errorRoutineNotFound.
  ///
  /// In en, this message translates to:
  /// **'No routine found for today.'**
  String get errorRoutineNotFound;

  /// No description provided for @errorJournalProposalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Journal proposal not found.'**
  String get errorJournalProposalNotFound;

  /// No description provided for @errorJournalProposalUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this proposal.'**
  String get errorJournalProposalUnauthorized;

  /// No description provided for @errorJournalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Journal entry not found.'**
  String get errorJournalNotFound;

  /// No description provided for @errorJournalUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this journal.'**
  String get errorJournalUnauthorized;

  /// No description provided for @errorProposalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Proposal not found.'**
  String get errorProposalNotFound;

  /// No description provided for @errorExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed. Please try again.'**
  String get errorExportFailed;

  /// No description provided for @errorS3NotConfigured.
  ///
  /// In en, this message translates to:
  /// **'File storage is not configured.'**
  String get errorS3NotConfigured;

  /// No description provided for @errorS3UploadFailed.
  ///
  /// In en, this message translates to:
  /// **'File upload failed. Please try again.'**
  String get errorS3UploadFailed;

  /// No description provided for @errorStripeWebhookInvalid.
  ///
  /// In en, this message translates to:
  /// **'Payment configuration error. Please contact support.'**
  String get errorStripeWebhookInvalid;

  /// No description provided for @errorAdminUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Admin action not allowed.'**
  String get errorAdminUnauthorized;

  /// No description provided for @errorAdminUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get errorAdminUserNotFound;

  /// No description provided for @errorEvolutionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Evolution data not found.'**
  String get errorEvolutionNotFound;

  /// No description provided for @errorEvolutionUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view evolution data.'**
  String get errorEvolutionUnauthorized;

  /// No description provided for @errorStageContentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Stage content not found.'**
  String get errorStageContentNotFound;

  /// No description provided for @errorPartnerUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to manage partners.'**
  String get errorPartnerUnauthorized;

  /// No description provided for @errorStripeNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Payment provider is not configured. Please contact support.'**
  String get errorStripeNotConfigured;

  /// No description provided for @errorStripeSubscriptionNotFound.
  ///
  /// In en, this message translates to:
  /// **'No active subscription found.'**
  String get errorStripeSubscriptionNotFound;

  /// No description provided for @errorModelNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI model is not configured.'**
  String get errorModelNotConfigured;

  /// No description provided for @errorModelDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Model download failed. Please try again.'**
  String get errorModelDownloadFailed;

  /// No description provided for @errorInvalidFileType.
  ///
  /// In en, this message translates to:
  /// **'Invalid file type.'**
  String get errorInvalidFileType;

  /// No description provided for @errorFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File too large.'**
  String get errorFileTooLarge;

  /// No description provided for @errorProposalAlreadyResolved.
  ///
  /// In en, this message translates to:
  /// **'This proposal has already been resolved.'**
  String get errorProposalAlreadyResolved;

  /// No description provided for @errorExportNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available to export.'**
  String get errorExportNoData;

  /// No description provided for @valInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get valInvalidEmail;

  /// No description provided for @valRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get valRequired;

  /// No description provided for @valMinLength.
  ///
  /// In en, this message translates to:
  /// **'Too short.'**
  String get valMinLength;

  /// No description provided for @valMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Too long.'**
  String get valMaxLength;

  /// No description provided for @valInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format.'**
  String get valInvalidFormat;

  /// No description provided for @valInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid date.'**
  String get valInvalidDate;

  /// No description provided for @valInvalidType.
  ///
  /// In en, this message translates to:
  /// **'Invalid value.'**
  String get valInvalidType;

  /// No description provided for @valInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid value.'**
  String get valInvalidValue;

  /// No description provided for @valUnexpectedField.
  ///
  /// In en, this message translates to:
  /// **'Unexpected field.'**
  String get valUnexpectedField;

  /// No description provided for @valInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input.'**
  String get valInvalidInput;

  /// No description provided for @emptyStateNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No {itemName} yet'**
  String emptyStateNoDataTitle(Object itemName);

  /// No description provided for @emptyStateNoDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first {itemName}'**
  String emptyStateNoDataSubtitle(Object itemName);

  /// No description provided for @emptyStateComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get emptyStateComingSoonTitle;

  /// No description provided for @emptyStateComingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{featureName} is under development.'**
  String emptyStateComingSoonSubtitle(Object featureName);

  /// No description provided for @addItemAction.
  ///
  /// In en, this message translates to:
  /// **'Add {itemName}'**
  String addItemAction(Object itemName);

  /// No description provided for @wheelPickerSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get wheelPickerSelectTime;

  /// No description provided for @wheelPickerHour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get wheelPickerHour;

  /// No description provided for @wheelPickerMinute.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get wheelPickerMinute;

  /// No description provided for @wheelPickerSelectRange.
  ///
  /// In en, this message translates to:
  /// **'Select Range'**
  String get wheelPickerSelectRange;

  /// No description provided for @wheelPickerRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get wheelPickerRange;

  /// No description provided for @wheelPickerUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get wheelPickerUnit;

  /// No description provided for @wheelPickerSelectMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Select {type} ({unit})'**
  String wheelPickerSelectMeasurement(Object type, Object unit);

  /// No description provided for @photoViewerDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss photo'**
  String get photoViewerDismiss;

  /// No description provided for @photoViewerBackToAlbum.
  ///
  /// In en, this message translates to:
  /// **'Back to album'**
  String get photoViewerBackToAlbum;

  /// No description provided for @photoViewerSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to browse  •  Tap to go back'**
  String get photoViewerSwipeHint;

  /// No description provided for @photoGridViewPhoto.
  ///
  /// In en, this message translates to:
  /// **'View photo'**
  String get photoGridViewPhoto;

  /// No description provided for @photoGridPhotoFromAlbum.
  ///
  /// In en, this message translates to:
  /// **'Photo from baby album'**
  String get photoGridPhotoFromAlbum;

  /// No description provided for @planPremiumTrial.
  ///
  /// In en, this message translates to:
  /// **'Premium · {days} trial days left'**
  String planPremiumTrial(Object days);

  /// No description provided for @planPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get planPremium;

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get planFree;

  /// No description provided for @pendingApprovalSingle.
  ///
  /// In en, this message translates to:
  /// **'1 change from your partner'**
  String get pendingApprovalSingle;

  /// No description provided for @pendingApprovalPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} changes from your partner'**
  String pendingApprovalPlural(Object count);

  /// No description provided for @reviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewLabel;

  /// No description provided for @semanticTap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get semanticTap;

  /// No description provided for @navigateToRegister.
  ///
  /// In en, this message translates to:
  /// **'Navigate to register'**
  String get navigateToRegister;

  /// No description provided for @albumTitle.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get albumTitle;

  /// No description provided for @cameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraLabel;

  /// No description provided for @galleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryLabel;

  /// No description provided for @noMilestonesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to add your first milestone.'**
  String get noMilestonesSubtitle;

  /// No description provided for @editMilestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Milestone'**
  String get editMilestoneTitle;

  /// No description provided for @updateLabel.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateLabel;

  /// No description provided for @updateMilestoneSemantic.
  ///
  /// In en, this message translates to:
  /// **'Update milestone'**
  String get updateMilestoneSemantic;

  /// No description provided for @saveMilestoneSemantic.
  ///
  /// In en, this message translates to:
  /// **'Save milestone'**
  String get saveMilestoneSemantic;

  /// No description provided for @milestoneSingular.
  ///
  /// In en, this message translates to:
  /// **'milestone'**
  String get milestoneSingular;

  /// No description provided for @milestonePlural.
  ///
  /// In en, this message translates to:
  /// **'milestones'**
  String get milestonePlural;

  /// No description provided for @milestoneCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{{singular}} other{{plural}}}'**
  String milestoneCount(num count, Object singular, Object plural);

  /// No description provided for @noActivitiesMessage.
  ///
  /// In en, this message translates to:
  /// **'No activities yet. Start tracking!'**
  String get noActivitiesMessage;

  /// No description provided for @stageEgg.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get stageEgg;

  /// No description provided for @stageHatchling.
  ///
  /// In en, this message translates to:
  /// **'Hatchling'**
  String get stageHatchling;

  /// No description provided for @stageJuvenile.
  ///
  /// In en, this message translates to:
  /// **'Juvenile'**
  String get stageJuvenile;

  /// No description provided for @stageAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get stageAdult;

  /// No description provided for @stageUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown stage'**
  String get stageUnknown;

  /// No description provided for @stageEggDescription.
  ///
  /// In en, this message translates to:
  /// **'Your BabyMon is developing in the egg. Keep the environment stable!'**
  String get stageEggDescription;

  /// No description provided for @stageHatchlingDescription.
  ///
  /// In en, this message translates to:
  /// **'Your BabyMon has hatched! It needs lots of care and attention.'**
  String get stageHatchlingDescription;

  /// No description provided for @stageJuvenileDescription.
  ///
  /// In en, this message translates to:
  /// **'Growing fast! Your BabyMon is becoming more active.'**
  String get stageJuvenileDescription;

  /// No description provided for @stageAdultDescription.
  ///
  /// In en, this message translates to:
  /// **'Your BabyMon has reached maturity. Great job raising it!'**
  String get stageAdultDescription;

  /// No description provided for @journalDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This entry will be removed from your journal.'**
  String get journalDeleteMessage;

  /// No description provided for @entryTypeChangeProposed.
  ///
  /// In en, this message translates to:
  /// **'{entryType} change proposed'**
  String entryTypeChangeProposed(Object entryType);

  /// No description provided for @childrensPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Children\'s Privacy'**
  String get childrensPrivacyTitle;

  /// No description provided for @amountLabelG.
  ///
  /// In en, this message translates to:
  /// **'Amount (g)'**
  String get amountLabelG;

  /// No description provided for @amountLabelUnit.
  ///
  /// In en, this message translates to:
  /// **'Amount ({unit})'**
  String amountLabelUnit(Object unit);

  /// No description provided for @guardianRole.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get guardianRole;

  /// No description provided for @grandparentRole.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get grandparentRole;

  /// No description provided for @selectFeedingAmount.
  ///
  /// In en, this message translates to:
  /// **'Select feeding amount'**
  String get selectFeedingAmount;

  /// No description provided for @systemFilter.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemFilter;

  /// No description provided for @promoCodeAppliedTitle.
  ///
  /// In en, this message translates to:
  /// **'Code applied!'**
  String get promoCodeAppliedTitle;

  /// No description provided for @promoCodeAppliedBody.
  ///
  /// In en, this message translates to:
  /// **'{days} days of {type} granted.'**
  String promoCodeAppliedBody(Object days, Object type);

  /// No description provided for @loadingWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loadingWelcomeBack;

  /// No description provided for @loadingYourBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Loading your BabyMon…'**
  String get loadingYourBabyMon;

  /// No description provided for @loadingPreparingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Preparing your dashboard…'**
  String get loadingPreparingDashboard;

  /// No description provided for @loadingAlmostReady.
  ///
  /// In en, this message translates to:
  /// **'Almost ready…'**
  String get loadingAlmostReady;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'fr', 'he', 'it', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'he': return AppLocalizationsHe();
    case 'it': return AppLocalizationsIt();
    case 'pt': return AppLocalizationsPt();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
