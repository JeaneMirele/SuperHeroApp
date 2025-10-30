import 'package:flutter/material.dart';
import 'package:super_app/service/hero_service.dart';
import '../../model/card_model.dart';
import '../../model/hero_model.dart';
import '../../service/card_service.dart';

class BattlePage extends StatefulWidget {
  const BattlePage({super.key});

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  List<CardModel> myCards = [];
  bool isLoading = true;

  int myIndex = 0;
  int myScore = 0;
  String? selectedAttribute;
  String? resultMessage;

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  Future<void> loadCards() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    final cardService = CardService(HeroService());
    var allCards = await cardService.getCollection();
    allCards.shuffle();
    myCards = allCards.take(15).toList();

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  void selectAttribute(String attribute) {
    setState(() {
      selectedAttribute = attribute;
    });
  }

  void declareVictory() {
    setState(() {
      myScore++;
      resultMessage = "Você venceu o round!";
    });
  }

  void declareDefeat() {
    setState(() {
      resultMessage = "Você perdeu o round.";
    });
  }

  void declareDraw() {
    setState(() {
      resultMessage = "O round empatou!";
    });
  }

  void nextRound() {
    setState(() {
      myIndex++;
      selectedAttribute = null;
      resultMessage = null;
    });
  }

  void restartGame() {
    setState(() {
      myIndex = 0;
      myScore = 0;
      selectedAttribute = null;
      resultMessage = null;
      loadCards();
    });
  }

  void _endGame() {
    setState(() {
      myIndex = myCards.length;
    });
  }


  Future<void> _showEndGameDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Encerrar Jogo?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tem certeza que deseja terminar a batalha?'),
                Text('O placar atual será exibido.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: const Text('Encerrar'),
              onPressed: () {
                Navigator.of(context).pop();
                _endGame();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (myCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Batalha")),
        body: const Center(
          child: Text("Você não tem cartas para batalhar."),
        ),
      );
    }

    final cardStyle = CardStyle(context);
    final bool isGameOver = myIndex >= myCards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isGameOver ? "Fim de Jogo" : "Batalha - Round ${myIndex + 1}/${myCards.length}"
        ),

        actions: [

          if (!isGameOver)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Encerrar Jogo',
              onPressed: _showEndGameDialog,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isGameOver
            ? _buildGameOver(cardStyle)
            : _buildBattle(cardStyle),
      ),
    );
  }



  Widget _buildBattle(CardStyle style) {
    final card = myCards[myIndex];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCard(card, style),
          const SizedBox(height: 24),

          _buildActionButtons(style),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CardStyle style) {
    if (resultMessage != null) {
      return Column(
        children: [
          Text(
            resultMessage!,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: style.text),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: nextRound,
            style: ElevatedButton.styleFrom(
              backgroundColor: style.button,
              foregroundColor: style.buttonText,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Próximo Round"),
          ),
        ],
      );
    }
    else if (selectedAttribute != null) {
      return Column(
        children: [
          Text(
            "Compare o atributo '${_attributeLabel(selectedAttribute!)}' com seu amigo e declare o resultado:",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: style.text),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(onPressed: declareVictory, child: const Text("Ganhei o round")),
              ElevatedButton(onPressed: declareDefeat, child: const Text("Perdi o round")),
              ElevatedButton(onPressed: declareDraw, child: const Text("Empate")),
            ],
          ),
        ],
      );
    }
    else {
      return Column(
        children: [
          Text(
            "Escolha um atributo para competir:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: style.text),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              'intelligence', 'strength', 'speed', 'durability', 'power', 'combat'
            ].map((attr) {
              return ElevatedButton(
                onPressed: () => selectAttribute(attr),
                child: Text(_attributeLabel(attr)),
              );
            }).toList(),
          ),
        ],
      );
    }
  }

  Widget _buildGameOver(CardStyle style) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Fim de Jogo!",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: style.text),
          ),
          const SizedBox(height: 16),
          Text(
            "Sua pontuação final: $myScore vitórias",
            style: TextStyle(fontSize: 20, color: style.text),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: restartGame,
            child: const Text("Jogar Novamente"),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(CardModel card, CardStyle style) {
    final hero = card.hero;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    hero.imgLg.isNotEmpty ? hero.imgLg : hero.imgXs,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 100),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    hero.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: style.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAttribute("intelligence", "Inteligência", hero.intelligence, style),
            _buildAttribute("strength", "Força", hero.strength, style),
            _buildAttribute("speed", "Velocidade", hero.speed, style),
            _buildAttribute("durability", "Durabilidade", hero.durability, style),
            _buildAttribute("power", "Poder", hero.power, style),
            _buildAttribute("combat", "Combate", hero.combat, style),
          ],
        ),
      ),
    );
  }

  Widget _buildAttribute(String attrKey, String label, int value, CardStyle style) {
    final bool isSelected = selectedAttribute == attrKey;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? style.button.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: style.button, width: 2) : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: style.text,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: value / 100.0,
              color: style.button,
              backgroundColor: style.background.withOpacity(0.3),
              minHeight: 10,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              "$value",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: style.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _attributeLabel(String attr) {
    const labels = {
      "intelligence": "Inteligência",
      "strength": "Força",
      "speed": "Velocidade",
      "durability": "Durabilidade",
      "power": "Poder",
      "combat": "Combate",
    };
    return labels[attr] ?? attr;
  }
}

class CardStyle {
  final BuildContext context;
  CardStyle(this.context);

  Color get background => Theme.of(context).colorScheme.surface;
  Color get text => Theme.of(context).colorScheme.onSurface;
  Color get button => Theme.of(context).colorScheme.primary;
  Color get buttonText => Theme.of(context).colorScheme.onPrimary;
}