import React from "react";

export function CampaignCreatorAlreadyRunningCampaignWarning({
  runningCampaignsPaths,
}) {
  if (!runningCampaignsPaths?.length > 0) return null;
  const plural = runningCampaignsPaths.length > 1;
  return (
    <>
      <div className="alert alert-warning" role="alert">
        <strong>Campagne{plural && "s"} déjà en cours !</strong> <br />
        Attention, vous avez déjà lancé{" "}
        {plural ? runningCampaignsPaths.length : "une"} autre{plural && "s"}{" "}
        campagne{plural && "s"}, qui notifie{plural && "nt"} actuellement des
        volontaires.{" "}
        {plural ? (
          <ul>
            {runningCampaignsPaths.map((path, i) => (
              <li key={path}>
                <a href={path} className="alert-link">
                  Consulter la campagne {i + 1}
                </a>
              </li>
            ))}
          </ul>
        ) : (
          <a href={runningCampaignsPaths[0]} className="alert-link">
            Consulter la campagne en cours
          </a>
        )}
      </div>
    </>
  );
}
