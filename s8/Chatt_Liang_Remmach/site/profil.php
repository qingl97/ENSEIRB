<?php session_start(); 

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


 $utils = new Util($db);
 if(isset($_SESSION['id']) && isset($_SESSION['password']) && isset($_SESSION['pseudo']) && $joueurManage->joueurConnect($_SESSION['pseudo'], $_SESSION['password']))
	$joueur = $joueurManage->selectJoueur($_SESSION['id']);

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
		<a class="lienMenu" href="profil.php" ><li class="button">Profil: <?php echo $_SESSION['pseudo']?></li></a>
<?php } ?>
	</ul>
	</nav>
	<section>
		<?php if(isset($joueur)){
			?>
			<h3>Profil du joueur <?php echo $joueur->getPseudo();?></h3>
			<?php if($joueur->getPseudo()=='root')
				echo 'Pour ajouter un jeux <a href="ajouterModifierJeu.php">cliquez ici</a>';
				?>
			
			<p>Si vous voullez modifier vote profil <a href="modifierJoueur.php?id=<?php echo $joueur->getId();?>" />cliquez ici</a></p>
			
			<p>Voici la liste des jeux disponible sur votre catégorie préféres qui ont été critiqué. </br> Cliquez sur une id pour consulter les commetaires.</p>
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
	$listJeux = $jeuManage->selectCritiquePlateformeCategorie($joueur->getId_plateforme(),$joueur->getId_categorie());
	$i = 0;
	foreach($listJeux as $jeu){
		if($i%2==0){ $i++;?>
	<tr>
		<td><a href="jeu.php?id=<?php echo $jeu->getId();?>"> <?php echo $jeu->getId();?></a></td>
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
		<td> <a href="jeu.php?id=<?php echo $jeu->getId();?>"> <?php echo $jeu->getId();?></a></td>
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
			
			
			<?php }?>
	</section>
	<footer>
		
	</footer>
	</div>
	</body>
</html>
