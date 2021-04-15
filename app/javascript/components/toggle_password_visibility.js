var input = $("[data-behavior='toggle-password-visibility'] input");
var icon = $("[data-behavior='toggle-password-visibility'] i");

$("[data-behavior='toggle-password-visibility'] a").on("click", function (e) {
  return (
    e.preventDefault(),
    "text" === input.attr("type")
      ? (input.attr("type", "password"),
        icon.addClass("fa-eye-slash"),
        icon.removeClass("fa-eye"))
      : "password" === input.attr("type")
      ? (input.attr("type", "text"),
        icon.removeClass("fa-eye-slash"),
        icon.addClass("fa-eye"))
      : void 0
  );
});
