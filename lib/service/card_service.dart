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


      if (savedDate.isAtSameMomentAs(startOfDay)) {
        return savedCard;
      }
    }


    try {
      final randomHero = await _getRandomHero();
      if (randomHero != null) {
        final newCard = CardModel(
          date: DateTime.now(),
          hero: randomHero,
          collected: false,
        );


        await prefs.setString(_dailyCardKey, jsonEncode(newCard.toJson()));
        return newCard;
      }
    } catch (e) {
      print('Erro ao gerar card diário: $e');
    }

    return null;
  }


  Future<bool> addToCollection(HeroModel hero) async {
    final prefs = await SharedPreferences.getInstance();


    final currentCards = await getCollectionCount();
    if (currentCards >= _maxCards) {
      return false;
    }


    final collectionData = prefs.getStringList(_collectionKey) ?? [];


    collectionData.add(jsonEncode(hero.toJson()));


    await prefs.setStringList(_collectionKey, collectionData);


    final dailyCard = await getDailyCard();
    if (dailyCard != null) {
      final updatedCard = CardModel(
        date: dailyCard.date,
        hero: dailyCard.hero,
        collected: true,
      );
      await prefs.setString(_dailyCardKey, jsonEncode(updatedCard.toJson()));
    }

    return true;
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