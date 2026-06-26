// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'BabyMon';

  @override
  String get appTagline => 'Intelligenter, sich entwickelnder Begleiter für Eltern';

  @override
  String get welcomeBack => 'Willkommen zurück';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get nameLabel => 'Name';

  @override
  String get loginButton => 'Anmelden';

  @override
  String get registerButton => 'Registrieren';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get resetPassword => 'Passwort zurücksetzen';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get verifyEmail => 'E-Mail bestätigen';

  @override
  String get backToLogin => 'Zurück zur Anmeldung';

  @override
  String get orContinueWith => 'oder fortfahren mit';

  @override
  String get noAccount => 'Noch kein Konto?';

  @override
  String get hasAccount => 'Bereits ein Konto? ';

  @override
  String get signUp => 'Registrieren';

  @override
  String get logOut => 'Abmelden';

  @override
  String get settings => 'Einstellungen';

  @override
  String get dashboard => 'Übersicht';

  @override
  String get milestones => 'Meilensteine';

  @override
  String get feeding => 'Fütterung';

  @override
  String get sleep => 'Schlaf';

  @override
  String get health => 'Gesundheit';

  @override
  String get growth => 'Wachstum';

  @override
  String get journal => 'Tagebuch';

  @override
  String get companion => 'KI-Begleiter';

  @override
  String get profile => 'Profil';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get error => 'Fehler';

  @override
  String get success => 'Erfolg';

  @override
  String get retry => 'Wiederholen';

  @override
  String get noData => 'Keine Daten verfügbar';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get ageConsent => 'Ich bestätige, dass ich mindestens 18 Jahre alt bin';

  @override
  String get tosConsent => 'Ich akzeptiere die Nutzungsbedingungen';

  @override
  String get privacyConsent => 'Ich akzeptiere die Datenschutzerklärung';

  @override
  String get dataConsent => 'Ich stimme der Verarbeitung von Gesundheits- und Entwicklungsdaten des Kindes zu';

  @override
  String get passwordStrength => 'Passwortstärke';

  @override
  String get passwordRequirements => 'Mindestens 8 Zeichen mit Großbuchstaben, Kleinbuchstaben und Zahlen';

  @override
  String get biometricLogin => 'Biometrische Anmeldung';

  @override
  String get medicalDisclaimer => 'Der KI-Begleiter ersetzt keine professionelle medizinische Beratung. Konsultieren Sie immer Ihren Arzt.';

  @override
  String get emergencyDisclaimer => 'Bei einem medizinischen Notfall beenden Sie die Nutzung dieser App und rufen Sie sofort den Notruf an.';

  @override
  String get dailyBrief => 'Tägliche Zusammenfassung';

  @override
  String get routine => 'Routine';

  @override
  String get adviceFeed => 'Ratschläge';

  @override
  String get chat => 'Chat';

  @override
  String get askCompanion => 'Den Begleiter fragen';

  @override
  String get typeMessage => 'Nachricht eingeben...';

  @override
  String get modelDownload => 'Modell-Download';

  @override
  String get downloadModel => 'Modell herunterladen';

  @override
  String get modelRequired => 'Der KI-Begleiter muss ein Sprachmodell herunterladen, um personalisierte Anleitungen auf Ihrem Gerät bereitzustellen.';

  @override
  String get downloading => 'Wird heruntergeladen...';

  @override
  String get verifying => 'Wird überprüft...';

  @override
  String get complete => 'Abgeschlossen';

  @override
  String get errorDownloading => 'Fehler beim Herunterladen des Modells';

  @override
  String get retryDownload => 'Wiederholen';

  @override
  String get medicalDisclaimerTitle => 'Medizinischer Hinweis';

  @override
  String get iUnderstand => 'Ich verstehe';

  @override
  String get achieved => 'Erreicht!';

  @override
  String get milestoneAchieved => 'Meilenstein erreicht!';

  @override
  String xpEarned(int xp) {
    return '+$xp EP';
  }

  @override
  String get noMilestones => 'Noch keine Meilensteine erfasst';

  @override
  String get expectedMilestones => 'Erwartete Meilensteine';

  @override
  String get achievedMilestones => 'Erreicht';

  @override
  String get allMilestones => 'Alle';

  @override
  String get activityPrompt => 'Aktivitätsvorschlag';

  @override
  String get needsEvaluation => 'Benötigt Bewertung';

  @override
  String get selectBabyMon => 'BabyMon auswählen';

  @override
  String get addBabyMon => 'BabyMon hinzufügen';

  @override
  String get deleteBabyMon => 'BabyMon löschen';

  @override
  String get deleteBabyMonConfirm => 'Diese Aktion kann nicht rückgängig gemacht werden. Alle Daten dieses BabyMon werden dauerhaft gelöscht.';

  @override
  String get permanentDeletion => 'Dauerhafte Löschung';

  @override
  String get cancelSubscription => 'Abonnement kündigen';

  @override
  String get subscriptionActive => 'Aktiv';

  @override
  String get subscriptionCancelling => 'Wird gekündigt';

  @override
  String trialDaysLeft(int days) {
    return 'Noch $days Tage im Testzeitraum';
  }

  @override
  String get subscribeNow => 'Jetzt abonnieren';

  @override
  String get manageSubscription => 'Abonnement verwalten';

  @override
  String get levelUp => 'Levelaufstieg!';

  @override
  String get phaseMilestone => 'Phasen-Meilenstein';

  @override
  String newLevel(int level, Object name) {
    return 'Level $level: $name';
  }

  @override
  String get shareBabyMon => 'BabyMon teilen';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get visualStyle => 'Visueller Stil';

  @override
  String get glass => 'Glas';

  @override
  String get clay => 'Ton';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get about => 'Über';

  @override
  String get version => 'Version';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountConfirm => 'Dies wird Ihr Konto und alle zugehörigen Daten dauerhaft löschen.';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get currentPassword => 'Aktuelles Passwort';

  @override
  String get updatePassword => 'Passwort aktualisieren';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get emailNotifications => 'E-Mail-Benachrichtigungen';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get trackMilestone => 'Meilenstein erfassen';

  @override
  String get addMilestone => 'Meilenstein hinzufügen';

  @override
  String get editMilestone => 'Meilenstein bearbeiten';

  @override
  String get milestoneTitle => 'Titel des Meilensteins';

  @override
  String get milestoneDate => 'Erreicht am';

  @override
  String get milestoneNotes => 'Notizen';

  @override
  String get milestoneDomain => 'Kategorie';

  @override
  String get grossMotor => 'Grobmotorik';

  @override
  String get fineMotor => 'Feinmotorik';

  @override
  String get languageComm => 'Sprache & Kommunikation';

  @override
  String get cognitive => 'Kognitiv';

  @override
  String get socialEmotional => 'Sozial & Emotional';

  @override
  String get logFeed => 'Fütterung erfassen';

  @override
  String get breastfeeding => 'Stillen';

  @override
  String get formula => 'Milchpulver';

  @override
  String get solidFood => 'Feste Nahrung';

  @override
  String get feedAmount => 'Menge';

  @override
  String get feedDuration => 'Dauer';

  @override
  String get feedUnit => 'Einheit';

  @override
  String get oz => 'oz';

  @override
  String get ml => 'ml';

  @override
  String get logSleep => 'Schlaf erfassen';

  @override
  String get sleepStart => 'Startzeit';

  @override
  String get sleepEnd => 'Endzeit';

  @override
  String get nap => 'Nickerchen';

  @override
  String get nightSleep => 'Nachtschlaf';

  @override
  String get sleepQuality => 'Qualität';

  @override
  String get logHealth => 'Gesundheitseintrag erfassen';

  @override
  String get healthCategory => 'Kategorie';

  @override
  String get vaccination => 'Impfung';

  @override
  String get doctorVisit => 'Arztbesuch';

  @override
  String get temperature => 'Temperatur';

  @override
  String get weight => 'Gewicht';

  @override
  String get height => 'Größe';

  @override
  String get headCircumference => 'Kopfumfang';

  @override
  String get logGrowth => 'Wachstum erfassen';

  @override
  String get growthType => 'Messtyp';

  @override
  String get growthValue => 'Wert';

  @override
  String get growthUnit => 'Einheit';

  @override
  String get cm => 'cm';

  @override
  String get kg => 'kg';

  @override
  String get lb => 'lb';

  @override
  String get unitInches => 'in';

  @override
  String get journalEntry => 'Tagebucheintrag';

  @override
  String get allEntries => 'Alle Einträge';

  @override
  String get filterByType => 'Nach Typ filtern';

  @override
  String get pendingProposals => 'Ausstehende Vorschläge';

  @override
  String get noEntries => 'Noch keine Einträge';

  @override
  String get photos => 'Fotos';

  @override
  String get uploadPhoto => 'Foto hochladen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromGallery => 'Aus der Galerie auswählen';

  @override
  String get noPhotos => 'Noch keine Fotos';

  @override
  String get discover => 'Entdecken';

  @override
  String get babyMonProfile => 'BabyMon-Profil';

  @override
  String get babyName => 'Name des Babys';

  @override
  String get birthDate => 'Geburtsdatum';

  @override
  String get conceptionDate => 'Konzeptionsdatum';

  @override
  String get gender => 'Geschlecht';

  @override
  String get bloodType => 'Blutgruppe';

  @override
  String get allergies => 'Allergien';

  @override
  String get addAllergy => 'Allergie hinzufügen';

  @override
  String get allergyName => 'Name der Allergie';

  @override
  String get allergySeverity => 'Schweregrad';

  @override
  String get allergyTriggers => 'Auslöser';

  @override
  String get allergyTreatment => 'Behandlung';

  @override
  String get mild => 'Leicht';

  @override
  String get moderate => 'Mittel';

  @override
  String get severe => 'Schwer';

  @override
  String get medicalTeam => 'Medizinisches Team';

  @override
  String get addMedicalContact => 'Medizinischen Kontakt hinzufügen';

  @override
  String get contactName => 'Name';

  @override
  String get specialty => 'Fachgebiet';

  @override
  String get facility => 'Einrichtung';

  @override
  String get partners => 'Co-Eltern';

  @override
  String get invitePartner => 'Co-Elternteil einladen';

  @override
  String get partnerEmail => 'E-Mail des Co-Elternteils';

  @override
  String get sendInvite => 'Einladung senden';

  @override
  String get pendingInvites => 'Ausstehende Einladungen';

  @override
  String get accepted => 'Angenommen';

  @override
  String get declined => 'Abgelehnt';

  @override
  String get subscription => 'Abonnement';

  @override
  String get currentPlan => 'Aktueller Plan';

  @override
  String get freePlan => 'Kostenlos';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get upgradeToPremium => 'Auf Premium upgraden';

  @override
  String get trialActive => 'Testzeitraum aktiv';

  @override
  String daysRemaining(Object days) {
    return 'Noch $days Tage';
  }

  @override
  String get renewalDate => 'Erneuerungsdatum';

  @override
  String get createBabyMon => 'BabyMon erstellen';

  @override
  String get stageType => 'Etappentyp';

  @override
  String get idea => 'Nur eine Idee';

  @override
  String get conceived => 'Empfangen';

  @override
  String get born => 'Geboren';

  @override
  String get createProfile => 'Profil erstellen';

  @override
  String get welcomeToBabymon => 'Willkommen bei BabyMon';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get trackYourJourney => 'Verfolgen Sie Ihre Elternreise';

  @override
  String get skip => 'Überspringen';

  @override
  String get next => 'Weiter';

  @override
  String get finish => 'Fertig';

  @override
  String get album => 'Album';

  @override
  String get share => 'Teilen';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get clearData => 'Daten löschen';

  @override
  String get clearAllData => 'Alle Daten löschen';

  @override
  String get clearAllDataConfirm => 'Dies wird alle Daten dauerhaft löschen. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get dataCleared => 'Alle Daten wurden gelöscht';

  @override
  String get exportStarted => 'Export gestartet';

  @override
  String get exportComplete => 'Export abgeschlossen';

  @override
  String get noInternet => 'Keine Internetverbindung';

  @override
  String get somethingWentWrong => 'Etwas ist schiefgelaufen';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get close => 'Schließen';

  @override
  String get search => 'Suchen';

  @override
  String get filter => 'Filtern';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get newest => 'Neueste';

  @override
  String get oldest => 'Älteste';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get selectTime => 'Uhrzeit auswählen';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get lastWeek => 'Letzte Woche';

  @override
  String get thisMonth => 'Dieser Monat';

  @override
  String get older => 'Älter';

  @override
  String get growthChart => 'Wachstumsdiagramm';

  @override
  String percentile(int p) {
    return '$p. Perzentile';
  }

  @override
  String get trendUp => 'Aufwärtstrend';

  @override
  String get trendDown => 'Abwärtstrend';

  @override
  String get trendStable => 'Stabil';

  @override
  String get comparedToWho => 'Verglichen mit WHO-Standards';

  @override
  String get sleepSummary => 'Schlafzusammenfassung';

  @override
  String get avgSleep => 'Durchschnittlicher Schlaf';

  @override
  String get totalSleep => 'Gesamtschlaf';

  @override
  String get feedSummary => 'Fütterungszusammenfassung';

  @override
  String get totalFeeds => 'Gesamte Fütterungen';

  @override
  String get healthRecords => 'Gesundheitsakten';

  @override
  String get upcomingVaccines => 'Bevorstehende Impfungen';

  @override
  String get dueDate => 'Fällig';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get pending => 'Ausstehend';

  @override
  String get verified => 'Verifiziert';

  @override
  String get unverified => 'Nicht verifiziert';

  @override
  String get resendEmail => 'Bestätigungs-E-Mail erneut senden';

  @override
  String get checkInbox => 'Bitte überprüfen Sie Ihren Posteingang und klicken Sie auf den Bestätigungslink';

  @override
  String get emailSent => 'Bestätigungs-E-Mail gesendet';

  @override
  String get biometricsPrompt => 'Authentifizieren Sie sich, um fortzufahren';

  @override
  String get biometricsNotAvailable => 'Biometrie nicht verfügbar';

  @override
  String get socialLoginGoogle => 'Mit Google fortfahren';

  @override
  String get socialLoginApple => 'Mit Apple fortfahren';

  @override
  String get socialLoginFacebook => 'Mit Facebook fortfahren';

  @override
  String get deleteConfirmation => 'Sind Sie sicher, dass Sie dies löschen möchten?';

  @override
  String get deleteWarning => 'Diese Aktion kann nicht rückgängig gemacht werden';

  @override
  String get noneRecorded => 'Nichts erfasst';

  @override
  String get traits => 'Eigenschaften';

  @override
  String get specialMove => 'Spezialzug';

  @override
  String get bloodGroup => 'Blutgruppe';

  @override
  String get mother => 'Mutter';

  @override
  String get father => 'Vater';

  @override
  String get contact => 'Kontakt';

  @override
  String get shareText => 'Geteilt über BabyMon';

  @override
  String get xpProgress => 'EP-Fortschritt';

  @override
  String get currentLevel => 'Aktuelles Level';

  @override
  String get nextLevel => 'Nächstes Level';

  @override
  String get badgesEarned => 'Verdiente Abzeichen';

  @override
  String get noBadges => 'Noch keine Abzeichen';

  @override
  String get viewAll => 'Alle anzeigen';

  @override
  String get showMore => 'Mehr anzeigen';

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String get confirmDelete => 'Löschen bestätigen';

  @override
  String get confirmLogout => 'Abmeldung bestätigen';

  @override
  String get logoutMessage => 'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'System';

  @override
  String get visualStyleGlass => 'Glas';

  @override
  String get visualStyleClay => 'Ton';

  @override
  String get loginTitle => 'Willkommen zurück!';

  @override
  String get loginSubtitle => 'Melden Sie sich an, um fortzufahren';

  @override
  String get emailRequired => 'Bitte geben Sie Ihre E-Mail-Adresse ein';

  @override
  String get passwordRequired => 'Bitte geben Sie Ihr Passwort ein';

  @override
  String get biometricPrompt => 'Authentifizieren Sie sich, um sich bei BabyMon anzumelden';

  @override
  String get biometricEnableTitle => 'Biometrische Anmeldung aktivieren';

  @override
  String get biometricEnablePrompt => 'Möchten Sie Biometrie für eine schnellere Anmeldung beim nächsten Mal verwenden?';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get enable => 'Aktivieren';

  @override
  String get orDivider => 'ODER';

  @override
  String get signUpLink => 'Registrieren';

  @override
  String get loginLink => 'Anmelden';

  @override
  String get resetPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get resetPasswordSubtitle => 'Geben Sie Ihre E-Mail-Adresse ein und wir senden Ihnen einen Link zum Zurücksetzen.';

  @override
  String get sendResetLink => 'Link senden';

  @override
  String get resetPasswordSuccess => 'Zurücksetzungslink an Ihre E-Mail gesendet';

  @override
  String get createAccountTitle => 'Konto erstellen';

  @override
  String get createAccountSubtitle => 'Treten Sie BabyMon noch heute bei';

  @override
  String get nameOptional => 'Name (optional)';

  @override
  String get passwordWeak => 'Schwach';

  @override
  String get passwordFair => 'Mittel';

  @override
  String get passwordGood => 'Gut';

  @override
  String get passwordStrong => 'Stark';

  @override
  String get dateOfBirth => 'Geburtsdatum';

  @override
  String get tapToSelect => 'Zum Auswählen tippen';

  @override
  String get dateOfBirthHelp => 'Wählen Sie Ihr Geburtsdatum';

  @override
  String get verifyEmailTitle => 'E-Mail bestätigen';

  @override
  String get verifyEmailSubtitle => 'Bitte überprüfen Sie Ihren Posteingang und klicken Sie auf den Bestätigungslink, um fortzufahren.';

  @override
  String get continueButton => 'Weiter';

  @override
  String get resendVerificationEmail => 'Bestätigungs-E-Mail erneut senden';

  @override
  String get emailSentSuccess => 'Bestätigungs-E-Mail gesendet! Überprüfen Sie Ihren Posteingang.';

  @override
  String get emailSendFailed => 'Fehler beim Senden der Bestätigungs-E-Mail. Bitte versuchen Sie es erneut.';

  @override
  String get emailNotVerified => 'E-Mail noch nicht bestätigt. Bitte überprüfen Sie Ihren Posteingang.';

  @override
  String get checkVerificationFailed => 'Fehler bei der Überprüfung des Bestätigungsstatus.';

  @override
  String get newPasswordLabel => 'Neues Passwort';

  @override
  String get passwordMinLength => 'Das Passwort muss mindestens 6 Zeichen enthalten';

  @override
  String get passwordsDoNotMatch => 'Die Passwörter stimmen nicht überein';

  @override
  String get passwordResetSuccess => 'Passwort erfolgreich zurückgesetzt. Bitte melden Sie sich an.';

  @override
  String get resetPasswordSemantic => 'Passwort zurücksetzen';

  @override
  String get acceptTermsPrefix => 'Ich akzeptiere die ';

  @override
  String get termsOfServiceLink => 'Nutzungsbedingungen';

  @override
  String get acceptPrivacyPrefix => 'Ich akzeptiere die ';

  @override
  String get privacyPolicyLink => 'Datenschutzerklärung';

  @override
  String get iConsentToDataProcessing => 'Ich stimme der Verarbeitung von Gesundheits- und Entwicklungsdaten des Kindes zu';

  @override
  String get pleaseSelectDob => 'Bitte wählen Sie Ihr Geburtsdatum';

  @override
  String get mustAcceptTos => 'Sie müssen die Nutzungsbedingungen akzeptieren';

  @override
  String get mustAcceptPrivacy => 'Sie müssen die Datenschutzerklärung akzeptieren';

  @override
  String get mustConsentData => 'Sie müssen der Datenverarbeitung zustimmen';

  @override
  String get togglePasswordVisibility => 'Passwortsichtbarkeit umschalten';

  @override
  String get editName => 'Name bearbeiten';

  @override
  String get nameUpdated => 'Name aktualisiert!';

  @override
  String get noBabyMonToExport => 'Kein BabyMon zum Exportieren';

  @override
  String get exportingData => 'Ihre Daten werden exportiert...';

  @override
  String get deletePermanently => 'Dauerhaft löschen';

  @override
  String get babyMonDeleted => 'BabyMon dauerhaft gelöscht';

  @override
  String get createBabyMonFirst => 'Erstellen Sie zuerst ein BabyMon';

  @override
  String get clearAllAllergies => 'Alle Allergien löschen';

  @override
  String get clearAllAllergiesDesc => 'Entfernt alle Allergieprofile und Ereignisse';

  @override
  String get clearAllEvents => 'Alle Allergieereignisse löschen';

  @override
  String get clearAllEventsDesc => 'Entfernt Ereignisse, behält aber Allergieprofile';

  @override
  String get allergiesCleared => 'Allergien gelöscht';

  @override
  String get eventsCleared => 'Ereignisse gelöscht';

  @override
  String get couldNotClear => 'Löschen nicht möglich. Bitte versuchen Sie es erneut.';

  @override
  String get noBabyMonsToDelete => 'Keine BabyMons zum Löschen';

  @override
  String get noBabyMonSelected => 'Kein BabyMon ausgewählt';

  @override
  String get logOutTitle => 'Abmelden';

  @override
  String get logOutConfirm => 'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get saveButton => 'Speichern';

  @override
  String get languageSetting => 'Sprache';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get currentLanguage => 'Aktuelle Sprache';

  @override
  String get localeUpdated => 'Sprache aktualisiert';

  @override
  String get localeUpdateFailed => 'Sprache konnte nicht aktualisiert werden';

  @override
  String get preferences => 'Preferences';

  @override
  String get subscriptionAndPlan => 'Subscription & Plan';

  @override
  String get comparePlans => 'Compare plans & upgrade';

  @override
  String get notificationPreferences => 'Notification preferences';

  @override
  String get notificationPreferencesDesc => 'Push, milestone reminders, partner activity';

  @override
  String get biometricLoginSetting => 'Biometric login';

  @override
  String get biometricLoginDesc => 'Use fingerprint or face to sign in';

  @override
  String get measurementUnits => 'Measurement units';

  @override
  String get visualStyleDesc => 'Glass or Clay theme';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get themeModeDesc => 'Light, dark, or follow system';

  @override
  String get babyMonData => 'BabyMon Data';

  @override
  String get activeBabyMon => 'Active BabyMon';

  @override
  String get switchBabyMonHint => 'Use the avatar in the top bar to switch';

  @override
  String get managePartners => 'Manage Partners';

  @override
  String get managePartnersDesc => 'Co-parents & guardians with access';

  @override
  String get backupPrivacy => 'Backup & Privacy';

  @override
  String get exportDataDesc => 'Download all records as JSON';

  @override
  String get syncStatus => 'Sync status';

  @override
  String get allChangesSaved => 'All changes saved';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get clearAllergiesEvents => 'Clear allergies & events';

  @override
  String get clearAllergiesEventsDesc => 'Remove allergy records for this BabyMon';

  @override
  String get deleteBabyMonDesc => 'Permanently remove all data';

  @override
  String get signOutDevice => 'Sign out of this device';

  @override
  String get clearButton => 'Clear';

  @override
  String get metric => 'Metric';

  @override
  String get imperial => 'Imperial';

  @override
  String featureComingSoon(Object feature) {
    return '$feature — coming soon';
  }

  @override
  String get errorInternal => 'Etwas ist schiefgelaufen. Bitte versuchen Sie es erneut.';

  @override
  String get errorDatabase => 'Ein Datenbankfehler ist aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get errorValidation => 'Ungültige Anfrage. Bitte überprüfen Sie Ihre Eingabe.';

  @override
  String get errorNotFound => 'Nicht gefunden. Die Funktion ist möglicherweise noch nicht verfügbar.';

  @override
  String get errorUnauthorized => 'Sitzung abgelaufen. Bitte melden Sie sich erneut an.';

  @override
  String get errorInvalidToken => 'Ungültiges Token. Bitte melden Sie sich erneut an.';

  @override
  String get errorTokenExpired => 'Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an.';

  @override
  String get errorUserNotFound => 'Benutzer nicht gefunden.';

  @override
  String get errorAccountDeleted => 'Dieses Konto wurde gelöscht.';

  @override
  String get errorOAuthRequired => 'Bitte verwenden Sie die soziale Anmeldung für dieses Konto.';

  @override
  String get errorDuplicateEmail => 'Diese E-Mail ist bereits registriert.';

  @override
  String get errorInvalidOperation => 'Ungültige Operation. Bitte versuchen Sie es erneut.';

  @override
  String get errorRateLimited => 'Zu viele Anfragen. Bitte warten Sie einen Moment.';

  @override
  String get errorTrialExpired => 'Ihre kostenlose Testphase ist abgelaufen. Bitte upgraden Sie.';

  @override
  String get errorLimitReached => 'Sie haben das Limit für diese Funktion erreicht.';

  @override
  String get errorUpgradeRequired => 'Diese Funktion erfordert ein Premium-Abonnement.';

  @override
  String get errorEmailInUse => 'E-Mail bereits in Verwendung.';

  @override
  String get errorInvalidPassword => 'Ungültiges Passwort.';

  @override
  String get errorBadRequest => 'Ungültige Anfrage. Bitte überprüfen Sie Ihre Eingabe.';

  @override
  String get errorForbidden => 'Sie sind nicht berechtigt, das zu tun.';

  @override
  String get errorConflict => 'Dies existiert bereits. Bitte verwenden Sie einen anderen Wert.';

  @override
  String get errorServer => 'Serverfehler. Bitte versuchen Sie es später erneut.';

  @override
  String get errorConnectionTimeout => 'Verbindungszeit überschritten. Bitte überprüfen Sie Ihr Internet.';

  @override
  String get errorConnectionFailed => 'Verbindung zum Server konnte nicht hergestellt werden.';

  @override
  String get errorNetwork => 'Netzwerkfehler. Bitte überprüfen Sie Ihre Verbindung.';

  @override
  String get errorBabyMonNotFound => 'BabyMon nicht gefunden.';

  @override
  String get errorMilestoneNotFound => 'Meilenstein nicht gefunden.';

  @override
  String get errorFeedLogNotFound => 'Fütterungsprotokoll nicht gefunden.';

  @override
  String get errorHealthRecordNotFound => 'Gesundheitsakte nicht gefunden.';

  @override
  String get errorInvitationNotFound => 'Einladung nicht gefunden.';

  @override
  String get errorCannotInviteSelf => 'Sie können sich nicht selbst einladen.';

  @override
  String get errorInvitationAlreadyProcessed => 'Einladung wurde bereits bearbeitet.';

  @override
  String get errorInvitationExpired => 'Die Einladung ist abgelaufen.';

  @override
  String get errorLinkNotFound => 'Link nicht gefunden.';

  @override
  String get errorPromoCodeInvalid => 'Ungültiger Promo-Code.';

  @override
  String get errorPromoCodeExpired => 'Dieser Promo-Code ist abgelaufen.';

  @override
  String get errorPromoCodeLimitReached => 'Dieser Promo-Code hat seine Nutzungsgrenze erreicht.';

  @override
  String get errorPromoCodeAlreadyUsed => 'Sie haben diesen Promo-Code bereits verwendet.';

  @override
  String get errorAppleSignInUnavailable => 'Apple-Anmeldung ist auf diesem Gerät nicht verfügbar.';

  @override
  String get errorAppleNoIdentityToken => 'Kein Identitätstoken von Apple erhalten.';

  @override
  String get errorFacebookNoAccessToken => 'Kein Zugriffstoken von Facebook erhalten.';

  @override
  String get welcomeChooseLanguage => 'Wählen Sie Ihre Sprache';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get errorUnknown => 'Etwas ist schiefgelaufen. Bitte versuchen Sie es erneut.';
}
