import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/client/api_manager.dart';
import 'package:hajzi/routes/app_routes.dart';
import 'package:hajzi/widgets/custom_button.dart';
import '../../core/utils/navigator_service.dart';
import 'bloc/business_detail_cubit.dart';
import '../seachbusiness/model/business_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/font_styles.dart';
import 'bloc/business_detail_state.dart';

class BusinessDetailScreen extends StatefulWidget {
  final BusinessModel business;
  final double? distance;
  final String? status;

  const BusinessDetailScreen({
    Key? key,
    required this.business,
    this.distance,
    this.status,
  }) : super(key: key);

  static Widget builder(BuildContext context, {required BusinessModel business, double? distance, String? status}) {
    return BlocProvider<BusinessDetailCubit>(
      create: (context) => BusinessDetailCubit(business: business),
      child: BusinessDetailScreen(business: business, distance: distance, status: status),
    );
  }

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  final focusFullName = FocusNode();
  final focusMobile = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserAndNavigate(context);
    });
  }

  void checkUserAndNavigate(BuildContext context) async {
    final token = await ApiManager.getToken();

    if(token!=null) {
      context.read<BusinessDetailCubit>().getUser();
    } else {
      await NavigatorService.pushNamed(AppRoutes.signIn).then((onValue) {
        context.read<BusinessDetailCubit>().getUser();
      });
    }
  }

  @override
  void dispose() {
    focusFullName.dispose();
    focusMobile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessDetailCubit, BusinessDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Column(
            children: [
              _buildBanner(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildBusinessCard(state),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Full name'),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextFormField(
                              controller: TextEditingController(text: state.fullName),
                              enabled: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Mobile number'),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextFormField(
                              controller: TextEditingController(text: state.mobileNumber),
                              enabled: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Number of people'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              focusFullName.unfocus();
                              focusMobile.unfocus();
                              _showCategorySheet(context, state, context.read<BusinessDetailCubit>());
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    state.numberOfPeople == null ? '' : state.numberOfPeople.toString(),
                                    style: FontStyles.fontW400.copyWith(
                                      fontSize: 16,
                                      color: state.numberOfPeople == 0 ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Checkbox(
                                value: state.textMessage,
                                onChanged: (value) => context.read<BusinessDetailCubit>().toggleTextMessage(value ?? false),
                                activeColor: AppColors.primary,
                              ),
                              Expanded(
                                child: Text(
                                  'Get the text message letting you know when to head to your reservation.',
                                  style: FontStyles.fontW400.copyWith(fontSize: 14, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (state.error != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Text(
                                state.error!,
                                style: FontStyles.fontW400.copyWith(fontSize: 14, color: Colors.red[700]),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              title: 'Reserve your spot',
                              onPressed: () async {
                                context.read<BusinessDetailCubit>().reserveSpot();
                              },
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 56, left: 16, right: 16),
      child: Image.asset('assets/ic_hajzi_banner.png', fit: BoxFit.cover),
    );
  }

  Widget _buildBusinessCard(BusinessDetailState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.business.name,
                      style: FontStyles.fontW700.copyWith(fontSize: 24, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.business.address} • ${widget.distance != 0.0 ? '${widget.distance?.toStringAsFixed(1)} Km away' : ''}',
                      style: FontStyles.fontW400.copyWith(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.status ?? '',
                      style: FontStyles.fontW600.copyWith(fontSize: 14, color: AppColors.primary),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: FontStyles.fontW500.copyWith(fontSize: 16, color: Colors.black),
    );
  }

  Widget _buildTextField({
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        focusNode: focusNode,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

void _showCategorySheet(BuildContext context, BusinessDetailState state, BusinessDetailCubit cubit) {
  final List<int> peopleOptions = List.generate(6, (index) => index + 1);
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Number of people', style: FontStyles.fontW800.copyWith(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Column(
              children: peopleOptions.map((count) {
                final isSelected = state.numberOfPeople == count;

                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        "$count ${count == 1 ? 'person' : 'persons'}",
                        style: FontStyles.fontW600.copyWith(
                          fontSize: 16,
                          color: isSelected ? Colors.black : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.black)
                          : null,
                      onTap: () {
                        cubit.updateNumberOfPeople(count);
                        Navigator.of(context).pop();
                      },
                    ),
                    const Divider(height: 0.5, color: Colors.grey),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      );
    },
  );
}