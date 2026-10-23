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

  Future<void> updatePlaceTitle(String id, String title) async {
    await PlacesDatabase.instance.updatePlaceTitle(id, title);

    final currentPlaces = await future;

    state = AsyncData([
      for (final place in currentPlaces)
        if (place.id == id)
          Place(
            id: place.id,
            title: title,
            image: place.image,
            location: place.location,
          )
        else
          place,
    ]);
  }

  Future<void> deletePlace(String id) async {
    await PlacesDatabase.instance.deletePlace(id);

    final currentPlaces = await future;

    state = AsyncData([
      for (final place in currentPlaces)
        if (place.id != id) place,
    ]);
  }
}

final placesProvider = AsyncNotifierProvider<PlacesNotifier, List<Place>>(
  PlacesNotifier.new,
);
