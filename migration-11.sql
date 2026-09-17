-- PartsFlow — migration 11 : module Clients (suivi des virements JET_S et
-- attribution de véhicules). Second flux d'activité, distinct de l'atelier :
-- envoi des justificatifs → confirmation de réception des fonds → attribution
-- d'un véhicule (qui rejoint alors la flotte "vehicules").

create table clients (
  id uuid primary key default gen_random_uuid(),
  nom text not null, prenoms text, telephone text, email text, pays text,
  vehicule_souhaite text, offre_actuelle text, migration_souhaitee text,
  statut_attribution text not null default 'en_attente',
  vehicule_attribue_id uuid references vehicules(id),
  date_attribution timestamptz, notes text,
  created_at timestamptz not null default now()
);

create table virements (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  montant_envoye numeric, montant_recu numeric,
  statut text not null default 'en_attente',
  date_virement date, reference text, notes text,
  created_at timestamptz not null default now()
);

alter table clients enable row level security;
alter table virements enable row level security;

create policy "staff read clients" on clients for select using (auth.role() = 'authenticated');
create policy "staff write clients" on clients for insert with check (auth.role() = 'authenticated');
create policy "staff update clients" on clients for update using (auth.role() = 'authenticated');
create policy "admin delete clients" on clients for delete using (is_admin());

create policy "staff read virements" on virements for select using (auth.role() = 'authenticated');
create policy "staff write virements" on virements for insert with check (auth.role() = 'authenticated');
create policy "staff update virements" on virements for update using (auth.role() = 'authenticated');
create policy "admin delete virements" on virements for delete using (is_admin());
