-- PartsFlow — migration 21 : historique des passages en atelier (entrée et
-- sortie d'immobilisation), archivé et consultable sur la fiche du véhicule.

create table historique_immobilisations (
  id uuid primary key default gen_random_uuid(),
  vehicule_id uuid not null references vehicules(id) on delete cascade,
  date_entree timestamptz not null,
  date_sortie timestamptz,
  motif text,
  detail text,
  created_at timestamptz not null default now()
);

alter table historique_immobilisations enable row level security;

create policy "staff read historique_immobilisations" on historique_immobilisations for select using (auth.role() = 'authenticated');
create policy "staff write historique_immobilisations" on historique_immobilisations for insert with check (auth.role() = 'authenticated');
create policy "staff update historique_immobilisations" on historique_immobilisations for update using (auth.role() = 'authenticated');
create policy "admin delete historique_immobilisations" on historique_immobilisations for delete using (is_admin());
