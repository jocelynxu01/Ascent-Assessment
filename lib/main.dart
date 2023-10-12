import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => LandingPage();
}

class MyContentPage extends StatefulWidget {
  const MyContentPage({super.key, required this.title});

  final String title;

  @override
  State<MyContentPage> createState() => ContentPage();
}

class LandingPage extends State<MyHomePage> {
  late ShakeDetector shakeDetector;

  @override
  void initState() {
    super.initState();
    shakeDetector = ShakeDetector.autoStart(onPhoneShake: () {
      navigateToContentPage();
    });
  }

  @override
  void dispose() {
    shakeDetector.stopListening();
    super.dispose();
  }

  void navigateToContentPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MyContentPage(title: 'content page'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: 660,
            child: Image.asset(
              ('images/dog bone background.jpg'),
              fit: BoxFit.cover,
             ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 350.0),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white
            )
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 100),
                SizedBox(
                    width: 190,
                    child: Image.asset(
                      ('images/dog_icon.png'), 
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'My Dog Fact App',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () {
                    navigateToContentPage();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 70),
                    backgroundColor: const Color(0xFF1E4799) // Set the button color to dark blue
                  ),
                  child: const Text('Shake for Facts!', style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContentPage extends State<MyContentPage> {
  bool isHome = true;
  bool isLiked = false;
  String dogFact = 'Loading fact...';
  late ShakeDetector shakeDetector;

  Future<void> loadJsonAsset() async {
    final String jsonString = await rootBundle.loadString('dog_facts.json');
    final data = jsonDecode(jsonString);

    if (data['facts'] is List) {
      final List<dynamic> facts = data['facts'];
      final random = Random();
      final factIndex = random.nextInt(facts.length);
      final fact = facts[factIndex];
      setState(() {
        dogFact = fact;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadJsonAsset();
    shakeDetector = ShakeDetector.autoStart(onPhoneShake: () {
      updateDogFact();
    });
  }

  @override
  void dispose() {
    shakeDetector.stopListening();
    super.dispose();
  }

  void updateDogFact() {
    loadJsonAsset();
  }

Future<void> saveFavoriteFact(String fact) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/favorite_facts.txt');
  // File: '/data/user/0/com.example.dog_facts_app/app_flutter/favorite_facts.txt'

  // Write the fact to the file
  await file.writeAsString('$fact\n', mode: FileMode.append);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E4799),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50),
            Padding(padding: const EdgeInsets.only(left: 8, right:8),child: 
              Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    // Top half: Image
                    SizedBox(
                      child: Image.asset(
                        ('images/dog.png'), 
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Bottom half: Text
                    const SizedBox(height: 30.0),
                      Container(
                        height: 180,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Text(
                              dogFact,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      // Like button
                    const SizedBox(height: 16.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                            ),
                            onPressed: () {
                              setState(() {
                                isLiked = !isLiked; 
                                if (isLiked) {
                                  saveFavoriteFact(dogFact);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                  ],
                 )
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 50.0), 
              child: ElevatedButton(
                onPressed: () {
                  updateDogFact();
                  isLiked = false;
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 70), 
                ),
                child: const Text('Shake for Facts!', style: TextStyle(fontSize: 15)),
              ),
            )
          ],
        ),
      ),
    );
  }
}