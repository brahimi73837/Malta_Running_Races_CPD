import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malta_running_races/models/race.dart';
import 'package:malta_running_races/widgets/race_image.dart';



class RaceItem extends StatelessWidget {
  RaceItem({super.key, required this.race, required this.onSelectRace});

  final Race race;
  final VoidCallback onSelectRace;
  final DateFormat formatter = DateFormat('MMM dd, yyyy');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelectRace,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            RaceImage(imagePath: race.images[0]),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    race.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStatItem(Icons.location_on, race.location),
                      const SizedBox(width: 12),
                      _buildStatItem(Icons.directions_run, '${race.distance} km'),
                      const SizedBox(width: 12),
                      _buildStatItem(Icons.calendar_today, 
                        formatter.format(race.date)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}