<?php


	class EditeurManager{
		protected $db;
		
		public function __construct($db){
			$this->db = $db;}
			
			
			public function exist($info){
			if(is_int($info)){
		$req = $this->db->prepare('select * from Editeur where Id_Editeur = ?');
		$req->execute(array($info));
		return (bool) $req->fetch();
	}
	else{
			$req = $this->db->prepare('select * from Editeur where Nom_Editeur = ?');
		$req->execute(array($info));
		return (bool) $req->fetch();
		}
	}
		public function addEditeur($Editeur){
			$req = $this->db->prepare('insert into Editeur values(\'\',?)');
			$req->execute(array($Editeur));
		}
		
		public function deleteEditeur($id){
			$req = $this->db->prepare('delete * from Editeur where Id_Editeur = ?');
			$req->execute(array($id));
		}
		
		public function modifyEditeur($Editeur){
			$req = $this->db->prepare('update Editeur set Nom_Editeur = ? where Id_Editeur = ?');
			$req->execute(array($Editeur['Nom_Editeur'], $Editeur['Id_Editeur']));
		}
		public function selectEditeur($id){
			$req = $this->db->prepare('select * from Editeur where Id_Editeur = ? ');
			$req->execute(array($id));
			$donne = $req->fetch(PDO::FETCH_ASSOC);
			return new Editeur($donne);
		}
		public function selectAllEditeurs(){
			$Editeurs = array();
			$req = $this->db->query('select * from Editeur');
			
			while($donnees = $req->fetch(PDO::FETCH_ASSOC))
				$Editeurs[] = new Editeur($donnees);
			return $Editeurs;
		}
}
		
			
