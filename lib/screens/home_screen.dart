import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/controllers/note_controller.dart';
import 'package:notes/controllers/theme_controller.dart';
import 'package:notes/models/note_model.dart';
import 'package:notes/screens/add_note_screen.dart';
import 'package:notes/screens/update_note_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NoteController controller =
    Get.find<NoteController>();

    final ThemeController themeController =
    Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Obx(
                () => IconButton(
              tooltip: 'Change theme',
              onPressed: themeController.toggleTheme,
              icon: Icon(
                themeController.themeMode.value ==
                    ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          _searchBox(controller),

          Expanded(
            child: Obx(
                  () {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _errorView(controller);
                }

                if (controller.filteredNotes.isEmpty) {
                  return _emptyNotes(
                    context,
                    controller,
                  );
                }

                return _notesList(controller);
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Get.to(
                () => const AddNoteScreen(),
          );

          controller.loadNotes();
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'New Note',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _searchBox(NoteController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: TextField(
        onChanged: controller.searchNotes,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.blue,
          ),
          suffixIcon: Obx(
                () {
              if (controller.searchQuery.value.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: controller.clearSearch,
                icon: const Icon(Icons.clear),
              );
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _notesList(NoteController controller) {
    return RefreshIndicator(
      color: Colors.blue,
      onRefresh: controller.loadNotes,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          100,
        ),
        itemCount: controller.filteredNotes.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          final NoteModel note =
          controller.filteredNotes[index];

          return _noteCard(
            context,
            controller,
            note,
          );
        },
      ),
    );
  }

  Widget _noteCard(
      BuildContext context,
      NoteController controller,
      NoteModel note,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Get.to(
                () => UpdateNoteScreen(note: note),
          );

          controller.loadNotes();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            14,
            12,
            14,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  IconButton(
                    visualDensity:
                    VisualDensity.compact,
                    onPressed: () {
                      controller.deleteNote(note);
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                note.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1.4,
                  color:
                  colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  _categoryChip(
                    context,
                    note.category,
                  ),

                  const Spacer(),

                  Icon(
                    Icons.text_fields,
                    size: 15,
                    color:
                    colorScheme.onSurfaceVariant,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    '${note.body.length} chars',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                      colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(
      BuildContext context,
      String category,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color:
          colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _emptyNotes(
      BuildContext context,
      NoteController controller,
      ) {
    final bool isSearching =
        controller.searchQuery.value.isNotEmpty;

    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off
                  : Icons.note_alt_outlined,
              size: 64,
              color: Colors.blue,
            ),

            const SizedBox(height: 18),

            Text(
              isSearching
                  ? 'No notes found'
                  : 'No notes yet',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isSearching
                  ? 'Try another search.'
                  : 'Create your first note to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                color:
                colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(
      NoteController controller,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 52,
              color: Colors.blue,
            ),

            const SizedBox(height: 14),

            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: controller.loadNotes,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}