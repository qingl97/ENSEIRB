<?php
session_start();
function chargerClasse($classname)
{
  require $classname.'.class.php';
}
 
spl_autoload_register('chargerClasse');

$pdo = new PDOFactory();
$db = $pdo->get_db();

$jeuManage =  new JeuManager($db);

$joueurManage = new JoueurManager($db);
$editeurManage = new EditeurManager($db);
$plateformeManage = new PlateformeManager($db);
$categorieManage = new CategorieManager($db);


?>



<!DOCTYPE html>

<html>
	<head>
	<meta charset="utf-8"/>	
	<link rel="stylesheet" href="style.css" />
	<!--[if lt IE 9]>
            <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
	<title>Liste des Jeux</title>
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
		<h2 class="centrage">Liste des jeux</h2>
		
	<?php if(isset($_SESSION['pseudo']) && isset($_SESSION['password']) && $joueurManage->joueurConnect($_SESSION['pseudo'], $_SESSION['password'])) { ?>
	<p>Par défaut tous les jeux sont affiché et classé par ordre décroissant de leur moyenne pondérée.</p>
		<?php if($_SESSION['pseudo']=='root') echo '<p>Pour créer un nouveau jeu cliquez <a href="ajouterModifierJeu.php">ici</a></p>'; ?>
		<p>Spécifiez une plateforme pour avoir la liste des jeux critiqués et classé par catégories disponible sur celle-ci </br>
		<form method="post" action="jeux.php">
		<label>Votre Plateforme</label> :
		<select name="plateforme" id="plateforme">
      <?php
      $plateformes = $plateformeManage->selectAllPlateformes();
      foreach($plateformes as $plate)
           echo '<option value="'.$plate->getId().'">'.$plate->getPlateforme().'</option>';
           ?>
       </select>
       <input type="submit" value="envoyer"/>
       </form>
       </p>
     <?php if(isset($_POST['plateforme']) && $plateformeManage->exist((int)$_POST['plateforme']))
				$listJeux = $jeuManage->selectCritiquePlateforme($_POST['plateforme']);
			else
				$listJeux = $jeuManage->selectJeuList();?>
	
	<div class="datagrid">
		<table>
<thead>
	<tr>
		<th>Id</th>
		<th>Nom</th>
		<th>Date Parution</th>
		<th>Plateforme</th>
		<th>Editeur</th>
		<th>Categories</th>
		</tr>
</thead>
<tbody>
	<?php
	$i = 0;
	foreach($listJeux as $jeu){
		if($i%2==0){ $i++;?>
	<tr>
		<td><?php if($_SESSION['pseudo']=='root') echo '<a href="jeuControl.php?delete=<?php'.$jeu->getId().'"><img src="delete.png" alt="supprimer"/></a>';?> 
		<a href="jeu.php?id=<?php echo $jeu->getId();?>"> <?php echo $jeu->getId();?></a></td>
		<td><?php echo $jeu->getNom();?></td>
		<td><?php echo $jeu->getDate();?></td>
		<td><?php echo $plateformeManage->selectPlateforme($jeu->getId_plateforme())->getPlateforme();?></td>
		<td><?php echo $editeurManage->selectEditeur($jeu->getId_editeur())->getEditeur();?></td>
		<td><?php $categories = $categorieManage->selectCategoriesJeu($jeu->getId()); foreach($categories as $categorie) echo $categorie['Nom_Categorie'].'  '; ?></td>
	</tr>
	<?php }
	else {
		?>
<tr class="alt">
		<td><?php if($_SESSION['pseudo']=='root') echo '<a href="jeuControl.php?delete=<?php'.$jeu->getId().'"><img src="delete.png" alt="supprimer"/></a>';?> 
		<a href="jeu.php?id=<?php echo $jeu->getId();?>"> <?php echo $jeu->getId();?></a></td>
		<td><?php echo $jeu->getNom();?></td>
		<td><?php echo $jeu->getDate();?></td>
<td><?php echo $plateformeManage->selectPlateforme($jeu->getId_plateforme())->getPlateforme();?></td>
		<td><?php echo $editeurManage->selectEditeur($jeu->getId_editeur())->getEditeur();?></td>
		<td><?php $categories = $categorieManage->selectCategoriesJeu($jeu->getId()); foreach($categories as $categorie) echo $categorie['Nom_Categorie'].'  '; ?></td>
	</tr>
	<?php $i++;
	} 
	} ?>
</table>
</div>
	
	
	<?php } else{ ?>
	<p>Connectez vous pour avoir accés à cette page.<br></p> <?php } ?>
	
	
	</section>
	<footer>
		
	</footer>
	</div>
	</body>
</html>
