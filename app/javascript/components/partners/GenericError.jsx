import React from "react";

export function GenericError({ messages = ["Une erreur s'est produite."] }) {
  return (
    <div className="alert alert-danger" role="alert">
      {messages.map((message, i) => {
        return <div>{message}</div>;
      })}
      <div>Besoin d'aide ? Contactez-nous sur partenaires@covidliste.com</div>
    </div>
  );
}
