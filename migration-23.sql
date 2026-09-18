-- PartsFlow — migration 23 : statuts "Entrée" et "Sortie" pour les véhicules.
--
-- "Entrée" est une nouvelle valeur possible pour vehicules.statut (colonne
-- texte libre, sans contrainte à mettre à jour). "Sortie" n'est pas un
-- statut où un véhicule reste — c'est l'action qui referme un épisode de
-- présence à la base (réparation terminée, dossier administratif résolu) et
-- ramène le véhicule à "Actif" ; le motif de cette sortie est enregistré ici,
-- sur l'épisode déjà ouvert.

alter table historique_immobilisations add column if not exists motif_sortie text;
