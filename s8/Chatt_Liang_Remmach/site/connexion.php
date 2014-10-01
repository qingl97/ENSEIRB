<?php
session_start();
?>




<!DOCTYPE html>

<html>
	<head>
	<meta charset="utf-8"/>	
	<link rel="stylesheet" href="style.css" />
	<!--[if lt IE 9]>
            <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
	<title>Connexion</title>
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
		<a class="lienMenu" href="profil.php" ><li class="button">Profil: <?php echo $joueur->getPseudo();?></li></a>
<?php } ?>
	</ul>
	</nav>
	<section>
			
   <p>
	   <?php if(!isset($_SESSION['id']) && !isset($_SESSION['password'])){?>
	<form class="form-container" method="post" action="joueurControl.php">
<div class="form-title"><h2>Connexion</h2></div>
<div class="form-title">Pseudo</div>
<input class="form-field" type="text" name="pseudo" /><br />
<div class="form-title">Mot de passe</div>
<input class="form-field" type="password" name="password" /><br />
<div class="submit-container">
	<input type="hidden" name="connexion" /> 
<input class="submit-button" type="submit" value="Envoyer" />
</div>
</form>
		<?php } else { ?>
		<p>Vous êtes déjà connecté. Vous n'avez pas besoin de vous reconnecter.</br></p>
		<?php } ?>
   </p>

	</section>
	<footer>
		
	</footer>
	</div>
	</body>
</html>
