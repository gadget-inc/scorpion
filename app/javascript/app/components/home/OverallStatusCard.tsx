import React from "react";
import { Card, Icon, IconProps, TextContainer, Heading, Stack } from "@shopify/polaris";
import { CircleTickMajorTwotone, CircleAlertMajorTwotone, CircleDisabledMajorTwotone } from "@shopify/polaris-icons";
import gql from "graphql-tag";

gql`
  fragment GetOverallStatus on AppQuery {
    currentProperty {
      id
      name
    }
  }
`;

export const OverallStatusCard = (props: { status: string }) => {
  let color: IconProps["color"];
  let icon: IconProps["source"];
  let title: string;

  switch (props.status) {
    case "success":
      color = "greenDark";
      icon = CircleTickMajorTwotone;
      title = "No major issues detected";
      break;
    case "warning":
      color = "yellowDark";
      icon = CircleAlertMajorTwotone;
      title = "Minor issues detected";
      break;
    case "critical":
      color = "redDark";
      icon = CircleDisabledMajorTwotone;
      title = "Major issues detected";
      break;
    default:
      throw new Error(`unknown status ${props.status}`);
  }

  return (
    <Card sectioned secondaryFooterActions={[{ content: "Report undetected issue" }]}>
      <Stack alignment="center">
        <Icon source={icon} color={color} backdrop />
        <TextContainer spacing="tight">
          <Heading>{title}</Heading>
          <p>Scanned less than 2 hours ago</p>
        </TextContainer>
      </Stack>
    </Card>
  );
};
