<?php
$body_id = "verbs";
//include_once("../lib/php/verbs.php");
include_once("../lib/includes/header.php");
#include_once("../lib/php/search_engines.php");
//$cfg = new ItalyDAO($_REQUEST);
//$regular = "";
//$irregular = "";
//$reflexive = "";
//$simple = "";
//$compound = "";
//if (isset($_POST['name'])) {
//  $regular = $_POST['regular'];
//  $irregular = $_POST['irregular'];
//  $reflexive = $_POST['reflexive'];
//  $simple = $_POST['simple'];
//  $compound = $_POST['compound'];
//  $cfg->conjugateVerb();
//}
?>

  <div id="text">
    <h3>I Verbi</h3>
    <form id="verbTypesForm" method="post" action="<?=$_SERVER['PHP_SELF']?>">
      <p>
        <strong>Select a verb:</strong>
        <?php
//          $cfg->getList("regular", $regular);
//          $cfg->getList("irregular", $irregular);
//          $cfg->getList("reflexive", $reflexive);
        ?>
        <input class="clear" type="button" id="clearVerbs" value="Clear" />
      </p>

      <p>
        <strong>Select a tense:</strong>
        <?php
//          $cfg->getList("simple", $simple);
//          $cfg->getList("compound", $compound);
        ?>
        <input class="clear" type="button" id="clearTenses" value="Clear" />
      </p>

      <p>
        <label><input class="submit" type="submit" value="Submit" /></label>
        <label><input class="submit" type="submit" id="refresh" name="refresh" value="Clear All" /></label>
      </p>

      <div id="message" class="error">
      </div>

      <div id="conjugatedVerb" style="display: none;">
        <table>
          <tbody>
            <tr>
              <td class="pronoun">io</td><td id="io" class="conjVerb"></td>
              <td class="pronoun">noi</td><td id="noi" class="conjVerb"></td>
            </tr>
            <tr>
	      <td class="pronoun">tu</td><td id="tu" class="conjVerb"></td>
              <td class="pronoun">voi</td><td id="voi" class="conjVerb"></td>
            </tr>
            <tr>
              <td class="pronoun">egli</td><td id="egli" class="conjVerb"></td>
              <td class="pronoun">loro</td><td id="loro" class="conjVerb"></td>
            </tr>
          </tbody>
        </table>
      </div>
    </form>
  </div>

  <?php
  include_once("../lib/includes/footer.php");
  ?>
