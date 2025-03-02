import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["target", "template"];
  static values = { wrapperSelector: String };

  addAssociation(event) {
    event.preventDefault();
    const timestamp = Date.now().toString();
    this.targetTarget.insertAdjacentHTML(
      "beforebegin",
      this.templateTarget.innerHTML.replace(/NEW_RECORD/g, timestamp)
    );
  }

  removeAssociation(event) {
    event.preventDefault();
    const wrapper = event.target.closest(this.wrapperSelectorValue || ".nested-form-wrapper");

    if (!wrapper) return;

    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove();
    } else {
      wrapper.hidden = true;
      const destroyInput = wrapper.querySelector("input[name*='_destroy']");
      if (destroyInput) destroyInput.value = "1";
    }
  }
}
