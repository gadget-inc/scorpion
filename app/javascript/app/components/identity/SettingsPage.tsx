import React from "react";
import gql from "graphql-tag";
import { Page } from "../common";
import { GetCurrentUserForSettingsComponent } from "app/app-graph";
import { TextContainer, DisplayText } from "@shopify/polaris";

gql`
  query GetCurrentUserForSettings {
    currentUser {
      id
      fullName
      email
    }
  }
`;

export default (_props: {}) => {
  return (
    <Page.Layout title="Users Settings">
      <Page.Load component={GetCurrentUserForSettingsComponent} require={["currentUser"]}>
        {(data) => (
          <>
            <Page.Layout.Section>
              <DisplayText>Settings</DisplayText>
            </Page.Layout.Section>
            <Page.Layout.Section>
              <TextContainer>Currently logged in as {data.currentUser.fullName}</TextContainer>
            </Page.Layout.Section>
          </>
        )}
      </Page.Load>
    </Page.Layout>
  );
};
