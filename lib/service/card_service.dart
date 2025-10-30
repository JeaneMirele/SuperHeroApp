import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/model/card_model.dart';
import 'package:super_app/model/hero_model.dart';
import 'package:super_app/service/hero_service.dart';

class CardService {
  static const String _dailyCardKey = 'daily_card';
  static const String _collectionKey = 'my_cards';
  static const int _maxCards = 15;
  static const String _abandonedCardsKey = 'abandoned_cards';

  final HeroService _heroService;

  CardService(this._heroService);


  Future<CardModel?> getDailyCard({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = now ?? DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final savedData = prefs.getString(_dailyCardKey);

    if (savedData != null) {
      final savedCard = CardModel.fromJson(jsonDecode(savedData));
      final savedDate = DateTime(
        savedCard.date.year,
        savedCard.date.month,
        savedCard.date.day,
      );

      if (savedDate == startOfDay) {
        return savedCard;
      }
    }

    try {
      final randomHero = await _getRandomHero();
      if (randomHero != null) {
        final newCard = CardModel(
          date: startOfDay,
          hero: randomHero,
          collected: false,
        );

        await prefs.setString(_dailyCardKey, jsonEncode(newCard.toJson()));
        return newCard;
      }
    } catch (e) {
      print('Erro ao gerar card diário: $e');
      await prefs.remove(_dailyCardKey);
    }

    return null;
  }


  Future<bool> addToCollection({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();

    final dailyCard = await getDailyCard(now: now);
    if (dailyCard == null) {
      print('Nenhum card diário disponível');
      return false;
    }

    if (dailyCard.collected) {
      print('Carta de hoje já foi adicionada!');
      return false;
    }

    final currentCards = await getCollectionCount();
    if (currentCards >= _maxCards) {
      print('Você já atingiu o limite de 15 cartas.');
      return false;
    }

    final collectionData = prefs.getStringList(_collectionKey) ?? [];
    collectionData.add(jsonEncode(dailyCard.toJson()));
    await prefs.setStringList(_collectionKey, collectionData);

    final updatedCard = CardModel(
      date: dailyCard.date,
      hero: dailyCard.hero,
      collected: true,
    );
    await prefs.setString(_dailyCardKey, jsonEncode(updatedCard.toJson()));

    return true;
  }

  Future<void> _addToAbandonedCards(int heroId) async {
    final prefs = await SharedPreferences.getInstance();
    final abandonedData = prefs.getStringList(_abandonedCardsKey) ?? [];

    if (!abandonedData.contains(heroId.toString())) {
      abandonedData.add(heroId.toString());
      await prefs.setStringList(_abandonedCardsKey, abandonedData);
    }
  }

  Future<bool> _isAbandonedCard(int heroId) async {
    final prefs = await SharedPreferences.getInstance();
    final abandonedData = prefs.getStringList(_abandonedCardsKey) ?? [];
    return abandonedData.contains(heroId.toString());
  }

  Future<HeroModel?> _getRandomHero() async {
    try {
      final randomPage = Random().nextInt(10) + 1;
      final heroes = await _heroService.fetchHeroesPage(randomPage, 10);

      if (heroes.isNotEmpty) {
        final availableHeroes = <HeroModel>[];
        for (final hero in heroes) {
          if (!(await _isAbandonedCard(hero.id))) {
            availableHeroes.add(hero);
          }
        }

        if (availableHeroes.isNotEmpty) {
          return availableHeroes[Random().nextInt(availableHeroes.length)];
        } else {
          await _resetAbandonedCards();
          return await _getRandomHero();
        }
      }
    } catch (e) {
      print('Erro ao buscar herói aleatório: $e');
    }
    return null;
  }

  Future<void> _resetAbandonedCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_abandonedCardsKey);
  }

  Future<bool> removeFromCollection(int heroId) async {
    final prefs = await SharedPreferences.getInstance();
    final collectionData = prefs.getStringList(_collectionKey) ?? [];
    final updatedCollection = <String>[];
    bool removed = false;

    for (final item in collectionData) {
      final cardJson = jsonDecode(item);
      if (cardJson['hero'] != null && cardJson['hero']['id'] != heroId) {
        updatedCollection.add(item);
      } else {
        removed = true;
      }
    }

    if (removed) {
      await prefs.setStringList(_collectionKey, updatedCollection);
      await _addToAbandonedCards(heroId);


      final dailyCard = await getDailyCard();
      if (dailyCard != null && dailyCard.hero.id == heroId) {

        final updatedDailyCard = CardModel(
          date: dailyCard.date,
          hero: dailyCard.hero,
          collected: false,
        );
        await prefs.setString(_dailyCardKey, jsonEncode(updatedDailyCard.toJson()));
        print('Carta diária ${heroId} resetada para não coletada.');
      }


      print('Herói $heroId removido da coleção e marcado como abandonado');
      return true;
    }

    return false;
  }

  Future<List<CardModel>> getCollection() async {
    final prefs = await SharedPreferences.getInstance();
    final collectionData = prefs.getStringList(_collectionKey) ?? [];
    final cards = <CardModel>[];

    for (final item in collectionData) {
      try {
        cards.add(CardModel.fromJson(jsonDecode(item)));
      } catch (e) {
        print('Erro ao decodificar carta da coleção: $e');
      }
    }
    cards.sort((a, b) => a.hero.id.compareTo(b.hero.id));
    return cards;
  }

  Future<int> getCollectionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_collectionKey)?.length ?? 0;
  }

  Future<bool> hasCollectedToday() async {
    final card = await getDailyCard();
    return card?.collected ?? false;
  }

Future<bool> addRandomCardToCollectionForTesting() async {
  final prefs = await SharedPreferences.getInstance();
  final currentCount = await getCollectionCount();

  if (currentCount >= _maxCards) {
    print(
        'DEBUG: Coleção já está cheia. Não é possível adicionar mais cartas.');
    return false;
  }
  final randomHero = await _getRandomHero();
  if (randomHero != null) {
    final newCard = CardModel(
      date: DateTime.now(),
      hero: randomHero,
      collected: true,
    );

    final collectionData = prefs.getStringList(_collectionKey) ?? [];
    collectionData.add(jsonEncode(newCard.toJson()));
    await prefs.setStringList(_collectionKey, collectionData);

    print('DEBUG: Carta ${randomHero.name} adicionada à coleção.');
    return true;
  }
  return false;
}

Future<void> clearCollectionForTesting() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_collectionKey);
  print('DEBUG: Todas as cartas foram removidas da coleção.');
}

}