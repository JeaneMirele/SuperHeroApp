import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:super_app/model/hero_model.dart';
import 'package:super_app/service/card_service.dart';

import '../../service/hero_service.dart';

class MyCardDetailPage extends StatefulWidget {

  final HeroModel hero;
  final bool isFromCollection;

  const MyCardDetailPage({
    super.key,
    required this.hero,
    this.isFromCollection = false,
  });

  @override
  State<MyCardDetailPage> createState() => _MyCardDetailPageState();
}

class _MyCardDetailPageState extends State<MyCardDetailPage> {
  final CardService _cardService = CardService(HeroService());
  bool _isLoading = false;

  void _showAbandonDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Abandonar Carta',
      desc: 'Tem certeza que deseja remover ${widget.hero.name} da sua coleção?',
      btnCancelText: 'Cancelar',
      btnOkText: 'Sim, Remover',
      btnCancelOnPress: () {},
      btnOkOnPress: _abandonCard,
    ).show();
  }

  Future<void> _abandonCard() async {
    setState(() {
      _isLoading = true;
    });

    try {

      final success = await _cardService.removeFromCollection(widget.hero.id);

      if (success) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao remover ${widget.hero.name}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao abandonar carta: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover carta'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStatRow(String label, int value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: value / 100,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  child: Text(
                    '$value',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.hero.name,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: widget.hero.imgLg.isNotEmpty
                    ? widget.hero.imgLg
                    : widget.hero.imgXs,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colorScheme.surfaceVariant,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.person_outline,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            backgroundColor: colorScheme.primary,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Powerstats
                  Card(
                    color: colorScheme.surface,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Atributos',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow('Inteligência', widget.hero.intelligence),
                          _buildStatRow('Força', widget.hero.strength),
                          _buildStatRow('Velocidade', widget.hero.speed),
                          _buildStatRow('Durabilidade', widget.hero.durability),
                          _buildStatRow('Poder', widget.hero.power),
                          _buildStatRow('Combate', widget.hero.combat),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),


                  Card(
                    color: colorScheme.surface,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Gênero', widget.hero.gender),
                          _buildInfoRow('Raça', widget.hero.race),
                          _buildInfoRow('Cor dos Olhos', widget.hero.eyeColor),
                          _buildInfoRow('Cor do Cabelo', widget.hero.hairColor),
                          _buildInfoRow('ID', widget.hero.id.toString()),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _showAbandonDialog,
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: _isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onError,
                          ),
                        )
                            : const Icon(Icons.delete_outline),
                        label: _isLoading
                            ? const Text('Removendo...')
                            : const Text('Abandonar Carta'),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}