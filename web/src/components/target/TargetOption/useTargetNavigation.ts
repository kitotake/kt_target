import { useCallback, useEffect, useRef, useState } from "react";
import type { OptionMeta } from "../../../typings";

export interface UseTargetNavigationReturn {
  /** Index of the currently focused option (-1 = none) */
  focusedIndex: number;
  /** Call to reset focus (e.g. when options change) */
  resetFocus: () => void;
  /** Ref to attach to the options container for scroll management */
  containerRef: React.RefObject<HTMLDivElement | null>;
}

/**
 * Keyboard navigation for the target menu.
 *
 * - ArrowUp / ArrowDown  → move focus
 * - Home / End           → jump to first / last
 * - Escape               → reset focus
 *
 * Pass `onActivate` to fire when Enter / Space is pressed on a focused option.
 */
export function useTargetNavigation(
  options: OptionMeta[],
  onActivate?: (meta: OptionMeta) => void
): UseTargetNavigationReturn {
  const [focusedIndex, setFocusedIndex] = useState(-1);
  const containerRef = useRef<HTMLDivElement | null>(null);

  const visibleOptions = options.filter((o) => !o.data.hide);
  const count = visibleOptions.length;

  const resetFocus = useCallback(() => setFocusedIndex(-1), []);

  // Reset whenever the option list changes
  useEffect(() => {
    resetFocus();
  }, [options, resetFocus]);

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (count === 0) return;

      switch (e.key) {
        case "ArrowDown": {
          e.preventDefault();
          setFocusedIndex((prev) => (prev + 1) % count);
          break;
        }
        case "ArrowUp": {
          e.preventDefault();
          setFocusedIndex((prev) => (prev <= 0 ? count - 1 : prev - 1));
          break;
        }
        case "Home": {
          e.preventDefault();
          setFocusedIndex(0);
          break;
        }
        case "End": {
          e.preventDefault();
          setFocusedIndex(count - 1);
          break;
        }
        case "Escape": {
          resetFocus();
          break;
        }
        case "Enter":
        case " ": {
          e.preventDefault();
          if (focusedIndex >= 0 && focusedIndex < count) {
            onActivate?.(visibleOptions[focusedIndex]);
          }
          break;
        }
      }
    },
    [count, focusedIndex, visibleOptions, onActivate, resetFocus]
  );

  useEffect(() => {
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [handleKeyDown]);

  // Scroll focused item into view
  useEffect(() => {
    if (focusedIndex < 0) return;
    const container = containerRef.current;
    if (!container) return;
    const items = container.querySelectorAll<HTMLElement>("[data-option-item]");
    items[focusedIndex]?.scrollIntoView({ block: "nearest" });
  }, [focusedIndex]);

  return { focusedIndex, resetFocus, containerRef };
}