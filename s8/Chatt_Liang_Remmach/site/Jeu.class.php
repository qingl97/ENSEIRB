<?php
	class Jeu{
		protected $id;
		protected $nom;
		protected $date_parution;
		protected $id_plateforme;
		protected $id_editeur;
		protected $img;
		
		
//---------------constructeur---------------------//

public function __construct(array $donnees)
{
		$this->hydrate($donnees);
	}

//---------------hydratation-------------------//

public function hydrate($donnees){
	//les id sont attribué par la base de données. La première fois qu'on instancie un jeu introduit
	// par un utilisateur on ne les connait pas donc on ne les donne pas dans l'array $donnees
	// il faut alors vérifier si elles existent avant de les utiliser.
	if(isset($donnees['Id_Jeu']))
		$this->setId($donnees['Id_Jeu']);
	if (isset($donnees['Id_Plateforme']))
		$this->setId_plateforme($donnees['Id_Plateforme']);
	if (isset($donnees['Id_Editeur']))
		$this->setId_editeur($donnees['Id_Editeur']);
	$this->setNom($donnees['Nom_Jeu']);
	$this->setDate_parution($donnees['Date_Parution']);
	$this->setImg($donnees['img']);
	}
		

//--------------------getters------------------------------------//
		public function getId(){ return $this->id;}
		public function getNom(){ return $this->nom;}
		public function getDate() { return $this->date_parution;}
		public function getId_plateforme() { return $this->id_plateforme;}
		public function getId_editeur(){ return $this->id_editeur;}
		public function getImg(){return $this->img;}
		
//--------------------setters------------------------------------//

		public function setId($id) { $this->id = $id;}
		public function setNom($nom) {$this->nom = $nom;}
		public function setDate_parution($date) { $this->date_parution = $date;}
		public function setId_plateforme($id_plateforme) {$this->id_plateforme = $id_plateforme;}
		public function setId_editeur($id_editeur) { $this ->id_editeur = $id_editeur;}
		public function setImg($img) {$this->img = $img;}
		
		
		
		
}
					
