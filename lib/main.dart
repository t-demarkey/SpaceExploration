import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:space_exploration/firebase_options.dart';
import 'package:space_exploration/pages/account_page.dart';
import 'package:space_exploration/pages/daily_photo.dart';
import 'package:space_exploration/pages/launch_service.dart';
import 'package:space_exploration/pages/learn.dart';
import 'package:space_exploration/pages/login_page.dart';
import 'package:space_exploration/pages/quiz_page.dart';
import 'auth_service.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: SpaceExploration(),
    ),
  );
}

// Class for Space Topics of the day
class SpaceTopic {
  final String title;
  final String description;

  SpaceTopic({required this.title, required this.description});
}

class SpaceExploration extends StatelessWidget {
  const SpaceExploration({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: HomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/account': (context) => AccountPage(),
      },
    ); //set theme dark since it is space related https://api.flutter.dev/flutter/material/MaterialApp/darkTheme.html
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<SpaceTopic> allTopics = [
    SpaceTopic(
      title: "Black Holes",
      description:
          "Mysterious regions of spacetime with immense gravitational pull.",
    ),
    SpaceTopic(
      title: "Mars Exploration",
      description:
          "Discovering the Red Planet with rovers and planned missions.",
    ),
    SpaceTopic(
      title: "Exoplanets",
      description: "Planets beyond our solar system, some possibly habitable.",
    ),
    SpaceTopic(
      title: "International Space Station",
      description: "A collaborative space station orbiting Earth.",
    ),
    SpaceTopic(
      title: "Lunar Missions",
      description: "Missions to the Moon, past, present, and future.",
    ),
    SpaceTopic(
      title: "Dark Matter",
      description:
          "An unknown form of matter that makes up most of the universe.",
    ),
    SpaceTopic(
      title: "Astrobiology",
      description: "The study of life in the universe.",
    ),
    SpaceTopic(
      title: "The Big Bang",
      description: "The prevailing theory of the origin of the universe.",
    ),
    SpaceTopic(
      title: "Galaxies",
      description: "Massive systems of stars, gas, and dark matter.",
    ),
    SpaceTopic(
      title: "Asteroids",
      description:
          "Rocky bodies orbiting the Sun, remnants of early solar system.",
    ),
    SpaceTopic(
      title: "Comets",
      description: "Icy bodies that develop tails when near the Sun.",
    ),
    SpaceTopic(
      title: "Solar Flares",
      description: "Explosive bursts of energy from the Sun.",
    ),
    SpaceTopic(
      title: "Nebulae",
      description: "Clouds of gas and dust where stars are born.",
    ),
    SpaceTopic(
      title: "Space Telescopes",
      description: "Telescopes in orbit, like Hubble and James Webb.",
    ),
    SpaceTopic(
      title: "Wormholes",
      description: "Theoretical passages through space-time.",
    ),
    SpaceTopic(
      title: "Space-Time",
      description: "The fabric of the universe combining space and time.",
    ),
    SpaceTopic(
      title: "Cosmic Microwave Background",
      description: "Radiation left over from the early universe.",
    ),
    SpaceTopic(
      title: "Gravity Waves",
      description: "Ripples in spacetime caused by massive objects.",
    ),
    SpaceTopic(
      title: "Colonizing Mars",
      description: "Long-term human settlement plans for Mars.",
    ),
    SpaceTopic(
      title: "Voyager Probes",
      description: "Historic spacecrafts now exploring interstellar space.",
    ),
  ];

  List<SpaceTopic> getRandomTopics() {
    //randomize 6 space topics
    final shuffled = [...allTopics]..shuffle();
    return shuffled.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topics = getRandomTopics();

    return Scaffold(
      appBar: AppBar(title: const Text("Space Exploration")),
      body: Column(
        children: [
          Text(
            "Below are the space topics of the day! Click on one to be presented a video!",
            style: TextStyle(color: Colors.deepPurple, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return AnimatedTopicTile(topic: topic);
              },
            ),
          ),
          LaunchCountdown(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 5,
              shrinkWrap: true,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizPage()),
                    );
                  },
                  child: const Text(
                    "Daily Quiz",
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Learn()),
                    );
                  },
                  child: const Text(
                    "Learn Section",
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NasaPage()),
                    );
                  },
                  child: const Text(
                    "NASA Picture of the Day",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Account",
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//video player via youtube player https://pub.dev/packages/youtube_player_iframe
class TopicVideoPage extends StatefulWidget {
  final String videoId;

  const TopicVideoPage({required this.videoId, super.key});

  @override
  State<TopicVideoPage> createState() => _TopicVideoPageState();
}

class _TopicVideoPageState extends State<TopicVideoPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    )..loadVideoById(videoId: widget.videoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("YouTube Video")),
      body: Center(child: YoutubePlayer(controller: _controller)),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

//videos for each topic
String getVideoIdForTopic(String title) {
  switch (title) {
    case "Black Holes":
      return "QqsLTNkzvaY"; // NASA video on black holes
    case "Mars Exploration":
      return "V2AyDjcGRrk"; //Mars video
    case "Exoplanets":
      return "7ATtD8x7vV0"; //expoplanet videos
    case "International Space Station":
      return "uzo0ScxuNmg"; //ISS videos
    case "Lunar Missions":
      return "_T8cn2J13-4"; //Lunar Missions videos
    case "Dark Matter":
      return "QAa2O_8wBUQ"; //dark matter videos
    case "Astrobiology":
      return "0v86Yk14rf8"; //astrobio videos
    case "The Big Bang":
      return "wNDGgL73ihY"; //big bang video
    case "Galaxies":
      return "I82ADyJC7wE";
    case "Asteroids":
      return "auxpcdQimCs";
    case "Comets":
      return "yB9HHyPpKds";
    case "Solar Flares":
      return "oHHSSJDJ4oo";
    case "Nebulae":
      return "W8UI7F43_Yk";
    case "Space Telescopes":
      return "O6YuhjQrgk0";
    case "Wormholes":
      return "9P6rdqiybaw";
    case "Space-Time":
      return "3khY_bwf5FY";
    case "Cosmic Microwave Background":
      return "3tCMd1ytvWg";
    case "Gravity Waves":
      return "iphcyNWFD10";
    case "Colonizing Mars":
      return "ax4wtOTaX7o";
    case "Voyager Probes":
      return "lbl_4TnPIGM";
    default:
      return "lbl_4TnPIGM"; // fallback to ISS
  }
}

class AnimatedTopicTile extends StatefulWidget {
  final SpaceTopic topic;

  const AnimatedTopicTile({super.key, required this.topic});

  @override
  State<AnimatedTopicTile> createState() => _AnimatedTopicTileState();
}

class _AnimatedTopicTileState extends State<AnimatedTopicTile> {
  bool _tapped = false;

  @override
  Widget build(BuildContext context) {
    return Animate(
      key: ValueKey(_tapped), // Rebuild when tapped
      effects:
          _tapped
              ? [
                ScaleEffect(duration: 200.ms, curve: Curves.easeOut),
                FadeEffect(duration: 200.ms),
              ]
              : [],
      onComplete: (controller) {
        if (_tapped) {
          setState(() => _tapped = false); // reset for next tap
          String videoId = getVideoIdForTopic(widget.topic.title);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TopicVideoPage(videoId: videoId),
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () => setState(() => _tapped = true),
        child: Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              widget.topic.title,
              style: const TextStyle(color: Colors.greenAccent),
            ),
            subtitle: Text(widget.topic.description),
          ),
        ),
      ),
    );
  }
}