import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myspots/models/place.dart';

class PlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() {
    return [];
  }

  void addPlace(Place place) {
    state = [...state, place];
  }
}

final placesProvider = NotifierProvider<PlacesNotifier, List<Place>>(
  PlacesNotifier.new,
);
