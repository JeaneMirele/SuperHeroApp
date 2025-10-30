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
    final appearance = json['appearance'] is Map ? json['appearance'] : {};
    final images = json['images'] is Map ? json['images'] : {};
    final powerstats = json['powerstats'] is Map ? json['powerstats'] : {};


    return HeroModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      intelligence: _parsePowerstat(powerstats['intelligence']),
      strength: _parsePowerstat(powerstats['strength']),
      speed: _parsePowerstat(powerstats['speed']),
      durability: _parsePowerstat(powerstats['durability']),
      power: _parsePowerstat(powerstats['power']),
      combat: _parsePowerstat(powerstats['combat']),
      gender: _parseString(appearance['gender']),
      race: _parseString(appearance['race']),
      eyeColor: _parseString(appearance['eyeColor']),
      hairColor: _parseString(appearance['hairColor']),
      imgXs: _parseString(images['xs']),
      imgLg: _parseString(images['lg']),
    );
  }
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int _parsePowerstat(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return 'Desconhecido';
    return value.toString();
  }



  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'powerstats': {
        'intelligence': intelligence,
        'strength': strength,
        'speed': speed,
        'durability': durability,
        'power': power,
        'combat': combat,
      },
      'appearance': {
        'gender': gender,
        'race': race,
        'eyeColor': eyeColor,
        'hairColor': hairColor,
      },
      'images': {
        'xs': imgXs,
        'lg': imgLg,
      },
    };
  }

}
