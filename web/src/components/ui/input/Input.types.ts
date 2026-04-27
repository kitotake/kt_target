import type { InputHTMLAttributes } from "react";

export interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?:       string;
  error?:       string;
  iconLeft?:    string;   // FA class
  iconRight?:   string;   // FA class
}
