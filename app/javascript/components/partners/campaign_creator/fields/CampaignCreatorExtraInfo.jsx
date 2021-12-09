import React from "react";
import { Field, useFormikContext } from "formik";
import { CampaignCreatorField } from "components/partners/campaign_creator/fields/CampaignCreatorField";

export const CampaignCreatorExtraInfo = () => {
  const { values } = useFormikContext();
  return (
    <CampaignCreatorField
      label="Détails d’accès"
      name="extraInfo"
      warning={dateInExtraInfoWarning(values.extraInfo)}
    >
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

const dateInExtraInfoWarning = (info) => {
  const dateRegex =
    /(lundi|mardi|mercredi|jeudi|vendredi|janvier|f[eé]vrier|mars|avril|mai|juin|juillet|ao[uû]t|septembre|octobre|novembre|d[eé]cembre|demain)/i;
  if (info.match(dateRegex)) {
    return (
      <>
        Votre message semble contenir une date : n'oubliez pas que les campagnes
        doivent être envoyées pour le jour même !
      </>
    );
  }
};
