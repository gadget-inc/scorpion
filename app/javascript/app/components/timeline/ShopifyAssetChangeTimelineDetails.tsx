import React from "react";
import gql from "graphql-tag";
import { ShopifyAssetChangeTimelineDetailsFragment } from "app/app-graph";
import { groupBy } from "lodash";

gql`
  fragment ShopifyAssetChangeTimelineDetails on ShopifyAssetChangeFeedSubject {
    id
    key
    action
    theme {
      id
      name
    }
  }
`;

export const ShopifyAssetChangeTimelineDetails = (events: ShopifyAssetChangeTimelineDetailsFragment[]) => {
  const themeGroups = groupBy(events, "theme.id");
  return Object.entries(themeGroups).map(([themeId, themeEvents]) => (
    <p key={themeId}>
      {themeEvents.length} asset(s) changed on {themeEvents[0].theme.name}:{" "}
      {themeEvents.map((event) => (
        <span key={event.id}>
          {event.action} {event.key}
        </span>
      ))}
    </p>
  ));
};
