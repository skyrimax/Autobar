
SET search_path TO GPA775, public;

-- Nettoyage des objets
DROP SEQUENCE IF EXISTS seq_actionneur_partnum;
DROP SEQUENCE IF EXISTS seq_capteur_partnum;

DROP INDEX IF EXISTS idx_machine_nom;
DROP INDEX IF EXISTS idx_recette_nom;
DROP INDEX IF EXISTS idx_client_nomutilisateur;
DROP INDEX IF EXISTS idx_employes_nomutilisateur;

DROP VIEW IF EXISTS nbr_commande_machine CASCADE;
DROP VIEW IF EXISTS ratio_recette_appreciee CASCADE;

-- Creation des Séquences
CREATE SEQUENCE seq_actionneur_partnum
INCREMENT BY 2 START WITH 100 NO CYCLE;
CREATE SEQUENCE seq_capteur_partnum
INCREMENT BY 2 START WITH 101 NO CYCLE;


-- Création des Indexes
CREATE UNIQUE INDEX idx_machine_nom
	ON machine(nom ASC NULLS LAST);
CREATE UNIQUE INDEX idx_recette_nom
	ON recette(nom ASC NULLS LAST);
CREATE UNIQUE INDEX idx_client_nomutilisateur
	ON client(nomutilisateur ASC NULLS LAST);
CREATE UNIQUE INDEX idx_employes_nomutilisateur
	ON employes(nomutilisateur ASC NULLS LAST);
	
	
--Créatiuon des vues
CREATE VIEW nbr_commande_machine AS
	SELECT machine.nom AS machine,
		COUNT(machinecommande.commande) AS QuantiterCommande
		FROM machine
		INNER JOIN machinecommande
			ON machine.id = machinecommande.machine
		GROUP BY machine.nom;

CREATE VIEW ratio_recette_appreciee AS
	SELECT recette.nom AS recette,
		ROUND(CAST(COUNT(CASE WHEN evaluation.appreciation THEN 1 END) AS NUMERIC)/CAST(COUNT(evaluation.appreciation) AS NUMERIC),2) AS ratio_appreciation
	FROM recette
	INNER JOIN evaluation
		ON recette.id = evaluation.recette
	GROUP BY recette.nom;

--Affichage des vues
--SELECT * FROM nbr_commande_machine;
--SELECT * FROM ratio_recette_appreciee;


DROP PROCEDURE IF EXISTS creation_recette;
--Création procédures SQL 
CREATE PROCEDURE creation_recette(
	nom_recette VARCHAR(64),
	nom_utilisateur VARCHAR(64),
	datecreation TIMESTAMP,
	prix MONEY)
	LANGUAGE SQL
  	AS $$
		INSERT INTO recette 
			VALUES(DEFAULT,nom_recette,(SELECT id FROM utilisateur WHERE nomUtilisateur = nom_utilisateur),datecreation,prix);
	  $$;
	  
-- Procédure PLpgSQL	  
DROP PROCEDURE IF EXISTS ajout_ingredient_recette;
CREATE PROCEDURE ajout_ingredient_recette(
	nom_recette	VARCHAR(64),
	nom_liquide_1 VARCHAR(64),
	nom_marque_1 VARCHAR(64),
	qt_ingredient_1 NUMERIC,
	nom_liquide_2 VARCHAR(64),
	nom_marque_2 VARCHAR(64),	
	qt_ingredient_2 NUMERIC)
	LANGUAGE PLPGSQL
	AS $$	
	BEGIN
		INSERT INTO recetteingredients VALUES((SELECT id FROM recette WHERE nom = nom_recette),
									 (SELECT id FROM ingredients WHERE
										 bouteille = (SELECT id FROM bouteille WHERE 
															  liquide = ((SELECT id FROM liquide WHERE typeliquide = nom_liquide_1)) AND
															  marque = ((SELECT id FROM marque WHERE nomMarque = nom_marque_1)))),qt_ingredient_1);	
		IF nom_liquide_2 IS NOT NULL AND nom_marque_2 IS NOT NULL THEN
			INSERT INTO recetteingredients VALUES((SELECT id FROM recette WHERE nom = nom_recette),
										 (SELECT id FROM ingredients WHERE
											 bouteille = (SELECT id FROM bouteille WHERE 
																  liquide = ((SELECT id FROM liquide WHERE typeliquide = nom_liquide_2)) AND
																  marque = ((SELECT id FROM marque WHERE nomMarque = nom_marque_2)))),qt_ingredient_2);																  
		END IF;
	END$$;	
	
-- ajout d'une recette dans une commande
DROP PROCEDURE IF EXISTS ajout_recette_commande;
CREATE PROCEDURE ajout_recette_commande(
	nom_machine VARCHAR(32),
	nom_recette	VARCHAR(64),
	date_commande TIMESTAMP,
	nom_utilisateur VARCHAR(64))
	LANGUAGE PLPGSQL
	AS $$	
	BEGIN 
		 INSERT INTO commandeRecette VALUES (DEFAULT,
											 (SELECT id FROM recette WHERE nom = nom_recette),
											(SELECT id FROM commandeClient WHERE datecommande = date_commande AND
											 client = (SELECT id FROM Client WHERE nomUtilisateur = nom_utilisateur)));
	END$$;
	
	 
-- Fonctions SQL	 
DROP FUNCTION IF EXISTS commande_retard;
CREATE FUNCTION commande_retard()
	RETURNS INTEGER
	LANGUAGE SQL
  	AS $$
		SELECT commandeclient.id
			FROM machinecommande
			INNER JOIN commandeclient
				ON commandeclient.id = machinecommande.commande
			ORDER BY commandeclient.datereception DESC,commandeclient.datecommande DESC
			LIMIT 1;	  
	$$;	 
	 
-- Fontionc SQL
CREATE OR REPLACE FUNCTION derniere_bout_insertion(
	nom_machine VARCHAR(32))
	RETURNS INTEGER 
	LANGUAGE PLPGSQL
	AS $$
	DECLARE
		bouteille_id INTEGER DEFAULT NULL;
	BEGIN
		CREATE TABLE tempo AS(
			SELECT bouteille.id AS bout
				FROM bouteille
				INNER JOIN marque
					ON bouteille.marque = marque.id
				INNER JOIN machine
					ON bouteille.machine = machine.id
				WHERE machine.nom LIKE nom_machine
				ORDER BY bouteille.dateInsertion DESC, machine.id DESC LIMIT 1);
		bouteille_id := bout FROM tempo;
		DROP TABLE tempo;
		RETURN bouteille_id;
	END$$;
	
	
-- Fontionc SQL
CREATE OR REPLACE FUNCTION bouteilles_vide(
	nom_machine VARCHAR(32))
	RETURNS TEXT 
	LANGUAGE PLPGSQL
	AS $$
	DECLARE
		bout_vides TEXT := ' ';
		bout_cur CURSOR(machine_nom VARCHAR(32)) FOR 
			SELECT * FROM bouteille WHERE machine = (SELECT id FROM machine WHERE nom = machine_nom) AND
				volumeactuel < (volume*0.15);
		bout_rec bouteille%ROWTYPE;
	BEGIN
		OPEN bout_cur(nom_machine);		
		LOOP
			FETCH bout_cur into bout_rec;
			EXIT WHEN NOT FOUND;
			bout_vides := bout_rec.id || ',' || bout_vides;
		END LOOP;
		CLOSE bout_cur;
		RETURN bout_vides;
	END$$; 

-- Création du déclencheur
CREATE OR REPLACE FUNCTION trigger_function()
	RETURNS TRIGGER 
	LANGUAGE PLPGSQL
	AS $$
	DECLARE
		emp_rec employes%ROWTYPE;
	BEGIN
		FOR emp_rec IN SELECT * FROM employes LOOP
			IF emp_rec.nom LIKE (SELECT contact_nom FROM fournisseur WHERE id= NEW.fournisseur) THEN
				RAISE NOTICE 'Conflit d''intérêts chez les %!!',emp_rec.nom;
			END IF;
		END LOOP;
		RETURN NEW;
	END$$;	 
	 
	 
 









