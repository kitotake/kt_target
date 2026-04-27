import React from "react";
import s from "./NoOptions.module.scss";

export interface NoOptionsProps {
  /** Message affiché quand toutes les options sont masquées */
  label: string;
  /** Icône FontAwesome optionnelle (défaut : ban) */
  icon?: string;
}

export const NoOptions: React.FC<NoOptionsProps> = ({
  label,
  icon = "fa-solid fa-circle-xmark",
}) => (
  <div className={s.wrapper} role="status" aria-live="polite">
    <i className={`fa-fw ${icon} ${s.icon}`} aria-hidden />
    <span className={s.label}>{label}</span>
  </div>
);