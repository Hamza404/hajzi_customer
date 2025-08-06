import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../core/utils/navigator_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/font_styles.dart';
import '../../widgets/custom_button.dart';
import 'bloc/map_cubit.dart';
import 'bloc/map_state.dart';
import 'model/business_model.dart';

class SearchBusinessScreen extends StatelessWidget {
  final int? categoryId;

  static Widget builder(BuildContext context, {int? categoryId}) {
    return BlocProvider<MapCubit>(
      create: (context) => MapCubit(categoryId: categoryId),
      child: SearchBusinessScreen(categoryId: categoryId),
    );
  }

  const SearchBusinessScreen({Key? key, this.categoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final state = context.watch<MapCubit>().state;

    if (!state.isMapReady) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.permissionStatus == LocationPermissionStatus.denied) {
      return _buildMapWithPermissionOverlay(context);
    }

    if (state.error != null && state.error!.contains('Location services are disabled')) {
      return _buildMapWithLocationServicesOverlay(context);
    }

    return const _GoogleMapStackView(); // Use refactored widget
  }

  Widget _buildMapWithPermissionOverlay(BuildContext context) {
    return Stack(
      children: [
        const _GoogleMapStackView(),
        Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    'Location Permission Required',
                    style: FontStyles.fontW600.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This app needs location permission to show your current location on the map.',
                    textAlign: TextAlign.center,
                    style: FontStyles.fontW400.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MapCubit>().refreshLocation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Grant Permission', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapWithLocationServicesOverlay(BuildContext context) {
    return const _GoogleMapStackView();
  }
}

class _GoogleMapStackView extends StatefulWidget {
  const _GoogleMapStackView({Key? key}) : super(key: key);

  @override
  State<_GoogleMapStackView> createState() => _GoogleMapStackViewState();
}

class _GoogleMapStackViewState extends State<_GoogleMapStackView> {
  late final CameraPosition _initialCameraPosition;
  CameraPosition? _lastCameraPosition;

  @override
  void initState() {
    super.initState();
    final state = context.read<MapCubit>().state;
    _initialCameraPosition = state.cameraPosition ?? const CameraPosition(target: LatLng(24.7136, 46.6753), zoom: 10);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapCubit>();

    return Stack(
      children: [
        BlocSelector<MapCubit, MapState, Set<Marker>>(
          selector: (state) => state.markers,
          builder: (context, markers) {
            return GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: cubit.setMapController,
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onCameraMove: (position) {
                _lastCameraPosition = position;
              },
              onCameraIdle: () {
                if (_lastCameraPosition != null) {
                  cubit.updateCameraPosition(_lastCameraPosition!);
                }
              },
            );
          },
        ),

        BlocSelector<MapCubit, MapState, bool>(
          selector: (state) => state.isLoading,
          builder: (context, isLoading) {
            return isLoading
                ? Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 8),
                    Text('Getting location...', style: FontStyles.fontW400.copyWith(fontSize: 14)),
                  ],
                ),
              ),
            )
                : const SizedBox.shrink();
          },
        ),

        Positioned(
          bottom: 100,
          right: 16,
          child: FloatingActionButton(
            onPressed: cubit.refreshLocation,
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.black87),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: const IconButton(
              onPressed: NavigatorService.goBack,
              icon: Icon(Icons.arrow_back),
              color: Colors.black87,
            ),
          ),
        ),

        BlocSelector<MapCubit, MapState, BusinessResponseModel?>(
          selector: (state) => state.selectedBusiness,
          builder: (context, selectedBusiness) {
            final position = context.read<MapCubit>().state.currentPosition;
            return selectedBusiness != null ? Positioned(
              left: 12,
              right: 12,
              bottom: 30,
              child: _buildBusinessInfoCard(selectedBusiness, position, context),
            ) : const SizedBox.shrink();
          },
        )
      ],
    );
  }

  Widget _buildBusinessInfoCard(BusinessResponseModel business, Position? currentPosition, BuildContext context) {

    final distance = context.read<MapCubit>().state.distance;
    final status = getBusinessStatus(business.workingHours);

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(business.business.name, style: FontStyles.fontW800.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            const SizedBox(height: 8),
            BlocBuilder<MapCubit, MapState>(
              builder: (context, state) {
                return Text(
                  '${business.business.address} • ${state.distance != 0.0 ? '${state.distance.toStringAsFixed(1)} Km away' : ''}',
                  style: FontStyles.fontW400.copyWith(fontSize: 14),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(getBusinessStatus(business.workingHours)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${business.business.queuedCount} people in queue', style: FontStyles.fontW500.copyWith(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),

            if(status.contains('Open'))
              CustomButton(
                title: 'Reserve a spot with 7ajzi',
                onPressed: () {

                  NavigatorService.pushNamed(
                    AppRoutes.businessDetail,
                    arguments: {
                      'business': business.business,
                      'distance': distance,
                      'status': status
                    },
                  ).then((onValue) {

                  });
                },
                backgroundColor: Colors.black,
                textColor: Colors.white
            ),

            if(status.contains('Closed'))
              CustomButton(
                  title: 'Not Available',
                  onPressed: () {},
                  backgroundColor: AppColors.gray,
                  textColor: Colors.black
              )

          ],
        ),
      ),
    );
  }

  String getBusinessStatus(List<WorkingHoursModel> schedule) {
    final now = DateTime.now();
    final today = now.weekday; // 1 = Monday, 7 = Sunday

    final todaySchedule = schedule.firstWhere(
          (item) => item.day == today,
      orElse: () => WorkingHoursModel(),
    );

    if (todaySchedule.startTime == null) return 'Closed all day';

    final start = _parseTime(todaySchedule.startTime);
    final end = _parseTime(todaySchedule.endTime);

    bool is24Hours = todaySchedule.startTime == todaySchedule.endTime;

    final startDateTime = DateTime(now.year, now.month, now.day, start.hour, start.minute);
    DateTime endDateTime = DateTime(now.year, now.month, now.day, end.hour, end.minute);
    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    if (is24Hours || (now.isAfter(startDateTime) && now.isBefore(endDateTime))) {
      final closeTimeFormatted = DateFormat('h:mm a').format(endDateTime);
      return 'Open until $closeTimeFormatted';
    } else {
      return 'Closed';
    }
  }

  TimeOfDay _parseTime(String? timeStr) {
    final format = DateFormat.jm(); // e.g., 12:00 PM
    if(timeStr==null) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
    final dt = format.parse(timeStr);
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }
}