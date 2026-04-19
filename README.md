# flutter_application_2

Application de vente de vêtements développée en Flutter avec Firebase.

## Tester le projer (lien github pages)

Vous rendre sur : https://funtag02.github.io/tp2_flutter_m2_miage/

## 🚀 Lancer le projet (local)

### Device testé
- ✅ Chrome (web - responsive mais format iPhone 12 Pro Max conseillé)

### Prérequis
- Flutter

### Installation
```bash
flutter pub get
flutter run -d chrome  # ou autre device
```

## 👤 Credentials de test

| Login | Password |
|-------|----------|
| chef | password123 |
| user | password456 |

---

## 📊 État des User Stories (MVP)

| US | Fonctionnalité | État | Détails |
|---|---|:-:|---|
| US#1 | Interface de login | ✅ | Authentification Firebase, validation de base, gestion des champs vides |
| US#2 | Liste des vêtements | ✅ | Récupération depuis Firebase, affichage en GridView (2 colonnes) |
| US#3 | Détail d'un vêtement | ✅ | Affichage complet, bouton "Ajouter au panier" fonctionnel |
| US#4 | Panier utilisateur | ✅ | Gestion des quantités, suppression items, calcul du total |
| US#5 | Profil utilisateur | ✅ | Modification des données (adresse, code postal, ville, etc.), sauvegarde en base |
| **US#6** | **Ajouter un vêtement** | **⚠️ Partielle** | **Voir section detaillée ci-dessous** |

### US#6 - Ajouter un vêtement
- ✅ Sélection d'image (caméra/galerie)
- ✅ Formulaire complet (titre, marque, taille, prix)
- ✅ Détection de catégorie par image (IA)
- ✅ Validation des champs
- ⚠️ **À compléter :** Sauvegarde réelle en Firebase (stockage des images)
- ⚠️ **À compléter :** Remplacer la détection IA aléatoire par une vraie (Cloud Vision, GPT-4V, etc.)

---

## ⚠️ Limitations et points d'amélioration (analyse de Claude Haiku 4.5)

### US#6 - Blocages identifiés

1. **Sauvegarde incomplète des articles**
   - 📍 Fichier : [`lib/service/article_service.dart`](lib/service/article_service.dart)
   - 🔴 La fonction `sauvegarder()` est un stub (TODO)
   - 🔴 Les images ne sont pas uploadées vers Firebase Storage
   - 💡 À implémenter : Appel à Firestore pour créer le doc article + upload image vers Firebase Storage

2. **Détection de catégorie par IA**
   - 📍 Fichier : [`lib/service/article_service.dart`](lib/service/article_service.dart)
   - 🔴 La détection est **aléatoire** (2sec delay simulé)
   - 💡 À implémenter : 
     - Google Cloud Vision API (classification d'images)
     - Ou ChatGPT-4 Vision
     - Ou TensorFlow Lite avec modèle pré-entraîné

### Autres améliorations futures
- Gestion des race conditions lors d'ajouts/suppressions rapides au panier (possibilité de déphasage BD)
- Implémentation d'une vraie détection IA de catégorie
- Upload et gestion des images dans Firebase Storage

---

## Détails supplémentaires et expérimentations

Pour la quantité, ce n'était pas demandé, mais le fait d'avoir ajotué des + et - pour gérer les quantités, j'ai introduit une faille : si j'appuie très rapidement en succession, la valeur dans la bdd ne se mettra pas à jour rapidement. 

Pour y remédier, on peut

- soit retirer les ajouts et suppressions à l'unité depuis le panier
- soit implémenter une feature de menu déroulant pour choisir le nombre
- soit implémenter une feature de choix de nombre en input (champ libre mais int)