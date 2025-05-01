import { Controller } from "@hotwired/stimulus";

export default class SpriteSwitchController extends Controller {
  static targets = ["icon"];
  static values = {expand: String, collapse: String};

  toggle() {
    const useElement = this.iconTarget.querySelector("use");
    const currentHref = useElement.getAttribute("href");

    const isExpanded = currentHref === this.expandValue;
    const nextHref = isExpanded ? this.collapseValue : this.expandValue;

    useElement.setAttribute("href", nextHref);
  }
}
