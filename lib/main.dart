import 'package:flutter/material.dart';
import 'package:super_app/ui/pages/hero_page.dart';
import 'theme/theme.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
  const HomeScreen({super.key});

  void _onButtonPressed(BuildContext context, String buttonName) {
    switch (buttonName) {
      case 'Heróis':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HeroesPage()),
        );
        break;
      case 'Card Diário':
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (_) => const CardDiarioPage()),
      // );
        break;
      case 'Minhas Cartas':
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (_) => const MinhasCartasPage()),
      // );
        break;
      case 'Batalhar':
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (_) => const BatalharPage()),
      // );
        break;
      default:
      // Para debug - você pode remover isso depois
        print('Botão $buttonName pressionado (não implementado)');
    }
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
      onPressed: () => _onButtonPressed(context, text),
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
