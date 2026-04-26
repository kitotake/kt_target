import { useEffect } from "react";
import type { NuiEvent } from "../typings";

export function useNuiMessage(
  handler: (data: NuiEvent) => void
): void {
  useEffect(() => {
    const listener = (event: MessageEvent<NuiEvent>) => {
      handler(event.data);
    };

    window.addEventListener("message", listener);
    return () => window.removeEventListener("message", listener);
  }, [handler]);
}