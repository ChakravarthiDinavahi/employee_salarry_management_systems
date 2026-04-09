import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { address: String }

  copy() {
    navigator.clipboard.writeText(this.addressValue).then(() => {
      const prev = this.element.textContent
      this.element.textContent = "Copied!"
      setTimeout(() => {
        this.element.textContent = prev
      }, 1600)
    })
  }
}
