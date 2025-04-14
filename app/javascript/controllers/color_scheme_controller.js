import { Controller } from "@hotwired/stimulus"
import { patch } from "@rails/request.js"

export default class ColorSchemeController extends Controller {
  static targets = ["colorSchemeItem", "colorSchemeIcon"];
  static values = {url: String, currentColorScheme: {type: String, default: "auto"}};

  connect() {
    this.updateUI(this.currentColorSchemeValue);
  }

  async switch(event) {
    event.preventDefault();

    const selectedElement = event.currentTarget;
    const selectedColorScheme = selectedElement.dataset.colorScheme;

    const response = await patch(this.urlValue, {
      body: JSON.stringify({color_scheme: selectedColorScheme}),
      contentType: "application/json",
      responseKind: "json"
    });

    if (response.ok) {
      const {preferred_color_scheme, icon} = await response.json();
      this.updateUI(preferred_color_scheme, icon);
    } else {
      console.warn("Failed to update color scheme");
    }
  }

  updateUI(colorScheme, iconName = null) {
    const theme = colorScheme === "auto" ? this.matchSystemColorScheme() : colorScheme;
    document.body.dataset.bsTheme = theme;

    this.colorSchemeItemTargets.forEach((el) => {
      el.classList.toggle("dropdown-item-checked", el.dataset.colorScheme === colorScheme);
    });

    const use = this.colorSchemeIconTarget?.querySelector("use");

    if (use && iconName) {
      use.setAttribute("href", `#${iconName}`);
    }
  }

  matchSystemColorScheme() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }
}
