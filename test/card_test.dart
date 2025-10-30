import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/model/hero_model.dart';
import 'package:super_app/service/card_service.dart';
import 'package:super_app/service/hero_service.dart';

// Importa o arquivo gerado pelo Mockito
import 'card_test.mocks.dart';

// Gera o mock para HeroService
@GenerateMocks([HeroService])
void main() {

  TestWidgetsFlutterBinding.ensureInitialized();


  late CardService cardService;
  late MockHeroService mockHeroService;


  final fakeHeroes = List.generate(
    20,
        (i) => HeroModel(
      id: i + 1,
      name: 'Hero ${i + 1}',
      intelligence: 50, strength: 50, speed: 50, durability: 50, power: 50, combat: 50,
      gender: 'N/A', race: 'N/A', eyeColor: 'N/A', hairColor: 'N/A', imgLg: '', imgXs: '',
    ),
  );

  setUp(() {

    mockHeroService = MockHeroService();
    cardService = CardService(mockHeroService);
    // Configura o SharedPreferences para usar uma implementação em memória
    SharedPreferences.setMockInitialValues({});
  });

  group('CardService - Teste de Limite de Coleção', () {
    test('Deve permitir adicionar até 15 cartas e falhar na 16ª', () async {
      // Simula a adição de cartas por 16 dias consecutivos
      for (int day = 1; day <= 16; day++) {
        // Define uma data simulada para cada dia
        final fakeNow = DateTime(2025, 1, day);
        // Pega o herói correspondente ao dia
        final heroForToday = fakeHeroes[day - 1];

        // Configura o mock para retornar o herói do dia quando fetchHeroesPage for chamado
        when(mockHeroService.fetchHeroesPage(any, any))
            .thenAnswer((_) async => [heroForToday]);

        // Tenta adicionar a carta à coleção na data simulada
        final bool result = await cardService.addToCollection(now: fakeNow);

        if (day <= 15) {
          // Para os primeiros 15 dias, a adição deve ser bem-sucedida
          expect(result, isTrue, reason: 'Deveria adicionar a carta no dia $day');

          // Verifica se o contador da coleção está correto
          final count = await cardService.getCollectionCount();
          expect(count, day, reason: 'A coleção deveria ter $day cartas no dia $day');
        } else {
          // No 16º dia, a adição deve falhar
          expect(result, isFalse, reason: 'Não deveria adicionar a 16ª carta');

          // Verifica se o contador da coleção permanece em 15
          final count = await cardService.getCollectionCount();
          expect(count, 15, reason: 'A coleção deveria permanecer com 15 cartas');
        }
      }
    });
  });
}