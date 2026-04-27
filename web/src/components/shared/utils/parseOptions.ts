import type { NuiEvent, OptionMeta } from "../../../typings";

type SetTargetPayload = Extract<NuiEvent, { event: "setTarget" }>;

export function parseOptions(data: SetTargetPayload): {
  meta: OptionMeta[];
  totalVisible: number;
} {
  const meta: OptionMeta[] = [];
  let totalVisible = 0;

  if (data.groups) {
    data.groups.forEach((group, gIdx) => {
      const groupIndex = gIdx + 1;
      group.options.forEach((opt, oIdx) => {
        const optionIndex = oIdx + 1;
        if (!opt.hide) totalVisible++;
        meta.push({
          key: `${group.key}-${optionIndex}`,
          groupIndex,
          optionIndex,
          data: opt,
        });
      });
    });
  }

  if (data.zones) {
    data.zones.forEach((zone) => {
      zone.options.forEach((opt, oIdx) => {
        const optionIndex = oIdx + 1;
        if (!opt.hide) totalVisible++;
        meta.push({
          key: `zone-${zone.zoneId}-${optionIndex}`,
          optionIndex,
          zoneId: zone.zoneId,
          data: opt,
        });
      });
    });
  }

  return { meta, totalVisible };
}
