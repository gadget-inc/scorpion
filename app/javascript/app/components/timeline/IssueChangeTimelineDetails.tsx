import React from "react";
import gql from "graphql-tag";
import { groupBy } from "lodash";
import { IssueChangeTimelineDetailsFragment } from "app/app-graph";

gql`
  fragment IssueChangeTimelineDetails on IssueChangeEvent {
    id
    action
    issue {
      name
      key
      keyCategory
      descriptor {
        title
        severity
      }
    }
  }
`;

export const IssueChangeTimelineDetails = (issueChangeEvents: IssueChangeTimelineDetailsFragment[]) => {
  const items: React.ReactNode[] = [];

  if (issueChangeEvents.length > 0) {
    if (issueChangeEvents.length == 1) {
      items.push(
        <p>
          {issueChangeEvents[0].issue.name} - {issueChangeEvents[0].issue.descriptor.title}: {issueChangeEvents[0].action}
        </p>
      );
    } else {
      Object.entries(groupBy(issueChangeEvents, "action")).forEach(([action, issues]) => {
        items.push(
          <p>
            {issues.length} issues {action}: {}
          </p>
        );
      });
    }
  }

  return items;
};
