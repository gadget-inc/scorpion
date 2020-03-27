import React from "react";
import { Card, Icon, Stack } from "@shopify/polaris";
import { QuestionMarkMajorTwotone } from "@shopify/polaris-icons";
import gql from "graphql-tag";
import { AppChangeTimelineEntryDetailsFragment } from "app/app-graph";

gql`
  fragment AppChangeTimelineEntryDetails on ShopifyDetectedAppChangeFeedSubject {
    id
    action
    actionAt
    key
    detectedApp {
      name
      reasons
    }
  }
`;

export const AppChangeTimelineEntryCard = (props: { appChangeEvent: AppChangeTimelineEntryDetailsFragment }) => {
  return (
    <Card
      sectioned
      title={
        <Stack>
          <Icon color="subdued" source={QuestionMarkMajorTwotone} />
          <span>
            App {props.appChangeEvent.action} - {props.appChangeEvent.detectedApp.name}
          </span>
        </Stack>
      }
    ></Card>
  );
};
