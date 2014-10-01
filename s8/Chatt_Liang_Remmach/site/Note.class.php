<?php

class Note{
	
	protected $id_joueur;
	protected $id_jeu;
	protected $id_commentaire;
	protected $id_note;
	protected $note;
	protected $date_note;
	
	
	public function __construct(array $donnees){
		$this->hydrate($donnees);
	}
	
	
	//Getters
	public function getId_joueur() { return $this->id_joueur;}
	public function getId_commentaire() { return $this->id_commentaire;}
	public function getId_jeu(){return $this->id_jeu;}
	public function getId_note() { return $this->id_note;}
	public function getNote() { return $this->note;}
	public function getDate_note() { return $this->date_note;}
	
	
	//Setters
	public function setId_joueur($id_joueur) {  $this->id_joueur=$id_joueur;}
	public function setId_commentaire($id_commentaire) {  $this->id_commentaire=$id_commentaire;}
	public function setId_jeu($id_jeu){ $this->id_jeu=$id_jeu;}
	public function setId_note($id_note) {  $this->id_note=$id_note;}
	public function setNote($note) {  $this->note=$note;}
	public function setDate_note($date_note) {  $this->date_note=$date_note;}
	
	
	public function hydrate(array $donnees){
		$this->setId_joueur($donnees['Id_Joueur']);
		$this->setId_jeu($donnees['Id_Jeu']);
		$this->setId_note($donnees['Id_Note']);
		$this->setId_commentaire($donnees['Id_Commentaire']);
		$this->setNote($donnees['Note']);
		$this->setDate_note($donnees['Date_Note']);
	
	}
	
	public function note2array(){
		$note_array = array('id_joueur'=>$this->getId_joueur(), 'id_jeu'=>$this->getId_jeu(), 'id_note'=>$this->getId_note(), 'id_commentaire'=>$this->getId_commentaire(), 'note'=>$this->getId_note(), 'date_note'=>$this->getDate_note());
		return $note_array;
	}
	
	
}
