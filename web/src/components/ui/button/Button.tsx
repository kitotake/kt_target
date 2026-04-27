import React from "react";
import { cx } from "../../shared/utils/classNames";
import type { ButtonProps } from "./Button.types";
import s from "./Button.module.scss";

export const Button: React.FC<ButtonProps> = ({
  variant = "primary",
  size    = "md",
  icon,
  loading = false,
  children,
  className,
  disabled,
  ...rest
}) => (
  <button
    className={cx(s.btn, s[variant], s[size], className)}
    disabled={disabled || loading}
    {...rest}
  >
    {loading
      ? <span className={s.spinner} aria-hidden />
      : icon && <i className={cx("fa-fw", icon, s.icon)} aria-hidden />}
    {children}
  </button>
);
