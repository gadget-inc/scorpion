import React from "react";
import { Page } from "../common";
import { Card, DisplayText } from "@shopify/polaris";
import gql from "graphql-tag";
import { GetIssuesForHomePageComponent } from "app/app-graph";
import { OverallStatusCard } from "./OverallStatusCard";
import { Timeline } from "../timeline/Timeline";

gql`
  query GetIssuesForHomePage {
    currentProperty {
      issues {
        nodes {
          id
          name
          number
          key
          keyCategory
          openedAt
          closedAt
        }
      }
    }
  }
`;

export default class HomePage extends Page {
  render() {
    return (
      <Page.Layout title="Home">
        <Page.Load component={GetIssuesForHomePageComponent} require={["currentProperty"]}>
          {data => (
            <>
              <Page.Layout.Section>
                <DisplayText>Good day.</DisplayText>
              </Page.Layout.Section>
              <Page.Layout.Section>
                <OverallStatusCard status="success" />

                <Timeline />
              </Page.Layout.Section>
              <Page.Layout.Section secondary>
                <Card sectioned></Card>
              </Page.Layout.Section>
            </>
          )}
        </Page.Load>
      </Page.Layout>
    );
  }
}
