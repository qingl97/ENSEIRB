<?php
session_start();

	function chargerClasse($classname)
{
  require $classname.'.class.php';
}
 
spl_autoload_register('chargerClasse');

$pdo = new PDOFactory();
$db = $pdo->get_db();

$joueurManage =  new JoueurManager($db);
 $utils = new Util($db);
 if(isset($_SESSION['id']) && isset($_SESSION['password']) && isset($_SESSION['pseudo']) && $joueurManage->joueurConnect($_SESSION['pseudo'], $_SESSION['password'])){
	$joueur = $joueurManage->selectJoueur($_SESSION['id']);
	//suppresion d'un joueur
	if(isset($_GET['delete']) && $joueurManage->exist((int) $_GET['delete']) && $_SESSION['pseudo']=='root'){
		$joueurManage->deleteJoueur((int) $_GET['delete']);
		header('Location: joueur.php');
	}



	//Modification d'un joueur
	if(isset($_POST['modify']) && isset($_POST['id']) && ($_POST['id'] == $_SESSION['id'] || $_SESSION['pseudo']=='root'))
	{
		$error =0;
		if(isset($_POST['id']) && $joueurManage->exist((int)$_POST['id']))
		{
			$jou = $joueurManage->selectJoueur($_POST['id']);
		}
		else{
			$error++;
		}
		if(!isset($_POST['nom']) || empty($_POST['nom'])){
			echo '<p>Nom manquant !</p>';
			$error++;
		}
		if(!isset($_POST['prenom']) || empty($_POST['prenom'])){
			echo '<p>Prenom manquant !</p>';
			$error++;
		}
		if(!isset($_POST['email']) || !$utils->is_email($_POST['email'])){
			echo '<p>Email manquant ou invalide!</p>'.$_POST['email'];
			$error++;
		}
		if(!isset($_POST['plateforme'])|| empty($_POST['plateforme'])){
			echo '<p>Plateforme manquante !</p>';
			$error++;
		}
		if(!isset($_POST['categorie']) || empty($_POST['categorie'])){
			echo '<p>Categorie manquante !</p>';
			$error++;
		}
		if($error == 0){
			$_POST['nom'] =htmlspecialchars($_POST['nom']);
			$_POST['prenom'] = htmlspecialchars($_POST['prenom']);
			$_POST['email']=htmlspecialchars($_POST['email']);
			$_POST['plateforme'] =$_POST['plateforme'];
			$_POST['categorie'] =$_POST['categorie'];
			$donnees = array('Id_Joueur'=>$jou->getId(),'Pseudo_Joueur'=>$jou->getPseudo(), 'Nom_Joueur'=>$_POST['nom'], 'Prenom_Joueur'=>$_POST['prenom'], 'Email_Joueur'=>$_POST['email'], 'Id_Plateforme'=>$_POST['plateforme'], 'Id_Categorie'=>$_POST['categorie']);
			$joueurManage->ModifyJoueur($donnees);
			echo '<p>Joueur modifié dans la base de données <a href="joueur.php">Cliquez ici pour revenir</a>.</p>';
			print_r($donnees);
			}
		else
			echo'<p>des erreurs se sont produites vérifiez vos données <a href="joueur.php">ici</a>.</p>';
			
		}
		
	}
		//Ajout d'un nouveau joueur
	
	if(isset($_POST['add']) )
	{
		$error =0;
		if(!isset($_POST['pseudo']) || empty($_POST['pseudo']) || $joueurManage->pseudoUtilise($_POST['pseudo'])){
			echo 'pseudo déja utilisé';
			$error++;}
		if(!isset($_POST['password']) || empty($_POST['password'])){
			echo 'Verifiez vote mot de passe';
			$error++;
		}
		if(!isset($_POST['nom']) || empty($_POST['nom'])){
			echo '<p>Nom manquant !</p>';
			$error++;
		}
		if(!isset($_POST['prenom']) || empty($_POST['prenom'])){
			echo '<p>Prenom manquant !</p>';
			$error++;
		}
		if(!isset($_POST['email']) || empty($_POST['email']) || !$utils->is_email($_POST['email'])){
			echo '<p>Email manquant ou invalide!</p>';
			$error++;
		}
		if(!isset($_POST['plateforme'])|| empty($_POST['plateforme'])){
			echo '<p>Plateforme manquante !</p>';
			$error++;
		}
		if(!isset($_POST['categorie']) || empty($_POST['categorie'])){
			echo '<p>Categorie manquante !</p>';
			$error++;
		}
		if($error == 0){
			$_POST['pseudo'] = htmlspecialchars($_POST['pseudo']);
			$_POST['nom'] =htmlspecialchars($_POST['nom']);
			$_POST['prenom'] = htmlspecialchars($_POST['prenom']);
			$_POST['email']=htmlspecialchars($_POST['email']);
			$_POST['plateforme'] =htmlspecialchars($_POST['plateforme']);
			$_POST['categorie'] =htmlspecialchars($_POST['categorie']);
			$_POST['password'] = sha1($_POST['password']);
			$donnees = array('Pseudo_Joueur'=>$_POST['pseudo'], 'Nom_Joueur'=>$_POST['nom'], 'Prenom_Joueur'=>$_POST['prenom'], 'Email_Joueur'=>$_POST['email'], 'Id_Plateforme'=>$_POST['plateforme'], 'Id_Categorie'=>$_POST['categorie'], 'password'=>$_POST['password']);
			$joueurManage->addJoueur($donnees);
			echo '<p>Joueur Ajouté dans la base de données. Connectez vous ici <a href="connexion.php">ici</a>.</p>';}
		else
			echo 'Erreur des champs sont absents ou mal formulé';
		}
	
	if(isset($_POST['connexion'])){
		$error = 0;
		if(!isset($_POST['pseudo'])){
			echo 'Pseudo manquant';
			$error++;
		}
		
		if(!isset($_POST['password'])){
			echo 'Mot de passe manquant';
			$error++;
		}
		if($error==0 && $joueurManage->joueurConnect($_POST['pseudo'],sha1($_POST['password']))){
			$joueur = $joueurManage->selectJoueurPseudo($_POST['pseudo']);
			$_SESSION['id']= $joueur->getId();
			$_SESSION['password'] = $joueur->getPassword();
			$_SESSION['pseudo'] = $joueur->getPseudo();
			echo 'session ouverte';
			header('Location: index.php');
		}
		else
			echo 'Identifiants incorrects';
		}
		
	if(isset($_GET['deconnexion'])){
		session_destroy();
		header('Location: index.php');
	}
//header('Location: '.$_SERVER['HTTP_REFERER']);
?>
			
			
