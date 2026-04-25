import React, { useEffect, useState } from "react";
import { Option } from "./components/Option";

type OptionMeta = {
  key: string;
  type: string;
  id: number;
  zoneId?: number;
  data: {
    label: string;
    icon: string;
    iconColor?: string;
    hide?: boolean;
    cooldown?: number;
  };
};

type NuiData = {
  event: string;
  state?: boolean;
  options?: Record<string, any[]>;
  zones?: any[][];
  noOptionsLabel?: string;
};

export const App: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [eyeHover, setEyeHover] = useState(false);
  const [optionsMeta, setOptionsMeta] = useState<OptionMeta[]>([]);
  const [noOptions, setNoOptions] = useState<string | null>(null);

  // Sync eye-hover sur le SVG statique dans le HTML
  useEffect(() => {
    const svg = document.getElementById("eyeSvg");
    if (!svg) return;
    svg.classList.toggle("eye-hover", eyeHover);
  }, [eyeHover]);

  // Sync visibility sur le body (l'œil et les options sont hors React)
  useEffect(() => {
    document.body.style.visibility = visible ? "visible" : "hidden";
  }, [visible]);

  useEffect(() => {
    const handleMessage = (event: MessageEvent<NuiData>) => {
      const data = event.data;

      switch (data.event) {
        case "visible":
          setVisible(!!data.state);
          if (!data.state) {
            setEyeHover(false);
            setOptionsMeta([]);
            setNoOptions(null);
          }
          break;

        case "leftTarget":
          setEyeHover(false);
          setOptionsMeta([]);
          setNoOptions(null);
          break;

        case "setTarget": {
          setEyeHover(true);
          setNoOptions(null);

          let totalVisible = 0;
          const newMeta: OptionMeta[] = [];

          if (data.options) {
            Object.entries(data.options).forEach(([type, list]) => {
              list.forEach((opt, index) => {
                if (!opt.hide) totalVisible++;
                newMeta.push({
                  key: `${type}-${index + 1}`,
                  type,
                  id: index + 1,
                  data: opt,
                });
              });
            });
          }

          if (data.zones) {
            data.zones.forEach((zone, zoneIndex) => {
              zone.forEach((opt, index) => {
                if (!opt.hide) totalVisible++;
                newMeta.push({
                  key: `zone-${zoneIndex + 1}-${index + 1}`,
                  type: "zones",
                  id: index + 1,
                  zoneId: zoneIndex + 1,
                  data: opt,
                });
              });
            });
          }

          setOptionsMeta(newMeta);

          if (totalVisible === 0) {
            setNoOptions(data.noOptionsLabel || "No interactions available");
          }
          break;
        }
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  // React gère uniquement les options — l'œil est dans le HTML statique
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
      {noOptions && <p id="no-options">{noOptions}</p>}
    </>
  );
};

export default App;