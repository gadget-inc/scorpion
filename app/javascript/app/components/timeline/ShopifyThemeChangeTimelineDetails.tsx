import React from "react";
import gql from "graphql-tag";
import { ShopifyThemeChangeTimelineDetailsFragment } from "app/app-graph";
import { isUndefined } from "lodash";

gql`
  fragment ShopifyThemeChangeTimelineDetails on ShopifyThemeChangeFeedSubject {
    id
    recordAttribute
    oldValue
    newValue
    theme {
      name
    }
  }
`;

export const ShopifyThemeChangeTimelineDetails = (events: ShopifyThemeChangeTimelineDetailsFragment[]) => {
  return events.map(event => (
    <p key={event.id}>
      Theme {event.theme.name} {event.recordAttribute} {isUndefined(event.newValue) && "unset"}
      {!isUndefined(event.newValue) && (
        <>
          changed from {event.oldValue} to {event.newValue}
        </>
      )}
    </p>
  ));
};
