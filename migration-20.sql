-- PartsFlow — migration 20 : corrige les virements déjà marqués "Validé"
-- dont le montant reçu est resté à 0 F — le bouton "Valider" changeait le
-- statut sans jamais demander ce montant (corrigé dans l'application), donc
-- tout virement validé avant ce correctif a pu garder un montant reçu à 0
-- malgré son statut. Reprend le montant envoyé par défaut : une estimation
-- raisonnable, à vérifier au cas par cas si un écart était connu.

update virements set montant_recu = montant_envoye
where statut = 'valide' and coalesce(montant_recu, 0) = 0 and coalesce(montant_envoye, 0) > 0;
