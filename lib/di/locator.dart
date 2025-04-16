import 'package:get_it/get_it.dart';
import 'package:launch/services/auth_service.dart';
import 'package:launch/services/activity_service.dart';
import 'package:launch/services/timer_service.dart';
import 'package:launch/services/storage_service.dart';
import 'package:launch/repositories/auth_repository.dart';
import 'package:launch/repositories/activity_repository.dart';
import 'package:launch/repositories/user_repository.dart';
import 'package:launch/viewmodels/auth_viewmodel.dart';
import 'package:launch/viewmodels/activity_viewmodel.dart';
import 'package:launch/viewmodels/countdown_viewmodel.dart';
import 'package:launch/viewmodels/timer_viewmodel.dart';
import 'package:launch/viewmodels/profile_viewmodel.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // 서비스 등록
  locator.registerLazySingleton<AuthService>(() => AuthServiceImpl());
  locator.registerLazySingleton<ActivityService>(() => ActivityServiceImpl());
  locator.registerLazySingleton<TimerService>(() => TimerServiceImpl());
  locator.registerLazySingleton<StorageService>(() => StorageServiceImpl());

  // 저장소 등록
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        authService: locator<AuthService>(),
        storageService: locator<StorageService>(),
      ));

  locator
      .registerLazySingleton<ActivityRepository>(() => ActivityRepositoryImpl(
            activityService: locator<ActivityService>(),
            storageService: locator<StorageService>(),
          ));

  locator.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
        authService: locator<AuthService>(),
        storageService: locator<StorageService>(),
      ));

  // 뷰모델 등록
  locator.registerFactory<AuthViewModel>(() => AuthViewModel(
        authRepository: locator<AuthRepository>(),
      ));

  locator.registerFactory<ActivityViewModel>(() => ActivityViewModel(
        activityRepository: locator<ActivityRepository>(),
      ));

  locator.registerFactory<CountdownViewModel>(() => CountdownViewModel(
        timerService: locator<TimerService>(),
      ));

  locator.registerFactory<TimerViewModel>(() => TimerViewModel(
        timerService: locator<TimerService>(),
        activityRepository: locator<ActivityRepository>(),
      ));

  locator.registerFactory<ProfileViewModel>(() => ProfileViewModel(
        userRepository: locator<UserRepository>(),
        activityRepository: locator<ActivityRepository>(),
      ));
}
