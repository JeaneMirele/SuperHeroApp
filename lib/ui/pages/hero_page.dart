import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:super_app/model/hero_model.dart';
import 'package:super_app/service/hero_service.dart';
import 'hero_detail_page.dart';

class HeroesPage extends StatefulWidget {
  const HeroesPage({super.key});

  @override
  State<HeroesPage> createState() => _HeroesPageState();
}

class _HeroesPageState extends State<HeroesPage> {
  final _pagingController = PagingController<int, HeroModel>(firstPageKey: 1);
  final _heroService = HeroService();
  static const _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      print('Solicitando página: $pageKey');

      final newItems = await _heroService.fetchHeroesPage(pageKey, _pageSize);

      print('Recebidos ${newItems.length} itens da página $pageKey');

      // Verificação: mostra os primeiros nomes de cada página
      if (newItems.isNotEmpty) {
        final names = newItems.take(3).map((hero) => hero.name).toList();
        print('Amostra da página $pageKey: $names');
      }

      // Se veio menos itens que o pageSize, é a última página
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        print('Ultima página: $pageKey');
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        print('Página $pageKey OK! Proxima: $nextPageKey');
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      print('ERRO na página $pageKey: $error');
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heróis')),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView<int, HeroModel>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<HeroModel>(
            itemBuilder: (context, hero, index) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HeroDetailPage(hero: hero)),
                ),
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(
                      hero.imgLg,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                    ),
                    title: Text(hero.name),
                    subtitle: Text(
                      'Força: ${hero.strength} | Velocidade: ${hero.speed}',
                    ),
                  ),
                ),
              );
            },
            firstPageProgressIndicatorBuilder: (context) =>
                const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (context) => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            firstPageErrorIndicatorBuilder: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar heróis',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _pagingController.refresh(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
            noItemsFoundIndicatorBuilder: (context) =>
                const Center(child: Text('Nenhum herói encontrado')),
            noMoreItemsIndicatorBuilder: (context) => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text(' Todos os heróis carregados!')),
            ),
          ),
        ),
      ),
    );
  }
}
