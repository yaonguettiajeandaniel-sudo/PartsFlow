-- PartsFlow — migration 2 : impression, tableau de bord étendu, prise en charge
-- SQL Editor → New query → coller → Run.

alter table vehicules add column if not exists immobilise_depuis timestamptz;
alter table devis add column if not exists duree_estimee_jours numeric;
alter table config add column if not exists entreprise text;
alter table config add column if not exists capacite_atelier int not null default 5;
