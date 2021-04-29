import React from "react";
import { Field } from "formik";
import { CampaignCreatorField } from "components/partners/campaign_creator/fields/CampaignCreatorField";

export const CampaignCreatorExtraInfo = () => {
  return (
    <CampaignCreatorField
      label="Informations supplémentaires"
      sublabel="Accès, modalités... Les volontaires ne verront ces informations qu’après avoir confirmé leur rendez-vous."
      name="extraInfo"
    >
      <Field
        as="textarea"
        name="extraInfo"
        id="extraInfo"
        className="form-control form-control-full-width"
        rows="2"
      />
    </CampaignCreatorField>
  );
};
