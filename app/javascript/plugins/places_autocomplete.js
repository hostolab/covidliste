import places from "places.js";

const placesAutocomplete = (appId, apiKey) => {
  // User Form
  const addressInput = document.getElementById("user_address");
  if (addressInput) {
    places({
      container: addressInput,
      appId: appId,
      apiKey: apiKey,
      templates: {
        value: formattedValue,
        suggestion: formattedSuggestion,
      },
    }).configure({
      language: "fr",
      countries: ["fr"],
    });
  }
  // 3 Rue de la Paix, 75002 Paris 2e Arrondissement, undefined

  // Vaccination Center Signup Form
  const centerAddressInput = document.getElementById(
    "vaccination_center_address"
  );
  const centerLatInput = document.getElementById("vaccination_center_lat");
  const centerLonInput = document.getElementById("vaccination_center_lon");
  if (centerAddressInput) {
    let p = places({
      container: centerAddressInput,
      appId: appId,
      apiKey: apiKey,
      templates: {
        value: formattedValue,
        suggestion: formattedSuggestion,
      },
    }).configure({
      language: "fr",
      countries: ["fr"],
    });
  }
};

function formattedValue(reponse) {
  // overide Algolia default address formating that includes French region but not the Zip code.
  // french region can confuse the address geocoding API
  return [reponse.name, reponse.postcode, reponse.city, reponse.country]
    .filter((e) => e !== "undefined")
    .join(" ");
}

function formattedSuggestion(reponse) {
  // overide Algolia default address formating suggestion that includes French region but not the Zip code.
  return [reponse.name, reponse.postcode, reponse.city, reponse.country]
    .filter((e) => e !== "undefined")
    .join(" ");
}

export { placesAutocomplete };
