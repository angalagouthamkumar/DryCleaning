import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationState {
  final String currentAddress;
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final String? error;

  LocationState({
    this.currentAddress = 'Hasmathpet, Bowenpally',
    this.latitude = 17.476370,
    this.longitude = 78.488990,
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    String? currentAddress,
    double? latitude,
    double? longitude,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      currentAddress: currentAddress ?? this.currentAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState()) {
    fetchLiveLocation();
  }

  Future<void> fetchLiveLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          currentAddress: 'Hasmathpet, Bowenpally',
          latitude: 17.476370,
          longitude: 78.488990,
          isLoading: false,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            currentAddress: 'Hasmathpet, Bowenpally',
            latitude: 17.476370,
            longitude: 78.488990,
            isLoading: false,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          currentAddress: 'Hasmathpet, Bowenpally',
          latitude: 17.476370,
          longitude: 78.488990,
          isLoading: false,
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final String liveAddress = 'Hasmathpet, Bowenpally';

      state = state.copyWith(
        currentAddress: liveAddress,
        latitude: position.latitude,
        longitude: position.longitude,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        currentAddress: 'Hasmathpet, Bowenpally',
        latitude: 17.476370,
        longitude: 78.488990,
        isLoading: false,
      );
    }
  }

  void updateAddress(String address) {
    state = state.copyWith(currentAddress: address);
  }
}

final locationStateProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
