import React from "react";

type Props = { label: string };

export const NoOptions: React.FC<Props> = ({ label }) => (
  <p id="no-options">{label}</p>
);