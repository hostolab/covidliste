import {
  camelCase,
  snakeCase,
  isPlainObject,
  mapKeys,
  mapValues,
  isArray,
} from "lodash";

const mapKeysDeep = (input, iteratee) => {
  const clone = (node) => {
    if (isArray(node)) return node.map(clone);
    if (isPlainObject(node))
      return mapValues(
        mapKeys(node, (value, key) => iteratee(key)),
        clone
      );
    return node;
  };
  return clone(input);
};

export const camelCaseDeep = (input) => mapKeysDeep(input, camelCase);
export const snakeCaseDeep = (input) => mapKeysDeep(input, snakeCase);
