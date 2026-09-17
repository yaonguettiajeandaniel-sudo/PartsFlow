-- PartsFlow — migration 18 : pièces à échange standard, contrôle anti-vol.
-- L'ancienne pièce doit être restituée (confirmée dans l'app) avant de
-- pouvoir clôturer l'OR sur lequel une pièce marquée "échange standard" a
-- été posée.

alter table articles add column if not exists echange_standard boolean not null default false;
