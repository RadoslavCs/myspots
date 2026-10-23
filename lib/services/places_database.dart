import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myspots/models/place.dart';

class PlacesDatabase {
  PlacesDatabase._();

  static final PlacesDatabase instance = PlacesDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();

    _database = await openDatabase(
      path.join(databasePath, 'myspots.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE places (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            image_path TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            address TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<List<Place>> getPlaces() async {
    final db = await database;

    final rows = await db.query('places', orderBy: 'rowid DESC');

    return rows.map((row) {
      return Place(
        id: row['id'] as String,
        title: row['title'] as String,
        image: File(row['image_path'] as String),
        location: PlaceLocation(
          latitude: row['latitude'] as double,
          longitude: row['longitude'] as double,
          address: row['address'] as String,
        ),
      );
    }).toList();
  }

  Future<Place> insertPlace(Place place) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    final imagesDirectory = Directory(
      path.join(documentsDirectory.path, 'place_images'),
    );

    await imagesDirectory.create(recursive: true);

    final extension = path.extension(place.image.path);

    final permanentImage = await place.image.copy(
      path.join(imagesDirectory.path, '${place.id}$extension'),
    );

    final savedPlace = Place(
      id: place.id,
      title: place.title,
      image: permanentImage,
      location: place.location,
    );

    try {
      final db = await database;

      await db.insert('places', {
        'id': savedPlace.id,
        'title': savedPlace.title,
        'image_path': savedPlace.image.path,
        'latitude': savedPlace.location.latitude,
        'longitude': savedPlace.location.longitude,
        'address': savedPlace.location.address,
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      return savedPlace;
    } catch (_) {
      if (await permanentImage.exists()) {
        await permanentImage.delete();
      }
      rethrow;
    }
  }

  Future<void> updatePlaceTitle(String id, String title) async {
    final db = await database;

    final updatedRows = await db.update(
      'places',
      {'title': title},
      where: 'id = ?',
      whereArgs: [id],
    );

    if (updatedRows != 1) {
      throw StateError('Place not found.');
    }
  }

  Future<void> deletePlace(String id) async {
    final db = await database;

    final rows = await db.query(
      'places',
      columns: ['image_path'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw StateError('Place not found.');
    }

    final imagePath = rows.first['image_path'] as String;

    await db.delete('places', where: 'id = ?', whereArgs: [id]);

    final image = File(imagePath);

    if (await image.exists()) {
      try {
        await image.delete();
      } on FileSystemException {
        // The database record is already deleted.
        // An orphaned image can be cleaned up separately.
      }
    }
  }
}
