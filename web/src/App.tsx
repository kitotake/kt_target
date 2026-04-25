import React, { useEffect, useState } from "react";
import { Option } from "./Option";

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
  const [options, setOptions] = useState<JSX.Element[]>([]);
  const [noOptions, setNoOptions] = useState<string | null>(null);

  useEffect(() => {
    const handleMessage = (event: MessageEvent<NuiData>) => {
      const data = event.data;

      setOptions([]);
      setNoOptions(null);

      switch (data.event) {
        case "visible":
          setVisible(!!data.state);
          setEyeHover(false);
          break;

        case "leftTarget":
          setEyeHover(false);
          break;

        case "setTarget":
          setEyeHover(true);

          let totalVisible = 0;
          const newOptions: JSX.Element[] = [];

          if (data.options) {
            Object.entries(data.options).forEach(([type, list]) => {
              list.forEach((opt, index) => {
                if (!opt.hide) totalVisible++;
                newOptions.push(
                  <Option
                    key={`${type}-${index}`}
                    type={type}
                    id={index + 1}
                    data={opt}
                  />
                );
              });
            });
          }

          if (data.zones) {
            data.zones.forEach((zone, zoneIndex) => {
              zone.forEach((opt, index) => {
                if (!opt.hide) totalVisible++;
                newOptions.push(
                  <Option
                    key={`zone-${zoneIndex}-${index}`}
                    type="zones"
                    id={index + 1}
                    zoneId={zoneIndex + 1}
                    data={opt}
                  />
                );
              });
            });
          }

          setOptions(newOptions);

          if (totalVisible === 0) {
            setNoOptions(data.noOptionsLabel || "No interactions available");
          }

          break;
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  return (
    <div style={{ visibility: visible ? "visible" : "hidden" }}>
      <div id="eyeSvg" className={eyeHover ? "eye-hover" : ""} />

      <div id="options-wrapper">
        {options}
        {noOptions && <p id="no-options">{noOptions}</p>}
      </div>
    </div>
  );
};