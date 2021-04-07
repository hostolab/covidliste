// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "bootstrap-select"

Rails.start()
Turbolinks.start()
ActiveStorage.start()


// ----------------------------------------------------
// Note(lewagon): ABOVE IS RAILS DEFAULT CONFIGURATION
// WRITE YOUR OWN JS STARTING FROM HERE 👇
// ----------------------------------------------------

// External imports
import "bootstrap";

import { placesAutocomplete } from '../plugins/places_autocomplete';
import { leafletMap } from '../plugins/leaflet_map';
document.addEventListener('turbolinks:load', () => {
  const appId = process.env.PLACES_APP_ID;
  const apiKey = process.env.PLACES_API_KEY;
  placesAutocomplete(appId, apiKey);
  leafletMap();
  $('[data-toggle="tooltip"]').tooltip()
});
