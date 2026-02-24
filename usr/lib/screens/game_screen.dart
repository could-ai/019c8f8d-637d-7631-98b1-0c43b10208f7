import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/types.dart';
import '../providers/game_provider.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF35654D), // Felt green
      appBar: AppBar(
        title: const Text('May I? Card Game'),
        backgroundColor: const Color(0xFF2A503D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Reset game
            },
          )
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          return Column(
            children: [
              // Top area: Opponents
              Expanded(
                flex: 2,
                child: _buildOpponentsArea(game),
              ),
              
              // Middle area: Deck and Discard
              Expanded(
                flex: 2,
                child: _buildTableArea(context, game),
              ),
              
              // Message Area
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  game.gameMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // Bottom area: Player Hand
              Expanded(
                flex: 3,
                child: _buildPlayerHand(context, game),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOpponentsArea(GameProvider game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: game.players.where((p) => !p.isHuman).map((player) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, color: Colors.white, size: 40),
            Text(player.name, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_none, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('${player.hand.length} cards', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            if (game.currentPlayer == player)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text("Thinking...", style: TextStyle(color: Colors.yellow, fontSize: 12)),
              )
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTableArea(BuildContext context, GameProvider game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Draw Pile
        GestureDetector(
          onTap: () {
            if (game.currentPlayer.isHuman && !game.hasDrawn) {
              game.drawFromDeck();
            }
          },
          child: Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 5, offset: Offset(2, 2))],
            ),
            child: const Center(
              child: Icon(Icons.diamond, color: Colors.white54, size: 40),
            ),
          ),
        ),
        const SizedBox(width: 40),
        // Discard Pile
        GestureDetector(
          onTap: () {
            if (game.currentPlayer.isHuman && !game.hasDrawn) {
              game.drawFromDiscard();
            }
          },
          child: Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey, width: 1),
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 5, offset: Offset(2, 2))],
            ),
            child: game.discardPile.isEmpty
                ? const Center(child: Text("Empty"))
                : _buildCardContent(game.discardPile.last),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerHand(BuildContext context, GameProvider game) {
    Player human = game.players.firstWhere((p) => p.isHuman);
    bool isMyTurn = game.currentPlayer == human;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Your Hand (${human.hand.length})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (isMyTurn && game.hasDrawn)
                const Text("Select card to discard", style: TextStyle(color: Colors.yellowAccent)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: human.hand.length,
              itemBuilder: (context, index) {
                final card = human.hand[index];
                return GestureDetector(
                  onTap: () {
                    if (isMyTurn && game.hasDrawn) {
                      game.discard(card);
                    }
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black, width: 1),
                      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 2, offset: Offset(1, 1))],
                    ),
                    child: _buildCardContent(card),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(PlayingCard card) {
    Color color = (card.suit == Suit.hearts || card.suit == Suit.diamonds) ? Colors.red : Colors.black;
    IconData icon;
    switch (card.suit) {
      case Suit.hearts: icon = Icons.favorite; break;
      case Suit.diamonds: icon = Icons.diamond; break;
      case Suit.clubs: icon = Icons.eco; break; // Close enough for clubs
      case Suit.spades: icon = Icons.shield; break; // Close enough for spades
    }

    String rankText;
    switch (card.rank) {
      case Rank.ace: rankText = "A"; break;
      case Rank.king: rankText = "K"; break;
      case Rank.queen: rankText = "Q"; break;
      case Rank.jack: rankText = "J"; break;
      case Rank.ten: rankText = "10"; break;
      default: rankText = (card.rank.index + 2).toString();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 2),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(rankText, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        Icon(icon, color: color, size: 24),
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 2),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Transform.rotate(
              angle: 3.14159,
              child: Text(rankText, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}
