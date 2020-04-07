import React from "react";
import pluralize from "pluralize";
import gql from "graphql-tag";
import { ShopifyAssetChangeTimelineDetailsFragment } from "app/app-graph";
import { groupBy } from "lodash";
import { Link } from "@shopify/polaris";
import { shopifyAdminLink, actionText } from "../common";

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
  return Object.entries(themeGroups).map(([_, themeEvents]) => {
    const theme = themeEvents[0].theme;
    return (
      <p key={theme.id}>
        {themeEvents.length} {pluralize("theme file", themeEvents.length)} changed on{" "}
        <Link url={shopifyAdminLink(`/themes/${theme.id}`)}>{theme.name}</Link>:{" "}
        {themeEvents.map((event) => (
          <span key={event.id}>
            <Link url={shopifyAdminLink(`/themes/${theme.id}?key=${event.key}`)}>{event.key}</Link> {actionText(event.action)}
          </span>
        ))}
      </p>
    );
  });
};
