// ─── Target Options ───────────────────────────────────────────────────────────

export type TargetOption = {
  label: string;
  icon: string;
  iconColor?: string;
  hide?: boolean;
  cooldown?: number; // ms
  name?: string;
  menuName?: string;
  openMenu?: string;
};

// ─── Payload NUI : un groupe d'options
export type OptionGroup = {
  key: string;
  options: TargetOption[];
};

// ─── Payload NUI : une zone
export type ZoneGroup = {
  zoneId: number;
  options: TargetOption[];
};

// ─── NUI Messages ────────────────────────────────────────────────────────────

export type NuiEvent =
  | { event: "visible"; state: boolean }
  | { event: "leftTarget" }
  | {
      event: "setTarget";
      groups?: OptionGroup[];
      zones?: ZoneGroup[];
      noOptionsLabel?: string;
    };

// ─── Payload envoyé via fetchNui("select", …) ────────────────────────────────
// [groupIndex, optionIndex, zoneId]
// groupIndex = 0 si c'est une zone
// zoneId     = 0 si c'est une entité
export type SelectPayload = [
  groupIndex: number,
  optionIndex: number,
  zoneId: number,
];

// ─── Internal option meta ─────────────────────────────────────────────────────

export type OptionMeta = {
  key: string;
  groupIndex?: number;
  optionIndex: number;
  zoneId?: number;
  data: TargetOption;
};
