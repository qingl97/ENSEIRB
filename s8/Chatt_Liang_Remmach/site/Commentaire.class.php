<?php

class Commentaire {
	
	private $id_commentaire;
	private $contenu;
	
	
	public function __construct($donnees){
		$this->hydrate($donnees);
	}
	
	
	public function hydrate($donnees){
		if(isset($donnees['Id_Commentaire']))
				$this->id_commentaire = $donnees['Id_Commentaire'];
		$this->contenu = $donnees['Contenu'];
	}
	
	public function getId_commentaire() { return $this->id_commentaire;}
	public function getContenu() { return $this->contenu; }
	
	
	public function setId_commentaire($id_commentaire) { $this->id_commentaire = $id_commentaire;}
	public function setContenu($contenu) { $this->contenu = $contenu; }
	
	
	
	
	public function evaluation($manager){
		$evaluations = $manager->getPertinence($this->id_commentaire);
		$bon=0;
		$mauvais =0;
		foreach($evaluations as $evaluation){
			if($evaluation['Valeur'] ==1)
				$bon++;
			else
				$mauvais--;
			}
		return (1+$bon)/(1+$mauvais);
	}
	
	public function vert($manager){
		$evaluations = $manager->getPertinence($this->id_commentaire);
		$bon=0;
		foreach($evaluations as $evaluation)
			if($evaluation['Valeur'] ==1)
				$bon++;
		return $bon;
	}
	
	public function rouge($manager){
		$evaluations = $manager->getPertinence($this->id_commentaire);
		$rouge=0;
		foreach($evaluations as $evaluation)
			if($evaluation['Valeur'] ==-1)
				$rouge++;
		return $rouge;
	}
	
}
	
