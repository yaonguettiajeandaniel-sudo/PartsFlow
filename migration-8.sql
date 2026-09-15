-- PartsFlow — migration 8 : technicien responsable d'un OR + statut véhicule
-- automatiquement synchronisé avec le cycle de vie de l'ordre de réparation.
alter table ordres add column if not exists technicien_responsable_id uuid references techniciens(id);
alter table ordres add column if not exists technicien_responsable_nom text;
