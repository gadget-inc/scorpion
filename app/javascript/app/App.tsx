import React from "react";
import { ApolloProvider } from "@apollo/react-components";
import { ApolloProvider as ApolloHooksProvider } from "@apollo/react-hooks";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import { getClient } from "./lib/apollo";
import { ScorpionGrommetTheme, SentryErrorBoundary, ScorpionGlobalStyle, SegmentIdentify, HotkeysContainer, Flag } from "../superlib";
import { Grommet } from "grommet";
import { Settings } from "./lib/settings";
import { ToastContainer, FlagsProvider } from "../superlib";
import { AppSidebar } from "./components/chrome/AppSidebar";
import { NotFoundPage } from "./components/chrome/NotFoundPage";
import { PageLoadSpin } from "../superlib";
import styled from "styled-components";

const HomePage = React.lazy(() => import("./components/home/HomePage"));
const Launchpad = React.lazy(() => import("./components/home/Launchpad"));
const InviteUsersPage = React.lazy(() => import("./components/identity/InviteUsersPage"));
const UsersSettingsPage = React.lazy(() => import("./components/identity/UsersSettingsPage"));
const AccountSettingsPage = React.lazy(() => import("./components/identity/AccountSettingsPage"));

export const ScorpionClient = getClient();
export const StyledGrommetContainer = styled(Grommet)`
  width: 100vw;
  height: 100vh;
  overflow: hidden;

  @media print {
    height: auto;
    width: 100%;
    overflow: visible;
  }
`;

export const StyledScorpionLayout = styled.div`
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: row;

  @media print {
    height: auto;
    display: block;
  }
`;

export const App = () => {
  const app = (
    <SegmentIdentify>
      <FlagsProvider flags={Settings.flags}>
        <ApolloProvider client={ScorpionClient}>
          <ApolloHooksProvider client={ScorpionClient}>
            <StyledGrommetContainer theme={ScorpionGrommetTheme}>
              <ScorpionGlobalStyle />
              <Router basename={Settings.baseUrl}>
                <ToastContainer>
                  <HotkeysContainer>
                    <React.Suspense fallback={<PageLoadSpin />}>
                      <StyledScorpionLayout id="Scorpion-Layout">
                        <Switch>
                          <Route>
                            <Flag
                              name={["gate.productAccess"]}
                              fallbackRender={() => (
                                <Switch>
                                  <Route component={NotFoundPage} />
                                </Switch>
                              )}
                            >
                              <AppSidebar embeddedInPageHeader={false} />
                              <Switch>
                                <Route path="/" exact component={HomePage} />
                                <Route path="/launchpad" exact component={Launchpad} />
                                <Route path="/invite" exact component={InviteUsersPage} />
                                <Route path="/settings" exact component={AccountSettingsPage} />
                                <Route path="/settings/account" exact component={AccountSettingsPage} />
                                <Route path="/settings/users" exact component={UsersSettingsPage} />
                                <Route component={NotFoundPage} />
                              </Switch>
                            </Flag>
                          </Route>
                        </Switch>
                      </StyledScorpionLayout>
                    </React.Suspense>
                  </HotkeysContainer>
                </ToastContainer>
              </Router>
            </StyledGrommetContainer>
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
