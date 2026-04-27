import React, { useId } from "react";
import { cx } from "../../shared/utils/classNames";
import type { CheckboxProps } from "./Checkbox.types";
import s from "./Checkbox.module.scss";

export const Checkbox: React.FC<CheckboxProps> = ({
  label,
  sublabel,
  checked,
  disabled,
  className,
  onChange,
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
        className={s.input}
        checked={checked}
        disabled={disabled}
        onChange={onChange}
        {...rest}
      />
      <span className={s.box} aria-hidden />
      {(label || sublabel) && (
        <span className={s.labels}>
          {label    && <span className={s.label}>{label}</span>}
          {sublabel && <span className={s.sublabel}>{sublabel}</span>}
        </span>
      )}
    </label>
  );
};
