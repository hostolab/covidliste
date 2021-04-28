import React from "react";
import { Field, useFormikContext } from "formik";
import { CampaignCreatorField } from "components/partners/campaign_creator/fields/CampaignCreatorField";
import { vaccineTypes } from "components/partners/campaign_creator/vaccineTypes";

export const CampaignCreatorVaccineType = () => {
  const { values } = useFormikContext();
  return (
    <CampaignCreatorField
      label="Type de vaccin"
      name="vaccineType"
      className="CampaignCreatorVaccineType"
    >
      {vaccineTypes.map((vaccineType) => {
        const selected = values.vaccineType === vaccineType.value;
        const className = selected ? "btn-primary" : "btn-outline-primary";
        return (
          <div key={vaccineType.value} className="vaccineType">
            <Field
              type="radio"
              className="d-none"
              name="vaccineType"
              value={vaccineType.value}
              id={vaccineType.value}
            />
            <label
              className={`btn btn-sm ${className}`}
              htmlFor={vaccineType.value}
            >
              {selected && <i className="fas fa-check"></i>}
              {vaccineType.label}
            </label>
          </div>
        );
      })}
    </CampaignCreatorField>
  );
};
