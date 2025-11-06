class HypnoticTexts {
  // Textes d'induction (écran d'accueil)
  static const List<String> inductionTexts = [
    "Prenez un instant pour ralentir…",
    "Observez simplement votre respiration.",
    "Laissez votre attention se déposer ici, maintenant.",
  ];

  // Phrases de transition
  static const Map<String, List<String>> transformationPhases = {
    'recognition': [
      "Voici comment votre esprit représentait cette situation…",
      "Remarquez simplement cette représentation…",
    ],
    'dissociation': [
      "Remarquez comme, à mesure que cela s'éloigne, quelque chose en vous s'allège…",
      "Observez cette distance qui se crée naturellement…",
    ],
    'transformation': [
      "Laissez venir une couleur qui symbolise votre force intérieure…",
      "Une nouvelle perspective émerge doucement…",
    ],
    'integration': [
      "Cette nouvelle perspective est déjà vôtre…",
      "Remarquez comme c'est simple et naturel…",
    ],
  };

  // Questions d'exploration des sous-modalités
  static const Map<String, String> submodalityQuestions = {
    'distance': "Quand vous pensez à cette situation… l'image est-elle proche ou éloignée ?",
    'brightness': "L'image est-elle lumineuse ou sombre ?",
    'size': "Cette image occupe-t-elle tout votre champ de vision, ou juste une partie ?",
    'color': "Choisissez une couleur qui représente cette situation",
    'clarity': "L'image est-elle nette ou floue ?",
    'sound': "Y a-t-il un son associé à cette image ?",
  };

  // Thèmes de transformation
  static const Map<String, Map<String, String>> themes = {
    'fear': {
      'title': 'Diminuer une peur',
      'emoji': '🌊',
      'description': 'Transformez la représentation d\'une peur en quelque chose de plus léger',
    },
    'belief': {
      'title': 'Modifier une croyance limitante',
      'emoji': '🔓',
      'description': 'Reprogrammez une croyance qui vous limite',
    },
    'memory': {
      'title': 'Transformer un souvenir',
      'emoji': '🎞️',
      'description': 'Changez votre relation à un souvenir difficile',
    },
    'resource': {
      'title': 'Renforcer une ressource intérieure',
      'emoji': '💎',
      'description': 'Amplifiez une qualité que vous possédez déjà',
    },
  };

  // Instructions d'ancrage
  static const List<String> anchorInstructions = [
    "Maintenant, créons ensemble un geste simple…",
    "Ce geste vous rappellera cet état chaque fois que vous le referez.",
    "Répétez ce geste trois fois, lentement…",
  ];

  // Questions de clôture
  static const String closureQuestion =
      "Sur une échelle de 0 à 10, quelle est l'intensité maintenant ?";
  static const String journalPrompt =
      "Que souhaitez-vous vous rappeler de cette expérience ?";
}
