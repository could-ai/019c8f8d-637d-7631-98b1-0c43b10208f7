import 'dart:math';
import 'package:flutter/material.dart';
import '../models/types.dart';

class GameProvider with ChangeNotifier {
  List<PlayingCard> _deck = [];
  List<PlayingCard> _discardPile = [];
  List<Player> _players = [];
  int _currentPlayerIndex = 0;
  int _currentRound = 1;
  String _gameMessage = "Welcome to May I!";
  bool _hasDrawn = false;
  
  // Getters
  List<PlayingCard> get discardPile => _discardPile;
  List<Player> get players => _players;
  int get currentPlayerIndex => _currentPlayerIndex;
  Player get currentPlayer => _players[_currentPlayerIndex];
  String get gameMessage => _gameMessage;
  bool get hasDrawn => _hasDrawn;
  int get currentRound => _currentRound;

  GameProvider() {
    _initializeGame();
  }

  void _initializeGame() {
    _players = [
      Player(name: "You", isHuman: true),
      Player(name: "Bot 1", isHuman: false),
      Player(name: "Bot 2", isHuman: false),
    ];
    _startRound();
  }

  void _startRound() {
    _deck = _createDeck();
    _discardPile = [];
    _hasDrawn = false;
    _currentPlayerIndex = 0;
    
    // Deal cards (usually 11 in May I, but varies by round)
    int cardsToDeal = 11; 
    
    for (var player in _players) {
      player.hand = [];
      player.melds = [];
      for (int i = 0; i < cardsToDeal; i++) {
        if (_deck.isNotEmpty) {
          player.hand.add(_deck.removeLast());
        }
      }
      _sortHand(player.hand);
    }

    // Flip first card
    if (_deck.isNotEmpty) {
      _discardPile.add(_deck.removeLast());
    }
    
    _gameMessage = "Round $_currentRound started. Your turn!";
    notifyListeners();
  }

  List<PlayingCard> _createDeck() {
    List<PlayingCard> newDeck = [];
    // May I usually uses 2-3 decks. Let's use 2 for 3 players.
    for (int i = 0; i < 2; i++) {
      for (var suit in Suit.values) {
        for (var rank in Rank.values) {
          newDeck.add(PlayingCard(suit: suit, rank: rank));
        }
      }
    }
    newDeck.shuffle(Random());
    return newDeck;
  }

  void drawFromDeck() {
    if (_hasDrawn) return;
    if (_deck.isEmpty) {
      // Reshuffle discard if deck empty
      if (_discardPile.length > 1) {
        var topCard = _discardPile.removeLast();
        _deck.addAll(_discardPile);
        _discardPile.clear();
        _discardPile.add(topCard);
        _deck.shuffle();
      } else {
        _gameMessage = "Deck is empty!";
        notifyListeners();
        return;
      }
    }
    
    currentPlayer.hand.add(_deck.removeLast());
    _hasDrawn = true;
    _sortHand(currentPlayer.hand);
    _gameMessage = "Card drawn. Discard to end turn.";
    notifyListeners();
  }

  void drawFromDiscard() {
    if (_hasDrawn) return;
    if (_discardPile.isEmpty) return;

    currentPlayer.hand.add(_discardPile.removeLast());
    _hasDrawn = true;
    _sortHand(currentPlayer.hand);
    _gameMessage = "Card taken from discard. Discard to end turn.";
    notifyListeners();
  }

  void discard(PlayingCard card) {
    if (!_hasDrawn) {
      _gameMessage = "You must draw first!";
      notifyListeners();
      return;
    }

    currentPlayer.hand.remove(card);
    _discardPile.add(card);
    _endTurn();
  }

  void _endTurn() {
    _hasDrawn = false;
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    
    if (currentPlayer.isHuman) {
      _gameMessage = "Your turn!";
      notifyListeners();
    } else {
      _gameMessage = "${currentPlayer.name}'s turn...";
      notifyListeners();
      // Simulate bot turn with a delay
      Future.delayed(const Duration(seconds: 1), () {
        _botPlay();
      });
    }
  }

  void _botPlay() {
    // Simple bot logic
    // 1. Draw
    if (_discardPile.isNotEmpty && Random().nextBool()) {
       // Take from discard sometimes
       currentPlayer.hand.add(_discardPile.removeLast());
    } else if (_deck.isNotEmpty) {
       currentPlayer.hand.add(_deck.removeLast());
    } else {
       // Handle empty deck edge case
       if (_discardPile.length > 1) {
          var top = _discardPile.removeLast();
          _deck.addAll(_discardPile);
          _discardPile.clear();
          _discardPile.add(top);
          _deck.shuffle();
          currentPlayer.hand.add(_deck.removeLast());
       }
    }
    
    // 2. Discard (random card)
    if (currentPlayer.hand.isNotEmpty) {
      PlayingCard cardToDiscard = currentPlayer.hand[Random().nextInt(currentPlayer.hand.length)];
      currentPlayer.hand.remove(cardToDiscard);
      _discardPile.add(cardToDiscard);
    }

    _endTurn();
  }

  void _sortHand(List<PlayingCard> hand) {
    hand.sort((a, b) {
      int suitComp = a.suit.index.compareTo(b.suit.index);
      if (suitComp != 0) return suitComp;
      return a.rank.index.compareTo(b.rank.index);
    });
  }
  
  // "May I" logic would go here - allowing out of turn players to take discard
  void requestMayI(Player player) {
    // Implementation for May I requests
    // Usually adds the discard + 1 penalty card
  }
}
