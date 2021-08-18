
SET search_path TO GPA775, public;

-- (Requête 1.1) Allez chercher la date de mise en route d'une machine
SELECT nom,dateMiseRoute FROM machine
		WHERE nom LIKE('Machine 1');

-- (Requête 2.1)Allez chercher toutes les alarmes sur une machine
SELECT * FROM alarme 
		WHERE machine = (SELECT id FROM machine WHERE nom LIKE('Machine 1'));

-- Requête (3.1) Information sur les recettes les plus populaires
SELECT recette.nom AS recette, 
		ROUND(CAST(COUNT(CASE WHEN evaluation.appreciation THEN 1 END) AS NUMERIC)/CAST(COUNT(evaluation.appreciation) AS NUMERIC),2) AS ratio_appreciation
		FROM Recette
		INNER JOIN commandeRecette
			ON Recette.id = commandeRecette.recette
		INNER JOIN evaluation
			ON Recette.id = evaluation.recette
		GROUP BY recette.nom
		ORDER BY ratio_appreciation DESC;
		
		
-- (Requête 3.2) Avoir le sommaire des commandes d'approvisionnement
SELECT prix,datecommande,fournisseur.nom AS nomFournisseur,contact_courriel,
	concat(employes.prenom, ' ',employes.nom) AS employe,
	lot.quantiter
		FROM commandeapprovisionnement
			INNER JOIN fournisseur
				ON commandeapprovisionnement.fournisseur = fournisseur.id
			INNER JOIN employes
				ON commandeapprovisionnement.employe = employes.id
			INNER JOIN lot
				ON commandeapprovisionnement.id = lot.commande;
				
-- Requête (5.2----->4.1) Affichage de l’historique des données de chaque équipement
SELECT machine.nom AS machine,
	equipements.id AS numero_equipement,
	donneeenregistree.valeur AS donnée,
	donneeenregistree.date AS date
		FROM equipements
			INNER JOIN machine
				ON equipements.machine = machine.id
			INNER JOIN donneeenregistree
				ON equipements.id = donneeenregistree.equipement;

--Requête (4.2) Requête pour afficher le numéro de paiement de la dernière commande
SELECT client.prenom AS prenom,
	client.nom AS nom,
	commandeClient.datecommande AS datecommande,
	modePaiement.numero AS numero,
	machinecommande.commande
	FROM modePaiement
		INNER JOIN client
		ON modePaiement.id = client.id
		INNER JOIN commandeClient
		ON commandeClient.id = client.id
		INNER JOIN machinecommande
		ON machinecommande.commande = commandeClient.id
		INNER JOIN machine
		ON machinecommande.machine = machine.id
	WHERE commandeClient.datereception = (SELECT MAX(commandeClient.datereception)FROM commandeClient);

-- Requête (4.3) Affichage des informations sur un ingrédient
SELECT ingredients.id AS ingredients, 
	 marque.nomMarque AS marque,
	 liquide.pourcentageAlcool, 
	 liquide.typeliquide  
		FROM bouteille
		INNER JOIN ingredients
			ON bouteille.id = ingredients.bouteille
		INNER JOIN liquide
			ON bouteille.liquide = liquide.id
		INNER JOIN marque
			ON bouteille.marque = marque.id;

--Requête (5.1) Requête pour savoir quel sont les derniers équipement qui ont été changé
SELECT equipements.id AS numéro_d_equipement,
		equipements.dateInstallation AS date_d_installation	
	FROM machine
		INNER JOIN equipements
		ON equipements.machine = machine.id
		INNER JOIN maintenance
		ON maintenance.machine = machine.id
	WHERE maintenance.id = (SELECT MAX(maintenance.id)FROM maintenance);

--Requête (4.1----> maintenant 5.2) Requête pour information sur une bouteille
SELECT liquide.typeliquide AS Type_de_liquide,
	marque.nomMarque AS Marque,
	commandeapprovisionnement.prix / lot.quantiter AS prix
		FROM bouteille
			INNER JOIN machine
			ON bouteille.machine = machine.id
			INNER JOIN liquide
			ON bouteille.liquide = liquide.id
			INNER JOIN marque
			ON bouteille.marque = marque.id
			INNER JOIN lot
			ON bouteille.lot = lot.id
			INNER JOIN commandeapprovisionnement
			ON lot.commande = commandeapprovisionnement.id
		WHERE machine.nom = 'Machine 1';
		
-- Requête (5.3) Sélectionnez les bouteilles requises pour une commande
SELECT commandeClient.id AS numerocommande,
    recette.id AS numero_recette,
    recetteIngredients.quantiter,
    bouteille.marque,
    bouteille.liquide
    FROM commandeClient
        INNER JOIN commandeRecette
        ON commandeClient.id = commandeRecette.commande
        INNER JOIN recette
        ON commandeRecette.recette = recette.id
        INNER JOIN recetteIngredients
        ON  recette.id = recetteIngredients.recette
        INNER JOIN ingredients
        ON recetteIngredients.ingredients = ingredients.id
        INNER JOIN bouteille
        ON ingredients.bouteille = bouteille.id
    WHERE commandeClient.id = 3;

--Requête (6.1) Requête pour avoir l'information sur une commande
SELECT commandeClient.id AS numéro_de_commande,
	recette.nom AS recette,
	liquide.typeliquide,
	marque.nommarque AS marque,
	recetteIngredients.quantiter
	FROM client
		INNER JOIN commandeClient
		ON commandeClient.client = client.id
		INNER JOIN commandeRecette
		ON commandeRecette.commande = commandeClient.id
		INNER JOIN recette
		ON recette.id =commandeRecette.recette	
		INNER JOIN recetteIngredients
		ON recetteIngredients.recette = recette.id
		INNER JOIN ingredients
		ON ingredients.id = recetteIngredients.ingredients
		INNER JOIN bouteille
		ON bouteille.id = ingredients.bouteille
		INNER JOIN liquide
		ON liquide.id = bouteille.liquide
		INNER JOIN marque
		ON marque.id = bouteille.marque
	WHERE client.prenom = 'Aladin' AND client.nom = 'Vachon' AND commandeClient.datecommande = to_timestamp('29/04/21 14:05:00','DD/MM/YY HH24:MI:SS' )
	GROUP BY recette.id,recetteIngredients.quantiter,liquide.typeliquide,commandeClient.id,marque.nommarque
	ORDER BY commandeClient.id,recette.id;
	

-- (Requête 6.2) Requête d’information sur une commande d’approvisionnement pour une bouteille installée
SELECT bouteille.dateinsertion,
		machine.nom AS machine,
		marque.nommarque,
		liquide.typeliquide,
		concat(employes.prenom, ' ', employes.nom) AS employes,
		lot.quantiter,
		commandeapprovisionnement.prix, commandeapprovisionnement.datecommande,
		fournisseur.nom AS fournisseur
		FROM bouteille
			INNER JOIN machine
				ON bouteille.machine = machine.id
			INNER JOIN marque
				ON bouteille.marque = marque.id
			INNER JOIN liquide
				ON bouteille.liquide = liquide.id
			INNER JOIN employes
				ON machine.responsable = employes.id
			INNER JOIN lot
				ON bouteille.lot = lot.id
			INNER JOIN commandeapprovisionnement
				ON lot.commande = commandeapprovisionnement.id
			INNER JOIN fournisseur
				ON fournisseur.id = commandeapprovisionnement.fournisseur
		WHERE Marque.nommarque = 'Bacardi superior' AND
				liquide.typeliquide = 'Rhum blanc';


-- Requête de calcul de temps
SELECT commandeclient.datecommande,
		commandeclient.datereception-commandeclient.datecommande AS duree,
		SUM(recette.prix) AS cout_commande
		FROM commandeclient
		INNER JOIN client
			ON commandeclient.client = client.id
		INNER JOIN commanderecette
			ON commanderecette.commande = commandeclient.id
		INNER JOIN recette
			ON recette.id = commanderecette.recette
		WHERE datereception IS NOT NULL
		GROUP BY commandeclient.id;
		
SELECT alarme.id AS alarme,
		alarme.messages,
		alarme.dateclear-alarme.datedébut AS duree,
		machine.nom AS machine
		FROM alarme
		INNER JOIN machine
			ON machine.id = alarme.machine
		WHERE alarme.dateclear IS NOT NULL;

-- Requete 6 clauses SELECT | FROM | WHERE | GROUP BY | HAVING | ORDER BY
-- Nombre de commande par fournisseur
SELECT fournisseur,
		COUNT(id) AS nombre_commande
		FROM commandeapprovisionnement
		WHERE employe = (SELECT id FROM employes WHERE nomutilisateur = '8ou8_lol')
		GROUP BY fournisseur
		HAVING COUNT(id) > 0
		ORDER BY fournisseur;

-- Nombre d'alarme actives par machine
SELECT machine, 
		COUNT(id) AS nombre_alarme_active
		FROM alarme 
		WHERE dateclear IS NULL
		GROUP BY machine
		HAVING COUNT(id)>0
		ORDER BY COUNT(id);

-- Requete faisant 3 Joint
SELECT concat(employes.prenom, employes.nom) AS employé,
		horaire.lundi,horaire.mardi,horaire.mercredi,horaire.jeudi,horaire.vendredi,horaire.samedi,horaire.dimanche,
		machine.nom AS machine,
		maintenance.datedebut AS DateMaintenance,
		maintenance.description AS MaintenanceDescription
		FROM employes
		INNER JOIN horaire
			ON employes.id = horaire.employes
		INNER JOIN machine
			ON machine.responsable = employes.id
		INNER JOIN maintenance
			ON maintenance.employe = employes.id;

-- Requete faisant 5 Joint
SELECT bouteille.dateinsertion,
		machine.nom AS machine,
		marque.nommarque,
		liquide.typeliquide,
		lot.quantiter,
		commandeapprovisionnement.prix, commandeapprovisionnement.datecommande
		FROM bouteille
			INNER JOIN machine
				ON bouteille.machine = machine.id
			INNER JOIN marque
				ON bouteille.marque = marque.id
			INNER JOIN liquide
				ON bouteille.liquide = liquide.id
			INNER JOIN lot
				ON bouteille.lot = lot.id
			INNER JOIN commandeapprovisionnement
				ON lot.commande = commandeapprovisionnement.id;

-- Requete faisant 7 Joints
SELECT commandeclient.id AS commande,commandeclient.datereception,
		CONCAT(client.prenom, client.nom) AS client,
		recette.nom AS recette,
		recette.prix,
		machine.nom AS machine,
		ratio_recette_appreciee.ratio_appreciation AS appreciation_générale,
		CONCAT(employes.prenom, employes.nom) AS responsable_machine
		FROM commandeclient
		INNER JOIN client
			ON client.id = commandeclient.client
		INNER JOIN commanderecette
			ON commanderecette.commande = commandeclient.id
		INNER JOIN recette
			ON recette.id = commanderecette.recette
		INNER JOIN machinecommande
			ON machinecommande.commande = commandeclient.id
		INNER JOIN machine
			ON machine.id = machinecommande.machine
		INNER JOIN ratio_recette_appreciee
			ON ratio_recette_appreciee.recette = recette.nom
		INNER JOIN employes
			ON employes.id = machine.responsable;


SELECT commande_retard();
SELECT derniere_bout_insertion('Machine 1');
SELECT bouteilles_vide('Machine 2') AS Bouteilles;	





