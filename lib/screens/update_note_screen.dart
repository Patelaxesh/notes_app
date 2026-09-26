import 'package:flutter/material.dart';
import 'package:notes/db/my_db.dart';
import 'package:notes/models/note_model.dart';

class UpdateNoteScreen extends StatefulWidget {
  final NoteModel note;

  const UpdateNoteScreen({super.key, required this.note});

  @override
  State<UpdateNoteScreen> createState() => _UpdateNoteScreenState();
}

class _UpdateNoteScreenState extends State<UpdateNoteScreen> {
  final MyDb db = MyDb();

  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController bodyController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.note.title);

    bodyController = TextEditingController(text: widget.note.body);
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

    setState(() {
      isLoading = true;
    });

    try {
      final note = NoteModel(
        id: widget.note.id,
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
      );

      await db.updateNote(note);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to update note.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Update Note'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter note title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: bodyController,
              maxLines: 8,
              maxLength: 5000,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Write your note...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
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
                style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: isLoading ? null : updateNote,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Update Note',
                        style: TextStyle(color: Colors.black),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
