import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "status", "preview"]
  static values = { modelName: String } // 'board' や 'homework' を受け取る

  async convert(event) {
    const files = event.target.files
    if (!files || files.length === 0) return

    const form = this.element.closest('form')
    // 修正1: buttonタグにも対応
    const submitBtn = form.querySelector('input[type="submit"], button[type="submit"]')

    if (submitBtn) {
      submitBtn.disabled = true
      submitBtn.innerText = "UPLOADING..." // button用
      if (submitBtn.tagName === "INPUT") submitBtn.value = "UPLOADING..." // input用
    }

    this.statusTarget.style.display = "block"
    this.statusTarget.textContent = "画像アップロード中..."
    
    // 修正2: 再選択時に古いhidden要素とプレビューを消去
    form.querySelectorAll(`.added-image-url`).forEach(el => el.remove())
    this.previewTarget.innerHTML = "" 

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
          input.classList.add("added-image-url")
          
          // 修正3: モデル名に基づいて名前を決定 (例: homework[image_urls][])
          const namePrefix = this.hasModelNameValue ? `${this.modelNameValue}[image_urls][]` : "image_urls[]"
          input.name = namePrefix
          input.value = data.secure_url
          
          form.appendChild(input)
          this.addPreview(data.secure_url)
        }
      }

      this.statusTarget.textContent = "完了！準備OK"
      if (submitBtn) {
        submitBtn.disabled = false
        submitBtn.innerText = "SUBMIT RECORD"
        if (submitBtn.tagName === "INPUT") submitBtn.value = "SUBMIT RECORD"
      }

    } catch (error) {
      console.error(error)
      this.statusTarget.textContent = "エラーが発生しました"
      if (submitBtn) {
        submitBtn.disabled = false
      }
    }
  }

  addPreview(url) {
    const img = document.createElement("img")
    img.src = url
    img.style.width = "60px"
    img.style.height = "60px"
    img.style.objectFit = "cover"
    img.style.margin = "5px"
    img.style.border = "1px solid #eee"
    img.style.borderRadius = "4px"
    this.previewTarget.appendChild(img)
  }
}