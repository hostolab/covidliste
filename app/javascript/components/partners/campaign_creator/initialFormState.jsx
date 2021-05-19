import dayjs from "dayjs";
import { vaccineTypes } from "./vaccineTypes";

export function initialFormState(campaignDefaults) {
  const ceilToFiveMinutes = (date) =>
    date.minute(Math.ceil(date.minute() / 5) * 5);

  const startsAt = ceilToFiveMinutes(
    campaignDefaults.startsAt
      ? dayjs(campaignDefaults.startsAt)
      : dayjs().add(30, "minutes")
  );

  const endsAt = ceilToFiveMinutes(
    campaignDefaults.endsAt
      ? dayjs(campaignDefaults.endsAt)
      : dayjs().add(4, "hours")
  );

  return {
    availableDoses: campaignDefaults.availableDoses || 16,
    vaccineType: campaignDefaults.vaccineType || vaccineTypes[0].value,
    minAge: campaignDefaults.minAge || 55,
    maxAge: campaignDefaults.maxAge || 130,
    maxDistanceInMeters: campaignDefaults.maxDistanceInMeters || 5000,
    startsAt,
    endsAt,
    extraInfo: "",
  };
}
