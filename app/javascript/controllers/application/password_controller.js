import { Controller } from "stimulus";
var zxcvbn = require("zxcvbn");

const passwordScores = {
  0: { message: "Très faible", isValid: false },
  1: { message: "Faible", isValid: false },
  2: { message: "Moyen", isValid: false },
  3: { message: "Robuste", isValid: true },
  4: { message: "Très robuste", isValid: true },
};

export default class extends Controller {
  static targets = ["password", "passwordCheck"];

  check(e) {
    const password = this.passwordTarget.value;
    let message = "";
    let isValid = false;
    if (password.length < 8) {
      message = "Trop court";
      isValid = false;
    } else {
      let score = zxcvbn(password).score;
      let scoreInfo = passwordScores[score];
      message = scoreInfo.message;
      isValid = scoreInfo.isValid;
    }
    this.passwordCheckTarget.innerHTML = message;
    this.passwordCheckTarget.classList.add(
      isValid ? "text-success" : "text-danger"
    );
    this.passwordCheckTarget.classList.remove(
      isValid ? "text-danger" : "text-success"
    );

    this.passwordTarget.setCustomValidity(
      isValid ? "" : "Veuillez choisir un mot de passe robuste ou très robuste"
    );
  }
}
