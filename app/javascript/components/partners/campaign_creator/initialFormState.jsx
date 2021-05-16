import dayjs from "dayjs";
import { vaccineTypes } from "./vaccineTypes";

export function initialFormState(initialCampaign) {
  const ceilToFiveMinutes = (date) =>
    date.minute(Math.ceil(date.minute() / 5) * 5);

  const startsAt = ceilToFiveMinutes(
    initialCampaign.startsAt
      ? dayjs(initialCampaign.startsAt)
      : dayjs().add(30, "minutes")
  );

  const endsAt = ceilToFiveMinutes(
    initialCampaign.endsAt
      ? dayjs(initialCampaign.endsAt)
      : dayjs().add(4, "hours")
  );

  return {
    availableDoses: initialCampaign.availableDoses || 16,
    vaccineType: initialCampaign.vaccineType || vaccineTypes[0].value,
    minAge: initialCampaign.minAge || 55,
    maxAge: initialCampaign.maxAge || 130,
    maxDistanceInMeters: initialCampaign.maxDistanceInMeters || 5000,
    startsAt,
    endsAt,
    extraInfo: "",
    phoneNumber: initialCampaign.phoneNumber || "",
  };
}
