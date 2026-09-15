-- PartsFlow — migration 10 : acompte sur un devis (avant conversion en facture)
alter table devis add column if not exists acomptes jsonb not null default '[]';
alter table devis add column if not exists acompte_total numeric not null default 0;
