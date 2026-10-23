import 'package:flutter/material.dart';
import 'package:myspots/models/place.dart';
import 'package:myspots/screens/place_detail_screen.dart';

class PlacesList extends StatelessWidget {
  const PlacesList({super.key, required this.places});

  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFFDFF5EF),
                child: Icon(
                  Icons.map_outlined,
                  size: 42,
                  color: Color(0xFF0F766E),
                ),
              ),
              SizedBox(height: 22),
              Text(
                'No places yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF115E59),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Start collecting your favorite places and memories.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF647C74),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE1EEEA)),
          ),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => PlaceDetailScreen(place: place),
                ),
              );
            },
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                place.image,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              place.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF115E59),
              ),
            ),
            subtitle: Text(
              place.location.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF0F766E),
            ),
          ),
        );
      },
    );
  }
}
