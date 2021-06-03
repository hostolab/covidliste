import "leaflet";
import "leaflet.markercluster";
import "leaflet-spin";
import "leaflet-ajax";

const leafletMap = () => {
  let leafletMapContainers = document.getElementsByClassName(
    "leaflet_map_container"
  );
  for (let i = 0; i < leafletMapContainers.length; ++i) {
    let leafletMapContainer = leafletMapContainers[i];

    let leafletMap = leafletMapContainer
      .getElementsByClassName("leaflet_map")
      .item(0);
    if (leafletMap) {
      let zoom = leafletMap.getAttribute("data-zoom") || 13;
      let lat = leafletMap.getAttribute("data-lat") || 48.8534;
      let lon = leafletMap.getAttribute("data-lon") || 2.3488;
      let address = leafletMap.getAttribute("data-address") || "";
      let icon = leafletMap.getAttribute("data-icon");
      let maxZoom = leafletMap.getAttribute("data-max-zoom");
      let canvas = !!leafletMap.getAttribute("data-canvas");

      let lmap = L.map(leafletMap, {
        preferCanvas: canvas,
      }).setView([lat, lon], zoom);

      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution:
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> & <a href="https://mapicons.mapsmarker.com">Maps Icons Collection</a>',
      }).addTo(lmap);

      if (maxZoom) {
        lmap.setMaxZoom(parseInt(maxZoom));
      }

      if (icon) {
        let centerIcon = new L.icon({
          iconUrl: icon,
          iconSize: [32, 37],
          iconAnchor: [16, 37],
          popupAnchor: [0, -37],
        });
        L.marker([lat, lon], { icon: centerIcon })
          .addTo(lmap)
          .bindPopup(address);
      }

      let border = leafletMap.getAttribute("data-border");
      if (border) {
        let bounds = JSON.parse(border);
        L.rectangle(bounds, { color: "#000e79", weight: 1, fill: false }).addTo(
          lmap
        );
        lmap.fitBounds(bounds);
        lmap.panTo([lat, lon]);
      }

      let leafletMarkers = leafletMapContainer.getElementsByClassName(
        "leaflet-marker"
      );
      if (leafletMarkers) {
        let leafletMarkersCluster = L.markerClusterGroup();
        for (let i = 0; i < leafletMarkers.length; ++i) {
          let leafletMarker = leafletMarkers[i];
          let markerLat = leafletMarker.getAttribute("data-lat");
          let markerLon = leafletMarker.getAttribute("data-lon");
          let markerIcon = leafletMarker.getAttribute("data-icon");
          let markerText = leafletMarker.innerHTML || "";
          if (markerLat && markerLon) {
            let marker = L.marker([markerLat, markerLon]);
            if (markerIcon) {
              let icon = new L.icon({
                iconUrl: markerIcon,
                iconSize: [32, 37],
                iconAnchor: [16, 37],
                popupAnchor: [0, -37],
              });
              marker = L.marker([markerLat, markerLon], { icon: icon });
            }
            marker.bindPopup(markerText);
            leafletMarkersCluster.addLayer(marker);
          }
        }
        lmap.addLayer(leafletMarkersCluster);
      }

      let leafletGeojsons = leafletMapContainer.getElementsByClassName(
        "leaflet-geojson"
      );
      if (leafletGeojsons) {
        let geojsonCodes = {};
        for (let i = 0; i < leafletGeojsons.length; ++i) {
          let leafletGeojson = leafletGeojsons[i];
          let geojsonUrl = leafletGeojson.getAttribute("data-url");
          let geojsonData = leafletGeojson.getAttribute("data-geojson");
          let geojsonHide = !!leafletGeojson.getAttribute("data-hide");
          let geojsonPane =
            leafletGeojson.getAttribute("data-pane") || "overlayPane";
          let geojsonName =
            leafletGeojson.getAttribute("data-name") ||
            Math.random().toString(36).substring(2);
          if (geojsonUrl) {
            let geoLayer = L.geoJSON.ajax(geojsonUrl, {
              pane: geojsonPane,
              pointToLayer: function (feature, latlng) {
                let style = { radius: 10 };
                if (feature.properties && feature.properties.style) {
                  style = feature.properties.style;
                }
                return L.circle(latlng, style);
              },
              style: function (feature) {
                if (feature.properties && feature.properties.style) {
                  return feature.properties.style;
                }
              },
              onEachFeature: function (feature, layer) {
                if (feature.properties && feature.properties.popupContent) {
                  layer.bindPopup(feature.properties.popupContent);
                }
              },
            });
            if (!geojsonHide) {
              geoLayer.addTo(lmap);
            }
            geojsonCodes[geojsonName] = geoLayer;
          } else if (geojsonData) {
            let geoLayer = L.geoJSON(geojsonData, {
              pane: geojsonPane,
              pointToLayer: function (feature, latlng) {
                let style = { radius: 10 };
                if (feature.properties && feature.properties.style) {
                  style = feature.properties.style;
                }
                return L.circle(latlng, style);
              },
              style: function (feature) {
                if (feature.properties && feature.properties.style) {
                  return feature.properties.style;
                }
              },
              onEachFeature: function (feature, layer) {
                if (feature.properties && feature.properties.popupContent) {
                  layer.bindPopup(feature.properties.popupContent);
                }
              },
            });
            if (!geojsonHide) {
              geoLayer.addTo(lmap);
            }
            geojsonCodes[geojsonName] = geoLayer;
          }
        }
        L.control.layers({}, geojsonCodes, { collapsed: false }).addTo(lmap);
      }

      let leafletFlyBtns = leafletMapContainer.getElementsByClassName(
        "leaflet_fly_btn"
      );
      for (let i = 0; i < leafletFlyBtns.length; ++i) {
        let leafletFlyBtn = leafletFlyBtns[i];
        let elemLat = leafletFlyBtn.getAttribute("data-lat");
        let elemLon = leafletFlyBtn.getAttribute("data-lon");
        let elemZoom = leafletFlyBtn.getAttribute("data-zoom") || zoom;
        let elemSmooth = leafletFlyBtn.getAttribute("data-smooth");
        if (elemLat && elemLon) {
          leafletFlyBtn.addEventListener(
            "click",
            function () {
              if (elemSmooth) {
                lmap.flyTo([elemLat, elemLon], elemZoom);
              } else {
                lmap.setView([elemLat, elemLon], elemZoom);
              }
            },
            false
          );
        }
      }
    }
  }
};

export { leafletMap };
