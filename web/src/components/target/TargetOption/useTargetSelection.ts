import { useCallback, useRef, useState } from "react";
import { fetchNui } from "../../../utils/fetchNui";
// FIX: Import depuis src/config (source unique) au lieu de "../../../config"
// qui pointait vers le même fichier — conservé pour clarté.
import { CLICK_LOCKOUT_MS } from "../../../config";
import type { OptionMeta } from "../../../typings";

export interface SelectionState {
  isCooling: boolean;
  progress: number;
}

export interface UseTargetSelectionReturn {
  selectOption: (meta: OptionMeta) => Promise<void>;
  getState: (key: string) => SelectionState;
}

export function useTargetSelection(): UseTargetSelectionReturn {
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

      const payload =
        meta.zoneId !== undefined
          ? [0, meta.optionIndex, meta.zoneId]
          : [meta.groupIndex ?? 0, meta.optionIndex, 0];

      const el = document.querySelector<HTMLElement>(
        `[data-option-key="${meta.key}"]`
      );
      if (el) el.style.pointerEvents = "none";

      try {
        await fetchNui("select", payload);

        if (meta.data.cooldown && meta.data.cooldown > 0) {
          startCooldown(meta.key, meta.data.cooldown, el);
          return;
        }
      } catch (err) {
        console.error("[useTargetSelection] select failed:", err);
      }

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