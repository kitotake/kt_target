import React, { useRef } from "react";
import { fetchNui } from "../utils";
import { useCooldown } from "../hooks";
import { CLICK_LOCKOUT_MS } from "../config";
import { CooldownBar } from "./CooldownBar";
import type { OptionMeta } from "../typings";

type OptionProps = Pick<OptionMeta, "type" | "id" | "zoneId" | "data">;

export const Option: React.FC<OptionProps> = ({ type, id, zoneId, data }) => {
  const { isCooling, progress, startCooldown } = useCooldown();
  const elRef = useRef<HTMLDivElement>(null);

  if (data.hide) return null;

  const handleClick = async () => {
    if (isCooling) return;

    const el = elRef.current;
    if (el) el.style.pointerEvents = "none";

    await fetchNui("select", [type, id, zoneId]);

    if (data.cooldown && data.cooldown > 0) {
      startCooldown(data.cooldown, () => {
        if (el) el.style.pointerEvents = "auto";
      });
    } else {
      setTimeout(() => {
        if (el) el.style.pointerEvents = "auto";
      }, CLICK_LOCKOUT_MS);
    }
  };

  return (
    <div
      ref={elRef}
      className={`option-container${isCooling ? " option-cooling" : ""}`}
      onClick={handleClick}
    >
      <i
        className={`fa-fw ${data.icon} option-icon`}
        style={data.iconColor ? { color: data.iconColor } : undefined}
      />
      <p className="option-label">{data.label}</p>

      {isCooling && <CooldownBar progress={progress} />}
    </div>
  );
};