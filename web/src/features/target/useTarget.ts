import { useCallback, useState } from "react";
import type { NuiEvent, OptionMeta } from "../../typings";
import { parseOptions } from "../../components/shared/utils/parseOptions";

type EyeEl = HTMLElement | null;

function setEyeHover(value: boolean): void {
  const svg: EyeEl = document.getElementById("eyeSvg");
  svg?.classList.toggle("eye-hover", value);
}

export type TargetState = {
  visible: boolean;
  optionsMeta: OptionMeta[];
  noOptions: string | null;
  handleNuiEvent: (data: NuiEvent) => void;
};

export function useTarget(): TargetState {
  const [visible, setVisible] = useState(false);
  const [optionsMeta, setOptionsMeta] = useState<OptionMeta[]>([]);
  const [noOptions, setNoOptions] = useState<string | null>(null);

  const reset = useCallback(() => {
    setEyeHover(false);
    setVisible(false);
    setOptionsMeta([]);
    setNoOptions(null);
  }, []);

  const handleNuiEvent = useCallback(
    (data: NuiEvent) => {
      if (!data?.event) return;

      switch (data.event) {
        case "visible": {
          const isVisible = !!data.state;
          setVisible(isVisible);
          setEyeHover(isVisible);
          if (!isVisible) reset();
          break;
        }
        case "leftTarget": {
          setEyeHover(true);
          setOptionsMeta([]);
          setNoOptions(null);
          break;
        }
        case "setTarget": {
          setVisible(true);
          setEyeHover(true);
          const { meta } = parseOptions(data);
          setOptionsMeta(meta);
          setNoOptions(data.noOptionsLabel ?? null);
          break;
        }
      }
    },
    [reset]
  );

  return { visible, optionsMeta, noOptions, handleNuiEvent };
}
