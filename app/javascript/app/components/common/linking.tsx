import urlJoin from "url-join";
import { Settings } from "app/lib/settings";

export const shopifyAdminLink = (path: string) => urlJoin(Settings.shopify.shopOrigin, "/admin", path);

export const actionText = (action: string) => {
  switch (action) {
    case "open": {
      return "opened";
    }
    case "close": {
      return "closed";
    }
    case "update": {
      return "updated";
    }
    default: {
      return action;
    }
  }
};
