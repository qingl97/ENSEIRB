<?php
	if(isset($_POST['pass']))
		echo 'mdp = '.sha1($_POST['pass']);
	else{
		?>
		<form method="post" action="pass.php">
   <p>
	   <fieldset>
	   Entrez vos identifiant ici </br>
		<label>mot de passe</label> : <input type="text" name="pass" /> </br>
		
		<input type="submit" value="envoyer"/>
		
   </p>
			
<?php }	
