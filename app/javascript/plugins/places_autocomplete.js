import places from "places.js";

const placesAutocomplete = (appId, apiKey) => {
  // User Form
  const addressInput = document.getElementById("user_address");
  const userLatInput = document.getElementById("user_lat");
  const userLonInput = document.getElementById("user_lon");
  if (addressInput) {
    const p = places({
      container: addressInput,
      appId: appId,
      apiKey: apiKey,
      templates: {
        value: formattedAdress,
        suggestion: formattedAdress,
      },
    }).configure({
      language: "fr",
      countries: ["fr"],
    });
    p.on("change", function (e) {
      let latlng = e.suggestion.latlng;
      userLatInput.value = latlng["lat"];
      userLonInput.value = latlng["lng"];
    });
  }
  // 3 Rue de la Paix, 75002 Paris 2e Arrondissement, undefined

  // Vaccination Center Signup Form
  const centerAddressInput = document.getElementById(
    "vaccination_center_address"
  );
  const centerDepartmentInput = document.getElementById(
    "vaccination_center_department"
  );
  if (centerAddressInput) {
    const p = places({
      container: centerAddressInput,
      appId: appId,
      apiKey: apiKey,
      templates: {
        value: formattedAdress,
        suggestion: formattedAdress,
      },
    }).configure({
      language: "fr",
      countries: ["fr", "gy", "gp", "re", "mq", "yt"],
    });

    p.on("change", ({ suggestion }) => {
      centerDepartmentInput.value = suggestion.county;
    });
  }
};

function formattedAdress(reponse) {
  // overide Algolia default address formating that includes French region but not the Zip code.
  // french region can confuse the address geocoding API
  var addressParts = [
    reponse.name,
    reponse.postcode,
    reponse.city,
    reponse.administrative,
  ];

  // We skipped country field if it's a DOM TOM as Algolia sent us France by default when it's one of them
  var excludeCountryFilters = [
    "Guyane",
    "Guadeloupe",
    "La Réunion",
    "Martinique",
    "Mayotte",
  ];
  if (excludeCountryFilters.indexOf(reponse.administrative) == -1) {
    addressParts.push(reponse.country);
  }

  var formattedString = addressParts.filter((e) => e !== "undefined").join(" ");
  return formattedString;
}

export { placesAutocomplete };
