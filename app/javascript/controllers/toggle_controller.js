import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["icon", "hideable"]

  call(event) {
    event.preventDefault()

    this.hideableTargets.forEach((el) => {
      el.classList.toggle("d-none")
    })

    this.iconTargets.forEach((icon) => {
      icon.classList.toggle("d-none")
    })
  }
}
