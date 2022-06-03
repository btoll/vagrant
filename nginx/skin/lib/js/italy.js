/***********************************
methods in ITALIA:
  - addLoadEvent
  - clearTenses
  - clearVerbs
  - conjugation
  - fadeOut
  - fadeIn
  - getElementsByClassName
  - getGrammar
  - getQueries
  - getSelection
  - getStyle
  - getWords
  - getVerbs
  - init
  - pronunciationGuide
***********************************/

String.prototype.trim = function() {
  return this.replace(/^\s+|\s+$/, "");
};

var $ = function (sElem) {
  return document.getElementById(sElem);
};

var ITALIA = {
  /*********************************************************************************************************/
  /*********************************************************************************************************/
  addLoadEvent: function (func) {
    // this function allows multiple onload method calls to be made;
    var oldOnload = window.onload;
    if (typeof window.onload != 'function') {
      window.onload = func;
    } else {
      window.onload = function() {
        oldOnload();
        func();
      }
    }
  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  clearTenses: function () {
    $("simple").value = "";
    $("compound").value = "";
  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  clearVerbs: function () {
    $("regular").value = "";
    $("irregular").value = "";
    $("reflexive").value = "";
  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  conjugation: function (oConj) {
    /*places each conjugated verb into its proper conjugated box in verbs.php*/
    $("conjugatedVerb").style.display = "block";
    $("io").innerHTML = oConj.io;
    $("tu").innerHTML = oConj.tu;
    $("egli").innerHTML = oConj.egli;
    $("noi").innerHTML = oConj.noi;
    $("voi").innerHTML = oConj.voi;
    $("loro").innerHTML = oConj.loro;
  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  counter: 0, //for the images;
  fader : 0,

  fadeOut: function (oElem) {

    var vOpaque = document.addEventListener ? ITALIA.getStyle(oElem, "opacity") : ITALIA.getStyle(oElem, "filter");
    if (navigator.userAgent.toLowerCase().indexOf("msie") > -1) {
      vOpaque = parseInt(vOpaque.replace(/.*=(.+)\)/g, function (a, b) { return b; }));
    }

    //the following is a hack for chrome (at least v. 9.0), vOpaque would be ~.04888895 and it would never reach 0; tested on all browsers but IE;
    if (vOpaque < .05) {
      vOpaque = 0;
    }

    if (vOpaque > 0) { //fade the elem;
      document.addEventListener ? oElem.style.opacity = vOpaque - .05 : oElem.style.filter = "alpha(opacity=" + (vOpaque - 5) + ")";
      oElem.fade = setTimeout(function() { ITALIA.fadeOut(oElem); }, 150);
    } else if (vOpaque <= 0) {
      clearTimeout(oElem.fade);
      oElem.fade = null;
      $("image").src = ITALIA.cache[ITALIA.counter].src;
      $("imageDescription").innerHTML = ITALIA.cache[ITALIA.counter].alt;
      ITALIA.counter = ITALIA.counter < (ITALIA.cache.length - 1) ? ++ITALIA.counter : 0; //reset the counter if it's the length of the array minus one, else increment by one;
      setTimeout(function() { ITALIA.fadeIn($("imageContainer")); }, 150);
    }

  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  ceiling: document.addEventListener ? 1 : 100,
  fadeTime: 3500,

  fadeIn: function (oElem) {

    if (ITALIA.fader < ITALIA.ceiling) { //fade the elem;
      document.addEventListener ? oElem.style.opacity = ITALIA.fader + .05 : oElem.style.filter = "alpha(opacity=" + (ITALIA.fader + 5) + ")";
      oElem.fade = setTimeout(function() { ITALIA.fadeIn(oElem); }, 150);
      if (navigator.userAgent.toLowerCase().indexOf("msie") > -1) {
        ITALIA.fader += 5;
      } else {
        ITALIA.fader += .05;
      }
    } else if (ITALIA.fader >= ITALIA.ceiling) {
      clearTimeout(oElem.fade);
      oElem.fade = setTimeout(function() { ITALIA.fadeOut(oElem); }, ITALIA.fadeTime);
      ITALIA.fader = 0;
    }

  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  getElementsByClassName: function (sClassname, vRootElem, sSearchBy) {
    if (!sClassname) return false; //exit the function if no classname is provided;

    var aTemp = [];
    var reTemp = new RegExp("\\b" + sClassname + "\\b");
    if (vRootElem) {
      var cElems = $(vRootElem).getElementsByTagName(sSearchBy);
    } else {
      var cElems = document.getElementsByTagName("*") || document.all;
    }
    var cElemsLength = cElems.length;
    for (var i = 0, j = cElemsLength; i < j; i++) {
      if (reTemp.test(cElems[i].className)) {
        aTemp.push(cElems[i]);
      }
    }
    return aTemp;
  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  getGrammar: function (oList) {
    var sDivName = oList.options[oList.selectedIndex].value;
    var cGrammarList = $("grammarList");

    for (var i = 1, iLength = cGrammarList.length; i < iLength; i++) {
      if ("div" + i == sDivName) {
        $(sDivName).style.display = "block";
      } else {
        $("div" + i).style.display = "none";
      }
    }
  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  getQueries: function (sFunction, sDiv) {

    if (sFunction == "check_email") {
      var sEmail = $("email").value;
      var sURL = "../lib/php/ajax.php?function=" + sFunction + "&email=" + sEmail;
    } else {
      var sURL = "../lib/php/ajax.php?function=" + sFunction;
    }

    ITALIA.xhr.ajax({
      type: "GET",
      url: sURL,
      elem: sDiv, //the div where the "Waiting for search results" text will go;
      onSuccess: function (sResponseText) {
        $(sDiv).innerHTML = "";
        $(sDiv).innerHTML = sResponseText;
        if (sFunction == "random_word" || sFunction == "check_email") {
          $("email").value = "";
          $("email").focus();
        }
      }
    });
    return false;
  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  getSelection: function (cRadios) {
    for (var i = 0, iLength = cRadios.length; i < iLength; i++) {
      if (cRadios[i].checked) {
        return cRadios[i].value;
      }
    }
  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  getStyle: function (oElem, sName) {
    //if the property exists in style[] then it's been set recently and is current;
    if (oElem.style[sName]) {
      return oElem.style[sName];
    } else if (oElem.currentStyle) {
      return oElem.currentStyle[sName]; //otherwise, try to use IE's method;
    } else if (document.defaultView && document.defaultView.getComputedStyle) { //or the w3c's method, if it exists;
      //it uses the traditional 'text-align' style of rule writing instead of 'textAlign';
      sName = sName.replace(/([A-Z])/g, "-$1");
      sName = sName.toLowerCase();

      //get the style object and get the value of the property if it exists;
      var s = document.defaultView.getComputedStyle(oElem, "");
      return s && s.getPropertyValue(sName);

    //otherwise, we're using some other browser;
    } else {
      return null;
    }
  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  getVerbs: function (fnCallback) {

    var fnSelectionCounter = function (iIndex, sGrammar) {
      var cSelects = $("verbTypesForm").getElementsByTagName("p")[iIndex].getElementsByTagName("select"); //get each set of <select>s;
      var iCounter = 0;
      for (var i = 0, iLength = cSelects.length; i < iLength; i++) {
        if (cSelects[i].value) {
          iCounter++; //count the number of selections;
          var oResults = { //it doesn't matter if oResults is overwritten when multiple verbs or tenses are selected b/c it's only returned when the correct number of selections was made(1);
            value: cSelects[i].value,
            text: cSelects[i].options[cSelects[i].selectedIndex].text
          };
        }
      }
      switch (iCounter) {
        case 0:
          $("message").innerHTML = "Please select a " + sGrammar;
          return false;
          break;

        case 1:
          return oResults;
          break;

        case 2:
        case 3:
          $("message").innerHTML = "Please only select one " + sGrammar + " at a time";
          return false;
	  break;

      }
    };

    var oVerb = fnSelectionCounter(0, "verb");
    if (!oVerb) return false; //if the function returns false it's b/c a message will be displayed so exit the function;

    var oTense = fnSelectionCounter(1, "tense");
    if (!oTense) return false; //if the function returns false it's b/c a message will be displayed so exit the function;

    //if we made it this far then the correct number of selections was made;
    var sURL = "../../lib/php/ajax.php?function=conjugate_verb&verb=" + oVerb.value + "&tense=" + oTense.value;
    ITALIA.xhr.ajax({
      type: "GET",
      url: sURL,
      data: "json",
      elem: "message", //the div where the "Waiting for search results" text will go;
      onSuccess: function (sResponseText) {
        $("message").innerHTML = "<span style='color: #000;'><u>Verb</u> =</span> <span style='color: orange;'>" + oVerb.text + "</span><span style='margin-left: 20px; color: #000;'><u>Tense</u> =</span> <span style='color: orange;'>" + oTense.text + "</span>";
        fnCallback(sResponseText);
        return false; //don't submit the form;
      }
    });

  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  getWords: function (sURL, sPhrase, sLanguage, sMatch, iStart, iPages) {

    //if (!$("phrase").value) return false; //exit the function if an empty string is submitted;

    var sPhrase = sPhrase || $("phrase").value;
    var sMatch = sMatch || ITALIA.getSelection(document.getElementsByName("match")); //get the value of the checked radio button;
    var sLanguage = sLanguage || ITALIA.getSelection(document.getElementsByName("language"));

      var sURL = !iStart ? sURL + "?phrase=" + sPhrase + "&language=" + sLanguage + "&match=" + sMatch :
        sURL + "?phrase=" + sPhrase + "&language=" + sLanguage + "&match=" + sMatch + "&start=" + iStart + "&pages=" + iPages;

    ITALIA.xhr.ajax({
      type: "GET",
      url: sURL,
      elem: "displayWords", //the div where the "Waiting for search results" text will go;
      onSuccess: function (sResponseText) {
        $("displayWords").innerHTML = "";
        $("displayWords").innerHTML = sResponseText;
        $("phrase").value = "";
        $("phrase").focus();

        /*collect all the links with a class of "pronunciation" and attach the handler*/
        var cLinks = ITALIA.getElementsByClassName("pronunciation", "displayWords", "a");
        for (var i = 0, iLength = cLinks.length; i < iLength; i++) {
          cLinks[i].onclick = function () {
            ITALIA.pronunciationGuide();
            return false;
          };
        }
      }
    });

    return false; //don't submit the form;

  },

  cache: [],

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  init: function () {
    //exit the function if it's an old browser that doesn't support the DOM core;
    if (!document.getElementsByTagName) return false;
    if (!document.getElementById) return false;

    var aImages = [
      { src: "Bacchus_Sarto.jpg", description: "" },
      { src: "Pietro_Perugino_2.jpg", description: "" },
      { src: "Raffaello_St_George.jpg", description: "<em>St. George</em> (1503-05), Raffaello Sanzio" },
      { src: "Leonardo_St_Anne_cartoon.jpg", description: "<em>The Virgin and Child with St. Anne and St. John the Baptist</em> (1499-1500), Leonardo da Vinci" },
      { src: "Raffaello_Pope_Leo_X.jpg", description: "<em>Pope Leo X with Cardinals Giulio di Medici and Luigi di Rossi</em> (1518-19), Raffaello Sanzio" },
      { src: "Dante_Alighieri.jpg", description: "<em>Dante Alighieri</em> (c. 1336), Giotto di Bondone" },
      { src: "Giorgione_Laura.jpg", description: "" },
      { src: "Pintoricchio.jpg", description: "<em>Portrait of a Boy</em> (1481-83), Pinturicchio" },
      { src: "Uccello_Portrait_of_a_Lady.jpg", description: "<em>Portrait of a Lady</em> (1450), Paolo Uccello" },
      { src: "botticelli.jpg", description: "<em>Portrait of a Young Man</em> (1482-1483), Sandro Botticelli" },
      { src: "Fra_Bartolomeo_Girolamo_Savonarola.jpg", description: "<em>Girolamo Savonarola</em> (c. 1498), Fra Bartolomeo" },
      { src: "Giovanni_Bellini_Portrait_of_a_Condottiere.jpg", description: "<em>Portrait of a Condottiero</em> (1475-80), Giovanni Bellini" },
      { src: "Pietro_Perugino_1.jpg", description: "<em>Self-portrait</em> (1497-1500), Pietro Vannucci (detto Perugino)" },
      { src: "Tizian.jpg", description: "" },
      { src: "Sandro_Botticelli_self_portrait.jpg", description: "<em>Self-portrait</em> (c. 1500), Sandro Botticelli" },
      { src: "Cimabue.jpg", description: "" },
      { src: "Raffaello_Sanzio_self_portrait.jpg", description: "<em>Self-portrait</em> (1506), Raffaello Sanzio" },
      { src: "Leonardo_Die_Dame_mit_dem_Hermelin.jpg", description: "<em>Portrait of Cecilia Gallerani (Lady with an Ermine)</em> (1483-90), Leonardo da Vinci" },
      { src: "Filippino_Lippi_Portrait_of_a_Youth.jpg", description: "" },
      { src: "St_Anne.jpg", description: "" },
      { src: "Domenico_Ghirlandaio.jpg", description: "<em>An Old Man and His Grandson</em> (c. 1490), Domenico Ghirlandaio" },
      { src: "Giotto_self_portrait.jpg", description: "<em>Giotto</em> (early 1500s), Paolo Uccello" },
      { src: "raffaello.jpg", description: "<em>Portrait of Bindo Altoviti</em> (1512-15), Raffaello Sanzio" },
      { src: "Sandro_Botticelli.jpg", description: "" },
      { src: "Giovanni_Bellini_Il_Doge.jpg", description: "<em>Portrait of Doge Leonardo Loredan</em> (1501), Giovanni Bellini" }
    ];

    for (var p = 0, len = aImages.length; p < len; p++) {
      ITALIA.cache[p] = new Image();
      ITALIA.cache[p].src = "/images/" + aImages[p].src;
      ITALIA.cache[p].alt = aImages[p].description;
    }

    //set the description for the first image displayed (see lib/includes/header.php for the hardcoded first image displayed);
    $("imageDescription").innerHTML = ITALIA.cache[ITALIA.cache.length - 1].alt;

    var cLinks = document.getElementsByTagName("a");
    for (var i = 0, iLength = cLinks.length; i < iLength; i++) {
      cLinks[i].onfocus = function () {
        if (this.blur) this.blur();
      };

      //if a link's rel="external", have it open in a new window
      if (cLinks[i].rel == "external") {
        cLinks[i].onclick = function () {
          this.target = "_blank";
        };
      }
    }

    var cButtons = document.getElementsByTagName("input");
    for (var i = 0, iLength = cButtons.length; i < iLength; i++) {
      if (cButtons[i].getAttribute("class") && cButtons[i].getAttribute("class") == "submit" || cButtons[i].getAttribute("class") == "clear") {
        cButtons[i].onfocus = function () {
          if (this.blur) this.blur();
        };
      }
    }

/*
    //setup the ability to control the image animation;
    var oButton = document.createElement("input");
    oButton.type = "button";
    oButton.id = "imageController";
    oButton.value = "Pause";
    $("text").parentNode.insertBefore(oButton, $("text"));
    $("imageController").onclick = function () {
      if (this.value === "Pause") {
        clearTimeout($("imageContainer").fade);
        $("imageContainer").fade = null;
        this.value = "Play";
      } else {
        $("imageContainer").fade = setTimeout(function() { ITALIA.fadeOut($("imageContainer")); }, 0);
        this.value = "Pause";
      }
    };
*/

    /*attach the handlers and methods depending upon the page*/
    var sBody = document.getElementsByTagName("body")[0].id;
    switch (sBody) {
      case "dictionary":
        $("phrase").focus();
	$("dictionaryForm").onsubmit = function () {
	  ITALIA.getWords("lib/php/word_search.php");
	  return false;
	};
	$("reset").onclick = function () {
          $('phrase').focus();
	};
        break;

      case "grammar":
        /*
         1. hide the <h4> elements on the pages
         2. setup each div by applying display: none;
         3. create the <p> and the <select> list and insert into the DOM;
         4. attach the event handler to the list;
        */
        //if js is disabled, having these elements will allow for graceful degradation;
        var h = $("text").getElementsByTagName("h4");
        for (var i = 0, len = h.length; i < len; i++) {
          h[i].style.display = "none";
        }
        var oDivs = $("text").getElementsByTagName("div");
        for (var i = 0, len = oDivs.length; i < len; i++) {
          oDivs[i].style.display = "none";
        }

        var oSelect = document.createElement("select");
        oSelect.id = "grammarList";
        var oPara = document.createElement("p");
        if ($("text").getElementsByTagName("h3")[0].firstChild.nodeValue === "I Numeri") {
          var oOption = new Option("Select Numbers", "select");
          oSelect.add(oOption, undefined);
          oOption = new Option("0 to 20", "div1");
          oSelect.add(oOption, undefined);
          oOption = new Option("21 to 40", "div2");
          oSelect.add(oOption, undefined);
          oOption = new Option("41 to 60", "div3");
          oSelect.add(oOption, undefined);
          oOption = new Option("61 to 80", "div4");
          oSelect.add(oOption, undefined);
          oOption = new Option("81 to 100", "div5");
          oSelect.add(oOption, undefined);
          oOption = new Option("Hundreds...", "div6");
          oSelect.add(oOption, undefined);
          oOption = new Option("Thousands...", "div7");
          oSelect.add(oOption, undefined);
          oOption = new Option("Millions...", "div8");
          oSelect.add(oOption, undefined);
          oOption = new Option("Billions...", "div9");
          oSelect.add(oOption, undefined);
          oOption = new Option("Ordinal Numbers...", "div10");
          oSelect.add(oOption, undefined);
          oPara.appendChild(document.createTextNode("Select your numbers from the list below:"));
        } else {
          var oOption = new Option("Select Pronouns", "select");
          oSelect.add(oOption, undefined);
          oOption = new Option("Direct Object", "div1");
          oSelect.add(oOption, undefined);
          oOption = new Option("Indirect Object", "div2");
          oSelect.add(oOption, undefined);
          oOption = new Option("Reflexive", "div3");
          oSelect.add(oOption, undefined);
          oOption = new Option("Disjunctive", "div4");
          oSelect.add(oOption, undefined);
          oOption = new Option("Possessive", "div5");
          oSelect.add(oOption, undefined);
          oPara.appendChild(document.createTextNode("Select your pronouns from the list below:"));
        }
        $("text").getElementsByTagName("h4")[0].parentNode.insertBefore(oSelect, $("text").getElementsByTagName("h4")[0]);
        $("grammarList").parentNode.insertBefore(oPara, $("grammarList"));

        if ($("grammarList")) { //for the <select> in numbers.php and pronouns.php;
          $("grammarList").onchange = function () {
            ITALIA.getGrammar(this);
          };
        }
        break;

      case "verbs":
        if ($("verbTypesForm")) { //remember for convenience numbers.php, pronouns.php and verbs.php all have body#grammar;
          $("verbTypesForm").onsubmit = function () {
            ITALIA.getVerbs(ITALIA.conjugation); //pass the method that uses innerHTML to display each piece of data in the table;
	    return false;
	  };
          $("clearVerbs").onclick = ITALIA.clearVerbs;
          $("clearTenses").onclick = ITALIA.clearTenses;
          $("refresh").onclick = function () {
            ITALIA.clearVerbs();
            ITALIA.clearTenses();
	  };
	}
        break;

      case "wotd":
        $("email").focus();
        $("wotdForm").onsubmit = function () {
          ITALIA.getQueries("check_email", "response")
	  return false;
        };
	$("refreshForm").onsubmit = function () {
          ITALIA.getQueries("random_word", "random");
	  return false;
        };
        break;

    }

    //finally enable the image animation behavior for each page;
/*
    ITALIA.counter = Math.floor(Math.random() * ITALIA.cache.length + 0); //randomize the start point;
    $("imageContainer").innerHTML = "";
    $("imageContainer").appendChild(ITALIA.cache[ITALIA.counter++]); //use the unary operator to ensure that the counter is incremented so the next picture isn't the same one as on page load;
*/
    setTimeout(function() { ITALIA.fadeOut($("imageContainer")); }, ITALIA.fadeTime);

  },

  /*********************************************************************************************************/
  /*********************************************************************************************************/
  pronunciationGuide: function () {
    var sArgs = "width=520,height=450,left=252,top=159,scrollbars=yes,location=no";
    window.open("mini_guide.php", "new_win", sArgs);
  }
};

ITALIA.addLoadEvent(ITALIA.init);

