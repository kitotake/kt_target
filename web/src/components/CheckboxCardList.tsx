import React, { useCallback, useState } from "react";
import { Stack } from "@mantine/core";
import { CheckboxCard } from "./CheckboxCard";
import type { CheckboxCardOption } from "./CheckboxCard";

type CheckboxCardListProps = {
  options: CheckboxCardOption[];
  mode?: "single" | "multiple";
  defaultSelected?: string[];
  onChange?: (selected: string[]) => void;
};

export const CheckboxCardList: React.FC<CheckboxCardListProps> = ({
  options,
  mode = "single",
  defaultSelected = [],
  onChange,
}) => {
  const [selected, setSelected] = useState<Set<string>>(
    new Set(defaultSelected)
  );

  const handleToggle = useCallback(
    (value: string) => {
      setSelected((prev) => {
        const next = new Set(prev);

        if (mode === "single") {
          // Single : on remplace la sélection
          if (next.has(value)) {
            next.clear();
          } else {
            next.clear();
            next.add(value);
          }
        } else {
          // Multiple : on toggle
          if (next.has(value)) {
            next.delete(value);
          } else {
            next.add(value);
          }
        }

        onChange?.(Array.from(next));
        return next;
      });
    },
    [mode, onChange]
  );

  return (
    <Stack gap="xs">
      {options.map((opt) => (
        <CheckboxCard
          key={opt.value}
          option={opt}
          selected={selected.has(opt.value)}
          onToggle={handleToggle}
        />
      ))}
    </Stack>
  );
};