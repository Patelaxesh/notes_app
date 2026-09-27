import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/controllers/note_controller.dart';
import 'package:notes/models/note_model.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final NoteController controller = Get.find<NoteController>();

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  String selectedCategory = 'Personal';

  final List<String> categories = [
    'Work',
    'Personal',
    'Task',
    'Ideas',
  ];

  @override
  void initState() {
    super.initState();

    titleController.addListener(_refresh);
    bodyController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  Future<void> saveNote() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final note = NoteModel(
      title: titleController.text.trim(),
      body: bodyController.text.trim(),
      category: selectedCategory,
    );

    final success = await controller.insertNote(note);

    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Note',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(
            () => Form(
          key: formKey,
          child: ListView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: titleController,
                textInputAction: TextInputAction.next,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title',
                  prefixIcon: const Icon(Icons.title_outlined),
                  counterText:
                  '${titleController.text.length}/100',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(
                    Icons.category_outlined,
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: controller.isSaving.value
                    ? null
                    : (value) {
                  if (value == null) return;

                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: bodyController,
                maxLines: 9,
                maxLength: 5000,
                decoration: InputDecoration(
                  labelText: 'Note',
                  hintText: 'Write your note...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 140),
                    child: Icon(Icons.notes_outlined),
                  ),
                  alignLabelWithHint: true,
                  counterText:
                  '${bodyController.text.length}/5000',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Note is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed:
                  controller.isSaving.value ? null : saveNote,
                  child: controller.isSaving.value
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Save Note',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
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