<?php
class Categorie {
		
		protected $id;
		protected $nom_categorie;
		
		public function __construct($categorie){
			$this->id = $categorie['Id_Categorie'];
			$this->nom_categorie = $categorie['Nom_Categorie'];
		}
		
		public function getId() {return $this->id;}
		public function getCategorie() { return $this->nom_categorie;}
		
		public function setId($id) { $this->id = $id;}
		public function setCategorie($nom_categorie) { $this->nom_categorie = $nom_categorie;}
		
}
