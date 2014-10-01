<?php

class NoteManager {
	
	private $db;
	
	public function __construct($db){
		$this->db = $db;
	}
	
	public function selectNote($id){
		$req = $this->db->prepare('select * from Note where Id_Note = ?');
		$req->execute(array($id));
		
		return new Note($req->fetch(PDO::FETCH_ASSOC));
	}
	
	public function exist($id){
		$req = $this->db->prepare('select * from Note where Id_Note = ?');
		$req->execute(array($id));
		
		return (bool) $req->fetch();
	}
	
	public function deleteNote($id){
		$req = $this->db->prepare('delete from Note where Id_Note = ?');
		$req->execute(array($id));
	}
	public function delete($note, $commentaireManage){
		$commentaireManage->deletePertinenceCommentaire($note->getId_commentaire());
		$id = $note->getId_commentaire();
		$idnote = $note->getId_note();
		$this->deleteNote($idnote);
		$commentaireManage->deleteCommentaire($id);
	}
	
	public function addNote($note){
		$req = $this->db->prepare('insert into Note values(\'\',?,?,?,?,NOW())');
		$req->execute(array($note['Id_Joueur'], $note['Id_Jeu'], $note['Id_Commentaire'], $note['Note']));
	}
	
public function modifyNote($note){
		$req = $this->db->prepare('update Note set values(\'\', ?,?,?,?,?)');
		$req->execute(array($note['Id_Joueur'], $note['Id_Jeu'], $note['Id_Commentaire'], $note['Id_Note'], $note['Note'], $note['Date_Note']));
	}
	
	public function selectAllNotesJeu($id_jeu){
		$req = $this->db->prepare('(
SELECT Note . * , ( 1 + pos ) / ( 1 + neg ) AS conf
FROM Note, (
(

SELECT Id_Commentaire, sum( T.positif ) AS pos, sum( T.negatif ) AS neg
FROM (
(
(

SELECT Id_Commentaire, count( * ) AS negatif, 0 AS positif
FROM Pertinence
WHERE Id_Commentaire
IN (

SELECT Id_Commentaire
FROM Note
WHERE Id_Jeu =?
)
AND Valeur = -1
GROUP BY Id_Commentaire
)
UNION (

SELECT Id_Commentaire, 0 AS negatif, count( * ) AS positif
FROM Pertinence
WHERE Id_Commentaire
IN (

SELECT Id_Commentaire
FROM Note
WHERE Id_Jeu =?
)
AND Valeur =1
GROUP BY Id_Commentaire
)
) AS T
)
GROUP BY Id_Commentaire
) AS F
)
WHERE Note.Id_Jeu =?
AND Note.Id_Commentaire = F.Id_Commentaire
ORDER BY ( 1 + pos ) / ( 1 + neg ) DESC
)
UNION (

SELECT Note . * , 1 AS conf
FROM Note
WHERE Note.Id_Jeu =?
AND Note.Id_Commentaire NOT
IN (

SELECT Id_Commentaire
FROM Pertinence
)
) order by conf desc');
		$req->execute(array($id_jeu,$id_jeu,$id_jeu,$id_jeu));
		$notes = array();
		while($note = $req->fetch(PDO::FETCH_ASSOC))
			$notes[] = new Note($note);
		return $notes;
	}
	
	public function selectAllNotesJoueur($id_joueur){
		$req = $this->db->prepare('select * from Note where Id_Joueur = ?');
		$req->execute(array($id_joueur));
		$notes = array();
		while($note = $req->fetch(PDO::FETCH_ASSOC))
			$notes[] = new Note($note);
		return $notes;
	}
	
		public function aNote($id_joueur, $id_jeu){
		$req = $this->db->prepare('select * from Note where Id_Joueur = ? and Id_Jeu = ?');
		$req->execute(array($id_joueur, $id_jeu));
		return (bool) $req->fetch();
	}
	
	public function moyenneNote($id_jeu){
		$req = $this->db->prepare('(select ROUND(sum(Note*((1+pos)/(1+neg)))/sum((1+pos)/(1+neg)),2) as note  from Note,
((select Id_Commentaire, sum(T.positif) as pos, sum(T.negatif) as neg from
(((select Id_Commentaire ,count(*) as negatif, 0 as positif from Pertinence 
where Id_Commentaire in (select Id_Commentaire from Note where Id_Jeu = ?)  
and Valeur = -1  group by Id_Commentaire) 
 union
(select Id_Commentaire ,0 as negatif,count(*) as positif from Pertinence
where Id_Commentaire in (select Id_Commentaire from Note where Id_Jeu = ?) and Valeur = 1  group by Id_Commentaire)) as T)  group by Id_Commentaire) as F) where Note.Id_Commentaire = F.Id_Commentaire);');
		$req->execute(array($id_jeu,$id_jeu));
		return $req->fetch(PDO::FETCH_ASSOC);
	}
	public function nNotes($n){
		$req = $this->db->prepare('SELECT *
FROM Note
ORDER BY Date_Note DESC
LIMIT 0 , :fin');
$req->bindParam(':fin',$n, PDO::PARAM_INT);
		$req->execute();
		$notes= array();
		while($note = $req->fetch(PDO::FETCH_ASSOC))
			$notes[] = new Note($note);
		return $notes;
	}
	public function notebycomment($id){
		$req = $this->db->prepare('select * from Note where Note.Id_Commentaire = ?');
		$req->execute(array($id));
		
		return new Note($req->fetch(PDO::FETCH_ASSOC));
	}
	public function populaire(){
		//$req = $this->db->query('select Id_Commentaire, max(nb) from ((select Id_Commentaire, count(*) as nb from Pertinence group by Id_Commentaire) as T)');
		$req = $this->db->query('select Id_Commentaire, count(Id_Commentaire) from Pertinence group by Id_Commentaire having count(Id_Commentaire) = (select max(T.nbs) 
		from ((select count(Id_Commentaire) as nbs from Pertinence group by Id_Commentaire) as T)) limit 1;');
		return $req->fetch(PDO::FETCH_ASSOC);
}
	
	public function nNotesClasse($n){
		$req = $this->db->prepare('(SELECT Note.*,
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
ORDER BY conf DESC limit :N;
');

$req->bindParam(':N',$n, PDO::PARAM_INT);
		$req->execute();
		$notes= array();
		while($note = $req->fetch(PDO::FETCH_ASSOC))
			$notes[] = new Note($note);
		return $notes;
	}
	
}
	
	
	
	/* les N commentaire classé par indice
	 * select Note.*,N.confiance from Note, ((select Id_Commentaire, (1+P.pos)/(1+.P.neg) as confiance from ((select Id_Commentaire, sum(T.positif) as pos, sum(T.negatif) as neg from (((select Id_Commentaire, count(Valeur) as positif, 0 as negatif from Pertinence where Valeur = 1 group by Id_Commentaire) union (select Id_Commentaire, 0 as positif, count(Valeur) as negatif from Pertinence where Valeur = -1 group by Id_Commentaire)) as T) group by Id_Commentaire) as P)) as N) where Note.Id_Commentaire = N.Id_Commentaire order by N.confiance desc limit N;*/
	
	
	
	

