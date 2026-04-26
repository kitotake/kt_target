import { EYE_SVG_ID } from "../config";

export function setEyeHover(value: boolean): void {
  const svg = document.getElementById(EYE_SVG_ID);
  if (!svg) return;
  svg.classList.toggle("eye-hover", value);
}