import React from "react";
import gql from "graphql-tag";
import { Page } from "../common";
import { GetCurrentUserForSettingsComponent } from "app/app-graph";
import { TextContainer } from "@shopify/polaris";

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
        {(data) => <TextContainer>{data.currentUser.fullName}</TextContainer>}
      </Page.Load>
    </Page.Layout>
  );
};
