-- PartsFlow — migration 4 : véhicules — retire année/km, ajoute groupe/type/contrat
alter table vehicules drop column if exists annee;
alter table vehicules drop column if exists km;
alter table vehicules add column if not exists groupe text;
alter table vehicules add column if not exists type text;
alter table vehicules add column if not exists contrat text;
