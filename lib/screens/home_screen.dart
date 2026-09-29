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
    final NoteController controller = Get.find<NoteController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final RxBool isGridView = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        flexibleSpace: Obx(
              () => Container(
            decoration: BoxDecoration(
              gradient: themeController.currentGradient,
            ),
          ),
        ),
        actions: [
          Obx(
                () => IconButton(
              tooltip: isGridView.value ? 'List view' : 'Grid view',
              onPressed: () => isGridView.value = !isGridView.value,
              icon: Icon(
                isGridView.value
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
              ),
            ),
          ),
          Obx(
                () => IconButton(
              tooltip: 'Change theme',
              onPressed: themeController.toggleTheme,
              icon: Icon(
                themeController.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _searchBox(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _errorView(controller, themeController);
              }

              if (controller.filteredNotes.isEmpty) {
                return _emptyNotes(context, controller, themeController);
              }

              return isGridView.value
                  ? _notesGrid(controller, themeController)
                  : _notesList(controller, themeController);
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(
            () => Container(
          decoration: BoxDecoration(
            gradient: themeController.currentGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: themeController.currentGradient.colors.first
                    .withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            onPressed: () async {
              await Get.to(() => const AddNoteScreen());
              controller.loadNotes();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'New Note',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBox(NoteController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: controller.searchNotes,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              tooltip: 'Clear search',
              onPressed: controller.clearSearch,
              icon: const Icon(Icons.clear_rounded),
            );
          }),
        ),
      ),
    );
  }

  Widget _notesList(
      NoteController controller,
      ThemeController themeController,
      ) {
    return RefreshIndicator(
      onRefresh: controller.loadNotes,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: controller.filteredNotes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final note = controller.filteredNotes[index];
          return _noteCard(context, controller, note, themeController);
        },
      ),
    );
  }

  Widget _notesGrid(
      NoteController controller,
      ThemeController themeController,
      ) {
    return RefreshIndicator(
      onRefresh: controller.loadNotes,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.82,
        ),
        itemCount: controller.filteredNotes.length,
        itemBuilder: (context, index) {
          final note = controller.filteredNotes[index];
          return _noteGridCard(context, controller, note, themeController);
        },
      ),
    );
  }

  Widget _noteCard(
      BuildContext context,
      NoteController controller,
      NoteModel note,
      ThemeController themeController,
      ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            themeController.currentGradient.colors.first.withOpacity(0.12),
            themeController.currentGradient.colors.last.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: themeController.currentGradient.colors.first.withOpacity(0.35),
          width: 1.4,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Get.to(() => UpdateNoteScreen(note: note));
            controller.loadNotes();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Delete note',
                      onPressed: () => controller.deleteNote(note),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  note.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.4,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _categoryChip(note.category, themeController),
                    const Spacer(),
                    Icon(
                      Icons.text_fields_rounded,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${note.body.length} chars',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _noteGridCard(
      BuildContext context,
      NoteController controller,
      NoteModel note,
      ThemeController themeController,
      ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            themeController.currentGradient.colors.first.withOpacity(0.12),
            themeController.currentGradient.colors.last.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: themeController.currentGradient.colors.first.withOpacity(0.35),
          width: 1.4,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Get.to(() => UpdateNoteScreen(note: note));
            controller.loadNotes();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Delete note',
                      onPressed: () => controller.deleteNote(note),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    note.body,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1.35,
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _categoryChip(note.category, themeController),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.text_fields_rounded,
                      size: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${note.body.length} chars',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String category, ThemeController themeController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: themeController.currentGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _emptyNotes(
      BuildContext context,
      NoteController controller,
      ThemeController themeController,
      ) {
    final isSearching = controller.searchQuery.value.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: themeController.currentGradient,
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.note_alt_outlined,
                size: 42,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              isSearching ? 'No notes found' : 'No notes yet',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try another search.'
                  : 'Create your first note to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(
      NoteController controller,
      ThemeController themeController,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: themeController.currentGradient,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: themeController.currentGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: controller.loadNotes,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}