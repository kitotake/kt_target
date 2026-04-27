import React, { useCallback } from "react";
import { useNuiMessage } from "./hooks/useNuiMessage";
import { useVisibility }  from "./hooks/useVisibility";
import { useTarget }      from "./features/target/useTarget";
import { TargetMenu }     from "./components/target/TargetMenu/TargetMenu";
import type { NuiEvent }  from "./typings";

export const App: React.FC = () => {
  const { visible, optionsMeta, noOptions, handleNuiEvent } = useTarget();

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
