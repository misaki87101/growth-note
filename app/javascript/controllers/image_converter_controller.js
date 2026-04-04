import { Controller } from "@hotwired/stimulus"
import heic2any from "heic2any"

export default class extends Controller {
  // inputフィールドでファイルが選ばれたら発動！
  async convert(event) {
    const files = event.target.files
    if (!files.length) return

    const dataTransfer = new DataTransfer()
    console.log("画像変換チェック開始...")

    for (let i = 0; i < files.length; i++) {
      let file = files[i]

      // HEICを検知
      if (file.type === "image/heic" || file.name.toLowerCase().endsWith(".heic")) {
        try {
          console.log(`${file.name} を変換中...`)
          const convertedBlob = await heic2any({
            blob: file,
            toType: "image/jpeg",
            quality: 0.7 // 少し圧縮してCloudinaryへの転送を軽くします
          })
          
          file = new File([convertedBlob], file.name.replace(/\.heic$/i, ".jpg"), {
            type: "image/jpeg"
          })
        } catch (error) {
          console.error("変換失敗:", error)
        }
      }
      dataTransfer.items.add(file)
    }

    // inputの中身を「全部JPG」にすり替える
    event.target.files = dataTransfer.files
    console.log("変換プロセス終了！")
  }
}