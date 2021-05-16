import React from "react";
import { useMutation } from "react-query";
import { Form, Formik } from "formik";
import { api } from "components/shared/api";
import { RootWrapper } from "components/shared/RootWrapper";
import { validateCampaignCreatorForm } from "components/partners/campaign_creator/validateCampaignCreatorForm";
import { CampaignCreatorReach } from "components/partners/campaign_creator/CampaignCreatorReach";
import { CampaignCreatorTimeRange } from "components/partners/campaign_creator/fields/CampaignCreatorTimeRange";
import { CampaignCreatorAgeRange } from "components/partners/campaign_creator/fields/CampaignCreatorAgeRange";
import { CampaignCreatorMaxDistance } from "components/partners/campaign_creator/fields/CampaignCreatorMaxDistance";
import { CampaignCreatorExtraInfo } from "components/partners/campaign_creator/fields/CampaignCreatorExtraInfo";
import { CampaignCreatorVaccineType } from "components/partners/campaign_creator/fields/CampaignCreatorVaccineType";
import { GenericError } from "components/partners/GenericError";
import { CampaignCreatorAvailableDoses } from "components/partners/campaign_creator/fields/CampaignCreatorAvailableDoses";
import { CampaignCreatorChecks } from "components/partners/campaign_creator/fields/CampaignCreatorChecks";
import { initialFormState } from "components/partners/campaign_creator/initialFormState";
import { CampaignCreatorAlreadyRunningCampaignWarning } from "components/partners/campaign_creator/CampaignCreatorAlreadyRunningCampaignWarning";

const _CampaignCreator = ({
  campaignDefaults,
  vaccinationCenter,
  flowImagePath,
  runningCampaignsPaths,
}) => {
  const createCampaign = useCreateCampaignMutation(vaccinationCenter);
  return (
    <div className="CampaignCreator">
      {createCampaign.isError && <GenericError />}
      <CampaignCreatorAlreadyRunningCampaignWarning
        runningCampaignsPaths={runningCampaignsPaths}
      />
      <Formik
        initialValues={initialFormState(campaignDefaults)}
        validate={validateCampaignCreatorForm}
        onSubmit={createCampaign.mutate}
        validateOnMount
      >
        {({ isValid, values }) => (
          <Form>
            <div className="CampaignCreatorMainForm">
              <h2>
                <i className="fas fa-syringe"></i> Doses et disponibilité
              </h2>
              <CampaignCreatorAvailableDoses />
              <CampaignCreatorVaccineType />
              <CampaignCreatorTimeRange />

              <h2>
                <i className="fas fa-user"></i> Sélection des volontaires
              </h2>
              <CampaignCreatorAgeRange />
              <CampaignCreatorMaxDistance />

              <h2>
                <i className="fas fa-info-circle"></i> Informations pour les
                volontaires
              </h2>
              <p>
                Les volontaires verront les informations suivantes uniquement
                <strong> après avoir confirmé leur rendez-vous.</strong> Il leur
                est déjà demandé d’apporter leur carte vitale et une pièce
                d’identité.
              </p>
              <CampaignCreatorExtraInfo />
              {/*ajouter la possibilité de faire apparaître son téléphone*/}

              <h2>
                <i className="fas fa-bullhorn"></i> Lancer la campagne
              </h2>
              <CampaignCreatorReach
                vaccinationCenter={vaccinationCenter}
                className="d-lg-none"
              />
              <img
                src={flowImagePath}
                alt="Covidliste va notifier les volontaires."
                width="100%"
              />
              <CampaignCreatorChecks />

              <button
                className="btn btn-primary btn-lg"
                type="submit"
                disabled={
                  !isValid ||
                  !values.checkDoses ||
                  !values.checkNotify ||
                  !createCampaign.isIdle
                }
              >
                <i className="fas fa-bullhorn"></i> Lancer la campagne
              </button>
            </div>
            <div className="CampaignCreatorSidebar d-none d-lg-block">
              <CampaignCreatorReach vaccinationCenter={vaccinationCenter} />
            </div>
          </Form>
        )}
      </Formik>
    </div>
  );
};

function useCreateCampaignMutation(vaccinationCenter) {
  return useMutation(
    (campaign) =>
      api.post(
        `/partners/vaccination_centers/${vaccinationCenter.id}/campaigns.json`,
        { campaign }
      ),
    { onSuccess: (data) => window.location.assign(data.redirectTo) }
  );
}

export const CampaignCreator = RootWrapper(_CampaignCreator);
