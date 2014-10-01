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
	<a class ="lienMenu" href="joueur.php" ><li class="button">joueurs</li></a>
		<a  class="lienMenu" href="jeux.php"><li class = "button" >Jeux</li></a>
<?php if(!isset($joueur)){?>
	<a class="lienMenu" href="connexion.php" ><li class="button">Connexion</li></a>
	<a class="lienMenu" href="ajouterJoueur.php" ><li class="button">Inscription</li></a>
	<?php } else{
	?>
		<a class="lienMenu" href="joueurControl.php?deconnexion" ><li class="button">Deconnexion</li></a>
<?php } ?>
	</ul>
	</nav>
	<section>
		
	<?php 
	if(isset($joueur)){
		if(isset($_GET['vert']) && $commentaireManage->exist((int) $_GET['vert']))
			{?>
				<p> Voici la liste de ceux qui ont aimé le commentaire : </p>
				<?php $liked = $commentaireManage->likedCommentaire($_GET['vert'],1);
				foreach($liked as $like)
					echo $joueurManage->getPseudo($like['Id_Joueur']).'</br>';
				}
		 if (isset($_GET['rouge']) && $commentaireManage->exist((int) $_GET['rouge']))
			{?>
				<p> Voici la liste de ceux qui n'ont pas aimé le commentaire : </p>
				<?php $liked = $commentaireManage->likedCommentaire($_GET['rouge'],-1);
				foreach($liked as $like)
					echo $joueurManage->getPseudo($like['Id_Joueur']).'</br>';
				}
			}
		else 
			echo '<p>Connectez vous pour accéder à cette page.</p>';
	?>
	
	</section>
	<footer>
		
	</footer>
	</div>
	</body>
</html>
