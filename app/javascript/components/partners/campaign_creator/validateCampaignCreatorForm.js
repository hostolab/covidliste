import { isNil, isInteger, find } from "lodash";
import {
  vaccineTypes,
  vaccineTypesValues,
} from "components/partners/campaign_creator/vaccineTypes";
import dayjs from "dayjs";

export const validateCampaignCreatorForm = (values) => {
  const errors = {};
  const now = dayjs();

  // Available doses
  if (isNil(values.availableDoses) || values.availableDoses === "")
    errors.availableDoses = "Veuillez choisir un nombre de doses";
  else if (!isInteger(values.availableDoses))
    errors.availableDoses = "Le nombre de doses doit être un nombre entier";
  else if (values.availableDoses < 1)
    errors.availableDoses = "Le nombre de doses doit être supérieur à 0";
  else if (values.availableDoses > 200)
    errors.availableDoses = "Le nombre de doses doit être inférieur à 200";

  // Vaccine Type
  const vaccineTypeDefinition = find(vaccineTypes, {
    value: values.vaccineType,
  });
  if (!values.vaccineType)
    errors.vaccineType = "Veuillez choisir un type de vaccin";
  else if (!vaccineTypeDefinition)
    errors.vaccineType = "Type de vaccin inconnu";

  // Starts At
  if (!values.startsAt?.isValid())
    errors.startsAt = "Veuillez choisir une heure de début";
  else if (values.startsAt.isBefore(now.add(9, "minutes"))) {
    errors.startsAt = `Pour laisser le temps aux premiers volontaires de se rendre dans votre établissement, la campagne ne peut commencer que dans 10 minutes, à partir de ${now
      .add(10, "minutes")
      .format("HH:mm")}`;
  } else if (!values.startsAt.isSame(now, "day")) {
    errors.startsAt = `La campagne doit être lancée pour aujourd'hui`;
  }

  // Ends At
  if (!values.endsAt?.isValid())
    errors.endsAt = "Veuillez choisir une heure de fin";
  else if (values.endsAt.isBefore(now.add(24, "minutes"))) {
    errors.endsAt = `Pour laisser le temps aux volontaires de se rendre dans votre établissement, la campagne ne peut se finir que dans 25 minutes au plus tôt, à partir de ${now
      .add(25, "minutes")
      .format("HH:mm")}`;
  } else if (values.endsAt.isBefore(values.startsAt.add(15, "minutes"))) {
    errors.endsAt = `Les volontaires doivent disposer d'un crénau d'au moins 15 minutes.`;
  }

  // Min Age
  if (isNil(values.minAge)) errors.minAge = "Veuillez choisir un âge minimum";
  else if (!isInteger(values.minAge))
    errors.minAge = "L'âge minimum doit être un nombre entier";
  else if (values.minAge < 18)
    errors.minAge = "Les volontaires doivent avoir au moins 18 ans";
  else if (
    vaccineTypeDefinition.minimumMinAge &&
    values.minAge < vaccineTypeDefinition.minimumMinAge
  )
    errors.minAge = `Pour le vaccin ${vaccineTypeDefinition.label}, les volontaires doivent avoir au moins ${vaccineTypeDefinition.minimumMinAge} ans`;

  // Max Age
  if (isNil(values.maxAge)) errors.maxAge = "Veuillez choisir un âge maximum";
  else if (!isInteger(values.maxAge))
    errors.maxAge = "L'âge maximum doit être un nombre entier";
  else if (values.maxAge <= values.minAge)
    errors.maxAge = "L'âge minimum doit être inférieur à l'âge maximum";

  // Max distance
  if (isNil(values.maxDistanceInMeters))
    errors.maxDistanceInMeters = "Veuillez choisir une distance";
  else if (values.maxDistanceInMeters < 1000)
    errors.maxDistanceInMeters = "La distance doit être d'au moins 1km";
  else if (values.maxDistanceInMeters > 50000)
    errors.maxDistanceInMeters = "La distance ne peut pas dépasser 50km";

  // Campaign launch date validation
  if (now.isBefore(now.hour(7))) {
    errors.checkNotify =
      "Les campagnes ne peuvent pas être lancées avant 7h du matin, pour ne pas prévenir de volontaires dans leur sommeil.";
  }

  return errors;
};
