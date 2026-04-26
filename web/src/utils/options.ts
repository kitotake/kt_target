import type { NuiEvent, OptionMeta, TargetOption } from "../typings";

type SetTargetPayload = Extract<NuiEvent, { event: "setTarget" }>;

export function parseOptions(data: SetTargetPayload): {
  meta: OptionMeta[];
  totalVisible: number;
} {
  const meta: OptionMeta[] = [];
  let totalVisible = 0;

  if (data.options) {
    Object.entries(data.options).forEach(([type, list]) => {
      (list as TargetOption[]).forEach((opt, index) => {
        if (!opt.hide) totalVisible++;
        meta.push({
          key: `${type}-${index + 1}`,
          type,
          id: index + 1,
          data: opt,
        });
      });
    });
  }

  if (data.zones) {
    data.zones.forEach((zone, zoneIndex) => {
      (zone as TargetOption[]).forEach((opt, index) => {
        if (!opt.hide) totalVisible++;
        meta.push({
          key: `zone-${zoneIndex + 1}-${index + 1}`,
          type: "zones",
          id: index + 1,
          zoneId: zoneIndex + 1,
          data: opt,
        });
      });
    });
  }

  return { meta, totalVisible };
}