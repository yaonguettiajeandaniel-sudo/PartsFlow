-- PartsFlow — schéma de base de données Supabase (Postgres)
-- À exécuter dans Supabase : SQL Editor → New query → coller tout → Run.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------- profils
-- Un profil par compte auth.users (créé manuellement dans Supabase pour
-- chaque employé). identifiant/role/tabs/active pilotent l'app ; le mot
-- de passe réel vit dans auth.users, géré par Supabase (haché, sécurisé).
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nom text not null,
  identifiant text unique not null,
  role text not null check (role in ('admin','agent')),
  tabs text[] not null default '{}',
  active boolean not null default true,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------- flotte
create table vehicules (
  id uuid primary key default gen_random_uuid(),
  immatriculation text unique not null,
  marque text, modele text, annee int, statut text default 'actif',
  km int, chauffeur_nom text, chauffeur_telephone text,
  created_at timestamptz not null default now()
);

create table fournisseurs (
  id uuid primary key default gen_random_uuid(),
  nom text not null, telephone text, delai_jours int
);

create table articles (
  id uuid primary key default gen_random_uuid(),
  reference text unique not null, designation text, famille text,
  prix_achat numeric default 0, prix_vente numeric default 0, tva numeric default 18,
  stock_qte numeric default 0, stock_seuil numeric default 0,
  fournisseur_id uuid references fournisseurs(id), emplacement text,
  created_at timestamptz not null default now()
);

create table techniciens (
  id uuid primary key default gen_random_uuid(),
  nom text not null, metier text, telephone text
);

-- Compteurs de numérotation : des séquences Postgres, incrémentées de
-- façon atomique (contrairement au bricolage à base de "lease" qu'il
-- fallait faire côté client avec la base de l'artifact Claude).
create sequence devis_seq;
create sequence facture_seq;
create sequence or_seq;
create sequence commande_seq;

create table devis (
  id uuid primary key default gen_random_uuid(),
  numero text unique not null, vehicule_id uuid references vehicules(id),
  statut text not null default 'brouillon', date timestamptz not null default now(),
  lignes jsonb not null default '[]',
  facture_id uuid, or_id uuid,
  created_at timestamptz not null default now(), created_by text
);

create table ordres (
  id uuid primary key default gen_random_uuid(),
  numero text unique not null, vehicule_id uuid references vehicules(id),
  statut text not null default 'ouvert',
  date_ouverture timestamptz not null default now(), date_cloture timestamptz,
  km int, technicien_ids uuid[] default '{}',
  pieces jsonb not null default '[]', interventions jsonb not null default '[]',
  facture_id uuid, devis_id uuid,
  created_at timestamptz not null default now(), created_by text
);

create table factures (
  id uuid primary key default gen_random_uuid(),
  numero text unique not null,
  devis_id uuid references devis(id), or_id uuid references ordres(id),
  vehicule_id uuid references vehicules(id), date timestamptz not null default now(),
  lignes jsonb not null default '[]',
  montant_total numeric not null default 0, montant_regle numeric not null default 0,
  statut_paiement text not null default 'impayee', reglements jsonb not null default '[]',
  created_at timestamptz not null default now(), created_by text
);

create table commandes (
  id uuid primary key default gen_random_uuid(),
  numero text unique not null, fournisseur_id uuid references fournisseurs(id),
  statut text not null default 'envoyee', date_commande timestamptz not null default now(),
  date_reception_prevue date, lignes jsonb not null default '[]',
  created_at timestamptz not null default now(), created_by text
);

create table mouvements (
  id uuid primary key default gen_random_uuid(),
  article_id uuid references articles(id), reference text, designation text,
  type text not null, quantite numeric not null,
  document_type text, document_numero text, utilisateur text,
  date timestamptz not null default now(), commentaire text
);

create table comptages (
  id uuid primary key default gen_random_uuid(),
  date timestamptz not null default now(), statut text not null default 'valide',
  lignes jsonb not null default '[]', valide_par text, date_validation timestamptz
);

create table audit (
  id uuid primary key default gen_random_uuid(),
  date timestamptz not null default now(), acteur text, role text,
  action text, cible text, detail text
);

create table config (
  id text primary key default 'general', devise text not null default 'FCFA'
);
insert into config (id, devise) values ('general', 'FCFA');

-- ---------------------------------------------------------- sécurité (RLS)
-- Toute personne connectée (compte créé par un admin) peut lire/écrire
-- les données métier partagées. Seul un admin peut créer/modifier/
-- désactiver un compte — c'est la seule table où l'accès est vraiment
-- verrouillé au niveau base de données plutôt que côté application.
alter table profiles enable row level security;
alter table vehicules enable row level security;
alter table fournisseurs enable row level security;
alter table articles enable row level security;
alter table techniciens enable row level security;
alter table devis enable row level security;
alter table ordres enable row level security;
alter table factures enable row level security;
alter table commandes enable row level security;
alter table mouvements enable row level security;
alter table comptages enable row level security;
alter table audit enable row level security;
alter table config enable row level security;

create function is_admin() returns boolean language sql security definer stable as $$
  select exists (select 1 from profiles where id = auth.uid() and role = 'admin');
$$;

create policy "read own or admin reads all profiles" on profiles for select
  using (auth.uid() = id or is_admin());
create policy "admin manages profiles" on profiles for all
  using (is_admin()) with check (is_admin());

create policy "staff read vehicules" on vehicules for select using (auth.role() = 'authenticated');
create policy "staff write vehicules" on vehicules for insert with check (auth.role() = 'authenticated');
create policy "staff update vehicules" on vehicules for update using (auth.role() = 'authenticated');

create policy "staff read fournisseurs" on fournisseurs for select using (auth.role() = 'authenticated');
create policy "staff write fournisseurs" on fournisseurs for insert with check (auth.role() = 'authenticated');
create policy "staff update fournisseurs" on fournisseurs for update using (auth.role() = 'authenticated');

create policy "staff read articles" on articles for select using (auth.role() = 'authenticated');
create policy "staff write articles" on articles for insert with check (auth.role() = 'authenticated');
create policy "staff update articles" on articles for update using (auth.role() = 'authenticated');

create policy "staff read techniciens" on techniciens for select using (auth.role() = 'authenticated');
create policy "staff write techniciens" on techniciens for insert with check (auth.role() = 'authenticated');

create policy "staff read devis" on devis for select using (auth.role() = 'authenticated');
create policy "staff write devis" on devis for insert with check (auth.role() = 'authenticated');
create policy "staff update devis" on devis for update using (auth.role() = 'authenticated');

create policy "staff read ordres" on ordres for select using (auth.role() = 'authenticated');
create policy "staff write ordres" on ordres for insert with check (auth.role() = 'authenticated');
create policy "staff update ordres" on ordres for update using (auth.role() = 'authenticated');

create policy "staff read factures" on factures for select using (auth.role() = 'authenticated');
create policy "staff write factures" on factures for insert with check (auth.role() = 'authenticated');
create policy "staff update factures" on factures for update using (auth.role() = 'authenticated');

create policy "staff read commandes" on commandes for select using (auth.role() = 'authenticated');
create policy "staff write commandes" on commandes for insert with check (auth.role() = 'authenticated');
create policy "staff update commandes" on commandes for update using (auth.role() = 'authenticated');

create policy "staff read mouvements" on mouvements for select using (auth.role() = 'authenticated');
create policy "staff write mouvements" on mouvements for insert with check (auth.role() = 'authenticated');

create policy "staff read comptages" on comptages for select using (auth.role() = 'authenticated');
create policy "staff write comptages" on comptages for insert with check (auth.role() = 'authenticated');

create policy "staff read audit" on audit for select using (auth.role() = 'authenticated');
create policy "staff write audit" on audit for insert with check (auth.role() = 'authenticated');

create policy "staff read config" on config for select using (auth.role() = 'authenticated');
create policy "admin write config" on config for update using (is_admin());
