enum Suit { hearts, diamonds, clubs, spades }
enum Rank { two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace }

class PlayingCard {
  final Suit suit;
  final Rank rank;
  bool isSelected;

  PlayingCard({required this.suit, required this.rank, this.isSelected = false});

  @override
  String toString() {
    return '${rank.name} of ${suit.name}';
  }

  String get assetName {
    // This would map to asset files if we had them, 
    // for now we'll use text/icons in the UI
    return '${rank.name}_of_${suit.name}';
  }
  
  int get value {
    if (rank == Rank.ace) return 15; // Usually high in May I
    if (rank.index >= Rank.ten.index) return 10; // Face cards
    if (rank == Rank.two) return 2; // Sometimes wild
    return rank.index + 2; // 3-9
  }
}

class Player {
  final String name;
  final bool isHuman;
  List<PlayingCard> hand = [];
  int score = 0;
  List<List<PlayingCard>> melds = [];

  Player({required this.name, required this.isHuman});
}
