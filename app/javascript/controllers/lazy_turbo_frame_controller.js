import { Controller } from "@hotwired/stimulus"

export default class LazyTurboFrameController extends Controller {
  static targets = ["icon"];
  static classes = ["hidden"];

  toggle(event) {
    event.preventDefault();

    const button = event.currentTarget;
    const href = button.getAttribute("href");
    const turboFrame = document.getElementById(button.dataset.turboFrame);
    const iconsInButton = this.iconTargets.filter(icon => button.contains(icon));

    if (!turboFrame || !href) return;

    // If turboFrame hasn't loaded yet, lazy load it and show after load
    if (turboFrame.innerHTML.trim() === "") {
      turboFrame.addEventListener("turbo:frame-load", () => {
        turboFrame.classList.remove(this.hiddenClass)
        this.toggleIcons(iconsInButton);
      }, {once: true})

      turboFrame.setAttribute("src", href)
    } else {
      // Already loaded: just toggle visibility and icons
      turboFrame.classList.toggle(this.hiddenClass)
      this.toggleIcons(iconsInButton)
    }
  }

  toggleIcons(icons) {
    icons.forEach(icon => icon.classList.toggle(this.hiddenClass));
  }
}
