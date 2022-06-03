<?php

//these functions looks up the english verb and tense and then echoes them to the screen for the user in the grammar/verbs.php script;
function look_up_verb($verb) {

  connect_db();

  $sql = sprintf("SELECT verb FROM verb_list WHERE id = %d", $verb);
  $result = mysql_query($sql) or die(mysql_error());
  $verb = mysql_fetch_array($result);

  return $verb[0];

}

function look_up_tense($tense) {

  connect_db();

  $sql = sprintf("SELECT tense FROM tenses WHERE id = %d", $tense);
  $result = mysql_query($sql) or die(mysql_error());
  $tense = mysql_fetch_array($result);

  return $tense[0];

}
?>
