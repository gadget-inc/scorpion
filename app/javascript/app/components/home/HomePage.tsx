import React from "react";
import { Page } from "../common";
import { Card, DisplayText, ResourceList, ResourceItem, TextStyle } from "@shopify/polaris";
import gql from "graphql-tag";
import { GetIssuesForHomePageComponent } from "app/app-graph";
import { ArrayElementType } from "app/lib/types";

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
      <Page.Layout title="Home" primaryAction={{ content: "Scan now" }}>
        <Page.Load component={GetIssuesForHomePageComponent} require={["currentProperty"]}>
          {data => (
            <>
              <Page.Layout.Section>
                <DisplayText>Good day.</DisplayText>
              </Page.Layout.Section>
              <Page.Layout.Section>
                <Card sectioned>
                  <ResourceList
                    resourceName={{ singular: "issue", plural: "issues" }}
                    items={data.currentProperty.issues.nodes}
                    renderItem={(issue: ArrayElementType<typeof data.currentProperty.issues.nodes>) => {
                      return (
                        <ResourceItem id={issue.id} url={`/issues/${issue.number}`} accessibilityLabel={`View details for ${issue.name}`}>
                          <h3>
                            <TextStyle variation="strong">{issue.name}</TextStyle>
                          </h3>
                        </ResourceItem>
                      );
                    }}
                  />
                </Card>
              </Page.Layout.Section>
            </>
          )}
        </Page.Load>
      </Page.Layout>
    );
  }
}
