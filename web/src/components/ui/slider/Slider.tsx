import React, { useId, useCallback } from "react";
import { cx } from "../../shared/utils/classNames";
import { clamp } from "../../shared/utils/format";
import type { SliderProps } from "./Slider.types";
import s from "./Slider.module.scss";

export const Slider: React.FC<SliderProps> = ({
  label,
  showValue = true,
  formatValue,
  min   = 0,
  max   = 100,
  value,
  onChange,
  className,
  ...rest
}) => {
  const id  = useId();
  const num = Number(value ?? min);
  const pct = clamp(((num - Number(min)) / (Number(max) - Number(min))) * 100, 0, 100);

  const format = useCallback(
    (v: number) => (formatValue ? formatValue(v) : String(v)),
    [formatValue]
  );

  return (
    <div className={cx(s.wrapper, className)}>
      {(label || showValue) && (
        <div className={s.header}>
          {label     && <label htmlFor={id} className={s.label}>{label}</label>}
          {showValue && <span className={s.value}>{format(num)}</span>}
        </div>
      )}
      <div
        className={s.track}
        style={{ "--thumb-pos": `${pct}%` } as React.CSSProperties}
      >
        <div className={s.fill} style={{ width: `${pct}%` }} />
        <input
          id={id}
          type="range"
          className={s.input}
          min={min}
          max={max}
          value={value}
          onChange={onChange}
          {...rest}
        />
      </div>
    </div>
  );
};
