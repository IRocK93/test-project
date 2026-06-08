import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/api_client.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  final apiClient = ApiClient();
  getIt.registerSingleton<ApiClient>(apiClient);

  // Auth
  getIt.registerLazySingleton<AuthRemoteDatasource>(() => AuthRemoteDatasource(
    apiClient: getIt<ApiClient>(),
    prefs: getIt<SharedPreferences>(),
  ));
  
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    getIt<AuthRemoteDatasource>(),
  ));
}