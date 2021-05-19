// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
// import * as ActiveStorage from "@rails/activestorage";
import "controllers/application";
// import "channels";
import "bootstrap";
import "bootstrap-select";
import "../components/fontawesome";
import "../components/confirmation";

Rails.start();
Turbolinks.start();
// ActiveStorage.start();

import { placesAutocomplete } from "../plugins/places_autocomplete";
import { leafletMap } from "../plugins/leaflet_map";
import { userMap } from "../plugins/user_map";
import { togglePasswordVisibility } from "../components/toggle_password_visibility";
import { smoothScrollAnchor } from "../components/smooth_scroll_anchor";
import { toggleMobileMatchInformation } from "../components/toggle_mobile_match_information";
document.addEventListener("turbolinks:load", () => {
  const appId = process.env.PLACES_APP_ID;
  const apiKey = process.env.PLACES_API_KEY;
  placesAutocomplete(appId, apiKey);
  leafletMap();
  userMap();
  togglePasswordVisibility();
  smoothScrollAnchor();
  toggleMobileMatchInformation();
  $('[data-toggle="tooltip"]').tooltip();

  // webpack will load this JS async
  if (document.getElementById("fuzzy-search")) {
    import("../plugins/fuzzy_search");
  }
});
