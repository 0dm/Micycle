import 'dart:async';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static DatabaseHelper get instance => _instance;
  static late Database _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database.isOpen) return _database;
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'bike_station.db');
    return await databaseFactoryFfiWeb.openDatabase(path);
  }

  Future<int> insertBikeStation(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('BikeStation', row);
  }

  Future<List<Map<String, dynamic>>> getBikeStations() async {
    Database db = await database;
    return await db.query('BikeStation');
  }

  Future<int> updateBikeStation(Map<String, dynamic> row) async {
    Database db = await database;
    int station = row['Station'];
    int bike = row['Bike'];
    return await db.update('BikeStation', row,
        where: 'Station = ? AND Bike = ?', whereArgs: [station, bike]);
  }

  Future<int> deleteBikeStation(int station, int bike) async {
    Database db = await database;
    return await db.delete('BikeStation',
        where: 'Station = ? AND Bike = ?', whereArgs: [station, bike]);
  }
}
