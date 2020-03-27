import React from "react";
import gql from "graphql-tag";
import styles from "./Timeline.module.scss";
import {
  TimelineEntryDetailsFragment,
  IssueChangeTimelineDetailsFragment,
  ShopifyAssetChangeTimelineDetailsFragment,
  ShopifyShopChangeTimelineDetailsFragment,
  ShopifyThemeChangeTimelineDetailsFragment,
  ShopifyEventTimelineDetailsFragment
} from "app/app-graph";
import { ScanTimelineEntryCard } from "./ScanTimelineEntryCard";
import { AppChangeTimelineEntryCard } from "./AppChangeTimelineEntryCard";
import { groupBy } from "lodash";
import { IssueChangeTimelineDetails } from "./IssueChangeTimelineDetails";
import { ShopifyAssetChangeTimelineDetails } from "./ShopifyAssetChangeTimelineDetails";
import { ShopifyShopChangeTimelineDetails } from "./ShopifyShopChangeTimelineDetails";
import { ShopifyThemeChangeTimelineDetails } from "./ShopifyThemeChangeTimelineDetails";
import { ShopifyEventTimelineDetails } from "./ShopifyEventTimelineDetails";

gql`
  fragment TimelineEntryDetails on FeedItem {
    id
    itemAt
    subjects {
      __typename
      ... on ProductionGroup {
        ...ScanTimelineEntryDetails
      }
      ... on ShopifyDetectedAppChangeFeedSubject {
        ...AppChangeTimelineEntryDetails
      }
      ... on IssueChangeEvent {
        ...IssueChangeTimelineDetails
      }
      ... on ShopifyEventFeedSubject {
        ...ShopifyEventTimelineDetails
      }
      ... on ShopifyAssetChangeFeedSubject {
        ...ShopifyAssetChangeTimelineDetails
      }
      ... on ShopifyShopChangeFeedSubject {
        ...ShopifyShopChangeTimelineDetails
      }
      ... on ShopifyThemeChangeFeedSubject {
        ...ShopifyThemeChangeTimelineDetails
      }
    }
  }
`;

export const TimelineEntry = (props: { feedItem: TimelineEntryDetailsFragment }) => {
  let content;
  const firstSubject = props.feedItem.subjects[0];
  if (firstSubject && firstSubject.__typename == "ProductionGroup") {
    content = <ScanTimelineEntryCard productionGroup={firstSubject} />;
  } else if (firstSubject && firstSubject.__typename == "ShopifyDetectedAppChangeFeedSubject") {
    content = <AppChangeTimelineEntryCard appChangeEvent={firstSubject} />;
  } else {
    const items: React.ReactNode[] = [];
    const groups = groupBy(props.feedItem.subjects, "__typename");

    Object.entries(groups).forEach(([typename, group]) => {
      switch (typename) {
        case "IssueChangeEvent": {
          items.push(...IssueChangeTimelineDetails(group as IssueChangeTimelineDetailsFragment[]));
          break;
        }
        case "ShopifyEventFeedSubject": {
          items.push(...ShopifyEventTimelineDetails(group as ShopifyEventTimelineDetailsFragment[]));
          break;
        }
        case "ShopifyAssetChangeFeedSubject": {
          items.push(...ShopifyAssetChangeTimelineDetails(group as ShopifyAssetChangeTimelineDetailsFragment[]));
          break;
        }
        case "ShopifyShopChangeFeedSubject": {
          items.push(...ShopifyShopChangeTimelineDetails(group as ShopifyShopChangeTimelineDetailsFragment[]));
          break;
        }
        case "ShopifyThemeChangeFeedSubject": {
          items.push(...ShopifyThemeChangeTimelineDetails(group as ShopifyThemeChangeTimelineDetailsFragment[]));
          break;
        }
        default: {
          throw `Unknown or invalid timeline entry type ${typename}`;
        }
      }
    });

    content = (
      <ul>
        {items.map((item, index) => (
          <li key={index}>{item}</li>
        ))}
      </ul>
    );
  }

  return <li className={styles.TimelineEntry}>{content}</li>;
};
