import Rails from "@rails/ujs";
import { camelCaseDeep, snakeCaseDeep } from "components/shared/casing";

const handleErrors = (response) => {
  if (!response.ok) throw Error(response.statusText);
  return response;
};

const request = (method) => (path, payload, fetchOptions) => {
  return fetch(window.origin + path, {
    method,
    credentials: "same-origin",
    headers: {
      "X-CSRF-Token": Rails.csrfToken(),
      "Content-Type": "application/json",
    },
    body: payload ? JSON.stringify(snakeCaseDeep(payload)) : undefined,
    ...fetchOptions,
  })
    .then(handleErrors)
    .then((res) => res.json())
    .then(camelCaseDeep);
};

export const get = request("GET");
export const post = request("POST");
export const put = request("PUT");
export const del = request("DELETE");
export const patch = request("PATCH");

export const api = { get, post, put, del, patch };
