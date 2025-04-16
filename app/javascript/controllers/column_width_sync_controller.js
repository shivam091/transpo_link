import { Controller } from "@hotwired/stimulus";

export default class ColumnWidthSyncController extends Controller {
  connect() {
    this.syncColumnWidths = this.syncColumnWidths.bind(this);
    this.syncColumnWidths();
    window.addEventListener("resize", this.syncColumnWidths);
  }

  disconnect() {
    window.removeEventListener("resize", this.syncColumnWidths);
  }

  syncColumnWidths() {
    const headerCells = Array.from(this.element.querySelectorAll(".table-header .table-cell"));
    const bodyRows = Array.from(this.element.querySelectorAll(".table-body .table-row"));

    if (headerCells.length === 0 || bodyRows.length === 0) return;

    const columnCount = headerCells.length;
    const maxWidths = new Array(columnCount).fill(0);

    // Measure header cells
    headerCells.forEach((cell, i) => {
      maxWidths[i] = Math.max(maxWidths[i], cell.offsetWidth, cell.scrollWidth);
    });

    // Measure body cells
    bodyRows.forEach(row => {
      const cells = Array.from(row.querySelectorAll(".table-cell"));
      cells.forEach((cell, i) => {
        maxWidths[i] = Math.max(maxWidths[i], cell.offsetWidth, cell.scrollWidth);
      });
    });

    // Apply max widths to all header and body cells
    headerCells.forEach((cell, i) => this.setCellWidth(cell, maxWidths[i]));
    bodyRows.forEach(row => {
      const cells = Array.from(row.querySelectorAll(".table-cell"));
      cells.forEach((cell, i) => this.setCellWidth(cell, maxWidths[i]));
    });

    // Optionally set container min-width based on total
    const totalWidth = maxWidths.reduce((sum, w) => sum + w, 0);
    this.element.style.minWidth = `${totalWidth}px`;
  }

  setCellWidth(cell, width) {
    const px = `${width}px`;
    Object.assign(cell.style, {
      flex: `0 0 ${px}`,
      minWidth: px,
      maxWidth: px,
    });
  }
}
