import React, { useCallback } from "react";
import { Stack, Text } from "@mantine/core";
import { CheckboxCard } from "./CheckboxCard";
import { fetchNui } from "../utils";
import { useCooldown } from "../hooks";
import type { OptionMeta } from "../typings";

type TargetMenuProps = {
  options: OptionMeta[];
  noOptions: string | null;
};

export const TargetMenu: React.FC<TargetMenuProps> = ({ options, noOptions }) => {
  if (options.length === 0 && !noOptions) return null;

  if (noOptions) {
    return (
      <div id="options-wrapper">
        <Text id="no-options" size="sm" c="dimmed" fs="italic">
          {noOptions}
        </Text>
      </div>
    );
  }

  return (
    <div id="options-wrapper">
      <Stack gap={2}>
        {options.map((meta) => (
          <TargetOption key={meta.key} meta={meta} />
        ))}
      </Stack>
    </div>
  );
};

// ─── Option individuelle ──────────────────────────────────────────────────────

type TargetOptionProps = { meta: OptionMeta };

const TargetOption: React.FC<TargetOptionProps> = React.memo(({ meta }) => {
  const { isCooling, startCooldown } = useCooldown();

  const handleToggle = useCallback(async () => {
    if (isCooling || meta.data.hide) return;

    const payload = meta.zoneId !== undefined
      ? [0, meta.optionIndex, meta.zoneId]
      : [meta.groupIndex ?? 0, meta.optionIndex, 0];

    try {
      await fetchNui("select", payload);
      if (meta.data.cooldown && meta.data.cooldown > 0) {
        startCooldown(meta.data.cooldown);
      }
    } catch (err) {
      console.error("[TargetOption] select failed:", err);
    }
  }, [isCooling, meta, startCooldown]);

  if (meta.data.hide) return null;

  return (
    <CheckboxCard
      option={{
        value      : meta.key,
        label      : meta.data.label,
        icon       : meta.data.icon,
        iconColor  : meta.data.iconColor,
        disabled   : isCooling,
      }}
      selected={false}   // le targeting n'a pas d'état sélectionné persistant
      onToggle={handleToggle}
    />
  );
});

TargetOption.displayName = "TargetOption";