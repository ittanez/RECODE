# ReCode

**Transformez votre réalité intérieure en silence**

Application Android de reprogrammation sensorielle silencieuse par PNL et hypnose visuelle.

## 📱 À propos

ReCode est une application thérapeutique innovante qui permet de modifier les sous-modalités sensorielles (VAKOG) associées à une émotion, un souvenir ou une croyance, en utilisant uniquement des interactions visuelles, textuelles et tactiles — **sans aucun composant audio**.

### Philosophie

- **Minimalisme hypnotique** : Interfaces épurées, animations lentes et fluides
- **Interactivité kinesthésique** : Chaque geste tactile devient un ancrage thérapeutique
- **Progression suggestive** : Le texte guide subtilement sans diriger explicitement
- **Discrétion absolue** : Utilisable en tout lieu, sans casque ni son

## ✨ Fonctionnalités

### Parcours de transformation

1. **Écran d'accueil / Induction**
   - Animation de respiration visuelle
   - Textes hypnotiques progressifs
   - Induction d'un état de calme

2. **Sélection du thème**
   - 🌊 Diminuer une peur
   - 🔓 Modifier une croyance limitante
   - 🎞️ Transformer un souvenir
   - 💎 Renforcer une ressource intérieure

3. **Exploration des sous-modalités**
   - Distance (proche/éloigné)
   - Luminosité (sombre/lumineux)
   - Taille (petit/grand)
   - Couleur dominante
   - Netteté (flou/net)
   - Son associé (optionnel)

4. **Transformation visuelle guidée**
   - Phase de reconnaissance
   - Phase de dissociation
   - Phase de transformation
   - Phase d'intégration
   - Durée totale : 60-90 secondes

5. **Ancrage kinesthésique**
   - Création d'un déclencheur tactile
   - Renforcement par répétition (3x)
   - Feedback haptique

6. **Journal et clôture**
   - Évaluation post-transformation
   - Notes personnelles
   - Comparaison avant/après

## 🛠️ Stack Technique

### Framework & Langages
- **Flutter** 3.24+
- **Dart** 3.0+

### Dépendances principales
- `flutter_riverpod` : Gestion d'état
- `sqflite` : Base de données locale
- `encrypt` : Chiffrement des données
- `flutter_animate` : Animations fluides
- `vibration` : Feedback haptique
- `fl_chart` : Visualisations statistiques

### Architecture

```
lib/
├── core/               # Configuration centrale
│   ├── theme/         # Thème et couleurs
│   ├── utils/         # Utilitaires
│   └── constants/     # Constantes (textes hypnotiques)
├── data/              # Couche de données
│   ├── models/        # Modèles de données
│   └── repositories/  # Accès aux données
├── presentation/      # Interface utilisateur
│   ├── screens/       # Écrans principaux
│   └── widgets/       # Composants réutilisables
└── domain/            # Logique métier
    └── use_cases/     # Cas d'usage et état
```

## 🚀 Installation

### Prérequis

- Flutter 3.24 ou supérieur
- Android SDK (API 26+)
- Dart 3.0+

### Étapes

1. Cloner le dépôt
```bash
git clone https://github.com/votre-repo/recode.git
cd recode
```

2. Installer les dépendances
```bash
flutter pub get
```

3. Exécuter l'application
```bash
flutter run
```

4. Compiler pour Android
```bash
flutter build apk --release
```

## 🎨 Design System

### Palette de couleurs

**Couleurs principales** (état neutre/calme)
- Primary: `#1A237E` (Bleu profond)
- Secondary: `#4A148C` (Violet hypnotique)
- Background: `#0D1117` (Noir doux)

**Couleurs ressources** (états positifs)
- Gold: `#FFD700`
- Emerald: `#50C878`
- Azure: `#007FFF`

### Typographie

- **Headline**: Inter/Poppins 24px, weight 300, spacing 1.2
- **Body**: 16px, weight 400, spacing 0.5, height 1.6
- **Caption**: 12px, weight 300, opacity 0.7

### Principes d'animation

- Durée standard : 300-500ms
- Transitions longues : 2000-4000ms
- Easing : `Curves.easeInOutCubic`
- Fluidité constante : 60 FPS

## 🔒 Sécurité & Confidentialité

- ✅ Stockage **100% local** (aucune donnée envoyée sur serveur)
- ✅ Chiffrement AES-256 pour les notes personnelles
- ✅ Option de purge complète des données
- ✅ Permissions minimales (uniquement vibration)
- ✅ Pas d'accès Internet requis

## 📊 Données collectées

Toutes les données sont stockées **localement** sur l'appareil :

- Intensité émotionnelle avant/après transformation
- Sous-modalités sélectionnées
- Notes personnelles (chiffrées)
- Statistiques d'utilisation

**Aucune donnée n'est transmise à des serveurs externes.**

## 🧪 Tests

```bash
# Lancer tous les tests
flutter test

# Tests avec couverture
flutter test --coverage
```

## 📦 Build & Déploiement

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (pour Google Play)
flutter build appbundle --release
```

### Configuration

- **Package name**: `com.novahypnose.recode`
- **Min SDK**: 26 (Android 8.0)
- **Target SDK**: 34 (Android 14)

## 📈 Roadmap

### Phase 1 : MVP ✅
- [x] Écrans 1-6 (parcours complet de base)
- [x] 4 thèmes fonctionnels
- [x] Base de données locale
- [x] Animations essentielles
- [x] State management avec Riverpod

### Phase 2 : Enrichissement (À venir)
- [ ] Mode "Écriture hypnotique"
- [ ] Mode "Visualisation libre"
- [ ] Statistiques avancées avec graphiques
- [ ] Export/Import de données
- [ ] Personnalisation des couleurs

### Phase 3 : Optimisation (À venir)
- [ ] Tests utilisateurs
- [ ] Optimisation performances
- [ ] Tests automatisés
- [ ] Documentation utilisateur complète

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👥 Auteurs

- **Nova Hypnose** - Conception & développement initial

## 🙏 Remerciements

- Inspiré par les travaux de Richard Bandler et John Grinder (PNL)
- Remerciements à la communauté Flutter pour les excellents packages

---

**ReCode** - Transformez votre réalité intérieure, en silence. 🌟
