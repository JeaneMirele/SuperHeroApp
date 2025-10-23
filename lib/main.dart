import 'package:flutter/material.dart';
import 'theme/theme.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: const MaterialTheme(TextTheme()).light(),
      darkTheme: const MaterialTheme(TextTheme()).dark(),
      highContrastDarkTheme:
      const MaterialTheme(TextTheme()).darkHighContrast(),
      highContrastTheme: const MaterialTheme(TextTheme()).lightHighContrast(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  void _onButtonPressed(String buttonName) {
    print('$buttonName pressed');
  }

  @override
  Widget build(BuildContext context) {

    final textButtonColor = Theme.of(context).colorScheme.onPrimary;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: textButtonColor,
        title: Text('Heroes',
            style: TextStyle(color: textButtonColor)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, 'Heróis'),
            SizedBox(height: 20),
            _buildButton(context, 'Card Diário'),
            SizedBox(height: 20),
            _buildButton(context, 'Minhas Cartas'),
            SizedBox(height: 20),
            _buildButton(context, 'Batalhar'),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,String text) {
    return ElevatedButton(
      onPressed: () => _onButtonPressed(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        minimumSize: Size(200, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}
