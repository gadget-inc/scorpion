const eventName = typeof Turbolinks !== "undefined" ? "turbolinks:load" : "DOMContentLoaded";

if (!document.documentElement.hasAttribute("data-turbolinks-preview")) {
  document.addEventListener(eventName, function flash() {
    const flashData = JSON.parse(document.getElementById("shopify-app-flash").dataset.flash);

    const Toast = window["app-bridge"].actions.Toast;

    if (flashData.notice) {
      Toast.create(app, {
        message: flashData.notice,
        duration: 5000
      }).dispatch(Toast.Action.SHOW);
    }

    if (flashData.error) {
      Toast.create(app, {
        message: flashData.error,
        duration: 5000,
        isError: true
      }).dispatch(Toast.Action.SHOW);
    }

    document.removeEventListener(eventName, flash);
  });
}
