import { Controller } from "@hotwired/stimulus";

export default class SpriteCycleController extends Controller {
  static targets = ["icon"];
  static values = {
    states: Array, // e.g., ["#icon-expand", "#icon-collapse"]
    index: Number
  };

  connect() {
    if (!this.hasIndexValue) this.indexValue = 0;
  }

  toggle() {
    this.indexValue = (this.indexValue + 1) % this.statesValue.length;

    const useElement = this.iconTarget.querySelector("use");
    const nextHref = this.statesValue[this.indexValue];

    useElement.setAttribute("href", nextHref);
  }
}
