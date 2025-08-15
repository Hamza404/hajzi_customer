import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hajzi/presentation/dashboard/dashboard_screen.dart';
import 'package:hajzi/presentation/manage_reservations/bloc/manage_reservations_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();

    _screens = [
      DashboardScreen.builder(context),
      DashboardScreen.builder(context),
      ManageReservationsScreen.builder(context),
      ProfileScreen.builder(context),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args!=null) {
        int index = args as int;
        final tab = TabItem.values[index];
        context.read<TabBloc>().add(TabChanged(tab));
      }
    });

    requestNotificationPermission();
    _initFirebaseMessaging();
    
    // Clear badges when app is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.clearBadge();
    });
  }

  void _initFirebaseMessaging() async {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show local notification with badge when app is in foreground
      if (message.notification != null) {
        NotificationService.showForegroundNotification(
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }

      // Handle message data and refresh orders
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final selectedTab = _indexToTab(0);
        context.read<TabBloc>().add(TabChanged(selectedTab));

        if (selectedTab == TabItem.home) {
          context.read<DashboardCubit>().fetchUserOrder();
        }
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final selectedTab = _indexToTab(0);
        context.read<TabBloc>().add(TabChanged(selectedTab));

        if (selectedTab == TabItem.home) {
          context.read<DashboardCubit>().fetchUserOrder();
        }
      });
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final selectedTab = _indexToTab(0);
        context.read<TabBloc>().add(TabChanged(selectedTab));

        if (selectedTab == TabItem.home) {
          context.read<DashboardCubit>().fetchUserOrder();
        }
      });
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
        print('✅ Notification permission granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('❌ Notification permission denied');
      } else if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        print('❓ Notification permission not determined');
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
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              final selectedTab = _indexToTab(index);
              if (selectedTab != state.currentTab) {
                context.read<TabBloc>().add(TabChanged(selectedTab));

                if (selectedTab == TabItem.home) {
                  context.read<DashboardCubit>().fetchUserOrder();
                } else if (selectedTab == TabItem.request) {
                  context.read<ManageReservationsCubit>().refreshOrders();
                }
              }
            },
          ),
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
        top: 10,
        left: 8,
        right: 8,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onTap(0),
              child: SizedBox(
                height: 38,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 60,
                    height: 38,
                    decoration: currentIndex == 0
                        ? BoxDecoration(
                      color: AppColors.light_gray,
                      borderRadius: BorderRadius.circular(50),
                    ) : null,
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/ic_home.svg',
                          width: 24,
                          height: 24,
                          color: currentIndex == 0 ? AppColors.blue : AppColors.gray,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onTap(1),
              child: SizedBox(
                height: 38,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 38,
                    width: 60,
                    decoration: currentIndex == 1
                        ? BoxDecoration(
                      color: AppColors.light_gray,
                      borderRadius: BorderRadius.circular(50),
                    ) : null,
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/ic_chat.svg',
                      width: 24,
                      height: 24,
                      color: currentIndex == 1 ? AppColors.blue : AppColors.gray,
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
                height: 38,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 38,
                    width: 60,
                    decoration: currentIndex == 2
                        ? BoxDecoration(
                      color: AppColors.light_gray,
                      borderRadius: BorderRadius.circular(50),
                    ) : null,
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/ic_request.svg',
                      width: 24,
                      height: 24,
                      color: currentIndex == 2 ? AppColors.blue : AppColors.gray,
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
                height: 38,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: currentIndex == 3
                        ? BoxDecoration(
                      color: AppColors.light_gray,
                      borderRadius: BorderRadius.circular(50),
                    ) : null,
                    height: 38,
                    width: 60,
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/ic_profile.svg',
                      width: 24,
                      height: 24,
                      color: currentIndex == 3 ? AppColors.blue : AppColors.gray,
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