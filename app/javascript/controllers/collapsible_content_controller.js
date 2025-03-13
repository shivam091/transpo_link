import { Controller } from "@hotwired/stimulus";

export default class CollapsibleContentController extends Controller {
  static targets = ["collapsedContent", "expandedContent"];
  static values = {
    showMoreText: String,
    showLessText: String
  };

  connect() {
    this.open = false;
    this.originalContent = this.collapsedContentTarget.innerHTML;
  }

  toggle(event) {
    (this.open === false) ? this.show(event) : this.hide(event);
  }

  show(event) {
    this.open = true;

    event.target.innerHTML = this.showLessTextValue;
    this.collapsedContentTarget.innerHTML = this.expandedContentTarget.innerHTML;
  }

  hide(event) {
    this.open = false;

    event.target.innerHTML = this.showMoreTextValue;
    this.collapsedContentTarget.innerHTML = this.originalContent;
  }
}
