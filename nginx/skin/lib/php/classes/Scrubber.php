<?php

class Scrubber {
  private $cleaned;
  private $reEmail = "/^([0-9a-z]+)([0-9a-z\.-_]+)@([0-9a-z\.-_]+)\.([0-9a-z]+)/";

  private function in($value) {
    return strip_tags(trim($value));
  }

  private function out($value) {
    return htmlentities(trim($value));
  }

  public function fromHtml($vars) {
    if (is_array($vars)) {
      $this->cleaned = array();
      foreach ($vars as $key => $value) {
        $this->cleaned[$key] = $this->in($value);
      }
      return $this->cleaned;
    } else {
      return $this->in($vars);
    }
  }

  public function scrubEmail($email) {
    $email = $this->out($email);
    return !preg_match($this->reEmail, $email) ? FALSE : $email;
  }

  public function toHtml($vars) {
    if (is_array($vars)) {
      $this->cleaned = array();
      foreach ($vars as $key => $value) {
        $this->cleaned[$key] = $this->out($value);
      }
      return $this->cleaned;
    } else {
      return $this->out($vars);
    }
  }
}
?>

