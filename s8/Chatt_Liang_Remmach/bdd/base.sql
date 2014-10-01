-- ============================================================
--   Nom de la base   :  JEUX VIDEO                                
--   Date de creation :  09/11/13                         
-- ============================================================

DROP TABLE IF EXISTS Pertinence ;

DROP TABLE IF EXISTS Categories_Jeu ;

DROP TABLE IF EXISTS Note ;

DROP TABLE IF EXISTS Commentaire ;

DROP TABLE IF EXISTS Jeu ;

DROP TABLE IF EXISTS Editeur;

DROP TABLE IF EXISTS Joueur ;

DROP TABLE IF EXISTS Categorie ;

DROP TABLE IF EXISTS Plateforme ; 





-- ============================================================
--   Table :  JOUEUR                                           
-- ============================================================

CREATE TABLE Joueur
(
       Id_Joueur		int NOT NULL AUTO_INCREMENT,
       Pseudo_Joueur 		CHAR(30) UNIQUE,
       Nom_Joueur 		CHAR(30) ,
       Prenom_Joueur 		CHAR(30),
       Email_Joueur 		CHAR(30) UNIQUE,
       Id_Plateforme 		int NOT NULL,
       Id_Categorie 		int NOT NULL,	
       password 		varchar(255) NOT NULL DEFAULT '7505d64a54e061b7acd54ccd58b49dc43500b635', -- default crypte 
       PRIMARY KEY (Id_Joueur) 
);


-- ============================================================
--   Table : JEU                                     
-- ============================================================

CREATE TABLE Jeu 
(
	Id_Jeu			int NOT NULL AUTO_INCREMENT,
	Nom_Jeu 		CHAR(100),
	Date_Parution		DATE,
	Id_Editeur 		int NOT NULL,
	Id_Plateforme 		int NOT NULL,
	img			varchar(255) default 'sample.jpg',
	PRIMARY KEY (Id_Jeu) 
);


-- ============================================================
--   Table : Plateforme                                         
-- ============================================================

CREATE TABLE Plateforme
(
	Id_Plateforme		int NOT NULL AUTO_INCREMENT,
	Nom_Plateforme		CHAR(30),
	PRIMARY KEY (Id_Plateforme) 
);


-- ============================================================
--   Table : CATEGORIE                                         
-- ============================================================

CREATE TABLE Categorie
(
	Id_Categorie		int NOT NULL AUTO_INCREMENT,
	Nom_Categorie		CHAR(30),
	PRIMARY KEY (Id_Categorie) 
);



-- ============================================================
--   Table : EDITEUR                                         
-- ============================================================

CREATE TABLE Editeur
(
	Id_Editeur		int NOT NULL AUTO_INCREMENT,
	Nom_Editeur		CHAR(30),
	PRIMARY KEY (Id_Editeur) 
);

-- ============================================================
--   Table : Categories_Jeu                      
-- ============================================================

CREATE TABLE Categories_Jeu 
(
	Id_Categorie		int NOT NULL,
	Id_Jeu 			int NOT NULL,
	PRIMARY KEY (Id_Categorie, Id_Jeu) 
);


-- ============================================================
--   Table : COMMENTAIRE                                            
-- ============================================================


CREATE TABLE Commentaire 
(
	Id_Commentaire		int NOT NULL AUTO_INCREMENT,
	Contenu 		TEXT NOT NULL,
	PRIMARY KEY (Id_Commentaire)	 
);


-- ============================================================
--   Table : NOTE                                 
-- ============================================================

CREATE TABLE Note 
(
	Id_Note 		 int NOT NULL AUTO_INCREMENT,		
	Id_Joueur		 int NOT NULL,
	Id_Jeu 			 int NOT NULL,
	Id_Commentaire		 int NOT NULL,
	Note 			 int,
	Date_Note		 DATETIME,
	PRIMARY KEY (Id_Note) 
);

-- ============================================================
--   Table :  PERTINENCE                                           
-- ============================================================

CREATE TABLE Pertinence 
(
	Id_Commentaire		int NOT NULL,
	Id_Joueur 		int NOT NULL,
	Valeur 			int,
	PRIMARY KEY (Id_Commentaire, Id_Joueur) 
);



-- ============================================================
--      DEFINITIONS DES CLES ETRANGERES              
-- ============================================================


ALTER TABLE Joueur
      ADD CONSTRAINT FK_Joueur_Id_Categorie FOREIGN KEY (Id_Categorie)
      REFERENCES Categorie (Id_Categorie);

ALTER TABLE Joueur
      ADD CONSTRAINT FK_Joueur_Id_Plateforme FOREIGN KEY (Id_Plateforme)
      REFERENCES Plateforme (Id_Plateforme);


ALTER TABLE Jeu
      ADD CONSTRAINT FK_Jeu_Id_Plateforme FOREIGN KEY (Id_Plateforme)
      REFERENCES Plateforme (Id_Plateforme);

ALTER TABLE Jeu
      ADD CONSTRAINT FK_Jeu_Id_Editeur FOREIGN KEY (Id_Editeur)
      REFERENCES Editeur (Id_Editeur);


ALTER TABLE Note
      ADD CONSTRAINT FK_Note_Id_Joueur FOREIGN KEY (Id_Joueur)
      REFERENCES Joueur (Id_Joueur);

ALTER TABLE Note 
      ADD CONSTRAINT FK_Note_Id_Jeu FOREIGN KEY (Id_Jeu) 
      REFERENCES Jeu (Id_Jeu);

ALTER TABLE Note 
      ADD CONSTRAINT FK_Note_Id_Commentaire FOREIGN KEY (Id_Commentaire) 
      REFERENCES Commentaire (Id_Commentaire)
      ON DELETE CASCADE;

ALTER TABLE Pertinence 
      ADD CONSTRAINT FK_Pertinence_Id_Commentaire FOREIGN KEY (Id_Commentaire) 
      REFERENCES Commentaire (Id_Commentaire)
      ON DELETE CASCADE;

ALTER TABLE Pertinence 
      ADD CONSTRAINT FK_Pertinence_Id_Joueur FOREIGN KEY (Id_Joueur) 
      REFERENCES Joueur (Id_Joueur)
      ON DELETE CASCADE;

ALTER TABLE Categories_Jeu 
      ADD CONSTRAINT FK_Categories_Jeu_Id_Categorie FOREIGN KEY (Id_Categorie) 
      REFERENCES Categorie (Id_Categorie);


ALTER TABLE Categories_Jeu 
      ADD CONSTRAINT FK_Categories_Jeu_Id_Jeu FOREIGN KEY (Id_Jeu) 
      REFERENCES Jeu (Id_Jeu);


-- ============================================================
--   TRIGGER D'INTEGRITE                                           
-- ============================================================


delimiter //
-- trigger supp note => supp pertinence ==> supp commentaire
CREATE TRIGGER supp_Note BEFORE DELETE ON Note
       FOR EACH ROW
       BEGIN
       DELETE from Commentaire WHERE Commentaire.Id_Commentaire = OLD.Id_Commentaire;
       END //

-- trigger supp joueur => supp note && supp pertinence
CREATE TRIGGER supp_Joueur BEFORE DELETE ON Joueur
       FOR EACH ROW
       BEGIN
       DELETE from Note WHERE Note.Id_Joueur = OLD.Id_Joueur;
       DELETE from Pertinence where Pertinence.Id_Joueur = OLD.Id_Joueur;
       END //

-- trigger supp jeu => supp note && supp categories_jeu
CREATE TRIGGER supp_Jeu BEFORE DELETE ON Jeu
       FOR EACH ROW
       BEGIN
       DELETE from Note WHERE Note.Id_Jeu = OLD.Id_Jeu;
       DELETE from Categories_Jeu Where Categories_Jeu.Id_Jeu = OLD.Id_Jeu;
       END //

CREATE TRIGGER verif_Note BEFORE INSERT ON Note
       FOR EACH ROW
       BEGIN
       IF (New.Note > 20 or New.Note < 0)
       CALL my_signal('ERROR NOTE SUP A 20 OU INF A 0');
       END IF;
       END//

delimiter ;

