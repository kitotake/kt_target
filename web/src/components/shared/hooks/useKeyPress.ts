import { useEffect } from "react";

/**
 * Fires `handler` whenever `key` is pressed.
 * @param key - e.g. "Escape", "Enter", "Tab"
 */
export function useKeyPress(key: string, handler: () => void): void {
  useEffect(() => {
    const listener = (e: KeyboardEvent) => {
      if (e.key === key) handler();
    };
    window.addEventListener("keydown", listener);
    return () => window.removeEventListener("keydown", listener);
  }, [key, handler]);
}
