import React from "react";
import { Field } from "formik";
import { CampaignCreatorField } from "components/partners/campaign_creator/fields/CampaignCreatorField";

export const CampaignCreatorExtraInfo = () => {
  return (
    <CampaignCreatorField label="Détails d’accès" name="extraInfo">
      <Field
        as="textarea"
        name="extraInfo"
        id="extraInfo"
        className="form-control form-control-full-width"
        rows="2"
        cols="100"
        placeholder="Vous pouvez préciser les modalités d’accès au lieu de vaccination."
      />
    </CampaignCreatorField>
  );
};
