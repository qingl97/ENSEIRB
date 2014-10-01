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
$categorieManage = new CategorieManager($db);
$plateformeManage = new PlateformeManager($db);
	

$listJoueurs = $joueurManage->selectJoueurList();

?>
<!DOCTYPE html>

<html>
	<head>
	<meta charset="utf-8"/>	
	<link rel="stylesheet" href="style.css" />
	<!--[if lt IE 9]>
            <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
	<title>Liste des joueurs</title>
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
	<?php if(isset($_SESSION['pseudo']) && isset($_SESSION['password']) && $joueurManage->joueurConnect($_SESSION['pseudo'], $_SESSION['password'])) { 
	
		if($_SESSION['pseudo']=='root') {
			echo '<h2>Cette page vous permettera de modifier les informations concernant les joueurs.</h2>
		<p>
			Pour modifier un joueur cliquez sur son Id dans la liste.</br>
			Pour le supprimer cliquez sur la petite croix à côté de son id dans la liste .</br>';
		} ?>
		
		</p>
		<h3>Liste des joueurs</h3>
		<p>Les joueurs sont classé par nombre de jeux qu'ils ont critiqué.</p>
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
	<?php
	$i = 0;
	foreach($listJoueurs as $joueur){
		if($i%2==0){ $i++;?>
	<tr>
		<td><?php if($_SESSION['pseudo']=='root') {?><a href="joueurControl.php?delete=<?php echo $joueur->getId();?>"><img src="delete.png" alt="supprimer"/></a> 
		<a href="modifierJoueur.php?id=<?php echo $joueur->getId();?>"> <?php echo $joueur->getId();?></a> <?php }else echo $joueur->getId(); ?> </td>
		<td><?php echo $joueur->getPseudo();?></td>
		<td><?php echo $joueur->getNom();?></td>
		<td><?php echo $joueur->getPrenom();?></td>
		<td><?php echo $joueur->getEmail();?></td>
		<td><?php echo $plateformeManage->selectPlateforme($joueur->getId_plateforme())->getPlateforme();?></td>
		<td><?php echo $categorieManage->selectCategorie($joueur->getId_categorie())->getCategorie();?></td>
	</tr>
	<?php }
	else {
		?>
<tr class="alt">
		<td><?php if($_SESSION['pseudo']=='root') {?><a href="joueurControl.php?delete=<?php echo $joueur->getId();?>"><img src="delete.png" alt="supprimer"/></a> 
		<a href="modifierJoueur.php?id=<?php echo $joueur->getId();?>"> <?php echo $joueur->getId();?></a> <?php }else echo $joueur->getId(); ?></td>
		<td><?php echo $joueur->getPseudo();?></td>
		<td><?php echo $joueur->getNom();?></td>
		<td><?php echo $joueur->getPrenom();?></td>
		<td><?php echo $joueur->getEmail();?></td>
		<td><?php echo $plateformeManage->selectPlateforme($joueur->getId_plateforme())->getPlateforme();?></td>
		<td><?php echo $categorieManage->selectCategorie($joueur->getId_categorie())->getCategorie();?></td>
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
