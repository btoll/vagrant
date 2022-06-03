<?php
include(dirname(__FILE__)."/../../../../italy.php");
include(dirname(__FILE__)."/../../../../ADOdb-5.21.3/adodb.inc.php");
include(dirname(__FILE__)."/../../../../ADOdb-5.21.3/adodb-errorpear.inc.php");
//include_once("./db/ADOdb-5.21.3/adodb-pager.inc.php");
//include_once("./db/ADOdb-5.21.3/adodb-exceptions.inc.php");

class DB {
  protected $connection;

  public function __construct() {
    $this->connection = ADONewConnection("mysql://" . DB_Config::DBUSER . ":" . DB_Config::DBPASS . "@" . DB_Config::DBHOST . "/" . DB_Config::DBNAME . "?persist");
  }

  protected function closeConnection() {
    $this->connection->Close();
  }
}
?>

