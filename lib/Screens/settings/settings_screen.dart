import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t_h_m/Constants/colors.dart';
import 'package:t_h_m/Providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = "English";
  double userRating = 0.0;
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getAverageRating();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString("language") ?? "English";
    });
  }

  Future<void> _updateLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", language);
    setState(() {
      selectedLanguage = language;
    });
  }

  Future<void> _submitRating(double rating) async {
    final CollectionReference ratings =
        FirebaseFirestore.instance.collection('ratings');

    await ratings.add({'rating': rating, 'timestamp': DateTime.now()});

    _getAverageRating();
  }

  Future<void> _getAverageRating() async {
    final CollectionReference ratings =
        FirebaseFirestore.instance.collection('ratings');
    final QuerySnapshot snapshot = await ratings.get();

    if (snapshot.docs.isNotEmpty) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += doc['rating'];
      }
      setState(() {
        averageRating = total / snapshot.docs.length;
      });
    }
  }

  void _showRatingDialog() {
    double tempRating = userRating;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Rate the App",
          style: TextStyle(fontSize: 19),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: userRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => Icon(Icons.star,
                  color: Theme.of(context).colorScheme.primary),
              onRatingUpdate: (rating) {
                tempRating = rating;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userRating = tempRating;
              });
              _submitRating(userRating);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).dialogTheme.backgroundColor),
            child: Text(
              "Submit",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "App Settings",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text("Dark Mode"),
              value: Provider.of<ThemeProvider>(context)
                  .isDarkMode, // ✅ تأكد إنه يستمع للتغيير
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
            ),
            SizedBox(height: 10),
            Text("Language",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updateLanguage(newValue);
                }
              },
              items: ["English", "العربية"].map((String lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text("About App"),
              leading: Icon(Icons.info),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Vital Signs App",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "Developed by علياء",
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text("Rate the App"),
              subtitle:
                  Text("Average Rating: ${averageRating.toStringAsFixed(1)}"),
              leading: Icon(
                Icons.star_rate,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: _showRatingDialog,
            ),
          ],
        ),
      ),
    );
  }
}
