import 'package:flutter/material.dart';
import 'package:space_exploration/pages/space_body_facts_page.dart';
import 'package:space_exploration/space_body.dart';
import 'package:geolocator/geolocator.dart';
import 'package:space_exploration/pages/visible_planets.dart';

final List<SpaceBody> spaceBodies = [
  SpaceBody(
    name: 'Sun',
    imagePath: 'assets/photos/sun.jpg',
    facts: 'The Sun is the star at the center of the Solar System.',
    diameter: 1392000,
    dayLength: 609.12,
    yearLength: 0.0002,
    avgTemperature: 5778,
    numberOfMoons: 0,
  ),
  SpaceBody(
    name: 'Mercury',
    imagePath: 'assets/photos/mercury.jpg',
    facts: 'Mercury is the closest planet to the Sun.',
    diameter: 4879,
    dayLength: 1407.5,
    yearLength: 0.24,
    avgTemperature: 167,
    numberOfMoons: 0,
  ),
  SpaceBody(
    name: 'Venus',
    imagePath: 'assets/photos/venus.jpg',
    facts: 'Venus is the hottest planet.',
    diameter: 12104,
    dayLength: 5832.5,
    yearLength: 0.615,
    avgTemperature: 464,
    numberOfMoons: 0,
  ),
  SpaceBody(
    name: 'Earth',
    imagePath: 'assets/photos/earth.jpg',
    facts: 'Earth is our home planet.',
    diameter: 12742,
    dayLength: 24.0,
    yearLength: 1.0,
    avgTemperature: 14,
    numberOfMoons: 1,
  ),
  SpaceBody(
    name: 'Mars',
    imagePath: 'assets/photos/mars.png',
    facts: 'Mars is known as the red planet.',
    diameter: 6779,
    dayLength: 24.6,
    yearLength: 1.88,
    avgTemperature: -60,
    numberOfMoons: 2,
  ),
  SpaceBody(
    name: 'Jupiter',
    imagePath: 'assets/photos/jupiter.jpg',
    facts: 'Jupiter is the largest planet.',
    diameter: 139820,
    dayLength: 9.9,
    yearLength: 11.86,
    avgTemperature: -108,
    numberOfMoons: 80,
  ),
  SpaceBody(
    name: 'Saturn',
    imagePath: 'assets/photos/saturn.jpg',
    facts: 'Saturn is famous for its rings.',
    diameter: 116460,
    dayLength: 10.7,
    yearLength: 29.46,
    avgTemperature: -139,
    numberOfMoons: 82,
  ),
  SpaceBody(
    name: 'Uranus',
    imagePath: 'assets/photos/uranus.jpg',
    facts: 'Uranus rotates on its side.',
    diameter: 50724,
    dayLength: 17.2,
    yearLength: 84.01,
    avgTemperature: -197,
    numberOfMoons: 27,
  ),
  SpaceBody(
    name: 'Neptune',
    imagePath: 'assets/photos/neptune.jpg',
    facts: 'Neptune is the farthest known planet.',
    diameter: 49244,
    dayLength: 16.1,
    yearLength: 164.79,
    avgTemperature: -201,
    numberOfMoons: 14,
  ),
  SpaceBody(
    name: 'Pluto',
    imagePath: 'assets/photos/pluto.jpg',
    facts: 'Pluto is a dwarf planet.',
    diameter: 2376,
    dayLength: 153.3,
    yearLength: 248.0,
    avgTemperature: -229,
    numberOfMoons: 5,
  ),
];

class Learn extends StatefulWidget {
  const Learn({super.key});

  @override
  State<Learn> createState() => _LearnState();
}

class _LearnState extends State<Learn> {
  Future<void> _showVisiblePlanets() async {
    try {
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

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final visiblePlanets = await getVisiblePlanets(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Visible Planets"),
              content:
                  visiblePlanets.isNotEmpty
                      ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            visiblePlanets
                                .map((planet) => Text(planet))
                                .toList(),
                      )
                      : const Text("No planets are currently visible."),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Error"),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn About Space')),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: spaceBodies.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final body = spaceBodies[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpaceBodyFactsPage(body: body),
                ),
              );
            },
            child: Hero(
              tag: body.name,
              child: GridTile(
                footer: GridTileBar(
                  backgroundColor: Colors.black54,
                  title: Text(body.name, textAlign: TextAlign.center),
                ),
                child: Image.asset(body.imagePath, fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showVisiblePlanets,
        icon: const Icon(Icons.visibility),
        label: const Text('Visible Planets'),
      ),
    );
  }
}
