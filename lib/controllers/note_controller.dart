import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/db/my_db.dart';
import 'package:notes/models/note_model.dart';

class NoteController extends GetxController {
  final MyDb db = MyDb();

  final RxList<NoteModel> notes = <NoteModel>[].obs;

  final RxString searchQuery = ''.obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  final RxString errorMessage = ''.obs;

  List<NoteModel> get filteredNotes {
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      return notes.toList();
    }

    return notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.body.toLowerCase().contains(query) ||
          note.category.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  Future<void> loadNotes() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final data = await db.getNotes();

      notes.assignAll(data);
    } catch (e) {
      errorMessage.value = 'Unable to load notes.';
    } finally {
      isLoading.value = false;
    }
  }

  void searchNotes(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  Future<bool> insertNote(NoteModel note) async {
    isSaving.value = true;

    try {
      await db.insertNote(note);
      await loadNotes();

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to save note.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateNote(NoteModel note) async {
    isSaving.value = true;

    try {
      await db.updateNote(note);
      await loadNotes();

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to update note.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteNote(
    NoteModel note, {
    bool showConfirmation = true,
  }) async {
    if (showConfirmation) {
      final bool? shouldDelete = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete note?'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(result: false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Get.back(result: true);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (shouldDelete != true) {
        return false;
      }
    }

    try {
      await db.deleteNote(note);
      await loadNotes();

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to delete note.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }
  }
}
