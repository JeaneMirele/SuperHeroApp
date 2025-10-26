import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/model/hero_model.dart';

class HeroService {
  final String baseUrl = "http://10.0.2.2:3000";
  List<HeroModel>? _allHeroesCache;

  Future<List<HeroModel>> fetchHeroesPage(int page, int limit) async {
    try {

      if (_allHeroesCache != null) {
        return _getLocalPage(page, limit);
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();

      final cachedHeroes = await _getAllHeroesFromCache();
      if (cachedHeroes.isNotEmpty) {
        print('Carregando ${cachedHeroes.length} heróis do cache persistente');
        _allHeroesCache = cachedHeroes;
        return _getLocalPage(page, limit);
      }


      print('Buscando TODOS os heróis da API...');
      final url = '$baseUrl/heroes';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Total de heróis encontrados: ${data.length}');


        _allHeroesCache = [];
        for (var item in data) {
          try {
            final hero = HeroModel.fromJson(item);
            _allHeroesCache!.add(hero);
          } catch (e) {
            print('Erro ao converter herói: $e');
          }
        }

        // Salva TODOS no SharedPreferences para uso futuro
        await _saveAllHeroesToCache(_allHeroesCache!);

        return _getLocalPage(page, limit);
      } else {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');

      // Tenta buscar do SharedPreferences como fallback
      final cachedHeroes = await _getAllHeroesFromCache();
      if (cachedHeroes.isNotEmpty) {
        print('Usando cache persistente como fallback: ${cachedHeroes.length} heróis');
        _allHeroesCache = cachedHeroes;
        return _getLocalPage(page, limit);
      } else {
        throw Exception('Sem conexão e sem dados em cache');
      }
    }
  }

  List<HeroModel> _getLocalPage(int page, int limit) {
    if (_allHeroesCache == null || _allHeroesCache!.isEmpty) {
      return [];
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= _allHeroesCache!.length) {
      return []; // Fim da lista
    }

    final endIndex = (startIndex + limit) < _allHeroesCache!.length
        ? (startIndex + limit)
        : _allHeroesCache!.length;

    final pageItems = _allHeroesCache!.sublist(startIndex, endIndex);

    print('Página $page: itens $startIndex-${endIndex-1} de ${_allHeroesCache!.length}');

    // Debug: mostra os PRIMEIROS heróis de CADA página
    if (pageItems.isNotEmpty) {
      final firstHero = pageItems.first.name;
      final lastHero = pageItems.last.name;
      print('   Primeiro: $firstHero, Último: $lastHero');
    }

    return pageItems;
  }

  // Salva TODOS os heróis no SharedPreferences
  Future<void> _saveAllHeroesToCache(List<HeroModel> heroes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> heroesJson =
      heroes.map((hero) => hero.toJson()).toList();

      await prefs.setString('all_heroes_cache', jsonEncode(heroesJson));
      print('${heroes.length} heróis salvos no cache persistente');
    } catch (e) {
      print('Erro ao salvar no cache: $e');
    }
  }

  // Busca TODOS os heróis do SharedPreferences
  Future<List<HeroModel>> _getAllHeroesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('all_heroes_cache');

      if (cachedData != null) {
        final List<dynamic> data = jsonDecode(cachedData);
        final List<HeroModel> heroes = [];

        for (var item in data) {
          try {
            final hero = HeroModel.fromJson(item);
            heroes.add(hero);
          } catch (e) {
            print('Erro ao converter herói do cache: $e');
          }
        }

        return heroes;
      }
      return [];
    } catch (e) {
      print('Erro ao buscar do cache: $e');
      return [];
    }
  }

  // Limpar cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('all_heroes_cache');
      _allHeroesCache = null;
      print('Cache limpo');
    } catch (e) {
      print('Erro ao limpar cache: $e');
    }
  }

  // Forçar recarregamento
  Future<void> refreshCache() async {
    _allHeroesCache = null;
    await clearCache();
  }
}