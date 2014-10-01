<?php
session_start();
function chargerClasse($classname)
{
  require $classname.'.class.php';
}
 
spl_autoload_register('chargerClasse');

$pdo = new PDOFactory();
$db = $pdo->get_db();

$joueurManage = new JoueurManager($db);
if(isset($_SESSION['id']) && isset($_SESSION['password']) && isset($_SESSION['pseudo']) && $joueurManage->joueurConnect($_SESSION['pseudo'], $_SESSION['password']))
	$joueur = $joueurManage->selectJoueur($_SESSION['id']);
$noteManage = new NoteManager($db);
$jeuManage =  new JeuManager($db);
$categorieManage = new CategorieManager($db);
$editeurManage = new EditeurManager($db);
$plateformeManage = new PlateformeManager($db);
$util = new Util($db);
$commentaireManage = new CommentaireManager($db);

?>



<!DOCTYPE html>

<html>
	<head>
	<meta charset="utf-8"/>	
	<link rel="stylesheet" href="style.css" />
	<!--[if lt IE 9]>
            <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
	<title>Jeu</title>
	</head>

	<body>
		<div id="conteneur">
	<header>
		
	</header>
	<nav>	
	<ul class="menu">
	<a class="lienMenu" href="index.php" ><li class="button">Accueil</li></a>
<a class="lienMenu" href="statistiques.php" ><li class="button">Statistiques</li></a>
	<a class ="lienMenu" href="joueur.php" ><li class="button">Joueurs</li></a>
		<a  class="lienMenu" href="jeux.php"><li class = "button" >Jeux</li></a>
<?php if(!isset($joueur)){?>
	<a class="lienMenu" href="connexion.php" ><li class="button">Connexion</li></a>
	<a class="lienMenu" href="ajouterJoueur.php" ><li class="button">Inscription</li></a>
	<?php } else{
	?>
		<a class="lienMenu" href="joueurControl.php?deconnexion" ><li class="button">Deconnexion</li></a>
				<a class="lienMenu" href="profil.php" ><li class="button">Profil: <?php echo $_SESSION['pseudo']?></li></a>
<?php } ?>
	</ul>
	</nav>
	<section>
   <p>
	   <?php
	   if(isset($_GET['id']) && $jeuManage->exist((int) $_GET['id']) && isset($joueur)) { 
		   $jeu = $jeuManage->selectJeu((int)$_GET['id']);
		   $_SESSION['id_jeu']=$_GET['id'];
		   $editeur = $editeurManage->selectEditeur($jeu->getId_editeur());
		   $plateforme = $plateformeManage->selectPlateforme($jeu->getId_plateforme());
		   ?>
		   <!-- les informations sur le jeu -->
	   <fieldset>
	  <h3 class="titreJeu"><?php echo $jeu->getNom(); ?></h3>
	 <p> <img class="imgJeu" src="<?php echo $jeu->getImg(); ?>" /> </br>
		<strong>Date de parution : <?php echo $jeu->getDate();?></strong></br>
		<strong>Editeur : <?php echo $editeur->getEditeur();?></strong></br>
		<strong>Plateforme : <?php echo $plateforme->getPlateforme();?></strong></br>
		<strong>Categorie(s) : <?php $categories = $categorieManage->selectCategoriesJeu($jeu->getId()); foreach($categories as $categorie) echo $categorie['Nom_Categorie'].'  '; ?></strong></br>
		<strong> Note des joueurs : <?php $note =  $noteManage->moyenneNote($_GET['id']); echo $note['note'];?></strong></br>
		<?php if($_SESSION['pseudo']=='root')
			echo '<a href="ajouterModifierJeu.php?id='.$_GET['id'].'"/>Cliquez ici pour modifier le jeu</a>';?>
	  </p>
		</fieldset>
		<!-- les notes sur le jeu -->
		<div>
		<?php
		
		$notes = $noteManage->selectAllNotesJeu($_GET['id']);
		foreach($notes as $note){ ?>
		<div class="note"><fieldset>
		<p><strong>Joueur : </strong><?php echo $joueurManage->selectJoueur($note->getId_joueur())->getPseudo();?>. </br>
			<strong>Note :</strong> <?php echo $note->getNote(); ?>/20 .</br>
			<strong>Date :</strong> <?php echo $note->getDate_note(); ?> .</br>
			<?php $commentaire = $commentaireManage->selectCommentaire($note->getId_commentaire());
			$rouge = $commentaire->rouge($commentaireManage);
			$vert = $commentaire->vert($commentaireManage);
				echo '<div class="comm"> '.$commentaire->getContenu().'</div>'; ?> 
		
		</p>
		<div class="jugement"> <a class="lienMenu" href="jeuControl.php?rouge&id_commentaire=<?php echo $commentaire->getId_commentaire();?>"> <img src="pouce_rouge.png"/> </a>
		<a href="likedcommentaire.php?rouge=<?php echo $commentaire->getId_commentaire();?>" class="lienMenu"/><span class="rouge" ><?php echo $rouge;?></span></a>  &nbsp;&nbsp; 
		<a class="lienMenu" href="jeuControl.php?vert&id_commentaire=<?php echo $commentaire->getId_commentaire();?>"><img src="pouce_vert.png"  /> </a>
		<a href="likedcommentaire.php?vert=<?php echo $commentaire->getId_commentaire();?>" class="lienMenu"/><span class="vert"><?php echo $vert;?></span></a>
		<span>Confiance : <?php echo $util->indice_confiance($rouge, $vert);?> </span>
		<?php if($commentaireManage->isowner($commentaire->getId_commentaire(), $_SESSION['id']) || $_SESSION['pseudo']=='root'){
			?>
			<a href="jeuControl.php?deleteNote=<?php echo $note->getId_note();?>"><img src="delete.png" alt="supprimer"/></a>
			<form method ="post" action="jeuControl.php">
		 <textarea name="commentaire" rows="4" cols="30">Modifiez le commentaire.</textarea> </br>
		<input type="hidden" name="modifyComment" />
		<input type="hidden" name="id" value="<?php echo $commentaire->getId_commentaire(); ?>"/>
		<input type="submit" value="valider" /> </br>
		</form>
		<?php }?>
		</div>
		</fieldset></div>
		<?php } 
		if(!$noteManage->aNote($_SESSION['id'], $jeu->getId())) { ?>
		<p>
			<h4>Donnez une note au jeu.</h4>
			<?php $_SESSION['id_jeu'] = $jeu->getId(); ?>
		<form method ="post" action="jeuControl.php">
		<label>Votre Note sur 20</label> </br>	 <input type="text" name="note" /> </br>
		 <textarea name="commentaire" rows="10" cols="50">Tapez votre commentaire ici.</textarea> </br>
		<input type="hidden" name="addComment" />
		<input type="submit" value="valider" /> </br>
		</form>
		<?php } } ?>
		</p>
		
		</div>
		
   

	

	
	</section>
	<footer>
		
	</footer>
	</div>
	</body>
</html>
