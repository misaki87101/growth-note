// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

document.addEventListener("turbo:load", () => {
  const forms = document.querySelectorAll("form");

  forms.forEach((form) => {
    form.addEventListener("submit", async (e) => {
      // 一旦、送信を止める
      const fileInputs = form.querySelectorAll('input[type="file"]');
      let needsConversion = false;

      // HEICが含まれているかチェック
      for (const input of fileInputs) {
        for (const file of input.files) {
          if (file.name.toLowerCase().endsWith(".heic") || file.name.toLowerCase().endsWith(".heif")) {
            needsConversion = true;
            break;
          }
        }
      }

      if (!needsConversion) return; // HEICがなければそのまま送信

      e.preventDefault(); // 送信を一時停止

      for (const input of fileInputs) {
        if (!input.files.length) continue;
        const dataTransfer = new DataTransfer();

        for (const file of input.files) {
          if (file.name.toLowerCase().endsWith(".heic") || file.name.toLowerCase().endsWith(".heif")) {
            try {
              const blob = await heic2any({
                blob: file,
                toType: "image/jpeg",
                quality: 0.6 // サーバー負荷軽減のため少し圧縮
              });
              const blobs = Array.isArray(blob) ? blob : [blob];
              blobs.forEach((b, index) => {
                const newFile = new File([b], file.name.replace(/\.[^/.]+$/, "") + `.jpg`, { type: "image/jpeg" });
                dataTransfer.items.add(newFile);
              });
            } catch (error) {
              dataTransfer.items.add(file);
            }
          } else {
            dataTransfer.items.add(file);
          }
        }
        input.files = dataTransfer.files;
      }
      
      // 変換が終わったので、イベントを削除してから再送
      form.submit();
    });
  });
});