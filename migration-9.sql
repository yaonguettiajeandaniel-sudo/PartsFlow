-- PartsFlow — migration 9 : statut "sinistré" + dossier de prise en charge
-- (signalement → diagnostic) sur les véhicules immobilisés.

alter table vehicules add column if not exists etape_prise_en_charge text;
alter table vehicules add column if not exists reception_par text;
alter table vehicules add column if not exists reception_date timestamptz;
alter table vehicules add column if not exists diagnostic_technicien_id uuid references techniciens(id);
alter table vehicules add column if not exists diagnostic_technicien_nom text;
alter table vehicules add column if not exists diagnostic_assigne_date timestamptz;
alter table vehicules add column if not exists diagnostic_confirme text;
alter table vehicules add column if not exists diagnostic_confirme_date timestamptz;

alter table vehicules add column if not exists sinistre_assureur text;
alter table vehicules add column if not exists sinistre_garage text;
alter table vehicules add column if not exists sinistre_date timestamptz;
alter table vehicules add column if not exists sinistre_retour_estime date;
