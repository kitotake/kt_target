import { StrictMode } from "react";
import { createRoot }  from "react-dom/client";
import "./styles/main.scss";
import App from "./App";

const mount = () => {
  const container = document.getElementById("options-wrapper");
  if (!container) {
    console.error("[kt_target] #options-wrapper not found");
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
