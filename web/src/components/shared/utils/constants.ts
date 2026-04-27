export const RESOURCE_NAME =
  (window as unknown as { GetParentResourceName?: () => string })
    .GetParentResourceName?.() ?? "kt_target";

export const CLICK_LOCKOUT_MS = 120;
export const DEFAULT_NO_OPTIONS_LABEL = "No interactions available";
export const EYE_SVG_ID = "eyeSvg";
