import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/controllers/note_controller.dart';
import 'package:notes/models/note_model.dart';

class UpdateNoteScreen extends StatefulWidget {
  final NoteModel note;

  const UpdateNoteScreen({
    super.key,
    required this.note,
  });

  @override
  State<UpdateNoteScreen> createState() =>
      _UpdateNoteScreenState();
}

class _UpdateNoteScreenState extends State<UpdateNoteScreen> {
  final NoteController controller =
  Get.find<NoteController>();

  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController bodyController;

  late String selectedCategory;

  final List<String> categories = [
    'Work',
    'Personal',
    'Task',
    'Ideas',
  ];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.note.title,
    );

    bodyController = TextEditingController(
      text: widget.note.body,
    );

    selectedCategory =
    categories.contains(widget.note.category)
        ? widget.note.category
        : 'Personal';

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

  Future<void> updateNote() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final note = NoteModel(
      id: widget.note.id,
      title: titleController.text.trim(),
      body: bodyController.text.trim(),
      category: selectedCategory,
    );

    final success = await controller.updateNote(note);

    if (success && mounted) {
      Get.back();
    }
  }

  Future<void> deleteNote() async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete note?'),
        content: const Text(
          'Are you sure you want to delete this note?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back(result: true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    final success = await controller.deleteNote(
      widget.note,
      showConfirmation: false,
    );

    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Note',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Delete note',
            onPressed: deleteNote,
            icon: const Icon(
              Icons.delete_outline,
            ),
          ),
        ],
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
                  prefixIcon: const Icon(
                    Icons.title_outlined,
                  ),
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
                    child: Icon(
                      Icons.notes_outlined,
                    ),
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
                  controller.isSaving.value
                      ? null
                      : updateNote,
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
                    'Update Note',
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