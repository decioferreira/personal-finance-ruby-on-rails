import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js/auto"

// Renders the category-spending pie chart on the dashboard.
// The backend supplies category names and totals (categoryTotalsValue);
// this controller only turns them into pixels, it never computes them.
export default class extends Controller {
  static targets = [ "canvas" ]
  static values = { categoryTotals: Array }

  connect() {
    new Chart(this.canvasTarget, {
      type: "pie",
      data: {
        labels: this.categoryTotalsValue.map((row) => row.category),
        datasets: [ {
          data: this.categoryTotalsValue.map((row) => parseFloat(row.amount)),
        } ],
      },
      options: {
        plugins: {
          legend: { position: "bottom" },
        },
      },
    })
  }
}
