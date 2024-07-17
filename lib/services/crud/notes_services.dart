import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:notes/services/crud/crud_exceptions.dart';
import "package:sqflite/sqflite.dart";
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';



class NotesService {
  Database? _db;

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailCloumn: email.toLowerCase(),
    });
    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CoudNotDeleteUser();
    }
  }

  Future<DataBaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';

    //create the node
    final noteId = await db.insert(notesTable, {
      userIdCloumn: owner.id,
      textCloumn: text,
      isSyncedWithCloudCloumn: 1,
    });

    final note = DataBaseNote(
        id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);
    return note;
  }

  Future<DataBaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final note = await db.query(
      notesTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [id],
    );
    if (note.isEmpty) {
      throw CouldNoteFindNote();
    } else {
      return DataBaseNote.fromRow(note.first);
    }
  }

  Future<DataBaseNote> updateNotes({
    required DataBaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    final updateCount = await db.update(notesTable, {
      textCloumn: text,
      isSyncedWithCloudCloumn: 0,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateNotes();
    } else {
      return getNote(id: note.id);
    }
  }

  Future<Iterable<DataBaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);
    return notes.map((notesrow) => DataBaseNote.fromRow(notesrow));
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      notesTable,
      where: 'id=?',
      whereArgs: [id],
    );

    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<int> deleteAllNote() async {
    final db = _getDatabaseOrThrow();
    final rowsDeleted = await db.delete(notesTable);
    return rowsDeleted;
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenExcpetion();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //create user table
      await db.execute(createUserTable);
      //create user table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailCloumn] as String;

  @override
  String toString() => 'person,ID=$id,email=$email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DataBaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DataBaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DataBaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdCloumn] as int,
        text = map[textCloumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudCloumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note,ID=$id , userId=$userId, isSyncedWithCloud=$isSyncedWithCloud, text=$text';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const notesTable = 'note';
const userTable = 'user';
const idColumn = "id";
const emailCloumn = 'email';
const userIdCloumn = 'user_id';
const textCloumn = 'text';
const isSyncedWithCloudCloumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';

const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
)
''';
