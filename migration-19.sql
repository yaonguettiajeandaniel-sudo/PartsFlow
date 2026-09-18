-- PartsFlow — migration 19 : pointage de l'arrivée des techniciens le matin,
-- avec heure d'ouverture et tolérance de retard configurables.

create table pointages (
  id uuid primary key default gen_random_uuid(),
  technicien_id uuid not null references techniciens(id) on delete cascade,
  date date not null,
  heure_arrivee timestamptz not null,
  en_retard boolean not null default false,
  marque_par text,
  created_at timestamptz not null default now()
);

alter table pointages enable row level security;

create policy "staff read pointages" on pointages for select using (auth.role() = 'authenticated');
create policy "staff write pointages" on pointages for insert with check (auth.role() = 'authenticated');
create policy "admin delete pointages" on pointages for delete using (is_admin());

alter table config add column if not exists heure_ouverture text default '08:00';
alter table config add column if not exists tolerance_retard_min int default 15;
