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
          // ✅ On passe groupIndex / optionIndex / zoneId
          // (plus "type" et "id" qui ne correspondent à rien côté Lua)
          groupIndex={meta.groupIndex}
          optionIndex={meta.optionIndex}
          zoneId={meta.zoneId}
          data={meta.data}
        />
      ))}
      {noOptions && <NoOptions label={noOptions} />}
    </>
  );
};

export default App;