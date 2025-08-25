import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hajzi/core/localization/app_localization.dart';
import 'package:hajzi/presentation/chat/user_chat_listing_screen.dart';
import 'package:hajzi/presentation/dashboard/dashboard_screen.dart';
import 'package:hajzi/presentation/manage_reservations/bloc/manage_reservations_cubit.dart';
import 'package:hajzi/theme/font_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../client/api_manager.dart';
import '../../core/constants/constants.dart';
import '../../theme/app_colors.dart';
import '../dashboard/bloc/dashboard_cubit.dart';
import '../manage_reservations/manage_reservations_screen.dart';
import '../profile/profile_screen.dart';
import 'bloc/tab_bloc.dart';
import 'bloc/tab_event.dart';
import 'bloc/tab_state.dart';
import '../../core/services/notification_service.dart';


class MainScreen extends StatefulWidget {
  final TabItem? initialTab;

  const MainScreen({this.initialTab, Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<TabBloc>(
      create: (context) => TabBloc()
        ..add(const TabChanged(TabItem.home)),
      child: const MainScreen(),
    );
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final List<Widget> _screens;
  late DashboardCubit _dashboardCubit;
  late TabBloc _tabBloc;

  @override
  void initState() {
    super.initState();

    _screens = [
      DashboardScreen.builder(context),
      UserChatListingScreen.builder(context),
      ManageReservationsScreen.builder(context),
      ProfileScreen.builder(context),
    ];

    _dashboardCubit = context.read<DashboardCubit>();
    _tabBloc = context.read<TabBloc>();

    ApiManager.isLoggedIn();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args!=null) {
        int index = args as int;
        final tab = TabItem.values[index];
        context.read<TabBloc>().add(TabChanged(tab));

        if(index == 0) {
          _dashboardCubit.fetchCategories();
          _dashboardCubit.fetchUserOrder();
        }
      }
    });

    requestNotificationPermission();
    _initFirebaseMessaging();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.clearBadge();
    });
  }

  void _initFirebaseMessaging() async {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        NotificationService.showForegroundNotification(
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }

      _dashboardCubit.fetchUserOrder();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dashboardCubit.fetchUserOrder();
      });
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _dashboardCubit.fetchUserOrder();
    }
  }

  Future<void> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Notification permission granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('Notification permission denied');
      } else if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        print('Notification permission not determined');
      }
    }
  }

  int _tabToIndex(TabItem tab) => TabItem.values.indexOf(tab);
  TabItem _indexToTab(int index) => TabItem.values[index];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabBloc, TabState>(
      builder: (context, state) {
        final currentIndex = _tabToIndex(state.currentTab);

        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Directionality(
              textDirection: TextDirection.ltr,
              child: CustomBottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  final selectedTab = _indexToTab(index);
                  if (selectedTab != state.currentTab) {
                    context.read<TabBloc>().add(TabChanged(selectedTab));

                    if (selectedTab == TabItem.home) {
                      context.read<DashboardCubit>().fetchUserOrder();
                    } else if (selectedTab == TabItem.request) {
                      context.read<ManageReservationsCubit>().refreshOrders(true);
                    }
                  }
                },
              )),
        );
      },
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.light_gray,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 6,
        left: 8,
        right: 8,
        bottom: 6 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onTap(0),
              child: SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        width: 75,
                        height: 49,
                        decoration: currentIndex == 0 ? BoxDecoration(
                          color: AppColors.light_gray,
                          borderRadius: BorderRadius.circular(50),
                        ) : null,
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/ic_home.svg',
                              width: 22,
                              height: 22,
                              color: currentIndex == 0 ? AppColors.blue : AppColors.gray,
                            ),
                            Text('home'.tr, style: FontStyles.fontW600.copyWith(
                              fontSize: Constants.getResponsiveFontSize(context, 11),
                              color: currentIndex == 0 ? AppColors.blue : AppColors.gray,
                            ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onTap(1),
              child: SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 49,
                    width: 75,
                    decoration: currentIndex == 1
                        ? BoxDecoration(
                      color: AppColors.light_gray,
                      borderRadius: BorderRadius.circular(50),
                    ) : null,
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/ic_chat.svg',
                          width: 22,
                          height: 22,
                          color: currentIndex == 1 ? AppColors.blue : AppColors.gray,
                        ),
                        Text('chat'.tr, style: FontStyles.fontW600.copyWith(
                          fontSize: Constants.getResponsiveFontSize(context, 10),
                          color: currentIndex == 1 ? AppColors.blue : AppColors.gray,
                        ))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onTap(2),
              child: SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 49,
                    width: 75,
                    decoration: currentIndex == 2
                        ? BoxDecoration(
                      color: AppColors.light_gray,
                      borderRadius: BorderRadius.circular(50),
                    ) : null,
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/ic_request.svg',
                          width: 22,
                          height: 22,
                          color: currentIndex == 2 ? AppColors.blue : AppColors.gray,
                        ),
                        Text('manage'.tr, style: FontStyles.fontW600.copyWith(
                          fontSize: Constants.getResponsiveFontSize(context, 10),
                          color: currentIndex == 2 ? AppColors.blue : AppColors.gray,
                        ))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onTap(3),
              child: SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: currentIndex == 3
                        ? BoxDecoration(
                      color: AppColors.light_gray,
                      borderRadius: BorderRadius.circular(50),
                    ) : null,
                    height: 49,
                    width: 75,
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/ic_profile.svg',
                          width: 24,
                          height: 24,
                          color: currentIndex == 3 ? AppColors.blue : AppColors.gray,
                        ),
                        Text('profile'.tr, style: FontStyles.fontW600.copyWith(
                            fontSize: Constants.getResponsiveFontSize(context, 10),
                            color: currentIndex == 3 ? AppColors.blue : AppColors.gray
                        ))
                      ],
                    ),
                  ),
                ),
              )
            ),
          )
        ],
      ),
    );
  }
}