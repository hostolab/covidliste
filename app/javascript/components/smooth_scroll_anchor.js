const smoothScrollAnchor = () => {
  const links = document.querySelectorAll(
    "a[data-behavior='smooth-scroll-anchor']"
  );

  for (const link of links) {
    link.addEventListener("click", clickHandler);
  }

  function clickHandler(e) {
    e.preventDefault();
    const href = this.getAttribute("href");
    const offsetTop = document.querySelector(href).offsetTop;

    scroll({
      top: offsetTop,
      behavior: "smooth",
    });
  }
};

export { smoothScrollAnchor };
