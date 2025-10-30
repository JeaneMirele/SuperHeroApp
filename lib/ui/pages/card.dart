import 'package:flutter/material.dart';
import 'package:super_app/model/card_model.dart';
import 'package:super_app/model/hero_model.dart';
import 'package:super_app/service/card_service.dart';
import 'package:super_app/service/hero_service.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';


class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final CardService _dailyCardService = CardService(HeroService());
  CardModel? _dailyCard;
  bool _isLoading = true;
  String _errorMessage = '';
  int _collectionCount = 0;
  bool _cardAdded = false;

  @override
  void initState() {
    super.initState();
    _loadDailyCard();
  }

  Future<void> _loadDailyCard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final card = await _dailyCardService.getDailyCard();
      final count = await _dailyCardService.getCollectionCount();

      setState(() {
        _dailyCard = card;
        _collectionCount = count;
        _cardAdded = card?.collected ?? false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar card diário';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCollection() async {
    if (_dailyCard == null) return;

    final success = await _dailyCardService.addToCollection();

    if (success) {
      _cardAdded = true;
      final count = await _dailyCardService.getCollectionCount();
      setState(() {
        _collectionCount = count;
        _dailyCard = CardModel(
          date: _dailyCard!.date,
          hero: _dailyCard!.hero,
          collected: true,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_dailyCard!.hero.name} adicionado à sua coleção!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Você já atingiu o limite de 15 cartas!'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Card Diário',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        elevation: 4,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDailyCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      )
          : _dailyCard == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum card disponível',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          ],
        ),
      )
          : _buildCardContent(context),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hero = _dailyCard!.hero;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cartas na coleção: $_collectionCount/15',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                       if(_cardAdded)
                         const SizedBox(height: 4),
                         Text(
                           'Volte amanhã para um novo card!',
                           style: textTheme.bodySmall?.copyWith(
                             color: colorScheme.onSurface.withOpacity(0.7),
                           ),
                         ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),


          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [

                  Text(
                    hero.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),


                  Hero(
                    tag: 'daily-card-${hero.id}',
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colorScheme.surfaceVariant,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          hero.imgLg,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Powerstats
                  ..._buildPowerstats(context, hero),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (!_dailyCard!.collected && _collectionCount < 15)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addToCollection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Adicionar à Minha Biblioteca',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          if (_dailyCard!.collected)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Card já adicionado à coleção!',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_collectionCount >= 15 && !_dailyCard!.collected)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Limite de 15 cartas atingido!',
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPowerstats(BuildContext context, HeroModel hero) {
    final colorScheme = Theme.of(context).colorScheme;
    final powerstats = {
      'Inteligência': hero.intelligence,
      'Força': hero.strength,
      'Velocidade': hero.speed,
      'Durabilidade': hero.durability,
      'Poder': hero.power,
      'Combate': hero.combat,
    };

    return powerstats.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${entry.value}/100',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            PrimerProgressBar(
              segments: [
                Segment(
                  value: entry.value,
                  color: _getStatColor(entry.value, colorScheme),
                ),
                Segment(
                  value: 100 - entry.value,
                  color: colorScheme.surfaceVariant,
                ),
              ],
              maxTotalValue: 100,
              ),
          ],
        ),
      );
    }).toList();
  }

  Color _getStatColor(int value, ColorScheme colorScheme) {
    if (value >= 80) return colorScheme.primary;
    if (value >= 60) return colorScheme.tertiary;
    if (value >= 40) return colorScheme.secondary;
    if (value >= 20) return colorScheme.primaryContainer;
    return colorScheme.error;
  }
}