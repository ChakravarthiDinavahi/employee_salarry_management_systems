import { Controller } from "@hotwired/stimulus"

// Debounced GET to the turbo frame (server-side search, Pagy-compatible).
export default class extends Controller {
  static values = { delay: { type: Number, default: 400 } }

  connect() {
    this.timeout = null
  }

  schedule() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.delayValue)
  }
}
