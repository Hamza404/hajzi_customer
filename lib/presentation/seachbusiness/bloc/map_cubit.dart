import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hajzi/client/api_manager.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'map_state.dart';
import '../model/business_model.dart';

class MapCubit extends Cubit<MapState> {
  GoogleMapController? _mapController;
  
  MapCubit({int? categoryId}) : super(MapState(selectedCategoryId: categoryId)) {
    initializeMap();
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> initializeMap() async {
    const defaultCameraPosition = CameraPosition(target: LatLng(24.7136, 46.6753), zoom: 10.0);

    emit(state.copyWith(
      isMapReady: true,
    ));

    await _startLocationFlow();

    if (state.selectedCategoryId != null) {
      await fetchBusinessesForCategory(state.selectedCategoryId!);
    }
  }

  Future<void> fetchBusinessesForCategory(int categoryId) async {
    emit(state.copyWith(isFetchingBusinesses: true));
    
    try {
      final response = await ApiManager.get('BusinessDetails/GetBusinessByServiceId/$categoryId');
      
      if (response['isSuccess']) {

        final rawList = response['content'] as List;

        final businesses = rawList.map((json) {
          final business = BusinessResponseModel.fromJson(json);
          business.currentDay = getTodayWorkingHours(business.workingHours);
          return business;
        }).toList();

        //final businesses = (response['content'] as List).map((json) => BusinessResponseModel.fromJson(json)).toList();
        final businessMarkers = await _createBusinessMarkers(businesses);
        final allMarkers = {...state.markers, ...businessMarkers};
        
        emit(state.copyWith(
          businesses: businesses,
          markers: allMarkers,
          isFetchingBusinesses: false,
        ));
      } else {
        emit(state.copyWith(
          isFetchingBusinesses: false,
          error: 'Failed to fetch businesses',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isFetchingBusinesses: false,
        error: 'Failed to fetch businesses: ${e.toString()}',
      ));
    }
  }

  WorkingHoursModel? getTodayWorkingHours(List<WorkingHoursModel> hoursList) {
    final now = DateTime.now();
    final today = now.weekday;

    return hoursList.firstWhere(
          (item) => item.day == today,
      orElse: () => WorkingHoursModel(),
    );
  }

  Future<Set<Marker>> _createBusinessMarkers(List<BusinessResponseModel> businesses) async {
    final markers = <Marker>{};

    for (int i = 0; i < businesses.length; i++) {
      final business = businesses[i];
      final markerId = 'business_${business.business.name}';

      final isOpen = isBusinessOpen(business.currentDay);
      
      final customIcon = await createCustomMarkerBitmap(
          isOpen ? '${business.business.queuedCount}\nWaiting' : 'Closed',
          isOpen ? 'assets/typcn_location.png' : 'assets/closed_marker.png'
      );
      
      final marker = Marker(
        markerId: MarkerId(markerId),
        position: LatLng(business.business.latitude, business.business.longitude),
        icon: customIcon,
        onTap: () async {
          await calculateDistance(
              state.currentPosition?.latitude ?? 0.0,
              state.currentPosition?.longitude ?? 0.0,
              business.business.latitude,
              business.business.longitude
          );
          emit(state.copyWith(
            selectedBusiness: business
          ));
        },
      );
      
      markers.add(marker);
    }
    
    return markers;
  }

  bool isBusinessOpen(WorkingHoursModel? currentDay) {
    if (currentDay?.startTime == null || currentDay?.endTime == null || currentDay?.startTime?.trim().isEmpty==true || currentDay?.endTime?.trim().isEmpty == true) {
      return false;
    }

    try {
      final now = DateTime.now();

      final start = _parseTime(currentDay?.startTime);
      final end = _parseTime(currentDay?.endTime);

      bool is24Hours = currentDay?.startTime == currentDay?.endTime;

      final startDateTime = DateTime(now.year, now.month, now.day, start.hour, start.minute);
      DateTime endDateTime = DateTime(now.year, now.month, now.day, end.hour, end.minute);
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(const Duration(days: 1));
      }

      if (is24Hours || (now.isAfter(startDateTime) && now.isBefore(endDateTime))) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
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

  Future<BitmapDescriptor> createCustomMarkerBitmap(String text, String marker) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = ui.Canvas(pictureRecorder);

    const double width = 250;
    const double height = 250;

    final paint = Paint()..color = Colors.transparent;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    final image = await loadImageFromAsset(marker);
    final imageOffset = Offset(
      (width - image.width) / 2,
      (height - image.height) / 2,
    );
    canvas.drawImage(image, imageOffset, Paint());

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textScaleFactor: 1.0,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: width,
    );

    final textOffset = Offset(
      (width - textPainter.width) / 2,
      (height - textPainter.height) / 2 - 10, // adjust if needed
    );

    textPainter.paint(canvas, textOffset);

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(buffer);
  }

  Future<ui.Image> loadImageFromAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> _startLocationFlow() async {
    emit(state.copyWith(isLoading: true));
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        emit(state.copyWith(
          permissionStatus: LocationPermissionStatus.denied,
          isLoading: false,
          error: 'Location permission is required to show your current location.',
        ));
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!serviceEnabled) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Location services are disabled. Please enable location services in your device settings.',
        ));
        await Geolocator.openLocationSettings();
        await Future.delayed(const Duration(seconds: 2));
        await _startLocationFlow();
        return;
      }

      emit(state.copyWith(permissionStatus: LocationPermissionStatus.granted));
      await _getCurrentLocation();
      
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to get location: ${e.toString()}',
      ));
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      final cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15.0,
      );

      final currentLocationMarker = Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(position.latitude, position.longitude),
      );

      final allMarkers = {currentLocationMarker, ...state.markers};

      emit(state.copyWith(
        currentPosition: position,
        cameraPosition: cameraPosition,
        isLoading: false,
        markers: allMarkers,
      ));

      await _animateToCurrentLocation(position);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to get current location: ${e.toString()}',
      ));
    }
  }

  Future<void> _animateToCurrentLocation(Position position) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 17.0,
          ),
        ),
      );
    }
  }

  Future<void> refreshLocation() async {
    await _startLocationFlow();
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void updateCameraPosition(CameraPosition position) {
    emit(state.copyWith(cameraPosition: position));
  }

  Future<void> calculateDistance(double currentLat, double currentLng, double businessLat, double businessLng) async {
    final distance = await getDistanceInKm(currentLat, currentLng, businessLat, businessLng);
    emit(state.copyWith(distance: distance));
  }

  Future<double> getDistanceInKm(
      double currentLat,
      double currentLng,
      double businessLat,
      double businessLng,
      ) async {
    final distanceInMeters = Geolocator.distanceBetween(
      currentLat,
      currentLng,
      businessLat,
      businessLng,
    );

    return distanceInMeters / 1000; // Convert to km
  }
} 