import type { OptionMeta } from "../../../typings";

export interface TargetMenuProps {
  options:    OptionMeta[];
  noOptions:  string | null;
  /** Optional header metadata */
  entityType?: string;
  entityName?: string;
}
