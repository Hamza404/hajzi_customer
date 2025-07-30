import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hajzi/client/api_manager.dart';
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
        final businesses = (response['content'] as List).map((json) => BusinessResponseModel.fromJson(json)).toList();
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

  Future<Set<Marker>> _createBusinessMarkers(List<BusinessResponseModel> businesses) async {
    final markers = <Marker>{};

    for (int i = 0; i < businesses.length; i++) {
      final business = businesses[i];
      final markerId = 'business_${business.business.name}';
      final customIcon = await createCustomMarkerBitmap(
        '${business.business.queuedCount}\nWaiting',
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

  Future<BitmapDescriptor> createCustomMarkerBitmap(String text) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = ui.Canvas(pictureRecorder);

    const double width = 250;
    const double height = 250;

    final paint = Paint()..color = Colors.transparent;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    final image = await loadImageFromAsset('assets/typcn_location.png');
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