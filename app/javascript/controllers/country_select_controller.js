import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

export default class CountrySelectController extends Controller {
  static values = {url: String}

  connect() {
    this.element.addEventListener("change", this.updateStates.bind(this));
  }

  updateStates(event) {
    let params = new URLSearchParams();
    params.append("country_code", event.target.value);

    get(this.urlValue, {
      query: params,
      responseKind: "turbo-stream"
    })
  }
}
