import React, { useCallback } from "react";
import { Option, NoOptions } from "./components";
import { useNuiMessage, useVisibility } from "./hooks";
import { useTargetStore } from "./features/target";
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
    <>
      {optionsMeta.map((meta) => (
        <Option
          key={meta.key}
          type={meta.type}
          id={meta.id}
          zoneId={meta.zoneId}
          data={meta.data}
        />
      ))}
      {noOptions && <NoOptions label={noOptions} />}
    </>
  );
};

export default App;