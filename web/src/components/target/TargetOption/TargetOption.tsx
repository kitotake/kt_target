import React, { useCallback, useRef } from "react";
import { cx } from "../../shared/utils/classNames";
import { CLICK_LOCKOUT_MS } from "../../shared/utils/constants";
import { useCooldown } from "../../../hooks/useCooldown";
import { fetchNui } from "../../../utils/fetchNui";
import type { TargetOptionProps } from "./TargetOption.types";
import s from "./TargetOption.module.scss";

export const TargetOption: React.FC<TargetOptionProps> = React.memo(
  ({ meta, onSelect }) => {
    const { isCooling, progress, startCooldown } = useCooldown();
    const elRef = useRef<HTMLDivElement>(null);

    const handleClick = useCallback(async () => {
      if (isCooling || meta.data.hide) return;

      const el = elRef.current;
      if (el) el.style.pointerEvents = "none";

      const payload =
        meta.zoneId !== undefined
          ? [0, meta.optionIndex, meta.zoneId]
          : [meta.groupIndex ?? 0, meta.optionIndex, 0];

      try {
        await fetchNui("select", payload);
        onSelect?.(meta);

        if (meta.data.cooldown && meta.data.cooldown > 0) {
          startCooldown(meta.data.cooldown, () => {
            if (el) el.style.pointerEvents = "auto";
          });
          return;
        }
      } catch (err) {
        console.error("[TargetOption] select failed:", err);
      }

      setTimeout(() => {
        if (el) el.style.pointerEvents = "auto";
      }, CLICK_LOCKOUT_MS);
    }, [isCooling, meta, onSelect, startCooldown]);

    if (meta.data.hide) return null;

    const icon = meta.data.icon ?? "fa-solid fa-hand-pointer";

    return (
      <div
        ref={elRef}
        className={cx(s.option, isCooling ? s.cooling : "")}
        onClick={handleClick}
        role="button"
        tabIndex={0}
        aria-label={meta.data.label}
        onKeyDown={(e) => {
          if (e.key === "Enter" || e.key === " ") handleClick();
        }}
      >
        <i
          className={cx("fa-fw", icon, s.icon)}
          style={meta.data.iconColor ? { color: meta.data.iconColor } : undefined}
          aria-hidden
        />
        <span className={s.label}>{meta.data.label}</span>

        {isCooling && (
          <div className={s.cooldownBar}>
            <div
              className={s.cooldownFill}
              style={{ transform: `scaleX(${progress})` }}
            />
          </div>
        )}
      </div>
    );
  }
);

TargetOption.displayName = "TargetOption";
