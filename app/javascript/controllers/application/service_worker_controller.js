import { Controller } from "stimulus";

export default class extends Controller {
  static values = {
    path: String,
  };

  connect() {
    if (this._isServiceWorkerSupported()) {
      navigator.serviceWorker
        .register(this.pathValue)
        .then((reg) => console.log("Service Worker Registered", reg))
        .catch((error) =>
          console.error("Service worker registration failed: " + error)
        );
    }
  }

  _isServiceWorkerSupported() {
    return "caches" in window && "serviceWorker" in navigator;
  }
}
