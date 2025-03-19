import { Controller } from "@hotwired/stimulus";
import moment from "moment-timezone";

export default class LiveClockController extends Controller {
  static targets = ["date", "time"];
  static values = {userTimeZone: String};

  connect() {
    this.updateClock();
    this.startClock();
  }

  startClock() {
    const tick = () => {
      this.updateClock();
      setTimeout(() => requestAnimationFrame(tick), 1000);
    };
    tick();
  }

  updateClock() {
    const now = moment().tz(this.userTimeZoneValue);
    this.dateTarget.textContent = now.format("ddd, MMMM D, YYYY");
    this.timeTarget.textContent = now.format("HH:mm:ss");
  }
}
