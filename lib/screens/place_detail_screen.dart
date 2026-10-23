import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myspots/models/place.dart';
import 'package:myspots/providers/places_provider.dart';
import 'package:myspots/screens/edit_place_screen.dart';

class PlaceDetailScreen extends ConsumerWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider).value;
    final currentPlace = places == null
        ? place
        : places.where((item) => item.id == place.id).firstOrNull ?? place;

    final position = LatLng(
      currentPlace.location.latitude,
      currentPlace.location.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: const Text('Place Details'),
        actions: [
          IconButton(
            tooltip: 'Edit place',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (context) => EditPlaceScreen(place: currentPlace),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Delete place',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref, currentPlace),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.file(
                currentPlace.image,
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              currentPlace.title,
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
                    currentPlace.location.address,
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
                              markerId: MarkerId(currentPlace.id),
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
                            'Latitude: ${currentPlace.location.latitude.toStringAsFixed(6)}',
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
                            'Longitude: ${currentPlace.location.longitude.toStringAsFixed(6)}',
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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Place currentPlace,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete place?'),
        content: Text(
          'Are you sure you want to delete "${currentPlace.title}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(placesProvider.notifier).deletePlace(currentPlace.id);

      if (!context.mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete place: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
