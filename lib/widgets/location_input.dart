import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:myspots/models/place.dart';
import 'package:myspots/screens/map_screen.dart';
import 'package:myspots/services/geocoding_service.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  bool _isGettingLocation = false;
  PlaceLocation? _selectedLocation;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final location = Location();

      var serviceEnabled = await location.serviceEnabled();

      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled.');
        }
      }

      var permission = await location.hasPermission();

      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
      }

      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.grantedLimited) {
        throw Exception('Location permission was not granted.');
      }

      final locationData = await location.getLocation();

      final latitude = locationData.latitude;
      final longitude = locationData.longitude;

      if (!latitude.isFinite ||
          !longitude.isFinite ||
          latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180) {
        throw Exception('Invalid GPS coordinates.');
      }

      String address = 'GPS location';

      try {
        address = await GeocodingService.getAddress(
          latitude: latitude,
          longitude: longitude,
        );
      } catch (_) {
        // GPS coordinates are still valid if geocoding is unavailable.
      }

      final selectedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      if (!mounted) return;

      setState(() {
        _selectedLocation = selectedLocation;
      });

      widget.onSelectLocation(selectedLocation);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not get location: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _openMap() async {
    final initialLocation =
        _selectedLocation ??
        const PlaceLocation(
          latitude: 48.8945,
          longitude: 18.0444,
          address: 'Trenčín',
        );

    final selectedLocation = await Navigator.of(context).push<PlaceLocation>(
      MaterialPageRoute(
        builder: (context) => MapScreen(initialLocation: initialLocation),
      ),
    );

    if (!mounted || selectedLocation == null) return;

    setState(() {
      _selectedLocation = selectedLocation;
    });

    widget.onSelectLocation(selectedLocation);
  }

  String _getStaticMapUrl(PlaceLocation location) {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

    final latitude = location.latitude;
    final longitude = location.longitude;

    return Uri.https('maps.googleapis.com', '/maps/api/staticmap', {
      'center': '$latitude,$longitude',
      'zoom': '15',
      'size': '600x300',
      'scale': '2',
      'maptype': 'roadmap',
      'markers': 'color:red|$latitude,$longitude',
      'key': apiKey,
    }).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE1EEEA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on_outlined, color: Color(0xFF0F766E)),
                SizedBox(width: 10),
                Text(
                  'Discover your location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF115E59),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Save the exact coordinates of your favorite spot.',
              style: TextStyle(fontSize: 13, color: Color(0xFF647C74)),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (_selectedLocation == null)
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0xFFDFF5EF),
                      child: Icon(
                        Icons.my_location_rounded,
                        size: 34,
                        color: Color(0xFF0F766E),
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: double.infinity,
                        height: 180,
                        child: Image.network(
                          _getStaticMapUrl(_selectedLocation!),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.map_outlined,
                                size: 48,
                                color: Color(0xFF0F766E),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Text(
                    _selectedLocation == null
                        ? 'Your next adventure starts here'
                        : 'Location captured!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF115E59),
                    ),
                  ),
                  if (_selectedLocation != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Latitude: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(color: Color(0xFF47796D)),
                    ),
                    Text(
                      'Longitude: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(color: Color(0xFF47796D)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedLocation!.address,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF115E59),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.gps_fixed_rounded),
                label: Text(
                  _isGettingLocation
                      ? 'Getting your location...'
                      : _selectedLocation == null
                      ? 'Use current location'
                      : 'Update location',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isGettingLocation ? null : _openMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Choose on map'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F766E),
                  side: const BorderSide(color: Color(0xFF0F766E)),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
