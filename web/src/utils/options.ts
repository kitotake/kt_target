import type { NuiEvent, OptionMeta } from "../typings";

type SetTargetPayload = Extract<NuiEvent, { event: "setTarget" }>;

export function parseOptions(data: SetTargetPayload): {
  meta: OptionMeta[];
  totalVisible: number;
} {
  const meta: OptionMeta[] = [];
  let totalVisible = 0;

  // ✅ Correction : on itère sur data.groups (tableau indexé numériquement)
  // groupIndex est le rang 1-based du groupe → correspond à optionsGroups[groupIndex] côté Lua
  if (data.groups) {
    data.groups.forEach((group, gIdx) => {
      const groupIndex = gIdx + 1; // 1-based pour Lua

      group.options.forEach((opt, oIdx) => {
        const optionIndex = oIdx + 1; // 1-based pour Lua

        if (!opt.hide) totalVisible++;

        meta.push({
          key: `${group.key}-${optionIndex}`,
          groupIndex,
          optionIndex,
          // zoneId absent : c'est une option d'entité
          data: opt,
        });
      });
    });
  }

  // ✅ Correction : on itère sur data.zones
  // zoneId est fourni directement par le Lua dans le payload (1-based)
  if (data.zones) {
    data.zones.forEach((zone) => {
      zone.options.forEach((opt, oIdx) => {
        const optionIndex = oIdx + 1; // 1-based pour Lua

        if (!opt.hide) totalVisible++;

        meta.push({
          key: `zone-${zone.zoneId}-${optionIndex}`,
          // groupIndex absent : c'est une option de zone
          optionIndex,
          zoneId: zone.zoneId,
          data: opt,
        });
      });
    });
  }

  return { meta, totalVisible };
}