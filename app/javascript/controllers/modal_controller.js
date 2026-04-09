import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close() {
    const frame = document.getElementById("employee_modal")
    if (frame) frame.innerHTML = ""
  }
}
