import { useCallback, useEffect, useRef, useState } from "react";

type UseCooldownReturn = {
  isCooling: boolean;
  progress: number; // 1 → 0
  startCooldown: (durationMs: number, onDone?: () => void) => void;
};

export function useCooldown(): UseCooldownReturn {
  const [isCooling, setIsCooling] = useState(false);
  const [progress, setProgress] = useState(0);
  const rafRef = useRef<number | null>(null);

  useEffect(() => {
    return () => {
      if (rafRef.current !== null) cancelAnimationFrame(rafRef.current);
    };
  }, []);

  const startCooldown = useCallback(
    (durationMs: number, onDone?: () => void) => {
      const startedAt = performance.now();
      setIsCooling(true);
      setProgress(1);

      const tick = () => {
        const remaining = 1 - (performance.now() - startedAt) / durationMs;

        if (remaining <= 0) {
          setProgress(0);
          setIsCooling(false);
          onDone?.();
          return;
        }

        setProgress(remaining);
        rafRef.current = requestAnimationFrame(tick);
      };

      rafRef.current = requestAnimationFrame(tick);
    },
    []
  );

  return { isCooling, progress, startCooldown };
}