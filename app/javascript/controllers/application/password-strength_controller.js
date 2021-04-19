import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["field", "progress"];

  // lifecycles
  connect() {
    import("zxcvbn").then((module) => {
      this.zxcvbn = module.default;
    });
  }

  // actions
  display(e) {
    const password = e.currentTarget.value;
    this.updateProgress(this.zxcvbn(password));
  }

  // private

  updateProgress({ score, password }) {
    switch (score) {
      case 0:
        this.progressWidth = `${password.length * 2}%`;
        this.progressColor = "bg-danger";
        break;
      case 1:
        this.progressWidth = "25%";
        this.progressColor = "bg-danger";
        break;
      case 2:
        this.progressWidth = "50%";
        this.progressColor = "bg-warning";
        break;
      case 3:
        this.progressWidth = "75%";
        this.progressColor = "bg-success";
        break;
      case 4:
        this.progressWidth = "100%";
        this.progressColor = "bg-success";
        break;
    }
  }

  set progressWidth(value) {
    this.progressTarget.style.width = value;
  }

  set progressColor(value) {
    this.progressTarget.classList.remove("bg-danger");
    this.progressTarget.classList.remove("bg-warning");
    this.progressTarget.classList.remove("bg-success");
    this.progressTarget.classList.add(value);
  }
}
