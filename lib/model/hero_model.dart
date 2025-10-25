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

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    return HeroModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? 'Sem nome',
      intelligence: _parsePowerstat(json['powerstats']?['intelligence']),
      strength: _parsePowerstat(json['powerstats']?['strength']),
      speed: _parsePowerstat(json['powerstats']?['speed']),
      durability: _parsePowerstat(json['powerstats']?['durability']),
      power: _parsePowerstat(json['powerstats']?['power']),
      combat: _parsePowerstat(json['powerstats']?['combat']),
      gender: json['appearance']?['gender']?.toString() ?? 'Desconhecido',
      race: json['appearance']?['race']?.toString() ?? 'Desconhecida',
      eyeColor: json['appearance']?['eyeColor']?.toString() ?? 'Desconhecida',
      hairColor: json['appearance']?['hairColor']?.toString() ?? 'Desconhecida',
      imgXs: json['images']?['xs']?.toString() ?? '',
      imgLg: json['images']?['lg']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int _parsePowerstat(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {

      if (value.toLowerCase() == 'null') return 0;
      return int.tryParse(value) ?? 0;
    }
    return 0;
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