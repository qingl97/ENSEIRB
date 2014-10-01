<?php
function chargerClasse($classname)
{
  require $classname.'.class.php';
}
 session_start();
spl_autoload_register('chargerClasse');

$pdo = new PDOFactory();
$db = $pdo->get_db();
$categorieManage = new CategorieManager($db);
$plateformeManage = new PlateformeManager($db);
	
$joueurManage =  new JoueurManager($db);

?>
<!DOCTYPE html>

<html>
	<head>
	<meta charset="utf-8"/>	
	<link rel="stylesheet" href="style.css" />
	<!--[if lt IE 9]>
            <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
	<title>Modification d'un Joueur</title>
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
		<?php if(isset($_SESSION['pseudo']) && isset($_SESSION['password']) && $joueurManage->joueurConnect($_SESSION['pseudo'], $_SESSION['password'])) { ?>
		<h3>Modification</h3>
		<?php
if(isset($_GET['id'])){
	if(!$joueurManage->exist((int) $_GET['id']))
	echo '<p>Aucun joueur Avec cette Id. </p>';
	else{ 
		$joueur = $joueurManage->selectJoueur($_GET['id']);
	?>
		<p>Voici le joueur que vous voullez modifier .</p>
	<div class="datagrid">
		<table>
<thead>
	<tr>
		<th>Id</th>
		<th>Pseudo</th>
		<th>Nom</th>
		<th>Prenom</th>
		<th>Email</th>
		<th>Plateforme</th>
		<th>Categorie</th>
		</tr>
</thead>
<tbody>
<tr class="alt">
		<td><?php echo $joueur->getId();?></td>
		<td><?php echo $joueur->getPseudo();?></td>
		<td><?php echo $joueur->getNom();?></td>
		<td><?php echo $joueur->getPrenom();?></td>
		<td><?php echo $joueur->getEmail();?></td>
		<td><?php echo $plateformeManage->selectPlateforme($joueur->getId_plateforme())->getPlateforme();?></td>
		<td><?php echo $categorieManage->selectCategorie($joueur->getId_categorie())->getCategorie();?></td>
	</tr>
</table>
</div>
</br>
	<form method="post" action="joueurControl.php">
   <p>
	   <fieldset>
	   Insérez les nouvelles valeurs ici </br>
		<label>Votre nom</label> : <input type="text" name="nom" /> </br>
		<label>Votre prenom</label> : <input type="text" name="prenom" /> </br>
		<label>Votre email</label> : <input type="email" name="email" /> </br>
		<label>Votre Plateforme</label> :
		<select name="plateforme" id="plateforme">
      <?php
      $plateformes = $plateformeManage->selectAllPlateformes();
      foreach($plateformes as $plate)
           echo '<option value="'.$plate->getId().'">'.$plate->getPlateforme().'</option>';
           ?>
       </select></br>
       
       <label>Votre Categorie</label> :
		<select name="categorie" id="categorie">
      <?php
      $categories = $categorieManage->selectAllCategories();
      foreach($categories as $cate)
           echo '<option value="'.$cate->getId().'">'.$cate->getCategorie().'</option>';
           ?>
       </select></br>

		
		<input type="hidden" name="modify" />
		<input type="hidden" name="id" value="<?php echo $_GET['id'] ;?>" />
		<input type="submit" value="envoyer"/>
		</fieldset>
   </p>
</form>
	<?php } } } else{ ?>
	<p>Connectez vous pour avoir accés à cette page.<br></p> <?php } ?>
	
	</section>
	<footer>
		
	</footer>
	</div>
	</body>
</html>
