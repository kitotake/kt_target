import type { OptionMeta } from "../../../typings";

export interface OptionProps {
  meta:          OptionMeta;
  /** Whether this option is keyboard-focused */
  focused?:      boolean;
  /** Cooldown progress 1 → 0 (0 = not cooling) */
  cooldownProgress?: number;
  isCooling?:    boolean;
  onClick:       (meta: OptionMeta) => void;
}