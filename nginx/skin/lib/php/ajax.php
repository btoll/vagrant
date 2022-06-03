<?php
include("../../lib/php/classes/ItalyDAO.php");
$cfg = new ItalyDAO();

switch ($_GET['function']) {
  case "check_email":
    $cfg->checkEmail($_GET['email']);
    break;

  case "conjugate_verb":
    $cfg->conjugateVerb($_GET['verb'], $_GET['tense']);
    break;

  case "random_word":
    $cfg->getRandomWord();
    break;
}
?>

