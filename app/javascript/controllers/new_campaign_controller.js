import { Controller } from "stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  static values = { simulatePath: String }
  static targets = ["minAge", "maxAge", "maxDistance", "simulationResult", "simulateButton", "submitButton"]

  simulate(e) {
    e.preventDefault();
    this._disableSubmit()
    this.simulationResultTarget.innerHTML = ""

    const minAge = parseInt(this.minAgeTarget.value, 10) || 0
    const maxAge = parseInt(this.maxAgeTarget.value, 10) || 0
    const maxDistance = parseInt(this.maxDistanceTarget.value, 10) || 0

    debugger
    if (minAge == 0 || maxAge == 0 || maxDistance == 0) {
      this.simulationResultTarget.innerHTML =
        "Simulation impossible, merci de bien remplir les trois champs âge et distance"
      return
    }

    fetch(this.simulatePathValue, {
      method: "POST",
      credentials: 'same-origin',
      headers: {
        "X-CSRF-Token": Rails.csrfToken(),
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        campaign: {
          min_age: minAge,
          max_age: maxAge,
          max_distance_in_meters: maxDistance * 1000
        }
      })
    })
    .then(data => data.json())
    .then(result => {
      this.simulationResultTarget.innerHTML =
        `Nous avons trouvé ${result.reach} volontaires avec ces critères d'âge et de distance au centre`;
      if (result.reach > 0) {
        this._enableSubmit()
      } else {
        this._disableSubmit()
      }
    })
  }

  _disableSubmit() {
    this.submitButtonTarget.setAttribute("disabled", "disabled")
    this.submitButtonTarget.classList.add("d-none")
    this.simulateButtonTarget.classList.remove("btn-secondary")
    this.simulateButtonTarget.classList.add("btn-primary")
  }

  _enableSubmit() {
    this.submitButtonTarget.removeAttribute("disabled")
    this.submitButtonTarget.classList.remove("d-none")
    this.simulateButtonTarget.classList.remove("btn-primary")
    this.simulateButtonTarget.classList.add("btn-secondary")
  }
}
