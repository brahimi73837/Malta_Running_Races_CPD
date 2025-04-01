import 'package:flutter/material.dart';
import 'package:malta_running_races/models/race.dart';
import 'package:malta_running_races/widgets/race_item.dart';


class RacesScreen extends StatelessWidget {
  const RacesScreen({
    super.key,
    required this.allRaces,
    this.onRaceSelected,
    required this.onRefresh, 
  });

  final List<Race> allRaces;
  final Function(Race)? onRaceSelected;
  final Future<void> Function() onRefresh;  

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24.0, top: 15.0, right: 24.0, bottom: 0),
          child: Text(
            'Races:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            color: Colors.orange,
            child: GridView(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              children: [
                if (allRaces.isNotEmpty)
                  for (final race in allRaces)
                    RaceItem(
                      race: race,
                      onSelectRace: () {
                        if (onRaceSelected != null) {
                          onRaceSelected!(race);
                        }
                      },
                    ),
                if (allRaces.isEmpty)
                  const Center(
                    child: Text(
                      'No races found',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}