// ─── Resource name (FiveM NUI) ────────────────────────────────────────────────

type NuiWindow = Window & {
  GetParentResourceName?: () => string;
  invokeNative?: unknown;
};

const nuiWindow = window as NuiWindow;

export const RESOURCE_NAME = nuiWindow.GetParentResourceName?.() ?? "kt_target";
export const IS_CFX_NUI = typeof nuiWindow.invokeNative !== "undefined";

// ─── Default labels ───────────────────────────────────────────────────────────

export const DEFAULT_NO_OPTIONS_LABEL = "No interactions available";

// ─── Eye SVG element id ───────────────────────────────────────────────────────

export const EYE_SVG_ID = "eyeSvg";

// ─── Cooldown ────────────────────────────────────────────────────────────────

/** Minimum ms before pointer-events re-enable after a click (no cooldown) */
export const CLICK_LOCKOUT_MS = 100;
