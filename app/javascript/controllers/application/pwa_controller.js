import { Controller } from "stimulus";

export default class extends Controller {
  static values = {
    deferredPrompt: Object,
  };

  connect() {
    this.element.style.display = "none";
  }

  configure(beforeinstallpromptEvent) {
    beforeinstallpromptEvent.preventDefault();

    this.element.style.display = "block";

    this.element.addEventListener("click", async () => {
      // hide our user interface that shows our A2HS button
      this.element.style.display = "none";
      // Show the prompt

      beforeinstallpromptEvent.prompt();
      // Wait for the user to respond to the prompt

      const choiceResult = await beforeinstallpromptEvent.userChoice;

      if (choiceResult.outcome === "accepted") {
        console.log("User accepted the A2HS prompt");
      } else {
        console.log("User dismissed the A2HS prompt");
      }
    });
  }
}
