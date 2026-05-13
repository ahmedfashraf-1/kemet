import 'package:get_it/get_it.dart';

import '../../../../core/network/paymob_dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/payment_usecases.dart';
import '../cubit/payment_cubit.dart';

final getIt = GetIt.instance;

void setupPaymentDi() {

  // Ensure Paymob client is available and initialised
  getIt.registerLazySingleton<PaymobDioClient>(() {
    final client = PaymobDioClient();
    client.init();
    return client;
  });

  // Data source
  getIt.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(client: getIt()),
  );

  // Repository , NetworkInfo is already registered in main
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      remoteDataSource: getIt<PaymentRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<AuthenticateUseCase>(
    () => AuthenticateUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<RegisterOrderUseCase>(
    () => RegisterOrderUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<GetPaymentKeyUseCase>(
    () => GetPaymentKeyUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<PayWithWalletUseCase>(
    () => PayWithWalletUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<VerifyTransactionUseCase>(
    () => VerifyTransactionUseCase(getIt<PaymentRepository>()),
  );

  // Cubit
  getIt.registerSingleton<PaymentCubit>(
    PaymentCubit(
      authenticate: getIt<AuthenticateUseCase>(),
      registerOrder: getIt<RegisterOrderUseCase>(),
      getPaymentKey: getIt<GetPaymentKeyUseCase>(),
      payWithWallet: getIt<PayWithWalletUseCase>(),
      verifyTransaction: getIt<VerifyTransactionUseCase>(),
    ),
  );
}
