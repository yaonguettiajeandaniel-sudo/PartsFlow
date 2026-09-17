# PartsFlow

Application interne de gestion d'atelier pour la flotte VTC de l'utilisateur (catalogue de pièces, stock, achats, devis, factures, ordres de réparation, prise en charge des véhicules, techniciens). Un seul fichier `index.html` (HTML/CSS/JS, aucun build step), déployé en statique sur **GitHub Pages** (`https://yaonguettiajeandaniel-sudo.github.io/PartsFlow/`) avec **Supabase** (Postgres + Auth + Realtime + RLS) comme backend. Voir le manuel intégré dans l'appli (Paramètres → Manuel d'utilisation) pour le détail de chaque module.

## Conventions de ce projet

- Toute modification du schéma passe par un nouveau fichier `migration-N.sql` (N croissant — le dernier est `migration-11.sql`) contenant uniquement le SQL du changement. On donne son contenu à l'utilisateur pour qu'il l'exécute lui-même dans Supabase (SQL Editor) — jamais exécuté par Claude directement (pas d'accès à la base depuis cette machine).
- `git push` est toujours fait par l'utilisateur dans son propre terminal, jamais par Claude.
- Après toute modification de `index.html`, valider la syntaxe JS avant de committer (pas de Node sur cette machine — utiliser `osascript -l JavaScript` avec `new Function(source)` sur le contenu du tag `<script>`, voir l'historique de conversation pour le pattern exact).
- Ne jamais mettre la clé `service_role` Supabase dans le code ; seule la clé publique (`sb_publishable_...`) est dans `index.html`.
- Les identifiants de connexion sont des emails fictifs `@cambouis.local` (pas de vraie boîte mail) — un changement de mot de passe se fait via l'API d'administration Supabase (curl + clé service_role dans le terminal de l'utilisateur), pas via "mot de passe oublié". Procédure détaillée dans le manuel intégré (Paramètres).

## Module Clients (suivi des virements "JET_S")

Second flux d'activité de l'utilisateur (vente/financement de véhicules à des clients par virement, distinct de l'atelier), initialement suivi via une appli tierce (captures d'écran "Détail du virement") et un Google Sheet séparé (formulaire d'intake : véhicule souhaité, offre, migration d'offre). Une première analyse ponctuelle (176 virements croisés avec ~150 clients du Sheet) a été livrée dans un doc Claude : https://claude.ai/code/artifact/3b61379a-c3fd-47a8-96ea-87b0e8540529.

**Intégré dans PartsFlow** (migration-11.sql, tables `clients` et `virements`) comme un onglet "Clients" normal (assignable par agent, comme les autres — pas réservé aux admins). Décisions retenues :
- Import en masse des ~150 clients existants via CSV (`CSV_SPECS.clients`, dédoublonnage par téléphone) plutôt qu'une ressaisie manuelle.
- L'attribution d'un véhicule à un client crée un véhicule réel et lié dans la flotte `vehicules` (ou réutilise un véhicule existant non déjà attribué) — pas une entité séparée.
- Processus suivi sur la fiche client : virements (envoi des justificatifs → En attente/Validé/Rejeté) puis attribution du véhicule une fois les fonds confirmés.

Reste à faire si besoin : préparer un fichier CSV prêt à importer à partir du Google Sheet actuel (pas encore régénéré depuis l'intégration du module).
