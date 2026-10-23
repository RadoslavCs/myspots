import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myspots/models/place.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final position = LatLng(place.location.latitude, place.location.longitude);

    return Scaffold(
      appBar: AppBar(toolbarHeight: 76, title: const Text('Place Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.file(
                place.image,
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              place.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF115E59),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF0F766E),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    place.location.address,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF647C74),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE1EEEA)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.map_outlined, color: Color(0xFF0F766E)),
                        SizedBox(width: 10),
                        Text(
                          'Location on map',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF115E59),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 220,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: position,
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(place.id),
                              position: position,
                            ),
                          },
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          scrollGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          rotateGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.gps_fixed_rounded,
                          size: 18,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Latitude: ${place.location.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(color: Color(0xFF47796D)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.explore_outlined,
                          size: 18,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Longitude: ${place.location.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(color: Color(0xFF47796D)),
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
      ),
    );
  }
}
