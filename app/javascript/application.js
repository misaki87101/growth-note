import "@hotwired/turbo-rails"
import "./controllers"

document.addEventListener("turbo:load", () => {
  const forms = document.querySelectorAll("form");
  
  forms.forEach((form) => {
    form.addEventListener("submit", (e) => {
      console.log("フォーム送信開始！");
      
      const fileInput = form.querySelector('input[type="file"]');
      if (fileInput && fileInput.files.length > 0) {
        console.log("画像が選択されています:", fileInput.files.length, "枚");
        // 一旦、変換処理をスルーしてそのまま送信させてみる
        // もしこれで動くなら、変換JSの中身に問題があります
      }
    });
  });
});