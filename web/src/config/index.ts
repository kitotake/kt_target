// ─── Resource name (FiveM NUI) ────────────────────────────────────────────────

export const RESOURCE_NAME =
  (window as any).GetParentResourceName?.() ?? "kt_target";

// ─── Default labels ───────────────────────────────────────────────────────────

export const DEFAULT_NO_OPTIONS_LABEL = "No interactions available";

// ─── Eye SVG element id ───────────────────────────────────────────────────────

export const EYE_SVG_ID = "eyeSvg";

// ─── Cooldown ────────────────────────────────────────────────────────────────

/** Minimum ms before pointer-events re-enable after a click (no cooldown) */
export const CLICK_LOCKOUT_MS = 100;