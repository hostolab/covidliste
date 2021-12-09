export const vaccineTypes = [
  {
    value: "pfizer",
    label: "Pfizer",
  },
  {
    value: "moderna",
    label: "Moderna",
    minimumMinAge: 30,
  },
  {
    value: "janssen",
    label: "Janssen / Johnson & Johnson",
    minimumMinAge: 55,
  },
  {
    value: "astrazeneca",
    label: "AstraZeneca",
    minimumMinAge: 55,
  },
];

export const vaccineTypesValues = vaccineTypes.map(
  (vaccineType) => vaccineType.value
);
