<?php session_start(); 
?>
<!DOCTYPE html>

<html>
	<head>
	<meta charset="utf-8"/>	
	<link rel="stylesheet" href="style.css" />
	<!--[if lt IE 9]>
            <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
	<title>Page principale</title>
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
		<h3 class="centrage">Projet SGBD : Jeux-vidéos</h3>
	<p class="pInSec">
	Ce site est réalisé dans le cadre du projet de base données du semestre 7 à l'ENSEIRB-MATMECA.
	Il permet de s'interfacer avec la base et de visualiser les résultats instantanément.</p>
	<h4 class="centrage">Utilisation</h4>
	<p class="texte">
	Le menu à gauche vous permettera de consulter les différentes requêtes demandées.</br>
	Sur la page <em>Inscription</em> vous pourrez ajouter un nouveau joueur, et sur la page <em>Connexion</em> vous pourrez vous connecter avec un utilisateur pérsent dans la base.</br>
	La page <em>Statistiques</em> vous permet de visualiser le résulats de toutes les requêtes statistiques sur la base, mis à part le classement des joueurs par nombre de jeux qu'ils ont notés qui lui est disponible dans
	la page <em>Joueurs</em>.</br>
	Sur la page <em>Jeux</em> Vous pouvez consulter la liste des jeux disponibles classé par moyenne pondéré. Les notes utilisées sont celles attribuées par les joueurs.
	vous pouvez cliquer sur un jeux pour consulter plus d'informations sur ce derniers et voir les notes et commentaires associés (les notes sont classé par indice de confiance).
	Si vous êtes connecté en tant que root vous pourrez modifier et supprimer le jeux que vous souhaitez. </br>
	La page <em>Joueurs</em> vous renvoie la liste des joueurs inscrits classé par nombre de jeux qu'ils ont noté. Si vous êtes connecté en tant que root vous pouvez modifier ou supprimer n'importe quel joueur.</br>
	Une fois connecté avec un utilisateur, vous pouvez accéder à la page <em>Profil</em>. Cette page vous permet de de modifier le joueur avec lequel vous êtes connecté (sauf si vous êtes root vous pouvez modifier le profil de tous le monde)
	Si vous êtes root vous pouvez en plus de modifier votre profil ajouter un nouveau jeu à la base. Vous pouvez aussi ajouter des catégorie, des éditeurs et des plate-formes.
	Sur cette même page vous pouvez consulter tous les jeux critiqués disponible sur votre plate-forme et catégorie préféré.
	

 
	
	</p>
	</section>
	<footer>
		
	</footer>
	</div>
	</body>
</html>
