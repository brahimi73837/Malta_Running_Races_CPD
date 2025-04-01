import 'package:flutter/material.dart';
import 'package:malta_running_races/models/race.dart';
import 'package:malta_running_races/services/firebase_service.dart';
import 'package:malta_running_races/services/image_service.dart';
import 'package:malta_running_races/services/notifications.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malta_running_races/widgets/input_field.dart';
import 'package:malta_running_races/widgets/race_image.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class AddRace extends StatefulWidget {
  const AddRace({required this.switchToViewRaces, super.key});
  final VoidCallback switchToViewRaces;

  @override
  State<AddRace> createState() => _AddRaceState();
}

class _AddRaceState extends State<AddRace> {
  final _nameController = TextEditingController();
  final _distanceController = TextEditingController();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final uuid = Uuid();
  final NotificationService _notificationService = NotificationService();
  final ImageService _imageService = ImageService();
  final FirebaseService _firebaseService = FirebaseService();
  final _descriptionController = TextEditingController();

  DateTime? _date;
  String? _imagePath;
  String? _selectedLocation;
  List<String> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
  try {
    final data = await rootBundle.loadString('assets/cities.json');
    final jsonMap = json.decode(data) as Map<String, dynamic>;
    setState(() {
      _locations = jsonMap.values.cast<String>().toList();
      _locations.sort(); // sort alphabetically
    });
  } catch (e) {
    _notificationService.showNotification(
      3, 'Error', 'Could not load locations');
    debugPrint('Error loading cities.json: $e');
  }
}

  void _presentDatePicker() async {
    var now = DateTime.now();
    var firstDate = DateTime(now.year - 30, now.month, now.day);

    var tmpDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
      initialDate: now,
    );

    if (tmpDate != null) {
      setState(() {
        _date = tmpDate;
      });
    }
  }

  void _pickImage() async {
    try {
      final imagePath = await _imageService.pickImage();
      if (imagePath != null) {
        setState(() {
          _imagePath = imagePath;
        });
      }
    } catch (e) {
      _notificationService.showNotification(
          2, 'Fail!', 'Could not pick image!');
    }
  }

  void _submitRace() async {
    if (_nameController.text.trim().isEmpty ||
        _distanceController.text.trim().isEmpty ||
        _date == null ||
        _imagePath == null ||
        _selectedLocation == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Missing Inputs",
              style: TextStyle(color: Colors.white)),
          content: const Text("There are some inputs left empty!",
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      try {
        final path = await _imageService.generateFilePath(XFile(_imagePath!));
        await _imageService.saveImageToAppDirectory(XFile(_imagePath!), path);

        Race race = Race(
          id: uuid.v4(),
          name: _nameController.text,
          location: _selectedLocation!,
          date: _date!,
          distance: double.parse(_distanceController.text),
          images: [path],
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        );

        await _firebaseService.saveRace(race);

        setState(() {
          _imagePath = path;
        });
        _notificationService.showNotification(
            2, 'Success!', 'Race was saved to firebase!');

        widget.switchToViewRaces();
      } catch (e) {
         _notificationService.showNotification(
            2, 'Fail!', 'Race could not be saved to firebase!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Race Details:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              InputField(label: "Name:", controller: _nameController),
              InputField(label: "Distance (km):", controller: _distanceController),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                items: _locations.map((location) => DropdownMenuItem<String>(
                  value: location,
                  child: Text(location, style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (value) => setState(() => _selectedLocation = value),
                decoration: const InputDecoration(
                  labelText: 'Location',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Date:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(
                    width: 225,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.white, width: 1.0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _date == null
                                ? "No Date Selected"
                                : formatter.format(_date!),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_month,
                                color: Colors.white),
                            onPressed: _presentDatePicker,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              InputField(
                label: "Description (optional):",
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Add Image'),
                ),
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: 20),
                Center(
                  child: RaceImage(imagePath: _imagePath!),
                ),
              ],
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitRace,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Save Race'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}