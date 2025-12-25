import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_service_wallet/core/services/local_storage_service.dart';
import 'package:smart_service_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:smart_service_wallet/features/services/presentation/bloc/services_bloc.dart';
import 'package:smart_service_wallet/features/rewards/presentation/bloc/rewards_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Services
  sl.registerLazySingleton(() => LocalStorageService(sl()));

  // Features - Blocs
  sl.registerLazySingleton(() => WalletBloc(storage: sl()));
  sl.registerLazySingleton(() => ServicesBloc(walletBloc: sl(), storage: sl()));
  sl.registerLazySingleton(() => RewardsBloc(storage: sl(), walletBloc: sl()));

  // Data sources
  // sl.registerLazySingleton(() => MockDataSource());

  // Repositories
  // sl.registerLazySingleton(() => Repository(dataSource: sl()));
}
