import React from "react";
import { Page } from "../common";
import { Card, DisplayText, ResourceList, ResourceItem, TextStyle, Tabs } from "@shopify/polaris";
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

function TabsExample() {
  const [selected, setSelected] = React.useState(0);

  const handleTabChange = React.useCallback(selectedTabIndex => setSelected(selectedTabIndex), []);

  const tabs = [
    {
      id: "all-customers",
      content: "All",
      accessibilityLabel: "All customers",
      panelID: "all-customers-content"
    },
    {
      id: "accepts-marketing",
      content: "Accepts marketing",
      panelID: "accepts-marketing-content"
    },
    {
      id: "repeat-customers",
      content: "Repeat customers",
      panelID: "repeat-customers-content"
    },
    {
      id: "prospects",
      content: "Prospects",
      panelID: "prospects-content"
    }
  ];

  return (
    <Card>
      <Tabs tabs={tabs} selected={selected} onSelect={handleTabChange}>
        <Card.Section title={tabs[selected].content}>
          <p>Tab {selected} selected</p>
        </Card.Section>
      </Tabs>
    </Card>
  );
}

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
                <Card sectioned>
                  <ResourceList
                    resourceName={{ singular: "issue", plural: "issues" }}
                    items={data.currentProperty.issues.nodes}
                    renderItem={(issue: ArrayElementType<typeof data.currentProperty.issues.nodes>) => {
                      const url = `/issues/${issue.number}`;

                      return (
                        <ResourceItem
                          id={issue.id}
                          onClick={() => {
                            this.props.history.push(url);
                          }}
                          accessibilityLabel={`View details for ${issue.name}`}
                        >
                          <h3>
                            <TextStyle variation="strong">{issue.name}</TextStyle>
                          </h3>
                        </ResourceItem>
                      );
                    }}
                  />
                </Card>
                <TabsExample />
              </Page.Layout.Section>
            </>
          )}
        </Page.Load>
      </Page.Layout>
    );
  }
}
