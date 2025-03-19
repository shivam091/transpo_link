import { Controller } from "@hotwired/stimulus";

export default class RangeSliderController extends Controller {
  static targets = ["rangeInput", "rangeThumb"];

  connect() {
    this.updateOutput();
    this.rangeInputTarget.addEventListener("input", this.updateOutput.bind(this));
  }

  updateOutput() {
    const input = this.rangeInputTarget;
    const thumb = this.rangeThumbTarget;

    if (!input || !thumb) return;

    const percent = ((input.value - input.min) / (input.max - input.min)) * 100;
    const sliderWidth = input.offsetWidth;
    const thumbWidth = thumb.offsetWidth;

    if (!sliderWidth || !thumbWidth) {
      requestAnimationFrame(() => this.updateOutput());
      return;
    }

    thumb.style.left = `${(percent / 100) * (sliderWidth - thumbWidth)}px`;
    thumb.textContent = input.value;
  }
}
