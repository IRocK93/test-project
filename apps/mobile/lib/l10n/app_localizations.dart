import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BabyMon'**
  String get appTitle;

  /// Tagline shown on splash and login screens
  ///
  /// In en, this message translates to:
  /// **'Smart Evolving Parenting Companion'**
  String get appTagline;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmail;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get hasAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestones;

  /// No description provided for @feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @companion.
  ///
  /// In en, this message translates to:
  /// **'AI Companion'**
  String get companion;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @ageConsent.
  ///
  /// In en, this message translates to:
  /// **'I confirm I am at least 18 years old'**
  String get ageConsent;

  /// No description provided for @tosConsent.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Service'**
  String get tosConsent;

  /// No description provided for @privacyConsent.
  ///
  /// In en, this message translates to:
  /// **'I accept the Privacy Policy'**
  String get privacyConsent;

  /// No description provided for @dataConsent.
  ///
  /// In en, this message translates to:
  /// **'I consent to the processing of child health and development data'**
  String get dataConsent;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password Strength'**
  String get passwordStrength;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters with uppercase, lowercase, and numbers'**
  String get passwordRequirements;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in with biometrics'**
  String get biometricLogin;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The AI Companion is not a substitute for professional medical advice. Always consult your healthcare provider.'**
  String get medicalDisclaimer;

  /// No description provided for @emergencyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'If this is a medical emergency, stop using this app and call 911 or your local emergency number immediately.'**
  String get emergencyDisclaimer;

  /// No description provided for @dailyBrief.
  ///
  /// In en, this message translates to:
  /// **'Daily Brief'**
  String get dailyBrief;

  /// No description provided for @routine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routine;

  /// No description provided for @adviceFeed.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get adviceFeed;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @askCompanion.
  ///
  /// In en, this message translates to:
  /// **'Ask the Companion'**
  String get askCompanion;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @modelDownload.
  ///
  /// In en, this message translates to:
  /// **'Model Download'**
  String get modelDownload;

  /// No description provided for @downloadModel.
  ///
  /// In en, this message translates to:
  /// **'Download Model'**
  String get downloadModel;

  /// No description provided for @modelRequired.
  ///
  /// In en, this message translates to:
  /// **'The AI Companion needs to download a language model to provide personalized guidance on your device.'**
  String get modelRequired;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @errorDownloading.
  ///
  /// In en, this message translates to:
  /// **'Error downloading model'**
  String get errorDownloading;

  /// No description provided for @retryDownload.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryDownload;

  /// No description provided for @medicalDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get medicalDisclaimerTitle;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get iUnderstand;

  /// No description provided for @achieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved!'**
  String get achieved;

  /// No description provided for @milestoneAchieved.
  ///
  /// In en, this message translates to:
  /// **'Milestone achieved!'**
  String get milestoneAchieved;

  /// No description provided for @xpEarned.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpEarned(int xp);

  /// No description provided for @noMilestones.
  ///
  /// In en, this message translates to:
  /// **'No milestones recorded yet'**
  String get noMilestones;

  /// No description provided for @expectedMilestones.
  ///
  /// In en, this message translates to:
  /// **'Expected Milestones'**
  String get expectedMilestones;

  /// No description provided for @achievedMilestones.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get achievedMilestones;

  /// No description provided for @allMilestones.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allMilestones;

  /// No description provided for @activityPrompt.
  ///
  /// In en, this message translates to:
  /// **'Activity Prompt'**
  String get activityPrompt;

  /// No description provided for @needsEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Needs Evaluation'**
  String get needsEvaluation;

  /// No description provided for @selectBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Select BabyMon'**
  String get selectBabyMon;

  /// No description provided for @addBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Add BabyMon'**
  String get addBabyMon;

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

  /// No description provided for @permanentDeletion.
  ///
  /// In en, this message translates to:
  /// **'Permanent Deletion'**
  String get permanentDeletion;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// No description provided for @subscriptionActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subscriptionActive;

  /// No description provided for @subscriptionCancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling'**
  String get subscriptionCancelling;

  /// No description provided for @trialDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left in trial'**
  String trialDaysLeft(int days);

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'Level Up!'**
  String get levelUp;

  /// No description provided for @phaseMilestone.
  ///
  /// In en, this message translates to:
  /// **'Phase Milestone'**
  String get phaseMilestone;

  /// No description provided for @newLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}: {name}'**
  String newLevel(int level, Object name);

  /// No description provided for @shareBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Share BabyMon'**
  String get shareBabyMon;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @visualStyle.
  ///
  /// In en, this message translates to:
  /// **'Visual Style'**
  String get visualStyle;

  /// No description provided for @glass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get glass;

  /// No description provided for @clay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get clay;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

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

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @trackMilestone.
  ///
  /// In en, this message translates to:
  /// **'Track Milestone'**
  String get trackMilestone;

  /// No description provided for @addMilestone.
  ///
  /// In en, this message translates to:
  /// **'Add Milestone'**
  String get addMilestone;

  /// No description provided for @editMilestone.
  ///
  /// In en, this message translates to:
  /// **'Edit Milestone'**
  String get editMilestone;

  /// No description provided for @milestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestone Title'**
  String get milestoneTitle;

  /// No description provided for @milestoneDate.
  ///
  /// In en, this message translates to:
  /// **'Date Achieved'**
  String get milestoneDate;

  /// No description provided for @milestoneNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get milestoneNotes;

  /// No description provided for @milestoneDomain.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get milestoneDomain;

  /// No description provided for @grossMotor.
  ///
  /// In en, this message translates to:
  /// **'Gross Motor'**
  String get grossMotor;

  /// No description provided for @fineMotor.
  ///
  /// In en, this message translates to:
  /// **'Fine Motor'**
  String get fineMotor;

  /// No description provided for @languageComm.
  ///
  /// In en, this message translates to:
  /// **'Language & Communication'**
  String get languageComm;

  /// No description provided for @cognitive.
  ///
  /// In en, this message translates to:
  /// **'Cognitive'**
  String get cognitive;

  /// No description provided for @socialEmotional.
  ///
  /// In en, this message translates to:
  /// **'Social & Emotional'**
  String get socialEmotional;

  /// No description provided for @logFeed.
  ///
  /// In en, this message translates to:
  /// **'Log Feeding'**
  String get logFeed;

  /// No description provided for @breastfeeding.
  ///
  /// In en, this message translates to:
  /// **'Breastfeeding'**
  String get breastfeeding;

  /// No description provided for @formula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// No description provided for @solidFood.
  ///
  /// In en, this message translates to:
  /// **'Solid Food'**
  String get solidFood;

  /// No description provided for @feedAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get feedAmount;

  /// No description provided for @feedDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get feedDuration;

  /// No description provided for @feedUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get feedUnit;

  /// No description provided for @oz.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get oz;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @logSleep.
  ///
  /// In en, this message translates to:
  /// **'Log Sleep'**
  String get logSleep;

  /// No description provided for @sleepStart.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get sleepStart;

  /// No description provided for @sleepEnd.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get sleepEnd;

  /// No description provided for @nap.
  ///
  /// In en, this message translates to:
  /// **'Nap'**
  String get nap;

  /// No description provided for @nightSleep.
  ///
  /// In en, this message translates to:
  /// **'Night Sleep'**
  String get nightSleep;

  /// No description provided for @sleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get sleepQuality;

  /// No description provided for @logHealth.
  ///
  /// In en, this message translates to:
  /// **'Log Health Record'**
  String get logHealth;

  /// No description provided for @healthCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get healthCategory;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @doctorVisit.
  ///
  /// In en, this message translates to:
  /// **'Doctor Visit'**
  String get doctorVisit;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @headCircumference.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference'**
  String get headCircumference;

  /// No description provided for @logGrowth.
  ///
  /// In en, this message translates to:
  /// **'Log Growth'**
  String get logGrowth;

  /// No description provided for @growthType.
  ///
  /// In en, this message translates to:
  /// **'Measurement Type'**
  String get growthType;

  /// No description provided for @growthValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get growthValue;

  /// No description provided for @growthUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get growthUnit;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @lb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get lb;

  /// Imperial unit abbreviation for inches
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get unitInches;

  /// No description provided for @journalEntry.
  ///
  /// In en, this message translates to:
  /// **'Journal Entry'**
  String get journalEntry;

  /// No description provided for @allEntries.
  ///
  /// In en, this message translates to:
  /// **'All Entries'**
  String get allEntries;

  /// No description provided for @filterByType.
  ///
  /// In en, this message translates to:
  /// **'Filter by Type'**
  String get filterByType;

  /// No description provided for @pendingProposals.
  ///
  /// In en, this message translates to:
  /// **'Pending Proposals'**
  String get pendingProposals;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntries;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @noPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotos;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @babyMonProfile.
  ///
  /// In en, this message translates to:
  /// **'BabyMon Profile'**
  String get babyMonProfile;

  /// No description provided for @babyName.
  ///
  /// In en, this message translates to:
  /// **'Baby Name'**
  String get babyName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @conceptionDate.
  ///
  /// In en, this message translates to:
  /// **'Conception Date'**
  String get conceptionDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @addAllergy.
  ///
  /// In en, this message translates to:
  /// **'Add Allergy'**
  String get addAllergy;

  /// No description provided for @allergyName.
  ///
  /// In en, this message translates to:
  /// **'Allergy Name'**
  String get allergyName;

  /// No description provided for @allergySeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get allergySeverity;

  /// No description provided for @allergyTriggers.
  ///
  /// In en, this message translates to:
  /// **'Triggers'**
  String get allergyTriggers;

  /// No description provided for @allergyTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get allergyTreatment;

  /// No description provided for @mild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get mild;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// No description provided for @medicalTeam.
  ///
  /// In en, this message translates to:
  /// **'Medical Team'**
  String get medicalTeam;

  /// No description provided for @addMedicalContact.
  ///
  /// In en, this message translates to:
  /// **'Add Medical Contact'**
  String get addMedicalContact;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactName;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @facility.
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get facility;

  /// No description provided for @partners.
  ///
  /// In en, this message translates to:
  /// **'Co-Parents'**
  String get partners;

  /// No description provided for @invitePartner.
  ///
  /// In en, this message translates to:
  /// **'Invite Co-Parent'**
  String get invitePartner;

  /// No description provided for @partnerEmail.
  ///
  /// In en, this message translates to:
  /// **'Partner Email'**
  String get partnerEmail;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send Invitation'**
  String get sendInvite;

  /// No description provided for @pendingInvites.
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pendingInvites;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freePlan;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPlan;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @trialActive.
  ///
  /// In en, this message translates to:
  /// **'Trial Active'**
  String get trialActive;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemaining(Object days);

  /// No description provided for @renewalDate.
  ///
  /// In en, this message translates to:
  /// **'Renewal Date'**
  String get renewalDate;

  /// No description provided for @createBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Create BabyMon'**
  String get createBabyMon;

  /// No description provided for @stageType.
  ///
  /// In en, this message translates to:
  /// **'Stage Type'**
  String get stageType;

  /// No description provided for @idea.
  ///
  /// In en, this message translates to:
  /// **'Just an Idea'**
  String get idea;

  /// No description provided for @conceived.
  ///
  /// In en, this message translates to:
  /// **'Conceived'**
  String get conceived;

  /// No description provided for @born.
  ///
  /// In en, this message translates to:
  /// **'Born'**
  String get born;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @welcomeToBabymon.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BabyMon'**
  String get welcomeToBabymon;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @trackYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Track your parenting journey'**
  String get trackYourJourney;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

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

  /// No description provided for @dataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data has been cleared'**
  String get dataCleared;

  /// No description provided for @exportStarted.
  ///
  /// In en, this message translates to:
  /// **'Export started'**
  String get exportStarted;

  /// No description provided for @exportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export complete'**
  String get exportComplete;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @older.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get older;

  /// No description provided for @growthChart.
  ///
  /// In en, this message translates to:
  /// **'Growth Chart'**
  String get growthChart;

  /// No description provided for @percentile.
  ///
  /// In en, this message translates to:
  /// **'{p}th percentile'**
  String percentile(int p);

  /// No description provided for @trendUp.
  ///
  /// In en, this message translates to:
  /// **'Trending up'**
  String get trendUp;

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

  /// No description provided for @comparedToWho.
  ///
  /// In en, this message translates to:
  /// **'Compared to WHO standards'**
  String get comparedToWho;

  /// No description provided for @sleepSummary.
  ///
  /// In en, this message translates to:
  /// **'Sleep Summary'**
  String get sleepSummary;

  /// No description provided for @avgSleep.
  ///
  /// In en, this message translates to:
  /// **'Average Sleep'**
  String get avgSleep;

  /// No description provided for @totalSleep.
  ///
  /// In en, this message translates to:
  /// **'Total Sleep'**
  String get totalSleep;

  /// No description provided for @feedSummary.
  ///
  /// In en, this message translates to:
  /// **'Feeding Summary'**
  String get feedSummary;

  /// No description provided for @totalFeeds.
  ///
  /// In en, this message translates to:
  /// **'Total Feeds'**
  String get totalFeeds;

  /// No description provided for @healthRecords.
  ///
  /// In en, this message translates to:
  /// **'Health Records'**
  String get healthRecords;

  /// No description provided for @upcomingVaccines.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Vaccines'**
  String get upcomingVaccines;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueDate;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendEmail;

  /// No description provided for @checkInbox.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and click the verification link'**
  String get checkInbox;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get emailSent;

  /// No description provided for @biometricsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to continue'**
  String get biometricsPrompt;

  /// No description provided for @biometricsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available'**
  String get biometricsNotAvailable;

  /// No description provided for @socialLoginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get socialLoginGoogle;

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

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get deleteConfirmation;

  /// No description provided for @deleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get deleteWarning;

  /// No description provided for @noneRecorded.
  ///
  /// In en, this message translates to:
  /// **'None recorded'**
  String get noneRecorded;

  /// No description provided for @traits.
  ///
  /// In en, this message translates to:
  /// **'Traits'**
  String get traits;

  /// No description provided for @specialMove.
  ///
  /// In en, this message translates to:
  /// **'Special Move'**
  String get specialMove;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Shared via BabyMon'**
  String get shareText;

  /// No description provided for @xpProgress.
  ///
  /// In en, this message translates to:
  /// **'XP Progress'**
  String get xpProgress;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get currentLevel;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @badgesEarned.
  ///
  /// In en, this message translates to:
  /// **'Badges Earned'**
  String get badgesEarned;

  /// No description provided for @noBadges.
  ///
  /// In en, this message translates to:
  /// **'No badges yet'**
  String get noBadges;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutMessage;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @visualStyleGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get visualStyleGlass;

  /// No description provided for @visualStyleClay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get visualStyleClay;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get loginSubtitle;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @biometricPrompt.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to log in to BabyMon'**
  String get biometricPrompt;

  /// No description provided for @biometricEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get biometricEnableTitle;

  /// No description provided for @biometricEnablePrompt.
  ///
  /// In en, this message translates to:
  /// **'Would you like to use biometrics for faster sign-in next time?'**
  String get biometricEnablePrompt;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpLink;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLink;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a password reset link.'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get resetPasswordSuccess;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join BabyMon today'**
  String get createAccountSubtitle;

  /// No description provided for @nameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get nameOptional;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

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

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// No description provided for @dateOfBirthHelp.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get dateOfBirthHelp;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and click the verification link to continue.'**
  String get verifyEmailSubtitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// No description provided for @emailSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Check your inbox.'**
  String get emailSentSuccess;

  /// No description provided for @emailSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email. Please try again.'**
  String get emailSendFailed;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not yet verified. Please check your inbox.'**
  String get emailNotVerified;

  /// No description provided for @checkVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check verification status.'**
  String get checkVerificationFailed;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successful. Please login.'**
  String get passwordResetSuccess;

  /// No description provided for @resetPasswordSemantic.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetPasswordSemantic;

  /// No description provided for @acceptTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get acceptTermsPrefix;

  /// No description provided for @termsOfServiceLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceLink;

  /// No description provided for @acceptPrivacyPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get acceptPrivacyPrefix;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @iConsentToDataProcessing.
  ///
  /// In en, this message translates to:
  /// **'I consent to processing of child health & development data'**
  String get iConsentToDataProcessing;

  /// No description provided for @pleaseSelectDob.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get pleaseSelectDob;

  /// No description provided for @mustAcceptTos.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms of Service'**
  String get mustAcceptTos;

  /// No description provided for @mustAcceptPrivacy.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Privacy Policy'**
  String get mustAcceptPrivacy;

  /// No description provided for @mustConsentData.
  ///
  /// In en, this message translates to:
  /// **'You must consent to data processing'**
  String get mustConsentData;

  /// No description provided for @togglePasswordVisibility.
  ///
  /// In en, this message translates to:
  /// **'Toggle password visibility'**
  String get togglePasswordVisibility;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated!'**
  String get nameUpdated;

  /// No description provided for @noBabyMonToExport.
  ///
  /// In en, this message translates to:
  /// **'No BabyMon to export'**
  String get noBabyMonToExport;

  /// No description provided for @exportingData.
  ///
  /// In en, this message translates to:
  /// **'Exporting your data...'**
  String get exportingData;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @babyMonDeleted.
  ///
  /// In en, this message translates to:
  /// **'BabyMon permanently deleted'**
  String get babyMonDeleted;

  /// No description provided for @createBabyMonFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a BabyMon first'**
  String get createBabyMonFirst;

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

  /// No description provided for @allergiesCleared.
  ///
  /// In en, this message translates to:
  /// **'allergies cleared'**
  String get allergiesCleared;

  /// No description provided for @eventsCleared.
  ///
  /// In en, this message translates to:
  /// **'events cleared'**
  String get eventsCleared;

  /// No description provided for @couldNotClear.
  ///
  /// In en, this message translates to:
  /// **'Could not clear. Please try again.'**
  String get couldNotClear;

  /// No description provided for @noBabyMonsToDelete.
  ///
  /// In en, this message translates to:
  /// **'No BabyMons to delete'**
  String get noBabyMonsToDelete;

  /// No description provided for @noBabyMonSelected.
  ///
  /// In en, this message translates to:
  /// **'No BabyMon selected'**
  String get noBabyMonSelected;

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutTitle;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @localeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get localeUpdated;

  /// No description provided for @localeUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update language'**
  String get localeUpdateFailed;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @subscriptionAndPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscription & Plan'**
  String get subscriptionAndPlan;

  /// No description provided for @comparePlans.
  ///
  /// In en, this message translates to:
  /// **'Compare plans & upgrade'**
  String get comparePlans;

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

  /// No description provided for @biometricLoginSetting.
  ///
  /// In en, this message translates to:
  /// **'Biometric login'**
  String get biometricLoginSetting;

  /// No description provided for @biometricLoginDesc.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face to sign in'**
  String get biometricLoginDesc;

  /// No description provided for @measurementUnits.
  ///
  /// In en, this message translates to:
  /// **'Measurement units'**
  String get measurementUnits;

  /// No description provided for @visualStyleDesc.
  ///
  /// In en, this message translates to:
  /// **'Glass or Clay theme'**
  String get visualStyleDesc;

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

  /// No description provided for @babyMonData.
  ///
  /// In en, this message translates to:
  /// **'BabyMon Data'**
  String get babyMonData;

  /// No description provided for @activeBabyMon.
  ///
  /// In en, this message translates to:
  /// **'Active BabyMon'**
  String get activeBabyMon;

  /// No description provided for @switchBabyMonHint.
  ///
  /// In en, this message translates to:
  /// **'Use the avatar in the top bar to switch'**
  String get switchBabyMonHint;

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

  /// No description provided for @backupPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Backup & Privacy'**
  String get backupPrivacy;

  /// No description provided for @exportDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Download all records as JSON'**
  String get exportDataDesc;

  /// No description provided for @syncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get syncStatus;

  /// No description provided for @allChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'All changes saved'**
  String get allChangesSaved;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

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

  /// No description provided for @deleteBabyMonDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove all data'**
  String get deleteBabyMonDesc;

  /// No description provided for @signOutDevice.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device'**
  String get signOutDevice;

  /// No description provided for @clearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperial;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} — coming soon'**
  String featureComingSoon(Object feature);

  /// No description provided for @errorInternal.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorInternal;

  /// No description provided for @errorDatabase.
  ///
  /// In en, this message translates to:
  /// **'A database error occurred. Please try again.'**
  String get errorDatabase;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your input.'**
  String get errorValidation;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found. The feature may not be available yet.'**
  String get errorNotFound;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorInvalidToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid token. Please log in again.'**
  String get errorInvalidToken;

  /// No description provided for @errorTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorTokenExpired;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get errorUserNotFound;

  /// No description provided for @errorAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'This account has been deleted.'**
  String get errorAccountDeleted;

  /// No description provided for @errorOAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please use social login for this account.'**
  String get errorOAuthRequired;

  /// No description provided for @errorDuplicateEmail.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get errorDuplicateEmail;

  /// No description provided for @errorInvalidOperation.
  ///
  /// In en, this message translates to:
  /// **'Invalid operation. Please try again.'**
  String get errorInvalidOperation;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment.'**
  String get errorRateLimited;

  /// No description provided for @errorTrialExpired.
  ///
  /// In en, this message translates to:
  /// **'Your free trial has expired. Please upgrade.'**
  String get errorTrialExpired;

  /// No description provided for @errorLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached the limit for this feature.'**
  String get errorLimitReached;

  /// No description provided for @errorUpgradeRequired.
  ///
  /// In en, this message translates to:
  /// **'This feature requires a Premium subscription.'**
  String get errorUpgradeRequired;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use.'**
  String get errorEmailInUse;

  /// No description provided for @errorInvalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid password.'**
  String get errorInvalidPassword;

  /// No description provided for @errorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your input.'**
  String get errorBadRequest;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get errorForbidden;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'This already exists. Please use a different value.'**
  String get errorConflict;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please check your internet.'**
  String get errorConnectionTimeout;

  /// No description provided for @errorConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server.'**
  String get errorConnectionFailed;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorBabyMonNotFound.
  ///
  /// In en, this message translates to:
  /// **'BabyMon not found.'**
  String get errorBabyMonNotFound;

  /// No description provided for @errorMilestoneNotFound.
  ///
  /// In en, this message translates to:
  /// **'Milestone not found.'**
  String get errorMilestoneNotFound;

  /// No description provided for @errorFeedLogNotFound.
  ///
  /// In en, this message translates to:
  /// **'Feed log not found.'**
  String get errorFeedLogNotFound;

  /// No description provided for @errorHealthRecordNotFound.
  ///
  /// In en, this message translates to:
  /// **'Health record not found.'**
  String get errorHealthRecordNotFound;

  /// No description provided for @errorInvitationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invitation not found.'**
  String get errorInvitationNotFound;

  /// No description provided for @errorCannotInviteSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot invite yourself.'**
  String get errorCannotInviteSelf;

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

  /// No description provided for @errorLinkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Link not found.'**
  String get errorLinkNotFound;

  /// No description provided for @errorPromoCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid promo code.'**
  String get errorPromoCodeInvalid;

  /// No description provided for @errorPromoCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This promo code has expired.'**
  String get errorPromoCodeExpired;

  /// No description provided for @errorPromoCodeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'This promo code has reached its usage limit.'**
  String get errorPromoCodeLimitReached;

  /// No description provided for @errorPromoCodeAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'You have already used this promo code.'**
  String get errorPromoCodeAlreadyUsed;

  /// No description provided for @errorAppleSignInUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In is not available on this device.'**
  String get errorAppleSignInUnavailable;

  /// No description provided for @errorAppleNoIdentityToken.
  ///
  /// In en, this message translates to:
  /// **'No identity token received from Apple.'**
  String get errorAppleNoIdentityToken;

  /// No description provided for @errorFacebookNoAccessToken.
  ///
  /// In en, this message translates to:
  /// **'No access token received from Facebook.'**
  String get errorFacebookNoAccessToken;

  /// No description provided for @welcomeChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get welcomeChooseLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

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

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
