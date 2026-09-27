import 'package:notes/models/note_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MyDb {
  Future<Database> database() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'notes_database.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE notes('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT NOT NULL, '
          'body TEXT NOT NULL, '
          'category TEXT NOT NULL'
          ')',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE notes ADD COLUMN category TEXT NOT NULL DEFAULT 'Personal'",
          );
        }
      },
    );

    return db;
  }

  Future<List<NoteModel>> getNotes() async {
    final db = await database();

    final data = await db.query('notes', orderBy: 'id DESC');

    return data.map((note) {
      return NoteModel.fromMap(note);
    }).toList();
  }

  Future<void> insertNote(NoteModel note) async {
    final db = await database();

    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNote(NoteModel note) async {
    final db = await database();

    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(NoteModel note) async {
    final db = await database();

    await db.delete('notes', where: 'id = ?', whereArgs: [note.id]);
  }
}
