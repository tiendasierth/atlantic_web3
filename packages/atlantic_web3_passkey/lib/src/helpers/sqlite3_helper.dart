import 'package:atlantic_web3/atlantic_web3.dart';

final class Sqlite3Helper {
  static Integer booleanToSqlite(Boolean input) => input == true ? 1 : 0;

  static Boolean sqliteToBoolean(Integer input) => input == 1 ? true : false;

  static String dateToSqlite(DateTime input) => input.toIso8601String();

  static DateTime sqliteToDate(String input) {
    if (input.isDate()) {
      return DateTime.parse(input);
    } else {
      List<String> result = input.substring(0, 10).split('-');
      return DateTime(int.parse(result.elementAt(0)),
          int.parse(result.elementAt(1)), int.parse(result.elementAt(2)));
    }
  }
}
