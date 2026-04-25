import React, { useEffect, useRef, useState } from "react";
import { fetchNui } from "../utils/fetchNui";

type OptionProps = {
  type: string;
  id: number;
  zoneId?: number;
  data: {
    label: string;
    icon: string;
    iconColor?: string;
    hide?: boolean;
    cooldown?: number; // ms — optionnel, défini côté Lua
  };
};

export const Option: React.FC<OptionProps> = ({ type, id, zoneId, data }) => {
  const [progress, setProgress] = useState(0); // 1 → 0
  const [isCooling, setIsCooling] = useState(false);
  const rafRef = useRef<number | null>(null);

  useEffect(() => {
    return () => {
      if (rafRef.current) cancelAnimationFrame(rafRef.current);
    };
  }, []);

  if (data.hide) return null;

  const handleClick = async (e: React.MouseEvent<HTMLDivElement>) => {
    if (isCooling) return;

    const el = e.currentTarget;
    el.style.pointerEvents = "none";

    await fetchNui("select", [type, id, zoneId]);

    if (data.cooldown && data.cooldown > 0) {
      const duration = data.cooldown;
      const startedAt = performance.now();

      setIsCooling(true);
      setProgress(1);

      const tick = () => {
        const remaining = 1 - (performance.now() - startedAt) / duration;

        if (remaining <= 0) {
          setProgress(0);
          setIsCooling(false);
          el.style.pointerEvents = "auto";
          return;
        }

        setProgress(remaining);
        rafRef.current = requestAnimationFrame(tick);
      };

      rafRef.current = requestAnimationFrame(tick);
    } else {
      setTimeout(() => (el.style.pointerEvents = "auto"), 100);
    }
  };

  return (
    <div
      className={`option-container${isCooling ? " option-cooling" : ""}`}
      onClick={handleClick}
    >
      <i
        className={`fa-fw ${data.icon} option-icon`}
        style={{ color: data.iconColor }}
      />
      <p className="option-label">{data.label}</p>

      {isCooling && (
        <div className="option-cooldown-bar">
          <div
            className="option-cooldown-fill"
            style={{ transform: `scaleX(${progress})` }}
          />
        </div>
      )}
    </div>
  );
};