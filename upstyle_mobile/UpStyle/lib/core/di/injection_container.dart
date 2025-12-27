import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:up_style/core/config/upstyle_config.dart';
import 'package:up_style/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:up_style/features/auth/data/repositories/auth_rep_impl.dart';
import 'package:up_style/features/auth/domain/repositories/auth_repository.dart';
import 'package:up_style/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:up_style/features/auth/domain/usecases/signin_use_case.dart';
import 'package:up_style/features/auth/domain/usecases/signup_use_case.dart';
import 'package:up_style/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:up_style/features/creator/data/datasource/creators_remote_data_source.dart';
import 'package:up_style/features/creator/presentation/provider/creators_provider.dart';
import 'package:up_style/features/home/data/datasources/categories_remote_datasource.dart';
import 'package:up_style/features/home/data/repositories/categories_repository_impl.dart';
import 'package:up_style/features/home/data/repositories/statistics_rep_impl.dart';
import 'package:up_style/features/home/domain/repositories/categories_repository.dart';
import 'package:up_style/features/home/domain/repositories/statistics_repository.dart';
import 'package:up_style/features/home/domain/usecases/get_categories_use_case.dart';
import 'package:up_style/features/home/domain/usecases/get_statistics_usecase.dart';
import 'package:up_style/features/warderobe/data/datasources/items_remote_datasource.dart';
import 'package:up_style/features/warderobe/data/repositories/items_repository_impl.dart';
import 'package:up_style/features/warderobe/domain/repositories/item_repository.dart';
import 'package:up_style/features/warderobe/domain/usecases/create_item_use_case.dart';
import 'package:up_style/features/warderobe/domain/usecases/save_upcycled_item_use_case.dart';
import 'package:up_style/service/fashion_transform/fashion_clip_service.dart';
import 'package:up_style/service/fashion_transform/fashion_transform_service.dart';
import 'package:up_style/service/fashion_transform/mock_fashion_transform_service.dart';
import 'package:up_style/service/fashion_transform/real_fashion_transform_service.dart';
import 'package:up_style/service/upcycle/gemini_upcycle_service.dart';
// NEW IMPORTS

import 'package:up_style/features/chat/presentation/provider/chat_provider.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  //! Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  //! Data Sources - Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthDataSource(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  //! Data Sources - Categories
  sl.registerLazySingleton<CategoriesRemoteDataSource>(
    () => FirebaseCategoriesDataSource(
      firestore: sl(),
      auth: sl(),
    ),
  );

  //! Data Sources - Items
  sl.registerLazySingleton<ItemsRemoteDataSource>(
    () => FirebaseItemsDataSource(
      firestore: sl(),
      auth: sl(),
      storage: sl(),
    ),
  );

  //! Data Sources - Creators (NEW)
  sl.registerLazySingleton<CreatorsRemoteDataSource>(
    () => FirebaseCreatorsDataSource(
      firestore: sl(),
      auth: sl(),
    ),
  );

  //! Data Sources - Chat (NEW)
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => FirebaseChatDataSource(
      firestore: sl(),
      auth: sl(),
      storage: sl(),
    ),
  );

  //! Services
  sl.registerLazySingleton<FashionCLIPService>(
    () => FashionCLIPService(),
  );

  sl.registerLazySingleton<GeminiUpcycleService>(
    () => GeminiUpcycleService(),
  );

  sl.registerLazySingleton<FashionTransformService>(
    () {
      if (UpstyleConfig.enableUpcycling) {
        return RealFashionTransformService(geminiService: sl());
      } else {
        return MockFashionTransformService();
      }
    },
  );

  //! Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ItemsRepository>(
    () => ItemsRepositoryImpl(
      remoteDataSource: sl(),
      fashionTransformService: sl(),
    ),
  );

  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(
      categoriesRepository: sl(),
      itemsRepository: sl(),
    ),
  );

  //! Providers - Creators (NEW)
  sl.registerFactory(() => CreatorsProvider(sl()));

  //! Providers - Chat (NEW)
  sl.registerFactory(() => ChatProvider(sl()));

  //! Use Cases - Auth
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SendEmailVerificationUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => SaveUpcycledItemUseCase(sl()));

  //! Use Cases - Categories
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => InitializeDefaultCategoriesUseCase(sl()));

  //! Use Cases - Items
  sl.registerLazySingleton(() => CreateItemUseCase(sl()));
  sl.registerLazySingleton(() => GetItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetItemByIdUseCase(sl()));
  sl.registerLazySingleton(() => DeleteItemUseCase(sl()));
  sl.registerLazySingleton(() => UpcycleItemUseCase(sl()));
  sl.registerLazySingleton(() => UpstyleItemUseCase(sl()));

  //! Use Cases - Statistics
  sl.registerLazySingleton(() => GetStatisticsUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoryStatisticsUseCase(sl()));
}
