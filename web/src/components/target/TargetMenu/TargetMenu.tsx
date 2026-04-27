import React from "react";
import { TargetOption } from "../TargetOption/TargetOption";
import { TargetHeader } from "../TargetHeader/TargetHeader";
import type { TargetMenuProps } from "./TargetMenu.types";
import s from "./TargetMenu.module.scss";

export const TargetMenu: React.FC<TargetMenuProps> = ({
  options,
  noOptions,
  entityType,
  entityName,
}) => {
  if (options.length === 0 && !noOptions) return null;

  if (noOptions) {
    return (
      <div className={s.menu}>
        <p className={s.noOptions}>{noOptions}</p>
      </div>
    );
  }

  return (
    <div className={s.menu}>
      <TargetHeader entityType={entityType} entityName={entityName} />
      {options.map((meta) => (
        <TargetOption key={meta.key} meta={meta} />
      ))}
    </div>
  );
};
