-- PartsFlow — migration 15 : nettoie le nom des véhicules souhaités déjà
-- enregistrés (texte brut hérité de l'ancien import CSV ou de la conversion
-- de la migration 14, ex. "Kaiyi E5 à 16 412 €") pour ne garder que le nom
-- du modèle, comme le fait déjà l'application pour les nouvelles demandes.

update demandes_vehicule d
set modele_id = m.id,
    modele_nom = m.nom
from modeles_vehicule m
where d.modele_id is null
  and d.modele_nom ilike '%' || m.nom || '%';
