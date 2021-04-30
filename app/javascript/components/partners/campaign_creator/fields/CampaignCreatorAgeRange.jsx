import React from "react";
import { CampaignCreatorField } from "components/partners/campaign_creator/fields/CampaignCreatorField";
import { CampaignCreatorInput } from "components/partners/campaign_creator/fields/CampaignCreatorInput";

export const CampaignCreatorAgeRange = () => {
  return (
    <CampaignCreatorField
      label="Âge des volontaires"
      names={["minAge", "maxAge"]}
    >
      <span>Entre</span>
      <CampaignCreatorInput
        name="minAge"
        size="2"
        type="number"
        min="18"
        max="130"
      />
      <span>et</span>
      <CampaignCreatorInput
        name="maxAge"
        size="2"
        type="number"
        min="18"
        max="130"
      />
      <span>ans inclus</span>
    </CampaignCreatorField>
  );
};
