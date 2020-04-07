import React from "react";
import { TextContainer, Heading } from "@shopify/polaris";
import gql from "graphql-tag";
import styles from "./Timeline.module.scss";
import { SimpleQuery } from "superlib";
import { GetActivityFeedForTimelineComponent } from "app/app-graph";
import { TimelineEntry } from "./TimelineEntry";

gql`
  query GetActivityFeedForTimeline {
    currentProperty {
      id
      activityFeedItems(first: 30) {
        nodes {
          ...TimelineEntryDetails
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  }
`;

// TODO: Pagination
export const Timeline = (_props: {}) => {
  return (
    <div className={styles.TimelineContainer}>
      <TextContainer>
        <Heading>Recent Activity</Heading>
      </TextContainer>

      <ul className={styles.Timeline}>
        <SimpleQuery component={GetActivityFeedForTimelineComponent} require={["currentProperty"]}>
          {(data) => data.currentProperty.activityFeedItems.nodes.map((node) => <TimelineEntry key={node.id} feedItem={node} />)}
        </SimpleQuery>
      </ul>
    </div>
  );
};
