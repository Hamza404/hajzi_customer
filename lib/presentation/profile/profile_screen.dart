import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/core/localization/app_localization.dart';
import 'package:hajzi/core/utils/navigator_service.dart';
import 'package:hajzi/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:hajzi/presentation/dashboard/model/order_model.dart';
import 'package:hajzi/routes/app_routes.dart';
import 'package:hajzi/theme/app_colors.dart';
import 'package:hajzi/widgets/custom_button.dart';
import '../../theme/font_styles.dart';
import '../dashboard/bloc/dashboard_cubit.dart';
import 'package:shimmer/shimmer.dart';

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

                Image.asset('assets/ic_hajzi_banner.png', fit: BoxFit.cover),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Text('Profile', style: FontStyles.fontW800.copyWith(fontSize: 36))),
                    InkWell(
                      onTap: () {

                      },
                      child: const Icon(Icons.language_outlined),
                    )
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
                      const Text(
                        "You're not authorized. Please login to continue.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 30),

                      CustomButton(title: 'Login/Signup', onPressed: () {
                        NavigatorService.pushNamed(AppRoutes.signIn).then((onValue) {
                          context.read<DashboardCubit>().getUserProfile();
                        });
                      }, backgroundColor: Colors.black, textColor: Colors.white)
                    ]
                  ),
                ) : Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.light_gray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Name', state.profileModel?.name ?? ''),
                      const SizedBox(height: 12),

                      _buildInfoRow('Phone Number', state.profileModel?.phoneNumber ?? ''),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        'Status',
                        state.profileModel?.isCompleted == true ? 'Complete' : 'Pending',
                      ),
                    ],
                  ),
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
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: FontStyles.fontW400.copyWith(
              fontSize: 14
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: FontStyles.fontW600.copyWith(
              color: Colors.black87,
                fontSize: 16
            ),
          ),
        ),
      ],
    );
  }
}