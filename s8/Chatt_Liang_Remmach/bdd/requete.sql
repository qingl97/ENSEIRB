-- ensemble des jeux critiqués disponibles sur une plateforme donnée, classés par catégorie

SELECT DISTINCT T.*
FROM Categories_Jeu, (
                        (SELECT Jeu.*
                         FROM Jeu,
                              Note
                         WHERE Jeu.Id_Plateforme = 1
                           AND Jeu.Id_Jeu = Note.Id_Jeu) AS T)
WHERE T.Id_Jeu = Categories_Jeu.Id_Jeu
ORDER BY Categories_Jeu.Id_Categorie;

-- pour un commentaire la liste des joueurs qui l'ont apprécié

SELECT Joueur.*
FROM Joueur
WHERE Id_Joueur IN
    (SELECT Id_Joueur
     FROM Pertinence
     WHERE Id_Commentaire = 1
       AND Valeur = 1);

-- liste des N commentaire les plus récents

SELECT *
FROM Note
ORDER BY Date_Note DESC LIMIT N;

-- Commentaire laissant le moins indifférents

SELECT Id_Commentaire,
       count(Id_Commentaire)
FROM Pertinence
GROUP BY Id_Commentaire HAVING count(Id_Commentaire) =
  (SELECT max(T.nbs)
   FROM (
           (SELECT count(Id_Commentaire) AS nbs
            FROM Pertinence
            GROUP BY Id_Commentaire) AS T));

-- Tous les commentaires triees par indice de confiance 

(SELECT Note.*,
        N.confiance AS conf
 FROM Note, (
               (SELECT Id_Commentaire, (1+P.pos)/(1+.P.neg) AS confiance
                FROM (
                        (SELECT Id_Commentaire,
                                sum(T.positif) AS pos,
                                sum(T.negatif) AS neg
                         FROM ((
                                  (SELECT Id_Commentaire,
                                          count(Valeur) AS positif,
                                          0 AS negatif
                                   FROM Pertinence
                                   WHERE Valeur = 1
                                   GROUP BY Id_Commentaire)
                                UNION
                                  (SELECT Id_Commentaire,
                                          0 AS positif,
                                          count(Valeur) AS negatif
                                   FROM Pertinence
                                   WHERE Valeur = -1
                                   GROUP BY Id_Commentaire)) AS T)
                         GROUP BY Id_Commentaire) AS P)) AS N)
 WHERE Note.Id_Commentaire = N.Id_Commentaire)
UNION
(SELECT Note.* ,
        1 AS conf
 FROM Note
 WHERE Id_Commentaire NOT IN
     (SELECT Id_Commentaire
      FROM Pertinence))
ORDER BY conf DESC;

 --  Joueurs classés selon le nb de jeux qu'ils ont noté

(SELECT Joueur.*,
          count(*) AS nb
   FROM Joueur,
        Note
   WHERE Joueur.Id_Joueur = Note.Id_Joueur
   GROUP BY Id_Joueur)
UNION
  (SELECT Joueur.*,
          0 AS nb
   FROM Joueur
   WHERE Id_Joueur NOT IN
       (SELECT Id_Joueur
        FROM Note))
ORDER BY nb DESC;

 -- Jeux classés selon la moyenne arithmétique de leur note ( les jeux non noté ne sont pas affichés )

SELECT Jeu.*
FROM Jeu, (
             (SELECT Id_Jeu,
                     avg(note) AS Note_moy
              FROM Note
              GROUP BY Id_Jeu
              ORDER BY Note_moy DESC) AS T)
WHERE Jeu.Id_Jeu = T.Id_Jeu;

 -- Commentaires du jeu ?? classé selon l'indice de confiance

(SELECT Note.*, (1+pos)/(1+neg) AS conf
 FROM Note, (
               (SELECT Id_Commentaire,
                       sum(T.positif) AS pos,
                       sum(T.negatif) AS neg
                FROM ((
                         (SELECT Id_Commentaire ,
                                 count(*) AS negatif,
                                 0 AS positif
                          FROM Pertinence
                          WHERE Id_Commentaire IN
                              (SELECT Id_Commentaire
                               FROM Note
                               WHERE Id_Jeu = 7)
                            AND Valeur = -1
                          GROUP BY Id_Commentaire)
                       UNION
                         (SELECT Id_Commentaire ,
                                 0 AS negatif,
                                 count(*) AS positif
                          FROM Pertinence
                          WHERE Id_Commentaire IN
                              (SELECT Id_Commentaire
                               FROM Note
                               WHERE Id_Jeu = 7)
                            AND Valeur = 1
                          GROUP BY Id_Commentaire)) AS T)
                GROUP BY Id_Commentaire) AS F)
 WHERE Note.Id_Jeu = 7
   AND Note.Id_Commentaire = F.Id_Commentaire
 ORDER BY (1+pos)/(1+neg) DESC)
UNION
  (SELECT Note.*,
          1 AS conf
   FROM Note
   WHERE Note.Id_Jeu = 7
     AND Note.Id_Commentaire NOT IN
       (SELECT Id_Commentaire
        FROM Pertinence))
ORDER BY conf DESC;

 -- Tous les Jeux classés par la moyenne pondéré "note confiance" (les jeux nn notés ne sont pas affichés)

(SELECT Jeu.*,Moy_Pond
 FROM Jeu, (
              (SELECT Id_Jeu,
                      sum(Note*confiance)/sum(confiance) AS Moy_Pond
               FROM (
                       (SELECT Id_Jeu, Id_Commentaire, Note,(1+sum(positif))/(1+sum(negatif)) AS confiance
                        FROM ((
                                 (SELECT Note.Id_Jeu,
                                         Note.Id_Commentaire,
                                         Note.Note ,
                                         count(*) AS negatif,
                                         0 AS positif
                                  FROM Pertinence,
                                       Note
                                  WHERE Note.Id_Commentaire = Pertinence.Id_Commentaire
                                    AND Valeur = -1
                                  GROUP BY Note.Id_Commentaire)
                               UNION
                                 (SELECT Note.Id_Jeu,
                                         Note.Id_Commentaire,
                                         Note.Note ,
                                         0 AS negatif ,
                                         count(*) AS positif
                                  FROM Pertinence,
                                       Note
                                  WHERE Note.Id_Commentaire = Pertinence.Id_Commentaire
                                    AND Valeur = 1
                                  GROUP BY Note.Id_Commentaire)) AS T)
                        GROUP BY Id_Commentaire) AS P)
               GROUP BY Id_Jeu
               ORDER BY Moy_Pond DESC) AS Y)
 WHERE Jeu.Id_Jeu = Y.Id_Jeu);

 -- Renvoie la moyenne pondéré du jeu ??

SELECT sum(Note*((1+pos)/(1+neg)))/sum((1+pos)/(1+neg)) AS avg_pond
FROM Note, (
              (SELECT Id_Commentaire,
                      sum(T.positif) AS pos,
                      sum(T.negatif) AS neg
               FROM ((
                        (SELECT Id_Commentaire ,
                                count(*) AS negatif,
                                0 AS positif
                         FROM Pertinence
                         WHERE Id_Commentaire IN
                             (SELECT Id_Commentaire
                              FROM Note
                              WHERE Id_Jeu = ??)
                           AND Valeur = -1
                         GROUP BY Id_Commentaire)
                      UNION
                        (SELECT Id_Commentaire ,
                                0 AS negatif,
                                count(*) AS positif
                         FROM Pertinence
                         WHERE Id_Commentaire IN
                             (SELECT Id_Commentaire
                              FROM Note
                              WHERE Id_Jeu = ??)
                           AND Valeur = 1
                         GROUP BY Id_Commentaire)) AS T)
               GROUP BY Id_Commentaire) AS F)
WHERE Note.Id_Commentaire = F.Id_Commentaire;


