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
$noteManage = new NoteManager($db);
$commentaireManage = new CommentaireManager($db);
 $utils = new Util($db);
 $jeuManage = new JeuManager($db);
$categorieManage = new CategorieManager($db);
$editeurManage = new EditeurManager($db);
$plateformeManage = new PlateformeManager($db);
/////
/*
function deletenote($note, $commentaireManage, $noteManage){
		$commentaireManage->deletePertinenceCommentaire($note->getId_commentaire());
		$id = $note->getId_commentaire();
		$idnote = $note->getId_note();
		$noteManage->deleteNote($idnote);
		$commentaireManage->deleteCommentaire($id);
	}
 */


if(isset($_SESSION['id']) && isset($_SESSION['password']) && isset($_SESSION['pseudo']) && $joueurManage->joueurConnect($_SESSION['pseudo'], $_SESSION['password'])){
	
	
	if(isset($_POST['addComment']))
		{
			$error=0;
			if(!isset($_SESSION['id_jeu'])){
				echo 'aucun jeu spécifié';
				$error++;}
			if(!isset($_POST['commentaire']) || empty($_POST['commentaire'])){
				$error++;
				echo ' mauvais commentaire';
			}
			if(!isset($_POST['note']) || empty($_POST['note']) || !is_int((int)$_POST['note']) || !$utils->valid((int) $_POST['note'])){
				$error++;
				echo 'erreur de note';
			}
			$id_com = $commentaireManage->addCommentaire(htmlspecialchars($_POST['commentaire']));
			
			if($error == 0){
				$note = array('Id_Joueur'=>$_SESSION['id'],'Id_Jeu'=>$_SESSION['id_jeu'],'Id_Commentaire'=>$id_com,'Note'=>$_POST['note']);
				$noteManage->addNote($note);
				echo 'ajout dans la base';
			}
			print_r($note);
		}
	if(isset($_GET['rouge']) && isset($_GET['id_commentaire']) && $commentaireManage->exist($_GET['id_commentaire']) && 
	!$commentaireManage->isowner($_GET['id_commentaire'],$_SESSION['id']) 
	&& !$commentaireManage->alreadyNoted($_SESSION['id'],$_GET['id_commentaire'])){
		echo 'rouge ok';
		$pertinence = array('Valeur'=>-1,'Id_Commentaire'=>$_GET['id_commentaire'], 'Id_Joueur'=>$_SESSION['id']);
		$commentaireManage->addPertinence($pertinence);
	}
		
		if(isset($_GET['vert']) && isset($_GET['id_commentaire']) && $commentaireManage->exist($_GET['id_commentaire']) && 
	!$commentaireManage->isowner($_GET['id_commentaire'],$_SESSION['id']) 
	&& !$commentaireManage->alreadyNoted($_SESSION['id'],$_GET['id_commentaire'])){
		$pertinence = array('Valeur'=>1,'Id_Commentaire'=>$_GET['id_commentaire'], 'Id_Joueur'=>$_SESSION['id']);
		$commentaireManage->addPertinence($pertinence);
	
	
	
	}
	
	if(isset($_GET['delete']) && $jeuManage->exist((int) $_GET['delete']) && $_SESSION['pseudo'] == 'root')
		$jeuManage->deleteJeu($_GET['delete']);
	
	
	if(isset($_POST['modifyComment']) && isset($_POST['id']) && isset($_POST['commentaire']) && ($commentaireManage->isowner($_POST['id'], $_SESSION['id']) || $_SESSION['pseudo'] == 'root')){
		$com = array('Id_Commentaire'=>$_POST['id'], 'Contenu'=>$_POST['commentaire']);
		$commentaireManage->modifyCommentaire($com);
	}
	if(isset($_GET['deleteNote']) && $noteManage->exist((int)$_GET['deleteNote'])){
		$note = $noteManage->selectNote($_GET['deleteNote']);
		if($commentaireManage->isowner($note->getId_commentaire(),$_SESSION['id']) || $_SESSION['pseudo']=='root')
			$noteManage->delete($note, $commentaireManage);
		}
		
	if(isset($_POST['modifyJeu']) && $_SESSION['pseudo'] == 'root' && isset($_POST['id']) && $jeuManage->exist((int) $_POST['id'])){
		$error = 0;
		//préparation des catégorie.
		$categoriesSelected = array();
		$categories = $categorieManage->selectAllCategories();
      foreach($categories as $cate)
		if(isset($_POST[$cate->getCategorie()]))
			$categoriesSelected[] = $cate->getId();
		if(count($categoriesSelected)==0)
			$error++;
		if(!isset($_POST['plateforme']) || !isset($_POST['date']) || !isset($_POST['editeur']) || !isset($_POST['nom']))
			$error++;
		if($error == 0){
			$categorieManage->deleteCategoriesJeu($_POST['id']);
			
			$newJeu = array('Id_Jeu'=>$_POST['id'],'Nom_Jeu'=>$_POST['nom'],'Date_Parution'=>$_POST['date'],'Id_Editeur'=>$_POST['editeur'],'Id_Plateforme'=>$_POST['plateforme'],'img'=>'sample.jpg');
			$jeuManage->modifyJeu($newJeu);
			foreach ($categoriesSelected as $catego)
					$categorieManage->addCategorieJeu($_POST['id'], $catego);
			
			
	}
}
	
	if(isset($_POST['addJeu']) && $_SESSION['pseudo'] == 'root' ){
		
		$error = 0;
		//préparation des catégorie.
		$categoriesSelected = array();
		$categories = $categorieManage->selectAllCategories();
      foreach($categories as $cate)
		if(isset($_POST[$cate->getCategorie()]))
			$categoriesSelected[] = $cate->getId();
		if(count($categoriesSelected)==0)
			$error++;
		if(!isset($_POST['plateforme']) || !isset($_POST['date']) || !isset($_POST['editeur']) || !isset($_POST['nom']))
			$error++;
		if($error == 0){
			
			$newJeu = array('Nom_Jeu'=>$_POST['nom'],'Date_Parution'=>$_POST['date'],'Id_Editeur'=>$_POST['editeur'],'Id_Plateforme'=>$_POST['plateforme'],'img'=>'sample.jpg');
			$id=$jeuManage->addJeu($newJeu);
			foreach ($categoriesSelected as $catego)
					$categorieManage->addCategorieJeu($id, $catego);
			
		}	
	}
	
	if(isset($_POST['categorieAdd']) && !$categorieManage->exist($_POST['categorieAdd'])){
		$categorieManage->addCategorie($_POST['categorieAdd']);
	}

if(isset($_POST['editeurAdd']) && !$editeurManage->exist($_POST['editeurAdd'])){
		$editeurManage->addediteur($_POST['editeurAdd']);
	}
	
	if(isset($_POST['plateformeAdd']) && !$plateformeManage->exist($_POST['plateformeAdd'])){
		$plateformeManage->addplateforme($_POST['plateformeAdd']);
	}

}




		header('Location: '.$_SERVER['HTTP_REFERER']);
	
	

	
	
