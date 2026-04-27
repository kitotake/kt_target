import { useEffect, useRef } from "react";

/**
 * Debounce a callback — only fires after `delay` ms without new calls.
 */
export function useDebounce(callback: () => void, delay: number): () => void {
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    return () => {
      if (timer.current) clearTimeout(timer.current);
    };
  }, []);

  return () => {
    if (timer.current) clearTimeout(timer.current);
    timer.current = setTimeout(callback, delay);
  };
}
