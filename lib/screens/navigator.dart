import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:malta_running_races/models/race.dart';
import 'package:malta_running_races/screens/add_race.dart';
import 'package:malta_running_races/screens/race_details.dart';
import 'package:malta_running_races/screens/view_races.dart';

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({super.key});

  @override
  State<NavigatorScreen> createState() {
    return _NavigatorScreenState();
  }
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  int _selectedPageIndex = 0;
  int? _selectedImageIndex;

  Future<List<Race>> _loadRaces() async {
    final url = Uri.https(
      'races-malta-default-rtdb.europe-west1.firebasedatabase.app',
      'races.json',
    );

    try {
      final response = await http.get(url);

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
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _switchToViewRaces() {
    setState(() {
      _selectedPageIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage;

    if (_selectedPageIndex == 1) {
      activePage = AddRace(
        switchToViewRaces: _switchToViewRaces,
      );
    } else {
      activePage = FutureBuilder<List<Race>>(
    future: _loadRaces(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else {
        final races = snapshot.data ?? [];
        return RacesScreen(
          allRaces: races,
          onRaceSelected: (race) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => RaceDetails(
                  race: race,
                  onImageSelected: (index) {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                ),
              ),
            );
          },
          onRefresh: () async {
            setState(() {}); // to reload races
          },
        );
      }
    },
  );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Races Tracker",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF424141),
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF424141),
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cases_outlined),
            label: 'View Races',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_outlined),
            label: 'Add Races',
          ),
        ],
      ),
    );
  }
}
