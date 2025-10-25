import 'package:flutter/material.dart';
import 'package:super_app/model/hero_model.dart';

class HeroDetailPage extends StatelessWidget {
  final HeroModel hero;

  const HeroDetailPage({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hero.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(hero.imgXs, height: 150),
            const SizedBox(height: 16),
            Text('Raça: ${hero.race}'),
            Text('Gênero: ${hero.gender}'),
            const Divider(),
            Text('Poder: ${hero.power}'),
            Text('Força: ${hero.strength}'),
            Text('Velocidade: ${hero.speed}'),
            Text('Durabilidade: ${hero.durability}'),
            Text('Combate: ${hero.combat}'),
          ],
        ),
      ),
    );
  }
}
