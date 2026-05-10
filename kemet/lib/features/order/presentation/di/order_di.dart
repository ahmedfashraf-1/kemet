import 'package:get_it/get_it.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/datasources/order_remote_datasource_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/order_usecases.dart';
import 'package:kemet/core/network/network_info.dart';
import '../../presentation/cubit/checkout_cubit.dart';

final getIt = GetIt.instance;

void setupOrderDi() {
  // Datasources
  getIt.registerSingleton<OrderRemoteDataSource>(OrderRemoteDataSourceImpl());

  // Repository
  getIt.registerSingleton<OrderRepository>(
    OrderRepositoryImpl(
      remoteDataSource: getIt<OrderRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<CreateOrderUseCase>(
    CreateOrderUseCase(getIt<OrderRepository>()),
  );

  getIt.registerSingleton<GetOrderUseCase>(
    GetOrderUseCase(getIt<OrderRepository>()),
  );

  getIt.registerSingleton<UpdateOrderPaymentStatusUseCase>(
    UpdateOrderPaymentStatusUseCase(getIt<OrderRepository>()),
  );

  getIt.registerSingleton<GetUserOrdersUseCase>(
    GetUserOrdersUseCase(getIt<OrderRepository>()),
  );

  // Cubit
  getIt.registerSingleton<CheckoutCubit>(
    CheckoutCubit(
      createOrder: getIt<CreateOrderUseCase>(),
      getOrder: getIt<GetOrderUseCase>(),
      updatePaymentStatus: getIt<UpdateOrderPaymentStatusUseCase>(),
    ),
  );
}
