-- PartsFlow — migration 12 : coût du véhicule souhaité par client, permettant
-- de comparer les fonds reçus au montant à atteindre avant attribution.

alter table clients add column if not exists cout_vehicule_souhaite numeric;
