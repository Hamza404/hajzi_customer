import 'package:flutter/material.dart';
import 'package:hajzi/presentation/bottomnavigation/main_screen.dart';
import 'package:hajzi/presentation/payment/payment_screen.dart';
import '../presentation/auth/otp_screen.dart';
import '../presentation/auth/sign_in_screen.dart';
import '../presentation/auth/user_name_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/seachbusiness/search_business_screen.dart';
import '../presentation/businessdetail/business_detail_screen.dart';

class AppRoutes {
  static const String initialRoute = '/';
  static const String signIn = '/sign-in';
  static const String mainScreen = '/main-screen';
  static const String dashboard = '/dashboard';
  static const String searchBusiness = '/search-business';
  static const String businessDetail = '/business-detail';
  static const String payment = '/payment';
  static const String otp = '/otp';
  static const String userNameScreen = '/user-name';

  static Map<String, WidgetBuilder> routes = {
    initialRoute: (context) => MainScreen.builder(context),
    signIn: (context) => SignInScreen.builder(context),
    otp: OtpScreen.builder,
    userNameScreen: UserNameScreen.builder,
    mainScreen: (context) => MainScreen.builder(context),
    dashboard: (context) => DashboardScreen.builder(context),
    searchBusiness: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final categoryId = args?['categoryId'] as int?;
      return SearchBusinessScreen.builder(context, categoryId: categoryId);
    },
    businessDetail: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final business = args?['business'];
      final distance = args?['distance'] as double?;
      final status = args?['status'] as String?;
      return BusinessDetailScreen.builder(
        context,
        business: business,
        distance: distance,
        status: status
      );
    },
    payment: (context) => PaymentScreen.builder(context)
  };
}