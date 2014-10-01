<?php




class Util{
	
	 private $db;
	
	public function __construct($db){
		$this->db = $db;}


	public function is_email($email){
			return preg_match("#^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]{2,}\.[a-zA-Z]{2,4}$#",$email);
		}
	public function indice_confiance($rouge, $vert){
		return (1+$vert)/(1+$rouge);
	}

	public function valid($note){
		if($note <=20 && $note >=0)
			return true;
		return false;
	}
}
