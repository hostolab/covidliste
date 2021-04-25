import React from "react";
import { CampaignCreatorField } from "components/partners/campaign_creator/fields/CampaignCreatorField";
import { CampaignCreatorInput } from "components/partners/campaign_creator/fields/CampaignCreatorInput";

export const CampaignCreatorAvailableDoses = () => {
  return (
    <CampaignCreatorField label="Nombre de doses" name="availableDoses">
      <CampaignCreatorInput
        type="number"
        name="availableDoses"
        id="availableDoses"
        min={1}
        max={200}
        size="4"
      />
    </CampaignCreatorField>
  );
};
