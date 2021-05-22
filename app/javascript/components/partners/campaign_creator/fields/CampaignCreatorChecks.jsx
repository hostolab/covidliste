import React from "react";
import { Field, useFormikContext } from "formik";

export const CampaignCreatorChecks = () => {
  const { getFieldMeta, values } = useFormikContext();
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
        {getFieldMeta("checkDoses").error && (
          <div className="alert alert-danger" role="alert">
            {getFieldMeta("checkDoses").error}
          </div>
        )}
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
      {getFieldMeta("checkNotify").error && (
        <div className="alert alert-danger" role="alert">
          {getFieldMeta("checkNotify").error}
        </div>
      )}
    </div>
  );
};
