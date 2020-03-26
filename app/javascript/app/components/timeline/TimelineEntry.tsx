import React from "react";
import { TextContainer, Heading } from "@shopify/polaris";
import gql from "graphql-tag";
import styles from "./Timeline.module.scss";
import { TimelineEntryDetailsFragment } from "app/app-graph";
import { ScanTimelineEntryCard } from "./ScanTimelineEntryCard";

gql`
  fragment TimelineEntryDetails on FeedItem {
    id
    itemAt
    subjects {
      __typename
      ... on ProductionGroup {
        ...ScanTimelineEntryDetails
      }
      ... on IssueChangeEvent {
        id
      }
      ... on ShopifyEventFeedSubject {
        id
        verb
      }
      ... on ShopifyAssetChangeFeedSubject {
        id
      }
      ... on ShopifyShopChangeFeedSubject {
        id
      }
      ... on ShopifyThemeChangeFeedSubject {
        id
      }
    }
  }
`;

export const TimelineEntry = (props: { feedItem: TimelineEntryDetailsFragment }) => {
  let content;
  if (props.feedItem.subjects[0] && props.feedItem.subjects[0].__typename == "ProductionGroup") {
    content = <ScanTimelineEntryCard productionGroup={props.feedItem.subjects[0]} />;
  } else {
    content = (
      <TextContainer>
        <Heading element="h3">Event - {props.feedItem.subjects.map(subject => subject.__typename)}</Heading>
      </TextContainer>
    );
  }

  return <li className={styles.TimelineEntry}>{content}</li>;
};
