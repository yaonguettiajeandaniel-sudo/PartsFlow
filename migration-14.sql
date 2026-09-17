-- PartsFlow — migration 14 : plusieurs véhicules souhaités par client
-- (modèles éventuellement différents), avec allocation automatique des
-- fonds reçus dans l'ordre où les véhicules ont été ajoutés.

create table demandes_vehicule (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id) on delete cascade,
  modele_id uuid references modeles_vehicule(id),
  modele_nom text not null,
  cout numeric not null default 0,
  statut text not null default 'en_attente',
  vehicule_attribue_id uuid references vehicules(id),
  date_attribution timestamptz,
  created_at timestamptz not null default now()
);

alter table demandes_vehicule enable row level security;

create policy "staff read demandes_vehicule" on demandes_vehicule for select using (auth.role() = 'authenticated');
create policy "staff write demandes_vehicule" on demandes_vehicule for insert with check (auth.role() = 'authenticated');
create policy "staff update demandes_vehicule" on demandes_vehicule for update using (auth.role() = 'authenticated');
create policy "admin delete demandes_vehicule" on demandes_vehicule for delete using (is_admin());

-- Conversion des données existantes : chaque client ayant déjà un véhicule
-- souhaité et/ou un coût devient une demande (statut et attribution repris
-- tels quels). Les colonnes d'origine sur "clients" restent en place (plus
-- utilisées par l'application après cette migration, mais rien n'est perdu).
insert into demandes_vehicule (client_id, modele_id, modele_nom, cout, statut, vehicule_attribue_id, date_attribution, created_at)
select id, vehicule_souhaite_id, coalesce(nullif(vehicule_souhaite, ''), 'Véhicule souhaité'), coalesce(cout_vehicule_souhaite, 0),
       coalesce(statut_attribution, 'en_attente'), vehicule_attribue_id, date_attribution, created_at
from clients
where (vehicule_souhaite is not null and vehicule_souhaite <> '')
   or coalesce(cout_vehicule_souhaite, 0) > 0
   or vehicule_attribue_id is not null;
