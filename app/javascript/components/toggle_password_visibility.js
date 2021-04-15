$(".show_hide_password a").on("click", function (e) {
  return (
    e.preventDefault(),
    "text" === $(".show_hide_password input").attr("type")
      ? ($(".show_hide_password input").attr("type", "password"),
        $(".show_hide_password i").addClass("fa-eye-slash"),
        $(".show_hide_password i").removeClass("fa-eye"))
      : "password" === $(".show_hide_password input").attr("type")
      ? ($(".show_hide_password input").attr("type", "text"),
        $(".show_hide_password i").removeClass("fa-eye-slash"),
        $(".show_hide_password i").addClass("fa-eye"))
      : void 0
  );
});
