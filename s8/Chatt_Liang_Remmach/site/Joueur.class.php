		<?php
			class Joueur {
				protected $id;
				protected $pseudo;
				protected $nom;
				protected $prenom;
				protected $email;
				protected $id_plateforme;
				protected $id_categorie;
				protected $password;
				
				public function __construct(array $donnees){
						$this->hydrate($donnees);
					}
				public function getPassword(){return $this->password;}
				public function getId(){ return $this->id;}
				public function getPseudo(){ return $this->pseudo;}
				public function getNom(){ return $this->nom;}
				public function getPrenom(){ return $this->prenom;}
				public function getEmail(){ return $this->email;}
				public function getId_plateforme(){ return $this->id_plateforme;}
				public function getId_categorie(){ return $this->id_categorie;}

				public function setPassword($password) {$this->password = $password;}
				public function setId($id){ $this->id = (int) $id;}
				public function setPseudo($pseudo){ $this->pseudo = $pseudo;}
				public function setNom($nom){ $this->nom = $nom;}
				public function setPrenom($prenom){ $this->prenom = $prenom;}
				public function setEmail($email){ $this->email = $email;}
		public function setId_plateforme($id){ $this->id_plateforme = (int) $id;}
		public function setId_categorie($id){ $this->id_categorie = (int) $id;}

		 public function hydrate(array $donnees)
		  {
			 if (isset($donnees['Id_Joueur']))
				$this->setId($donnees['Id_Joueur']);
			$this->setPseudo($donnees['Pseudo_Joueur']);	
			$this->setNom($donnees['Nom_Joueur']);
			$this->setPrenom($donnees['Prenom_Joueur']);
			$this->setEmail($donnees['Email_Joueur']);
			if(isset($donnees['Id_Plateforme']))
				$this->setId_plateforme($donnees['Id_Plateforme']);
			if(isset($donnees['Id_Categorie']))
				$this->setId_categorie($donnees['Id_Categorie']);
		 $this->setPassword($donnees['password']);
		}
		
	
		public function joueur2array($joueur){
			$player = array('id'=>$joueur->getId(),'pseudo'=>$joueur->getPseudo(), 'nom'=>$joueur->getNom(), 'prenom'=>$joueur->getPrenom(), 'email'=>$joueur->getEmail(),'id_plateforme'=>$joueur->getId_plateforme(), 'id_categorie'=>$joueur->getId_categorie(),'password'=>$joueur->password);
			return $player;
		}
	}
