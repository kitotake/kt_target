import React from "react";
import type { TargetHeaderProps } from "./TargetHeader.types";
import s from "./TargetHeader.module.scss";

export const TargetHeader: React.FC<TargetHeaderProps> = ({
  entityType,
  entityName,
}) => {
  if (!entityType && !entityName) return null;

  return (
    <div className={s.header}>
      {entityType && <span className={s.type}>{entityType}</span>}
      {entityName && <span className={s.name}>{entityName}</span>}
    </div>
  );
};
