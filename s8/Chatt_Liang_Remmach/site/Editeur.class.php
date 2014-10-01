<?php 

	class Editeur{
		protected $id;
		protected $nom_editeur;
		
		
		
		
		public function __construct($donnees){
			$this->hydrate($donnees);}
			
		public function getId() { return $this->id;}
		public function getEditeur() { return $this->nom_editeur;}
		
		
		public function setId($id) { $this->id = $id;}
		public function setEditeur($nom_editeur) { $this->nom_editeur = $nom_editeur;}
		
		
		
		
		public function hydrate($donnees){
			$this->setId($donnees['Id_Editeur']);
			$this->setEditeur($donnees['Nom_Editeur']);
		}
		
		
	}
		
