-- PartsFlow — migration 24 : pièces suggérées au diagnostic (oubliée lors
-- de l'ajout du module Diagnostic enrichi — la colonne n'avait jamais été
-- créée, d'où l'erreur "Could not find the 'diagnostic_pieces_suggerees'
-- column of 'vehicules'" au moment d'enregistrer un diagnostic ou de
-- sortir un véhicule de la base).

alter table vehicules add column if not exists diagnostic_pieces_suggerees jsonb;
