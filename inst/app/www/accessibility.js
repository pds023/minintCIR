document.addEventListener("DOMContentLoaded", function () {
  const filters = document.querySelector('[aria-controls="filters_sidebar"]');
  if (filters) {
    filters.title = "Afficher ou masquer les filtres";
    filters.setAttribute("aria-label", filters.title);
    const label = document.createElement("span");
    label.className = "filter-toggle-label";
    label.textContent = "Filtres";
    filters.append(label);
  }
  const navigation = document.querySelector(".navbar-toggler");
  if (navigation) navigation.setAttribute("aria-label", "Ouvrir ou fermer la navigation");
  document.querySelectorAll(".bslib-full-screen-enter").forEach(function (button) {
    button.title = "Agrandir le graphique ou le tableau";
    button.setAttribute("aria-label", button.title);
  });
});
