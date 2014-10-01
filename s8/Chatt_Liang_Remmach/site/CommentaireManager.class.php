<?php

class CommentaireManager{
	
	private $db;
	
	public function __construct($db){
		$this->db = $db;
	}
	
	
	public function selectCommentaire($id){
		$req = $this->db->prepare('select * from Commentaire where Id_Commentaire = ? ');
		$req->execute(array($id));
		
		return new Commentaire($req->fetch(PDO::FETCH_ASSOC));
	}
	public function exist($id){
		$req= $this->db->prepare('select * from Commentaire where Id_Commentaire = ?');
		$req->execute(array($id));
		return (bool) $req->fetch();
	}


	public function selectAllCommentaires(){
		$req = $this->db->query('select * from Commentaire');
		$commentaires = array();
		
		while($com = $req->fetch(PDO::FETCH_ASSOC))
			$commentaires[] = new Commentaire($com);
		return $commentaires;
	}
	
	
	public function modifyCommentaire($com){
		$req = $this->db->prepare('update Commentaire set Contenu = ? where Id_Commentaire = ?');
		$req->execute(array($com['Contenu'], $com['Id_Commentaire']));
	}
	
	public function addCommentaire($com){
		$req = $this->db->prepare('insert into Commentaire values (\'\',?)');
		$req->execute(array($com));
		return $this->db->lastInsertId();
	}
	
	public function getPertinence($id){
		$req = $this->db->prepare('select * from Pertinence where Id_Commentaire = ?');
		$req->execute(array($id));
		$evaluations = array();
		while($evaluation = $req->fetch(PDO::FETCH_ASSOC))
			$evaluations[] = $evaluation;
			
		return $evaluations;
	}
	public function deleteCommentaire($id){
		$req = $this->db->prepare('delete from Commentaire where Id_Commentaire = ?');
	$req->execute(array($id));
}
	
	public function addPertinence($pertinence){
		$req= $this->db->prepare('insert into Pertinence values (?,?,?)');
		$req->execute(array($pertinence['Id_Commentaire'], $pertinence['Id_Joueur'], $pertinence['Valeur']));
	}
	
	public function isowner($id_commentaire, $id_joueur){
		$req = $this->db->prepare('select Commentaire.Contenu from Note, Commentaire where Note.Id_Joueur = ? and Note.Id_Commentaire = ?');
		$req->execute(array($id_joueur, $id_commentaire));
		return (bool) $req->fetch();
	}
	
	public function alreadyNoted($id_joueur, $id_commentaire){
		$req = $this->db->prepare('select * from Pertinence P where P.Id_Joueur = ? and P.Id_Commentaire = ?');
		$req->execute(array($id_joueur, $id_commentaire));
		return (bool) $req->fetch();
	}
	
	public function likedCommentaire($id_commentaire, $like){
		$req= $this->db->prepare('select * from Pertinence where Id_Commentaire = ? and Valeur = ?');
		$req->execute(array($id_commentaire, $like));
		
		$pertinence = array();
		while($perti = $req->fetch(PDO::FETCH_ASSOC))
				$pertinence[] = $perti;
		
		return $pertinence;
	}
	
	public function deletePertinenceJoueur($id){
		$req = $this->db->prepare('delete from Pertinence where Id_Joueur = ?');
		$req->execute(array($id));
	}
	public function deletePertinenceCommentaire($id){
		$req = $this->db->prepare('delete from Pertinence where Id_Commentaire = ?');
		$req->execute(array($id));
	}
	
	
	
	
}
