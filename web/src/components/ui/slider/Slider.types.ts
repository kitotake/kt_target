import type { InputHTMLAttributes } from "react";

export interface SliderProps
  extends Omit<InputHTMLAttributes<HTMLInputElement>, "type"> {
  label?:       string;
  showValue?:   boolean;
  formatValue?: (v: number) => string;
}
