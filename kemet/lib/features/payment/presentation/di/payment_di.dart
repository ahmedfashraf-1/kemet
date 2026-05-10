import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../../core/network/paymob_dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/usecases/payment_usecases.dart';
import '../cubit/payment_cubit.dart';

final getIt = GetIt.instance;

void setupPaymentDi() {
  // Ensure Paymob client is available and initialised.
  getIt.registerLazySingleton<PaymobDioClient>(() {
    final client = PaymobDioClient();
    client.init();
    return client;
  });

  // Network info
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnectionChecker.instance),
  );

  // Data source
  getIt.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(client: getIt()),
  );

  // Repository
  getIt.registerLazySingleton(
    () => PaymentRepositoryImpl(
      remoteDataSource: getIt<PaymentRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => AuthenticateUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterOrderUseCase(getIt()));
  getIt.registerLazySingleton(() => GetPaymentKeyUseCase(getIt()));
  getIt.registerLazySingleton(() => PayWithWalletUseCase(getIt()));
  getIt.registerLazySingleton(() => VerifyTransactionUseCase(getIt()));

  // Cubit
  getIt.registerFactory(
    () => PaymentCubit(
      authenticate: getIt(),
      registerOrder: getIt(),
      getPaymentKey: getIt(),
      payWithWallet: getIt(),
      verifyTransaction: getIt(),
    ),
  );
}
