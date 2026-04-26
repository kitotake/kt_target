import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "@mantine/core/styles.css";
import "./styles/main.scss";
import App from "./App";
import { ThemeProvider } from "./providers";

const mount = () => {
  const container = document.getElementById("options-wrapper");
  if (!container) {
    console.error("[kt_target] #options-wrapper not found in DOM");
    return;
  }

  createRoot(container).render(
    <StrictMode>
      <ThemeProvider>
        <App />
      </ThemeProvider>
    </StrictMode>
  );
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", mount);
} else {
  mount();
}