import React from "react";

type Props = { progress: number };

export const CooldownBar: React.FC<Props> = ({ progress }) => (
  <div className="option-cooldown-bar">
    <div
      className="option-cooldown-fill"
      style={{ transform: `scaleX(${progress})` }}
    />
  </div>
);