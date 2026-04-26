import { useEffect } from "react";

export function useVisibility(visible: boolean): void {
  useEffect(() => {
    document.body.style.visibility = visible ? "visible" : "hidden";
  }, [visible]);
}