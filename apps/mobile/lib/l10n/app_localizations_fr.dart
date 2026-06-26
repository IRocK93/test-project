// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'BabyMon';

  @override
  String get appTagline => 'Compagnon Parental Intelligent en Évolution';

  @override
  String get welcomeBack => 'Bon Retour';

  @override
  String get createAccount => 'Créer un Compte';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de Passe';

  @override
  String get nameLabel => 'Nom';

  @override
  String get loginButton => 'Se Connecter';

  @override
  String get registerButton => 'S\'inscrire';

  @override
  String get forgotPassword => 'Mot de Passe Oublié ?';

  @override
  String get resetPassword => 'Réinitialiser le Mot de Passe';

  @override
  String get newPassword => 'Nouveau Mot de Passe';

  @override
  String get confirmPassword => 'Confirmer le Mot de Passe';

  @override
  String get verifyEmail => 'Vérifiez votre E-mail';

  @override
  String get backToLogin => 'Retour à la Connexion';

  @override
  String get orContinueWith => 'ou continuer avec';

  @override
  String get noAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get hasAccount => 'Vous avez déjà un compte ? ';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get logOut => 'Déconnexion';

  @override
  String get settings => 'Paramètres';

  @override
  String get dashboard => 'Tableau de Bord';

  @override
  String get milestones => 'Jalons';

  @override
  String get feeding => 'Alimentation';

  @override
  String get sleep => 'Sommeil';

  @override
  String get health => 'Santé';

  @override
  String get growth => 'Croissance';

  @override
  String get journal => 'Journal';

  @override
  String get companion => 'Compagnon IA';

  @override
  String get profile => 'Profil';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get retry => 'Réessayer';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get termsOfService => 'Conditions d\'Utilisation';

  @override
  String get ageConsent => 'Je confirme avoir au moins 18 ans';

  @override
  String get tosConsent => 'J\'accepte les Conditions d\'Utilisation';

  @override
  String get privacyConsent => 'J\'accepte la Politique de Confidentialité';

  @override
  String get dataConsent => 'Je consens au traitement des données de santé et de développement de l\'enfant';

  @override
  String get passwordStrength => 'Force du Mot de Passe';

  @override
  String get passwordRequirements => 'Au moins 8 caractères avec majuscules, minuscules et chiffres';

  @override
  String get biometricLogin => 'Connexion biométrique';

  @override
  String get medicalDisclaimer => 'Le Compagnon IA ne remplace pas un avis médical professionnel. Consultez toujours votre professionnel de santé.';

  @override
  String get emergencyDisclaimer => 'En cas d\'urgence médicale, arrêtez d\'utiliser cette application et appelez le 911 ou votre numéro d\'urgence local immédiatement.';

  @override
  String get dailyBrief => 'Résumé Quotidien';

  @override
  String get routine => 'Routine';

  @override
  String get adviceFeed => 'Conseils';

  @override
  String get chat => 'Chat';

  @override
  String get askCompanion => 'Demander au Compagnon';

  @override
  String get typeMessage => 'Tapez un message...';

  @override
  String get modelDownload => 'Téléchargement du Modèle';

  @override
  String get downloadModel => 'Télécharger le Modèle';

  @override
  String get modelRequired => 'Le Compagnon IA doit télécharger un modèle linguistique pour fournir des conseils personnalisés sur votre appareil.';

  @override
  String get downloading => 'Téléchargement en cours...';

  @override
  String get verifying => 'Vérification en cours...';

  @override
  String get complete => 'Terminé';

  @override
  String get errorDownloading => 'Erreur lors du téléchargement du modèle';

  @override
  String get retryDownload => 'Réessayer';

  @override
  String get medicalDisclaimerTitle => 'Avis Médical';

  @override
  String get iUnderstand => 'Je Comprends';

  @override
  String get achieved => 'Atteint !';

  @override
  String get milestoneAchieved => 'Jalon atteint !';

  @override
  String xpEarned(int xp) {
    return '+$xp PX';
  }

  @override
  String get noMilestones => 'Aucun jalon enregistré pour l\'instant';

  @override
  String get expectedMilestones => 'Jalons Attendus';

  @override
  String get achievedMilestones => 'Atteints';

  @override
  String get allMilestones => 'Tous';

  @override
  String get activityPrompt => 'Suggestion d\'Activité';

  @override
  String get needsEvaluation => 'Nécessite une Évaluation';

  @override
  String get selectBabyMon => 'Sélectionner BabyMon';

  @override
  String get addBabyMon => 'Ajouter BabyMon';

  @override
  String get deleteBabyMon => 'Supprimer BabyMon';

  @override
  String get deleteBabyMonConfirm => 'Cette action est irréversible. Toutes les données de ce BabyMon seront supprimées définitivement.';

  @override
  String get permanentDeletion => 'Suppression Définitive';

  @override
  String get cancelSubscription => 'Annuler l\'Abonnement';

  @override
  String get subscriptionActive => 'Actif';

  @override
  String get subscriptionCancelling => 'Annulation en Cours';

  @override
  String trialDaysLeft(int days) {
    return '$days jours restants d\'essai';
  }

  @override
  String get subscribeNow => 'S\'abonner Maintenant';

  @override
  String get manageSubscription => 'Gérer l\'Abonnement';

  @override
  String get levelUp => 'Niveau Supérieur !';

  @override
  String get phaseMilestone => 'Jalon de Phase';

  @override
  String newLevel(int level, Object name) {
    return 'Niveau $level : $name';
  }

  @override
  String get shareBabyMon => 'Partager BabyMon';

  @override
  String get exportData => 'Exporter les Données';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get visualStyle => 'Style Visuel';

  @override
  String get glass => 'Verre';

  @override
  String get clay => 'Argile';

  @override
  String get systemDefault => 'Paramètre Système';

  @override
  String get about => 'À Propos';

  @override
  String get version => 'Version';

  @override
  String get deleteAccount => 'Supprimer le Compte';

  @override
  String get deleteAccountConfirm => 'Cela supprimera définitivement votre compte et toutes les données associées.';

  @override
  String get changePassword => 'Changer le Mot de Passe';

  @override
  String get currentPassword => 'Mot de Passe Actuel';

  @override
  String get updatePassword => 'Mettre à Jour le Mot de Passe';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Notifications Push';

  @override
  String get emailNotifications => 'Notifications par E-mail';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get trackMilestone => 'Enregistrer un Jalon';

  @override
  String get addMilestone => 'Ajouter un Jalon';

  @override
  String get editMilestone => 'Modifier le Jalon';

  @override
  String get milestoneTitle => 'Titre du Jalon';

  @override
  String get milestoneDate => 'Date d\'Atteinte';

  @override
  String get milestoneNotes => 'Notes';

  @override
  String get milestoneDomain => 'Catégorie';

  @override
  String get grossMotor => 'Motricité Globale';

  @override
  String get fineMotor => 'Motricité Fine';

  @override
  String get languageComm => 'Langage et Communication';

  @override
  String get cognitive => 'Cognitif';

  @override
  String get socialEmotional => 'Social et Émotionnel';

  @override
  String get logFeed => 'Enregistrer l\'Alimentation';

  @override
  String get breastfeeding => 'Allaitement';

  @override
  String get formula => 'Lait en Poudre';

  @override
  String get solidFood => 'Aliments Solides';

  @override
  String get feedAmount => 'Quantité';

  @override
  String get feedDuration => 'Durée';

  @override
  String get feedUnit => 'Unité';

  @override
  String get oz => 'oz';

  @override
  String get ml => 'ml';

  @override
  String get logSleep => 'Enregistrer le Sommeil';

  @override
  String get sleepStart => 'Heure de Début';

  @override
  String get sleepEnd => 'Heure de Fin';

  @override
  String get nap => 'Sieste';

  @override
  String get nightSleep => 'Sommeil Nocturne';

  @override
  String get sleepQuality => 'Qualité';

  @override
  String get logHealth => 'Enregistrer une Donnée de Santé';

  @override
  String get healthCategory => 'Catégorie';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get doctorVisit => 'Visite Médicale';

  @override
  String get temperature => 'Température';

  @override
  String get weight => 'Poids';

  @override
  String get height => 'Taille';

  @override
  String get headCircumference => 'Périmètre Crânien';

  @override
  String get logGrowth => 'Enregistrer la Croissance';

  @override
  String get growthType => 'Type de Mesure';

  @override
  String get growthValue => 'Valeur';

  @override
  String get growthUnit => 'Unité';

  @override
  String get cm => 'cm';

  @override
  String get kg => 'kg';

  @override
  String get lb => 'lb';

  @override
  String get unitInches => 'po';

  @override
  String get journalEntry => 'Entrée de Journal';

  @override
  String get allEntries => 'Toutes les Entrées';

  @override
  String get filterByType => 'Filtrer par Type';

  @override
  String get pendingProposals => 'Propositions en Attente';

  @override
  String get noEntries => 'Aucune entrée pour l\'instant';

  @override
  String get photos => 'Photos';

  @override
  String get uploadPhoto => 'Télécharger une Photo';

  @override
  String get takePhoto => 'Prendre une Photo';

  @override
  String get chooseFromGallery => 'Choisir dans la Galerie';

  @override
  String get noPhotos => 'Aucune photo pour l\'instant';

  @override
  String get discover => 'Découvrir';

  @override
  String get babyMonProfile => 'Profil BabyMon';

  @override
  String get babyName => 'Nom du Bébé';

  @override
  String get birthDate => 'Date de Naissance';

  @override
  String get conceptionDate => 'Date de Conception';

  @override
  String get gender => 'Genre';

  @override
  String get bloodType => 'Groupe Sanguin';

  @override
  String get allergies => 'Allergies';

  @override
  String get addAllergy => 'Ajouter une Allergie';

  @override
  String get allergyName => 'Nom de l\'Allergie';

  @override
  String get allergySeverity => 'Gravité';

  @override
  String get allergyTriggers => 'Déclencheurs';

  @override
  String get allergyTreatment => 'Traitement';

  @override
  String get mild => 'Légère';

  @override
  String get moderate => 'Modérée';

  @override
  String get severe => 'Grave';

  @override
  String get medicalTeam => 'Équipe Médicale';

  @override
  String get addMedicalContact => 'Ajouter un Contact Médical';

  @override
  String get contactName => 'Nom';

  @override
  String get specialty => 'Spécialité';

  @override
  String get facility => 'Établissement';

  @override
  String get partners => 'Co-Parents';

  @override
  String get invitePartner => 'Inviter un Co-Parent';

  @override
  String get partnerEmail => 'E-mail du Co-Parent';

  @override
  String get sendInvite => 'Envoyer l\'Invitation';

  @override
  String get pendingInvites => 'Invitations en Attente';

  @override
  String get accepted => 'Acceptée';

  @override
  String get declined => 'Refusée';

  @override
  String get subscription => 'Abonnement';

  @override
  String get currentPlan => 'Plan Actuel';

  @override
  String get freePlan => 'Gratuit';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get trialActive => 'Essai Actif';

  @override
  String daysRemaining(Object days) {
    return '$days jours restants';
  }

  @override
  String get renewalDate => 'Date de Renouvellement';

  @override
  String get createBabyMon => 'Créer BabyMon';

  @override
  String get stageType => 'Type d\'Étape';

  @override
  String get idea => 'Juste une Idée';

  @override
  String get conceived => 'Conçu';

  @override
  String get born => 'Né';

  @override
  String get createProfile => 'Créer le Profil';

  @override
  String get welcomeToBabymon => 'Bienvenue sur BabyMon';

  @override
  String get getStarted => 'Commencer';

  @override
  String get trackYourJourney => 'Suivez votre parcours parental';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get finish => 'Terminer';

  @override
  String get album => 'Album';

  @override
  String get share => 'Partager';

  @override
  String get editProfile => 'Modifier le Profil';

  @override
  String get clearData => 'Effacer les Données';

  @override
  String get clearAllData => 'Effacer Toutes les Données';

  @override
  String get clearAllDataConfirm => 'Cela supprimera définitivement toutes les données. Cette action est irréversible.';

  @override
  String get dataCleared => 'Toutes les données ont été effacées';

  @override
  String get exportStarted => 'Exportation démarrée';

  @override
  String get exportComplete => 'Exportation terminée';

  @override
  String get noInternet => 'Pas de connexion Internet';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passé';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get close => 'Fermer';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sortBy => 'Trier Par';

  @override
  String get newest => 'Plus Récent';

  @override
  String get oldest => 'Plus Ancien';

  @override
  String get selectDate => 'Sélectionner une Date';

  @override
  String get selectTime => 'Sélectionner une Heure';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get thisWeek => 'Cette Semaine';

  @override
  String get lastWeek => 'Semaine Dernière';

  @override
  String get thisMonth => 'Ce Mois';

  @override
  String get older => 'Plus Ancien';

  @override
  String get growthChart => 'Graphique de Croissance';

  @override
  String percentile(int p) {
    return '${p}e percentile';
  }

  @override
  String get trendUp => 'Tendance à la Hausse';

  @override
  String get trendDown => 'Tendance à la Baisse';

  @override
  String get trendStable => 'Stable';

  @override
  String get comparedToWho => 'Comparé aux normes de l\'OMS';

  @override
  String get sleepSummary => 'Résumé du Sommeil';

  @override
  String get avgSleep => 'Sommeil Moyen';

  @override
  String get totalSleep => 'Sommeil Total';

  @override
  String get feedSummary => 'Résumé de l\'Alimentation';

  @override
  String get totalFeeds => 'Total des Repas';

  @override
  String get healthRecords => 'Dossiers de Santé';

  @override
  String get upcomingVaccines => 'Vaccins à Venir';

  @override
  String get dueDate => 'Échéance';

  @override
  String get completed => 'Terminé';

  @override
  String get pending => 'En Attente';

  @override
  String get verified => 'Vérifié';

  @override
  String get unverified => 'Non Vérifié';

  @override
  String get resendEmail => 'Renvoyer l\'E-mail de Vérification';

  @override
  String get checkInbox => 'Veuillez vérifier votre boîte de réception et cliquer sur le lien de vérification';

  @override
  String get emailSent => 'E-mail de vérification envoyé';

  @override
  String get biometricsPrompt => 'Authentifiez-vous pour continuer';

  @override
  String get biometricsNotAvailable => 'Biométrie non disponible';

  @override
  String get socialLoginGoogle => 'Continuer avec Google';

  @override
  String get socialLoginApple => 'Continuer avec Apple';

  @override
  String get socialLoginFacebook => 'Continuer avec Facebook';

  @override
  String get deleteConfirmation => 'Êtes-vous sûr de vouloir supprimer ceci ?';

  @override
  String get deleteWarning => 'Cette action est irréversible';

  @override
  String get noneRecorded => 'Aucun enregistrement';

  @override
  String get traits => 'Traits';

  @override
  String get specialMove => 'Mouvement Spécial';

  @override
  String get bloodGroup => 'Groupe Sanguin';

  @override
  String get mother => 'Mère';

  @override
  String get father => 'Père';

  @override
  String get contact => 'Contact';

  @override
  String get shareText => 'Partagé via BabyMon';

  @override
  String get xpProgress => 'Progression PX';

  @override
  String get currentLevel => 'Niveau Actuel';

  @override
  String get nextLevel => 'Niveau Suivant';

  @override
  String get badgesEarned => 'Badges Gagnés';

  @override
  String get noBadges => 'Aucun badge pour l\'instant';

  @override
  String get viewAll => 'Voir Tout';

  @override
  String get showMore => 'Afficher Plus';

  @override
  String get showLess => 'Afficher Moins';

  @override
  String get confirmDelete => 'Confirmer la Suppression';

  @override
  String get confirmLogout => 'Confirmer la Déconnexion';

  @override
  String get logoutMessage => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get visualStyleGlass => 'Verre';

  @override
  String get visualStyleClay => 'Argile';

  @override
  String get loginTitle => 'Bon Retour !';

  @override
  String get loginSubtitle => 'Connectez-vous pour continuer';

  @override
  String get emailRequired => 'Veuillez saisir votre e-mail';

  @override
  String get passwordRequired => 'Veuillez saisir votre mot de passe';

  @override
  String get biometricPrompt => 'Authentifiez-vous pour vous connecter à BabyMon';

  @override
  String get biometricEnableTitle => 'Activer la Connexion Biométrique';

  @override
  String get biometricEnablePrompt => 'Souhaitez-vous utiliser la biométrie pour une connexion plus rapide la prochaine fois ?';

  @override
  String get notNow => 'Pas Maintenant';

  @override
  String get enable => 'Activer';

  @override
  String get orDivider => 'OU';

  @override
  String get signUpLink => 'Inscrivez-vous';

  @override
  String get loginLink => 'Se Connecter';

  @override
  String get resetPasswordTitle => 'Réinitialiser le Mot de Passe';

  @override
  String get resetPasswordSubtitle => 'Saisissez votre adresse e-mail et nous vous enverrons un lien de réinitialisation.';

  @override
  String get sendResetLink => 'Envoyer le Lien';

  @override
  String get resetPasswordSuccess => 'Lien de réinitialisation envoyé à votre e-mail';

  @override
  String get createAccountTitle => 'Créer un Compte';

  @override
  String get createAccountSubtitle => 'Rejoignez BabyMon dès aujourd\'hui';

  @override
  String get nameOptional => 'Nom (facultatif)';

  @override
  String get passwordWeak => 'Faible';

  @override
  String get passwordFair => 'Moyenne';

  @override
  String get passwordGood => 'Bonne';

  @override
  String get passwordStrong => 'Forte';

  @override
  String get dateOfBirth => 'Date de Naissance';

  @override
  String get tapToSelect => 'Appuyez pour sélectionner';

  @override
  String get dateOfBirthHelp => 'Sélectionnez votre date de naissance';

  @override
  String get verifyEmailTitle => 'Vérifiez votre E-mail';

  @override
  String get verifyEmailSubtitle => 'Veuillez vérifier votre boîte de réception et cliquer sur le lien de vérification pour continuer.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get resendVerificationEmail => 'Renvoyer l\'E-mail de Vérification';

  @override
  String get emailSentSuccess => 'E-mail de vérification envoyé ! Vérifiez votre boîte de réception.';

  @override
  String get emailSendFailed => 'Échec de l\'envoi de l\'e-mail de vérification. Veuillez réessayer.';

  @override
  String get emailNotVerified => 'E-mail pas encore vérifié. Veuillez vérifier votre boîte de réception.';

  @override
  String get checkVerificationFailed => 'Échec de la vérification du statut.';

  @override
  String get newPasswordLabel => 'Nouveau Mot de Passe';

  @override
  String get passwordMinLength => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordResetSuccess => 'Mot de passe réinitialisé avec succès. Veuillez vous connecter.';

  @override
  String get resetPasswordSemantic => 'Réinitialiser votre mot de passe';

  @override
  String get acceptTermsPrefix => 'J\'accepte les ';

  @override
  String get termsOfServiceLink => 'Conditions d\'Utilisation';

  @override
  String get acceptPrivacyPrefix => 'J\'accepte la ';

  @override
  String get privacyPolicyLink => 'Politique de Confidentialité';

  @override
  String get iConsentToDataProcessing => 'Je consens au traitement des données de santé et de développement de l\'enfant';

  @override
  String get pleaseSelectDob => 'Veuillez sélectionner votre date de naissance';

  @override
  String get mustAcceptTos => 'Vous devez accepter les Conditions d\'Utilisation';

  @override
  String get mustAcceptPrivacy => 'Vous devez accepter la Politique de Confidentialité';

  @override
  String get mustConsentData => 'Vous devez consentir au traitement des données';

  @override
  String get togglePasswordVisibility => 'Afficher/Masquer le mot de passe';

  @override
  String get editName => 'Modifier le Nom';

  @override
  String get nameUpdated => 'Nom mis à jour !';

  @override
  String get noBabyMonToExport => 'Aucun BabyMon à exporter';

  @override
  String get exportingData => 'Exportation de vos données...';

  @override
  String get deletePermanently => 'Supprimer Définitivement';

  @override
  String get babyMonDeleted => 'BabyMon supprimé définitivement';

  @override
  String get createBabyMonFirst => 'Créez d\'abord un BabyMon';

  @override
  String get clearAllAllergies => 'Effacer toutes les allergies';

  @override
  String get clearAllAllergiesDesc => 'Supprime tous les profils d\'allergie et événements';

  @override
  String get clearAllEvents => 'Effacer tous les événements d\'allergie';

  @override
  String get clearAllEventsDesc => 'Supprime les événements mais conserve les profils d\'allergie';

  @override
  String get allergiesCleared => 'Allergies effacées';

  @override
  String get eventsCleared => 'Événements effacés';

  @override
  String get couldNotClear => 'Impossible d\'effacer. Veuillez réessayer.';

  @override
  String get noBabyMonsToDelete => 'Aucun BabyMon à supprimer';

  @override
  String get noBabyMonSelected => 'Aucun BabyMon sélectionné';

  @override
  String get logOutTitle => 'Déconnexion';

  @override
  String get logOutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get languageSetting => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la Langue';

  @override
  String get currentLanguage => 'Langue Actuelle';

  @override
  String get localeUpdated => 'Langue mise à jour';

  @override
  String get localeUpdateFailed => 'Échec de la mise à jour de la langue';

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
  String get errorInternal => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get errorDatabase => 'Une erreur de base de données s\'est produite. Veuillez réessayer.';

  @override
  String get errorValidation => 'Requête invalide. Veuillez vérifier vos informations.';

  @override
  String get errorNotFound => 'Non trouvé. Cette fonctionnalité n\'est peut-être pas encore disponible.';

  @override
  String get errorUnauthorized => 'Session expirée. Veuillez vous reconnecter.';

  @override
  String get errorInvalidToken => 'Token invalide. Veuillez vous reconnecter.';

  @override
  String get errorTokenExpired => 'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get errorUserNotFound => 'Utilisateur non trouvé.';

  @override
  String get errorAccountDeleted => 'Ce compte a été supprimé.';

  @override
  String get errorOAuthRequired => 'Veuillez utiliser la connexion sociale pour ce compte.';

  @override
  String get errorDuplicateEmail => 'Cet e-mail est déjà enregistré.';

  @override
  String get errorInvalidOperation => 'Opération invalide. Veuillez réessayer.';

  @override
  String get errorRateLimited => 'Trop de requêtes. Veuillez patienter un moment.';

  @override
  String get errorTrialExpired => 'Votre essai gratuit a expiré. Veuillez mettre à niveau.';

  @override
  String get errorLimitReached => 'Vous avez atteint la limite pour cette fonctionnalité.';

  @override
  String get errorUpgradeRequired => 'Cette fonctionnalité nécessite un abonnement Premium.';

  @override
  String get errorEmailInUse => 'E-mail déjà utilisé.';

  @override
  String get errorInvalidPassword => 'Mot de passe invalide.';

  @override
  String get errorBadRequest => 'Requête invalide. Veuillez vérifier vos informations.';

  @override
  String get errorForbidden => 'Vous n\'êtes pas autorisé à faire cela.';

  @override
  String get errorConflict => 'Cela existe déjà. Veuillez utiliser une valeur différente.';

  @override
  String get errorServer => 'Erreur serveur. Veuillez réessayer plus tard.';

  @override
  String get errorConnectionTimeout => 'Délai de connexion dépassé. Veuillez vérifier votre connexion Internet.';

  @override
  String get errorConnectionFailed => 'Impossible de se connecter au serveur.';

  @override
  String get errorNetwork => 'Erreur réseau. Veuillez vérifier votre connexion.';

  @override
  String get errorBabyMonNotFound => 'BabyMon non trouvé.';

  @override
  String get errorMilestoneNotFound => 'Jalon non trouvé.';

  @override
  String get errorFeedLogNotFound => 'Journal d\'alimentation non trouvé.';

  @override
  String get errorHealthRecordNotFound => 'Dossier de santé non trouvé.';

  @override
  String get errorInvitationNotFound => 'Invitation non trouvée.';

  @override
  String get errorCannotInviteSelf => 'Vous ne pouvez pas vous inviter vous-même.';

  @override
  String get errorInvitationAlreadyProcessed => 'L\'invitation a déjà été traitée.';

  @override
  String get errorInvitationExpired => 'L\'invitation a expiré.';

  @override
  String get errorLinkNotFound => 'Lien non trouvé.';

  @override
  String get errorPromoCodeInvalid => 'Code promotionnel invalide.';

  @override
  String get errorPromoCodeExpired => 'Ce code promotionnel a expiré.';

  @override
  String get errorPromoCodeLimitReached => 'Ce code promotionnel a atteint sa limite d\'utilisation.';

  @override
  String get errorPromoCodeAlreadyUsed => 'Vous avez déjà utilisé ce code promotionnel.';

  @override
  String get errorAppleSignInUnavailable => 'La connexion Apple n\'est pas disponible sur cet appareil.';

  @override
  String get errorAppleNoIdentityToken => 'Aucun jeton d\'identité reçu d\'Apple.';

  @override
  String get errorFacebookNoAccessToken => 'Aucun jeton d\'accès reçu de Facebook.';

  @override
  String get welcomeChooseLanguage => 'Choisissez votre langue';

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
  String get errorUnknown => 'Une erreur s\'est produite. Veuillez réessayer.';
}
