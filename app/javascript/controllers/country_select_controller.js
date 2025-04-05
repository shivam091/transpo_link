import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";

export default class CountrySelectController extends Controller {
  static targets = ["countrySelect", "stateSelect"];
  static values = {url: String};

  updateStates() {
    if (!this.hasCountrySelectTarget || !this.hasStateSelectTarget) return;

    const params = new URLSearchParams({
      country_code: this.countrySelectTarget.value,
      target: this.stateSelectTarget.id
    });

    get(this.urlValue, {
      query: params,
      responseKind: "turbo-stream"
    }).catch((error) => console.error("Failed to fetch states:", error));
  }
}
