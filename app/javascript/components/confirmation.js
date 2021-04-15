import Rails from "@rails/ujs";

// Cache a copy of the old Rails.confirm since we'll override it when the modal opens
const old_confirm = Rails.confirm;

// Elements we want to listen to for data-confirm
const elements = [
  "a[data-confirm]",
  "button[data-confirm]",
  "input[type=submit][data-confirm]",
];

const createConfirmModal = (element) => {
  const id = "confirm-modal-" + String(Math.random()).slice(2, -1);
  const confirm = element.dataset.confirm;
  const message = element.dataset.message;
  const commit = element.dataset.commit || "Je confirme";
  const cancel = element.dataset.cancel || "Annuler";

  const content = `
    <div class="modal fade"
          data-controller="modal"
          data-modal-open="true" id="${id}"
          tabindex="-1"
          role="dialog"
          aria-labelledby="confirmationModdal"
          aria-hidden="true" >
      <div class="modal-dialog modal-dialog-centered modal-md mobile-bottom" role="document">
        <div class="modal-content p-3">
          <div class="modal-body">
            <h5>${confirm}</h5>
            <p class="text-muted mt-3">${message ? message : ""}</p>
          </div>
          <div class="d-flex justify-content-end">
            <button data-behavior="cancel"
                    type="button"
                    class="btn btn-black mr-3"
                    data-dismiss="modal">
                      ${cancel}
            </button>
            <button data-behavior="commit"
                    type="button"
                    class="btn btn-danger"
                    data-dismiss="modal">
                    ${commit}
            </button>
          </div>
        </div>
      </div>
    </div>
  `;
  document.body.insertAdjacentHTML("afterend", content);

  const modal = document.getElementById(id);
  $(`#${id}`).modal().show();
  element.dataset.confirmModal = `#${id}`;

  const closeModal = () => {
    $(`#${id}`).modal().hide();
  };

  $(`#${id}`).on("hidden.bs.modal", (e) => {
    element.removeAttribute("data-confirm-modal");
  });

  document.addEventListener("keyup", (event) => {
    if (event.key === "Escape") {
      event.preventDefault();
      closeModal();
    }
  });

  modal
    .querySelector("[data-behavior='cancel']")
    .addEventListener("click", (event) => {
      event.preventDefault();
      closeModal();
    });

  modal
    .querySelector("[data-behavior='commit']")
    .addEventListener("click", (event) => {
      event.preventDefault();

      // Allow the confirm to go through
      Rails.confirm = () => {
        return true;
      };

      // Click the link again
      element.click();

      // Restore the confirm behavior
      Rails.confirm = old_confirm;

      closeModal();
    });

  modal.querySelector("[data-behavior='commit']").focus();
  return modal;
};

// Checks if confirm modal is open
const confirmModalOpen = (element) => {
  return !!element.dataset.confirmModal;
};

const handleConfirm = (event) => {
  // If there is a modal open, let the second confirm click through
  if (confirmModalOpen(event.target)) {
    return true;

    // First click, we need to spawn the modal
  } else {
    createConfirmModal(event.target);
    return false;
  }
};

// When a Rails confirm event fires, we'll handle it
Rails.delegate(document, elements.join(", "), "confirm", handleConfirm);
