import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/model/hero_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HeroService {
  final String baseUrl = "http://10.0.2.2:3000";


  List<HeroModel>? _inMemoryCache;


  Future<List<HeroModel>> fetchHeroesPage(int page, int limit) async {

    if (_inMemoryCache != null) {
      print("Retornando página $page do cache em memória.");
      return _getLocalPage(page, limit);
    }

    final online = await _hasConnection();

    if (online) {
      try {

        print("Online: Buscando lista completa de heróis da API...");
        final allHeroes = await _fetchAllFromApi();
        _inMemoryCache = allHeroes;
        await _saveAllHeroesToCache(allHeroes);
        return _getLocalPage(page, limit);
      } catch (e) {

        print("Falha na API ($e). Usando cache do disco como fallback.");
        return await _loadFromDiskAndPaginate(page, limit);
      }
    } else {

      print("Offline: Buscando do cache do disco.");
      return await _loadFromDiskAndPaginate(page, limit);
    }
  }


  Future<List<HeroModel>> _loadFromDiskAndPaginate(int page, int limit) async {
    final cachedHeroes = await _getAllHeroesFromCache();
    if (cachedHeroes.isNotEmpty) {
      _inMemoryCache = cachedHeroes;
      return _getLocalPage(page, limit);
    } else {

      throw Exception('Sem conexão e sem dados em cache.');
    }
  }


  List<HeroModel> _getLocalPage(int page, int limit) {
    if (_inMemoryCache == null || _inMemoryCache!.isEmpty) {
      return [];
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= _inMemoryCache!.length) {
      return [];
    }


    final endIndex = (startIndex + limit).clamp(0, _inMemoryCache!.length);

    print('Paginação local: Retornando ${endIndex - startIndex} heróis para a página $page.');
    return _inMemoryCache!.sublist(startIndex, endIndex);
  }


  Future<List<HeroModel>> _fetchAllFromApi() async {
    final url = '$baseUrl/heroes';
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      final heroes = data.map((item) => HeroModel.fromJsonCard(item)).toList();
      print("API retornou ${heroes.length} heróis no total.");
      return heroes;
    } else {
      throw Exception('Erro HTTP ${response.statusCode}');
    }
  }


  Future<void> _saveAllHeroesToCache(List<HeroModel> heroes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final heroesJson = heroes.map((hero) => hero.toJson()).toList();
      await prefs.setString('all_heroes_cache', jsonEncode(heroesJson));
      print('${heroes.length} heróis salvos no cache do disco.');
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
      final heroes = data.map((item) => HeroModel.fromJsonCard(item)).toList();
      print('Cache do disco carregado: ${heroes.length} heróis.');
      return heroes;
    } catch (e) {
      print('Erro ao buscar do cache do disco: $e');
      return [];
    }
  }


  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('all_heroes_cache');
    _inMemoryCache = null;
    print('Cache limpo (memória e disco).');
  }
}


Future<bool> _hasConnection() async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}
