import React from "react";
import gql from "graphql-tag";
import { ShopifyShopChangeTimelineDetailsFragment } from "app/app-graph";
import { isUndefined, isBoolean, isNull, isString } from "lodash";

gql`
  fragment ShopifyShopChangeTimelineDetails on ShopifyShopChangeFeedSubject {
    id
    recordAttribute
    oldValue
    newValue
  }
`;

const formatValue = (value: any) => {
  if (isBoolean(value) || isUndefined(value) || isNull(value)) {
    return value ? "set" : "unset";
  } else if (isString(value)) {
    return value;
  } else {
    return JSON.stringify(value);
  }
};

export const ShopifyShopChangeTimelineDetails = (events: ShopifyShopChangeTimelineDetailsFragment[]) => {
  return events.map(event => {
    let message: React.ReactNode;

    switch (event.recordAttribute) {
      case "has_storefront": {
        message = event.newValue ? "Shop online store was enabled" : "Shop online store was disabled";
        break;
      }
      case "password_enabled": {
        message = event.newValue ? "Shop online store password was enabled" : "Shop online store password was disabled";
        break;
      }
      case "setup_required": {
        message = event.newValue ? "Shop started requiring setup" : "Shop setup was completed";
        break;
      }
      case "multi_location_enabled": {
        message = event.newValue ? "Shop multi-location support was enabled" : "Shop multi-location support was disabled";
        break;
      }
      default: {
        message = (
          <>
            Shop {event.recordAttribute} {isUndefined(event.newValue) && "unset"}
            {!isUndefined(event.newValue) && (
              <>
                changed from {formatValue(event.oldValue)} to {formatValue(event.newValue)}
              </>
            )}
          </>
        );
      }
    }

    return <p key={event.id}>{message}</p>;
  });
};
