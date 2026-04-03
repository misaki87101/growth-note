import { Controller } from "@hotwired/stimulus"
// ↓ これを追加！
import { Turbo } from "@hotwired/turbo" 

export default class extends Controller {
  connect() {
    console.log("Feedback form controller connected!")
  }

  updateStudents(event) {
    const groupId = event.target.value
    console.log("Selected Group ID:", groupId) // 動作確認用のログ
    
    if (!groupId) return

    fetch(`/feedbacks/select_group?group_id=${groupId}`, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        // ↓ これを追加！Railsのセキュリティチェックを通すために必要です
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.text())
    .then(html => {
      // ログを出して中身が届いているか確認
      console.log("Turbo Stream received") 
      Turbo.renderStreamMessage(html)
    })
  }
}