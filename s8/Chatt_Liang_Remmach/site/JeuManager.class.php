<?php

class JeuManager{
	private $db;
	
	public function __construct($db){
		$this->db = $db;
	}
	
	public function exist($info){
		if(is_int($info)){
		$req = $this->db->prepare('select * from Jeu where Id_Jeu = ?');
		$req->execute(array($info));
		return (bool) $req->fetch();
	}
	else{
			$req = $this->db->prepare('select * from Jeu where Nom_Jeu = ?');
		$req->execute(array($info));
		return (bool) $req->fetch();
		}
	}
	
	public function count(){
		return $this->db->query('select count(*) from Jeu')->fetchcolumn();
	}
	
	public function modifyJeu($jeu){
		$req = $this->db->prepare('update Jeu set Nom_Jeu = ?, Date_Parution = ?, Id_Editeur = ?, Id_Plateforme = ? ,img = ? where Id_Jeu = ? ');
		$req->execute(array($jeu['Nom_Jeu'], $jeu['Date_Parution'], $jeu['Id_Editeur'], $jeu['Id_Plateforme'], $jeu['img'], $jeu['Id_Jeu']));
	}
	
	public function addJeu($jeu){
		$req = $this->db->prepare('insert into Jeu values(\'\', ?, ?, ?, ?,?)');
		$req->execute(array($jeu['Nom_Jeu'], $jeu['Date_Parution'], $jeu['Id_Editeur'], $jeu['Id_Plateforme'],$jeu['img']));
		return $this->db->LastInsertId();
	}
	public function deleteJeu($id){
		$req = $this->db->prepare('delete from Jeu where Id_Jeu = ?');
		$req->execute(array($id));
	}
	
	public function selectJeu($id){
		$req = $this->db->prepare('select * from Jeu where Id_Jeu = ?');
		$req->execute(array($id));
		
		return new Jeu($req->fetch(PDO::FETCH_ASSOC));
	}
	
	public function selectJeuList(){
		$req = $this->db->query('
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
 WHERE Jeu.Id_Jeu = Y.Id_Jeu)
 order by Moy_Pond desc;');
		
		/*(select Jeu.* from Jeu,((select Id_Jeu, avg(note) as Note_moy from Note group by Id_Jeu order by Note_moy desc,Id_Jeu asc) as T) 
		where Jeu.Id_Jeu = T.Id_Jeu) union (select Jeu.* from Jeu where Id_Jeu not in (select Id_Jeu from Note) order by Id_Jeu asc);'*/
		//classe les jeux selon leur note non pondéré.
		$jeux = array();
		
		while($jeu = $req->fetch(PDO::FETCH_ASSOC))
			$jeux[] = new Jeu($jeu);
			
		return $jeux;
	}
	
	public function selectCritiquePlateformeCategorie($plateforme, $categorie){
		$req = $this->db->prepare('SELECT distinct J.* FROM Jeu J, Categories_Jeu CJ, Note N WHERE J.Id_Plateforme =? AND CJ.Id_Categorie =?
									AND CJ.Id_Jeu = J.Id_Jeu AND N.Id_Jeu = J.Id_Jeu ORDER BY CJ.Id_Categorie');
		$req->execute(array($plateforme,$categorie));
		$jeux = array();
		while($jeu = $req->fetch(PDO::FETCH_ASSOC))
			$jeux[] = new Jeu($jeu);
		return $jeux;
	}
	
	public function selectCritiquePlateforme($plateforme){
		$req = $this->db->prepare('select distinct T.* from Categories_Jeu, ((select Jeu.* from Jeu, Note where Jeu.Id_Plateforme = ? and Jeu.Id_Jeu = Note.Id_Jeu) as T) 
		where T.Id_Jeu = Categories_Jeu.Id_Jeu order by Categories_Jeu.Id_Categorie;');
		/*select Jeu.* from Jeu,((select Id_Jeu, avg(note) as Note_moy from Note group by Id_Jeu order by Note_moy desc,Id_Jeu asc) as T) where Jeu.Id_Jeu = T.Id_Jeu and Id_Plateforme = ?*/
		$req->execute(array($plateforme));
		$jeux = array();
		while($jeu = $req->fetch(PDO::FETCH_ASSOC))
			$jeux[] = new Jeu($jeu);
		return $jeux;
	}
	
	public function isCriticized($id){
		$req = $this->db->prepare('select * from Note where Id_Jeu = ?');
		$req->execute(array($id));
		return (bool) $req->fetch();
	}
	
	
	
	
	
	
	
	
	
	
	
	
}
