import type { OptionMeta } from "../../../typings";

export interface TargetOptionProps {
  meta:      OptionMeta;
  /** Called after a successful select NUI call */
  onSelect?: (meta: OptionMeta) => void;
}
