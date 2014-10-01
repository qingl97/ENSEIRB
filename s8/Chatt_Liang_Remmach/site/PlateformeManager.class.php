<?php

	class PlateformeManager {
		private $db;
		
		public function __construct($db){
			$this->db = $db; }
			
		public function exist($info){
			if(is_int($info)){
		$req = $this->db->prepare('select * from Plateforme where Id_Plateforme = ?');
		$req->execute(array($info));
		return (bool) $req->fetch();
	}
	else{
			$req = $this->db->prepare('select * from Plateforme where Nom_Plateforme = ?');
		$req->execute(array($info));
		return (bool) $req->fetch();
		}
	}
		public function addPlateforme($plateforme){
			$req = $this->db->prepare('insert into Plateforme values(\'\',?)');
			$req->execute(array($plateforme));
		}
		
		public function deletePlateforme($id){
			$req = $this->db->prepare('delete * from Plateforme where Id_Plateforme = ?');
			$req->execute(array($id));
		}
		
		public function modifyPlateforme($plateforme){
			$req = $this->db->prepare('update Plateforme set Nom_Plateforme = ? where Id_Plateforme = ?');
			$req->execute(array($plateforme['Nom_Plateforme'], $plateforme['Id_Plateforme']));
		}
		public function selectPlateforme($id){
			$req = $this->db->prepare('select * from Plateforme where Id_Plateforme = ? ');
			$req->execute(array($id));
			$donne = $req->fetch(PDO::FETCH_ASSOC);
			return new Plateforme($donne);
		}
		public function selectAllPlateformes(){
			$plateformes = array();
			$req = $this->db->query('select * from Plateforme');
			
			while($donnees = $req->fetch(PDO::FETCH_ASSOC))
				$plateformes[] = new Plateforme($donnees);
			return $plateformes;
		}
		
		
}
