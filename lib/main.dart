import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(DhumTracker());
}

class DhumTracker extends StatefulWidget {
  @override
  _DhumTrackerState createState() => _DhumTrackerState();
}

class _DhumTrackerState extends State<DhumTracker> {
  Map<String, Map<String, dynamic>> cigarettes = {
    'Marlboro Reds': {'count': 0, 'nicotine': '0.8 mg'},
    'Marlboro Advance': {'count': 0, 'nicotine': '0.5 mg'},
    'Garam': {'count': 0, 'nicotine': '0 mg'},
    'Black': {'count': 0, 'nicotine': '0.2 mg'},
    'Camel': {'count': 0, 'nicotine': '0.7 mg'},
  };

  int totalSmoked = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalSmoked = prefs.getInt("totalSmoked") ?? 0;
      cigarettes.keys.forEach((cigarette) {
        cigarettes[cigarette]!['count'] = prefs.getInt(cigarette) ?? 0;
      });
    });
  }

  Future<void> _increment(String type) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cigarettes[type]!['count'] = (cigarettes[type]!['count'] ?? 0) + 1;
      totalSmoked += 1;
    });
    await prefs.setInt(type, cigarettes[type]!['count']);
    await prefs.setInt("totalSmoked", totalSmoked);
  }

  Future<void> _reset() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cigarettes.forEach((key, value) {
        value['count'] = 0;
      });
      totalSmoked = 0;
    });
    prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("DHUM TRACKER"),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Total Smoked: $totalSmoked",
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            Expanded(
              child: ListView(
                scrollDirection:
                    Axis.horizontal, // Horizontal scroll for Amazon-like UI
                children: cigarettes.keys.map((cigarette) {
                  return Container(
                    width: 250, // Increased width for better image display
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2, // Gives more space to image
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Image.asset(
                                "assets/images/${cigarette.toLowerCase().replaceAll(' ', '_')}.png",
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    cigarette,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Nicotine: ${cigarettes[cigarette]!['nicotine']}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Count: ${cigarettes[cigarette]!['count']}",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  SizedBox(height: 6),
                                  ElevatedButton(
                                    onPressed: () => _increment(cigarette),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black),
                                    child: Text("Add"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _reset,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: Colors.black),
              child: Text("Reset Data"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
