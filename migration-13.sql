-- PartsFlow — migration 13 : catalogue des modèles de véhicules (nom + coût),
-- pour préremplir automatiquement le coût du véhicule souhaité sur une fiche
-- client selon le modèle choisi, sans le ressaisir à chaque fois.

create table modeles_vehicule (
  id uuid primary key default gen_random_uuid(),
  nom text unique not null,
  cout numeric not null default 0,
  created_at timestamptz not null default now()
);

alter table modeles_vehicule enable row level security;

create policy "staff read modeles_vehicule" on modeles_vehicule for select using (auth.role() = 'authenticated');
create policy "admin write modeles_vehicule" on modeles_vehicule for insert with check (is_admin());
create policy "admin update modeles_vehicule" on modeles_vehicule for update using (is_admin());
create policy "admin delete modeles_vehicule" on modeles_vehicule for delete using (is_admin());

alter table clients add column if not exists vehicule_souhaite_id uuid references modeles_vehicule(id);

-- Les deux modèles déjà connus dans les données actuelles (Google Sheet JET_S).
insert into modeles_vehicule (nom, cout) values
  ('Kaiyi E5', 16412),
  ('Suzuki Dzire', 15771)
on conflict (nom) do nothing;
