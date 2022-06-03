<?php

include_once("connect_db.php");

function plural_array($display, $var) {

  $noi = $display[noi] . " " . $var;
  $voi = $display[voi] . " " . $var;
  $loro = $display[loro] . " ". $var;
	
  return $array = array($noi, $voi, $loro);

}

// this function completely conjugates the regular verb;

function conjugate($verb, $root, $verb_type, $conj_with, $check_verb, $past_part) {

	// open and connect to the database;

	connect_db();

	// first check if it has previously been entered;

	$sql = "SELECT * FROM verb_list WHERE verb='" . $verb . "'";

	$result = mysql_query($sql) or die("There has been a problem accessing the database");

	// this function counts the results in the array;

	$num_results = mysql_num_rows($result);

	if ($num_results > 0) {

		echo "<body link=\"navy\" alink=\"navy\" vlink=\"navy\">\n";
		echo "Sorry, <font color=\"navy\">$verb</font> has already been entered.<br>\n";
		echo "<a href=\"add_verb.php\">Back</a>\n";
		echo "</body>";

		exit;

	}
 
	// enter the verb into the verb_list table (1=regular), (2=irregular), (3=reflexive);

	if ($verb_type == 'regular') {

		$verb_type = 1;

	} else {

		$verb_type = 3;
		$conj_with = 'essere';
	
		// get the last four letters of the verb so it can be conjugated properly;

		$verb_length = strlen($verb);
		$new_length = ($verb_length - 4);
		$check_verb = substr($verb, $new_length, $verb_length);
		
	}
		
	$sql = "INSERT INTO verb_list VALUES (null, '$verb', $verb_type)";

	$result = mysql_query($sql) or die("The data could not be entered.");

	if (!$result) {

		return false;

	}

	// conjugate each tense and enter into the verbs table;

	// lookup the foreign key for the verb (its number in the verb_list table);

	$sql = "SELECT id FROM verb_list WHERE verb='" . $verb . "'";

	$result = mysql_query($sql) or die("There has been a problem.");

	$display = mysql_fetch_row($result) or die("There has been a problem.");

	$id = $display[0];

	// now begin conjugating the verb;

	if ($check_verb == 'are' or $check_verb == 'arsi') {

		$v = 'a'; // 'v' for vowel;
		$z = 'a';
		$y = 'i';
		$x = 'o';

	} elseif ($check_verb == 'ere' or $check_verb == 'ersi') {

		$v = 'e';
		$z = 'o';
		$y = 'a';
		$x = 'e';

	}


	// enter the data into the server;

		// PRESENT INDICATIVE;

		$io = $root . "o";
		$tu = $root . "i";
		$egli = $root . $v;
		$noi = $root . "iamo";
		$voi = $root . $v . "te";
		$loro = $root . $z . "no";
	
		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$noi', '$voi', '$loro', 1)";

		$result = mysql_query($sql);
	
		// IMPERFECT;

		$io = $root . $v . "vo";
		$tu = $root . $v . "vi";
		$egli = $root . $v . "va";
		$noi = $root . $v . "vamo";
		$voi = $root . $v . "vate";
		$loro = $root . $v . "vano";
	
		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$noi', '$voi', '$loro', 5)";

		$result = mysql_query($sql);
	
		// PAST ABSOLUTE;

		$io = $root . $v . "i";
		$tu = $root . $v . "sti";
		$egli = $root . $x . "\'";
		$noi = $root . $v . "mmo";
		$voi = $root . $v . "ste";
		$loro = $root . $v . "rono";

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$noi', '$voi', '$loro', 6)";

		$result = mysql_query($sql);
	
		// FUTURE;

		$io = $root . "ero\'";
		$tu = $root . "erai";
		$egli = $root . "era\'";
		$noi = $root . "eremo";
		$voi = $root . "erete";
		$loro = $root . "eranno";

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$noi', '$voi', '$loro', 7)";

		$result = mysql_query($sql);
	
		// PRESENT CONDITIONAL;

		$io = $root . "erei";
		$tu = $root . "eresti";
		$egli = $root . "erebbe";
		$noi = $root . "eremmo";
		$voi = $root . "ereste";
		$loro = $root . "erebbero";

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$noi', '$voi', '$loro', 8)";

		$result = mysql_query($sql);
	
		// PRESENT SUBJUNCTIVE;

		$io = $root . $y;
		$tu = $root . $y;
		$egli = $root . $y;
		$noi = $root . "iamo";
		$voi = $root . "iate";
		$loro = $root . $y . "no";

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$noi', '$voi', '$loro', 9)";

		$result = mysql_query($sql);
	
		// IMPERFECT SUBJUNCTIVE;

		$io = $root . $v . "ssi";
		$tu = $root . $v . "ssi";
		$egli = $root . $v . "sse";
		$noi = $root . $v . "ssimo";
		$voi = $root . $v . "ste";
		$loro = $root . $v . "ssero";

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$noi', '$voi', '$loro', 10)";

		$result = mysql_query($sql);

###################################################################	

		$root = $past_part; // change the root variable;
		
		// chop off the last letter of the past participle for the compound plural;
		$length = strlen($past_part);
		$cut = ($length - 1);
		$new_part = substr($past_part, 0, $cut); // everything but the last letter;
		$plural = $new_part . "i"; // add the plural form of the past participle;
		
		// PRESENT PERFECT;

		if ($conj_with == 'avere') { // populate the avere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=1 AND tense=1";
		
		} else { // populate the essere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=2 AND tense=1";
		
		}
				
		$result = mysql_query($sql) or die("The query cannot be completed.");
		$display = mysql_fetch_array($result) or die("The query cannot be completed.");
		$io = $display[io] . " " . $root;
		$tu = $display[tu] . " " . $root;
		if ($display[egli] == "e'") { 
			// add a slash before the apostrophe or the query will bomb;
			$egli = "e\'" . " " . $root;
		} else {
			$egli = $display[egli] . " " . $root;
		}

		// the following function populates the compound tenses;

		if ($conj_with == 'avere') {

			// all participles wil end with 'o';
			$array = plural_array($display, $root);
	
		} else {

			// this will have an 'i' on the end;	
			$array = plural_array($display, $plural);

		}

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$array[0]', '$array[1]', '$array[2]', 11)";

		$result = mysql_query($sql);
	
		// PAST PERFECT;

		if ($conj_with == 'avere') { // populate the avere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=1 AND tense=5";
		
		} else { // populate the essere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=2 AND tense=5";
		
		}
				
		$result = mysql_query($sql) or die("The query cannot be completed.");
		$display = mysql_fetch_array($result) or die("The query cannot be completed.");
		$io = $display[io] . " " . $root;
		$tu = $display[tu] . " " . $root;
		$egli = $display[egli] . " " . $root;

		// the following function populates the compound tenses;

		if ($conj_with == 'avere') {

			// all participles wil end with 'o';
			$array = plural_array($display, $root);
	
		} else {

			// this will have an 'i' on the end;	
			$array = plural_array($display, $plural);

		}

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$array[0]', '$array[1]', '$array[2]', 12)";

		$result = mysql_query($sql);

		// PAST ANTERIOR;

		if ($conj_with == 'avere') { // populate the avere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=1 AND tense=6";
		
		} else { // populate the essere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=2 AND tense=6";
		
		}
				
		$result = mysql_query($sql) or die("The query cannot be completed.");
		$display = mysql_fetch_array($result) or die("The query cannot be completed.");
		$io = $display[io] . " " . $root;
		$tu = $display[tu] . " " . $root;
		$egli = $display[egli] . " " . $root;

		// the following function populates the compound tenses;

		if ($conj_with == 'avere') {

			// all participles wil end with 'o';
			$array = plural_array($display, $root);
	
		} else {

			// this will have an 'i' on the end;	
			$array = plural_array($display, $plural);

		}

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$array[0]', '$array[1]', '$array[2]', 13)";

		$result = mysql_query($sql);

		// FUTURE PERFECT;

		if ($conj_with == 'avere') { // populate the avere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=1 AND tense=7";
		
		} else { // populate the essere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=2 AND tense=7";
		
		}
				
		$result = mysql_query($sql) or die("The query cannot be completed.");
		$display = mysql_fetch_array($result) or die("The query cannot be completed.");
		if ($display[io] == "saro'") {
			// add a slash before the apostrophe or the query will bomb;
			$io = "saro\' " . $root;
		} else {
			$io = "avro\' " . $root;
		}
		$tu = $display[tu] . " " . $root;
		if ($display[egli] == "sara'") { 
			// add a slash before the apostrophe or the query will bomb;
			$egli = "sara\' " . $root;
		} else {
			$egli = "avra\' " . $root;
		}

		// the following function populates the compound tenses;

		if ($conj_with == 'avere') {

			// all participles wil end with 'o';
			$array = plural_array($display, $root);
	
		} else {

			// this will have an 'i' on the end;	
			$array = plural_array($display, $plural);

		}

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$array[0]', '$array[1]', '$array[2]', 14)";

		$result = mysql_query($sql);

		// PAST CONDITIONAL;

		if ($conj_with == 'avere') { // populate the avere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=1 AND tense=8";
		
		} else { // populate the essere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=2 AND tense=8";
		
		}
				
		$result = mysql_query($sql) or die("The query cannot be completed.");
		$display = mysql_fetch_array($result) or die("The query cannot be completed.");
		$io = $display[io] . " " . $root;
		$tu = $display[tu] . " " . $root;
		$egli = $display[egli] . " " . $root;

		// the following function populates the compound tenses;

		if ($conj_with == 'avere') {

			// all participles wil end with 'o';
			$array = plural_array($display, $root);
	
		} else {

			// this will have an 'i' on the end;	
			$array = plural_array($display, $plural);

		}

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$array[0]', '$array[1]', '$array[2]', 15)";

		$result = mysql_query($sql);

		// PAST SUBJUNCTIVE;

		if ($conj_with == 'avere') { // populate the avere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=1 AND tense=9";
		
		} else { // populate the essere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=2 AND tense=9";
		
		}
				
		$result = mysql_query($sql) or die("The query cannot be completed.");
		$display = mysql_fetch_array($result) or die("The query cannot be completed.");
		$io = $display[io] . " " . $root;
		$tu = $display[tu] . " " . $root;
		$egli = $display[egli] . " " . $root;

		// the following function populates the compound tenses;

		if ($conj_with == 'avere') {

			// all participles wil end with 'o';
			$array = plural_array($display, $root);
	
		} else {

			// this will have an 'i' on the end;	
			$array = plural_array($display, $plural);

		}

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$array[0]', '$array[1]', '$array[2]', 16)";

		$result = mysql_query($sql);

		// PAST PERFECT SUBJUNCTIVE;

		if ($conj_with == 'avere') { // populate the avere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=1 AND tense=10";
		
		} else { // populate the essere array;
	
			$sql = "SELECT * FROM verbs WHERE verb=2 AND tense=10";
		
		}
				
		$result = mysql_query($sql) or die("The query cannot be completed.");
		$display = mysql_fetch_array($result) or die("The query cannot be completed.");
		$io = $display[io] . " " . $root;
		$tu = $display[tu] . " " . $root;
		$egli = $display[egli] . " " . $root;

		// the following function populates the compound tenses;

		if ($conj_with == 'avere') {

			// all participles wil end with 'o';
			$array = plural_array($display, $root);
	
		} else {

			// this will have an 'i' on the end;	
			$array = plural_array($display, $plural);

		}

		$sql = "INSERT INTO verbs VALUES (null, $id, '$io', '$tu', '$egli', '$array[0]', '$array[1]', '$array[2]', 17)";

		$result = mysql_query($sql);

	return true;

}

?>
