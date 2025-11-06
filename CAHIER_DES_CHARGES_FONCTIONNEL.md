# 📋 Cahier des Charges Fonctionnel - ReCode

**Application de reprogrammation sensorielle silencieuse par PNL et hypnose visuelle**

Version : 1.0
Date : 06 Novembre 2025
Plateforme : Android (minimum API 26 / Android 8.0)
Technologie : Flutter 3.24+ / Dart 3.0+

---

## 🎯 1. VISION ET OBJECTIFS

### 1.1 Vision Générale
ReCode est une application Android de thérapie autonome permettant à l'utilisateur de transformer ses représentations mentales négatives (peurs, croyances limitantes, souvenirs difficiles) en utilisant les techniques de PNL (Programmation Neuro-Linguistique) et d'hypnose visuelle.

### 1.2 Principe Fondamental
**MODE SILENCIEUX UNIQUEMENT** : Aucun son audio. L'expérience repose exclusivement sur :
- ✅ Interactions visuelles (animations, couleurs, textes)
- ✅ Interactions tactiles (gestes, touches)
- ✅ Retour haptique (vibrations)

### 1.3 Objectifs Thérapeutiques
- Diminuer l'intensité émotionnelle d'une situation difficile
- Transformer les sous-modalités sensorielles (VAKOG) d'une représentation mentale
- Créer un ancrage kinesthésique pour retrouver l'état ressource
- Permettre une pratique autonome, sans thérapeute
- **NOUVEAU** : Utiliser le support visuel (le **Cercle Miroir**) comme un médiateur interactif pour faciliter la manipulation symbolique de la représentation mentale intérieure

---

## 🗺️ 2. PARCOURS UTILISATEUR GLOBAL

```
┌─────────────────┐
│ 1. ACCUEIL      │  Induction hypnotique + respiration guidée (24s)
│ (Welcome)       │  → Vibration à chaque expiration
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 2. THÈMES       │  Choix du problème à transformer
│ (Theme)         │  → 4 icônes animées
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 3. EXPLORATION  │  Exploration des sous-modalités (6 exercices)
│ (Exploration)   │  → Gestes naturels (glisser, pincer)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 4. ÉVALUATION   │  Intensité émotionnelle initiale (0-10)
│ (Dialog)        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 5. TRANSFO      │  Transformation visuelle progressive (80s)
│ (Transform)     │  → 4 phases hypnotiques
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 5b. FEEDBACK    │  Message "LE CODE EST MODIFIÉ ✨" (5s)
│ (Post-Transfo)  │  → Vibration longue + cercle transformé
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 6. ANCRAGE      │  Création d'un geste physique reproductible
│ (Anchor)        │  → 3 répétitions avec vibration
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 7. JOURNAL      │  Réévaluation + notes personnelles
│ (Journal)       │  → Sauvegarde SQLite
└─────────────────┘
```

**Durée totale** : ~5-8 minutes par session

---

## 📱 3. SPÉCIFICATIONS PAR ÉCRAN

### 3.1 ÉCRAN D'ACCUEIL (WelcomeScreen)

#### Objectif
Induire un état de relaxation et de réceptivité hypnotique par la respiration guidée.

#### Éléments visuels
- **Logo** : "ReCode" (48px, espacement 8, poids 200)
- **Sous-titre** : "Transformez votre réalité intérieure en silence"
- **Animation de respiration** : Cercle pulsant (120-160px)
  - Cycle : 8 secondes (4s inspire + 4s expire)
  - Couleur : Bleu azur avec gradient radial
  - Courbe : `Curves.easeInOut`
- **Textes hypnotiques** (séquentiels, 4s entre chaque) :
  1. "Prenez un instant pour ralentir…"
  2. "Observez simplement votre respiration."
  3. "Laissez votre attention se déposer ici, maintenant."

#### Interactions
- **Retour haptique** : Vibration 50ms à chaque expiration (détection automatique)
- **Guidance yeux** (protocole YO/YF) :
  - Cycle 2 : "Si vous le souhaitez... fermez doucement les yeux"
  - **Cycle 3 (NOUVEAU)** : "Laissez vos yeux se fermer. Faites le point sur l'image que vous venez de choisir."
  - Cycle 4 : "Vous pouvez rouvrir les yeux... en douceur, ou les garder clos si cela est confortable. L'écran va maintenant vous guider."
- **Continuer** : Toucher l'écran après 24 secondes
- **Transition** : Fade 800ms vers écran Thèmes

#### Données techniques
- Durée minimale : 24 secondes
- Fréquence haptique : 0.125 Hz (toutes les 8s)
- Background : Gradient vertical (noir → bleu nuit → noir)

---

### 3.2 ÉCRAN SÉLECTION THÈME (ThemeSelectionScreen)

#### Objectif
Permettre à l'utilisateur de choisir la problématique à transformer.

#### Thèmes disponibles (4)

| Clé | Titre | Description | Icône animée |
|-----|-------|-------------|--------------|
| `fear` | Diminuer une peur | Transformez la représentation d'une peur en quelque chose de plus léger | ☁️ Nuage dissolvant (4s) |
| `belief` | Modifier une croyance limitante | Reprogrammez une croyance qui vous limite | 🔓 Cadenas s'ouvrant (3s) |
| `memory` | Transformer un souvenir | Changez votre relation à un souvenir difficile | 🌀 Spirale hypnotique (4s) |
| `resource` | Renforcer une ressource intérieure | Amplifiez une qualité que vous possédez déjà | 🌱 Graine germant (3s) |

#### Éléments visuels
- **Titre** : "Que souhaitez-vous transformer ?"
- **Cartes thème** : Gradient (primaire → secondaire), bordure or
- **Icônes** : CustomPaint animés en boucle
  - Nuage : Opacité décroissante + particules s'éloignant
  - Cadenas : Anse qui s'ouvre progressivement
  - Spirale : Rotation continue 360°
  - Graine : Tige qui pousse + feuilles qui apparaissent
- **État hover** : Bordure or + glow + intensité accrue

#### Interactions
- **Tap carte** : Sélection + vibration + transition fade 600ms
- **Animation entrée** : Slide-X depuis gauche, 800ms

#### Données sauvegardées
```dart
transformationState.theme = 'fear' | 'belief' | 'memory' | 'resource'
```

---

### 3.3 ÉCRAN EXPLORATION (ExplorationScreen)

#### Objectif
Explorer les sous-modalités sensorielles (VAKOG) de la représentation mentale actuelle.

#### Concept clé : Le Cercle Miroir
**LE CERCLE = VOTRE REPRÉSENTATION INTÉRIEURE**

**NOTE PÉDAGOGIQUE CRITIQUE** : Le cercle est le **Symbole Miroir** de l'image ou de la sensation que vous avez dans votre tête. Les gestes (glisser, pincer) vous aident à donner un mouvement physique à une idée intérieure.

**Décision Design** :
- ❌ **PAS de téléchargement d'image** : L'objectif de la PNL est de manipuler la représentation symbolique et non une photo concrète. Une photo chargerait trop l'émotion et rendrait la dissociation difficile.
- ✅ **Cercle azur constant** : Maintenir le cercle sur une couleur azur constante tout au long des 6 exercices pour renforcer la cohérence visuelle de la "Représentation" unique manipulée.

#### Structure des exercices (Alternance Yeux Ouverts/Fermés)

Chaque exercice suit une structure en **3 phases** :

**Étape 1 : Manipulation (YO - Yeux Ouverts)**
- Question posée
- Interaction tactile pour ajuster le cercle
- Feedback visuel immédiat

**Étape 2 : Intégration (YF - Yeux Fermés)**
- Bouton "Fermer les yeux et ressentir" (recommandé mais non-bloquant)
- Instruction : "Fermez les yeux. Observez l'image ajustée. Prenez note de la sensation dans votre corps."
- Pause silencieuse (5-10 secondes)

**Étape 3 : Validation (YO - Continuer)**
- Bouton "Suivant"
- Instruction : "Ouvrez les yeux. Nous passons à l'attribut suivant."

#### 6 Exercices successifs

##### 3.3.1 Distance (Exemple structure 3 phases)

**Étape 1 : Manipulation (YO)**
- **Question** : "Quand vous pensez à cette situation… l'image est-elle proche ou éloignée ?"
- **Interaction** : Glisser verticalement (drag)
  - ⬆️ Haut = Proche (cercle GRAND 200px, opaque)
  - ⬇️ Bas = Éloigné (cercle PETIT 100px, transparent)
- **Visuel** : Cercle **azur constant** avec gradient radial
- **Labels** : "PROCHE ⬆️" / "Moyen" / "ÉLOIGNÉ ⬇️" + pourcentage
- **Instruction** : "Ajustez la distance sur l'écran pour qu'elle corresponde à celle que vous avez en tête."
- **Feedback haptique** : Léger retour (20ms) lors du drag

**Étape 2 : Intégration (YF)**
- **Bouton** : "Fermer les yeux et ressentir" (apparaît après ajustement)
- **Instruction** : "Fermez les yeux. Observez l'image ajustée. Prenez note de la sensation dans votre corps."
- **Durée** : 5-10 secondes (timer invisible)

**Étape 3 : Validation (YO)**
- **Bouton** : "Suivant"
- **Instruction** : "Ouvrez les yeux. Nous passons à l'attribut suivant."

##### 3.3.2 Luminosité
- **Question** : "L'image est-elle lumineuse ou sombre ?"
- **Interaction** : Slider horizontal (0.0 - 1.0)
  - Gauche = Sombre (opacité 0%)
  - Droite = Lumineux (opacité 100%)
- **Visuel** : Cercle **azur constant** 220px dont l'opacité varie
- **Labels** : "Sombre" ↔ "Lumineux"
- **Feedback haptique** : Léger retour (20ms) lors du déplacement du slider
- **Structure 3 phases** : Idem 3.3.1 (Manipulation → Intégration YF → Validation YO)

##### 3.3.3 Taille
- **Question** : "Cette image occupe-t-elle tout votre champ de vision, ou juste une partie ?"
- **Interaction** : Geste pincer (pinch-to-zoom)
  - Pincer = Petit (100px)
  - Écarter = Grand (250px)
- **Visuel** : Cercle **azur constant** avec icône `open_in_full`
- **Labels** : "Petit" / "Moyen" / "Grand" + pourcentage
- **Feedback haptique** : Léger retour (20ms) lors du pinch
- **Structure 3 phases** : Idem 3.3.1

##### 3.3.4 Couleur
- **Question** : "Choisissez une couleur qui représente cette situation"
- **Interaction** : Sélection parmi 10 couleurs
- **Palette** :
  - Gris, Rouge, Orange, Jaune, Vert
  - Bleu, Indigo, Violet, Or, Émeraude
- **Visuel** : Cercles 60px, bordure or si sélectionné
- **Note** : Le cercle principal reste azur, seuls les boutons de choix sont colorés
- **Structure 3 phases** : Idem 3.3.1

##### 3.3.5 Netteté (MODIFIÉ : Cercle uniforme)
- **Question** : "L'image est-elle nette ou floue ?"
- **Interaction** : Slider horizontal (0.0 - 1.0)
- **Visuel** : **Cercle azur 220px** (non rectangle !) avec BackdropFilter blur
  - Flou max : sigmaX/Y = 10
  - Net : sigmaX/Y = 0
- **Labels** : "Flou" ↔ "Net"
- **Feedback haptique** : Léger retour (20ms) lors du déplacement du slider
- **Justification** : Maintenir la cohérence de l'objet "Cercle Miroir" manipulé
- **Structure 3 phases** : Idem 3.3.1

##### 3.3.6 Son
- **Question** : "Y a-t-il un son associé à cette image ?"
- **Interaction** : Boutons radio (3 choix)
  - Silencieux
  - Doux
  - Fort
- **Visuel** : Boutons arrondis, fond or si sélectionné
- **Structure 3 phases** : Idem 3.3.1

#### Navigation
- **Bouton suivant** : "Suivant" (1-5) ou "Transformer" (6)
- **Barre progression** : LinearProgressIndicator (1/6 → 6/6)
- **Transition** : AnimatedSwitcher 500ms entre exercices

#### Données sauvegardées
```dart
Submodality {
  distance: 0.0-1.0,
  brightness: 0.0-1.0,
  size: 0.0-1.0,
  colorValue: Color.value (int),
  clarity: 0.0-1.0,
  soundLevel: 'silent' | 'soft' | 'loud'
}
```

---

### 3.4 DIALOGUE ÉVALUATION INITIALE

#### Objectif
Mesurer l'intensité émotionnelle AVANT transformation pour comparaison ultérieure.

#### Éléments
- **Titre** : "Évaluation initiale"
- **Question** : "Sur une échelle de 0 à 10, quelle est l'intensité de cette émotion/sensation maintenant ?"
- **Précision** : "(0 = Minimum, 10 = Maximum)" (texte or italique)
- **Slider** : 0-10 (divisions 10)
- **Affichage** : Nombre en très gros (36px, bold, or)
- **Labels** : "0\nMin" et "10\nMax" sous le slider
- **Bouton** : "Continuer" (or)

#### Interaction
- Modal non-dismissible (barrierDismissible: false)
- Valeur par défaut : 5

#### Données sauvegardées
```dart
transformationState.intensityBefore = 0-10
```

---

### 3.5 ÉCRAN TRANSFORMATION (TransformationScreen)

#### Objectif
Effectuer la transformation visuelle progressive des sous-modalités pendant 80 secondes, accompagnée de textes hypnotiques.

#### Durée et phases
**Total : 80 secondes**

| Phase | Durée | Description | Textes hypnotiques |
|-------|-------|-------------|--------------------|
| 1. Reconnaissance | 20s | Affichage représentation actuelle | "Voici comment votre esprit représentait cette situation…" |
| 2. Dissociation | 20s | Distance augmente, opacité baisse | "Remarquez comme, à mesure que cela s'éloigne, quelque chose en vous s'allège…" |
| 3. Transformation | 20s | Couleur change vers émeraude, taille diminue | "Laissez venir une couleur qui symbolise votre force intérieure…" |
| 4. Intégration | 20s | Stabilisation finale | "Cette nouvelle perspective est déjà vôtre…" |

#### Transformation automatique appliquée
```dart
Original (de l'exploration) → Transformé
{
  distance: X → 0.7 (plus éloigné = moins intense)
  brightness: X → 0.8 (plus lumineux = plus positif)
  size: X → 0.4 (plus petit = moins envahissant)
  colorValue: X → Émeraude (couleur ressource)
  clarity: X → 0.6 (légèrement flou = dissociation)
  soundLevel: X → 'soft' (apaisant)
}
```

#### Éléments visuels
- **Cercle central** : Morphing progressif selon sous-modalités
- **Textes hypnotiques** : Apparition/disparition lente (fade 3s)
- **Timer invisible** : Transition automatique après 80s

#### Interactions
- **Aucune** : L'utilisateur observe passivement
- **Transition automatique** : Vers écran Feedback post-transformation après 80s

---

### 3.5.0 FEEDBACK POST-TRANSFORMATION (NOUVEAU)

#### Objectif
Expliciter le changement effectué et ancrer la nouvelle représentation avant de passer à l'ancrage kinesthésique.

#### Durée
**5 secondes** (pause intégrative)

#### Éléments visuels
- **Message principal** : "LE CODE EST MODIFIÉ ✨" (42px, bold, or, centré)
- **Animation** : Fade in 1s → Stable 3s → Fade out 1s
- **Cercle transformé** : Reste visible dans son état final (émeraude, petit, éloigné, lumineux)
- **Background** : Gradient apaisant (noir → violet profond)

#### Interactions
- **Vibration longue** : 500ms (confirmation haptique du changement)
- **Transition automatique** : Vers écran Ancrage après 5 secondes

#### Justification PNL/Hypnose
Le changement visuel progressif (80s) n'est pas suffisant. Il faut un **texte de bilan explicite** pour que le cerveau enregistre consciemment la modification effectuée. C'est le pont entre la transformation visuelle et l'ancrage kinesthésique.

---

### 3.6 ÉCRAN ANCRAGE (AnchorScreen)

#### Objectif
Créer un geste physique kinesthésique reproductible n'importe où pour réactiver l'état ressource.

#### Étape 1 : Choix du geste (3 options)

| Geste | Label | Description | Emoji |
|-------|-------|-------------|-------|
| `fingerPress` | Presser deux doigts | Pressez votre pouce contre votre index | 👌 |
| `wristTouch` | Toucher le poignet | Touchez votre poignet avec deux doigts | ✌️ |
| `fingerCross` | Croiser les doigts | Croisez l'index et le majeur | 🤞 |

#### Étape 2 : Répétition du geste (3x)

- **Instruction contextuelle** : Affichée selon le geste choisi
  - Ex: "Pressez fermement votre pouce\ncontre votre index"
- **Cercle central** : 200px, gradient or/émeraude/azur, pulsant
- **Label** : "Faites le geste\npuis touchez ici"
- **Compteur** : "1/3" → "2/3" → "3/3" (48px, bold, or)

#### Interaction
1. Utilisateur fait le geste physique
2. Utilisateur touche le cercle
3. **Vibration 100ms**
4. Compteur s'incrémente
5. Répéter 3 fois

#### Message final
- "Votre ancrage est créé ✨"
- "Vous pourrez le reproduire n'importe où"
- Transition automatique après 2s → Journal

#### Données sauvegardées
```dart
transformationState.anchorType = 'fingerPress' | 'wristTouch' | 'fingerCross'
```

---

### 3.7 ÉCRAN JOURNAL (JournalScreen)

#### Objectif
Réévaluer l'intensité émotionnelle APRÈS transformation et permettre à l'utilisateur de noter ses observations.

#### Section 1 : Réévaluation

- **Question** : "Sur une échelle de 0 à 10, quelle est l'intensité maintenant ?"
- **Précision** : "(0 = Minimum, 10 = Maximum)"
- **Slider** : 0-10
- **Affichage** : Nombre 36px, bold, or
- **Labels** : "0\nMin" et "10\nMax"

#### Section 2 : Notes personnelles

- **Question** : "Que souhaitez-vous vous rappeler de cette expérience ?"
- **Champ texte** : TextField multilignes (3-5 lignes)
- **Placeholder** : "Notez vos observations, sensations, prises de conscience..."

#### Bouton final
- **Label** : "Terminer la session"
- **Action** : Sauvegarde SQLite + retour écran d'accueil

#### Données sauvegardées
```dart
Transformation {
  id: UUID,
  theme: String,
  date: DateTime,
  intensityBefore: int,
  intensityAfter: int,
  initialSubmodality: Submodality (JSON),
  transformedSubmodality: Submodality (JSON),
  anchorType: String,
  notes: String,
}
```

---

## 🏗️ 4. ARCHITECTURE TECHNIQUE

### 4.1 Structure Clean Architecture

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart              # Thème dark hypnotique
│   └── constants/
│       └── texts.dart                   # Tous les textes de l'app
├── data/
│   ├── models/
│   │   ├── submodality.dart            # Modèle sous-modalités
│   │   └── transformation.dart         # Modèle transformation complète
│   └── repositories/
│       └── transformation_repository.dart  # Accès SQLite
├── domain/
│   └── use_cases/
│       └── transformation_state.dart    # StateNotifier Riverpod
└── presentation/
    ├── screens/
    │   ├── welcome_screen.dart          # 1. Accueil
    │   ├── theme_selection_screen.dart  # 2. Thèmes
    │   ├── exploration_screen.dart      # 3. Exploration
    │   ├── transformation_screen.dart   # 5. Transformation
    │   ├── anchor_screen.dart           # 6. Ancrage
    │   └── journal_screen.dart          # 7. Journal
    └── widgets/
        ├── hypnotic_text.dart           # Textes animés
        ├── submodality_slider.dart      # Sliders + color picker
        └── animated_theme_icons.dart    # Icônes CustomPaint
```

### 4.2 Technologies utilisées

| Dépendance | Version | Usage |
|------------|---------|-------|
| `flutter` | 3.24.0+ | Framework UI |
| `flutter_riverpod` | 2.4.9 | Gestion d'état |
| `sqflite` | 2.3.0 | Base de données locale |
| `encrypt` | 5.0.3 | Chiffrement données sensibles |
| `flutter_animate` | 4.3.0 | Animations déclaratives |
| `vibration` | 1.8.4 | Retour haptique |
| `fl_chart` | 0.65.0 | Graphiques (statistiques futures) |

### 4.3 Gestion d'état (Riverpod)

```dart
// Provider global
final transformationProvider = StateNotifierProvider<TransformationNotifier, TransformationState>((ref) {
  return TransformationNotifier();
});

// État
class TransformationState {
  final String? theme;
  final Submodality? currentSubmodality;
  final Submodality? transformedSubmodality;
  final int? intensityBefore;
  final int? intensityAfter;
  final String? anchorType;
  final String? notes;
}

// Actions
class TransformationNotifier extends StateNotifier<TransformationState> {
  void selectTheme(String theme);
  void updateSubmodality(Submodality submodality);
  void updateIntensityBefore(int intensity);
  void updateIntensityAfter(int intensity);
  Future<void> saveTransformation();
}
```

### 4.4 Base de données SQLite

```sql
CREATE TABLE transformations (
  id TEXT PRIMARY KEY,
  theme TEXT NOT NULL,
  date INTEGER NOT NULL,
  intensity_before INTEGER,
  intensity_after INTEGER,
  initial_submodality TEXT, -- JSON
  transformed_submodality TEXT, -- JSON
  anchor_type TEXT,
  notes TEXT
);
```

---

## 🎨 5. DESIGN SYSTEM

### 5.1 Palette de couleurs

```dart
class AppTheme {
  // Couleurs principales
  static const primary = Color(0xFF1A237E);    // Bleu nuit profond
  static const secondary = Color(0xFF4A148C);  // Violet hypnotique
  static const background = Color(0xFF0D1117); // Noir doux

  // Couleurs accent
  static const gold = Color(0xFFFFD700);       // Or (highlights)
  static const emerald = Color(0xFF50C878);    // Émeraude (ressource)
  static const azure = Color(0xFF007FFF);      // Azur (calme)

  // Textes
  static const textPrimary = Color(0xFFE6E6E6);
  static const textSecondary = Color(0xFFB0B0B0);
}
```

### 5.2 Typographie

```dart
TextTheme(
  headlineLarge: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    letterSpacing: 2,
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
  bodySmall: TextStyle(
    fontSize: 13,
    color: textSecondary,
  ),
)
```

### 5.3 Animations

- **Durées standard** :
  - Fade in/out : 1000-2000ms
  - Transitions écrans : 600-800ms
  - Morphing : 300-500ms
- **Courbes** : `Curves.easeInOut`, `Curves.easeInOutCubic`
- **Framerate** : 60 FPS constant

---

## 🔒 6. CONTRAINTES ET EXIGENCES

### 6.1 Contraintes techniques
- ✅ Android uniquement (API 26+)
- ✅ Fonctionne 100% hors ligne
- ✅ Aucun audio requis
- ✅ Données stockées localement (SQLite)
- ✅ Chiffrement des données sensibles
- ✅ Respect de la vie privée (aucune télémétrie)

### 6.2 Contraintes UX
- ✅ Parcours linéaire et guidé (pas de retour arrière)
- ✅ Pas de comptes utilisateur / connexion
- ✅ Interface épurée, peu de texte
- ✅ Langage permissif ("Si vous le souhaitez...", "Vous pouvez...")
- ✅ Rythme lent et apaisant
- ✅ **Protocole Yeux Ouverts / Yeux Fermés (YO/YF)** : Alternance systématique pour favoriser l'intégration
- ❌ **PAS de téléchargement d'image** : Le cercle est un symbole neutre. Une photo concrète chargerait trop l'émotion et rendrait la dissociation difficile (principe PNL)

### 6.3 Performances
- ✅ Lancement < 2 secondes
- ✅ Transitions fluides 60 FPS
- ✅ Utilisation mémoire < 150 MB
- ✅ Taille APK < 30 MB

---

## 📊 7. MÉTRIQUES DE SUCCÈS

### 7.1 Efficacité thérapeutique
- Réduction moyenne intensité : **≥ 30%** (intensityBefore → intensityAfter)
- Taux de complétion session : **≥ 80%**
- Sessions répétées (même thème) : Indicateur d'efficacité

### 7.2 UX
- Temps moyen session : **5-8 minutes**
- Taux d'abandon : **< 20%**
- Clarté des instructions (feedback qualitatif)

---

## 🚀 8. ÉTAT ACTUEL DU DÉVELOPPEMENT

### 8.1 Fonctionnalités implémentées ✅
- [x] Écran d'accueil avec respiration haptique
- [x] Sélection thème avec icônes animées
- [x] 6 exercices exploration (gestes naturels)
- [x] Dialogue évaluation avec labels clairs
- [x] Transformation visuelle automatique
- [x] Ancrage avec gestes physiques reproductibles
- [x] Journal avec réévaluation et notes
- [x] Sauvegarde SQLite
- [x] Build APK via GitHub Actions

### 8.2 Corrections récentes (06/11/2025) ✅
- [x] BUG distance inversée corrigé
- [x] Cercles agrandis (220px)
- [x] Taille min pinch augmentée (100px)
- [x] Sélecteur ambiance retiré
- [x] Questions clarifiées
- [x] Ancrage simplifié (gestes physiques)
- [x] Labels 0/10 ajoutés

### 8.3 À développer (futures phases)
- [ ] Statistiques visuelles avec graphiques
- [ ] Support photo/dessin dans journal
- [ ] Export PDF des sessions
- [ ] Mode guidé pour débutants
- [ ] Bibliothèque de ressources (sons mentaux, images positives)

---

## 📝 9. POINTS À DISCUTER / MODIFIER

**Indiquez ci-dessous les changements que vous souhaitez apporter :**

### 9.1 Fonctionnalités à ajouter
- [ ] _À compléter par l'utilisateur_

### 9.2 Fonctionnalités à modifier
- [ ] _À compléter par l'utilisateur_

### 9.3 Fonctionnalités à supprimer
- [ ] _À compléter par l'utilisateur_

### 9.4 Design / UX à améliorer
- [ ] _À compléter par l'utilisateur_

### 9.5 Textes / Instructions à reformuler
- [ ] _À compléter par l'utilisateur_

---

**Document rédigé le 06/11/2025**
**Prêt pour modifications et itérations** ✏️
