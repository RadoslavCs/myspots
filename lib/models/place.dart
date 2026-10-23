import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum PlaceCategory {
  nature('Nature'),
  food('Food'),
  travel('Travel'),
  culture('Culture'),
  other('Other');

  const PlaceCategory(this.label);

  final String label;
}

class PlaceLocation {
  const PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;
}

class Place {
  Place({
    required this.title,
    required this.image,
    required this.location,
    this.category = PlaceCategory.other,
    String? id,
  }) : id = id ?? uuid.v4();

  final String id;
  final String title;
  final File image;
  final PlaceLocation location;
  final PlaceCategory category;
}
