#!/usr/bin/env python3
"""Batch replace hardcoded UI strings with context.l10n.* calls."""
import glob, os

replacements = {
    # Auth
    "'Start tracking your BabyMon\\'s milestones today'": 'context.l10n.registerSubtitle',
    "'Sign in to continue tracking your BabyMon\\'s journey'": 'context.l10n.loginSubtitle',
    "'Verification Code'": 'context.l10n.verificationCodeTitle',
    "'A 6-digit code was sent to your email.'": 'context.l10n.verificationCodeSubtitle',
    "'Enter 6-digit code'": 'context.l10n.enterCode',
    "'Verifying...'": 'context.l10n.verifying',
    "'Resend'": 'context.l10n.resend',
    "'Verify'": 'context.l10n.verify',
    "'Show'": 'context.l10n.show',
    "'Hide'": 'context.l10n.hide',
    # Dashboard
    "'Welcome to BabyMon!'": 'context.l10n.welcomeToBabymon',
    "'Create your first BabyMon to start tracking milestones, feedings, and more.'": 'context.l10n.createBabyMonPrompt',
    "'Select Gender'": 'context.l10n.selectGender',
    "'Select Blood Type'": 'context.l10n.selectBloodType',
    "'Select Eye Color'": 'context.l10n.selectEyeColor',
    "'Add custom'": 'context.l10n.addCustom',
    "'Add Custom Trait'": 'context.l10n.addCustomTrait',
    "'e.g. Brave, Silly, Stubborn'": 'context.l10n.customTraitHint',
    "'Updated!'": 'context.l10n.updated',
    "'Got it!'": 'context.l10n.gotIt',
    "'Profile save failed'": 'context.l10n.profileSaveFailed',
    "'BabyMon save failed'": 'context.l10n.babyMonSaveFailed',
    # Navigation
    "'More'": 'context.l10n.more',
    "'More Features'": 'context.l10n.moreFeatures',
    "'Main'": 'context.l10n.main',
    "'Your Parenting Companion'": 'context.l10n.yourParentingCompanion',
    "'BabyMon v1.0.0'": 'context.l10n.babyMonVersion',
    "'Notifications coming soon'": 'context.l10n.notificationsComingSoon',
    "'Quick actions'": 'context.l10n.quickActions',
    "'Add Measurement'": 'context.l10n.addMeasurement',
    "'Measurement'": 'context.l10n.measurement',
    "'Add Event'": 'context.l10n.addEvent',
    "'Event'": 'context.l10n.event',
    "'Journal'": 'context.l10n.journal',
    "'Album'": 'context.l10n.album',
    "'Notifications'": 'context.l10n.notifications',
    "'Add Medical Team'": 'context.l10n.addMedicalContact',
    "'Create BabyMon'": 'context.l10n.createBabyMon',
    "'Settings'": 'context.l10n.settings',
    "'Manage Partners'": 'context.l10n.managePartners',
    "'Logout'": 'context.l10n.logoutTitle',
    # Delete confirmations
    "'This cannot be undone.'": 'context.l10n.deleteConfirmText',
    "'Delete Feed Log?'": 'context.l10n.deleteFeedLogTitle',
    "'Delete Health Record?'": 'context.l10n.deleteHealthRecordTitle',
    "'Delete Photo'": 'context.l10n.deletePhotoTitle',
    "'Remove this photo?'": 'context.l10n.removePhotoConfirm',
    "'Delete entry?'": 'context.l10n.deleteEntryTitle',
    "'Are you sure you want to logout?'": 'context.l10n.logoutMessage',
    "'Delete Milestone?'": 'context.l10n.deleteMilestoneTitle',
    # Album
    "'Start your baby album'": 'context.l10n.startAlbum',
    "'Tap + to add photos'": 'context.l10n.tapToAddPhotos',
    "'Add a photo'": 'context.l10n.addPhoto',
    "'Photo uploaded!'": 'context.l10n.photoUploaded',
    "'Photo deleted'": 'context.l10n.photoDeleted',
    "'Take a photo'": 'context.l10n.takePhotoAction',
    "'Pick from gallery'": 'context.l10n.pickFromGallery',
    "'Camera'": 'context.l10n.cameraAction',
    "'Gallery'": 'context.l10n.galleryAction',
    "'Add a photo to your album'": 'context.l10n.addPhoto',
    # Feeding
    "'Feeding log deleted'": 'context.l10n.feedingLogDeleted',
    "'Weight'": 'context.l10n.weightLabel',
    "'Piece'": 'context.l10n.pieceLabel',
    "'Notes'": 'context.l10n.milestoneNotes',
    # Sleep
    "'Sleep log deleted'": 'context.l10n.sleepLogDeleted',
    "'Still sleeping'": 'context.l10n.stillSleeping',
    "'End time'": 'context.l10n.endTime',
    "'Not set'": 'context.l10n.notSet',
    # Journal
    "'Entry deleted'": 'context.l10n.entryDeleted',
    "'Could not delete. Please try again.'": 'context.l10n.couldNotDelete',
    "'Journey Journal'": 'context.l10n.journeyJournal',
    "'Your journal is empty'": 'context.l10n.journalEmpty',
    "'Milestones, feedings, and health records you add will appear here.'": 'context.l10n.journalEmptySubtitle',
    "'Add a milestone'": 'context.l10n.addMilestoneAction',
    "'Decline'": 'context.l10n.decline',
    "'Accept'": 'context.l10n.accept',
    "'No entries yet'": 'context.l10n.noEntries',
    "'Filter by Type'": 'context.l10n.filterByType',
    # Milestones
    "'Milestone deleted'": 'context.l10n.milestoneUndone',
    "'Title'": 'context.l10n.milestoneTitle',
    # Health
    "'Deleted'": 'context.l10n.entryDeleted',
    "'Event deleted'": 'context.l10n.entryDeleted',
    "'All records'": 'context.l10n.allMilestones',
    "'Title (optional)'": 'context.l10n.titleOptional',
    "'e.g. Morning weigh-in'": 'context.l10n.noteOptionalHint',
    "'Notes (optional)'": 'context.l10n.notesOptionalLabel',
    "'Medical team member added'": 'context.l10n.medicalTeamAdded',
    "'Failed to add'": 'context.l10n.failedToAdd',
    "'Triggers'": 'context.l10n.triggers',
    "'e.g. Ingestion, Skin contact, Airborne'": 'context.l10n.triggersHint',
    "'Treatment'": 'context.l10n.treatment',
    "'e.g. EpiPen, Antihistamine, Avoidance'": 'context.l10n.treatmentHint',
    "'Allergy added!'": 'context.l10n.allergyAdded',
    "'Allergy event recorded!'": 'context.l10n.allergyEventRecorded',
    "'Failed to save. Please try again.'": 'context.l10n.failedToSave',
    "'Name / Title'": 'context.l10n.nameTitle',
    "'e.g. ER Visit'": 'context.l10n.erVisit',
    "'Annual Checkup'": 'context.l10n.annualCheckup',
    "'Attending Staff'": 'context.l10n.attendingStaff',
    "'Time'": 'context.l10n.time',
    "'Description'": 'context.l10n.description',
    "'Venue'": 'context.l10n.venue',
    "'Vaccine name'": 'context.l10n.vaccineName',
    "'Enter custom vaccine'": 'context.l10n.enterCustomVaccine',
    "'Search vaccines...'": 'context.l10n.searchVaccines',
    "'Allergy name'": 'context.l10n.allergyNameField',
    "'Enter custom allergy'": 'context.l10n.enterCustomAllergy',
    "'Search allergies...'": 'context.l10n.searchAllergies',
    "'Name'": 'context.l10n.nameLabel',
    "'Role / Phone'": 'context.l10n.contactName',
    # Growth chart
    "'e.g., 2 month checkup'": 'context.l10n.noteOptionalHint',
    "'Edit'": 'context.l10n.editProfile',
    # Companion - model download
    "'Model Update Available'": 'context.l10n.modelUpdateAvailable',
    "'A newer AI model is available. Update to get improved responses and new features.'": 'context.l10n.newerVersionAvailable',
    "'Later'": 'context.l10n.later',
    "'Update Now'": 'context.l10n.updateNow',
    "'Download AI Model'": 'context.l10n.downloadAiModel',
    "'Start Download'": 'context.l10n.startDownload',
    "'Skip for now'": 'context.l10n.skipForNow',
    "'Downloading AI model...'": 'context.l10n.downloadingAiModel',
    "'Verifying download...'": 'context.l10n.verifyingDownload',
    "'Checking file integrity'": 'context.l10n.checkingIntegrity',
    "'Download Complete!'": 'context.l10n.downloadComplete',
    "'Your AI Companion is ready.'": 'context.l10n.aiCompanionReady',
    "'Download Failed'": 'context.l10n.downloadFailed',
    "'Use Content Cards'": 'context.l10n.useContentCards',
    # Companion - settings
    "'Delete Model'": 'context.l10n.deleteModel',
    "'Delete model'": 'context.l10n.deleteModelTooltip',
    "'Basic mode'": 'context.l10n.basicMode',
    "'Content cards only, no on-device AI'": 'context.l10n.contentCardsOnly',
    "'No AI model installed'": 'context.l10n.noAiModelInstalled',
    "'Download a model below to enable on-device AI.'": 'context.l10n.downloadModelBelow',
    "'Available to Download'": 'context.l10n.availableToDownload',
    "'Active Model'": 'context.l10n.activeModel',
    "'Premium Feature'": 'context.l10n.premiumFeature',
    "'Upgrade to Premium'": 'context.l10n.upgradeToPremiumUnlock',
    "'Maybe later'": 'context.l10n.maybeLater',
    "'Quick Start'": 'context.l10n.quickStart',
    "'Better Quality'": 'context.l10n.betterQuality',
    "'PREMIUM'": 'context.l10n.premiumPlan',
    # Companion - advice/milestones
    "'Clinical Guide'": 'context.l10n.clinicalGuide',
    "'Development Guide'": 'context.l10n.developmentGuide',
    "'General Guide'": 'context.l10n.generalGuide',
    "'Call Doctor'": 'context.l10n.callDoctor',
    "'Read more'": 'context.l10n.readMore',
    "'Show less'": 'context.l10n.showLess',
    "'Was this helpful?'": 'context.l10n.wasThisHelpful',
    "'No advice cards yet'": 'context.l10n.noAdviceCards',
    "'Thinking...'": 'context.l10n.thinking',
    "'Ask BabyMon Companion...'": 'context.l10n.askCompanionHint',
    "'Send message'": 'context.l10n.sendMessage',
    "'No saved cards yet'": 'context.l10n.noSavedCards',
    # Companion - routine
    "'TODAY\\'S SCHEDULE'": 'context.l10n.todaysSchedule',
    "'BEDTIME RITUAL'": 'context.l10n.bedtimeRitual',
    "'Routine Coming Soon'": 'context.l10n.routineComingSoon',
    # Companion - tabs
    "'Today'": 'context.l10n.todayTab',
    "'Routine'": 'context.l10n.routineTab',
    "'Milestones'": 'context.l10n.milestonesTab',
    "'Advice'": 'context.l10n.adviceTab',
    "'Saved'": 'context.l10n.savedTab',
    # Partner
    "'No BabyMon found'": 'context.l10n.noBabyMonFound',
    "'Invitation sent!'": 'context.l10n.invitationSent',
    "'Partner accepted!'": 'context.l10n.partnerAccepted',
    "'Invitation declined'": 'context.l10n.invitationDeclined',
    "'Partner removed'": 'context.l10n.partnerRemoved',
    # Subscription
    "'Have a promo code?'": 'context.l10n.havePromoCode',
    "'Promo Code'": 'context.l10n.promoCodeTitle',
    "'Apply'": 'context.l10n.apply',
    "'Payment is not configured yet. Please try again later.'": 'context.l10n.paymentNotConfigured',
    "'Could not start checkout. Please try again.'": 'context.l10n.couldNotStartCheckout',
    "'Could not upgrade. Please try again.'": 'context.l10n.couldNotUpgrade',
    "'Need help? Talk to support'": 'context.l10n.needHelp',
    # Discover
    "'Discover features: Tips, community content, stage-based insights, and more!'": 'context.l10n.featureComingSoon',
    # Misc
    "'Scroll to today'": 'context.l10n.scrollToToday',
    "'Add Stage'": 'context.l10n.addStage',
    "'Keep tracking to unlock!'": 'context.l10n.keepTracking',
    "'First Name *'": 'context.l10n.firstNameRequired',
    "'Middle Name'": 'context.l10n.middleName',
    "'Last Name'": 'context.l10n.lastName',
    "'Boy'": 'context.l10n.boy',
    "'Girl'": 'context.l10n.girl',
    "'Neutral'": 'context.l10n.neutralGender',
    "'Plan'": 'context.l10n.planLabel',
    "'e.g. \"Loves bath time\", \"Funny laugh\"'": 'context.l10n.customTraitHint',
    "'e.g., Brave, Silly, Kind'": 'context.l10n.customTraitHint',
    "'Export Data'": 'context.l10n.exportData',
    "'Activity Log'": 'context.l10n.trackingTitle',
    "'Add Activity'": 'context.l10n.addActivity',
}

# Also need to add 'trackingTitle' and 'addActivity' to ARB
# These will fall back to English

files = glob.glob('**/*.dart', recursive=True)
count = 0
updated_files = set()
for f in files:
    if '.g.dart' in f or 'test' in f or 'l10n' in f or 'replace_strings.py' in f:
        continue
    with open(f, 'r', encoding='utf-8') as fp:
        content = fp.read()
    original = content
    for old, new in replacements.items():
        if old in content:
            content = content.replace(old, new)
    if content != original:
        with open(f, 'w', encoding='utf-8') as fp:
            fp.write(content)
        updated_files.add(f)
        # Count replacements
        for old in replacements:
            if old in original:
                count += 1

print(f'Updated {len(updated_files)} files with ~{count} replacements:')
for f in sorted(updated_files):
    print(f'  {f}')
