import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.cleanupBackdrop();

    this.modal = bootstrap.Modal.getOrCreateInstance(this.element, {
      focus: true,
      keyboard: false,
      backdrop: "static"
    });
    this.show();
  }

  disconnect() {
    this.hide();
  }

  hideBeforeRender(event) {
    if (this.isOpen()) {
      event.preventDefault();
      this.element.addEventListener("hidden.bs.modal", event.detail.resume, {once: true});
      this.hide();
    }
  }

  show() {
    this.modal.show();
  }

  hide() {
    this.modal.hide();
    this.remoteModalTurboFrameTarget.src = null;
  }

  isOpen() {
    return this.element.classList.contains("show");
  }

  get remoteModalTurboFrameTarget() {
    return document.querySelector("turbo-frame#remote_modal");
  }

  cleanupBackdrop() {
    document.querySelectorAll(".modal-backdrop").forEach(backdrop => backdrop.remove());
  }
}
