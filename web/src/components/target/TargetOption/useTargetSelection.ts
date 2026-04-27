import { useCallback, useRef, useState } from "react";
import { fetchNui } from "../../../utils/fetchNui";
import { CLICK_LOCKOUT_MS } from "../../../config";
import type { OptionMeta } from "../../../typings";

export interface SelectionState {
  /** Whether this option key is currently cooling down */
  isCooling: boolean;
  /** Cooldown progress 1 → 0 */
  progress: number;
}

export interface UseTargetSelectionReturn {
  /** Call when an option is clicked / activated */
  selectOption: (meta: OptionMeta) => Promise<void>;
  /** Get per-option selection state by key */
  getState: (key: string) => SelectionState;
}

/**
 * Centralises the NUI `select` call and per-option cooldown tracking.
 *
 * Each option keeps its own RAF-driven cooldown progress so multiple
 * options can cool down independently.
 */
export function useTargetSelection(): UseTargetSelectionReturn {
  // key → cooldown state
  const [states, setStates] = useState<Record<string, SelectionState>>({});
  const rafRefs = useRef<Record<string, number>>({});

  const startCooldown = useCallback(
    (key: string, durationMs: number, elRef: HTMLElement | null) => {
      const startedAt = performance.now();

      const tick = () => {
        const remaining = 1 - (performance.now() - startedAt) / durationMs;

        if (remaining <= 0) {
          setStates((prev) => ({ ...prev, [key]: { isCooling: false, progress: 0 } }));
          if (elRef) elRef.style.pointerEvents = "auto";
          delete rafRefs.current[key];
          return;
        }

        setStates((prev) => ({ ...prev, [key]: { isCooling: true, progress: remaining } }));
        rafRefs.current[key] = requestAnimationFrame(tick);
      };

      setStates((prev) => ({ ...prev, [key]: { isCooling: true, progress: 1 } }));
      rafRefs.current[key] = requestAnimationFrame(tick);
    },
    []
  );

  const selectOption = useCallback(
    async (meta: OptionMeta) => {
      const state = states[meta.key];
      if (state?.isCooling || meta.data.hide) return;

      // Build payload — mirrors existing convention
      const payload =
        meta.zoneId !== undefined
          ? [0, meta.optionIndex, meta.zoneId]
          : [meta.groupIndex ?? 0, meta.optionIndex, 0];

      // Grab DOM element to block pointer events during cooldown
      const el = document.querySelector<HTMLElement>(
        `[data-option-key="${meta.key}"]`
      );
      if (el) el.style.pointerEvents = "none";

      try {
        await fetchNui("select", payload);

        if (meta.data.cooldown && meta.data.cooldown > 0) {
          startCooldown(meta.key, meta.data.cooldown, el);
          return; // pointer-events re-enabled inside startCooldown
        }
      } catch (err) {
        console.error("[useTargetSelection] select failed:", err);
      }

      // No cooldown — re-enable after lockout
      setTimeout(() => {
        if (el) el.style.pointerEvents = "auto";
      }, CLICK_LOCKOUT_MS);
    },
    [states, startCooldown]
  );

  const getState = useCallback(
    (key: string): SelectionState =>
      states[key] ?? { isCooling: false, progress: 0 },
    [states]
  );

  return { selectOption, getState };
}