import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myspots/providers/places_provider.dart';
import 'package:myspots/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:myspots/models/place.dart';
import 'package:myspots/widgets/location_input.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  File? _selectedImage;
  PlaceLocation? _selectedLocation;
  bool _isSaving = false;

  void _onSelectLocation(PlaceLocation location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _onPickImage(File image) {
    setState(() {
      _selectedImage = image;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _savePlace() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a photo and choose a location.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final place = Place(
        title: _titleController.text.trim(),
        image: _selectedImage!,
        location: _selectedLocation!,
      );

      await ref.read(placesProvider.notifier).addPlace(place);

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save place: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 76, title: const Text('Add New Place')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Capture a place worth remembering.',
                style: TextStyle(fontSize: 15, color: Color(0xFF647C74)),
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE1EEEA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.edit_location_alt_outlined,
                            color: Color(0xFF0F766E),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Place details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF115E59),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Give your favorite place a memorable name.',
                        style: TextStyle(color: Color(0xFF647C74)),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 60,
                        decoration: InputDecoration(
                          labelText: 'Place name',
                          hintText: 'e.g. Mountain viewpoint',
                          prefixIcon: const Icon(Icons.place_outlined),
                          filled: true,
                          fillColor: const Color(0xFFF8FCFA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFB8DAD0),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a place name.';
                          }
                          if (value.trim().length < 3) {
                            return 'Use at least 3 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ImageInput(onPickImage: _onPickImage),
              const SizedBox(height: 16),
              LocationInput(onSelectLocation: _onSelectLocation),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _isSaving ? null : _savePlace,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Saving place...' : 'Save Place'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedImage == null
                    ? 'Choose a photo to continue.'
                    : _selectedLocation == null
                    ? 'Photo ready! Add a location to continue.'
                    : 'Everything is ready! Save your favorite place.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF647C74), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
