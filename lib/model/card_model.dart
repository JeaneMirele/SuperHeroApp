import 'hero_model.dart';

class CardModel {
  final DateTime date;
  final HeroModel hero;
  final bool collected;

  CardModel({
    required this.date,
    required this.hero,
    this.collected = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'hero': hero.toJson(),
      'collected': collected,
    };
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      date: DateTime.parse(json['date']),
      hero: HeroModel.fromJson(json['hero']),
      collected: json['collected'] ?? false,
    );
  }
}