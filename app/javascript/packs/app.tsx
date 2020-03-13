import "@shopify/polaris/styles.css";
import "../app/components/common/global_style.scss";
import "../superlib/polyfills";
import * as React from "react";
import * as ReactDOM from "react-dom";
import { SettingsContext, Settings } from "../app/lib/settings";
import { App } from "../app/App";

const main = document.createElement("main");
main.id = "ScorpionMain";
document.body.appendChild(main);

ReactDOM.render(
  <SettingsContext.Provider value={Settings}>
    <App />
  </SettingsContext.Provider>,
  main
);
