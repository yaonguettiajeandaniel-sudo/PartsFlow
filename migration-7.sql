-- PartsFlow — migration 7 : sanction / licenciement d'un technicien sans perte d'historique
alter table techniciens add column if not exists statut text not null default 'actif';
alter table techniciens add column if not exists motif_sanction text;
alter table techniciens add column if not exists date_sanction timestamptz;
