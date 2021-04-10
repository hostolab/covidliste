import { Controller } from "stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
  static values = { simulatePath: String, maxDistanceInKm: Number }
  static targets = [
    "minAge", 
    "maxAge", 
    "maxDistance", 
    "availableDoses", 
    "vaccineType", 
    "simulationResult", 
    "simulateButton", 
    "submitButton"
  ];

  simulate(e) {
    e.preventDefault();
    this._disableSubmit();
    this.simulationResultTarget.innerHTML = "";

    const minAge = parseInt(this.minAgeTarget.value, 10) || 0
    const maxAge = parseInt(this.maxAgeTarget.value, 10) || 0
    const availableDoses = parseInt(this.availableDosesTarget.value, 10) || 0
    const vaccineType = this.vaccineTypeTarget.value || ""
    const maxDistance = parseInt(this.maxDistanceTarget.value, 10) || 0

    if (minAge == 0 || maxAge == 0 || maxDistance == 0 || availableDoses == 0) {
      this.simulationResultTarget.innerHTML =
        "Simulation impossible, merci de bien remplir les trois champs âge et distance";
      return;
    }

    if (maxDistance > this.maxDistanceInKmValue) {
      this.simulationResultTarget.innerHTML = `Simulation impossible, merci de préciser une distance inférieure ou égale à ${this.maxDistanceInKmValue} km`;
      return;
    }

    fetch(this.simulatePathValue, {
      method: "POST",
      credentials: "same-origin",
      headers: {
        "X-CSRF-Token": Rails.csrfToken(),
        "Content-Type": "application/json",
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
        `Nous avons trouvé ${result.reach} volontaires avec ces critères d'âge et de distance au centre.`;
      if (result.reach > 0) {
        this._enableSubmit()
        if (this.betterSelection(result.reach, availableDoses, vaccineType)) {
          this.simulationResultTarget.innerHTML +=
            `<br/> Au vu du nombre de volontaires trouvés et du nombre de doses de vaccin, nous vous conseillons d'élargir vos critères de sélections (âge et/ou distance).`
        }
      } else {
        this._disableSubmit()
      }
    })
  }

  /**
   * Returns true if reach is too low for the doses quantity. Depends of vaccine type
   * @param {Number} reach 
   * @param {Number} doses 
   * @param {'pfizer'|'moderna'|'astrazeneca'|'janssen'} vaccineType 
   * @returns {boolean}
   */
  betterSelection(reach, doses, vaccineType) {
    switch (vaccineType){
      case 'pfizer':
      case 'moderna':
        return doses > reach * 5
      
      case 'astrazeneca':
        return doses > reach * 20
      default:
        return doses > reach * 5
    }
  }

  _disableSubmit() {
    this.submitButtonTarget.setAttribute("disabled", "disabled");
    this.submitButtonTarget.classList.add("d-none");
    this.simulateButtonTarget.classList.remove("btn-secondary");
    this.simulateButtonTarget.classList.add("btn-primary");
  }

  _enableSubmit() {
    this.submitButtonTarget.removeAttribute("disabled");
    this.submitButtonTarget.classList.remove("d-none");
    this.simulateButtonTarget.classList.remove("btn-primary");
    this.simulateButtonTarget.classList.add("btn-secondary");
  }
}
