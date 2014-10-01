<?php

class PDOFactory{
	//Information de connexion à la base de donnée
	//utilisateur de la base
	private $user = '';
	//mot de pase de l'utilisateur
	private $mdp = '';
	//nom de la base
	private $dbname = '';
	//adresse du serveur Mysql 
	private $host = '';
	
	public function get_db(){
		try
	{
    $bdd = new PDO('mysql:host='.$this->host.';dbname='.$this->dbname,$this->user,$this->mdp);
    $bdd->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_WARNING);
    return $bdd;
	}
	catch(Exception $e)
	{
        die('Erreur : '.$e->getMessage());
	}
	}
	
	
	
	
	
	
}
