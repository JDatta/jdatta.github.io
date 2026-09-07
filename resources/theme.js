(function () {
  var storageKey = "jdatta-main-theme";
  var root = document.documentElement;
  var mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");

  function savedTheme() {
    try {
      return localStorage.getItem(storageKey);
    } catch (error) {
      return null;
    }
  }

  function applyTheme(theme) {
    root.dataset.theme = theme;
    root.style.colorScheme = theme;
  }

  function preferredTheme() {
    return mediaQuery.matches ? "dark" : "light";
  }

  applyTheme(savedTheme() || preferredTheme());
  root.classList.add("js");

  window.addEventListener("DOMContentLoaded", function () {
    var toggle = document.querySelector(".theme-toggle");
    if (!toggle) return;

    function updateToggle() {
      var nextTheme = root.dataset.theme === "dark" ? "light" : "dark";
      var label = "Switch to " + nextTheme + " mode";
      toggle.setAttribute("aria-label", label);
      toggle.title = label;
    }

    toggle.addEventListener("click", function () {
      var nextTheme = root.dataset.theme === "dark" ? "light" : "dark";
      applyTheme(nextTheme);
      try {
        localStorage.setItem(storageKey, nextTheme);
      } catch (error) {
        // The new selection remains active for this page when storage is unavailable.
      }
      updateToggle();
    });

    updateToggle();
  });

  mediaQuery.addEventListener("change", function (event) {
    if (!savedTheme()) {
      applyTheme(event.matches ? "dark" : "light");
      var toggle = document.querySelector(".theme-toggle");
      if (toggle) {
        var nextTheme = root.dataset.theme === "dark" ? "light" : "dark";
        var label = "Switch to " + nextTheme + " mode";
        toggle.setAttribute("aria-label", label);
        toggle.title = label;
      }
    }
  });
}());
