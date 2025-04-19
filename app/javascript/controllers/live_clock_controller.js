import { Controller } from "@hotwired/stimulus";
import moment from "moment-timezone";
import { DATE_FORMATS, TIME_FORMATS } from "transpo_link/constants/date_time_formats";

export default class LiveClockController extends Controller {
  static targets = ["date", "time"];
  static values = {userTimeZone: String, dateFormat: String, timeFormat: String};

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
    const dateFormat = DATE_FORMATS[this.dateFormatValue] || "ddd, MMMM D, YYYY";
    const timeFormat = TIME_FORMATS[this.timeFormatValue] || "HH:mm:ss";

    this.dateTarget.textContent = now.format(dateFormat);
    this.timeTarget.textContent = now.format(timeFormat);
  }
}
