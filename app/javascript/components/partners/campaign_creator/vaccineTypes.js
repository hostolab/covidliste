export const vaccineTypes = [
  {
    value: "astrazeneca",
    label: "AstraZeneca",
    minimumMinAge: 55,
  },
  {
    value: "pfizer",
    label: "Pfizer",
  },
  {
    value: "moderna",
    label: "Moderna",
  },
  {
    value: "janssen",
    label: "Janssen / Johnson & Johnson",
    minimumMinAge: 55,
  },
];

export const vaccineTypesValues = vaccineTypes.map(
  (vaccineType) => vaccineType.value
);
