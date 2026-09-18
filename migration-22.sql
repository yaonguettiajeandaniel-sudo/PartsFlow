-- PartsFlow — migration 22 : contrôle hebdomadaire de l'état des véhicules
-- (propreté, usure, éclairage…) pour vérifier que le chauffeur en prend soin.

create table controles_vehicule (
  id uuid primary key default gen_random_uuid(),
  vehicule_id uuid not null references vehicules(id) on delete cascade,
  date timestamptz not null,
  agent text,
  criteres jsonb not null default '[]',
  statut_global text not null default 'bon',
  observations text,
  created_at timestamptz not null default now()
);

alter table controles_vehicule enable row level security;

create policy "staff read controles_vehicule" on controles_vehicule for select using (auth.role() = 'authenticated');
create policy "staff write controles_vehicule" on controles_vehicule for insert with check (auth.role() = 'authenticated');
create policy "admin delete controles_vehicule" on controles_vehicule for delete using (is_admin());
