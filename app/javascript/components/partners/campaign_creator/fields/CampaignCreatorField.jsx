import React from "react";
import { useFormikContext } from "formik";

export const CampaignCreatorField = ({
  label,
  sublabel,
  name,
  names = [name],
  children,
  className = "",
  warning,
}) => {
  const { getFieldMeta } = useFormikContext();
  const errors = names.map((name) => getFieldMeta(name).error).filter(Boolean);
  return (
    <div className={`CampaignCreatorField ${className}`}>
      <label htmlFor={name}>
        {label && <h3>{label}</h3>}
        {sublabel && <p>{sublabel}</p>}
        <div className="input">{children}</div>
      </label>
      {errors.map((error) => (
        <div className="alert alert-danger" role="alert" key={error.slice(50)}>
          {error}
        </div>
      ))}
      {warning && !errors.length && (
        <div className="alert alert-warning" role="alert">
          {warning}
        </div>
      )}
    </div>
  );
};
