<?php session_start(); 

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
	<title>Statistiques</title>
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
	<?php if(!isset($_SESSION['id']) || !isset($_SESSION['password'])){?>
	<a class="lienMenu" href="connexion.php" ><li class="button">Connexion</li></a>
	<a class="lienMenu" href="ajouterJoueur.php" ><li class="button">Inscription</li></a>
	<?php } else{
	?>
		<a class="lienMenu" href="joueurControl.php?deconnexion" ><li class="button">Deconnexion</li></a>
		<a class="lienMenu" href="profil.php" ><li class="button">Profil: <?php echo $_SESSION['pseudo'];?></li></a>
<?php } ?>
	</ul>
	</nav>
	<section>
		<?php if(isset($joueur)){?>
	<h2 class="centrage">Page de statistiques</h2>	
	<p>Ici seront présentées les resultats des requêtes statistiques sur la base. </br></p> 
	
	<div>
	<h4 class="centrage">Le commentaire qui laisse le moins indifférent</h4>
		<div class="note"><fieldset>
			<?php 
			
			$id_populaire = $noteManage->populaire();
		
			$populaire = $noteManage->notebycomment($id_populaire['Id_Commentaire']);
			?>
		<p><strong>Joueur : </strong><?php echo $joueurManage->selectJoueur($populaire->getId_joueur())->getPseudo();?>. </br>
			<strong>Note :</strong> <?php echo $populaire->getNote(); ?>/20 .</br>
			<strong>Date :</strong> <?php echo $populaire->getDate_note(); ?> .</br>
			<strong>Jeu: <?php echo $jeuManage->selectJeu($populaire->getId_jeu())->getNom();?></strong>
			<?php $commentaire_p = $commentaireManage->selectCommentaire($populaire->getId_commentaire());
			$rouge = $commentaire_p->rouge($commentaireManage);
			$vert = $commentaire_p->vert($commentaireManage);
				echo '<p>'.$commentaire_p->getContenu().'</p>'; ?> 
		
		</p>
		<div class="jugement"> <a class="lienMenu" href="jeuControl.php?rouge&id_commentaire=<?php echo $commentaire_p->getId_commentaire();?>"> <img src="pouce_rouge.png"/> </a>
		<a href="likedcommentaire.php?rouge=<?php echo $commentaire_p->getId_commentaire();?>" class="lienMenu"/><span class="rouge" ><?php echo $rouge;?></span></a>  &nbsp;&nbsp; 
		<a class="lienMenu" href="jeuControl.php?vert&id_commentaire=<?php echo $commentaire_p->getId_commentaire();?>"><img src="pouce_vert.png"  /> </a>
		<a href="likedcommentaire.php?vert=<?php echo $commentaire_p->getId_commentaire();?>" class="lienMenu"/><span class="vert"><?php echo $vert;?></span></a>
		<span>Confiance : <?php echo $util->indice_confiance($rouge, $vert);?> </span>
		</div>
		</fieldset>
	</div>
	
	<h4 class="centrage">Les derniers commentaires</h4>
	<p> Par défaut les 5 derniers sont affiché mais vous pouvez modifier ce numéro :</p>
	<form method ="post" action="statistiques.php">
		<label>Un numéro N</label>	 <input type="text" name="n" /> 
		<input type="submit" value="envoyer"/></br></br>
		</form>
	
	
	
	<div>
		<?php
		if(isset($_POST['n']))
			$n = (int)$_POST['n'];
		else
			$n = 5;
		$notes = $noteManage->nNotes($n);
		foreach($notes as $note){ ?>
		<div class="note"><fieldset>
		<p><strong>Joueur : </strong><?php echo $joueurManage->selectJoueur($note->getId_joueur())->getPseudo();?>. </br>
			<strong>Note :</strong> <?php echo $note->getNote(); ?>/20 .</br>
			<strong>Date :</strong> <?php echo $note->getDate_note(); ?> .</br>
			<strong>Jeu: <?php echo $jeuManage->selectJeu($note->getId_jeu())->getNom();?></strong>
			<?php $commentaire = $commentaireManage->selectCommentaire($note->getId_commentaire());
			$rouge = $commentaire->rouge($commentaireManage);
			$vert = $commentaire->vert($commentaireManage);
				echo '<p> '.$commentaire->getContenu().'</p>'; ?> 
		
		</p>
		<div class="jugement"> <a class="lienMenu" href="jeuControl.php?rouge&id_commentaire=<?php echo $commentaire->getId_commentaire();?>"> <img src="pouce_rouge.png"/> </a>
		<a href="likedcommentaire.php?rouge=<?php echo $commentaire->getId_commentaire();?>" class="lienMenu"/><span class="rouge" ><?php echo $rouge;?></span></a>  &nbsp;&nbsp; 
		<a class="lienMenu" href="jeuControl.php?vert&id_commentaire=<?php echo $commentaire->getId_commentaire();?>"><img src="pouce_vert.png"  /> </a>
		<a href="likedcommentaire.php?vert=<?php echo $commentaire->getId_commentaire();?>" class="lienMenu"/><span class="vert"><?php echo $vert;?></span></a>
		<span>Confiance : <?php echo $util->indice_confiance($rouge, $vert);?> </span>
		</div>
		</fieldset><?php } ?></div>
		
		<h4 class="centrage">Les commentaires classées par indice de confiance</h4>
	<p> Par défaut les 5 commentaires ayant le plus de confiance, vous pouvez modifier ce numéro :</p>
	<form method ="post" action="statistiques.php">
		<label>Un numéro N</label>	 <input type="text" name="N" /> 
		<input type="submit" value="envoyer"/></br></br>
		</form>
		
		<div>
		<?php
		if(isset($_POST['N']))
			$N = (int)$_POST['N'];
		else
			$N = 5;
		$notes = $noteManage->nNotesClasse($N);
		foreach($notes as $note){ ?>
		<div class="note"><fieldset>
		<p><strong>Joueur : </strong><?php echo $joueurManage->selectJoueur($note->getId_joueur())->getPseudo();?>. </br>
			<strong>Note :</strong> <?php echo $note->getNote(); ?>/20 .</br>
			<strong>Date :</strong> <?php echo $note->getDate_note(); ?> .</br>
			<strong>Jeu: <?php echo $jeuManage->selectJeu($note->getId_jeu())->getNom();?></strong>
			<?php $commentaire = $commentaireManage->selectCommentaire($note->getId_commentaire());
			$rouge = $commentaire->rouge($commentaireManage);
			$vert = $commentaire->vert($commentaireManage);
				echo '<p> '.$commentaire->getContenu().'</p>'; ?> 
		
		</p>
		<div class="jugement"> <a class="lienMenu" href="jeuControl.php?rouge&id_commentaire=<?php echo $commentaire->getId_commentaire();?>"> <img src="pouce_rouge.png"/> </a>
		<a href="likedcommentaire.php?rouge=<?php echo $commentaire->getId_commentaire();?>" class="lienMenu"/><span class="rouge" ><?php echo $rouge;?></span></a>  &nbsp;&nbsp; 
		<a class="lienMenu" href="jeuControl.php?vert&id_commentaire=<?php echo $commentaire->getId_commentaire();?>"><img src="pouce_vert.png"  /> </a>
		<a href="likedcommentaire.php?vert=<?php echo $commentaire->getId_commentaire();?>" class="lienMenu"/><span class="vert"><?php echo $vert;?></span></a>
		<span>Confiance : <?php echo $util->indice_confiance($rouge, $vert);?> </span>
		</div>
		</fieldset><?php } ?></div>
		
		<?php } else echo '<p>Connectez vous pour voir cette page.</p>'; ?>
	
	</section>
	<footer>
		
	</footer>
	</div>
	</body>
</html>
