import 'package:dio/dio.dart';
import 'package:hospital_patient/core/interceptors/token_interceptor.dart';
import 'package:hospital_patient/features/auth/data/datasources/auth_datasource.dart';
import 'package:hospital_patient/features/auth/data/repositories/auth_repository.dart';
import 'package:hospital_patient/features/auth/domain/repositories/auth_repositories.dart';
import 'package:hospital_patient/features/auth/domain/usecases/delete_token_usecase.dart';
import 'package:hospital_patient/features/auth/domain/usecases/get_token_usecase.dart';
import 'package:hospital_patient/features/auth/domain/usecases/login_usecase.dart';
import 'package:hospital_patient/features/auth/domain/usecases/register_usecase.dart';
import 'package:hospital_patient/features/auth/domain/usecases/save_token_usecase.dart';
import 'package:hospital_patient/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:hospital_patient/features/auth/presentation/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:hospital_patient/features/auth/presentation/blocs/sign_in_form_bloc/sign_in_form_bloc.dart';
import 'package:hospital_patient/features/auth/presentation/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:hospital_patient/features/auth/presentation/blocs/sign_up_form_bloc/sign_up_form_bloc.dart';
import 'package:hospital_patient/injection_container.dart';

mixin AuthInjector on Injector {
  @override
  Future<void> init() async {
    await super.init();
    final dio = sl<Dio>(instanceName: globalDio);

    // blocs
    sl.registerLazySingleton(() => AuthBloc(
          saveTokenUsecase: sl(),
          getTokenUsecase: sl(),
          deleteTokenUsecase: sl(),
        ));
    sl.registerFactory(() => SignInFormBloc());
    sl.registerFactory(() => SignUpFormBloc());
    sl.registerFactory(() => SignInBloc(loginUsecase: sl()));
    sl.registerFactory(() => SignUpBloc(registerUsecase: sl()));

    // use cases
    sl.registerLazySingleton(() => LoginUsecase(repository: sl()));
    sl.registerLazySingleton(() => RegisterUsecase(repository: sl()));
    sl.registerLazySingleton(() => SaveTokenUsecase(saveHiveFieldUsecase: sl()));
    sl.registerLazySingleton(() => GetTokenUsecase(getHiveFieldUsecase: sl()));
    sl.registerLazySingleton(() => DeleteTokenUsecase(deleteHiveFieldUsecase: sl()));

    // repositories
    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(datasource: sl()));

    // data sources
    sl.registerLazySingleton<AuthDatasource>(() => AuthDatasourceImpl(dio: dio));

    dio..interceptors.add(TokenInterceptor(getTokenUsecase: sl()));
  }
}
