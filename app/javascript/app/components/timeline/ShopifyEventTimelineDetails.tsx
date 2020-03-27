import React from "react";
import gql from "graphql-tag";
import { ShopifyEventTimelineDetailsFragment } from "app/app-graph";
import { Link } from "@shopify/polaris";

gql`
  fragment ShopifyEventTimelineDetails on ShopifyEventFeedSubject {
    id
    description
    path
  }
`;

export const ShopifyEventTimelineDetails = (events: ShopifyEventTimelineDetailsFragment[]) => {
  return events.map(event => (
    <p key={event.id}>
      {event.description}&nbsp;
      {event.path && (
        <Link url={event.path} external>
          View
        </Link>
      )}
    </p>
  ));
};
