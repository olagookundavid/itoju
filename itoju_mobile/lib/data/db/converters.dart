import 'dart:convert';
import 'package:drift/drift.dart';

/// Stores a List<String> (tags) as a JSON text column. Mirrors the backend's
/// TEXT[] tag columns; JSON keeps ordering and round-trips cleanly for sync.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final decoded = jsonDecode(fromDb);
    return (decoded as List).map((e) => e.toString()).toList();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
