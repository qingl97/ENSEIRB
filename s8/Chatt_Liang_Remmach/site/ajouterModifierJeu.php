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
$jeuManage = new JeuManager($db);
$joueurManage =  new JoueurManager($db);
$editeurManage = new EditeurManager($db);
$noteManage = new NoteManager($db);

?>
<!DOCTYPE html>

<html>
	<head>
	<meta charset="utf-8"/>	
	<link rel="stylesheet" href="style.css" />
	<!--[if lt IE 9]>
            <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
	<title>Modification ou ajout d'un Jeu</title>
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
		<?php if(isset($_SESSION['pseudo']) && isset($_SESSION['password']) && $_SESSION['pseudo']=='root' && $joueurManage->joueurConnect($_SESSION['pseudo'], $_SESSION['password'])) { ?>
		
		<h3 >Ajouter une Catégorie</h3>
		<form method="post" action="jeuControl.php">
			<input type="text" name="categorieAdd"/>
			<input type="submit" value="ajouter" />
			</form>
			
			<h3 >Ajouter un Éditeur</h3>
		<form method="post" action="jeuControl.php">
			<input type="text" name="editeurAdd"/>
			<input type="submit" value="ajouter" />
			</form>
			
			<h3 >Ajouter une Plateforme</h3>
		<form method="post" action="jeuControl.php">
			<input type="text" name="plateformeAdd"/>
			<input type="submit" value="ajouter" />
			</form>
			
		<?php
if(isset($_GET['id'])){
	if(!$jeuManage->exist((int) $_GET['id']))
	echo '<p>Aucun joueur Avec cette Id. </p>';
	else{ 
		echo '<h3>Modification d\'un jeu</h3>';
		$jeu = $jeuManage->selectJeu($_GET['id']);
		$editeur = $editeurManage->selectEditeur($jeu->getId_editeur());
		   $plateforme = $plateformeManage->selectPlateforme($jeu->getId_plateforme());
	?>
	<p>Voici le jeu que vous voullez modifier .</p>
	   <fieldset>
	  <h3 class="titreJeu"><?php echo $jeu->getNom(); ?></h3>
	 <p> <img class="imgJeu" src="<?php echo $jeu->getImg(); ?>" /> </br>
		<strong>Date de parution : <?php echo $jeu->getDate();?></strong></br>
		<strong>Editeur : <?php echo $editeur->getEditeur();?></strong></br>
		<strong>Plateforme : <?php echo $plateforme->getPlateforme();?></strong></br>
		<strong>Categorie(s) : <?php $categories = $categorieManage->selectCategoriesJeu($jeu->getId()); foreach($categories as $categorie) echo $categorie['Nom_Categorie'].'  '; ?></strong></br>
		<strong> Note des joueurs : <?php $note =  $noteManage->moyenneNote($_GET['id']); echo $note['note'];?></strong>
	  </p>
		</fieldset>
		
	
</br>
	<form method="post" action="jeuControl.php">
   <p>
	   <fieldset>
	   Insérez les nouvelles valeurs ici </br>
		<label>Le nom</label> : <input type="text" name="nom" /> </br>
		<label>Date de parution</label> : <input type="text" name="date" /> </br>
		<label>Editeur</label> : 
		<select name="editeur" id="editeur">
			<?php 
			$editeurs = $editeurManage->selectAllEditeurs();
			foreach($editeurs as $edi)
				echo '<option value="'.$edi->getId().'">'.$edi->getEditeur().'</option>';			
			?>
			</select> </br>
		<label>La Plateforme</label> :
		<select name="plateforme" id="plateforme">
      <?php
      $plateformes = $plateformeManage->selectAllPlateformes();
      foreach($plateformes as $plate)
           echo '<option value="'.$plate->getId().'">'.$plate->getPlateforme().'</option>';
           ?>
       </select></br>
       
       <label>Categorie(s)</label> : </br>
      <?php
      $categories = $categorieManage->selectAllCategories();
      foreach($categories as $cate)
           echo '<input type="checkbox" name="'.$cate->getCategorie().'" value="'.$cate->getId().'"  /> <label for="'.$cate->getCategorie().'">'.$cate->getCategorie().'</label><br />';
           ?>
       

		
		<input type="hidden" name="modifyJeu" />
		<input type="hidden" name="id" value="<?php echo $_GET['id'] ;?>" />
		<input type="submit" value="envoyer"/>
		</fieldset>
   </p>
</form>
	<?php } }
	
	else{?>
		
		<h3>Ajout d'un nouveau jeu</h3>
		<form method="post" action="jeuControl.php">
   <p>
	   <fieldset>
	   Renségnez les champs : </br>
		<label>Le nom</label> : <input type="text" name="nom" /> </br>
		<label>Date de parution</label> : <input type="text" name="date" /> </br>
		<label>Editeur</label> : 
		<select name="editeur" id="editeur">
			<?php 
			$editeurs = $editeurManage->selectAllEditeurs();
			foreach($editeurs as $edi)
				echo '<option value="'.$edi->getId().'">'.$edi->getEditeur().'</option>';			
			?>
			</select> </br>
		<label>La Plateforme</label> :
		<select name="plateforme" id="plateforme">
      <?php
      $plateformes = $plateformeManage->selectAllPlateformes();
      foreach($plateformes as $plate)
           echo '<option value="'.$plate->getId().'">'.$plate->getPlateforme().'</option>';
           ?>
       </select></br>
       
       <label>Categorie(s)</label> : </br>
      <?php
      $categories = $categorieManage->selectAllCategories();
      foreach($categories as $cate)
           echo '<input type="checkbox" name="'.$cate->getCategorie().'" value="'.$cate->getId().'"  /> <label for="'.$cate->getCategorie().'">'.$cate->getCategorie().'</label><br />';
           ?>
       

		
		<input type="hidden" name="addJeu" />
		<input type="submit" value="envoyer"/>
		</fieldset>
   </p>
</form>
		
		<?php } } else{ ?>
	<p>Connectez vous pour avoir accés à cette page.<br></p> <?php } ?>
	
	</section>
	<footer>
		
	</footer>
	</div>
	</body>
</html>
