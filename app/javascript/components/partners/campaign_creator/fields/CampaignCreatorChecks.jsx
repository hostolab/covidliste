import React from "react";
import { Field, useFormikContext } from "formik";
import { CampaignCreatorField } from "components/partners/campaign_creator/fields/CampaignCreatorField";

export const CampaignCreatorChecks = () => {
  const { values } = useFormikContext();
  return (
    <div>
      <fieldset className="form-group boolean required">
        <div className="form-check">
          <Field
            className="form-check-input boolean required"
            required
            type="checkbox"
            name="checkDoses"
            id="checkDoses"
          />
          <label
            className="form-check-label boolean required"
            htmlFor="checkDoses"
          >
            Je confirme avoir {values.availableDoses} doses pour les volontaires
            Covidliste, et pouvoir leur injecter aujourd’hui entre{" "}
            {values.startsAt?.format("HH:mm")} et{" "}
            {values.endsAt?.format("HH:mm")}
          </label>
        </div>
      </fieldset>
      <fieldset className="form-group boolean required">
        <div className="form-check">
          <Field
            className="form-check-input boolean required"
            required
            type="checkbox"
            name="checkNotify"
            id="checkNotify"
          />
          <label
            className="form-check-label boolean required"
            htmlFor="checkNotify"
          >
            J’ai compris qu’en cliquant sur <strong>Lancer la campagne</strong>,
            les volontaires seront <strong>instantanément notifiés</strong> par
            email/SMS.
          </label>
        </div>
      </fieldset>
    </div>
  );
};
