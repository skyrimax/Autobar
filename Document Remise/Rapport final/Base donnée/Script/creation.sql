
-- Nettoyage des contraintes

ALTER TABLE IF EXISTS alarme
    DROP CONSTRAINT IF EXISTS fk_alarme_machine;
	
ALTER TABLE IF EXISTS machine
    DROP CONSTRAINT IF EXISTS fk_machine_responsable;

ALTER TABLE IF EXISTS maintenance
    DROP CONSTRAINT IF EXISTS fk_maintenance_employe,
	DROP CONSTRAINT IF EXISTS fk_maintenance_machine;
		
ALTER TABLE IF EXISTS horaire
		DROP CONSTRAINT IF EXISTS fk_horaire_employes;
		
ALTER TABLE IF EXISTS modePaiement
		DROP CONSTRAINT IF EXISTS fk_modePaiement_id;

ALTER TABLE IF EXISTS ingredients
		DROP CONSTRAINT IF EXISTS fk_ingredients_bouteille; 

ALTER TABLE IF EXISTS bouteille
		DROP CONSTRAINT IF EXISTS fk_bouteille_marque,
		DROP CONSTRAINT IF EXISTS fk_bouteille_liquide,
		DROP CONSTRAINT IF EXISTS fk_bouteille_lot,
		DROP CONSTRAINT IF EXISTS fk_bouteille_machine;

ALTER TABLE IF EXISTS recette
		DROP CONSTRAINT IF EXISTS fk_recette_client;

ALTER TABLE IF EXISTS recetteIngredients
		DROP CONSTRAINT IF EXISTS fk_recetteIngredient_recette,
		DROP CONSTRAINT IF EXISTS fk_recetteIngredient_ingredients;

ALTER TABLE IF EXISTS evaluation
		DROP CONSTRAINT IF EXISTS  fk_evaluation_recette,
		DROP CONSTRAINT IF EXISTS fk_evaluation_client;
		
ALTER TABLE IF EXISTS commandeApprovisionnement
		DROP CONSTRAINT IF EXISTS fk_commandeApprovisionnement_fournisseur,
		DROP CONSTRAINT IF EXISTS fk_commandeApprovisionnement_employe;

ALTER TABLE IF EXISTS lot
		DROP CONSTRAINT IF EXISTS fk_lot_commande; 
			
ALTER TABLE IF EXISTS commandeClient
		DROP CONSTRAINT IF EXISTS fk_commandeClient_client;

ALTER TABLE IF EXISTS commandeRecette
		DROP CONSTRAINT IF EXISTS fk_commandeRecette_recette,
		DROP CONSTRAINT IF EXISTS fk_commandeRecette_commande;

ALTER TABLE IF EXISTS machineCommande
		DROP CONSTRAINT IF EXISTS fk_machineCommande_commande,
		DROP CONSTRAINT IF EXISTS fk_machineCommande_machine;

ALTER TABLE IF EXISTS equipements
		DROP CONSTRAINT IF EXISTS fk_equipements_machine;
		
ALTER TABLE IF EXISTS donneeCapteur
		DROP CONSTRAINT IF EXISTS fk_donneeCapteur_equipement;

ALTER TABLE IF EXISTS donneeActionneur
		DROP CONSTRAINT IF EXISTS fk_donneeActionneur_equipement;
		
ALTER TABLE IF EXISTS donneeenregistree
		DROP CONSTRAINT IF EXISTS fk_equipements_equipement;
		
-- Nettoyage des tables
DROP TABLE IF EXISTS liquide;
DROP TABLE IF EXISTS marque;
DROP TABLE IF EXISTS alarme;
DROP TABLE IF EXISTS machine CASCADE;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS employes;
DROP TABLE IF EXISTS maintenance;
DROP TABLE IF EXISTS utilisateur;
DROP TABLE IF EXISTS horaire;
DROP TABLE IF EXISTS modePaiement;
DROP TABLE IF EXISTS bouteille;
DROP TABLE IF EXISTS ingredients;
DROP TABLE IF EXISTS recette CASCADE;
DROP TABLE IF EXISTS recetteIngredients;
DROP TABLE IF EXISTS evaluation;
DROP TABLE IF EXISTS fournisseur;
DROP TABLE IF EXISTS commandeApprovisionnement;
DROP TABLE IF EXISTS lot;
DROP TABLE IF EXISTS commandeClient;
DROP TABLE IF EXISTS commandeRecette;
DROP TABLE IF EXISTS machineCommande;
DROP TABLE IF EXISTS actionneur; 
DROP TABLE IF EXISTS capteur;
DROP TABLE IF EXISTS equipements;
DROP TABLE IF EXISTS donneeEnregistree CASCADE;
DROP TABLE IF EXISTS donneeCapteur;
DROP TABLE IF EXISTS donneeActionneur;

DROP SCHEMA IF EXISTS GPA775 CASCADE;

-- Création du schéma
CREATE SCHEMA GPA775;
SET search_path TO GPA775, public;


-- Création des tables

CREATE TABLE liquide (
	id					SERIAL,
	pourcentageAlcool	INTEGER			NOT NULL,
	typeliquide			VARCHAR(64)		NOT NULL,
	
	CONSTRAINT pk_liquide PRIMARY KEY (id),
	CONSTRAINT range_pourcentageAlcool CHECK (pourcentageAlcool BETWEEN 0 AND 100),
	CONSTRAINT uc_liquide_ppourcentageType UNIQUE(pourcentageAlcool,typeliquide)	
);

CREATE TABLE marque (
	id					SERIAL,
	nomMarque			VARCHAR(64)		NOT NULL,
	
	CONSTRAINT pk_marque PRIMARY KEY (id),
	CONSTRAINT uc_marque_nom UNIQUE(nomMarque)
);


CREATE TABLE machine (
	id					SERIAL			NOT NULL,			
	nom					VARCHAR(32)		NOT NULL,
	dateMiseRoute		TIMESTAMP		NOT NULL,
	responsable			INTEGER			NOT NULL,

	CONSTRAINT pk_machine PRIMARY KEY (id),
	CONSTRAINT uc_machine_nom UNIQUE(nom)
);


CREATE TABLE alarme (
	id					SERIAL,
	dateDébut			TIMESTAMP		NOT NULL,
	niveau				NUMERIC			NOT NULL,
	messages			TEXT,
	clear				BOOLEAN			NOT NULL,
	ack					BOOLEAN			NOT NULL,
	dateClear			TIMESTAMP,
	machine				INTEGER			NOT NULL,
	
	CONSTRAINT pk_alarme PRIMARY KEY (id),
	CONSTRAINT range_niveau CHECK (niveau BETWEEN 1 AND 4),
	CONSTRAINT cc_alarme_dates CHECK(dateClear IS NULL OR dateClear > dateDébut),
	CONSTRAINT cc_alarme_clear CHECK(ack = clear OR clear = FALSE)	
);
--Clé étrangère de machine dans la table alarme pointant vers un id de machine
ALTER TABLE alarme
    ADD CONSTRAINT fk_alarme_machine
        FOREIGN KEY (machine) REFERENCES machine(id);


CREATE TABLE utilisateur (
	id					SERIAL,
	nomUtilisateur		VARCHAR(64)		NOT NULL,
	nom					VARCHAR(64)		NOT NULL,
	prenom				VARCHAR(64)		NOT NULL,
	age					INTEGER			NOT NULL,
	motPasse			VARCHAR(64)		NOT NULL,
	courriel			VARCHAR(128)	NOT NULL,
	
	CONSTRAINT pk_utilisateur PRIMARY KEY (id),
	CONSTRAINT cc_ind_noms CHECK(LENGTH(nom) > 1 AND LENGTH(prenom) > 1),
	CONSTRAINT cc_ind_motPasse CHECK(LENGTH(motPasse) >= 8),
	CONSTRAINT cc_ind_age CHECK(age >= 18),
	CONSTRAINT uc_utilisateur_nomUtilisateur UNIQUE(nomUtilisateur),
	CONSTRAINT uc_utilisateur_courriel UNIQUE(courriel),
	CONSTRAINT cc_utilisateur_courriel CHECK(courriel ~* '^[A-Za-z0-9_.-]+@[A-Za-z0-9_.-]+[.][A-Za-z]+$')	-- https://regex101.com/
);	

--La table client hérite de la table utilisateur
CREATE TABLE client(
	dateCreation		TIMESTAMP		NOT NULL
	
)INHERITS(utilisateur);

--La table employés hérite de la table utilisateur
CREATE TABLE employes(
	numeroTelephone		BIGINT			NOT NULL,
	salaire				MONEY			NOT NULL
	
	CONSTRAINT cc_employes_tel CHECK(numeroTelephone BETWEEN 0000000000 AND 9999999999)
)INHERITS(utilisateur);

--Clé étrangère du responsable dans la table machine pointant vers un id de employés, appartenant à utilisateur
ALTER TABLE machine
    ADD CONSTRAINT fk_machine_responsable
        FOREIGN KEY (responsable) REFERENCES utilisateur(id);

CREATE TABLE maintenance(
	id				SERIAL			NOT NULL,
	description		TEXT			NOT NULL,
	dateDebut		TIMESTAMP		NOT NULL,
	DateFin			TIMESTAMP,
	employe			INTEGER			NOT NULL,
	machine			INTEGER			NOT NULL,
	
	CONSTRAINT pk_maintenance PRIMARY KEY (id),
	CONSTRAINT cc_maintenance_date CHECK(dateFin IS NULL OR dateFin >= dateDebut)
);
--Clé étrangère de l'employe et de mahcine pointant vers un id de employés et machine respectivement
ALTER TABLE maintenance
    ADD CONSTRAINT fk_maintenance_employe
        FOREIGN KEY (employe) REFERENCES utilisateur(id),
	ADD CONSTRAINT fk_maintenance_machine
        FOREIGN KEY (machine) REFERENCES machine(id);

CREATE TABLE horaire(
	employes		INTEGER			NOT NULL,
	lundi			BOOLEAN,
	mardi			BOOLEAN,
	mercredi		BOOLEAN,
	jeudi			BOOLEAN,
	vendredi		BOOLEAN,
	samedi			BOOLEAN,
	dimanche		BOOLEAN,	

	CONSTRAINT pk_horaire PRIMARY KEY (employes)	
);
--Clé étrangère de l'employee de la table horaire pointant vers un id de employés, appartenant à utilisateur
ALTER TABLE horaire
		ADD CONSTRAINT fk_horaire_employes 
			FOREIGN KEY (employes) REFERENCES utilisateur(id);

CREATE TABLE modePaiement(
	id				INTEGER			NOT NULL,
	numero			VARCHAR(16)		NOT NULL,
	codeSecuriter	VARCHAR(8)		NOT NULL,
	expiration		VARCHAR(8)		NOT NULL,
	adresse_no		VARCHAR(32)		NOT NULL,
	adresse_rue		VARCHAR(64)		NOT NULL,
	adresse_ville	VARCHAR(32)		NOT NULL,
	adresse_pays	VARCHAR(32)		NOT NULL,
	adresse_postal	VARCHAR(32)		NOT NULL,
	
	CONSTRAINT cc_modePaiement_numero CHECK(LENGTH(numero) = 16),
	CONSTRAINT cc_modePaiement_codeSecuriter CHECK(LENGTH(codeSecuriter) = 3),
	CONSTRAINT cc_modePaiement_expiration CHECK(LENGTH(expiration) = 4),
	CONSTRAINT cc_modePaiement_postal CHECK(LENGTH(adresse_postal) = 6)
);
--Clé étrangère du id de la table modePaiement pointant vers un id de client, appartenant à utilisateur
ALTER TABLE modePaiement
		ADD CONSTRAINT fk_modePaiement_id 
			FOREIGN KEY (id) REFERENCES utilisateur(id);

CREATE TABLE fournisseur(
	id 					SERIAL			NOT NULL,
	nom					VARCHAR(64)		NOT NULL,
	adresse_no			VARCHAR(32)		NOT NULL,
	adresse_rue			VARCHAR(64)		NOT NULL,
	adresse_ville		VARCHAR(32)		NOT NULL,
	adresse_pays		VARCHAR(32)		NOT NULL,
	adresse_postal		VARCHAR(32)		NOT NULL,	
	contact_nom			VARCHAR(64)		NOT NULL,
	contact_prenom		VARCHAR(64)		NOT NULL,
	contact_courriel	VARCHAR(128)    NOT NULL,
	contact_telephonne	BIGINT			NOT NULL,
	
	CONSTRAINT pk_fournisseur PRIMARY KEY (id),
	CONSTRAINT cc_fournisseur_tel CHECK(contact_telephonne BETWEEN 0000000000 AND 9999999999),
	CONSTRAINT uc_fournisseur_courriel UNIQUE(contact_courriel),
	CONSTRAINT uc_fournisseur_postal UNIQUE(adresse_postal)
);


CREATE TABLE commandeApprovisionnement(
	id				SERIAL			NOT NULL,
	prix			MONEY			NOT NULL,
	dateCommande	TIMESTAMP		NOT NULL,
	dateReception	TIMESTAMP,
	fournisseur		INTEGER			NOT NULL,
	employe			INTEGER			NOT NULL,
	
	CONSTRAINT pk_commandeApprovisionnement PRIMARY KEY (id),
	CONSTRAINT cc_commandeApprovisionnement_date CHECK(dateReception IS NULL OR dateReception > dateCommande),
	CONSTRAINT uc_commandeApprovisionnement_dateANDcontact UNIQUE(dateCommande,fournisseur),
	CONSTRAINT cc_commandeApprovisionnement_prix CHECK(prix::NUMERIC > 0.00)
);			
--Clé étrangère de fournisseur, lot et employe vers leur id dans les tables fournisseur, lot et utilisateur
ALTER TABLE commandeApprovisionnement
		ADD CONSTRAINT fk_commandeApprovisionnement_fournisseur
			FOREIGN KEY (fournisseur) REFERENCES fournisseur(id),
		ADD CONSTRAINT fk_commandeApprovisionnement_employe
			FOREIGN KEY (employe) REFERENCES utilisateur(id);


CREATE TABLE lot(
	id				SERIAL			NOT NULL,
	commande		INTEGER			NOT NULL,
	quantiter		INTEGER			NOT NULL,
	
	CONSTRAINT pk_lot PRIMARY KEY (id),
	CONSTRAINT cc_lot_quantiter CHECK(quantiter>0)
);
ALTER TABLE lot
		ADD CONSTRAINT fk_lot_commande 
			FOREIGN KEY (commande) REFERENCES commandeApprovisionnement(id);


CREATE TABLE bouteille(
	id				SERIAL			NOT NULL,
	dateInsertion	TIMESTAMP		NOT NULL,
	volume			NUMERIC			NOT NULL,
	volumeActuel	NUMERIC,
	marque			INTEGER			NOT NULL,
	liquide			INTEGER			NOT NULL,
	lot				INTEGER			NOT NULL,
	machine			INTEGER			NOT NULL,
	
	CONSTRAINT pk_bouteille PRIMARY KEY (id),
	CONSTRAINT cc_bouteille_volume CHECK(volumeActuel IS NULL OR volume >= volumeActuel),
	CONSTRAINT uc_bouteille_identification UNIQUE(marque,liquide)
);
ALTER TABLE bouteille
		ADD CONSTRAINT fk_bouteille_marque
			FOREIGN KEY (marque) REFERENCES marque(id),
		ADD CONSTRAINT fk_bouteille_liquide
			FOREIGN KEY (liquide) REFERENCES liquide(id),
		ADD CONSTRAINT fk_bouteille_lot
			FOREIGN KEY (lot) REFERENCES lot(id),
		ADD CONSTRAINT fk_bouteille_machine
			FOREIGN KEY (machine) REFERENCES machine(id);


CREATE TABLE ingredients(
	id				SERIAL			NOT NULL,
	bouteille		INTEGER			NOT NULL,
	
	CONSTRAINT pk_ingredients PRIMARY KEY (id)
);
--Clé étrangère du id de la table indredients pointant vers un id de client, appartenant à utilisateur
ALTER TABLE ingredients
		ADD CONSTRAINT fk_ingredients_bouteille 
			FOREIGN KEY (bouteille) REFERENCES bouteille(id);


CREATE TABLE recette(
	id				SERIAL			NOT NULL,
	nom				VARCHAR(64)		NOT NULL,
	client			INTEGER,
	dateCreation	TIMESTAMP,
	prix			MONEY			NOT NULL,
	
	CONSTRAINT pk_recette PRIMARY KEY (id),
	CONSTRAINT uc_recette_nom UNIQUE(nom),
	CONSTRAINT cc_recette_prix CHECK(prix::NUMERIC > 0)
);
--Clé étrangère du client de la table recette pointant vers un id de client, appartenant à utilisateur
ALTER TABLE recette
		ADD CONSTRAINT fk_recette_client
			FOREIGN KEY (client) REFERENCES utilisateur(id) DEFERRABLE;
			

-- Plusieurs ingrédients par recette
CREATE TABLE recetteIngredients(
	recette			INTEGER			NOT NULL,
	ingredients		INTEGER			NOT NULL,
	quantiter		NUMERIC			NOT NULL,
	
	CONSTRAINT pk_recetteIngredients PRIMARY KEY (recette,ingredients),
	CONSTRAINT cc_recetteIngredients_quantiter CHECK(quantiter > 0)
);
--Clé étrangère de recette et ingredients des tables recette et indrédient pointant vers leur id 
ALTER TABLE recetteIngredients
		ADD CONSTRAINT fk_recetteIngredient_recette
			FOREIGN KEY (recette) REFERENCES recette(id),
		ADD CONSTRAINT fk_recetteIngredient_ingredients
			FOREIGN KEY (ingredients) REFERENCES ingredients(id);


CREATE TABLE commandeClient(
	id				SERIAL			NOT NULL,
	datecommande	TIMESTAMP		NOT NULL,
	datereception	TIMESTAMP,
	client			INTEGER			NOT NULL,
	
	CONSTRAINT pk_commandeClient PRIMARY KEY (id),
	CONSTRAINT uc_commandeclient_dateANDclient UNIQUE(datecommande,client)
);
--Clé étrangère de client vers son id dans la table utilisateur
ALTER TABLE commandeClient
		ADD CONSTRAINT fk_commandeClient_client
			FOREIGN KEY (client) REFERENCES utilisateur(id);

-- Plusieurs recettes par commande
CREATE TABLE commandeRecette(
	id			SERIAL			NOT NULL,
	recette		INTEGER			NOT NULL,
	commande	INTEGER			NOT NULL,

	CONSTRAINT pk_commandeRecette PRIMARY KEY (id)
);
--Clé étrangère de recette et commande vers leur id dans les tables recette et commande
ALTER TABLE commandeRecette
		ADD CONSTRAINT fk_commandeRecette_recette
			FOREIGN KEY (recette) REFERENCES recette(id),
		ADD CONSTRAINT fk_commandeRecette_commande
			FOREIGN KEY (commande) REFERENCES commandeClient(id);


CREATE TABLE evaluation(
	recette			INTEGER			NOT NULL,
	client			INTEGER			NOT NULL,
	appreciation	BOOLEAN			NOT NULL,
	
	CONSTRAINT pk_evaluation PRIMARY KEY (recette,client)	
);
--Clé étrangère de recette et client des tables recette et utilisateur pointant vers leur id 
ALTER TABLE evaluation
		ADD CONSTRAINT fk_evaluation_recette
			FOREIGN KEY (recette) REFERENCES recette(id),
		ADD CONSTRAINT fk_evaluation_client
			FOREIGN KEY (client) REFERENCES utilisateur(id);
			
			
CREATE TABLE machineCommande(
	commande	INTEGER			NOT NULL,
	machine		INTEGER			NOT NULL,
	
	CONSTRAINT pk_machineCommande PRIMARY KEY (commande,machine)		
);
--Clé étrangère de recette et commande vers leur id dans les tables recette et commande
ALTER TABLE machineCommande
		ADD CONSTRAINT fk_machineCommande_commande
			FOREIGN KEY (commande) REFERENCES commandeclient(id),
		ADD CONSTRAINT fk_machineCommande_machine
			FOREIGN KEY (machine) REFERENCES machine(id);


CREATE TABLE equipements(
	id					SERIAL		NOT NULL,
	dateInstallation	TIMESTAMP	NOT NULL,
	dateRetrait			TIMESTAMP,
	etatActuel			NUMERIC		NOT NULL,
	machine				INTEGER		NOT NULL,
	
	CONSTRAINT pk_equipements PRIMARY KEY (id)			
);
--Clé étrangère de machine vers son id dans la table machine
ALTER TABLE equipements
		ADD CONSTRAINT fk_equipements_machine
			FOREIGN KEY (machine) REFERENCES machine(id);


CREATE TABLE actionneur(
	heureChangement		TIMESTAMP	NOT NULL,
	partnumber			INTEGER		NOT NULL,
	
	CONSTRAINT uc_actionneur_partnum UNIQUE(partnumber)
)INHERITS(equipements);


CREATE TABLE capteur(
	tauxEchantillonage	INTEGER		NOT NULL,
	heureDonnee			TIMESTAMP	NOT NULL,
	partnumber			INTEGER		NOT NULL,
	
	CONSTRAINT uc_capteur_partnum UNIQUE(partnumber)
)INHERITS(equipements);


CREATE TABLE donneeEnregistree(
	id		SERIAL			NOT NULL,
	date	TIMESTAMP		NOT NULL,
	valeur	NUMERIC			NOT NULL,
	equipement	INTEGER		NOT NULL,

	CONSTRAINT pk_donneeEnregistree PRIMARY KEY (id)				
);
ALTER TABLE donneeEnregistree
	ADD CONSTRAINT fk_equipements_equipement
			FOREIGN KEY (equipement) REFERENCES equipements(id);

CREATE TABLE donneeCapteur(
	equipement	INTEGER		NOT NULL,
	donnee		INTEGER		NOT NULL,

	CONSTRAINT pk_donneeCapteur PRIMARY KEY (equipement, donnee)					
);
ALTER TABLE donneeCapteur
		ADD CONSTRAINT fk_donneeCapteur_equipement
			FOREIGN KEY (equipement) REFERENCES capteur(partnumber);


CREATE TABLE donneeActionneur(
	equipement	INTEGER		NOT NULL,
	donnee		INTEGER		NOT NULL,

	CONSTRAINT pk_donneeActionneur PRIMARY KEY (equipement, donnee)					
);
ALTER TABLE donneeActionneur
		ADD CONSTRAINT fk_donneeActionneur_equipement
			FOREIGN KEY (equipement) REFERENCES actionneur(partnumber);

