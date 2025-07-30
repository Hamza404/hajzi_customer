import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../model/business_model.dart';

enum LocationPermissionStatus {
  initial,
  requesting,
  granted,
  denied,
  permanentlyDenied,
}

class MapState {
  final LocationPermissionStatus permissionStatus;
  final Position? currentPosition;
  final CameraPosition? cameraPosition;
  final bool isLoading;
  final bool isMapReady;
  final String? error;
  final Set<Marker> markers;
  final List<BusinessResponseModel> businesses;
  final bool isFetchingBusinesses;
  final int? selectedCategoryId;
  final BusinessResponseModel? selectedBusiness;
  final double distance;

  MapState({
    this.permissionStatus = LocationPermissionStatus.initial,
    this.currentPosition,
    this.cameraPosition,
    this.isLoading = false,
    this.isMapReady = false,
    this.error,
    this.markers = const {},
    this.businesses = const [],
    this.isFetchingBusinesses = false,
    this.selectedCategoryId,
    this.selectedBusiness,
    this.distance = 0.0
  });

  MapState copyWith({
    LocationPermissionStatus? permissionStatus,
    Position? currentPosition,
    CameraPosition? cameraPosition,
    bool? isLoading,
    bool? isMapReady,
    String? error,
    Set<Marker>? markers,
    List<BusinessResponseModel>? businesses,
    bool? isFetchingBusinesses,
    int? selectedCategoryId,
    BusinessResponseModel? selectedBusiness,
    double? distance,
  }) {
    return MapState(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      currentPosition: currentPosition ?? this.currentPosition,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      isLoading: isLoading ?? this.isLoading,
      isMapReady: isMapReady ?? this.isMapReady,
      error: error,
      markers: markers ?? this.markers,
      businesses: businesses ?? this.businesses,
      isFetchingBusinesses: isFetchingBusinesses ?? this.isFetchingBusinesses,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedBusiness: selectedBusiness ?? this.selectedBusiness,
      distance: distance ?? this.distance,
    );
  }
} 