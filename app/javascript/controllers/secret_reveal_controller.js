import { Controller } from "@hotwired/stimulus";

export default class SecretRevealController extends Controller {
  static targets = ["input", "icon"];
  static classes = ["hidden"];

  connect() {
    this.hidden = (this.inputTarget.type === "password");
  }

  toggle(event) {
    this.hidden = !this.hidden;
    this.inputTarget.type = this.hidden ? "password" : "text";
    this.iconTargets.forEach(icon => icon.classList.toggle(this.hiddenClass));
  }

  get hidden() {
    return this.data.get("hidden") === "true";
  }

  set hidden(value) {
    this.data.set("hidden", value.toString());
  }
}
