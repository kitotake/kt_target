import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
// ✅ On n'importe plus Mantine du tout — aucun composant Mantine
// n'est utilisé dans l'UI finale (l'UI est du pur HTML + SCSS).
// Garder MantineProvider causait des conflits de reset CSS.
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
      <App />
    </StrictMode>
  );
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", mount);
} else {
  mount();
}