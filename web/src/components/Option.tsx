import React from "react";
import { fetchNui } from "./fetchNui";

type OptionProps = {
  type: string;
  id: number;
  zoneId?: number;
  data: {
    label: string;
    icon: string;
    iconColor?: string;
    hide?: boolean;
  };
};

export const Option: React.FC<OptionProps> = ({ type, id, zoneId, data }) => {
  if (data.hide) return null;

  const handleClick = async (e: React.MouseEvent<HTMLDivElement>) => {
    const el = e.currentTarget;
    el.style.pointerEvents = "none";

    await fetchNui("select", [type, id, zoneId]);

    setTimeout(() => {
      el.style.pointerEvents = "auto";
    }, 100);
  };

  return (
    <div className="option-container" onClick={handleClick}>
      <i
        className={`fa-fw ${data.icon} option-icon`}
        style={{ color: data.iconColor }}
      />
      <p className="option-label">{data.label}</p>
    </div>
  );
};