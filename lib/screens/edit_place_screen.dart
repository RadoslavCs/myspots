import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myspots/models/place.dart';
import 'package:myspots/providers/places_provider.dart';

class EditPlaceScreen extends ConsumerStatefulWidget {
  const EditPlaceScreen({super.key, required this.place});

  final Place place;

  @override
  ConsumerState<EditPlaceScreen> createState() => _EditPlaceScreenState();
}

class _EditPlaceScreenState extends ConsumerState<EditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late PlaceCategory _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.place.title);
    _selectedCategory = widget.place.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(placesProvider.notifier)
          .updatePlace(widget.place.id, title, _selectedCategory);

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update place: $error'),
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
      appBar: AppBar(toolbarHeight: 76, title: const Text('Edit Place')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            children: [
              const Text(
                'Give your favorite place a new name.',
                style: TextStyle(fontSize: 15, color: Color(0xFF647C74)),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE1EEEA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _titleController,
                    maxLength: 60,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Place name',
                      prefixIcon: const Icon(Icons.edit_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF8FCFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (value) {
                      final title = value?.trim() ?? '';

                      if (title.isEmpty) {
                        return 'Please enter a place name.';
                      }

                      if (title.length < 3) {
                        return 'Use at least 3 characters.';
                      }

                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PlaceCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final category in PlaceCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: _isSaving
                    ? null
                    : (category) {
                        if (category == null) return;
                        setState(() => _selectedCategory = category);
                      },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveChanges,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Saving changes...' : 'Save Changes'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
