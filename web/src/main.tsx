import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { MantineProvider } from "@mantine/core";

import "./styles/main.scss";
import App from "./App";

const mount = () => {
  const container = document.getElementById("options-wrapper");
  if (!container) {
    console.error("[kt_target] #options-wrapper not found in DOM");
    return;
  }

  createRoot(container).render(
    <StrictMode>
      <MantineProvider >
        <App />
      </MantineProvider>
    </StrictMode>
  );
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", mount);
} else {
  mount();
}