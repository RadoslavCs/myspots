import 'dart:io';

import 'package:myspots/widgets/image_input.dart';
import 'package:flutter/material.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  File? _selectedImage;

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

  void _validateTitle() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title is valid. Photo and location are coming next!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                      OutlinedButton.icon(
                        onPressed: _validateTitle,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Check place name'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ImageInput(onPickImage: _onPickImage),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.map_outlined,
                title: 'Location',
                description: 'Save the exact location of your favorite spot.',
                status: 'Coming soon',
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Place'),
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
                    : 'Photo ready! Add a location to save your place.',
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String description;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE1EEEA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFDFF5EF),
              child: Icon(icon, color: const Color(0xFF0F766E)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF115E59),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF647C74),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
