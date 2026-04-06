// app/javascript/controllers/image_converter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "status", "preview"]
  static values = { modelName: String }

  async convert(event) {
    const files = event.target.files
    if (!files || files.length === 0) return

    const form = this.element.closest('form')
    const submitBtn = form.querySelector('input[type="submit"]')

    submitBtn.disabled = true
    submitBtn.value = "UPLOADING..."
    this.statusTarget.style.display = "block"
    this.statusTarget.textContent = "画像アップロード中..."
    this.previewTarget.innerHTML = "" 

    try {
      for (let file of files) {
        // HEIC変換
        if (file.type === "image/heic" || file.name.toLowerCase().endsWith(".heic")) {
          if (window.heic2any) {
            const blob = await window.heic2any({ blob: file, toType: "image/jpeg", quality: 0.7 })
            file = new File([blob], file.name.replace(/\.[^/.]+$/, ".jpg"), { type: "image/jpeg" })
          }
        }

        // Cloudinaryアップロード
        const formData = new FormData()
        formData.append("file", file)
        formData.append("upload_preset", "growth_note_preset")

        const response = await fetch("https://api.cloudinary.com/v1_1/dl1ukak2p/image/upload", {
          method: "POST",
          body: formData
        })

        const data = await response.json()

        if (data.secure_url) {
          const input = document.createElement("input")
          input.type = "hidden"
          
          input.name = "image_urls[]" 
  input.value = data.secure_url
  
  form.appendChild(input)
  this.addPreview(data.secure_url)
}
      } // forループ終了

      this.statusTarget.textContent = "完了！準備OK"
      submitBtn.disabled = false
      submitBtn.value = "SUBMIT RECORD"

    } catch (error) {
      console.error(error)
      this.statusTarget.textContent = "エラーが発生しました"
      submitBtn.disabled = false
      submitBtn.value = "SUBMIT RECORD"
    }
  }

  addPreview(url) {
    const img = document.createElement("img")
    img.src = url
    img.style.width = "60px"
    img.style.margin = "5px"
    img.style.border = "1px solid #eee"
    this.previewTarget.appendChild(img)
  }
}