import { Controller } from "@hotwired/stimulus";

export default class NestedFormsController extends Controller {
  static targets = ["target", "template"];
  static values = {wrapperSelector: {type: String, default: ".nested-form-wrapper"}};

  addAssociation(event) {
    const timestamp = Date.now().toString();
    this.targetTarget.insertAdjacentHTML(
      "beforebegin",
      this.templateTarget.innerHTML.replace(/NEW_RECORD/g, timestamp)
    );
  }

  removeAssociation(event) {
    const wrapper = event.target.closest(this.wrapperSelectorValue);

    if (!wrapper) return;

    // If it's a new record, we remove it entirely
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove();
    } else {
      // If it's an existing record, hide it and mark it for destruction
      wrapper.hidden = true;
      const destroyInput = wrapper.querySelector("input[name*='_destroy']");
      if (destroyInput) destroyInput.value = "1";
    }
  }
}
