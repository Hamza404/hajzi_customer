import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/core/localization/app_localization.dart';
import 'package:hajzi/core/utils/navigator_service.dart';
import 'package:hajzi/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:hajzi/routes/app_routes.dart';
import 'package:hajzi/widgets/custom_button.dart';
import '../../client/api_manager.dart';
import '../../core/utils/pref_utils.dart';
import '../../theme/font_styles.dart';
import '../../widgets/custom_toast.dart';
import '../dashboard/bloc/dashboard_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (context) => DashboardCubit(),
      child: const ProfileScreen(),
    );
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(top: 56, left: 18, right: 18),
            child: Column(
              children: [

                Row(
                  children: [
                    Expanded(child: Text('profile'.tr, style: FontStyles.fontW800.copyWith(fontSize: 36)))
                  ],
                ),
                const SizedBox(height: 10),

                state.isProfileLoading == true ? const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ) : state.profileModel==null ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "not_authorized_message".tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 30),

                      CustomButton(title: 'login_signup'.tr, onPressed: () {
                        NavigatorService.pushNamed(AppRoutes.signIn).then((onValue) {
                          final cubit = context.read<DashboardCubit>();
                          cubit.updateFCM();
                          cubit.getUserProfile();
                        });
                      }, backgroundColor: Colors.black, textColor: Colors.white)
                    ]
                  ),
                ) : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(12)
                        ),
                        gradient: LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF2196F3)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('name'.tr, state.profileModel?.name ?? ''),
                          const SizedBox(height: 12),

                          _buildInfoRow('phone_number'.tr, state.profileModel?.phoneNumber ?? ''),
                          const SizedBox(height: 12),

                          _buildInfoRow(
                            'status'.tr,
                            state.profileModel?.isCompleted == true ? 'complete'.tr : 'pending'.tr,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildMenuItem(
                      icon: Icons.language_sharp,
                      text: "language".tr,
                      onTap: () {
                        NavigatorService.pushNamed(AppRoutes.language);
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      text: "logout".tr,
                      onTap: () async {
                        await showLogoutDialog(context);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: SizedBox(
          child: Text(
            '$label:',
            style: FontStyles.fontW400.copyWith(
                fontSize: 13, color: Colors.white
            ),
          ),
        )),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: FontStyles.fontW600.copyWith(
              color: Colors.white,
                fontSize: 16
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Future<bool> showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("logout".tr, style: FontStyles.fontW600.copyWith(fontSize: 16)),
          content: Text("logout_message".tr, style: FontStyles.fontW400.copyWith(fontSize: 14)),
          actions: [
            CustomButton(
              title: 'logout'.tr,
              onPressed: () async {

                await ApiManager.get('User/UpdateUserDeviceToken?deviceToken=null');

                final pref = PrefUtils();
                pref.clearPreferencesData();
                CustomToast.show(context, message: 'logout_successfully'.tr);

                final cubit = context.read<DashboardCubit>();
                cubit.getUserProfile();
                cubit.resetProfile();
                Navigator.of(context).pop(true);
                NavigatorService.pushNamedAndRemoveUntil(AppRoutes.mainScreen);
              },
              backgroundColor: Colors.black,
              textColor: Colors.white,
            ),
            const SizedBox(height: 10),
            CustomButton(
              title: 'cancel'.tr,
              onPressed: () async {
                Navigator.of(context).pop();
              },
              backgroundColor: Colors.grey,
              textColor: Colors.white,
            ),
          ],
        );
      },
    );
    return result == true;
  }
}