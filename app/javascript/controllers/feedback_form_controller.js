import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Connected!")
  }

  updateStudents(event) {
    const groupId = event.target.value
    if (!groupId) return

    fetch(`/feedbacks/select_group?group_id=${groupId}`, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.text())
    .then(html => {
      // 🚨 直接 window.Turbo を使う（import を使わない）
      if (window.Turbo) {
        window.Turbo.renderStreamMessage(html)
      } else {
        console.error("Turbo not found")
      }
    })
  }
}