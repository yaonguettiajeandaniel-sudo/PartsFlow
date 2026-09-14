-- PartsFlow — migration 3 : autorise la création de la ligne de config
-- (l'enregistrement passe techniquement par un "upsert", qui a besoin
-- d'une règle d'insertion en plus de la règle de modification).
create policy "admin insert config" on config for insert with check (is_admin());
