import React from "react";
import { Card, Icon, IconProps, TextContainer, Heading, Stack } from "@shopify/polaris";
import { CircleTickMajorTwotone, CircleAlertMajorTwotone, CircleDisabledMajorTwotone } from "@shopify/polaris-icons";
import gql from "graphql-tag";
import { SimpleQuery, Link } from "superlib";
import { GetOverallStatusComponent } from "app/app-graph";

gql`
  query GetOverallStatus {
    currentProperty {
      id
      name
      assessmentSummary {
        id
        openIssueCount
        openUrgentIssueCount
        openWarningIssueCount
        currentStatus
        mostUrgentIssues {
          id
          number
          nameWithTitle
          descriptor {
            severity
          }
        }
      }
    }
  }
`;

export const OverallStatusCard = (_props: {}) => {
  return (
    <SimpleQuery component={GetOverallStatusComponent} require={["currentProperty"]}>
      {(data) => {
        let color: IconProps["color"];
        let icon: IconProps["source"];
        let title: string;
        const status = data.currentProperty.assessmentSummary.currentStatus;

        switch (status) {
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
            throw new Error(`unknown status ${status}`);
        }

        return (
          <Card secondaryFooterActions={[{ content: "Report undetected issue" }]}>
            <Card.Section>
              <Stack alignment="center">
                <Icon source={icon} color={color} backdrop />
                <TextContainer spacing="tight">
                  <Heading>{title}</Heading>
                  <p>Scanned less than 2 hours ago</p>
                </TextContainer>
              </Stack>
            </Card.Section>
            <Card.Section>
              <TextContainer>
                <p>Most important issues:</p>
                <ul>
                  {data.currentProperty.assessmentSummary.mostUrgentIssues.map((issue) => (
                    <li key={issue.id}>
                      <Link url={`/issues/${issue.number}`}>{issue.nameWithTitle}</Link>
                    </li>
                  ))}
                </ul>
                <Link url={`/issues`}>See all...</Link>
              </TextContainer>
            </Card.Section>
          </Card>
        );
      }}
    </SimpleQuery>
  );
};
