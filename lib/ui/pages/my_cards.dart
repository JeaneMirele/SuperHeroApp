import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:super_app/model/hero_model.dart';
import 'package:super_app/service/card_service.dart';
import 'package:super_app/ui/pages/debug_page.dart';
import 'package:super_app/ui/pages/my_cards_deital.dart';
import '../../model/card_model.dart';
import '../../service/hero_service.dart';


class MyCardsPage extends StatefulWidget {
  const MyCardsPage({super.key});

  @override
  State<MyCardsPage> createState() => _MyCardsPageState();
}

class _MyCardsPageState extends State<MyCardsPage> {
  final CardService _cardService = CardService(HeroService());
  List<CardModel> _myCards = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMyCards();
  }

  Future<void> _loadMyCards() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final cards = await _cardService.getCollection();

      if (!mounted) return;
      setState(() {
        _myCards = cards;
        _isLoading = false;
      });

      print('Carregadas ${_myCards.length} cartas da coleção');
    } catch (error) {
      print('ERRO ao carregar cartas: $error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar suas cartas';
      });
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
          'Minhas Cartas',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),

        actions: [

          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.science_outlined),
              tooltip: 'Ferramentas de Teste',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DebugPage()),
                ).then((_) {
                  _loadMyCards();
                });
              },
            ),


          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_myCards.length}/15',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(colorScheme, textTheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorBody(colorScheme, textTheme);
    }

    if (_myCards.isEmpty) {
      return _buildEmptyBody(colorScheme, textTheme);
    }

    return RefreshIndicator(
      backgroundColor: colorScheme.background,
      color: colorScheme.primary,
      onRefresh: _loadMyCards,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _myCards.length,
        itemBuilder: (context, index) {
          final card = _myCards[index];
          final hero = card.hero;

          return GestureDetector(
            onTap: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MyCardDetailPage(
                          hero: hero,
                          isFromCollection: true,
                        ),
                  ),
                ).then((removed) {
                  if (removed == true) {
                    _loadMyCards();
                  }
                }),
            child: _buildHeroCard(card, colorScheme, textTheme, index),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(CardModel card, ColorScheme colorScheme,
      TextTheme textTheme, int index) {
    final hero = card.hero;

    return Card(
      margin: const EdgeInsets.all(8),
      color: colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () =>
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MyCardDetailPage(hero: hero)),
            ),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
          leading: _buildHeroImage(hero, colorScheme),
          title: Text(
            hero.name,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Força: ${hero.strength} | Velocidade: ${hero.speed}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Inteligência: ${hero.intelligence} | Combate: ${hero.combat}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#${hero.id}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(HeroModel hero, ColorScheme colorScheme) {
    return Hero(
      tag: 'hero-image-${hero.id}',
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: CachedNetworkImage(
            imageUrl: hero.imgLg.isNotEmpty ? hero.imgLg : hero.imgXs,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            errorWidget: (_, __, ___) =>
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 24,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBody(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(_errorMessage, style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onBackground)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMyCards,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBody(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.collections_outlined, size: 64,
              color: colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Nenhuma carta na coleção',
              style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Volte todos os dias para coletar novas cartas!',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }
}