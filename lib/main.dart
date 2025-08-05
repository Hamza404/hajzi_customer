import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hajzi/presentation/bottomnavigation/bloc/tab_bloc.dart';
import 'package:hajzi/presentation/dashboard/bloc/dashboard_cubit.dart';
import 'package:hajzi/presentation/manage_reservations/bloc/manage_reservations_cubit.dart';
import 'package:hajzi/routes/app_routes.dart';
import 'core/localization/app_localization.dart';
import 'core/localization/locale_cubit.dart';
import 'core/utils/navigator_service.dart';
import 'core/utils/pref_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedLang = await PrefUtils().readValue(PrefUtils.language) ?? 'en';
  final savedLocale = Locale(savedLang);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit(savedLocale),
        ),
        BlocProvider(create: (_) => TabBloc()),
        BlocProvider(create: (_) => DashboardCubit()),
        BlocProvider(create: (_) => ManageReservationsCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Locale>(
        future: AppLocalization.getSavedLocale(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return MaterialApp(
            title: '7ajzi',
            routes: AppRoutes.routes,
            navigatorKey: NavigatorService.navigatorKey,
            initialRoute: AppRoutes.initialRoute,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizationDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            locale: snapshot.data,
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            builder: (context, child) {
              return Directionality(
                textDirection: _getTextDirection(snapshot.data!.languageCode),
                child: child!,
              );
            },
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Poppins',
            ),
          );
        });
  }

  TextDirection _getTextDirection(String langCode) {
    return langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }
}