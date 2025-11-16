class SpaceBody {
  final String name;
  final String imagePath;
  final String facts;
  final double diameter;
  final double dayLength;
  final double yearLength; // in Earth years
  final double avgTemperature; // in Celsius
  final int numberOfMoons;
  SpaceBody({
    required this.name,
    required this.imagePath,
    required this.facts,
    required this.diameter,
    required this.dayLength,
    required this.yearLength,
    required this.avgTemperature,
    required this.numberOfMoons,
  });
}