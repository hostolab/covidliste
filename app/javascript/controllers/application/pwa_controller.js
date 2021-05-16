import { Controller } from "stimulus";

export default class extends Controller {
  static values = {
    deferredPrompt: Object,
  };

  connect() {
    this.element.style.display = "none";
  }

  configure(event) {
    event.preventDefault();

    this.deferredPromptValue = event;
    this.element.style.display = "block";

    this.element.addEventListener("click", onAddButtonClicked);
  }

  async onAddButtonClicked() {
    // hide our user interface that shows our A2HS button
    this.element.style.display = "none";
    // Show the prompt
    this.deferredPromptValue.prompt();
    // Wait for the user to respond to the prompt

    const choiceResult = await this.deferredPromptValue.userChoice;

    if (choiceResult.outcome === "accepted") {
      console.log("User accepted the A2HS prompt");
    } else {
      console.log("User dismissed the A2HS prompt");
    }
    this.deferredPromptValue = null;
  }
}
