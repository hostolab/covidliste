import React from "react";
import { Field, useFormikContext } from "formik";

export function CampaignCreatorInput(props) {
  const { getFieldMeta } = useFormikContext();
  const errorClass = getFieldMeta(props.name)?.error ? "is-invalid" : "";
  return <Field {...props} className={`form-control ${errorClass}`} />;
}
