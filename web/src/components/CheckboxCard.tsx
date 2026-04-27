import React, { useCallback, useId } from "react";
import { Card, Checkbox, Group, Text, Badge } from "@mantine/core";

export type CheckboxCardOption = {
  value: string;
  label: string;
  description?: string;
  icon?: string;       // classe FontAwesome
  iconColor?: string;
  disabled?: boolean;
  badge?: string;
};

type CheckboxCardProps = {
  option: CheckboxCardOption;
  selected: boolean;
  onToggle: (value: string) => void;
};

export const CheckboxCard: React.FC<CheckboxCardProps> = React.memo(
  ({ option, selected, onToggle }) => {
    const id = useId();

    const handleClick = useCallback(() => {
      if (option.disabled) return;
      onToggle(option.value);
    }, [option.disabled, option.value, onToggle]);

    const handleKeyDown = useCallback(
      (e: React.KeyboardEvent) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          handleClick();
        }
      },
      [handleClick]
    );

    return (
      <Card
        className={[
          "checkbox-card",
          selected   ? "checkbox-card--selected"  : "",
          option.disabled ? "checkbox-card--disabled" : "",
        ]
          .filter(Boolean)
          .join(" ")}
        onClick={handleClick}
        onKeyDown={handleKeyDown}
        tabIndex={option.disabled ? -1 : 0}
        role="checkbox"
        aria-checked={selected}
        aria-disabled={option.disabled}
        aria-labelledby={id}
        withBorder
        radius="sm"
        p="sm"
      >
        <Group justify="space-between" wrap="nowrap">
          <Group gap="sm" wrap="nowrap" style={{ flex: 1, minWidth: 0 }}>

            {/* Icône */}
            {option.icon && (
              <i
                className={`fa-fw ${option.icon} checkbox-card__icon`}
                style={option.iconColor ? { color: option.iconColor } : undefined}
                aria-hidden="true"
              />
            )}

            {/* Texte */}
            <div style={{ minWidth: 0 }}>
              <Text
                id={id}
                size="sm"
                fw={500}
                className="checkbox-card__label"
                truncate
              >
                {option.label}
              </Text>
              {option.description && (
                <Text
                  size="xs"
                  c="dimmed"
                  className="checkbox-card__description"
                  truncate
                >
                  {option.description}
                </Text>
              )}
            </div>

          </Group>

          <Group gap="xs" wrap="nowrap">
            {option.badge && (
              <Badge size="xs" variant="light" color="violet">
                {option.badge}
              </Badge>
            )}
            <Checkbox
              checked={selected}
              onChange={() => {}} // géré par onClick du Card
              disabled={option.disabled}
              tabIndex={-1}       // focus géré par le Card
              aria-hidden="true"
              color="violet"
              radius="sm"
            />
          </Group>
        </Group>
      </Card>
    );
  }
);

CheckboxCard.displayName = "CheckboxCard";