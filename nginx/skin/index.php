<?php
$body_id = "home";
include_once("./lib/includes/header.php");
#include("../lib/php/classes/ItalyDAO.php");
#$links = new ItalyDAO();
?>
    <main>
        <article id="text">
                <form id="dictionaryForm" method="get" action="<?=$_SERVER['PHP_SELF']?>">
                    <p>There are <b>
                    <?=htmlentities($dict->getCount("words"));?>
                    </b> words and expressions in the database.</p>
                    <h4>Enter a word to get its translation:</h4>
                    <label><input type="text" name="phrase" id="phrase" class="text" /></label>
                    <label><input type="radio" name="match" value="like" checked="checked" /> Must Contain Entire Phrase, In Exact Order</label>
                    <label><input type="radio" name="match" value="each_word" /> Must Contain Each Word In Phrase, In Any Order</label>
                    <label><input type="radio" name="match" value="exact" /> Exact Match - Entire Phrase</label>
                    <hr />
                    <h4>The above text is in:</h4>
                    <label><input type="radio" name="language" value="italian" checked="checked" /> Italian</label>
                    <label><input type="radio" name="language" value="english" /> English</label>
                    <p><label><input class="submit" type="submit" value="Search" /></label> <label><input class="submit" type="reset" id="reset" name="reset" value="Clear" /></label></p>

                    <div id="displayWords">
                    <?php
                    if (isset($_GET['phrase']))
                    include_once("./lib/php/word_search.php");
                    ?>
                    </div>
                </form>
        </article>
    </main>
</body>
</html>

