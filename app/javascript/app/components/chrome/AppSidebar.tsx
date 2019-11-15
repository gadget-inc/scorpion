import React from "react";
import styled from "styled-components";
import { ResponsiveContext, Layer, Box, Button, Text, DropButton, Heading } from "grommet";
import { FormClose, Menu, Launch } from "grommet-icons";
import { withRouter, RouteComponentProps } from "react-router-dom";
import gql from "graphql-tag";
import { SiderInfoComponent } from "../../app-graph";
import { UserAvatar } from "../common/UserAvatar";
import { signOut } from "../../lib/auth";
import { Settings } from "../../lib/settings";
import { Invite, Settings as SettingsIcon } from "../common/ScorpionIcons";
import { NavigationSectionButton, NavigationSubItemButton } from "./Navigation";
import { Alert } from "superlib";

gql`
  query SiderInfo {
    currentUser {
      email
      fullName
      authAreaUrl
      ...UserCard
      accounts {
        id
      }
    }
    currentAccount {
      name
    }
  }
`;

interface AppSidebarState {
  openForSmall: boolean;
}

export const StyledAppSidebarContainer = styled(Box)`
  @media print {
    display: none;
  }
`;

export const AppSidebar = withRouter(
  class InnerSidebar extends React.Component<RouteComponentProps & { embeddedInPageHeader: boolean }, AppSidebarState> {
    static contextType = ResponsiveContext;
    state: AppSidebarState = { openForSmall: false };

    close = () => {
      this.setState({ openForSmall: false });
    };

    renderLogo() {
      return (
        <Box flex={false}>
          <Heading level="2">Scorpion</Heading>
        </Box>
      );
    }
    renderMenu() {
      return (
        <SiderInfoComponent>
          {({ loading, error, data }) => {
            if (error) {
              console.error(error);
              return <Alert type="error" message="There was an error loading data for Scorpion. Please refresh to try again" />;
            }

            if (!data) {
              return null;
            }

            return (
              <>
                <Box pad="small" align="center" flex={false}>
                  {this.renderLogo()}
                </Box>
                {Settings.devMode && (
                  <Box background="accent-2" align="center" flex={false}>
                    <Text size="xsmall" color="white">
                      DEV ENV
                    </Text>
                  </Box>
                )}
                <Box background="accent-2" align="center" flex={false}>
                  <Text size="xsmall" color="white">
                    ALPHA
                  </Text>
                </Box>
                {data.currentUser && data.currentUser.accounts.length > 0 && (
                  <Box background="accent-4" align="center" flex={false}>
                    <Text size="xsmall" color="white">
                      {data.currentAccount.name}
                    </Text>
                  </Box>
                )}
                <Box flex="grow" overflow={{ vertical: "auto" }}>
                  <NavigationSectionButton path="/launchpad" text="Launchpad" icon={<Launch />} onClick={this.close} />
                  <Box flex />
                  <NavigationSectionButton path="/invite" text="Invite Users" icon={<Invite />} onClick={this.close} />
                  <NavigationSectionButton path="/settings" text="Settings" icon={<SettingsIcon />} onClick={this.close}>
                    <NavigationSubItemButton path="/settings/account" exact text="Account" onClick={this.close} />
                    <NavigationSubItemButton path="/settings/users" exact text="Users" onClick={this.close} />
                  </NavigationSectionButton>
                </Box>
                {!loading && (
                  <Box pad="small" align="center" flex={false}>
                    <DropButton
                      hoverIndicator="light-4"
                      dropAlign={{ bottom: "top" }}
                      dropContent={
                        <Box pad="small" background="white" gap="small" width="small">
                          <Button onClick={() => (window.location.href = data.currentUser.authAreaUrl)}>Switch Accounts</Button>
                          <Button onClick={signOut}>Sign Out</Button>
                        </Box>
                      }
                    >
                      <UserAvatar user={data.currentUser} size={48} />
                    </DropButton>
                  </Box>
                )}
              </>
            );
          }}
        </SiderInfoComponent>
      );
    }

    render() {
      const size = this.context;

      if (size === "small") {
        if (!this.props.embeddedInPageHeader) {
          return null;
        }

        return (
          <>
            <StyledAppSidebarContainer>
              <Button
                icon={<Menu />}
                onClick={() => {
                  this.setState({ openForSmall: true });
                }}
              />
            </StyledAppSidebarContainer>
            {this.state.openForSmall && (
              <Layer full={true}>
                <Button icon={<FormClose />} onClick={this.close} style={{ position: "fixed", top: 0, right: 0 }} />
                {this.renderMenu()}
              </Layer>
            )}
          </>
        );
      } else {
        if (this.props.embeddedInPageHeader) {
          return null;
        }

        return (
          <StyledAppSidebarContainer
            fill="vertical"
            width="small"
            flex={false}
            background={Settings.devMode ? "accent-2" : "light-2"}
            className="AppSidebar-container"
          >
            {this.renderMenu()}
          </StyledAppSidebarContainer>
        );
      }
    }
  }
);
