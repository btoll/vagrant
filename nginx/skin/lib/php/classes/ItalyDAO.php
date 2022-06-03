<?php
//include_once("./lib/php/interfaces/Email.php");

//class ItalyDAO extends DB implements Email {
//include("./lib/php/classes/DB.php");
//include("./lib/php/classes/Scrubber.php");
//include("./lib/php/classes/Template.php");
include(dirname(__FILE__)."/DB.php");
include(dirname(__FILE__)."/Scrubber.php");
include(dirname(__FILE__)."/Template.php");
class ItalyDAO extends DB {

  protected $scrubber;
  protected $template;
  protected $cleaned = array();
  protected $errors = array();

  public function __construct($vars = null) {
    parent::__construct();
    $this->scrubber = new Scrubber;
    $this->template = new Template;
    $this->cleaned = $this->scrubber->fromHtml($vars);
  }

  public function __destruct() {
    $this->closeConnection();
  }

  public function addWordSearch() {
    $query = $this->connection->Prepare("INSERT INTO word_search VALUES (?, ?, ?, null)");
    $this->connection->Execute($query, array($this->cleaned['phrase'], $this->cleaned['language'], $this->cleaned['ip']));
  }

  public function addWord() {
    $query = $this->connection->Prepare("INSERT INTO words VALUES (?, ?, ?, ?)");
    $this->connection->Execute($query, array($this->cleaned['italian'], $this->cleaned['pronunciation'], $this->cleaned['grammar'], $this->cleaned['translation']));

    echo $this->connection->ErrorNo() > 0 ?
      $this->template->duplicateRecord($this->scrubber->toHtml($this->cleaned['italian'])) :
        $this->template->newRecord($this->scrubber->toHtml($this->cleaned['italian']));
  }

  public function checkEmail($email) {
    $cleaned = $this->scrubber->scrubEmail($email);
    if (!$cleaned) {
      echo "<span style=\"color: purple; font-weight: bold;\">You did not enter a valid email address.</span>\n";
    } else {
      $query = $this->connection->Prepare("SELECT email FROM email_addresses WHERE email = ?");
      $rs = $this->connection->Execute($query, array($cleaned));
      if ($this->connection->ErrorNo() == 0) {
        if ($rs->RecordCount() > 0) {
          echo "<span style=\"color: red; font-weight: bold;\">This address already exists.  Please enter another.</span>\r\n";
        } else {
          $query = $this->connection->Prepare("INSERT INTO email_addresses VALUES (?)");
          $this->connection->Execute($query, array($cleaned));
          #$this->sendEmail($cleaned);
          #send me an email alerting me that someone has signed up;
          $this->sendEmail((object) array(
            "subscriber" => $cleaned,
            "message" => "You have just received a Word of the Day request from " . $cleaned,
            "subject" => "Word of the Day Request",
            "mail_to" => "benjam72@yahoo.com",
            "mail_from" => "wotd@benjamintoll.com"
          ));

          #send the user an email confirming their desire to receive the Word of the Day;
          $this->sendEmail((object) array(
            "message" => "You have just signed up to receive the Word of the Day from http://italy.benjamintoll.com.  If you feel you have received this message in error, simply reply to this email with 'unsubscribe' in the body of the message.",
            "subject" => "Word of the Day confirmation",
            "mail_to" => $cleaned,
            "mail_from" => "wotd@benjamintoll.com"
          ));
          echo "<span style=\"color: navy; font-weight: bold;\">The Word of the Day will be sent to the following email address:</span><br /><strong>$email</strong>\n";
        }
      }
    }
  }

  public function conjugateVerb($verb, $tense) {
    $this->cleaned = $this->scrubber->fromHtml(array($verb, $tense));
    $query = $this->connection->Prepare("SELECT * FROM verbs WHERE verb = ? AND tense = ?");
    $rs = $this->connection->GetRow($query, array($this->cleaned[0], $this->cleaned[1]));
    if ($this->connection->ErrorNo() == 0) {
      $json = new Services_JSON();
      echo $json->encode($rs);
    }
  }

  public function sendEmail($params) {
    mail($params->mail_to, $params->subject, $params->message, "From: " . $params->mail_from);
  }

  public function getCount($table) {
    $query = $this->connection->Prepare("SELECT * FROM " . $table);
    $rs = $this->connection->Execute($query);
    if ($this->connection->ErrorNo() == 0) {
      return number_format($rs->RecordCount());
    }
  }

  public function getLinks($id) {
    $query = $this->connection->Prepare("SELECT link, name FROM links WHERE type = ? ORDER BY name");
    $rs = $this->connection->GetAssoc($query, array($this->scrubber->toHtml($id)));
    if ($this->connection->ErrorNo() == 0) {
      return $this->template->getLinks($rs);
    }
  }

  public function getList($list, $selected) {
    switch ($list) {
      case "simple": $query = "SELECT id, tense FROM tenses WHERE type_tense = 1 ORDER BY id"; break;
      case "compound": $query = "SELECT id, tense FROM tenses WHERE type_tense = 2 ORDER BY id"; break;
      case "regular": $query = "SELECT id, verb FROM verb_list WHERE type = 1 ORDER BY verb"; break;
      case "irregular": $query = "SELECT id, verb FROM verb_list WHERE type = 2 ORDER BY verb"; break;
      case "reflexive": $query = "SELECT id, verb FROM verb_list WHERE type = 3 ORDER BY verb"; break;
    }
    $query = $this->connection->Prepare($query);
    $rs = $this->connection->GetAssoc($query);
    if ($rs) {
      echo $this->template->getList($this->scrubber->toHtml($rs), $this->scrubber->toHtml($list), $this->scrubber->toHtml($selected));
    }
  }

  public function getRandomWord() {
    $query = $this->connection->Prepare("SELECT * FROM words ORDER BY RAND()");
    $rs = $this->connection->GetRow($query);
    if ($rs) {
      echo $this->template->getRandomWord($this->scrubber->toHtml($rs));
    }
  }

  public function getWords() {
    $language = $this->cleaned['language'] === "italian" ? "italian" : "translation"; //"translation" == search for the English words;

    switch ($this->cleaned['match']) {
      case "like":
        $phrase = $this->cleaned['phrase'];
        $sql = "SELECT * FROM words WHERE $language LIKE ? ORDER BY italian, grammar";
        $arr = "%$phrase%";
        break;
      case "each_word":
        $phrase = str_replace(" ", "% AND {$this->cleaned['language']} LIKE %", $this->cleaned['phrase']);
        $sql = "SELECT * FROM words WHERE $language LIKE ? ORDER BY italian, grammar";
        $arr = "%$phrase%";
        break;
      case "exact":
        $phrase = $this->cleaned['phrase'];
        $sql = "SELECT * FROM words WHERE $language = ? ORDER BY italian, grammar";
        $arr = "%$phrase%";
    }

    $query = $this->connection->Prepare($sql);
    $rs = $this->connection->Execute($query, array($arr));
    //$rs = $this->connection->Execute($query, array($this->cleaned['language'], $this->cleaned['phrase']));
    //$rs = $this->connection->Execute($query, array($phrase));
    if ($rs) {
      return $rs;
    }
  }

}
?>

