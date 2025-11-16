import 'package:flutter/material.dart';
import 'package:space_exploration/space_body.dart';

class SpaceBodyFactsPage extends StatelessWidget {
  final SpaceBody body;

  const SpaceBodyFactsPage({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(body.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: body.name,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(body.imagePath, height: 250),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                body.facts,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              Text(
                'Diameter: ${body.diameter} km',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Day Length: ${body.dayLength} hours',
                style: const TextStyle(fontSize: 16)),
              Text(
                'Year Length: ${body.yearLength} years',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Average Temperature: ${body.avgTemperature}°C',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Number of Moons: ${body.numberOfMoons}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
