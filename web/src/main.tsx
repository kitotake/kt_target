import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { MantineProvider } from "@mantine/core";
import "@mantine/core/styles.css";
import "./styles/main.scss";
import App from "./App";
import { theme } from "./theme";

const mount = () => {
  const container = document.getElementById("options-wrapper");
  if (!container) {
    console.error("[kt_target] #options-wrapper introuvable dans le DOM");
    return;
  }

  createRoot(container).render(
    <StrictMode>
      <MantineProvider theme={theme} defaultColorScheme="dark">
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