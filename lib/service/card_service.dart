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


  final HeroService _heroService;

  CardService(this._heroService);

  Future<CardModel?> getDailyCard() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
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

  Future<bool> addToCollection() async {
    final prefs = await SharedPreferences.getInstance();

    final dailyCard = await getDailyCard();
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


    collectionData.add(jsonEncode(dailyCard.hero.toJson()));


    await prefs.setStringList(_collectionKey, collectionData);

    final updatedCard = CardModel(
      date: dailyCard.date,
      hero: dailyCard.hero,
      collected: true,
    );

      await prefs.setString(_dailyCardKey, jsonEncode(updatedCard.toJson()));

    return true;
  }

  Future<bool> removeFromCollection(int heroId) async {
    final prefs = await SharedPreferences.getInstance();
    final collectionData = prefs.getStringList(_collectionKey) ?? [];


    final updatedCollection = <String>[];
    bool removed = false;

    for (final item in collectionData) {
      try {
        final heroJson = jsonDecode(item);
        if (heroJson['id'] != heroId) {
          updatedCollection.add(item);
        } else {
          removed = true;
        }
      } catch (e) {
        print('Erro ao processar item da coleção: $e');
        updatedCollection.add(item);
      }
    }

    if (removed) {
      await prefs.setStringList(_collectionKey, updatedCollection);
      print('Herói $heroId removido da coleção');
      return true;
    }

    print('Herói $heroId não encontrado na coleção');
    return false;
  }

  Future<List<HeroModel>> getCollection() async {
    final prefs = await SharedPreferences.getInstance();
    final collectionData = prefs.getStringList(_collectionKey) ?? [];

    final heroes = <HeroModel>[];
    for (final item in collectionData) {
      try {
        final heroJson = jsonDecode(item);
        heroes.add(HeroModel.fromJsonCard(heroJson));
      } catch (e) {
        print('Erro ao decodificar herói da coleção: $e');
      }
    }

    heroes.sort((a, b) => a.id.compareTo(b.id));

    return heroes;
  }

  Future<int> getCollectionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final collectionData = prefs.getStringList(_collectionKey) ?? [];
    return collectionData.length;
  }


  Future<HeroModel?> _getRandomHero() async {
    try {

      final randomPage = Random().nextInt(10) + 1;
      final heroes = await _heroService.fetchHeroesPage(randomPage, 10);

      if (heroes.isNotEmpty) {
        final randomIndex = Random().nextInt(heroes.length);
        return heroes[randomIndex];
      }
    } catch (e) {
      print('Erro ao buscar herói aleatório: $e');
    }
    return null;
  }


  Future<bool> hasCollectedToday() async {
    final card = await getDailyCard();
    return card?.collected ?? false;
  }

}