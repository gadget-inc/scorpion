import React from "react";
import enTranslations from "@shopify/polaris/locales/en.json";
import { AppProvider } from "@shopify/polaris";
import { AppConfig } from "@shopify/app-bridge";
import { Provider, RoutePropagator } from "@shopify/app-bridge-react";
import { ApolloProvider } from "@apollo/react-components";
import { ApolloProvider as ApolloHooksProvider } from "@apollo/react-hooks";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import { getClient } from "./lib/apollo";
import { SentryErrorBoundary, SegmentIdentify, HotkeysContainer } from "../superlib";
import { Settings } from "./lib/settings";
import { FlagsProvider } from "../superlib";
import { NotFoundPage } from "./components/chrome/NotFoundPage";
import { PageLoadSpin } from "../superlib";
import { NavigationBar } from "./components/chrome/NavigationBar/NavigationBar";

const HomePage = React.lazy(() => import("./components/home/HomePage"));
const Launchpad = React.lazy(() => import("./components/home/Launchpad"));
const SettingsPage = React.lazy(() => import("./components/identity/SettingsPage"));
const IssuePage = React.lazy(() => import("./components/issues/IssuePage"));
const IssuesIndexPage = React.lazy(() => import("./components/issues/IssuesIndexPage"));

export const ScorpionClient = getClient();

const AppBridgeConfig: AppConfig = {
  apiKey: Settings.shopify.apiKey,
  shopOrigin: Settings.shopify.shopOrigin,
  forceRedirect: false,
};

export const App = () => {
  const app = (
    <SegmentIdentify>
      <FlagsProvider flags={Settings.flags}>
        <ApolloProvider client={ScorpionClient}>
          <ApolloHooksProvider client={ScorpionClient}>
            <Provider config={AppBridgeConfig}>
              <AppProvider i18n={enTranslations}>
                <Router basename={Settings.baseUrl}>
                  <NavigationBar />
                  <Route>{({ location }) => <RoutePropagator location={location} />}</Route>
                  <HotkeysContainer>
                    <React.Suspense fallback={<PageLoadSpin />}>
                      <Switch>
                        <Route>
                          <Switch>
                            <Route path="/" exact component={HomePage} />
                            <Route path="/launchpad" exact component={Launchpad} />
                            <Route path="/settings" exact component={SettingsPage} />
                            <Route path="/issues" exact component={IssuesIndexPage} />
                            <Route path="/issues/:number" exact component={IssuePage} />
                            <Route component={NotFoundPage} />
                          </Switch>
                        </Route>
                      </Switch>
                    </React.Suspense>
                  </HotkeysContainer>
                </Router>
              </AppProvider>
            </Provider>
          </ApolloHooksProvider>
        </ApolloProvider>
      </FlagsProvider>
    </SegmentIdentify>
  );

  if (!Settings.devMode) {
    return <SentryErrorBoundary>{app}</SentryErrorBoundary>;
  } else {
    return app;
  }
};
