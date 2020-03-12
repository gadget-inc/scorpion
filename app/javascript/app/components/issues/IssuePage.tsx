import React from "react";
import { Page } from "../common";
import { Card, DisplayText, Stack, Badge, BadgeProps, TextContainer, Layout, DescriptionList } from "@shopify/polaris";
import gql from "graphql-tag";
import { GetIssueForIssuePageComponent } from "app/app-graph";

gql`
  query GetIssueForIssuePage($number: Int!) {
    issue(number: $number) {
      id
      name
      number
      key
      keyCategory
      openedAt
      lastSeenAt
      closedAt
    }
  }
`;

const IssueSeverityBadge = (_props: { issue: {} }) => {
  let status: BadgeProps["status"], text;

  switch (1) {
    case 1: {
      status = "warning";
      text = "Severe";
    }
  }

  return <Badge status={status}>{text}</Badge>;
};

export default class IssuePage extends Page<{ number: string }> {
  render() {
    return (
      <Page.Load component={GetIssueForIssuePageComponent} variables={{ number: parseInt(this.props.match.params.number, 10) }}>
        {data => (
          <Page.Layout title={data.issue.name} breadcrumbs={[{ content: "Issues" }]}>
            <Layout.Section>
              <Stack alignment="center">
                <DisplayText>{data.issue.name}</DisplayText>
                <IssueSeverityBadge issue={data.issue} />
              </Stack>
            </Layout.Section>
            <Layout.Section>
              <Card title="Issue details" sectioned>
                <p>View a summary of the issue.</p>
              </Card>
            </Layout.Section>
            <Layout.Section secondary>
              <Card title="Details" sectioned>
                <DescriptionList
                  items={[
                    {
                      term: "First seen",
                      description: data.issue.openedAt
                    },
                    {
                      term: "Last seen",
                      description: data.issue.lastSeenAt
                    }
                  ]}
                />
              </Card>
            </Layout.Section>
          </Page.Layout>
        )}
      </Page.Load>
    );
  }
}
