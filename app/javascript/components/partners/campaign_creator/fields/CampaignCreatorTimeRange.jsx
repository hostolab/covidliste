import React from "react";
import { useFormikContext } from "formik";
import dayjs, { utcTimezone } from "../utils/dayjs";
import { range } from "lodash";
import { CampaignCreatorField } from "components/partners/campaign_creator/fields/CampaignCreatorField";

const RANGE_MINUTES = range(0, 60, 5);
const RANGE_HOURS = range(24);

export const CampaignCreatorTimeRange = ({ timezone }) => {
  dayjs.tz.setDefault(timezone);

  const { values } = useFormikContext();
  return (
    <CampaignCreatorField
      label="Pendant quel créneau les volontaires doivent arriver ?"
      sublabel={
        <>
          Vous les invitez à se présenter <strong>aujourd’hui</strong>, sur
          cette plage horaire.
        </>
      }
      names={["startsAt", "endsAt"]}
      warning={timeRangeWarning(values)}
    >
      <span>Entre</span>
      <TimePicker name="startsAt" />
      <span>et</span>
      <TimePicker name="endsAt" />
      <span>({utcTimezone(timezone)})</span>
    </CampaignCreatorField>
  );
};

function TimePicker({ name }) {
  const { setFieldValue, values, getFieldMeta } = useFormikContext();
  const value = values[name];

  const errorClass = getFieldMeta(name)?.error ? "is-invalid" : "";
  return (
    <>
      <SelectRange
        range={RANGE_HOURS}
        value={value.hour()}
        onChange={(newHours) => setFieldValue(name, value.hour(newHours))}
        className={`form-control ${errorClass} margin-xs`}
      />
      <span className="margin-xs">:</span>
      <SelectRange
        range={RANGE_MINUTES}
        value={value.minute()}
        onChange={(newMinutes) => setFieldValue(name, value.minute(newMinutes))}
        className={`form-control ${errorClass}`}
      />
    </>
  );
}

function SelectRange({ range, onChange, value, className }) {
  return (
    <select
      onChange={(e) => onChange(e.target.value)}
      value={value}
      className={className}
    >
      {range.map((value) => (
        <option value={value} key={value}>
          {value.toString().padStart(2, "0")}
        </option>
      ))}
    </select>
  );
}

function timeRangeWarning(values) {
  if (values.endsAt?.isBefore?.(dayjs().add(2, "hours"))) {
    return (
      <>
        Pour laisser le temps aux volontaires de répondre,{" "}
        <strong>
          nous vous recommandons de lancer les campagnes au moins 2 heures avant
          la fin du créneau.
        </strong>
      </>
    );
  }
}
