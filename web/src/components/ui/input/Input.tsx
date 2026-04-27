import React, { useId } from "react";
import { cx } from "../../shared/utils/classNames";
import type { InputProps } from "./Input.types";
import s from "./Input.module.scss";

export const Input: React.FC<InputProps> = ({
  label,
  error,
  iconLeft,
  iconRight,
  className,
  ...rest
}) => {
  const id = useId();

  return (
    <div className={cx(s.wrapper, className)}>
      {label && <label htmlFor={id} className={s.label}>{label}</label>}
      <div
        className={cx(
          s.field,
          iconLeft  ? s.hasLeft  : "",
          iconRight ? s.hasRight : "",
          error     ? s.hasError : ""
        )}
      >
        {iconLeft  && <i className={cx("fa-fw", iconLeft,  s.iconLeft)}  aria-hidden />}
        <input id={id} className={s.input} {...rest} />
        {iconRight && <i className={cx("fa-fw", iconRight, s.iconRight)} aria-hidden />}
      </div>
      {error && <span className={s.error}>{error}</span>}
    </div>
  );
};
