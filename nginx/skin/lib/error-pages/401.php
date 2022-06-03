<!-- Authorization Required -->
<?php
include_once("../../header.php");
include_once("../mysql_queries.php");
?>
<body id="error_page">

<?php
include_once("../../menu.php");
?>
<div id="image">
  <img src="../images/raffaello.jpg" width="250" height="330" alt="Raffaello Sanzio" />
</div>  <!-- end div#image -->

<p>&nbsp;</p>
<div id="redirect">
  <p>Sorry, you don't seem to be on our guest list!</p>
  <p>The permissions may have been changed since your last visit.</p>
</div><!-- end div#redirect -->

<?php
include_once("../../footer.php");
?>