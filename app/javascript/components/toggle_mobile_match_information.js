const toggleMobileMatchInformation = () => {
  const matchInfo = document.getElementById("mobile-match-info");
  const matchIdentity = document.getElementById("mobile-match-identity");
  const buttonInterested = document.getElementById("interested-button");

  if (matchInfo) {
    buttonInterested.addEventListener("click", function (e) {
      matchInfo.classList.add("d-none");
      matchIdentity.classList.remove("d-none", "d-sm-block");
    });
  }
};

export { toggleMobileMatchInformation };
