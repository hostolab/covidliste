import { Controller } from "stimulus";

import { Deck } from "@deck.gl/core";
import { GridCellLayer, GeoJsonLayer, IconLayer } from "@deck.gl/layers";
import mapboxgl from "mapbox-gl";
import { scaleLinear } from "d3-scale";

import departements from "./departements-version-simplifiee.json";
import popByCode from "./pop2021.json";

// const UNKNOW_DEPT_COLOR = [220, 220, 220];
const UNKNOW_DEPT_COLOR = [50, 100, 238];

const TERRITOIRES = {
  METROPOLE: {
    label: "France métropolitaine",
    lon: 2.3,
    lat: 46.5,
    zoom: 4.5,
  },
  GUYANNE: {
    label: "Guyanne",
    lon: -53.02730090442361,
    lat: 4,
    zoom: 6.5,
  },
  GUADELOUPE: {
    label: "Gadeloupe",
    lon: -61.5,
    lat: 16.176021024448076,
    zoom: 9,
  },
  REUNION: {
    label: "La Réunion",
    lon: 55.53913649067738,
    lat: -21.153674695744286,
    zoom: 9,
  },
  MARTINIQUE: {
    label: "Martinique",
    lon: -60.97336870145841,
    lat: 14.632175285699219,
    zoom: 9.3,
  },
  MAYOTTE: {
    label: "Mayotte",
    lon: 45.16242028163609,
    lat: -12.831199035192768,
    zoom: 9.5,
  },
  ST_BARTH: {
    label: "St-Barth.",
    lon: -62.834089499999976,
    lat: 17.90895231756872,
    zoom: 11.5,
  },
  ST_MARTIN: {
    label: "St-Martin",
    lon: -63.05,
    lat: 18.060599132556177,
    zoom: 11,
  },
};

const INIT_TERRITOIRE = "METROPOLE";
if (!TERRITOIRES[INIT_TERRITOIRE]) {
  throw new Error(`Unknown territoire ${INIT_TERRITOIRE}`);
}

const INITIAL_VIEW_STATE = {
  bearing: 0,
  latitude: TERRITOIRES[INIT_TERRITOIRE].lat,
  longitude: TERRITOIRES[INIT_TERRITOIRE].lon,
  zoom: TERRITOIRES[INIT_TERRITOIRE].zoom,
  pitch: 0,
};

export default class extends Controller {
  connect() {
    // Render map
    const data = JSON.parse(this.element.dataset.map);

    const getDepartmentValue = (code) =>
      data.usersByDept[code] &&
      (data.usersByDept[code] / popByCode[code]) * 1e5;
    const getDepartmentTooltip = (object) => {
      const value = getDepartmentValue(object.properties.code);
      let html = `<b>${object.properties.nom}</b><br />`;
      if (value == null) {
        html += "Nombre inconnu de volontaires";
      } else {
        html += `Environ <b>${
          Math.round(value * 10) / 10
        }</b> volontaires inscrits par 100 000 habitants`;
      }
      return { html };
    };

    const colorScale = scaleLinear()
      .domain([
        0,
        Math.max(...Object.keys(data.usersByDept).map(getDepartmentValue)),
      ])
      .range([
        [50, 238, 238],
        [50, 0, 238],
      ])
      .unknown(UNKNOW_DEPT_COLOR);

    const departementsLayer = new GeoJsonLayer({
      data: departements,
      pickable: true, // enable tooltip?
      filled: true,
      stroked: true,
      getFillColor: (d) => colorScale(getDepartmentValue(d.properties.code)),
      getLineColor: [255, 255, 255],
      getLineWidth: 500, // meters
    });

    const ICON_MAPPING = {
      marker: { anchorY: 128, height: 128, width: 128, mask: true },
    };

    const iconLayer = new IconLayer({
      data: data.vaccinationCenters,
      pickable: false, // enable tooltip?
      // iconAtlas and iconMapping are required
      // getIcon: return a string
      iconAtlas:
        "https://raw.githubusercontent.com/visgl/deck.gl-data/master/website/icon-atlas.png",
      iconMapping: ICON_MAPPING,
      getIcon: (d) => "marker",
      sizeScale: 15,
      getPosition: (d) => d.coordinates,
      getSize: (d) => 2,
      getColor: (d) => [255, 100, 100],
    });

    const layers = [departementsLayer, iconLayer];

    const map = new mapboxgl.Map({
      container: "map",
      style: "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json",
      interactive: false,
      center: [INITIAL_VIEW_STATE.longitude, INITIAL_VIEW_STATE.latitude],
      zoom: INITIAL_VIEW_STATE.zoom,
      bearing: INITIAL_VIEW_STATE.bearing,
      pitch: INITIAL_VIEW_STATE.pitch,
    });
    const deckgl = new Deck({
      mapStyle: null,
      canvas: "deck-canvas",
      initialViewState: INITIAL_VIEW_STATE,
      controller: false,
      onViewStateChange: ({ viewState }) => {
        map.jumpTo({
          center: [viewState.longitude, viewState.latitude],
          zoom: viewState.zoom,
          bearing: viewState.bearing,
          pitch: viewState.pitch,
        });
      },
      // getTooltip: ({ object }) => object && getDepartmentTooltip(object),
      layers: layers,
    });

    // Render territories selection
    const btnContainer = document.getElementById("territoire-container");
    Object.keys(TERRITOIRES).forEach((k) => {
      const el = document.createElement("a");
      el.setAttribute("href", "");
      el.className = "col btn-sm btn btn-link small mx-2";
      const t = TERRITOIRES[k];
      el.innerHTML = t.label;
      el.onclick = () => {
        deckgl.setProps({
          initialViewState: {
            ...INITIAL_VIEW_STATE,
            longitude: t.lon,
            latitude: t.lat,
            zoom: t.zoom,
          },
        });
        map.jumpTo({
          center: [t.lon, t.lat],
          zoom: t.zoom,
        });
        return false;
      };
      btnContainer.appendChild(el);
    });

    console.log("Visualisation loaded");
  }
}
