// app/javascript/controllers/feedback_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  updateStudents(event) {
    const groupId = event.target.value
    if (!groupId) return

    // 💡 修正ポイント：URLを組み立てる際に location.origin を含めるか、相対パスを明示的に指定
    const url = new URL("/feedbacks/select_group", window.location.origin)
    url.searchParams.append("group_id", groupId)

    fetch(url, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => {
      if (!response.ok) throw new Error("Network response was not ok")
      return response.text()
    })
    .then(html => {
      if (window.Turbo) {
        window.Turbo.renderStreamMessage(html)
      } else {
        console.error("Turbo not found")
      }
    })
    .catch(error => console.error("Error:", error))
  }
}