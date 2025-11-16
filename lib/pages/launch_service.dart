import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:http/http.dart' as http;

// Fetches the next launch from Launch Library 2 API
Future<Map<String, dynamic>?> fetchNextLaunch() async {
  final response = await http.get(
    Uri.parse(
      'https://ll.thespacedevs.com/2.2.0/launch/upcoming/?limit=1&ordering=net&status=1',
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final launch = data['results'][0];
    return {
      'name': launch['name'],
      'net': launch['net'], // No Earlier Than
    };
  } else {
    return null;
  }
}

class LaunchCountdown extends StatefulWidget {
  const LaunchCountdown({super.key});

  @override
  State<LaunchCountdown> createState() => _LaunchCountdownState();
}

class _LaunchCountdownState extends State<LaunchCountdown> {
  String? launchName;
  int? launchTimestamp;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    loadLaunch();

    // Refresh every 4 minutes
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 4),
      (timer) => loadLaunch(),
    );
  }

  Future<void> loadLaunch() async {
    final launch = await fetchNextLaunch();
    if (launch != null) {
      final launchTime = DateTime.parse(launch['net']);
      setState(() {
        launchName = launch['name'];
        launchTimestamp = launchTime.millisecondsSinceEpoch;
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          launchName == null || launchTimestamp == null
              ? const CircularProgressIndicator()
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next Space Rocket Launch:', style: TextStyle(color: Colors.deepPurple),),
                  const SizedBox(height: 8),
                  Text(
                    launchName!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CountdownTimer(
                    endTime: launchTimestamp!,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      color: Colors.greenAccent,
                    ),
                    onEnd: () {
                      // Optional: refresh again when countdown ends
                      loadLaunch();
                    },
                  ),
                ],
              ),
    );
  }
}
