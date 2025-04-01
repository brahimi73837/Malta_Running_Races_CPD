import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:malta_running_races/models/race.dart';

class FirebaseService {
  static const String _baseUrl = 'races-malta-default-rtdb.europe-west1.firebasedatabase.app';
  static const String _endpoint = 'races.json';
  
  Uri get _url => Uri.https(_baseUrl, _endpoint);

  Future<void> saveRace(Race race) async {
    try {
      final response = await http.post(
        _url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_raceToJson(race)),
      );

      if (response.statusCode >= 400) {
        throw HttpException('Failed to save race: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error saving race: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _raceToJson(Race race) {
    final formatter = DateFormat('yyyy-MM-dd');
    return {
      'name': race.name,
      'location': race.location,
      'date': formatter.format(race.date),
      'distance': race.distance,
      'images': race.images,
      'description': race.description,
    };
  }

  Future<void> updateRace(Race race) async {
  final updateUrl = Uri.https(
    'races-malta-default-rtdb.europe-west1.firebasedatabase.app',
    'races/${race.id}.json',
  );

  await http.patch(
    updateUrl,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'name': race.name,
      'location': race.location,
      'date': DateFormat('yyyy-MM-dd').format(race.date),
      'distance': race.distance,
      'description': race.description,
    }),
  );
}

  Future<void> updateRaceImages(String raceId, List<String> images) async {
    final updateUrl = Uri.https(
      'races-malta-default-rtdb.europe-west1.firebasedatabase.app',
      'races/$raceId.json',
    );

    await http.patch(
      updateUrl,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'images': images,
      }),
    );
  }

  Future<List<Race>> loadRaces() async {
      final response = await http.get(_url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> firebaseData = json.decode(response.body);

        if (firebaseData.isNotEmpty) {
          final List<Race> loadedList = [];
          firebaseData.forEach((id, raceData) {
            final Race race = Race(
              id: id,
              name: raceData["name"],
              location: raceData["location"],
              date: DateTime.parse(raceData["date"]),
              distance: raceData["distance"],
              images: List<String>.from(raceData["images"] ?? []),
              description: raceData["description"],
            );
            loadedList.add(race);
          });

          return loadedList;
        }
      }
      return [];
    }
}
