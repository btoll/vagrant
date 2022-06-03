<?php
//include_once("./lib/php/config.php");
include(dirname(__FILE__)."/../../../italy.php");

#########################################

// display the text_files that include a phrase entered by the user as a search criterion;
//var_dump($_GET);
$phrase = $_GET['phrase'];
$language = $_GET['language'] == "italian" ? "italian" : "translation"; //"translation" == search for the English words;
$match = $_GET['match'];

//the SQL query will be based on the language (Italian or English) the user selected in the dictionary.php script as part of the search criteria;
if ($match == "like") {
  $sql = sprintf("SELECT italian, pronunciation, grammar, translation FROM words WHERE $language LIKE '%%%s%%' ORDER BY italian, grammar", addslashes($phrase));
  $sql2 = sprintf("SELECT COUNT(*) FROM words WHERE $language LIKE '%%%s%%' ORDER BY italian, grammar", addslashes($phrase));
} elseif ($match == "each_word") {
  $phrase_replace = str_replace(" ", "%' AND $language LIKE '%", addslashes($phrase));
  $sql = sprintf("SELECT italian, pronunciation, grammar, translation FROM words WHERE $language LIKE '%%%s%%' ORDER BY italian, grammar", $phrase_replace);
  $sql2 = sprintf("SELECT COUNT(*) FROM words WHERE $language LIKE '%%%s%%' ORDER BY italian, grammar", $phrase_replace);
} elseif ($match == "exact") {
  $sql = sprintf("SELECT italian, pronunciation, grammar, translation FROM words WHERE $language = '%s' ORDER BY italian, grammar", addslashes($phrase));
  $sql2 = sprintf("SELECT COUNT(*) FROM words WHERE $language = '%s' ORDER BY italian, grammar", addslashes($phrase));
}

$db = mysqli_connect(DB_Config::DBHOST, DB_Config::DBUSER, DB_Config::DBPASS);
mysqli_select_db($db, DB_Config::DBNAME);

//if there is nothing returned then let the user know and the script will end;
$result2 = mysqli_query($db, $sql2) or die("The server cannot be reached at this time.");
$display2 = mysqli_fetch_row($result2) or die("The server cannot be reached at this time.");
if ($display2[0] == 0) {
  echo "<p>There are no records found for <strong style=\"color: #000;\">" . $phrase . "</strong></p>"; #strip slashes since they were added to query the db;

  #add the missing word into a db table and then send me an email if there are more than 'x' new searched phrases;
  $arr = array("phrase" => $phrase, "language" => $language, "ip" => $_SERVER['REMOTE_ADDR']);
  $cfg = new ItalyDAO($arr);
  $cfg->addWordSearch();
  if ($cfg->getCount("word_search") > 9) {
    $result = mysql_query("SELECT * FROM word_search");
    $all_words = array();
    while ($display = mysqli_fetch_assoc($result)) {
      $all_words[] = "\nword: " . $display['word'] . "\nlanguage: " . $display['language'] . "\nip: " . $display['ip'] . "\ntimestamp: " . $display['timestamp'];
    }
//    $cfg->sendEmail((object) array(
//      "message" => "Here are the latest searched words:\n\n" . join("\n", $all_words),
//      "subject" => "italy.benjamintoll.com searched words list",
//      "mail_to" => "benjam72@yahoo.com",
//      "mail_from" => "wotd@benjamintoll.com"
//    ));
  }

} else {
  //there are records found so print the results;
  //$result = mysql_query($sql) or die("The server cannot be reached at this time.");
  $result = mysqli_query($db, $sql);

  //this function counts the results in the array and displays the result
  //on the page along with the word searched for;
  $num_results = mysqli_num_rows($result);

  if ($num_results > 250) {
    $num_results = number_format($num_results);
    //echo "<p>Number of results found for <a href=\"index.php?phrase=$phrase&language=$language&match=$match\"><strong style=\"color: #000;\">$phrase</strong></a>: <strong style=\"color: olive;\">$num_results</strong></p><hr />\n";
    echo "<p>Number of results found for <strong style=\"color: #000;\">$phrase</strong>: <strong style=\"color: olive;\">$num_results</strong></p><hr />\n";
    echo "<h4>Search results too large.  Please try to narrow your search.</h4>\n";
  } else{
    //Number of records to show per page:
    $records_per_page = 15;

    //Determine how many pages there are.
    if (isset($_GET['pages'])) { //Already been determined.
      $num_pages = $_GET['pages'];
    } else { // Need to determine.
      //Calculate the number of pages.
      if ($num_results > $records_per_page) { //More than 1 page.
        $num_pages = ceil ($num_results / $records_per_page);
      } else {
        $num_pages = 1;
      }
    } //End of pages IF.

    //Determine where in the database to start returning results.
    if (isset($_GET['start'])) {
      $start = $_GET['start'];
    } else {
      $start = 0;
    }

    $sql = $sql . " LIMIT $start, $records_per_page";
    //i have to make another result identifier b/c the $start and
    //$records_per_page variables weren't available to me before;
    //i couldn't determine those variables until after i already created
    //a result identifier to get the total number of rows, which then
    //subsequently was the only way to determine the previously
    //mentioned variables;
    $result = mysqli_query($db, $sql) or die(mysql_error());

    $num_results = number_format($num_results);

    //iterate through the array;
    //first strip all backslashes from the phrase so it's presentable to the user;
    //echo "<p>Number of results found for <a href=\"index.php?phrase=$phrase&language=$language&match=$match\" onclick=\"ITALIA.getWords('lib/php/word_search.php', '$phrase', '$language', '$match'); return false;\"><strong style=\"color: #000;\">$phrase</strong></a>: <strong style=\"color: olive;\">$num_results</strong></p><hr />\n";
    echo "<p>Number of results found for <strong style=\"color: #000;\">$phrase</strong>: <strong style=\"color: olive;\">$num_results</strong></p><hr />\n";

    //NOW begin to build the definitions that will be returned to the user;
    //increment the counter ($n) depending on where $start is;
//    $n = $_GET['start'];
    $n = $start;
    while ($display = mysqli_fetch_assoc($result)) {

      $n = $n + 1;
      ###################################
      # add an accent mark if applicable;
      ###################################

      $iword = $display['italian']; //$iword is short for italian word;
      if (strpos($iword, 'e\'') OR strpos($iword, 'a\'') OR strpos($iword, 'u\'') OR strpos($iword, 'i\'') OR strpos($iword, 'o\'') OR substr($iword, 0, 2) == 'e\'') {

        if (strpos($iword, 'e\'')) {
          $iword = str_replace('e\'', '&egrave;', $iword);
        } elseif (strpos($iword, 'a\'')) {
          $iword = str_replace('a\'', '&agrave;', $iword);
        } elseif (strpos($iword, 'u\'')) {
          $iword = str_replace('u\'', '&ugrave;', $iword);
        } elseif (strpos($iword, 'i\'')) {
          $iword = str_replace('i\'', '&igrave;', $iword);
        } elseif (strpos($iword, 'o\'')) {
          $iword = str_replace('o\'', '&ograve;', $iword);
        } elseif (substr($iword, 0, 2) == 'e\'') {
          //this is for when "e'" are the first two letters in the def;
          $iword = str_replace('e\'', '&egrave;', $iword);
        }
      }

      $temp = mysqli_real_escape_string($db, $iword);
      //the following checks for the occurence of a comma (,) then a semi-colon (;) within in the same definition as a comma and if they are present replaces them with spaces;
      echo $href_first_part = "<p>$n. <a href=\"index.php?phrase=$temp&language=italian&match=like\" class=\"italianWord\" onclick=\"ITALIA.getWords('lib/php/word_search.php', '$temp', 'italian', 'like'); return false;\"><strong>$iword</strong></a> [<a href=\"/pronunciation/\" class=\"pronunciation\"><strong>{$display['pronunciation']}</strong></a>], <span style=\"color: #000;\">{$display['grammar']}:</span> ";

      //remember all links are set to be white in the stylesheet; override, or links will be white against a white background;
      $pattern = "/([^,;]+)/";
      $replace = "<a href='index.php?phrase=$1&language=english&match=like' onclick=\"ITALIA.getWords('lib/php/word_search.php', '$1', 'english', 'like'); return false;\"><strong>$1</strong></a>";
      echo preg_replace($pattern, $replace, $display['translation']);
      echo "</p>";

    }

    //make the links to other pages, if necessary; also, NOTE that each link has a url in case javascript is disabled;
    if ($num_pages > 1) {
      echo '<div id="pagination">';
      //Determine what page the script is on.
      $current_page = ($start/$records_per_page) + 1;

      // If it's not the first page, make a Previous button.
      if ($current_page != 1) {
        $s = $start - $records_per_page;
        echo "<a style=\"color: #FFA500;\" href=\"index.php?phrase=$phrase&language=$language&match=$match&start=$s&pages=$num_pages\" onclick=\"ITALIA.getWords('lib/php/word_search.php', '$phrase', '$language', '$match', '$s', '$num_pages'); return false;\">Previous</a> ";
      }

      //Make all the numbered pages.
      for ($i = 1; $i <= $num_pages; $i++) {
        if ($i != $current_page) {
          $s = $records_per_page * ($i - 1);
          echo "<a href=\"index.php?phrase=$phrase&language=$language&match=$match&start=$s&pages=$num_pages\" onclick=\"ITALIA.getWords('lib/php/word_search.php', '$phrase', '$language', '$match', '$s', '$num_pages'); return false;\">$i</a> ";
        } else {
          echo $i . ' ';
        }
      }

      //If it's not the last page, make a Next button.
      if ($current_page != $num_pages) {
        $s = $start + $records_per_page;
        echo "<a style=\"color: #FFA500;\" href=\"index.php?phrase=$phrase&language=$language&match=$match&start=$s&pages=$num_pages\" onclick=\"ITALIA.getWords('lib/php/word_search.php', '$phrase', '$language', '$match', '$s', '$num_pages'); return false;\">Next</a>";
      }

      echo '</div><!--end div#pagination-->';

    } //End of links section.

  }
}

?>

