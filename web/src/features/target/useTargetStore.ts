import { useCallback, useState } from "react";
import type { NuiEvent, OptionMeta } from "../../typings";
import { setEyeHover, parseOptions } from "../../utils";
import { DEFAULT_NO_OPTIONS_LABEL } from "../../config";

type TargetStore = {
  visible: boolean;
  optionsMeta: OptionMeta[];
  noOptions: string | null;
  handleNuiEvent: (data: NuiEvent) => void;
};

export function useTargetStore(): TargetStore {
  const [visible, setVisible] = useState(false);
  const [optionsMeta, setOptionsMeta] = useState<OptionMeta[]>([]);
  const [noOptions, setNoOptions] = useState<string | null>(null);

  const reset = useCallback(() => {
    setEyeHover(false);
    setOptionsMeta([]);
    setNoOptions(null);
  }, []);

  const handleNuiEvent = useCallback(
    (data: NuiEvent) => {
      switch (data.event) {
        case "visible":
          setVisible(!!data.state);
          if (!data.state) reset();
          break;

        case "leftTarget":
          reset();
          break;

        case "setTarget": {
          setEyeHover(true);
          setNoOptions(null);

          // ✅ parseOptions gère maintenant data.groups + data.zones
          const { meta, totalVisible } = parseOptions(data);
          setOptionsMeta(meta);

          if (totalVisible === 0) {
            setNoOptions(data.noOptionsLabel ?? DEFAULT_NO_OPTIONS_LABEL);
          }
          break;
        }
      }
    },
    [reset]
  );

  return { visible, optionsMeta, noOptions, handleNuiEvent };
}