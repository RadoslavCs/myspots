import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:myspots/models/place.dart';

void main() {
  group('Place model', () {
    final location = PlaceLocation(
      latitude: 48.8945,
      longitude: 18.0444,
      address: 'Trencin, Slovakia',
    );

    test('uses Other as the default category', () {
      final place = Place(
        title: 'Test Place',
        image: File('test.jpg'),
        location: location,
      );

      expect(place.category, PlaceCategory.other);
    });

    test('stores the selected category', () {
      final place = Place(
        title: 'Castle',
        image: File('castle.jpg'),
        location: location,
        category: PlaceCategory.culture,
      );

      expect(place.category, PlaceCategory.culture);
      expect(place.title, 'Castle');
    });

    test('generates a unique ID for each place', () {
      final firstPlace = Place(
        title: 'First',
        image: File('first.jpg'),
        location: location,
      );

      final secondPlace = Place(
        title: 'Second',
        image: File('second.jpg'),
        location: location,
      );

      expect(firstPlace.id, isNotEmpty);
      expect(secondPlace.id, isNotEmpty);
      expect(firstPlace.id, isNot(secondPlace.id));
    });

    test('preserves a provided ID', () {
      final place = Place(
        id: 'place-123',
        title: 'Test',
        image: File('test.jpg'),
        location: location,
      );

      expect(place.id, 'place-123');
    });

    test('stores location information', () {
      expect(location.latitude, 48.8945);
      expect(location.longitude, 18.0444);
      expect(location.address, 'Trencin, Slovakia');
    });
  });

  group('PlaceCategory enum', () {
    test('contains all five categories', () {
      expect(PlaceCategory.values.length, 5);
    });

    test('has correct display labels', () {
      expect(PlaceCategory.nature.label, 'Nature');
      expect(PlaceCategory.food.label, 'Food');
      expect(PlaceCategory.travel.label, 'Travel');
      expect(PlaceCategory.culture.label, 'Culture');
      expect(PlaceCategory.other.label, 'Other');
    });
  });
}
