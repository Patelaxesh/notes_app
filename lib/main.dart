import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/controllers/note_controller.dart';
import 'package:notes/controllers/theme_controller.dart';
import 'package:notes/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(ThemeController());
  Get.put(NoteController());

  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
          () => GetMaterialApp(
        title: 'Notes',
        debugShowCheckedModeBanner: false,
        theme: themeController.lightTheme,
        darkTheme: themeController.darkTheme,
        themeMode: themeController.themeMode.value,
        home: const HomeScreen(),
      ),
    );
  }
}