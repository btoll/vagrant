<?php
$body_id = "links";
include_once("../lib/includes/header.php");
#include("../lib/php/classes/ItalyDAO.php");
#$links = new ItalyDAO();
?>
    <main>
        <article id="text">
            <?php
                $arr = array("Museums and Galleries", "International News", "Hotels and Hostels", "Miscellaneous");
                //map each array element to the link type in the table;
                for ($i = 0; $i < count($arr); $i++) {
                    echo "<h4>" . $arr[$i] . "</h4>\n";
                    foreach ($links->getLinks($i) as $link) {
                        echo $link;
                    }
                }
            ?>
        </article>
    </main>
    <?php
    include_once("../lib/includes/footer.php");
    ?>

