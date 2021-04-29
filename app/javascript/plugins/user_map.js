import "leaflet";

const userMap = () => {
  const user_map = document.getElementById("user_map");
  if (user_map) {
    let zoom = user_map.getAttribute("data-zoom") || 12;
    let lat = user_map.getAttribute("data-lat");
    let lon = user_map.getAttribute("data-lon");
    var lmap = L.map(user_map).setView([lat, lon], zoom);
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution:
        'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
      maxZoom: 14,
    }).addTo(lmap);
    lmap.panTo(new L.LatLng(lat, lon));
    L.circle([lat, lon], {
      color: "#0089fb",
      fillColor: "#0089fb",
      fillOpacity: 0.3,
      radius: 500,
    }).addTo(lmap);
  }
};

export { userMap };
