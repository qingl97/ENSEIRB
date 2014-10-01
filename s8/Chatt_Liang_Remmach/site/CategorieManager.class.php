<?php

	class CategorieManager {
		private $db;
		
		public function __construct($db){
			$this->db = $db; }
			
		public function exist($info){
			if(is_int($info)){
		$req = $this->db->prepare('select * from Categorie where Id_Categorie = ?');
		$req->execute(array($info));
		return (bool) $req->fetch();
	}
	else{
			$req = $this->db->prepare('select * from Categorie where Nom_Categorie = ?');
		$req->execute(array($info));
		return (bool) $req->fetch();
		}
	}
		public function addCategorie($categorie){
			$req = $this->db->prepare('insert into Categorie values(\'\',?)');
			$req->execute(array($categorie));
		}
		
		public function deleteCategorie($id){
			$req = $this->db->prepare('delete * from Categorie where Id_Categorie = ?');
			$req->execute(array($id));
		}
		
		public function modifyCategorie($categorie){
			$req = $this->db->prepare('update Categorie set Nom_Categorie = ? where Id_Categorie = ?');
			$req->execute(array($categorie['Nom_Categorie'], $categorie['Id_Categorie']));
		}
		public function selectCategorie($id){
			$req = $this->db->prepare('select * from Categorie where Id_Categorie = ? ');
			$req->execute(array($id));
			$donne = $req->fetch(PDO::FETCH_ASSOC);
			return new Categorie($donne);
		}
		public function selectAllCategories(){
			$categories = array();
			$req = $this->db->query('select * from Categorie');
			
			while($donnees = $req->fetch(PDO::FETCH_ASSOC))
				$categories[] = new Categorie($donnees);
			return $categories;
		}
		
		public function selectCategoriesJeu($id){
			$req = $this->db->prepare('select C.Nom_Categorie from Categorie C, Categories_Jeu CJ where CJ.Id_Jeu = ? and CJ.Id_Categorie = C.Id_Categorie');
			$req->execute(array($id));
			$categories = array();
			
			while($categorie = $req->fetch(PDO::FETCH_ASSOC))
				$categories[]=$categorie;
				
			return $categories;
			
		}
		public function deleteCategoriesJeu($id){
			$req = $this->db->prepare('delete from Categories_Jeu where Id_Jeu =?');
			$req->execute(array($id));
		}
		
		public function addCategorieJeu($id_jeu, $id_categorie){
			$req = $this->db->prepare('insert into Categories_Jeu values( :cate, :jeu )');
			$req->bindParam(':cate',$id_categorie, PDO::PARAM_INT);
			$req->bindParam(':jeu',$id_jeu, PDO::PARAM_INT);
			echo $id_categorie;
			$req->execute();
		}
		
		
}
