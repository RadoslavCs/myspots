import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:myspots/models/place.dart';
import 'package:myspots/services/geocoding_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.initialLocation});

  final PlaceLocation initialLocation;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng _selectedPosition;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _selectedPosition = LatLng(
      widget.initialLocation.latitude,
      widget.initialLocation.longitude,
    );
  }

  Future<void> _saveLocation() async {
    setState(() {
      _isSaving = true;
    });

    String address = 'Selected map location';

    try {
      address = await GeocodingService.getAddress(
        latitude: _selectedPosition.latitude,
        longitude: _selectedPosition.longitude,
      );
    } catch (_) {
      // Keep the selected coordinates even if geocoding fails.
    }

    if (!mounted) return;

    final location = PlaceLocation(
      latitude: _selectedPosition.latitude,
      longitude: _selectedPosition.longitude,
      address: address,
    );

    Navigator.of(context).pop(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            onTap: (position) {
              setState(() {
                _selectedPosition = position;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _selectedPosition,
              ),
            },
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tap anywhere on the map',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF115E59),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_selectedPosition.latitude.toStringAsFixed(6)}, '
                        '${_selectedPosition.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(color: Color(0xFF647C74)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isSaving ? null : _saveLocation,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
                          label: Text(
                            _isSaving
                                ? 'Finding address...'
                                : 'Confirm location',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
