import { Controller } from "@hotwired/stimulus";

export default class CheckboxSelectionController extends Controller {
  static targets = ["selectAll", "itemCheckbox", "selectedCount"];

  connect() {
    if (this.hasSelectAllTarget) {
      this.selectAllTarget.addEventListener("change", this.toggle.bind(this));
    }
    this.itemCheckboxTargets.forEach(checkbox => checkbox.addEventListener("change", this.refresh.bind(this)));
    this.refresh();
  }

  disconnect() {
    if (this.hasSelectAllTarget) {
      this.selectAllTarget.removeEventListener("change", this.toggle.bind(this));
    }
    this.itemCheckboxTargets.forEach(checkbox => checkbox.removeEventListener("change", this.refresh.bind(this)));
  }

  toggle(event) {
    this.itemCheckboxTargets.forEach(checkbox => {
      checkbox.checked = event.target.checked;
      checkbox.dispatchEvent(new Event("input", {bubbles: false, cancelable: true}));
    });
    this.refresh();
  }

  refresh() {
    const checkedCount = this.checked.length;
    const totalCount = this.itemCheckboxTargets.length;

    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = checkedCount === totalCount;
      this.selectAllTarget.indeterminate = checkedCount > 0 && checkedCount < totalCount;
    }

    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = this.selectedCountText(checkedCount);
    }
  }

  selectedCountText(count) {
    return this.selectedCountTarget.dataset.labelTemplate.replace("%{count}", count);
  }

  get checked() {
    return this.itemCheckboxTargets.filter(checkbox => checkbox.checked);
  }
}
