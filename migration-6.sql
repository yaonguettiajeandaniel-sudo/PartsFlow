-- PartsFlow — migration 6 : suppression admin (devis/factures) + réinitialisation complète

-- Nécessaire pour les boutons "Supprimer définitivement" déjà présents sur les
-- devis et les factures : sans ces règles, la base refusait la suppression
-- (row-level security), même pour un administrateur.
create policy "admin delete devis" on devis for delete using (is_admin());
create policy "admin delete factures" on factures for delete using (is_admin());

-- Réinitialisation complète (bouton "Zone dangereuse" des Paramètres) : vide en
-- une seule opération les données d'exploitation (véhicules, stock, fournisseurs,
-- achats, devis, ordres de réparation, factures, mouvements de stock, comptages,
-- journal d'activité) et remet les numéros de documents à 1. Ne touche ni aux
-- comptes (profiles), ni aux techniciens, ni à la configuration générale.
-- "security definer" + vérification is_admin() explicite : la fonction s'exécute
-- avec les droits du propriétaire (donc peut truncate malgré les RLS), mais
-- refuse de le faire pour quiconque n'est pas administrateur.
create or replace function reset_all_data() returns void
language plpgsql security definer as $$
begin
  if not is_admin() then
    raise exception 'Réservé aux administrateurs';
  end if;
  truncate table
    mouvements, comptages, audit, factures, ordres, devis,
    commandes, articles, fournisseurs, vehicules;
  alter sequence devis_seq restart with 1;
  alter sequence facture_seq restart with 1;
  alter sequence or_seq restart with 1;
  alter sequence commande_seq restart with 1;
end;
$$;
grant execute on function reset_all_data() to authenticated;
