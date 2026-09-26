import 'package:notes/models/note_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MyDb {
  Future<Database> database() async {
    final db = openDatabase(
      join(await getDatabasesPath(), 'notes_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE notes('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT NOT NULL, '
          'body TEXT NOT NULL'
          ')',
        );
      },
      version: 1,
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
