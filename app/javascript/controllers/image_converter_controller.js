import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "status", "preview"]
  static values = { modelName: String }

  async convert(event) {
    const files = event.target.files
    if (!files || files.length === 0) return

    // 💡 強化ポイント1: フォームの取得
    // Stimulusが付いている要素自体がformならそれを使う、そうでなければ中から探すか親を探す
    const form = this.element.tagName === 'FORM' ? this.element : (this.element.querySelector('form') || this.element.closest('form'))
    
    // 💡 強化ポイント2: ボタンの取得
    // this.element(コントローラーの範囲内)から探すことで、HTML構造の変化に強くする
    const submitBtn = this.element.querySelector('input[type="submit"], button[type="submit"]')

    // アップロード開始時のUI更新
    if (submitBtn) {
      submitBtn.disabled = true
      if (submitBtn.tagName === "INPUT") {
        submitBtn.value = "UPLOADING..."
      } else {
        submitBtn.innerText = "UPLOADING..."
      }
    }

    this.statusTarget.style.display = "block"
    this.statusTarget.textContent = "画像アップロード中..."
    
    // 既存のプレビューとhidden inputをクリア
    if (form) {
      form.querySelectorAll(`.added-image-url`).forEach(el => el.remove())
    }
    this.previewTarget.innerHTML = "" 

    try {
      for (let file of files) {
        // HEIC 変換ロジック
        if (file.type === "image/heic" || file.name.toLowerCase().endsWith(".heic")) {
          if (window.heic2any) {
            try {
              const blob = await window.heic2any({ blob: file, toType: "image/jpeg", quality: 0.7 })
              file = new File([blob], file.name.replace(/\.[^/.]+$/, ".jpg"), { type: "image/jpeg" })
            } catch (e) {
              console.error("HEIC conversion failed:", e)
            }
          }
        }

        // Cloudinary アップロード
        const formData = new FormData()
        formData.append("file", file)
        formData.append("upload_preset", "growth_note_preset")

        const response = await fetch("https://api.cloudinary.com/v1_1/dl1ukak2p/image/upload", {
          method: "POST",
          body: formData
        })

        const data = await response.json()

        if (data.secure_url && form) {
          const input = document.createElement("input")
          input.type = "hidden"
          input.classList.add("added-image-url")
          
          // モデル名に基づいたname属性の決定
          const namePrefix = this.hasModelNameValue ? `${this.modelNameValue}[image_urls][]` : "image_urls[]"
          input.name = namePrefix
          input.value = data.secure_url
          
          form.appendChild(input)
          this.addPreview(data.secure_url)
        }
      }

      // 成功時のUI復旧
      this.statusTarget.textContent = "完了！準備OK"
      if (submitBtn) {
        submitBtn.disabled = false
        // 編集か新規作成かに合わせてラベルを戻す
        const isEdit = form?.querySelector('input[name="_method"]')?.value === "patch"
        const finalLabel = isEdit ? "UPDATE RECORD" : "SUBMIT RECORD"
        
        if (submitBtn.tagName === "INPUT") {
          submitBtn.value = finalLabel
        } else {
          submitBtn.innerText = finalLabel
        }
      }

    } catch (error) {
      console.error("Upload error:", error)
      this.statusTarget.textContent = "エラーが発生しました"
      if (submitBtn) {
        submitBtn.disabled = false
        if (submitBtn.tagName === "INPUT") {
          submitBtn.value = "ERROR - TRY AGAIN"
        } else {
          submitBtn.innerText = "ERROR - TRY AGAIN"
        }
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