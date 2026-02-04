import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/places_service.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng currentLocation;
  const LocationPickerScreen({super.key, required this.currentLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? pickup;
  LatLng? drop;

  final pickupCtrl = TextEditingController();
  final dropCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    pickup = widget.currentLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Set pickup & drop",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _typeAhead(
                controller: pickupCtrl,
                hint: "Pickup location",
                onSelect: (lat, lng, address) {
                  pickup = LatLng(lat, lng);
                  pickupCtrl.text = address;
                },
              ),
              const SizedBox(height: 16),
              _typeAhead(
                controller: dropCtrl,
                hint: "Drop location",
                onSelect: (lat, lng, address) {
                  drop = LatLng(lat, lng);
                  dropCtrl.text = address;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7AAB98),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: pickup != null && drop != null
                    ? () {
                        Navigator.pop(context, {
                          'pickup': pickup,
                          'drop': drop,
                        });
                      }
                    : null,
                child: const Text("Confirm locations"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeAhead({
    required TextEditingController controller,
    required String hint,
    required Function(double, double, String) onSelect,
  }) {
    return TypeAheadField<Map<String, dynamic>>(
      debounceDuration: const Duration(milliseconds: 300),
      hideOnEmpty: true,
      hideSuggestionsOnKeyboardHide: false,

      suggestionsCallback: (pattern) async {
        if (pattern.length < 2) return [];
        return await PlacesService.getSuggestions(pattern);
      },

      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(suggestion['description']),
        );
      },

      onSuggestionSelected: (suggestion) async {
        final d = await PlacesService.getPlaceDetails(suggestion['place_id']);
        onSelect(d['lat'], d['lng'], d['address']);
      },

      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        cursorColor: Colors.black,
        keyboardType: TextInputType.streetAddress,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
