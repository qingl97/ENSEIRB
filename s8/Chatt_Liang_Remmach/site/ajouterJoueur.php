<?php
session_start();



function chargerClasse($classname)
{
  require $classname.'.class.php';
}
 
spl_autoload_register('chargerClasse');

$pdo = new PDOFactory();
$db = $pdo->get_db();
$categorieManage = new CategorieManager($db);
$plateformeManage = new PlateformeManager($db);
	


?>
?>
<!DOCTYPE html>

<html>
	<head>
	<meta charset="utf-8"/>	
	<link rel="stylesheet" href="style.css" />
	<!--[if lt IE 9]>
            <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
	<title>Ajout d'un Joueur</title>
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
				<a class="lienMenu" href="profil.php" ><li class="button">Profil: <?php echo $_SESSION['pseudo']?></li></a>
<?php } ?>
	</ul>
	</nav>
	<section>
	<form method="post" action="joueurControl.php">
   <p>
	   <?php if(!isset($_SESSION['id']) && !isset($_SESSION['password'])){?>
	   <fieldset>
	  Cette page vous permet d'ajouter un nouveau joueur dans la base. </br>
	   <label for='pseudo'>Votre pseudo </label> : <input type="text" name="pseudo" id='pseudo'/> </br>
	   <label for='password'>Mot de passe </label> : <input type="password" name="password" id='password'/> </br>
	   <label for='nom'>Votre nom    </label> : <input type="text" name="nom" id='nom'/> </br>
	   <label for='prenom'>Votre prenom </label> : <input type="text" name="prenom" id='prenom'/> </br>
	   <label for='email'>Votre email  </label> : <input type="email" name="email" id='email'/> </br>
	   <label for='plateforme'>Votre Plateforme</label> :
		<select name="plateforme" id="plateforme">
      <?php
      $plateformes = $plateformeManage->selectAllPlateformes();
      foreach($plateformes as $plate)
           echo '<option value="'.$plate->getId().'">'.$plate->getPlateforme().'</option>';
           ?>
       </select></br>
       
        <label for='categorie'>Votre Categorie </label> :
		<select name="categorie" id="categorie">
      <?php
      $categories = $categorieManage->selectAllCategories();
      foreach($categories as $cate)
           echo '<option value="'.$cate->getId().'">'.$cate->getCategorie().'</option>';
           ?>
       </select for='pseudo'></br>
		<input type="hidden" name="add" />
		<input type="submit" value="envoyer"/>
		</fieldset>
		<?php } else { ?>
		<p>Vous êtes déjà connecté. Vous n'avez pas besoin de créer un nouveau compte</br></p>
		<?php } ?>
   </p>
</form>

	

	
	</section>
	<footer>
		
	</footer>
	</div>
	</body>
</html>
