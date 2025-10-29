class HeroModel {
  final int id;
  final String name;
  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;
  final String gender;
  final String race;
  final String eyeColor;
  final String hairColor;
  final String imgXs;
  final String imgLg;

  HeroModel({
    required this.id,
    required this.name,
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
    required this.gender,
    required this.race,
    required this.eyeColor,
    required this.hairColor,
    required this.imgXs,
    required this.imgLg,
  });

  factory HeroModel.fromJsonCard(Map<String, dynamic> json) {

    return HeroModel(
      id: json['id'],
      name: json['name']?.toString() ?? 'Sem nome',
      intelligence: json['intelligence'],
      strength: json['strength'],
      speed: json['speed'],
      durability: json['durability'],
      power: json['power'],
      combat: json['combat'],
      gender: json['gender']?.toString() ?? 'Desconhecido',
      race: json['race']?.toString() ?? 'Desconhecida',
      eyeColor: json['eyeColor']?.toString() ?? 'Desconhecida',
      hairColor: json['hairColor']?.toString() ?? 'Desconhecida',
      imgXs: json['imgXs']?.toString() ?? '',
      imgLg: json['imgLg']?.toString() ?? '',
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return 'Desconhecido';
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? 'Desconhecido' : trimmed;
    }
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final cleaned = value.trim();
      if (cleaned.isEmpty || cleaned.toLowerCase() == 'null') return 0;
      return int.tryParse(cleaned) ?? 0;
    }
    return int.tryParse(value.toString()) ?? 0;
  }

  static int _parsePowerstat(dynamic value) {
    return _parseInt(value).clamp(0, 100);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'intelligence': intelligence,
      'strength': strength,
      'speed': speed,
      'durability': durability,
      'power': power,
      'combat': combat,
      'gender': gender,
      'race': race,
      'eyeColor': eyeColor,
      'hairColor': hairColor,
      'imgXs': imgXs,
      'imgLg': imgLg,
    };
  }
}