import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myspots/models/place.dart';
import 'package:myspots/services/places_database.dart';

class PlacesNotifier extends AsyncNotifier<List<Place>> {
  @override
  Future<List<Place>> build() {
    return PlacesDatabase.instance.getPlaces();
  }

  Future<void> addPlace(Place place) async {
    final savedPlace = await PlacesDatabase.instance.insertPlace(place);

    final currentPlaces = await future;

    state = AsyncData([savedPlace, ...currentPlaces]);
  }
}

final placesProvider =
    AsyncNotifierProvider<PlacesNotifier, List<Place>>(
  PlacesNotifier.new,
);