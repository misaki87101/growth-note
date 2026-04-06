// javascript/controllers/image_converter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "status", "preview"]
  uploadedUrls = []

  async convert(event) {
    const files = event.target.files
    if (!files || files.length === 0) return

    const form = this.inputTarget.form
    const submitBtn = form.querySelector('input[type="submit"]')

    submitBtn.disabled = true
    submitBtn.value = "UPLOADING..."
    this.statusTarget.style.display = "block"
    this.statusTarget.textContent = "画像アップロード中..."
    this.uploadedUrls = [] 

    try {
      for (let file of files) {
        if (file.type === "image/heic" || file.name.toLowerCase().endsWith(".heic")) {
          if (window.heic2any) {
            const blob = await window.heic2any({ blob: file, toType: "image/jpeg", quality: 0.7 })
            file = new File([blob], file.name.replace(/\.[^/.]+$/, ".jpg"), { type: "image/jpeg" })
          }
        }

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
          input.name = "homework[image_urls][]"
          input.value = data.secure_url
          form.appendChild(input)

          console.log("✅ フォームにURLを注入完了！")
          this.addPreview(data.secure_url)
        }
      } // 🔥 ここ！この閉じカッコが抜けていました

      this.statusTarget.textContent = `完了！${document.querySelectorAll('input[name="homework[image_urls][]"]').length}枚準備OK`
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