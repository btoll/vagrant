<?php

final class Template {

  private $elements;

  public function getLinks($links) {
    $this->elements = array();
    foreach ($links as $url => $name) {
      $this->elements[] = "\t<a href='$url' rel=\"external\">$name</a>\n";
    }
    return $this->elements;
  }

  public function getList($options, $list, $selected = NULL) {
    $this->elements = array();
    $this->elements[] = "\n<select id='$list' name='$list'><option value=''><strong>" . ucfirst($list) . "</strong></option>";
    foreach ($options as $value => $text) {
      if ($value === $selected) {
        $this->elements[] =  "\t<option value='$value' selected=\"selected\">$text</option>\n";
      } else {
        $this->elements[] =  "\t<option value='$value'>$text</option>\n";
      }
    }
    $this->elements[] = "</select>\n";
    return implode($this->elements);
  }

  public function getRandomWord($rs) {
    return "<strong>{$rs['italian']}</strong> [<span style=\"color: red;\">{$rs['pronunciation']}</span>], {$rs['grammar']}: <span style=\"color; navy;\"><strong>{$rs['translation']}</strong></span>\n";
  }


  public function duplicateRecord($name) {
    return "<p><strong>$name</strong> has <span style=\"color:red;\">already been entered</span> into the database.</p>\n";
  }

  public function newRecord($name) {
    return "<p><strong>$name</strong> was <span style=\"color:navy;\">successfully entered</span> into the database.</p>\n";
  }

}
?>

