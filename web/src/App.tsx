import React, { useCallback } from "react";
import { useNuiMessage, useVisibility } from "./hooks";
import { useTargetStore } from "./features/target";
import { TargetMenu } from "./components/TargetMenu";
import type { NuiEvent } from "./typings";

export const App: React.FC = () => {
  const { visible, optionsMeta, noOptions, handleNuiEvent } = useTargetStore();

  useVisibility(visible);

  const handler = useCallback(
    (data: NuiEvent) => handleNuiEvent(data),
    [handleNuiEvent]
  );

  useNuiMessage(handler);

  return (
    <TargetMenu
      options={optionsMeta}
      noOptions={noOptions}
    />
  );
};

export default App;