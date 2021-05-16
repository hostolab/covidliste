import React from "react";
import { useFormikContext } from "formik";
import { CampaignCreatorField } from "components/partners/campaign_creator/fields/CampaignCreatorField";
import { CampaignCreatorInput } from "components/partners/campaign_creator/fields/CampaignCreatorInput";

export const CampaignCreatorPhoneNumber = ({
  vaccinationCenterPhoneNumber,
}) => {
  const fieldName = "phoneNumber";
  const { setFieldValue, values } = useFormikContext();
  return (
    <>
      <CampaignCreatorField
        label="Numéro de téléphone (facultatif)"
        name={fieldName}
      >
        <CampaignCreatorInput type="tel" name={fieldName} id={fieldName} />
      </CampaignCreatorField>
      {vaccinationCenterPhoneNumber &&
        values[fieldName] !== vaccinationCenterPhoneNumber && (
          <button
            className="btn btn-outline-primary btn-sm"
            type="button"
            onClick={() =>
              setFieldValue(fieldName, vaccinationCenterPhoneNumber)
            }
          >
            Utiliser le numéro du centre de vaccination (
            {vaccinationCenterPhoneNumber})
          </button>
        )}
    </>
  );
};
