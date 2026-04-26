// ─── Target Options ───────────────────────────────────────────────────────────

export type TargetOption = {
  label: string;
  icon: string;
  iconColor?: string;
  hide?: boolean;
  cooldown?: number; // ms
  name?: string;
  groups?: string | string[] | Record<string, number>;
  items?: string | string[] | Record<string, number>;
  menuName?: string;
  openMenu?: string;
  distance?: number;
  bones?: string | string[];
  offset?: [number, number, number];
  canInteract?: (...args: any[]) => boolean;
  onSelect?: (data: any) => void;
  event?: string;
  serverEvent?: string;
  command?: string;
  export?: string;
  resource?: string;
  qtarget?: boolean;
};

// ─── NUI Messages ────────────────────────────────────────────────────────────

export type NuiEvent =
  | { event: "visible"; state: boolean }
  | { event: "leftTarget" }
  | {
      event: "setTarget";
      options?: Record<string, TargetOption[]>;
      zones?: TargetOption[][];
      noOptionsLabel?: string;
    };

// ─── Internal option meta (used by React rendering) ──────────────────────────

export type OptionMeta = {
  key: string;
  type: string;
  id: number;
  zoneId?: number;
  data: TargetOption;
};