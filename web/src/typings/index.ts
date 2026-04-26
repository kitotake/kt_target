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
  // Les champs runtime Lua (groups, items, canInteract, etc.) ne sont
  // jamais envoyés au NUI — le Lua les filtre dans serializeOption().
};

// ─── Payload NUI : un groupe d'options (ex: __global, globalTarget, model…)
export type OptionGroup = {
  key: string;       // nom Lua interne (__global, globalTarget, model…)
  options: TargetOption[];
};

// ─── Payload NUI : une zone (PolyZone, BoxZone, SphereZone)
export type ZoneGroup = {
  zoneId: number;    // 1-based, correspond à nearbyZones[zoneId] côté Lua
  options: TargetOption[];
};

// ─── NUI Messages ────────────────────────────────────────────────────────────

export type NuiEvent =
  | { event: "visible"; state: boolean }
  | { event: "leftTarget" }
  | {
      event: "setTarget";
      // ✅ Correction : "groups" (indices numériques stables) + "zones"
      groups?: OptionGroup[];
      zones?: ZoneGroup[];
      noOptionsLabel?: string;
    };

// ─── Ce que React renvoie via fetchNui("select", …) ──────────────────────────
// [groupIndex, optionIndex, zoneId?]
//   groupIndex  : index 1-based dans groups[]  (null/undefined si zone)
//   optionIndex : index 1-based dans options[]
//   zoneId      : index 1-based dans zones[]   (null/undefined si entité)
export type SelectPayload =
  | [groupIndex: number, optionIndex: number, zoneId?: undefined]
  | [groupIndex: undefined, optionIndex: number, zoneId: number];

// ─── Internal option meta (used by React rendering) ──────────────────────────

export type OptionMeta = {
  key: string;
  /** 1-based index dans groups[] — undefined si c'est une zone */
  groupIndex?: number;
  /** 1-based index dans options[] du groupe ou de la zone */
  optionIndex: number;
  /** 1-based index dans zones[] — undefined si c'est une entité */
  zoneId?: number;
  data: TargetOption;
};