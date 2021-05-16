import { Controller } from "stimulus";
var zxcvbn = require("zxcvbn");

const passwordScores = {
  0: { message: "Très faible", color: "red" },
  1: { message: "Faible", color: "red" },
  2: { message: "Moyen", color: "orange" },
  3: { message: "Robuste", color: "green" },
  4: { message: "Très robuste", color: "green" },
};

export default class extends Controller {
  static targets = ["password", "passwordCheck"];

  check(e) {
    const password = this.passwordTarget.value;
    let message = "";
    let color = "red";
    if (password.length < 8) {
      message = "Trop court";
      color = "red";
    } else {
      let score = zxcvbn(password).score;
      let scoreInfo = passwordScores[score];
      message = scoreInfo.message;
      color = scoreInfo.color;
    }
    this.passwordCheckTarget.innerHTML = message;
    this.passwordCheckTarget.style.color = color;
    this.passwordTarget.setCustomValidity("Veuillez choisir un mot de passe robuste ou très robuste")
  }
}
