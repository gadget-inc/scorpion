import React from "react";

import { Badge, BadgeProps } from "@shopify/polaris";

export const IssueSeverityBadge = (_props: { issue: {} }) => {
  let status: BadgeProps["status"], text;

  switch (1) {
    case 1: {
      status = "warning";
      text = "Severe";
    }
  }

  return <Badge status={status}>{text}</Badge>;
};
