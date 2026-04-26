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
      if (!data || !data.event) return;

      switch (data.event) {
        case "visible": {
          const isVisible = !!data.state;
          setVisible(isVisible);

          if (!isVisible) reset();
          break;
        }

        case "leftTarget": {
          reset();
          break;
        }

        case "setTarget": {
          setEyeHover(true);

          const { meta, totalVisible } = parseOptions(data);

          setOptionsMeta(meta);
          setNoOptions(
            totalVisible === 0
              ? data.noOptionsLabel ?? DEFAULT_NO_OPTIONS_LABEL
              : null
          );

          break;
        }
      }
    },
    [reset]
  );

  return { visible, optionsMeta, noOptions, handleNuiEvent };
}