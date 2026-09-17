# PartsFlow

Application interne de gestion d'atelier pour la flotte VTC de l'utilisateur (catalogue de pièces, stock, achats, devis, factures, ordres de réparation, prise en charge des véhicules, techniciens). Un seul fichier `index.html` (HTML/CSS/JS, aucun build step), déployé en statique sur **GitHub Pages** (`https://yaonguettiajeandaniel-sudo.github.io/PartsFlow/`) avec **Supabase** (Postgres + Auth + Realtime + RLS) comme backend. Voir le manuel intégré dans l'appli (Paramètres → Manuel d'utilisation) pour le détail de chaque module.

## Conventions de ce projet

- Toute modification du schéma passe par un nouveau fichier `migration-N.sql` (N croissant — le dernier est `migration-10.sql`) contenant uniquement le SQL du changement. On donne son contenu à l'utilisateur pour qu'il l'exécute lui-même dans Supabase (SQL Editor) — jamais exécuté par Claude directement (pas d'accès à la base depuis cette machine).
- `git push` est toujours fait par l'utilisateur dans son propre terminal, jamais par Claude.
- Après toute modification de `index.html`, valider la syntaxe JS avant de committer (pas de Node sur cette machine — utiliser `osascript -l JavaScript` avec `new Function(source)` sur le contenu du tag `<script>`, voir l'historique de conversation pour le pattern exact).
- Ne jamais mettre la clé `service_role` Supabase dans le code ; seule la clé publique (`sb_publishable_...`) est dans `index.html`.
- Les identifiants de connexion sont des emails fictifs `@cambouis.local` (pas de vraie boîte mail) — un changement de mot de passe se fait via l'API d'administration Supabase (curl + clé service_role dans le terminal de l'utilisateur), pas via "mot de passe oublié". Procédure détaillée dans le manuel intégré (Paramètres).

## Chantier en cours : suivi des virements "JET_S"

L'utilisateur a un second flux d'activité (vente/financement de véhicules à des clients par virement, distinct de l'atelier) actuellement suivi via une appli tierce (captures d'écran "Détail du virement" : nom, montant envoyé/reçu, statut Validé/En attente/Rejeté) et un Google Sheet séparé (formulaire d'intake client : véhicule souhaité, offre, migration d'offre).

Une première analyse ponctuelle (176 virements croisés avec ~150 clients du Sheet) a été livrée dans un doc Claude : https://claude.ai/code/artifact/3b61379a-c3fd-47a8-96ea-87b0e8540529 — transactions regroupées par client avec validé/en attente mis en évidence, et véhicule souhaité par client (avec les changements de choix repérés).

**Prochaine étape validée par l'utilisateur : intégrer ce suivi comme un nouveau module/onglet de PartsFlow** (pas une appli séparée) — l'utilisateur veut centraliser. Processus cible déjà esquissé dans le doc : envoi des justificatifs → confirmation de réception des fonds (Validé/En attente/Rejeté, montant reçu vs envoyé) → attribution du véhicule (à relier au choix du Sheet). Ça touche vraisemblablement un nouveau concept de données ("clients"/"virements" côté PartsFlow, distinct des véhicules de la flotte atelier) — à concevoir avec l'utilisateur avant d'implémenter, pas de schéma déjà décidé.
