-- PartsFlow — migration 17 : validation manuelle "prêt à attribuer" par un
-- administrateur pour un véhicule souhaité déjà financé à plus de 90 %, sans
-- attendre les derniers versements.

alter table demandes_vehicule add column if not exists valide_manuellement boolean not null default false;
alter table demandes_vehicule add column if not exists date_validation_manuelle timestamptz;
