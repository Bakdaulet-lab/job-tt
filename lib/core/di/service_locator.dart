import 'package:get_it/get_it.dart';
import '../../features/todos/data/datasources/todo_remote_data_source.dart';
import '../../features/todos/data/repositories/todo_repository_impl.dart';
import '../../features/todos/domain/repositories/itodo_repository.dart';
import '../../features/todos/presentation/cubit/todos_cubit.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Data Sources
  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ITodoRepository>(
    () => TodoRepositoryImpl(remoteDataSource: sl()),
  );

  // Cubits - всегда Factory, чтобы при переходе на экран создавался новый стейт
  sl.registerFactory<TodosCubit>(
    () => TodosCubit(repository: sl()),
  );
}
