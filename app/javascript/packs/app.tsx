import "@shopify/polaris/styles.css";
import "../superlib/polyfills";
import * as React from "react";
import * as ReactDOM from "react-dom";
import { SettingsContext, Settings } from "../app/lib/settings";
import { App } from "../app/App";

ReactDOM.render(
  <SettingsContext.Provider value={Settings}>
    <App />
  </SettingsContext.Provider>,
  document.body.appendChild(document.createElement("main"))
);
