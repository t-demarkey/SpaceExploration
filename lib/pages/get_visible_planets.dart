import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:space_exploration/pages/visible_planets.dart';


class LocationExamplePage extends StatefulWidget {
  const LocationExamplePage({super.key});

  @override
  LocationExamplePageState createState() => LocationExamplePageState();
}

class LocationExamplePageState extends State<LocationExamplePage> {
  String status = 'Getting location...';
  List<String> visiblePlanets = [];

  @override
  void initState() {
    super.initState();
    _fetchLocationAndPlanets();
  }

  Future<void> _fetchLocationAndPlanets() async {
    try {
      Position position = await getLocation();
      setState(() {
        status = 'Fetching visible planets...';
      });

      final planets = await getVisiblePlanets(position.latitude, position.longitude);

      setState(() {
        visiblePlanets = planets;
        status = 'Visible planets found!';
      });
    } catch (e) {
      setState(() {
        status = 'Error: $e';
      });
    }
  }

  Future<Position> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Location services are disabled.");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied.");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stargazing Mode")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: visiblePlanets.isEmpty
            ? Center(child: Text(status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Planets currently visible above you:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: visiblePlanets.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.black,
                          child: ListTile(
                            title: Text(
                              visiblePlanets[index].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            leading: const Icon(Icons.public, color: Colors.purpleAccent),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
