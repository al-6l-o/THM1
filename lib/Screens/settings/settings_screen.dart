import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t_h_m/Providers/theme_provider.dart';
import 'package:t_h_m/generated/l10n.dart';
import 'theme_toggle.dart';
import 'language_selector.dart';
import 'about_dialog.dart';
import 'rating_dialog.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _getAverageRating();
  }

  Future<void> _getAverageRating() async {
    double avg = await getAverageRating();
    setState(() {
      averageRating = avg;
    });
  }

  void updateAverageRating(double newAverage) {
    setState(() {
      averageRating = newAverage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).app_settings,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThemeToggle(),
            Divider(color: isDarkMode ? Colors.grey : Colors.black),
            LanguageSelector(),
            Divider(color: isDarkMode ? Colors.grey : Colors.black),
            ListTile(
              leading: Icon(Icons.info,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(S.of(context).about_app),
              onTap: () => showCustomAboutDialog(context),
            ),
            Divider(color: isDarkMode ? Colors.grey : Colors.black),
            ListTile(
              leading: Icon(Icons.star_rate,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(S.of(context).rate_app),
              subtitle: Text(
                  "${S.of(context).average_rating}: ${averageRating.toStringAsFixed(1)}"),
              onTap: () => showRatingDialog(context, updateAverageRating),
            ),
          ],
        ),
      ),
    );
  }
}
