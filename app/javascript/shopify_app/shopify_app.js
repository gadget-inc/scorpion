document.addEventListener("DOMContentLoaded", () => {
  const data = document.getElementById("shopify-app-init").dataset;
  const AppBridge = window["app-bridge"];
  const createApp = AppBridge.default;
  window.app = createApp({
    apiKey: data.apiKey,
    shopOrigin: data.shopOrigin
  });

  const actions = AppBridge.actions;
  const TitleBar = actions.TitleBar;
  TitleBar.create(app, {
    title: data.page
  });
});
