import { useCallback, useState } from "react";
import type { NuiEvent, OptionMeta } from "../../typings";
import { setEyeHover, parseOptions } from "../../utils";

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
    setVisible(false);
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
          setEyeHover(isVisible);
          if (!isVisible) reset();
          break;
        }

        case "leftTarget": {
          // Garde le body visible (ALT encore maintenu)
          // mais vide les options
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

          // noOptionsLabel est envoyé par le Lua uniquement si des options
          // existent mais sont toutes cachées (canInteract / groups / items)
          setNoOptions(data.noOptionsLabel ?? null);
          break;
        }
      }
    },
    [reset]
  );

  return { visible, optionsMeta, noOptions, handleNuiEvent };
}