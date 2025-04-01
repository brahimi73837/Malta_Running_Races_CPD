import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malta_running_races/models/race.dart';
import 'package:intl/intl.dart';
import 'package:malta_running_races/services/firebase_service.dart';
import 'package:malta_running_races/services/image_service.dart';
import 'package:malta_running_races/services/notifications.dart';
import 'package:malta_running_races/widgets/input_field.dart';
import 'package:malta_running_races/widgets/race_image.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class RaceDetails extends StatefulWidget {
  const RaceDetails({super.key, required this.race, this.onImageSelected});

  final Race race;
  final Function(int)? onImageSelected;

  @override
  _RaceDetailsState createState() => _RaceDetailsState();
}

class _RaceDetailsState extends State<RaceDetails> {
  String? _imagePath;
  final NotificationService _notificationService = NotificationService();
  final ImageService _imageService = ImageService();
  final FirebaseService _firebaseService = FirebaseService();
  late TextEditingController _nameController;
  late TextEditingController _distanceController;
  late TextEditingController _descriptionController;
  late String? _selectedLocation;
  List<String> _locations = [];
  DateTime? _selectedDate;
  final DateFormat _formatter = DateFormat('yyyy-MM-dd');
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.race.name);
    _distanceController = TextEditingController(text: widget.race.distance.toString());
    _descriptionController = TextEditingController(text: widget.race.description ?? '');
    _selectedLocation = widget.race.location;
    _selectedDate = widget.race.date;
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final data = await rootBundle.loadString('assets/cities.json');
      final jsonMap = json.decode(data) as Map<String, dynamic>;
      setState(() {
        _locations = jsonMap.values.cast<String>().toList();
        _locations.sort();
      });
    } catch (e) {
      _notificationService.showNotification(3, 'Error', 'Could not load locations');
      debugPrint('Error loading cities.json: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final imagePath = await _imageService.pickImage();
      if (imagePath != null) {
        final path = await _imageService.generateFilePath(XFile(imagePath));
        await _imageService.saveImageToAppDirectory(XFile(imagePath), path);

        setState(() {
          _imagePath = path;
          widget.race.images.add(path);
        });

        await _firebaseService.updateRaceImages(widget.race.id, widget.race.images);
        _notificationService.showNotification(2, 'Success!', 'Image added successfully!');
      }
    } catch (e) {
      _notificationService.showNotification(2, 'Fail!', 'Could not pick image!');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    try {
      final updatedRace = widget.race.copyWith(
        name: _nameController.text,
        location: _selectedLocation,
        date: _selectedDate,
        distance: double.tryParse(_distanceController.text) ?? widget.race.distance,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      );

      await _firebaseService.updateRace(updatedRace);

      if (mounted) {
        setState(() {
          widget.race.name = updatedRace.name;
          widget.race.location = updatedRace.location;
          widget.race.date = updatedRace.date;
          widget.race.distance = updatedRace.distance;
          widget.race.description = updatedRace.description;
          _isEditing = false;
        });
      }

      _notificationService.showNotification(2, 'Success!', 'Race updated successfully!');
      _toggleEditing();
    } catch (e) {
      _notificationService.showNotification(2, 'Error!', 'Failed to update race: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.race.name),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEditing,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEditing) ...[
                InputField(
                  label: "Name:",
                  controller: _nameController,
                ),
                InputField(
                  label: "Distance (km):",
                  controller: _distanceController,
                ),
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
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        _selectedDate != null 
                            ? _formatter.format(_selectedDate!)
                            : "Select Date",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                InputField(
                  label: "Description:",
                  controller: _descriptionController,
                  maxLines: 3,
                ),
              ] else ...[
                Text("Name: ${widget.race.name}", 
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                Text("Distance: ${widget.race.distance} km", 
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                Text("Location: ${widget.race.location}", 
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                Text("Date: ${_formatter.format(widget.race.date)}", 
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                if (widget.race.description != null && widget.race.description!.isNotEmpty) ...[
                const Text("Description:", 
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(widget.race.description!,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
              ],
            ],
              const SizedBox(height: 20),
              const Text(
                'Race Images:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < widget.race.images.length; i++)
                GestureDetector(
                  onTap: () {
                    if (widget.onImageSelected != null) {
                      widget.onImageSelected!(i);
                    }
                  },
                  child: RaceImage(imagePath: widget.race.images[i]),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Add Image'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}