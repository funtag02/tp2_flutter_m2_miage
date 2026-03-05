# flutter_application_2

TODO : à remplir if infos spécifiques.

## Détails supplémentaires et expérimentations

Pour la quantité, ce n'était pas demandé, mais le fait d'avoir ajotué des + et - pour gérer les quantités, j'ai introduit une faille : si j'appuie très rapidement en succession, la valeur dans la bdd ne se mettra pas à jour rapidement. 

Pour y remédier, on peut

- soit retirer les ajouts et suppressions à l'unité depuis le panier
- soit implémenter une feature de menu déroulant pour choisir le nombre
- soit implémenter une feature de choix de nombre en input (champ libre mais int)