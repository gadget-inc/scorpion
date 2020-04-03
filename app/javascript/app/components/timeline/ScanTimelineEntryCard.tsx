import React from "react";
import { Card, TextContainer, Button, Icon, Stack } from "@shopify/polaris";
import { QuestionMarkMajorTwotone } from "@shopify/polaris-icons";
import gql from "graphql-tag";
import { ScanTimelineEntryDetailsFragment } from "app/app-graph";

gql`
  fragment ScanTimelineEntryDetails on ProductionGroup {
    id
    reason
    startedAt
    changedIssueCount
    issueChangeEvents(first: 3) {
      nodes {
        id
        action
        issue {
          number
          nameWithTitle
        }
      }
    }
  }
`;

export const ScanTimelineEntryCard = (props: { productionGroup: ScanTimelineEntryDetailsFragment }) => {
  const hiddenIssueCount = props.productionGroup.changedIssueCount - props.productionGroup.issueChangeEvents.nodes.length;
  return (
    <Card
      sectioned
      title={
        <Stack>
          <Icon color="subdued" source={QuestionMarkMajorTwotone} />
          <span>Scan run</span>
        </Stack>
      }
    >
      <TextContainer>
        <p>{props.productionGroup.changedIssueCount} issue(s) changed</p>
      </TextContainer>
      <ul>
        {props.productionGroup.issueChangeEvents.nodes.map((changeEvent) => (
          <li key={changeEvent.id}>
            {changeEvent.issue.nameWithTitle} {changeEvent.action}
          </li>
        ))}
      </ul>
      {hiddenIssueCount > 0 && <Button plain>and {String(hiddenIssueCount)} more...</Button>}
    </Card>
  );
};
