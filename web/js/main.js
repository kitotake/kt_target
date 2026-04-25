import { createOptions } from "./createOptions.js";

const optionsWrapper = document.getElementById("options-wrapper");
const body = document.body;
const eye = document.getElementById("eyeSvg");

// Élément de feedback "aucune interaction"
const noOptions = document.createElement("p");
noOptions.id = "no-options";
noOptions.style.display = "none";
document.body.appendChild(noOptions);

window.addEventListener("message", (event) => {
  optionsWrapper.innerHTML = "";
  noOptions.style.display = "none";

  switch (event.data.event) {
    case "visible": {
      body.style.visibility = event.data.state ? "visible" : "hidden";
      return eye.classList.remove("eye-hover");
    }

    case "leftTarget": {
      return eye.classList.remove("eye-hover");
    }

    case "setTarget": {
      eye.classList.add("eye-hover");

      let totalVisible = 0;

      if (event.data.options) {
        for (const type in event.data.options) {
          event.data.options[type].forEach((data, id) => {
            if (!data.hide) totalVisible++;
            createOptions(type, data, id + 1);
          });
        }
      }

      if (event.data.zones) {
        for (let i = 0; i < event.data.zones.length; i++) {
          event.data.zones[i].forEach((data, id) => {
            if (!data.hide) totalVisible++;
            createOptions("zones", data, id + 1, i + 1);
          });
        }
      }

      // Affiche le message si l'œil est actif mais rien n'est visible
      if (totalVisible === 0) {
        noOptions.textContent = event.data.noOptionsLabel || "No interactions available";
        noOptions.style.display = "block";
      }
    }
  }
});