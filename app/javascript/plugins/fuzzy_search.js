import Fuse from "fuse.js/dist/fuse.basic.esm";

const engine = document.getElementById("fuzzy-search");

if (engine) {
  let source = engine.getAttribute("data-fuzzy-search-source");
  let domInput = document.querySelector(
    engine.getAttribute("data-fuzzy-search-input")
  );
  let domNoResults = document.querySelector(
    engine.getAttribute("data-fuzzy-search-none")
  );
  let domItems = document.querySelectorAll(
    engine.getAttribute("data-fuzzy-search-item")
  );
  let domItemTitleSelector = engine.getAttribute(
    "data-fuzzy-search-item-title"
  );

  if (!domInput) {
    console.error("Aucun champ texte de recherche de trouvé");
  } else if (!domItems) {
    console.error("Aucun jeu de donnée pre-existant");
  } else {
    const trustScoreFactor = 0.45;
    const fuseOptions = {
      isCaseSensitive: false,
      includeScore: true,
      shouldSort: true,
      includeMatches: false,
      findAllMatches: false,
      minMatchCharLength: 3,
      threshold: trustScoreFactor,
      useExtendedSearch: false,
      ignoreLocation: true,
      ignoreFieldNorm: false,
      keys: ["category", "title", "body_md_erb"],
    };

    fetch(source)
      .then((response) => response.json())
      .then((dataset) => {
        const fuse = new Fuse(dataset, fuseOptions);
        let domItemsCount = domItems.length;
        domInput.addEventListener(
          "keyup",
          function (e) {
            const searchTerm = this.value;
            if (searchTerm.length < 3) {
              engine.classList.remove("search-done");
              domNoResults.classList.add("d-none");
              for (var i = 0; i < domItemsCount; i++)
                domItems[i].classList.remove("d-none");
            } else {
              engine.classList.add("search-done");
              const matches = fuse.search(searchTerm);
              console.clear();
              console.table(matches);
              const matchesFiltered = matches.filter(
                (match) => match.score <= trustScoreFactor
              );
              const matchesTitles = matchesFiltered.map((r) => r.item["title"]);
              if (matchesTitles.length > 0) {
                domNoResults.classList.add("d-none");
                for (var i = 0; i < domItemsCount; i++) {
                  const domItemTitle = domItems[i]
                    .querySelector(domItemTitleSelector)
                    .textContent.replace(/^\s+|\s+$/g, "");
                  if (
                    searchTerm.length == 0 ||
                    matchesTitles.indexOf(domItemTitle) >= 0
                  ) {
                    domItems[i].classList.remove("d-none");
                    domItems[i].style.order = matchesTitles.indexOf(
                      domItemTitle
                    );
                  } else {
                    domItems[i].classList.add("d-none");
                    domItems[i].style.order = "inherit";
                  }
                }
              } else {
                domNoResults.classList.remove("d-none");
                for (var i = 0; i < domItemsCount; i++) {
                  domItems[i].classList.add("d-none");
                }
              }
            }
          },
          false
        );
      })
      .catch(console.error);
  }
}
