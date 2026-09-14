-- PartsFlow — migration 5 : motif d'immobilisation + commandes urgentes
alter table vehicules add column if not exists motif_inactivite text;
alter table vehicules add column if not exists detail_inactivite text;
alter table commandes add column if not exists urgente boolean not null default false;
alter table commandes add column if not exists vehicule_id uuid references vehicules(id);
alter table commandes add column if not exists note text;
