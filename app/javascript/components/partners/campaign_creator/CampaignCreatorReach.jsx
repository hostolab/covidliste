import React, { useEffect, useState } from "react";
import { useQuery } from "react-query";
import { useFormikContext } from "formik";
import { api } from "components/shared/api";
import { omit, isNumber } from "lodash";

export const CampaignCreatorReach = ({ vaccinationCenter, className }) => {
  const { values, isValid } = useFormikContext();
  const debouncedValues = useDebounce(values, 2000);
  const { isFetching, data } = useReachQuery(
    {
      campaign: omit(debouncedValues, [
        "extraInfo",
        "checkDoses",
        "checkNotify",
      ]),
    },
    vaccinationCenter
  );
  let status = "unknown";
  if (data && isValid) {
    if (data.reach >= data.minimumReachToDoseRatio * values.availableDoses)
      status = "success";
    else status = "warning";
  }

  return (
    <div className={`CampaignCreatorReach ${status} ${className}`}>
      <div className="count">
        {(isFetching || debouncedValues != values) && (
          <div className="spinner"></div>
        )}
        <span className="countNumber">
          {isNumber(data?.reach) && status !== "unknown" ? data.reach : "-"}
        </span>
        <br />
        volontaires éligibles
      </div>
      <p className="advice">
        {status === "success" && (
          <>
            <strong>Bravo !</strong> Les paramètres de votre campagne sont
            parfaits pour trouver {values.availableDoses} volontaires.
          </>
        )}
        {status === "warning" && (
          <>
            <strong>C’est un peu juste !</strong> Elargissez les critères de
            sélection des volontaires pour garantir le succès de votre campagne.
          </>
        )}
        {status === "unknown" && (
          <>Il y a des erreurs dans les paramètres de votre campagne</>
        )}
      </p>
    </div>
  );
};

function useReachQuery(reachParams, vaccinationCenter) {
  const { isValid } = useFormikContext();
  return useQuery(
    ["reach", reachParams],
    () =>
      api.post(
        `/partners/vaccination_centers/${vaccinationCenter.id}/campaigns/simulate_reach.json`,
        reachParams
      ),
    {
      enabled: isValid,
      keepPreviousData: true,
      refetchInterval: 60000,
    }
  );
}

function useDebounce(value, delay) {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);
    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}
