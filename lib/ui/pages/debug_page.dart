import 'package:flutter/material.dart';
import 'package:super_app/service/card_service.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:super_app/service/hero_service.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final CardService _cardService = CardService(HeroService());
  int _cardCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCardCount();
  }

  Future<void> _loadCardCount() async {
    final count = await _cardService.getCollectionCount();
    if (mounted) {
      setState(() {
        _cardCount = count;
      });
    }
  }
  Future<void> _addCard() async {
    setState(() { _isLoading = true; });

    final colorScheme = Theme.of(context).colorScheme;

    final success = await _cardService.addRandomCardToCollectionForTesting();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Nova carta adicionada!' : 'Ação falhou. A coleção pode estar cheia.'),

          backgroundColor: success ? colorScheme.primary : colorScheme.error,
        ),
      );
      await _loadCardCount();
    }

    setState(() { _isLoading = false; });
  }

  Future<void> _clearCollection() async {
    setState(() { _isLoading = true; });
    final colorScheme = Theme.of(context).colorScheme;

    await _cardService.clearCollectionForTesting();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Coleção de cartas limpa!'),

          backgroundColor: colorScheme.secondary,
        ),
      );
      await _loadCardCount();
    }

    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text("Disponível apenas em modo de depuração.")),
      );
    }


    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ferramentas de Teste'),

        backgroundColor: colorScheme.primary,

        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Simulador de Cartas',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Text(
                'Cartas na Coleção: $_cardCount / 15',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _addCard,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Adicionar Carta Aleatória'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _clearCollection,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Limpar Coleção'),

                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 20),
                const Center(child: CircularProgressIndicator()),
              ]
            ],
          ),
        ),
      ),
    );
  }
}