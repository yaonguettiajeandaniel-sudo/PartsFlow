-- PartsFlow — migration 16 : véhicules partagés entre plusieurs clients
-- (parts 1/2, 1/3…). Le coût de chaque part se calcule dans l'application à
-- partir du prix catalogue divisé par ce dénominateur ; un même véhicule de
-- la flotte peut désormais être attribué à plusieurs demandes.

alter table demandes_vehicule add column if not exists part_denominateur int not null default 1;
