<?php

class JoueurManager {
	
	private $db;
	
	public function __construct($db){
		$this->db = $db;
	}
	
	public function exist($info){
		if(is_int($info)){
		$req = $this->db->prepare('select * from Joueur where Id_Joueur = ?');
		$req->execute(array($info));
		return (bool) $req->fetch();
	}
	else{
			$req = $this->db->prepare('select * from Joueur where Nom_Joueur = ?');
		$req->execute(array($info));
		return (bool) $req->fetch();
		}
	}
	
	public function pseudoUtilise($pseudo){
		$req = $this->db->prepare('select * from Joueur where Pseudo_Joueur = ?');
		$req->execute(array($pseudo));
		return (bool) $req->fetch();
	}
	
	


	public function count(){
		return $this->db->query('select count(*) from Joueur')->fetchcolumn();
	}
	
	public function modifyJoueur($joueur){
		print_r($joueur);
		$req = $this->db->prepare('update Joueur set Nom_Joueur = ?, Pseudo_joueur = ?, Prenom_Joueur = ?, Email_Joueur = ?, Id_Plateforme = ?, Id_Categorie = ? where Id_joueur = ?');
		$req->execute(array($joueur['Nom_Joueur'],$joueur['Pseudo_Joueur'],$joueur['Prenom_Joueur'],$joueur['Email_Joueur'],$joueur['Id_Plateforme'],$joueur['Id_Categorie'],$joueur['Id_Joueur']));
	}
	
	public function deleteJoueur($id){
		$req = $this->db->prepare('delete from Joueur where Id_joueur = ?');
		$req->execute(array($id));
	}
	
	public function addJoueur($joueur){
		$req = $this->db->prepare('insert into Joueur values(\'\',?,?,?,?,?,?,?)');
		$req->execute(array($joueur['Pseudo_Joueur'], $joueur['Nom_Joueur'], $joueur['Prenom_Joueur'], $joueur['Email_Joueur'], $joueur['Id_Plateforme'], $joueur['Id_Categorie'],$joueur['password']));
	}
	
	public function selectJoueurList(){
		$req = $this->db->query('(select * from 
((select Joueur.*,count(*) as nb from Joueur,Note where Joueur.Id_Joueur = Note.Id_Joueur group by Pseudo_Joueur order by nb asc)
union
(select Joueur.*,0 as nb from Joueur where Id_Joueur not in ( select Id_Joueur from Note))) as T
order by nb desc);');
		$joueurs = array();
		
		while($donnees = $req->fetch(PDO::FETCH_ASSOC))
			$joueurs[] = new Joueur($donnees);
		return $joueurs;
	}
	
	
	
	public function selectJoueur($id){
		$req = $this->db->prepare('select * from Joueur where Id_Joueur = ?');
		$req->execute(array($id));
		$joueur = new Joueur($req->fetch(PDO::FETCH_ASSOC));
		return $joueur;
	}	
	
	public function selectJoueurPseudo($pseudo){
		$req = $this->db->prepare('select * from Joueur where Pseudo_Joueur = ?');
		$req->execute(array($pseudo));
		$joueur = new Joueur($req->fetch(PDO::FETCH_ASSOC));
		return $joueur;
	}	
	
	public function joueurConnect($pseudo, $password){
		$req = $this->db->prepare('select * from Joueur where Pseudo_Joueur = ? and password = ?');
		$req->execute(array($pseudo,$password));
		return (bool) $req->fetch();
	}
	
	public function getPseudo($id){
		$req = $this->db->prepare('select Pseudo_Joueur from Joueur where Id_Joueur = ?');
		$req->execute(array($id));
		$pseudo =$req->fetch(PDO::FETCH_ASSOC);
		return $pseudo['Pseudo_Joueur'];
	}

	
	
	
	
	
}
























