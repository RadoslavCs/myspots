import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myspots/models/place.dart';
import 'package:myspots/providers/places_provider.dart';
import 'package:myspots/screens/add_place_screen.dart';
import 'package:myspots/widgets/places_list.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  final _searchController = TextEditingController();
  PlaceCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _openAddPlaceScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const AddPlaceScreen()),
    );
  }

  List<Place> _filterPlaces(List<Place> places) {
    final query = _searchController.text.trim().toLowerCase();

    return places.where((place) {
      final matchesSearch =
          query.isEmpty ||
          place.title.toLowerCase().contains(query) ||
          place.location.address.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == null || place.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _selectedCategory = null;
    });

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: 'Search places or addresses...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 58,
                child: Stack(
                  children: [
                    ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (_) {
                              setState(() => _selectedCategory = null);
                            },
                          ),
                        ),
                        for (final category in PlaceCategory.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category.label),
                              selected: _selectedCategory == category,
                              onSelected: (_) {
                                setState(() => _selectedCategory = category);
                              },
                            ),
                          ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          width: 24,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0x00F8FCFA), Color(0xFFF8FCFA)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swipe_left_rounded,
                      size: 15,
                      color: Color(0xFF647C74),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Swipe to explore categories',
                      style: TextStyle(fontSize: 11, color: Color(0xFF647C74)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: places.when(
              data: (items) {
                final filteredPlaces = _filterPlaces(items);

                final hasActiveFilters =
                    _searchController.text.trim().isNotEmpty ||
                    _selectedCategory != null;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 18,
                            color: Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${filteredPlaces.length} '
                            '${filteredPlaces.length == 1 ? 'place' : 'places'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF115E59),
                            ),
                          ),
                          const Spacer(),
                          if (hasActiveFilters)
                            TextButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(
                                Icons.restart_alt_rounded,
                                size: 18,
                              ),
                              label: const Text('Reset filters'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: items.isNotEmpty && filteredPlaces.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.search_off_rounded,
                                      size: 54,
                                      color: Color(0xFF0F766E),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No matching places',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF115E59),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Try another search or category.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF647C74),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      onPressed: _clearFilters,
                                      icon: const Icon(
                                        Icons.restart_alt_rounded,
                                      ),
                                      label: const Text('Clear filters'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : PlacesList(places: filteredPlaces),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load places: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPlaceScreen,
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
