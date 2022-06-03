<!-- Internal Server Error -->
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
  <p>Sorry, there was an internal error on our server.</p>
  <p>It is not your fault, but sadly, there is nothing you can do about it!</p>
</div><!-- end div#redirect -->

<?php
include_once("../../footer.php");
?>