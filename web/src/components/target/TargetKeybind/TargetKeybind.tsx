import React from "react";
import type { TargetKeybindProps } from "./TargetKeybind.types";
import s from "./TargetKeybind.module.scss";

export const TargetKeybind: React.FC<TargetKeybindProps> = ({
  keyLabel,
  description,
}) => (
  <div className={s.keybind}>
    <span className={s.key}>{keyLabel}</span>
    {description && <span className={s.desc}>{description}</span>}
  </div>
);
