D:\Claude Workspace\Projects\00. Test Project\apps\mobile>flutter pub get
Resolving dependencies...
Downloading packages... (3.0s)
+ _fe_analyzer_shared 93.0.0 (100.0.0 available)
+ analyzer 10.0.1 (13.0.0 available)
+ args 2.7.0
+ async 2.13.1
+ boolean_selector 2.1.2
+ build 4.0.5
+ build_config 1.3.0
+ build_daemon 4.1.1
+ build_runner 2.14.0
+ built_collection 5.1.1
+ built_value 8.12.5
+ characters 1.4.1
+ charcode 1.4.0
+ checked_yaml 2.0.4
+ cli_util 0.4.2 (0.5.0 available)
+ clock 1.1.2
+ code_assets 1.0.0
+ collection 1.19.1
+ convert 3.1.2
+ crypto 3.0.7
+ cupertino_icons 1.0.9
+ dart_style 3.1.7 (3.1.8 available)
+ dio 5.9.2
+ dio_web_adapter 2.1.2
+ drift 2.32.1
+ drift_dev 2.32.1
+ fake_async 1.3.3
+ ffi 2.2.0
+ file 7.0.1
+ fixnum 1.1.1
+ flutter 0.0.0 from sdk flutter
+ flutter_lints 3.0.2 (6.0.0 available)
+ flutter_riverpod 2.6.1 (3.3.1 available)
+ flutter_secure_storage 9.2.4 (10.0.0 available)
+ flutter_secure_storage_linux 1.2.3 (3.0.0 available)
+ flutter_secure_storage_macos 3.1.3 (4.0.0 available)
+ flutter_secure_storage_platform_interface 1.1.2 (2.0.1 available)
+ flutter_secure_storage_web 1.2.1 (2.1.0 available)
+ flutter_secure_storage_windows 3.1.2 (4.1.0 available)
+ flutter_test 0.0.0 from sdk flutter
+ flutter_web_plugins 0.0.0 from sdk flutter
+ glob 2.1.3
+ go_router 13.2.5 (17.2.2 available)
+ graphs 2.3.2
+ hooks 1.0.3
+ http_multi_server 3.2.2
+ http_parser 4.1.2
+ intl 0.18.1 (0.20.2 available)
+ io 1.0.5
+ jni 1.0.0
+ jni_flutter 1.0.1
+ js 0.6.7 (0.7.2 available)
+ json_annotation 4.11.0
+ leak_tracker 11.0.2
+ leak_tracker_flutter_testing 3.0.10
+ leak_tracker_testing 3.0.2
+ lints 3.0.0 (6.1.0 available)
+ logging 1.3.0
+ matcher 0.12.19
+ material_color_utilities 0.13.0
+ meta 1.17.0 (1.18.2 available)
+ mime 2.0.0
+ native_toolchain_c 0.17.6 (0.18.0 available)
+ objective_c 9.3.0
+ package_config 2.2.0
+ path 1.9.1
+ path_provider 2.1.5
+ path_provider_android 2.3.1
+ path_provider_foundation 2.6.0
+ path_provider_linux 2.2.1
+ path_provider_platform_interface 2.1.2
+ path_provider_windows 2.3.0
+ platform 3.1.6
+ plugin_platform_interface 2.1.8
+ pool 1.5.2
+ pub_semver 2.2.0
+ pubspec_parse 1.5.0
+ recase 4.1.0
+ record_use 0.6.0
+ riverpod 2.6.1 (3.2.1 available)
+ shared_preferences 2.5.5
+ shared_preferences_android 2.4.23
+ shared_preferences_foundation 2.5.6
+ shared_preferences_linux 2.4.1
+ shared_preferences_platform_interface 2.4.2
+ shared_preferences_web 2.4.3
+ shared_preferences_windows 2.4.1
+ shelf 1.4.2
+ shelf_web_socket 3.0.0
+ sky_engine 0.0.0 from sdk flutter
+ source_gen 4.2.2
+ source_span 1.10.2
+ sqlite3 3.3.1
+ sqlite3_flutter_libs 0.5.42 (0.6.0+eol available)
+ sqlparser 0.44.3
+ stack_trace 1.12.1
+ state_notifier 1.0.0
+ stream_channel 2.1.4
+ stream_transform 2.1.1
+ string_scanner 1.4.1
+ term_glyph 1.2.2
+ test_api 0.7.10 (0.7.11 available)
+ typed_data 1.4.0
+ uuid 4.5.3
+ vector_math 2.2.0 (2.3.0 available)
+ vm_service 15.1.0
+ watcher 1.2.1
+ web 1.1.1
+ web_socket 1.0.1
+ web_socket_channel 3.0.3
+ win32 5.15.0 (6.1.0 available)
+ xdg_directories 1.1.0
+ yaml 3.1.3
Changed 113 dependencies!
23 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.




D:\Claude Workspace\Projects\00. Test Project\apps\mobile>flutter analyze
Analyzing mobile...

  error - Target of URI doesn't exist: 'package:get_it/get_it.dart' - lib\core\di\service_locator.dart:1:8 -
         uri_does_not_exist
  error - Target of URI doesn't exist: '../features/auth/data/repositories/auth_repository_impl.dart' -
         lib\core\di\service_locator.dart:2:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../features/auth/domain/repositories/auth_repository.dart' -
         lib\core\di\service_locator.dart:3:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../features/auth/presentation/providers/auth_provider.dart' -
         lib\core\di\service_locator.dart:4:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../features/dashboard/data/repositories/dashboard_repository.dart' -
         lib\core\di\service_locator.dart:5:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../features/dashboard/presentation/providers/dashboard_provider.dart' -
         lib\core\di\service_locator.dart:6:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../features/tracking/data/repositories/activity_repository_impl.dart' -
         lib\core\di\service_locator.dart:7:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../features/tracking/domain/repositories/activity_repository.dart' -
         lib\core\di\service_locator.dart:8:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../features/tracking/presentation/providers/activity_provider.dart' -
         lib\core\di\service_locator.dart:9:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../features/profile/data/repositories/profile_repository_impl.dart' -
         lib\core\di\service_locator.dart:10:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../features/profile/domain/repositories/profile_repository.dart' -
         lib\core\di\service_locator.dart:11:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../features/profile/presentation/providers/profile_provider.dart' -
         lib\core\di\service_locator.dart:12:8 - uri_does_not_exist
  error - Undefined name 'GetIt' - lib\core\di\service_locator.dart:14:15 - undefined_identifier
  error - The name 'AuthRepository' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:18:31 - non_type_as_type_argument
  error - The function 'AuthRepositoryImpl' isn't defined - lib\core\di\service_locator.dart:18:53 - undefined_function
  error - The name 'DashboardRepository' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:19:31 - non_type_as_type_argument
  error - The function 'DashboardRepository' isn't defined - lib\core\di\service_locator.dart:19:58 - undefined_function
  error - The name 'ActivityRepository' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:20:31 - non_type_as_type_argument
  error - The function 'ActivityRepositoryImpl' isn't defined - lib\core\di\service_locator.dart:20:57 -
         undefined_function
  error - The name 'ProfileRepository' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:21:31 - non_type_as_type_argument
  error - The function 'ProfileRepositoryImpl' isn't defined - lib\core\di\service_locator.dart:21:56 -
         undefined_function
  error - The name 'AuthProvider' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:24:25 - non_type_as_type_argument
  error - The function 'AuthProvider' isn't defined - lib\core\di\service_locator.dart:24:45 - undefined_function
  error - The name 'AuthRepository' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:24:64 - non_type_as_type_argument
  error - The name 'DashboardProvider' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:25:25 - non_type_as_type_argument
  error - The function 'DashboardProvider' isn't defined - lib\core\di\service_locator.dart:25:50 - undefined_function
  error - The name 'DashboardRepository' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:25:74 - non_type_as_type_argument
  error - The name 'ActivityProvider' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:26:25 - non_type_as_type_argument
  error - The function 'ActivityProvider' isn't defined - lib\core\di\service_locator.dart:26:49 - undefined_function
  error - The name 'ActivityRepository' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:26:72 - non_type_as_type_argument
  error - The name 'ProfileProvider' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:27:25 - non_type_as_type_argument
  error - The function 'ProfileProvider' isn't defined - lib\core\di\service_locator.dart:27:48 - undefined_function
  error - The name 'ProfileRepository' isn't a type, so it can't be used as a type argument -
         lib\core\di\service_locator.dart:27:70 - non_type_as_type_argument
  error - The argument type 'CardTheme' can't be assigned to the parameter type 'CardThemeData?'.  -
         lib\core\theme\app_theme.dart:30:18 - argument_type_not_assignable
  error - The argument type 'CardTheme' can't be assigned to the parameter type 'CardThemeData?'.  -
         lib\core\theme\app_theme.dart:95:18 - argument_type_not_assignable
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\core\widgets\loading_widget.dart:24:35 - deprecated_member_use
  error - Target of URI doesn't exist: 'package:http/http.dart' -
         lib\features\auth\data\datasources\auth_remote_datasource.dart:2:8 - uri_does_not_exist
  error - The getter 'timeout' isn't defined for the type 'ApiConstants' -
         lib\features\auth\data\datasources\auth_remote_datasource.dart:30:28 - undefined_getter
  error - The getter 'timeout' isn't defined for the type 'ApiConstants' -
         lib\features\auth\data\datasources\auth_remote_datasource.dart:53:28 - undefined_getter
  error - The getter 'timeout' isn't defined for the type 'ApiConstants' -
         lib\features\auth\data\datasources\auth_remote_datasource.dart:77:28 - undefined_getter
  error - Target of URI doesn't exist: '../../../data/services/api_service.dart' -
         lib\features\dashboard\data\repositories\dashboard_repository.dart:2:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../core/constants/constants.dart' -
         lib\features\dashboard\data\repositories\dashboard_repository.dart:3:8 - uri_does_not_exist
  error - Undefined class 'ApiService' - lib\features\dashboard\data\repositories\dashboard_repository.dart:8:9 -
         undefined_class
  error - The method 'ApiService' isn't defined for the type 'DashboardRepository' -
         lib\features\dashboard\data\repositories\dashboard_repository.dart:8:34 - undefined_method
  error - Undefined name 'ApiConstants' - lib\features\dashboard\data\repositories\dashboard_repository.dart:13:54 -
         undefined_identifier
  error - Undefined name 'ApiConstants' - lib\features\dashboard\data\repositories\dashboard_repository.dart:30:40 -
         undefined_identifier
  error - Undefined name 'ApiConstants' - lib\features\dashboard\data\repositories\dashboard_repository.dart:45:40 -
         undefined_identifier
  error - Undefined name 'ApiConstants' - lib\features\dashboard\data\repositories\dashboard_repository.dart:76:50 -
         undefined_identifier
  error - Undefined name 'ApiConstants' - lib\features\dashboard\data\repositories\dashboard_repository.dart:84:50 -
         undefined_identifier
  error - Undefined name 'ApiConstants' - lib\features\dashboard\data\repositories\dashboard_repository.dart:92:50 -
         undefined_identifier
warning - Unused import: '../../domain/entities/dashboard_data.dart' -
       lib\features\dashboard\presentation\screens\dashboard_screen.dart:3:8 - unused_import
warning - Unused import: 'package:intl/intl.dart' - lib\features\dashboard\presentation\widgets\baby_mon_card.dart:2:8 -
       unused_import
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\dashboard\presentation\widgets\baby_mon_card.dart:71:68 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\dashboard\presentation\widgets\badge_showcase.dart:74:58 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\dashboard\presentation\widgets\evolution_visualizer.dart:101:60 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\dashboard\presentation\widgets\xp_progress_bar.dart:62:67 - deprecated_member_use
  error - Target of URI doesn't exist: '../../../data/services/api_service.dart' -
         lib\features\feeding\data\repositories\feeding_repository.dart:2:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../domain/entities/feed_log.dart' -
         lib\features\feeding\data\repositories\feeding_repository.dart:3:8 - uri_does_not_exist
  error - Undefined class 'ApiService' - lib\features\feeding\data\repositories\feeding_repository.dart:6:9 -
         undefined_class
  error - The method 'ApiService' isn't defined for the type 'FeedingRepository' -
         lib\features\feeding\data\repositories\feeding_repository.dart:6:27 - undefined_method
  error - The name 'FeedLog' isn't a type, so it can't be used as a type argument -
         lib\features\feeding\data\repositories\feeding_repository.dart:8:15 - non_type_as_type_argument
  error - Undefined name 'FeedLog' - lib\features\feeding\data\repositories\feeding_repository.dart:12:33 -
         undefined_identifier
  error - The name 'FeedLog' isn't a type, so it can't be used as a type argument -
         lib\features\feeding\data\repositories\feeding_repository.dart:18:10 - non_type_as_type_argument
  error - Undefined class 'FeedLog' - lib\features\feeding\data\repositories\feeding_repository.dart:18:33 -
         undefined_class
  error - Undefined name 'FeedLog' - lib\features\feeding\data\repositories\feeding_repository.dart:21:14 -
         undefined_identifier
  error - The name 'FeedLog' isn't a type, so it can't be used as a type argument -
         lib\features\feeding\data\repositories\feeding_repository.dart:27:10 - non_type_as_type_argument
  error - Undefined class 'FeedLog' - lib\features\feeding\data\repositories\feeding_repository.dart:27:33 -
         undefined_class
  error - Undefined name 'FeedLog' - lib\features\feeding\data\repositories\feeding_repository.dart:30:14 -
         undefined_identifier
  error - The argument type 'String?' can't be assigned to the parameter type 'String'.  -
         lib\features\feeding\presentation\providers\feeding_provider.dart:29:50 - argument_type_not_assignable
  error - The property 'loggedAt' can't be unconditionally accessed because the receiver can be 'null' -
         lib\features\feeding\presentation\providers\feeding_provider.dart:30:29 - unchecked_use_of_nullable_value
  error - The property 'loggedAt' can't be unconditionally accessed because the receiver can be 'null' -
         lib\features\feeding\presentation\providers\feeding_provider.dart:30:50 - unchecked_use_of_nullable_value
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\feeding\presentation\widgets\feed_log_card.dart:58:64 - deprecated_member_use
warning - Unused import: 'package:intl/intl.dart' - lib\features\feeding\presentation\widgets\feed_log_form.dart:2:8 -
       unused_import
warning - Unused import: '../providers/feeding_provider.dart' -
       lib\features\feeding\presentation\widgets\feed_log_form.dart:5:8 - unused_import
warning - The declaration '_field' isn't referenced - lib\features\feeding\presentation\widgets\feed_log_form.dart:70:10
       - unused_element
   info - 'value' is deprecated and shouldn't be used. Use initialValue instead. This will set the initial value for the
          form field. This feature was deprecated after v3.33.0-1.0.pre -
          lib\features\feeding\presentation\widgets\feed_log_form.dart:98:13 - deprecated_member_use
  error - The getter 'typeEmoji' isn't defined for the type 'FeedType' -
         lib\features\feeding\presentation\widgets\feed_log_form.dart:100:91 - undefined_getter
   info - 'value' is deprecated and shouldn't be used. Use initialValue instead. This will set the initial value for the
          form field. This feature was deprecated after v3.33.0-1.0.pre -
          lib\features\feeding\presentation\widgets\feed_log_form.dart:105:13 - deprecated_member_use
   info - 'groupValue' is deprecated and shouldn't be used. Use a RadioGroup ancestor to manage group value instead.
          This feature was deprecated after v3.32.0-0.0.pre -
          lib\features\feeding\presentation\widgets\feed_log_form.dart:126:43 - deprecated_member_use
   info - 'onChanged' is deprecated and shouldn't be used. Use RadioGroup to handle value change instead. This feature
          was deprecated after v3.32.0-0.0.pre - lib\features\feeding\presentation\widgets\feed_log_form.dart:127:19 -
          deprecated_member_use
  error - Expected to find ')' - lib\features\feeding\presentation\widgets\feed_log_form.dart:146:6 - expected_token
  error - The argument type 'String?' can't be assigned to the parameter type 'String'.  -
         lib\features\health\presentation\providers\health_provider.dart:38:58 - argument_type_not_assignable
warning - Unused import: 'package:intl/intl.dart' - lib\features\health\presentation\screens\health_screen.dart:3:8 -
       unused_import
  error - The method 'loadRecords' isn't defined for the type 'HealthNotifier' -
         lib\features\health\presentation\screens\health_screen.dart:20:62 - undefined_method
  error - The method 'loadRecords' isn't defined for the type 'HealthNotifier' -
         lib\features\health\presentation\screens\health_screen.dart:30:107 - undefined_method
  error - The method 'loadRecords' isn't defined for the type 'HealthNotifier' -
         lib\features\health\presentation\screens\health_screen.dart:40:66 - undefined_method
  error - The method 'deleteRecord' isn't defined for the type 'HealthNotifier' -
         lib\features\health\presentation\screens\health_screen.dart:44:69 - undefined_method
  error - The method 'addRecord' isn't defined for the type 'HealthNotifier' -
         lib\features\health\presentation\screens\health_screen.dart:63:53 - undefined_method
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\health\presentation\widgets\health_record_card.dart:100:22 - deprecated_member_use
   info - 'value' is deprecated and shouldn't be used. Use initialValue instead. This will set the initial value for the
          form field. This feature was deprecated after v3.33.0-1.0.pre -
          lib\features\health\presentation\widgets\health_record_form.dart:69:11 - deprecated_member_use
  error - The getter 'typeEmoji' isn't defined for the type 'HealthRecordType' -
         lib\features\health\presentation\widgets\health_record_form.dart:71:97 - undefined_getter
   info - 'value' is deprecated and shouldn't be used. Use initialValue instead. This will set the initial value for the
          form field. This feature was deprecated after v3.33.0-1.0.pre -
          lib\features\health\presentation\widgets\health_record_form.dart:76:11 - deprecated_member_use
  error - The getter 'dio' isn't defined for the type 'ApiService' -
         lib\features\journal\data\repositories\journal_repository.dart:49:42 - undefined_getter
  error - A value of type 'Null' can't be returned from the method '_getFeedDescription' because it has a return type of
         'String' - lib\features\journal\domain\entities\journal_entry.dart:126:12 - return_of_invalid_type
  error - The argument type 'String?' can't be assigned to the parameter type 'String'.  -
         lib\features\journal\presentation\providers\journal_provider.dart:38:59 - argument_type_not_assignable
  error - The argument type 'String?' can't be assigned to the parameter type 'String'.  -
         lib\features\journal\presentation\providers\journal_provider.dart:51:59 - argument_type_not_assignable
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\journal\presentation\screens\journal_screen.dart:185:40 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\journal\presentation\screens\journal_screen.dart:189:41 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\journal\presentation\screens\journal_screen.dart:193:40 - deprecated_member_use
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\journal\presentation\screens\journal_screen.dart:197:39 - deprecated_member_use
warning - Unused import: '../../../../core/constants/constants.dart' -
       lib\features\milestones\data\repositories\milestones_repository.dart:3:8 - unused_import
  error - The argument type 'String?' can't be assigned to the parameter type 'String'.  -
         lib\features\milestones\presentation\providers\milestones_provider.dart:39:58 - argument_type_not_assignable
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\milestones\presentation\widgets\milestone_card.dart:47:64 - deprecated_member_use
   info - 'value' is deprecated and shouldn't be used. Use initialValue instead. This will set the initial value for the
          form field. This feature was deprecated after v3.33.0-1.0.pre -
          lib\features\milestones\presentation\widgets\milestone_form.dart:87:17 - deprecated_member_use
  error - Target of URI doesn't exist: '../../../core/services/local_storage_service.dart' -
         lib\features\profile\data\repositories\profile_repository_impl.dart:2:8 - uri_does_not_exist
  error - Classes and mixins can only implement other classes and mixins -
         lib\features\profile\data\repositories\profile_repository_impl.dart:4:40 - implements_non_class
warning - The method doesn't override an inherited method -
       lib\features\profile\data\repositories\profile_repository_impl.dart:9:23 - override_on_non_overriding_member
  error - Undefined name 'LocalStorageService' -
         lib\features\profile\data\repositories\profile_repository_impl.dart:10:24 - undefined_identifier
  error - The method 'jsonDecode' isn't defined for the type 'ProfileRepositoryImpl' -
         lib\features\profile\data\repositories\profile_repository_impl.dart:16:23 - undefined_method
warning - The method doesn't override an inherited method -
       lib\features\profile\data\repositories\profile_repository_impl.dart:24:16 - override_on_non_overriding_member
  error - Undefined name 'LocalStorageService' -
         lib\features\profile\data\repositories\profile_repository_impl.dart:25:11 - undefined_identifier
  error - The method 'jsonEncode' isn't defined for the type 'ProfileRepositoryImpl' -
         lib\features\profile\data\repositories\profile_repository_impl.dart:25:54 - undefined_method
warning - The method doesn't override an inherited method -
       lib\features\profile\data\repositories\profile_repository_impl.dart:29:16 - override_on_non_overriding_member
  error - Undefined name 'LocalStorageService' -
         lib\features\profile\data\repositories\profile_repository_impl.dart:30:11 - undefined_identifier
  error - The method 'jsonEncode' isn't defined for the type 'ProfileRepositoryImpl' -
         lib\features\profile\data\repositories\profile_repository_impl.dart:30:55 - undefined_method
  error - Target of URI doesn't exist: '../../../constants/app_colors.dart' -
         lib\features\profile\presentation\providers\profile_provider.dart:2:8 - uri_does_not_exist
  error - Target of URI doesn't exist: 'package:provider/provider.dart' -
         lib\features\profile\presentation\screens\profile_screen.dart:2:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../constants/app_colors.dart' -
         lib\features\profile\presentation\screens\profile_screen.dart:3:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../widgets/custom_button.dart' -
         lib\features\profile\presentation\screens\profile_screen.dart:4:8 - uri_does_not_exist
  error - The method 'read' isn't defined for the type 'BuildContext' -
         lib\features\profile\presentation\screens\profile_screen.dart:22:15 - undefined_method
  error - The method 'Consumer' isn't defined for the type '_ProfileScreenState' -
         lib\features\profile\presentation\screens\profile_screen.dart:38:13 - undefined_method
  error - The method 'CustomButton' isn't defined for the type '_ProfileScreenState' -
         lib\features\profile\presentation\screens\profile_screen.dart:57:17 - undefined_method
  error - Target of URI doesn't exist: 'package:provider/provider.dart' -
         lib\features\profile\presentation\widgets\achievements_section.dart:2:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../constants/app_colors.dart' -
         lib\features\profile\presentation\widgets\achievements_section.dart:3:8 - uri_does_not_exist
  error - The method 'watch' isn't defined for the type 'BuildContext' -
         lib\features\profile\presentation\widgets\achievements_section.dart:11:29 - undefined_method
  error - The name 'ProfileProvider' isn't a type, so it can't be used as a type argument -
         lib\features\profile\presentation\widgets\achievements_section.dart:11:35 - non_type_as_type_argument
  error - Undefined name 'AppColors' - lib\features\profile\presentation\widgets\achievements_section.dart:83:21 -
         undefined_identifier
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\profile\presentation\widgets\achievements_section.dart:84:33 - deprecated_member_use
  error - Undefined name 'AppColors' - lib\features\profile\presentation\widgets\achievements_section.dart:90:21 -
         undefined_identifier
  error - Invalid constant value - lib\features\profile\presentation\widgets\achievements_section.dart:114:55 -
         invalid_constant
  error - Undefined name 'AppColors' - lib\features\profile\presentation\widgets\achievements_section.dart:114:55 -
         undefined_identifier
  error - Invalid constant value - lib\features\profile\presentation\widgets\achievements_section.dart:124:25 -
         invalid_constant
  error - Undefined name 'AppColors' - lib\features\profile\presentation\widgets\achievements_section.dart:124:25 -
         undefined_identifier
  error - Target of URI doesn't exist: 'package:provider/provider.dart' -
         lib\features\profile\presentation\widgets\baby_info_card.dart:2:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../constants/app_colors.dart' -
         lib\features\profile\presentation\widgets\baby_info_card.dart:3:8 - uri_does_not_exist
  error - The method 'watch' isn't defined for the type 'BuildContext' -
         lib\features\profile\presentation\widgets\baby_info_card.dart:11:29 - undefined_method
  error - The name 'ProfileProvider' isn't a type, so it can't be used as a type argument -
         lib\features\profile\presentation\widgets\baby_info_card.dart:11:35 - non_type_as_type_argument
  error - Undefined name 'AppColors' - lib\features\profile\presentation\widgets\baby_info_card.dart:111:37 -
         undefined_identifier
  error - Target of URI doesn't exist: 'package:provider/provider.dart' -
         lib\features\profile\presentation\widgets\profile_header.dart:2:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../constants/app_colors.dart' -
         lib\features\profile\presentation\widgets\profile_header.dart:3:8 - uri_does_not_exist
  error - The method 'watch' isn't defined for the type 'BuildContext' -
         lib\features\profile\presentation\widgets\profile_header.dart:11:29 - undefined_method
  error - Undefined name 'AppColors' - lib\features\profile\presentation\widgets\profile_header.dart:22:32 -
         undefined_identifier
  error - Invalid constant value - lib\features\profile\presentation\widgets\profile_header.dart:32:63 -
         invalid_constant
  error - Undefined name 'AppColors' - lib\features\profile\presentation\widgets\profile_header.dart:32:63 -
         undefined_identifier
  error - Undefined name 'AppColors' - lib\features\profile\presentation\widgets\profile_header.dart:50:30 -
         undefined_identifier
  error - Undefined name 'AppColors' - lib\features\profile\presentation\widgets\profile_header.dart:57:30 -
         undefined_identifier
  error - Invalid constant value - lib\features\profile\presentation\widgets\profile_header.dart:63:32 -
         invalid_constant
  error - Undefined name 'AppColors' - lib\features\profile\presentation\widgets\profile_header.dart:63:32 -
         undefined_identifier
  error - Target of URI doesn't exist: '../../../core/services/local_storage_service.dart' -
         lib\features\tracking\data\repositories\activity_repository_impl.dart:4:8 - uri_does_not_exist
  error - The final variable 'activities' can only be set once -
         lib\features\tracking\data\repositories\activity_repository_impl.dart:14:7 - assignment_to_final_local
  error - Undefined name 'LocalStorageService' -
         lib\features\tracking\data\repositories\activity_repository_impl.dart:53:24 - undefined_identifier
  error - Undefined name 'LocalStorageService' -
         lib\features\tracking\data\repositories\activity_repository_impl.dart:63:7 - undefined_identifier
  error - Undefined name 'LocalStorageService' -
         lib\features\tracking\data\repositories\activity_repository_impl.dart:70:11 - undefined_identifier
  error - Target of URI doesn't exist: 'package:provider/provider.dart' -
         lib\features\tracking\presentation\screens\tracking_screen.dart:2:8 - uri_does_not_exist
  error - The method 'read' isn't defined for the type 'BuildContext' -
         lib\features\tracking\presentation\screens\tracking_screen.dart:21:15 - undefined_method
  error - The method 'Consumer' isn't defined for the type '_TrackingScreenState' -
         lib\features\tracking\presentation\screens\tracking_screen.dart:53:13 - undefined_method
  error - The method 'read' isn't defined for the type 'BuildContext' -
         lib\features\tracking\presentation\screens\tracking_screen.dart:97:31 - undefined_method
  error - The method 'read' isn't defined for the type 'BuildContext' -
         lib\features\tracking\presentation\screens\tracking_screen.dart:100:19 - undefined_method
  error - Target of URI doesn't exist: '../../../constants/app_colors.dart' -
         lib\features\tracking\presentation\widgets\activity_card.dart:2:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../utils/date_utils.dart' -
         lib\features\tracking\presentation\widgets\activity_card.dart:3:8 - uri_does_not_exist
  error - Undefined name 'AppColors' - lib\features\tracking\presentation\widgets\activity_card.dart:22:16 -
         undefined_identifier
  error - Undefined name 'AppDateUtils' - lib\features\tracking\presentation\widgets\activity_card.dart:41:17 -
         undefined_identifier
  error - Undefined name 'AppColors' - lib\features\tracking\presentation\widgets\activity_card.dart:49:22 -
         undefined_identifier
  error - Invalid constant value - lib\features\tracking\presentation\widgets\activity_card.dart:55:24 -
         invalid_constant
  error - Undefined name 'AppColors' - lib\features\tracking\presentation\widgets\activity_card.dart:55:24 -
         undefined_identifier
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\features\tracking\presentation\widgets\activity_card.dart:87:22 - deprecated_member_use
  error - Target of URI doesn't exist: '../../../constants/app_colors.dart' -
         lib\features\tracking\presentation\widgets\activity_type_selector.dart:2:8 - uri_does_not_exist
  error - Undefined name 'AppColors' - lib\features\tracking\presentation\widgets\activity_type_selector.dart:40:24 -
         undefined_identifier
  error - Undefined name 'AppColors' - lib\features\tracking\presentation\widgets\activity_type_selector.dart:41:25 -
         undefined_identifier
  error - Target of URI doesn't exist: 'package:provider/provider.dart' -
         lib\features\tracking\presentation\widgets\add_activity_sheet.dart:2:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../constants/app_colors.dart' -
         lib\features\tracking\presentation\widgets\add_activity_sheet.dart:3:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../widgets/custom_button.dart' -
         lib\features\tracking\presentation\widgets\add_activity_sheet.dart:4:8 - uri_does_not_exist
  error - The method 'Consumer' isn't defined for the type '_AddActivitySheetState' -
         lib\features\tracking\presentation\widgets\add_activity_sheet.dart:68:13 - undefined_method
  error - The method 'CustomButton' isn't defined for the type '_AddActivitySheetState' -
         lib\features\tracking\presentation\widgets\add_activity_sheet.dart:69:50 - undefined_method
  error - The method 'read' isn't defined for the type 'BuildContext' -
         lib\features\tracking\presentation\widgets\add_activity_sheet.dart:189:30 - undefined_method
  error - Invalid constant value - lib\features\tracking\presentation\widgets\add_activity_sheet.dart:197:28 -
         invalid_constant
  error - Undefined name 'AppColors' - lib\features\tracking\presentation\widgets\add_activity_sheet.dart:197:28 -
         undefined_identifier
  error - Undefined name 'sharedPreferencesProvider' - lib\main.dart:16:9 - undefined_identifier
warning - Unused import: 'package:flutter/material.dart' - lib\presentation\router\app_router.dart:1:8 - unused_import
  error - Target of URI doesn't exist: '../providers/auth_provider.dart' -
         lib\presentation\screens\auth\login_screen.dart:4:8 - uri_does_not_exist
  error - Undefined name 'authProvider' - lib\presentation\screens\auth\login_screen.dart:27:22 - undefined_identifier
  error - Undefined name 'authProvider' - lib\presentation\screens\auth\login_screen.dart:31:20 - undefined_identifier
  error - Undefined name 'authProvider' - lib\presentation\screens\auth\login_screen.dart:39:33 - undefined_identifier
  error - Target of URI doesn't exist: '../providers/auth_provider.dart' -
         lib\presentation\screens\auth\register_screen.dart:4:8 - uri_does_not_exist
  error - Undefined name 'authProvider' - lib\presentation\screens\auth\register_screen.dart:29:22 -
         undefined_identifier
  error - Undefined name 'authProvider' - lib\presentation\screens\auth\register_screen.dart:34:20 -
         undefined_identifier
  error - Undefined name 'authProvider' - lib\presentation\screens\auth\register_screen.dart:42:33 -
         undefined_identifier
  error - Target of URI doesn't exist: '../../../data/services/api_service.dart' -
         lib\presentation\screens\main\dashboard\dashboard_screen.dart:4:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../core/constants/constants.dart' -
         lib\presentation\screens\main\dashboard\dashboard_screen.dart:5:8 - uri_does_not_exist
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\dashboard\dashboard_screen.dart:8:20 -
         undefined_function
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\dashboard\dashboard_screen.dart:10:26
         - undefined_function
  error - Undefined name 'ApiConstants' - lib\presentation\screens\main\dashboard\dashboard_screen.dart:10:46 -
         undefined_identifier
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\dashboard\dashboard_screen.dart:15:20
         - undefined_function
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\dashboard\dashboard_screen.dart:18:28
         - undefined_function
  error - Undefined name 'ApiConstants' - lib\presentation\screens\main\dashboard\dashboard_screen.dart:18:48 -
         undefined_identifier
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\dashboard\dashboard_screen.dart:27:28
         - undefined_function
  error - Undefined name 'ApiConstants' - lib\presentation\screens\main\dashboard\dashboard_screen.dart:27:45 -
         undefined_identifier
  error - The operator '[]' isn't defined for the type 'Object' -
         lib\presentation\screens\main\dashboard\dashboard_screen.dart:64:41 - undefined_operator
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\presentation\screens\main\dashboard\dashboard_screen.dart:106:84 - deprecated_member_use
  error - The operator '[]' isn't defined for the type 'Object' -
         lib\presentation\screens\main\dashboard\dashboard_screen.dart:110:39 - undefined_operator
  error - The operator '[]' isn't defined for the type 'Object' -
         lib\presentation\screens\main\dashboard\dashboard_screen.dart:112:42 - undefined_operator
  error - The operator '[]' isn't defined for the type 'Object' -
         lib\presentation\screens\main\dashboard\dashboard_screen.dart:112:71 - undefined_operator
  error - The operator '[]' isn't defined for the type 'Object' -
         lib\presentation\screens\main\dashboard\dashboard_screen.dart:129:39 - undefined_operator
  error - The operator '[]' isn't defined for the type 'Object' -
         lib\presentation\screens\main\dashboard\dashboard_screen.dart:130:47 - undefined_operator
  error - The operator '[]' isn't defined for the type 'Object' -
         lib\presentation\screens\main\dashboard\dashboard_screen.dart:131:47 - undefined_operator
  error - The operator '[]' isn't defined for the type 'Object' -
         lib\presentation\screens\main\dashboard\dashboard_screen.dart:132:43 - undefined_operator
  error - The operator '[]' isn't defined for the type 'Object' -
         lib\presentation\screens\main\dashboard\dashboard_screen.dart:199:41 - undefined_operator
  error - Target of URI doesn't exist: '../../../data/services/api_service.dart' -
         lib\presentation\screens\main\feeding\feeding_screen.dart:4:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../core/constants/constants.dart' -
         lib\presentation\screens\main\feeding\feeding_screen.dart:5:8 - uri_does_not_exist
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\feeding\feeding_screen.dart:8:20 -
         undefined_function
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\feeding\feeding_screen.dart:10:26 -
         undefined_function
  error - Undefined name 'ApiConstants' - lib\presentation\screens\main\feeding\feeding_screen.dart:10:46 -
         undefined_identifier
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\presentation\screens\main\feeding\feeding_screen.dart:50:80 - deprecated_member_use
  error - The method 'ApiService' isn't defined for the type 'FeedingScreen' -
         lib\presentation\screens\main\feeding\feeding_screen.dart:120:45 - undefined_method
  error - The method 'ApiService' isn't defined for the type 'FeedingScreen' -
         lib\presentation\screens\main\feeding\feeding_screen.dart:121:27 - undefined_method
  error - Undefined name 'ApiConstants' - lib\presentation\screens\main\feeding\feeding_screen.dart:121:48 -
         undefined_identifier
  error - Target of URI doesn't exist: '../../../data/services/api_service.dart' -
         lib\presentation\screens\main\health\health_screen.dart:4:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../core/constants/constants.dart' -
         lib\presentation\screens\main\health\health_screen.dart:5:8 - uri_does_not_exist
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\health\health_screen.dart:8:20 -
         undefined_function
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\health\health_screen.dart:10:26 -
         undefined_function
  error - Undefined name 'ApiConstants' - lib\presentation\screens\main\health\health_screen.dart:10:46 -
         undefined_identifier
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\presentation\screens\main\health\health_screen.dart:50:53 - deprecated_member_use
  error - The method 'ApiService' isn't defined for the type 'HealthScreen' -
         lib\presentation\screens\main\health\health_screen.dart:119:45 - undefined_method
  error - The method 'ApiService' isn't defined for the type 'HealthScreen' -
         lib\presentation\screens\main\health\health_screen.dart:120:27 - undefined_method
  error - Undefined name 'ApiConstants' - lib\presentation\screens\main\health\health_screen.dart:120:48 -
         undefined_identifier
  error - Target of URI doesn't exist: '../../../data/services/api_service.dart' -
         lib\presentation\screens\main\journal\journal_screen.dart:4:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../core/constants/constants.dart' -
         lib\presentation\screens\main\journal\journal_screen.dart:5:8 - uri_does_not_exist
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\journal\journal_screen.dart:8:20 -
         undefined_function
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\journal\journal_screen.dart:10:26 -
         undefined_function
  error - Undefined name 'ApiConstants' - lib\presentation\screens\main\journal\journal_screen.dart:10:47 -
         undefined_identifier
  error - The operator '[]' isn't defined for the type 'Object' -
         lib\presentation\screens\main\journal\journal_screen.dart:29:34 - undefined_operator
  error - The operator '[]' isn't defined for the type 'Object' -
         lib\presentation\screens\main\journal\journal_screen.dart:30:36 - undefined_operator
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\presentation\screens\main\journal\journal_screen.dart:101:68 - deprecated_member_use
  error - Target of URI doesn't exist: '../dashboard/dashboard_screen.dart' -
         lib\presentation\screens\main\main_screen.dart:3:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../milestones/milestones_screen.dart' -
         lib\presentation\screens\main\main_screen.dart:4:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../feeding/feeding_screen.dart' -
         lib\presentation\screens\main\main_screen.dart:5:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../health/health_screen.dart' -
         lib\presentation\screens\main\main_screen.dart:6:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../journal/journal_screen.dart' -
         lib\presentation\screens\main\main_screen.dart:7:8 - uri_does_not_exist
  error - The name 'DashboardScreen' isn't a class - lib\presentation\screens\main\main_screen.dart:20:11 -
         creation_with_non_type
  error - The name 'MilestonesScreen' isn't a class - lib\presentation\screens\main\main_screen.dart:21:11 -
         creation_with_non_type
  error - The name 'FeedingScreen' isn't a class - lib\presentation\screens\main\main_screen.dart:22:11 -
         creation_with_non_type
  error - The name 'HealthScreen' isn't a class - lib\presentation\screens\main\main_screen.dart:23:11 -
         creation_with_non_type
  error - The name 'JournalScreen' isn't a class - lib\presentation\screens\main\main_screen.dart:24:11 -
         creation_with_non_type
  error - Target of URI doesn't exist: '../../../data/services/api_service.dart' -
         lib\presentation\screens\main\milestones\milestones_screen.dart:4:8 - uri_does_not_exist
  error - Target of URI doesn't exist: '../../../core/constants/constants.dart' -
         lib\presentation\screens\main\milestones\milestones_screen.dart:5:8 - uri_does_not_exist
  error - The function 'ApiService' isn't defined - lib\presentation\screens\main\milestones\milestones_screen.dart:8:20
         - undefined_function
  error - The function 'ApiService' isn't defined -
         lib\presentation\screens\main\milestones\milestones_screen.dart:10:26 - undefined_function
  error - Undefined name 'ApiConstants' - lib\presentation\screens\main\milestones\milestones_screen.dart:10:46 -
         undefined_identifier
   info - 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss -
          lib\presentation\screens\main\milestones\milestones_screen.dart:50:78 - deprecated_member_use
  error - The method 'ApiService' isn't defined for the type 'MilestonesScreen' -
         lib\presentation\screens\main\milestones\milestones_screen.dart:108:45 - undefined_method
  error - The method 'ApiService' isn't defined for the type 'MilestonesScreen' -
         lib\presentation\screens\main\milestones\milestones_screen.dart:109:27 - undefined_method
  error - Undefined name 'ApiConstants' - lib\presentation\screens\main\milestones\milestones_screen.dart:109:48 -
         undefined_identifier
  error - Target of URI doesn't exist: '../../data/services/api_service.dart' -
         lib\presentation\screens\onboarding\create_baby_mon_screen.dart:5:8 - uri_does_not_exist
  error - The method 'ApiService' isn't defined for the type '_CreateBabyMonScreenState' -
         lib\presentation\screens\onboarding\create_baby_mon_screen.dart:63:30 - undefined_method
  error - The method 'ApiService' isn't defined for the type '_CreateBabyMonScreenState' -
         lib\presentation\screens\onboarding\create_baby_mon_screen.dart:64:13 - undefined_method
  error - Target of URI doesn't exist: '../providers/auth_provider.dart' -
         lib\presentation\screens\splash\splash_screen.dart:4:8 - uri_does_not_exist
  error - Undefined name 'authProvider' - lib\presentation\screens\splash\splash_screen.dart:22:35 -
         undefined_identifier

257 issues found. (ran in 8.5s)



D:\Claude Workspace\Projects\00. Test Project\apps\mobile>flutter devices
Found 3 connected devices:
  Windows (desktop) • windows • windows-x64    • Microsoft Windows [Version 10.0.26200.8246]
  Chrome (web)      • chrome  • web-javascript • Google Chrome 147.0.7727.117
  Edge (web)        • edge    • web-javascript • Microsoft Edge 147.0.3912.72

Run "flutter emulators" to list and start any available device emulators.