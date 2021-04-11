import { Controller } from "stimulus";

import { Deck } from "@deck.gl/core";
import { GridCellLayer, GeoJsonLayer, IconLayer } from "@deck.gl/layers";
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";
import { scaleLinear } from "d3-scale";

import departements from "./departements-version-simplifiee.json";
import popByCode from "./pop2021.json";

export default class extends Controller {
  connect() {
    const data = JSON.parse(this.element.dataset.map);

    const UNKNOW_DEPT_COLOR = [220, 220, 220];

    const getDepartmentValue = (code) =>
      data.usersByDept[code] && (data.usersByDept[code] / popByCode[code]) * 1e5;
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

    const INITIAL_VIEW_STATE = {
      bearing: 30,
      latitude: 45.5,
      longitude: 2.3,
      pitch: 45,
      zoom: 5.2,
    };
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
      getTooltip: ({ object }) => object && getDepartmentTooltip(object),
      layers: layers,
    });
    console.log("Visualisation loaded");
  };
}
