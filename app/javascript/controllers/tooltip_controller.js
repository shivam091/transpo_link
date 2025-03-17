import { Controller } from "@hotwired/stimulus";

export default class TooltipController extends Controller {

  connect() {
    new bootstrap.Tooltip(this.element, {
      html: true,
      trigger: "hover"
    });
  }
}
