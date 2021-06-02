import "leaflet";

const userMap = () => {
  const user_map = document.getElementById("user_map");
  if (user_map) {
    let lat = user_map.getAttribute("data-lat");
    let lon = user_map.getAttribute("data-lon");
    let radius = (user_map.getAttribute("data-rayon") || 0.5) * 1000
    let zoom = 9;
    if (radius <= 5000){
      zoom = 11;
    }else if (radius <= 2000){
      zoom = 12;
    }
    else if (radius <= 1000){
      zoom = 13;
    }
    var lmap = L.map(user_map).setView([lat, lon], zoom);
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution:
        'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
      maxZoom: 14,
    }).addTo(lmap);
    //lmap.panTo(new L.LatLng(lat, lon));
    L.circle([lat, lon], {
      color: "#0089fb",
      fillColor: "#0089fb",
      fillOpacity: 0.3,
      radius: radius,
    }).addTo(lmap);
  }
};

export { userMap };
