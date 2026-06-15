/// Core Widgets Barrel
///
/// Import all reusable widgets from a single location:
/// ```dart
/// import 'package:baby_mon/core/widgets/widgets.dart';
/// ```
///
/// Instead of importing individual files:
/// ```dart
/// import 'package:baby_mon/core/widgets/premium_card.dart';
/// import 'package:baby_mon/core/widgets/button_loading.dart';
/// ```
library;

// ── Animation ──
export 'animated_entry.dart'
    show StaggeredFadeSlide, ScrollStagger, ScalePress;
export 'fade_scale_in.dart' show FadeScaleIn;
export 'morphing_hamburger.dart' show MorphingHamburger;

// ── Buttons ──
export 'button_loading.dart' show ButtonLoading;
export 'custom_button.dart' show CustomButton;
export 'theme_button.dart' show ThemeButton, ThemeButtonVariant, ThemeButtonStyle, themedInkWell, themedGestureDetector;

// ── Loading ──
export 'loading_widget.dart' show LoadingWidget;
export 'premium_loading.dart' show PremiumLoading;

// ── Text ──
export 'theme_text.dart' show ThemeText;

export 'premium_background.dart' show PremiumBackground;

// ── Premium Components ──
export 'premium_card.dart' show PremiumCard, BentoVariant;
export 'premium_double_bezel.dart' show PremiumDoubleBezel;
export 'premium_empty_state.dart' show PremiumEmptyState;
export 'premium_progress_bar.dart' show PremiumProgressBar;
export 'premium_section.dart' show PremiumSection;
export 'premium_stat_card.dart' show PremiumStatCard;

// ── Media ──
export 'photo_grid.dart' show PhotoGridItem, PhotoMonthSection;
export 'photo_viewer.dart' show PhotoViewerPage;

// ── FAB ──
export 'info_fab.dart' show InfoFab, InfoFabAction;

// ── Layout ──
export 'screen_header.dart' show ScreenHeader;
export 'scroll_aware.dart' show ScrollAware;
export 'sliver_fill_centered.dart' show SliverFillCentered;

// ── Settings ──
export 'identity_card.dart' show IdentityCard;
export 'settings_row.dart' show SettingsRow;
export 'settings_section_header.dart' show SettingsSectionHeader;

// ── Subscription ──
export 'plan_card.dart' show PlanCard;
export 'feature_comparison_row.dart' show FeatureComparisonRow;

// ── Journal ──
export 'date_group_header.dart' show DateGroupHeader;
export 'journal_entry_row.dart' show JournalEntryRow;
export 'journal_entry_type.dart' show JournalEntryType;
export 'pending_approval_banner.dart' show PendingApprovalBanner;

// ── Dashboard ──
export 'stage_hero.dart' show StageHero;

// ── Health ──
export 'health_record_row.dart' show HealthRecordRow;

// ── Milestones ──
export 'milestone_timeline_row.dart' show MilestoneTimelineRow;

// ── Dialogs ──
export 'confirm_delete_dialog.dart' show ConfirmDeleteDialog;

// ── Pickers ──
export 'wheel_picker.dart' show WheelPickerBottomSheet, WheelColumn, WheelOption;
