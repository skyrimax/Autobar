
-- Insertion date to_date('04|11|20','DD|MM|YY') OU current_time

SET search_path TO GPA775, public;

-- Insertion
-- DESACTIVATE TRIGGER
ALTER TABLE machine DISABLE TRIGGER ALL;
ALTER TABLE recette DISABLE TRIGGER ALL;
ALTER TABLE maintenance DISABLE TRIGGER ALL;
ALTER TABLE horaire DISABLE TRIGGER ALL;
ALTER TABLE commandeApprovisionnement DISABLE TRIGGER ALL;
ALTER TABLE modepaiement DISABLE TRIGGER ALL;
ALTER TABLE evaluation DISABLE TRIGGER ALL;
ALTER TABLE commandeclient DISABLE TRIGGER ALL;
ALTER TABLE donneecapteur DISABLE TRIGGER ALL;
ALTER TABLE donneeactionneur DISABLE TRIGGER ALL;
ALTER TABLE donneeenregistree DISABLE TRIGGER ALL;


--Création requetes préparées (recette)
PREPARE ins_insertion_recette AS
	INSERT INTO recette VALUES(DEFAULT,$1,$2,$3,$4);
-- Insert recette
EXECUTE ins_insertion_recette('Rhum sec',NULL,NULL,5.00);
EXECUTE ins_insertion_recette('Rhum and Coke',NULL,NULL,4.00);
EXECUTE ins_insertion_recette('Vodka limonade',NULL,NULL,4.00);
EXECUTE ins_insertion_recette('Tequila sec',NULL,NULL,5.00);
EXECUTE ins_insertion_recette('Vodka sec',NULL,NULL,5.00);
DEALLOCATE ins_insertion_recette;


-- Insert client
INSERT INTO client VALUES(DEFAULT,'Beowulf_XxX','Dugrand','Axel',21,'papier1234','axeldugrand@gmail.com',to_date('30|05|21','DD|MM|YY'));
INSERT INTO client VALUES(DEFAULT,'Dartagan_BMX','Dugrand','Isuldur',18,'LuneSoleil','isuldugrand@gmail.com',to_date('30|05|21','DD|MM|YY'));
INSERT INTO client VALUES(DEFAULT,'Fishing_Line','Vachon','Aladin',25,'roche123','aladoune@gmail.com',to_date('30|05|21','DD|MM|YY'));

-- Insert employes
INSERT INTO employes VALUES(DEFAULT,'GabyChou23','Tremblay','Gabrielle',24,'Hello234','GabyChou23@gmail.com',9453554545,15.36);
INSERT INTO employes VALUES(DEFAULT,'8ou8_lol','Lacharité','Sébastien',18,'JwElei82jf','SebastLacharite@outlook.ca',3342654578,14.53);
INSERT INTO employes VALUES(DEFAULT,'BibiVUCT','Lemelon','Bob',28,'rklSjv!!fg$','Lemelonlon@hotmail.com',6502397985,15.12);


-- Insert Mode de paiement
INSERT INTO modepaiement VALUES((SELECT id FROM client WHERE nomUtilisateur = 'Beowulf_XxX'),
							   '4540543139240023','434','0424','3137','Rue des topazes','Saint-Eustache','Canada','J1G4S8');
INSERT INTO modepaiement VALUES((SELECT id FROM client WHERE nomUtilisateur = 'Dartagan_BMX'),
							   '5598483432140212','257','0825','1200','Rue Peel','Montréal','Canada','H3B2T6');
INSERT INTO modepaiement VALUES((SELECT id FROM client WHERE nomUtilisateur = 'Fishing_Line'),
							   '4724041452758347','984','1123','285','Rue Dupont Gravé','Tadoussac','Canada','G0T2A0');							   

-- Insert machine	
PREPARE ins_machine AS
	INSERT INTO machine VALUES(DEFAULT,$1,$2,(SELECT id FROM utilisateur WHERE nomUtilisateur = $3));
EXECUTE ins_machine('Machine 1',to_date('01|01|21','DD|MM|YY'), 'GabyChou23');
EXECUTE ins_machine('Machine 2',to_date('01|01|21','DD|MM|YY'), '8ou8_lol');
EXECUTE ins_machine('Machine 3',to_date('01|01|21','DD|MM|YY'), 'BibiVUCT');
DEALLOCATE ins_machine;


--Insert liquide
INSERT INTO liquide VALUES(DEFAULT,40,'Vodka');
INSERT INTO liquide VALUES(DEFAULT,40,'Tequila');
INSERT INTO liquide VALUES(DEFAULT,40,'Rhum blanc');
INSERT INTO liquide VALUES(DEFAULT,40,'Dry gin');
INSERT INTO liquide VALUES(DEFAULT,0,'Liqueur');
INSERT INTO liquide VALUES(DEFAULT,0,'Limonade');

-- Insert fournisseur
INSERT INTO fournisseur VALUES(DEFAULT,'SAQ','501','Place dArmes','Montréal','Canada','H2Y 2W7',
							   'Desrosiers','Sylvie','sylvie.d@outlook.ca',5146239312);
INSERT INTO fournisseur VALUES(DEFAULT,'SAQ','1150','Rue Ontario','Montréal','Canada','H5M 5L0',
							   'Labrosse','Sylvain','sylvain.l@outlook.ca',5146230469);						
INSERT INTO fournisseur VALUES(DEFAULT,'SAQ','2204','Rue Sainte-Catherine','Montréal','Canada','H3H 1M7',
							   'Dubois','Hubert','hubert.dubois@gmail.com',5144358241);
							   
--Commande d'approvisionnement
CREATE TRIGGER recette_ins
	BEFORE INSERT OR UPDATE ON commandeapprovisionnement
	FOR EACH ROW
	EXECUTE PROCEDURE trigger_function();	
INSERT INTO commandeApprovisionnement VALUES(DEFAULT, 365.13,to_date('13|05|21','DD|MM|YY'),to_date('23|05|21','DD|MM|YY'),
											(SELECT id FROM fournisseur WHERE contact_courriel = 'sylvie.d@outlook.ca'),
											 (SELECT id FROM utilisateur WHERE nomUtilisateur = '8ou8_lol'));
INSERT INTO commandeApprovisionnement VALUES(DEFAULT, 25.36,to_date('20|04|21','DD|MM|YY'),to_date('23|05|21','DD|MM|YY'),
											(SELECT id FROM fournisseur WHERE contact_courriel = 'sylvain.l@outlook.ca'),
											 (SELECT id FROM utilisateur WHERE nomUtilisateur = 'BibiVUCT'));
INSERT INTO commandeApprovisionnement VALUES(DEFAULT, 509.45,to_date('21|04|21','DD|MM|YY'),to_date('23|05|21','DD|MM|YY'),
											(SELECT id FROM fournisseur WHERE contact_courriel = 'hubert.dubois@gmail.com'),
											 (SELECT id FROM utilisateur WHERE nomUtilisateur = '8ou8_lol'));
INSERT INTO commandeApprovisionnement VALUES(DEFAULT, 509.45,to_date('23|04|21','DD|MM|YY'),to_date('29|05|21','DD|MM|YY'),
											(SELECT id FROM fournisseur WHERE contact_courriel = 'hubert.dubois@gmail.com'),
											 (SELECT id FROM utilisateur WHERE nomUtilisateur = '8ou8_lol'));
											 
-- Insert Lot
INSERT INTO lot VALUES(DEFAULT,(SELECT id FROM commandeApprovisionnement WHERE datecommande = to_date('13|05|21','DD|MM|YY') AND 
						fournisseur = (SELECT id FROM fournisseur WHERE contact_courriel = 'sylvie.d@outlook.ca')),10);
INSERT INTO lot VALUES(DEFAULT,(SELECT id FROM commandeApprovisionnement WHERE datecommande = to_date('21|04|21','DD|MM|YY') AND 
						fournisseur = (SELECT id FROM fournisseur WHERE contact_courriel = 'hubert.dubois@gmail.com')),20);
INSERT INTO lot VALUES(DEFAULT,(SELECT id FROM commandeApprovisionnement WHERE datecommande = to_date('20|04|21','DD|MM|YY') AND 
						fournisseur = (SELECT id FROM fournisseur WHERE contact_courriel = 'sylvain.l@outlook.ca')),1);
INSERT INTO lot VALUES(DEFAULT,(SELECT id FROM commandeApprovisionnement WHERE datecommande = to_date('23|04|21','DD|MM|YY') AND 
						fournisseur = (SELECT id FROM fournisseur WHERE contact_courriel = 'hubert.dubois@gmail.com')),13);

-- Insert Marque
INSERT INTO marque VALUES(DEFAULT,'Bacardi superior');
INSERT INTO marque VALUES(DEFAULT,'Gordon''s');
INSERT INTO marque VALUES(DEFAULT,'Coke');
INSERT INTO marque VALUES(DEFAULT,'Sealtest');
INSERT INTO marque VALUES(DEFAULT,'1800 Silver');
INSERT INTO marque VALUES(DEFAULT,'Absolut');

-- Insert bouteille
INSERT INTO bouteille VALUES(DEFAULT,to_date('23|04|21','DD|MM|YY'),1140,860,
							(SELECT id FROM marque WHERE nomMarque = 'Bacardi superior'),
							(SELECT id FROM liquide WHERE typeliquide = 'Rhum blanc'),
							(SELECT id FROM lot WHERE commande = (SELECT id FROM commandeApprovisionnement WHERE datecommande = to_date('13|05|21','DD|MM|YY') AND 
																	fournisseur = (SELECT id FROM fournisseur WHERE contact_courriel = 'sylvie.d@outlook.ca'))),
							(SELECT id FROM machine WHERE nom = 'Machine 1'));
INSERT INTO bouteille VALUES(DEFAULT,to_date('23|04|21','DD|MM|YY'),750,600,
							(SELECT id FROM marque WHERE nomMarque = 'Gordon''s'),
							(SELECT id FROM liquide WHERE typeliquide = 'Dry gin'),
							(SELECT id FROM lot WHERE commande = (SELECT id FROM commandeApprovisionnement WHERE datecommande = to_date('20|04|21','DD|MM|YY') AND 
																	fournisseur = (SELECT id FROM fournisseur WHERE contact_courriel = 'sylvain.l@outlook.ca'))),
							(SELECT id FROM machine WHERE nom = 'Machine 1'));
INSERT INTO bouteille VALUES(DEFAULT,to_date('23|04|21','DD|MM|YY'),750,400,
							(SELECT id FROM marque WHERE nomMarque = 'Absolut'),
							(SELECT id FROM liquide WHERE typeliquide = 'Vodka'),
							(SELECT id FROM lot WHERE commande = (SELECT id FROM commandeApprovisionnement WHERE datecommande = to_date('21|04|21','DD|MM|YY') AND 
																	fournisseur = (SELECT id FROM fournisseur WHERE contact_courriel = 'hubert.dubois@gmail.com'))),
							(SELECT id FROM machine WHERE nom = 'Machine 2'));
INSERT INTO bouteille VALUES(DEFAULT,to_date('23|04|21','DD|MM|YY'),750,750,
							(SELECT id FROM marque WHERE nomMarque = '1800 Silver'),
							(SELECT id FROM liquide WHERE typeliquide = 'Tequila'),
							(SELECT id FROM lot WHERE commande = (SELECT id FROM commandeApprovisionnement WHERE datecommande = to_date('21|04|21','DD|MM|YY') AND 
																	fournisseur = (SELECT id FROM fournisseur WHERE contact_courriel = 'hubert.dubois@gmail.com'))),
							(SELECT id FROM machine WHERE nom = 'Machine 2'));
INSERT INTO bouteille VALUES(DEFAULT,to_date('23|04|21','DD|MM|YY'),750,40,
							(SELECT id FROM marque WHERE nomMarque = 'Coke'),
							(SELECT id FROM liquide WHERE typeliquide = 'Liqueur'),
							(SELECT id FROM lot WHERE commande = (SELECT id FROM commandeApprovisionnement WHERE datecommande = to_date('21|04|21','DD|MM|YY') AND 
																	fournisseur = (SELECT id FROM fournisseur WHERE contact_courriel = 'hubert.dubois@gmail.com'))),
							(SELECT id FROM machine WHERE nom = 'Machine 2'));
INSERT INTO bouteille VALUES(DEFAULT,to_date('23|04|21','DD|MM|YY'),750,450,
							(SELECT id FROM marque WHERE nomMarque = 'Sealtest'),
							(SELECT id FROM liquide WHERE typeliquide = 'Limonade'),
							(SELECT id FROM lot WHERE commande = (SELECT id FROM commandeApprovisionnement WHERE datecommande = to_date('21|04|21','DD|MM|YY') AND 
																	fournisseur = (SELECT id FROM fournisseur WHERE contact_courriel = 'hubert.dubois@gmail.com'))),
							(SELECT id FROM machine WHERE nom = 'Machine 1'));							

-- Insert Ingredients
INSERT INTO ingredients VALUES(DEFAULT,(SELECT id FROM bouteille WHERE 
							  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Rhum blanc')) AND
							  marque = ((SELECT id FROM marque WHERE nomMarque = 'Bacardi superior'))));
INSERT INTO ingredients VALUES(DEFAULT,(SELECT id FROM bouteille WHERE 
							  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Dry gin')) AND
							  marque = ((SELECT id FROM marque WHERE nomMarque = 'Gordon''s'))));
INSERT INTO ingredients VALUES(DEFAULT,(SELECT id FROM bouteille WHERE 
							  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Liqueur')) AND
							  marque = ((SELECT id FROM marque WHERE nomMarque = 'Coke'))));
INSERT INTO ingredients VALUES(DEFAULT,(SELECT id FROM bouteille WHERE 
							  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Limonade')) AND
							  marque = ((SELECT id FROM marque WHERE nomMarque = 'Sealtest'))));
INSERT INTO ingredients VALUES(DEFAULT,(SELECT id FROM bouteille WHERE 
							  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Tequila')) AND
							  marque = ((SELECT id FROM marque WHERE nomMarque = '1800 Silver'))));				
INSERT INTO ingredients VALUES(DEFAULT,(SELECT id FROM bouteille WHERE 
							  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Vodka')) AND
							  marque = ((SELECT id FROM marque WHERE nomMarque = 'Absolut'))));				
				
				
-- Insert RecetteIngredients
INSERT INTO recetteingredients VALUES((SELECT id FROM recette WHERE nom = 'Vodka sec'),
									 (SELECT id FROM ingredients WHERE
										 bouteille = (SELECT id FROM bouteille WHERE 
															  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Vodka')) AND
															  marque = ((SELECT id FROM marque WHERE nomMarque = 'Absolut')))),20);
INSERT INTO recetteingredients VALUES((SELECT id FROM recette WHERE nom = 'Rhum sec'),
									 (SELECT id FROM ingredients WHERE
										 bouteille = (SELECT id FROM bouteille WHERE 
															  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Rhum blanc')) AND
															  marque = ((SELECT id FROM marque WHERE nomMarque = 'Bacardi superior')))),15);
INSERT INTO recetteingredients VALUES((SELECT id FROM recette WHERE nom = 'Rhum and Coke'),
									 (SELECT id FROM ingredients WHERE
										 bouteille = (SELECT id FROM bouteille WHERE 
															  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Rhum blanc')) AND
															  marque = ((SELECT id FROM marque WHERE nomMarque = 'Bacardi superior')))),15);															  
INSERT INTO recetteingredients VALUES((SELECT id FROM recette WHERE nom = 'Rhum and Coke'),
									 (SELECT id FROM ingredients WHERE
										 bouteille = (SELECT id FROM bouteille WHERE 
															  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Liqueur')) AND
															  marque = ((SELECT id FROM marque WHERE nomMarque = 'Coke')))),30);															  
INSERT INTO recetteingredients VALUES((SELECT id FROM recette WHERE nom = 'Vodka limonade'),
									 (SELECT id FROM ingredients WHERE
										 bouteille = (SELECT id FROM bouteille WHERE 
															  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Limonade')) AND
															  marque = ((SELECT id FROM marque WHERE nomMarque = 'Sealtest')))),30);
INSERT INTO recetteingredients VALUES((SELECT id FROM recette WHERE nom = 'Vodka limonade'),
									 (SELECT id FROM ingredients WHERE
										 bouteille = (SELECT id FROM bouteille WHERE 
															  liquide = ((SELECT id FROM liquide WHERE typeliquide = 'Vodka')) AND
															  marque = ((SELECT id FROM marque WHERE nomMarque = 'Absolut')))),15);
															  
															  
															  
															  
-- Insert Evaluation
INSERT INTO evaluation VALUES((SELECT id FROM recette WHERE nom = 'Rhum sec'),
							  (SELECT id FROM client WHERE nomutilisateur = 'Dartagan_BMX'),TRUE);
INSERT INTO evaluation VALUES((SELECT id FROM recette WHERE nom = 'Tequila sec'),
							  (SELECT id FROM client WHERE nomutilisateur = 'Dartagan_BMX'),TRUE);							  
INSERT INTO evaluation VALUES((SELECT id FROM recette WHERE nom = 'Rhum sec'),
							  (SELECT id FROM client WHERE nomutilisateur = 'Fishing_Line'),FALSE);							  
INSERT INTO evaluation VALUES((SELECT id FROM recette WHERE nom = 'Rhum and Coke'),
							  (SELECT id FROM client WHERE nomutilisateur = 'Beowulf_XxX'),TRUE);
INSERT INTO evaluation VALUES((SELECT id FROM recette WHERE nom = 'Rhum and Coke'),
							  (SELECT id FROM client WHERE nomutilisateur = 'Dartagan_BMX'),TRUE);
INSERT INTO evaluation VALUES((SELECT id FROM recette WHERE nom = 'Rhum and Coke'),
							  (SELECT id FROM client WHERE nomutilisateur = 'Fishing_Line'),FALSE);
INSERT INTO evaluation VALUES((SELECT id FROM recette WHERE nom = 'Vodka limonade'),
							  (SELECT id FROM client WHERE nomutilisateur = 'Beowulf_XxX'),TRUE);
INSERT INTO evaluation VALUES((SELECT id FROM recette WHERE nom = 'Tequila sec'),
							  (SELECT id FROM client WHERE nomutilisateur = 'Beowulf_XxX'),False);


-- Insert Commande de client
INSERT INTO commandeclient VALUES(DEFAULT,to_timestamp('30/05/21 14:05:00','DD/MM/YY HH24:MI:SS' ),
								  to_timestamp('30/05/21 14:06:35','DD/MM/YY HH24:MI:SS' ),
								 (SELECT id FROM client WHERE nomUtilisateur = 'Beowulf_XxX'));
INSERT INTO commandeclient VALUES(DEFAULT,to_timestamp('30/05/21 16:05:00','DD/MM/YY HH24:MI:SS' ),
								  to_timestamp('30/05/21 16:08:00','DD/MM/YY HH24:MI:SS' ),
								 (SELECT id FROM client WHERE nomUtilisateur = 'Dartagan_BMX'));								 
INSERT INTO commandeclient VALUES(DEFAULT,to_timestamp('29/04/21 14:05:00','DD/MM/YY HH24:MI:SS' ),
								  NULL,
								 (SELECT id FROM client WHERE nomUtilisateur = 'Fishing_Line'));
INSERT INTO commandeclient VALUES(DEFAULT,to_timestamp('02/05/21 14:05:00','DD/MM/YY HH24:MI:SS' ),
								  NULL,
								 (SELECT id FROM client WHERE nomUtilisateur = 'Fishing_Line'));
								 
-- Insert CommandeRecette
INSERT INTO commanderecette VALUES(DEFAULT,
								 (SELECT id FROM recette WHERE nom = 'Rhum sec'),
								 (SELECT id FROM commandeclient WHERE 
								  				datecommande = to_timestamp('30/05/21 16:05:00','DD/MM/YY HH24:MI:SS' )
								 					AND client = (SELECT id FROM client WHERE nomUtilisateur = 'Dartagan_BMX')));
INSERT INTO commanderecette VALUES(DEFAULT,
								 (SELECT id FROM recette WHERE nom = 'Tequila sec'),
								 (SELECT id FROM commandeclient WHERE 
								  				datecommande = to_timestamp('30/05/21 16:05:00','DD/MM/YY HH24:MI:SS' )
								 					AND client = (SELECT id FROM client WHERE nomUtilisateur = 'Dartagan_BMX')));													
INSERT INTO commanderecette VALUES(DEFAULT,
								 (SELECT id FROM recette WHERE nom = 'Rhum and Coke'),
								 (SELECT id FROM commandeclient WHERE 
								  				datecommande = to_timestamp('29/04/21 14:05:00','DD/MM/YY HH24:MI:SS' )
								 					AND client = (SELECT id FROM client WHERE nomUtilisateur = 'Fishing_Line')));
INSERT INTO commanderecette VALUES(DEFAULT,
								 (SELECT id FROM recette WHERE nom = 'Vodka limonade'),
								 (SELECT id FROM commandeclient WHERE 
								  				datecommande = to_timestamp('29/04/21 14:05:00','DD/MM/YY HH24:MI:SS' )
								 					AND client = (SELECT id FROM client WHERE nomUtilisateur = 'Fishing_Line')));
INSERT INTO commanderecette VALUES(DEFAULT,
								 (SELECT id FROM recette WHERE nom = 'Vodka limonade'),
								 (SELECT id FROM commandeclient WHERE 
								  				datecommande = to_timestamp('02/05/21 14:05:00','DD/MM/YY HH24:MI:SS' )
								 					AND client = (SELECT id FROM client WHERE nomUtilisateur = 'Fishing_Line')));
													
-- Insert MachineCommande
INSERT INTO machinecommande VALUES((SELECT id FROM commandeclient WHERE 
										datecommande = to_timestamp('30/05/21 14:05:00','DD/MM/YY HH24:MI:SS') 
										AND client = (SELECT id FROM client WHERE nomUtilisateur = 'Beowulf_XxX')),
								  (SELECT id FROM machine WHERE nom = 'Machine 1'));
INSERT INTO machinecommande VALUES((SELECT id FROM commandeclient WHERE 
										datecommande = to_timestamp('30/05/21 16:05:00','DD/MM/YY HH24:MI:SS') 
										AND client = (SELECT id FROM client WHERE nomUtilisateur = 'Dartagan_BMX')),
								  (SELECT id FROM machine WHERE nom = 'Machine 1'));
INSERT INTO machinecommande VALUES((SELECT id FROM commandeclient WHERE 
										datecommande = to_timestamp('29/04/21 14:05:00','DD/MM/YY HH24:MI:SS') 
										AND client = (SELECT id FROM client WHERE nomUtilisateur = 'Fishing_Line')),
								  (SELECT id FROM machine WHERE nom = 'Machine 1'));
INSERT INTO machinecommande VALUES((SELECT id FROM commandeclient WHERE 
										datecommande = to_timestamp('02/05/21 14:05:00','DD/MM/YY HH24:MI:SS') 
										AND client = (SELECT id FROM client WHERE nomUtilisateur = 'Fishing_Line')),
								  (SELECT id FROM machine WHERE nom = 'Machine 1'));
-- Insert Capteur
INSERT INTO capteur VALUES(DEFAULT,to_date('01|01|21','DD|MM|YY'),null,1,(SELECT id FROM machine WHERE nom = 'Machine 3'),54,
						  to_timestamp('11/06/21 15:16:01','DD/MM/YY HH24:MI:SS'),nextval('seq_capteur_partnum'));
INSERT INTO capteur VALUES(DEFAULT,to_date('01|01|21','DD|MM|YY'),null,0,(SELECT id FROM machine WHERE nom = 'Machine 1'),12,
						  to_timestamp('11/06/21 15:18:01','DD/MM/YY HH24:MI:SS'),nextval('seq_capteur_partnum'));
INSERT INTO capteur VALUES(DEFAULT,to_date('01|01|21','DD|MM|YY'),null,1,(SELECT id FROM machine WHERE nom = 'Machine 3'),14,
						  to_timestamp('11/06/21 15:19:01','DD/MM/YY HH24:MI:SS'),nextval('seq_capteur_partnum'));

-- Insert actionneur
INSERT INTO actionneur VALUES(DEFAULT,to_date('01|01|21','DD|MM|YY'),NULL,1,(SELECT id FROM machine WHERE nom = 'Machine 1'),
							  to_timestamp('11/06/21 09:08:00','DD/MM/YY HH24:MI:SS'),nextval('seq_actionneur_partnum'));
INSERT INTO actionneur VALUES(DEFAULT,to_date('01|01|21','DD|MM|YY'),NULL,1,(SELECT id FROM machine WHERE nom = 'Machine 2'),
							  to_timestamp('11/06/21 13:14:02','DD/MM/YY HH24:MI:SS'),nextval('seq_actionneur_partnum'));
INSERT INTO actionneur VALUES(DEFAULT,to_date('01|01|21','DD|MM|YY'),NULL,0,(SELECT id FROM machine WHERE nom = 'Machine 2'),
							  to_timestamp('11/06/21 17:16:01','DD/MM/YY HH24:MI:SS'),nextval('seq_actionneur_partnum'));

-- Insert DonneesCapteur
INSERT INTO donneecapteur VALUES(101,1);
INSERT INTO donneecapteur VALUES(103,1);
INSERT INTO donneecapteur VALUES(105,0);

-- Insert DonneesActionneur
INSERT INTO donneeactionneur VALUES(100,1);
INSERT INTO donneeactionneur VALUES(102,1);
INSERT INTO donneeactionneur VALUES(104,0);

-- Insert Données enregistrés
INSERT INTO donneeenregistree VALUES(DEFAULT,to_timestamp('11/06/21 09:08:00','DD/MM/YY HH24:MI:SS'),1,(SELECT id FROM capteur WHERE partnumber= 101));
INSERT INTO donneeenregistree VALUES(DEFAULT,to_timestamp('11/06/21 13:14:02','DD/MM/YY HH24:MI:SS'),1,(SELECT id FROM capteur WHERE partnumber= 103));
INSERT INTO donneeenregistree VALUES(DEFAULT,to_timestamp('11/06/21 17:16:01','DD/MM/YY HH24:MI:SS'),0,(SELECT id FROM capteur WHERE partnumber= 105));
INSERT INTO donneeenregistree VALUES(DEFAULT,to_timestamp('11/06/21 15:16:01','DD/MM/YY HH24:MI:SS'),1,(SELECT id FROM actionneur WHERE partnumber= 100));
INSERT INTO donneeenregistree VALUES(DEFAULT,to_timestamp('11/06/21 15:18:01','DD/MM/YY HH24:MI:SS'),1,(SELECT id FROM actionneur WHERE partnumber= 102));
INSERT INTO donneeenregistree VALUES(DEFAULT,to_timestamp('11/06/21 15:19:01','DD/MM/YY HH24:MI:SS'),0,(SELECT id FROM actionneur WHERE partnumber= 104));

															  
-- Insert Maintenance
INSERT INTO maintenance VALUES(DEFAULT,'Actuateur bloqué',to_date('30|05|21','DD|MM|YY'),to_date('30|05|21','DD|MM|YY'),
							   (SELECT id FROM employes WHERE nomUtilisateur = 'GabyChou23'),
							  (SELECT id FROM machine WHERE responsable = (SELECT id FROM employes WHERE nomUtilisateur = 'GabyChou23')));
INSERT INTO maintenance VALUES(DEFAULT,'Bouteille bloquée',to_date('30|05|21','DD|MM|YY'),to_date('30|05|21','DD|MM|YY'),
							   (SELECT id FROM employes WHERE nomUtilisateur = 'GabyChou23'),
							  (SELECT id FROM machine WHERE responsable = (SELECT id FROM employes WHERE nomUtilisateur = 'GabyChou23')));
INSERT INTO maintenance VALUES(DEFAULT,'Actuateur bloqué',to_date('01|06|21','DD|MM|YY'),to_date('01|06|21','DD|MM|YY'),
							   (SELECT id FROM employes WHERE nomUtilisateur = '8ou8_lol'),
							  (SELECT id FROM machine WHERE responsable = (SELECT id FROM employes WHERE nomUtilisateur = '8ou8_lol')));							  

-- Insert Horaire
INSERT INTO horaire VALUES((SELECT id FROM employes WHERE nomUtilisateur = 'GabyChou23'),TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE);
INSERT INTO horaire VALUES((SELECT id FROM employes WHERE nomUtilisateur = '8ou8_lol'),FALSE,FALSE,FALSE,TRUE,TRUE,TRUE,TRUE);
INSERT INTO horaire VALUES((SELECT id FROM employes WHERE nomUtilisateur = 'BibiVUCT'),FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,TRUE);


-- Insert Alarmes
INSERT INTO alarme VALUES(DEFAULT,to_timestamp('01/02/21 07:05:00','DD/MM/YY HH24:MI:SS'),1,'Ceci est une alarme',
						  TRUE,TRUE,to_timestamp('01/02/21 07:10:00','DD/MM/YY HH24:MI:SS'),
						 (SELECT id FROM machine WHERE nom = 'Machine 1'));
INSERT INTO alarme VALUES(DEFAULT,to_timestamp('10/02/21 07:05:00','DD/MM/YY HH24:MI:SS'),1,'Ceci est aussi une alarme',
						  FALSE,FALSE,NULL,
						 (SELECT id FROM machine WHERE nom = 'Machine 1'));
INSERT INTO alarme VALUES(DEFAULT,to_timestamp('01/04/21 07:05:00','DD/MM/YY HH24:MI:SS'),3,'Ceci est aussi une alarme',
						  FALSE,TRUE,NULL,
						 (SELECT id FROM machine WHERE nom = 'Machine 1'));
INSERT INTO alarme VALUES(DEFAULT,to_timestamp('01/05/21 07:05:00','DD/MM/YY HH24:MI:SS'),1,'Ceci est aussi une alarme',
						  FALSE,TRUE,NULL,
						 (SELECT id FROM machine WHERE nom = 'Machine 2'));
INSERT INTO alarme VALUES(DEFAULT,to_timestamp('01/06/21 07:05:30','DD/MM/YY HH24:MI:SS'),2,'Ceci est aussi une alarme',
						  FALSE,TRUE,NULL,
						 (SELECT id FROM machine WHERE nom = 'Machine 2'));						 
INSERT INTO alarme VALUES(DEFAULT,to_timestamp('01/06/21 07:06:00','DD/MM/YY HH24:MI:SS'),3,'Ceci est aussi une alarme',
						  true,TRUE,to_timestamp('01/06/21 07:10:00','DD/MM/YY HH24:MI:SS'),
						 (SELECT id FROM machine WHERE nom = 'Machine 3'));
						 
						 
-- ACTIVATE TRIGGER 
ALTER TABLE machine ENABLE TRIGGER ALL;
ALTER TABLE recette ENABLE TRIGGER ALL;
ALTER TABLE maintenance ENABLE TRIGGER ALL;
ALTER TABLE horaire ENABLE TRIGGER ALL;
ALTER TABLE commandeApprovisionnement ENABLE TRIGGER ALL;
ALTER TABLE modepaiement ENABLE TRIGGER ALL;
ALTER TABLE evaluation ENABLE TRIGGER ALL;
ALTER TABLE commandeclient ENABLE TRIGGER ALL;
ALTER TABLE donneecapteur ENABLE TRIGGER ALL;
ALTER TABLE donneeactionneur ENABLE TRIGGER ALL;
ALTER TABLE donneeenregistree ENABLE TRIGGER ALL;


ALTER TABLE recette DISABLE TRIGGER ALL;
CALL creation_recette(CAST('Création 1' AS VARCHAR(64)),
					  CAST('Beowulf_XxX' AS VARCHAR(64)), 
					  CAST(to_date('30|06|21','DD|MM|YY') AS TIMESTAMP), 
					  CAST(6.00 AS MONEY));
ALTER TABLE recette ENABLE TRIGGER ALL;

CALL ajout_ingredient_recette(CAST('Création 1' AS VARCHAR(64)),
								CAST('Vodka' AS VARCHAR(64)), CAST('Absolut' AS VARCHAR(64)), 15,
								CAST('Liqueur' AS VARCHAR(64)), CAST('Coke' AS VARCHAR(64)), 30);

	
			
			
