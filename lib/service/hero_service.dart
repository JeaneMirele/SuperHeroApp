import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/model/hero_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HeroService {
  final String baseUrl = "http://10.0.2.2:3000";
  List<HeroModel> _allHeroesCache = [];

  Future<List<HeroModel>> fetchHeroesPage(int page, int limit) async {
    final online = await _hasConnection();

    if (online) {
      try {
        final url = '$baseUrl/heroes?_page=$page&_limit=$limit';
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final newHeroes = data.map((item) => HeroModel.fromJsonCard(item)).toList();

          // adiciona e salva tudo no cache
          _allHeroesCache.addAll(newHeroes);
          await _saveAllHeroesToCache(_allHeroesCache);

          print('Página $page carregada online (${newHeroes.length} heróis)');
          return newHeroes;
        } else {
          throw Exception('Erro HTTP ${response.statusCode}');
        }
      } on SocketException catch (_) {
        print('Sem conexão durante requisição — usando cache');
        return await _loadFromCache(page, limit);
      } catch (e) {
        print('Erro inesperado online: $e');
        return await _loadFromCache(page, limit);
      }
    } else {
      print('Sem internet detectada — usando cache local');
      return await _loadFromCache(page, limit);
    }
  }

  Future<List<HeroModel>> _loadFromCache(int page, int limit) async {
    final cachedHeroes = await _getAllHeroesFromCache();
    _allHeroesCache = cachedHeroes;
    final localPage = _getLocalPage(page, limit);
    print('Página offline $page: ${localPage.length} heróis');
    return localPage;
  }

  List<HeroModel> _getLocalPage(int page, int limit) {
    if (_allHeroesCache.isEmpty) return [];
    final startIndex = (page - 1) * limit;
    if (startIndex >= _allHeroesCache.length) return [];

    final endIndex = (startIndex + limit).clamp(0, _allHeroesCache.length);
    return _allHeroesCache.sublist(startIndex, endIndex);
  }

  Future<void> _saveAllHeroesToCache(List<HeroModel> heroes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final heroesJson = heroes.map((hero) => hero.toJson()).toList();
      await prefs.setString('all_heroes_cache', jsonEncode(heroesJson));
      print('${heroes.length} heróis salvos no cache');
    } catch (e) {
      print('Erro ao salvar no cache: $e');
    }
  }

  Future<List<HeroModel>> _getAllHeroesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('all_heroes_cache');
      if (cachedData == null) return [];

      final List<dynamic> data = jsonDecode(cachedData);
      final heroes = data.map((item) {
        try {
          return HeroModel.fromJsonCard(item);
        } catch (_) {
          return null;
        }
      }).whereType<HeroModel>().toList();

      print('Cache carregado: ${heroes.length} heróis');
      return heroes;
    } catch (e) {
      print('Erro ao buscar cache: $e');
      return [];
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('all_heroes_cache');
    _allHeroesCache.clear();
    print('Cache limpo');
  }
}

Future<bool> _hasConnection() async {
  try {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) return false;

    // Testa se realmente há internet
    final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 3));
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
