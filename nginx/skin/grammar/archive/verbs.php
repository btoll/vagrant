<?php
# by Benjamin Toll (ben@benjamintoll.com)
# rewrite began on July 9, 2005
# last modified on November 27, 2008

include_once("../lib/php/verbs.php");
include_once("../header.php");
include_once("../lib/php/search_engines.php");
?>
<body id="grammar">

  <?php
  include_once("../menu.php");
  ?>

  <div id="image">
    <img src="/images/raffaello.jpg" width="250" height="330" alt="Raffaello Sanzio" />
    <br />
  </div>

  <div id="text">

    <h3>I Verbi</h3>
    <form id="verbTypesForm">

      <p>
        <strong>Select a verb:</strong><br />
        <select id="regular" name="regular"><option value=""><strong>Regular</strong></option>
        <?php
        // create the regular verbs drop-down list;
        regular_verbs($_POST['regular']);
        ?>
        </select>
        <select id="irregular" name="irregular"><option value=""><strong>Irregular</strong></option>
        <?php
        // create the irregular verbs drop-down list;
        irregular_verbs($_POST['irregular']);
        ?>
        </select>
        <select id="reflexive" name="reflexive"><option value=""><strong>Reflexive</strong></option>
        <?php
        // create the irregular verbs drop-down list;
        reflexive_verbs($_POST['reflexive']);
        ?>
        </select>
        <input class="clear" type="button" id="clearVerbs" value="Clear" />
      </p>

      <p>
        <strong>Select a tense:</strong><br />
        <select id="simple" name="simple"><option value=""><strong>Simple</strong></option>
        <?php
        // create the simple tenses drop-down list;
        simple_tenses_list($_POST['simple']);
        ?>
        </select>
        <select id="compound" name="compound"><option value=""><strong>Compound</strong></option>
        <?php
        // create the compound tenses drop-down list;
        compound_tenses_list($_POST['compound']);
        ?>
        </select>
        <input class="clear" type="button" id="clearTenses" value="Clear" />
      </p>

      <p><label><input class="submit" type="submit" name="submit" value="Submit" /></label> <label><input class="submit" type="submit" id="refresh" name="refresh" value="Clear All" /></label></p>

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
      </div><!--end div#conjugatedVerb-->

    </form>
  </div><!--end div#text-->

  <?php
  include_once("http://www.benjamintoll.com/italy/footer.php");
  ?>