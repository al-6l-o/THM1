import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t_h_m/Constants/colors.dart';
import 'package:t_h_m/Providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'package:t_h_m/Providers/localization.dart';

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

  void _changeLanguage(String languageCode) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    localeProvider.setLocale(languageCode); // تغيير اللغة
  }

  String getLanguageName(String languageCode) {
    if (languageCode == 'en') {
      return 'English';
    } else if (languageCode == 'ar') {
      return 'العربية';
    } else {
      return 'Unknown Language';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).select_language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // تحديد اللغة الإنجليزية بشكل افتراضي عندما تكون هي اللغة الحالية
              RadioListTile<String>(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("English"),
                    Text("الإنجليزية",
                        style: TextStyle(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 100, 100, 100))),
                  ],
                ),
                value: "en", // استخدام 'en' بدلاً من 'English'
                groupValue: Provider.of<LocaleProvider>(context)
                    .locale
                    .languageCode, // تعيين القيمة المحددة بناءً على اللغة الحالية
                onChanged: (value) {
                  if (value != null) {
                    _updateLanguage(value);
                    _changeLanguage(value); // تغيير اللغة إلى الإنجليزية
                    Navigator.pop(context);
                  }
                },
              ),
              // تحديد اللغة العربية بشكل افتراضي إذا كانت هي اللغة الحالية
              RadioListTile<String>(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Arabic"),
                    Text("العربية",
                        style: TextStyle(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 100, 100, 100))),
                  ],
                ),
                value: "ar", // استخدام 'ar' بدلاً من 'Arabic'
                groupValue: Provider.of<LocaleProvider>(context)
                    .locale
                    .languageCode, // تعيين القيمة المحددة بناءً على اللغة الحالية
                onChanged: (value) {
                  if (value != null) {
                    _updateLanguage(value);
                    _changeLanguage(value); // تغيير اللغة إلى العربية
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
        title: Text(S.of(context).rate_app),
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
            child: Text(S.of(context).cancel,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
            child: Text(S.of(context).submit,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).app_settings,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(S.of(context).dark_mode),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),
            Divider(color: isDarkMode ? Colors.grey : Colors.black),
            ListTile(
              leading: Icon(Icons.language,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(S.of(context).language),
              subtitle: Text(getLanguageName(
                  Provider.of<LocaleProvider>(context).locale.languageCode)),
              onTap: _showLanguageDialog,
            ),
            Divider(color: isDarkMode ? Colors.grey : Colors.black),
            ListTile(
              leading: Icon(Icons.info,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(S.of(context).about_app),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(S.of(context).about_app),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.of(context).app_title),
                          SizedBox(height: 8),
                          Text("${S.of(context).version}: 1.0.0"),
                          SizedBox(height: 8),
                          Text("${S.of(context).developedBy}: 'THM' team"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(S.of(context).close),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Divider(color: isDarkMode ? Colors.grey : Colors.black),
            ListTile(
              leading: Icon(Icons.star_rate,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(S.of(context).rate_app),
              subtitle: Text(
                  "${S.of(context).average_rating}: ${averageRating.toStringAsFixed(1)}"),
              onTap: _showRatingDialog,
            ),
          ],
        ),
      ),
    );
  }
}
