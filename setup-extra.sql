-- PartsFlow — à exécuter APRÈS schema.sql (une seule fois de plus).
-- SQL Editor → New query → coller → Run.

-- Numérotation atomique des devis/factures/OR/commandes (DEV-2026-0001, etc.)
create or replace function next_numero(seq_name text) returns bigint
language sql as $$ select nextval(seq_name::regclass); $$;
grant execute on function next_numero(text) to authenticated;

-- Temps réel sur les comptes : indispensable pour que la révocation d'un
-- accès par un administrateur déconnecte la personne en quelques secondes,
-- même si elle est déjà en train d'utiliser l'application.
alter publication supabase_realtime add table profiles;
