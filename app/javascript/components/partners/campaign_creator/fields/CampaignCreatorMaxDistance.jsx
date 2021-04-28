import React from "react";
import { useFormikContext } from "formik";
import { CampaignCreatorField } from "components/partners/campaign_creator/fields/CampaignCreatorField";

export const CampaignCreatorMaxDistance = () => {
  const { values, setFieldValue, getFieldMeta } = useFormikContext();
  const errorClass = getFieldMeta("maxDistanceInMeters")?.error
    ? "is-invalid"
    : "";
  return (
    <CampaignCreatorField
      label="Localisation des volontaires"
      name="maxDistanceInMeters"
    >
      <span>À</span>
      <input
        name="maxDistanceInMeters"
        id="maxDistanceInMeters"
        size="2"
        type="number"
        min="1"
        max="50"
        value={values.maxDistanceInMeters / 1000}
        onChange={(e) =>
          setFieldValue("maxDistanceInMeters", e.target.value * 1000)
        }
        className={`form-control ${errorClass}`}
      />
      <span>km maximum de votre établissement</span>
    </CampaignCreatorField>
  );
};
