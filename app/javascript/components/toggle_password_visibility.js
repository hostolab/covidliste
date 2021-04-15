var input = document.querySelector(
  "[data-behavior='toggle-password-visibility'] input"
);
var icon = document.querySelector(
  "[data-behavior='toggle-password-visibility'] i"
);

document
  .querySelector("[data-behavior='toggle-password-visibility'] a")
  .addEventListener("click", function (e) {
    if (input.getAttribute("type") === "text") {
      input.setAttribute("type", "password");
      icon.classList.add("fa-eye-slash");
      icon.classList.remove("fa-eye");
    } else if (input.getAttribute("type") === "password") {
      input.setAttribute("type", "text");
      icon.classList.add("fa-eye");
      icon.classList.remove("fa-eye-slash");g
    }
    e.preventDefault();
  });
