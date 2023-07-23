import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ChangeNotifier.dart';

class settingscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Center(
          child: SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
        ),
      ),
    );
  }
}
