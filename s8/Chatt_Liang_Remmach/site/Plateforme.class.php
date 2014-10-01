<?php
class Plateforme {
		
		protected $id;
		protected $nom_plateforme;
		
		public function __construct($plateforme){
			$this->id = $plateforme['Id_Plateforme'];
			$this->nom_plateforme = $plateforme['Nom_Plateforme'];
		}
		
		public function getId() {return $this->id;}
		public function getPlateforme() { return $this->nom_plateforme;}
		
		public function setId($id) { $this->id = $id;}
		public function setPlateforme($nom_plateforme) { $this->nom_plateforme = $nom_plateforme;}
		
}
