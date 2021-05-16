import dayjs from "dayjs";
import { vaccineTypes } from "./vaccineTypes";

export function initialFormState(lastCampaign) {
  const ceilToFiveMinutes = (date) =>
    date.minute(Math.ceil(date.minute() / 5) * 5);

  const startsAt = ceilToFiveMinutes(
    lastCampaign.startsAt
      ? dayjs(lastCampaign.startsAt)
      : dayjs().add(30, "minutes")
  );

  const endsAt = ceilToFiveMinutes(
    lastCampaign.endsAt
      ? dayjs(lastCampaign.endsAt)
      : dayjs().add(4, "hours")
  );

  return {
    availableDoses: lastCampaign.availableDoses || 16,
    vaccineType: lastCampaign.vaccineType || vaccineTypes[0].value,
    minAge: lastCampaign.minAge || 55,
    maxAge: lastCampaign.maxAge || 130,
    maxDistanceInMeters: lastCampaign.maxDistanceInMeters || 5000,
    startsAt,
    endsAt,
    extraInfo: "",
  };
}
