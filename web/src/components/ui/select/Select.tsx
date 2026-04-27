import React, { useId, useCallback } from "react";
import { cx } from "../../shared/utils/classNames";
import type { SelectProps } from "./Select.types";
import s from "./Select.module.scss";

export const Select: React.FC<SelectProps> = ({
  label,
  options,
  value,
  placeholder,
  disabled,
  onChange,
  className,
}) => {
  const id = useId();

  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLSelectElement>) => onChange?.(e.target.value),
    [onChange]
  );

  return (
    <div className={cx(s.wrapper, className)}>
      {label && <label htmlFor={id} className={s.label}>{label}</label>}
      <div className={s.field}>
        <select
          id={id}
          className={s.select}
          value={value}
          disabled={disabled}
          onChange={handleChange}
        >
          {placeholder && (
            <option value="" disabled>
              {placeholder}
            </option>
          )}
          {options.map((opt) => (
            <option key={opt.value} value={opt.value} disabled={opt.disabled}>
              {opt.label}
            </option>
          ))}
        </select>
        <i className={cx("fa-solid fa-chevron-down", s.chevron)} aria-hidden />
      </div>
    </div>
  );
};
