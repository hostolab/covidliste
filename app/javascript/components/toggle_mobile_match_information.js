const toggleMobileMatchInformation = () => {
  const matchInfo = document.getElementById("mobile-match-info");
  const matchIdentity = document.getElementById("mobile-match-identity");
  const interestedButton = document.getElementById("interested-button");
  const backButton = document.getElementById("mobile-match-back");

  if (matchInfo) {
    interestedButton.addEventListener("click", function (e) {
      matchInfo.classList.add("d-none");
      matchIdentity.classList.remove("d-none", "d-md-block");
      backButton.classList.remove("d-none");
    });
    backButton.addEventListener("click", function (e) {
      matchInfo.classList.remove("d-none");
      matchIdentity.classList.add("d-none", "d-md-block");
    });
  }
};

export { toggleMobileMatchInformation };
