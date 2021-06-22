import dayjs from "./utils/dayjs";

import { vaccineTypes } from "./vaccineTypes";

export function initialFormState(campaignDefaults, { timezone }) {
  dayjs.tz.setDefault(timezone);


  const ceilToFiveMinutes = (date) =>
    date.minute(Math.ceil(date.minute() / 5) * 5);

  const startsAt = ceilToFiveMinutes(
    campaignDefaults.startsAt
      ? dayjs.tz(campaignDefaults.startsAt)
      : dayjs.tz().add(30, "minutes")
  );

  const endsAt = ceilToFiveMinutes(
    campaignDefaults.endsAt
      ? dayjs.tz(campaignDefaults.endsAt)
      : dayjs.tz().add(4, "hours")
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
