import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:confetti/confetti.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  QuizPageState createState() => QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _question;
  List<String>? _options;
  String _selectedAnswer = '';
  bool _hasAttemptedToday = false;
  bool _isSignedIn = false;
  List<DocumentSnapshot>? _leaderboard;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _checkSignInStatus();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Function to check if user is signed in and fetch quiz
  Future<void> _checkSignInStatus() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _isSignedIn = true;
      });
      _checkQuizAttempt(user.uid);
    } else {
      setState(() {
        _isSignedIn = false;
        _question = "You must sign in to play.";
        _options = [];
      });
    }
  }

  // Function to check if the user has attempted the quiz today
  Future<void> _checkQuizAttempt(String userId) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('user').doc(userId).get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        String? lastAttemptDate = data['last_quiz_attempt_date'];

        if (lastAttemptDate != null && lastAttemptDate == formattedDate) {
          setState(() {
            _hasAttemptedToday = true;
            _question = "You've already taken the quiz today!";
            _options = [];
          });
          _fetchLeaderboard();
        } else {
          setState(() {
            _hasAttemptedToday = false;
          });
          await _fetchQuestion(); // Fetch the quiz if no attempt today
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking quiz attempt: $e')),
      );
    }
  }

  Future<void> _fetchLeaderboard() async {
    try {
      QuerySnapshot leaderboardSnapshot =
          await _firestore
              .collection('user')
              .orderBy('points', descending: true)
              .limit(10)
              .get();

      setState(() {
        _leaderboard = leaderboardSnapshot.docs;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('error getting leaderboard.')));
    }
  }

  // Function to fetch the daily quiz question
  Future<void> _fetchQuestion() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      DocumentSnapshot quizDoc =
          await _firestore.collection('daily_quiz').doc(formattedDate).get();

      if (quizDoc.exists) {
        Map<String, dynamic> data = quizDoc.data() as Map<String, dynamic>;

        if (data.containsKey('question') &&
            data['question'] is String &&
            data.containsKey('options') &&
            data['options'] is List<dynamic> &&
            data.containsKey('correct_answer') &&
            data['correct_answer'] is String) {
          setState(() {
            _question = data['question'];
            _options = List<String>.from(data['options']);
          });
        } else {
          setState(() {
            _question = "No quiz available today.";
            _options = [];
          });
        }
      } else {
        setState(() {
          _question = "No quiz available today.";
          _options = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching quiz: $e')));
    }
  }

  // Function to update points and mark quiz attempt
  Future<void> _updatePoints() async {
    User? user = _auth.currentUser;
    if (user != null && !_hasAttemptedToday) {
      try {
        String userId = user.uid;
        DocumentReference userDocRef = _firestore
            .collection('user')
            .doc(userId);

        // Fetch quiz data
        DocumentSnapshot quizDoc =
            await _firestore
                .collection('daily_quiz')
                .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
                .get();

        String feedback = 'No quiz available today.';
        int pointsToAdd = 0;

        if (quizDoc.exists) {
          String correctAnswer = quizDoc['correct_answer'];
          if (_selectedAnswer == correctAnswer) {
            pointsToAdd = 10;
            feedback = 'Correct!';
          } else {
            feedback = 'Incorrect.';
          }
        }

        if (pointsToAdd > 0) {
          await userDocRef.set({
            'points': FieldValue.increment(pointsToAdd),
            'last_quiz_attempt_date': DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime.now()),
          }, SetOptions(merge: true));

          // Fetch updated points after incrementing
          DocumentSnapshot updatedUserDoc = await userDocRef.get();
          int newTotalPoints =
              (updatedUserDoc.data() as Map<String, dynamic>)['points'] ?? 0;

          feedback += ' You now have $newTotalPoints points.';
        }

        setState(() {
          _hasAttemptedToday = true;
          _question = "You've already taken the quiz today!";
          _options = [];
          _fetchLeaderboard();
        });
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(feedback)));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating points: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already attempted the quiz today!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_question != null)
              Text(
                _question!,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),
            if (_options != null && !_hasAttemptedToday)
              ..._options!.map((option) {
                bool isSelected = _selectedAnswer == option;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.green : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedAnswer = option;
                      });
                    },
                    child: Text(option),
                  ),
                );
              }),
            SizedBox(height: 20),
            if (_isSignedIn && !_hasAttemptedToday)
              ElevatedButton(
                onPressed: () {
                  if (_selectedAnswer.isNotEmpty) {
                    _updatePoints(); // Update points
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please select an answer before submitting!',
                        ),
                      ),
                    );
                  }
                },
                child: Text('Submit Answer'),
              ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.3,
              ),
            ),
            if (_leaderboard != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Leaderboard:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _leaderboard!.length,
                        itemBuilder: (context, index) {
                          final userDoc = _leaderboard![index];
                          final data =
                              userDoc.data() as Map<String, dynamic>? ?? {};
                          final username = data['userName'] ?? 'Unknown';
                          final points = data['points'] ?? 0;

                          Color? tileColor;
                          switch (index) {
                            case 0:
                              tileColor = Colors.amber[400];
                              break;
                            case 1:
                              tileColor = Colors.grey[400];
                              break;
                            case 2:
                              tileColor = Colors.brown[300];
                              break;
                            default:
                              tileColor = null;
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                username,
                                style: TextStyle(color: Colors.purple),
                              ),
                              trailing: Text(
                                '$points points',
                                style: TextStyle(color: Colors.purple),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
