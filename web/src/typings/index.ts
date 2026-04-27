// ─── Target option shape (matches Lua serialization) ─────────────────────────

export type TargetOption = {
  label:      string;
  icon:       string;
  iconColor?: string;
  hide?:      boolean;
  cooldown?:  number;   // ms
  name?:      string;
  menuName?:  string;
  openMenu?:  string;
};

export type OptionGroup = {
  key:     string;
  options: TargetOption[];
};

export type ZoneGroup = {
  zoneId:  number;
  options: TargetOption[];
};

// ─── NUI event union ─────────────────────────────────────────────────────────

export type NuiEvent =
  | { event: "visible"; state: boolean }
  | { event: "leftTarget" }
  | {
      event:           "setTarget";
      groups?:         OptionGroup[];
      zones?:          ZoneGroup[];
      noOptionsLabel?: string;
    };

// ─── Internal flattened option ────────────────────────────────────────────────

export type OptionMeta = {
  key:          string;
  groupIndex?:  number;
  optionIndex:  number;
  zoneId?:      number;
  data:         TargetOption;
};
