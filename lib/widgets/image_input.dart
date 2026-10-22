import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedImage == null || !mounted) return;

      final imageFile = File(pickedImage.path);

      setState(() {
        _selectedImage = imageFile;
      });

      widget.onPickImage(imageFile);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load image: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF8FCFA),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add a photo',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF115E59),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose how you want to capture your favorite place.',
                  style: TextStyle(color: Color(0xFF647C74), fontSize: 14),
                ),
                const SizedBox(height: 24),
                _ImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  title: 'Take a photo',
                  subtitle: 'Open your camera',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 12),
                _ImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from gallery',
                  subtitle: 'Select an existing photo',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.add_a_photo_outlined, color: Color(0xFF0F766E)),
                SizedBox(width: 10),
                Text(
                  'Capture your moment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF115E59),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Every great place deserves a beautiful memory.',
              style: TextStyle(fontSize: 13, color: Color(0xFF647C74)),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 210,
                color: const Color(0xFFF0F9F6),
                child: _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 54,
                            color: Color(0xFF0F766E),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Your photo will appear here',
                            style: TextStyle(
                              color: Color(0xFF47796D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null) ...[
              const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF0F766E),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Photo selected',
                    style: TextStyle(
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _showImageSourcePicker,
                icon: Icon(
                  _selectedImage == null
                      ? Icons.add_a_photo_rounded
                      : Icons.refresh_rounded,
                ),
                label: Text(
                  _selectedImage == null ? 'Choose a photo' : 'Change photo',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  const _ImageSourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF115E59),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF647C74),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF0F766E)),
            ],
          ),
        ),
      ),
    );
  }
}
