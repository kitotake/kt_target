import React, { useId } from "react";
import { cx } from "../../shared/utils/classNames";
import type { ToggleProps } from "./Toggle.types";
import s from "./Toggle.module.scss";

export const Toggle: React.FC<ToggleProps> = ({
  label,
  sublabel,
  checked,
  disabled,
  onChange,
  className,
  ...rest
}) => {
  const id = useId();

  return (
    <label
      htmlFor={id}
      className={cx(
        s.wrapper,
        checked  ? s.checked  : "",
        disabled ? s.disabled : "",
        className
      )}
    >
      <input
        id={id}
        type="checkbox"
        role="switch"
        aria-checked={checked}
        className={s.input}
        checked={checked}
        disabled={disabled}
        onChange={onChange}
        {...rest}
      />
      <span className={s.track} aria-hidden>
        <span className={s.thumb} />
      </span>
      {(label || sublabel) && (
        <span className={s.labels}>
          {label    && <span className={s.label}>{label}</span>}
          {sublabel && <span className={s.sublabel}>{sublabel}</span>}
        </span>
      )}
    </label>
  );
};
