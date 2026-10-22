import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myspots/providers/places_provider.dart';
import 'package:myspots/screens/add_place_screen.dart';
import 'package:myspots/widgets/places_list.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  void _openAddPlaceScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const AddPlaceScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 86,
        title: const Row(
          children: [
            Icon(Icons.place_rounded, size: 30),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MySpots',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Your favorite places, all in one spot.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF47796D),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: PlacesList(places: places),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddPlaceScreen(context),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Place',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
