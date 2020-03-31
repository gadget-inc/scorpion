import React from "react";
import { Page } from "../common";
import { Card, Layout, ResourceList, ResourceItem, TextStyle, Link } from "@shopify/polaris";
import gql from "graphql-tag";
import { IssueTypeEnum, useGetIssuesForIssuesIndexQuery, IssuesIndexIssueFragment } from "app/app-graph";
import { IssueSeverityBadge } from "./IssueSeverityBadge";
import { DateTime } from "luxon";
import { useHistory } from "react-router";
import { ConnectionPaginator, ResourceListPaginationContainer, useConnectionPagination } from "../common/ConnectionPaginator";

gql`
  fragment IssuesIndexIssue on Issue {
    id
    nameWithTitle
    number
    key
    keyCategory
    openedAt
    lastSeenAt
    closedAt
    descriptor {
      title
      description
    }
    subjectType
    subjectId
  }

  query GetIssuesForIssuesIndex($first: Int, $last: Int, $before: String, $after: String) {
    issues(first: $first, last: $last, before: $before, after: $after) {
      nodes {
        ...IssuesIndexIssue
      }
      pageInfo {
        endCursor
        startCursor
        hasPreviousPage
        hasNextPage
      }
    }
  }
`;

export default (props: {}) => {
  const history = useHistory();
  const paginationConfig = useConnectionPagination();
  const { data, loading, fetchMore } = useGetIssuesForIssuesIndexQuery({ variables: paginationConfig.variables });

  return (
    <Page.Layout title="Issues">
      <Layout.Section>
        <Card>
          <ResourceList
            resourceName={{ singular: "customer", plural: "customers" }}
            items={data?.issues.nodes || []}
            renderItem={(issue: IssuesIndexIssueFragment) => {
              const url = `/issues/${issue.number}`;
              return (
                <ResourceItem
                  id={issue.id}
                  onClick={() => {
                    history.push(url);
                  }}
                  accessibilityLabel={`View details for ${issue.nameWithTitle}`}
                >
                  <div style={{ display: "flex", flexDirection: "row" }}>
                    <h3 style={{ flexGrow: 0, flexShrink: 0, width: "4rem" }}>#{issue.number}</h3>
                    <div style={{ flexGrow: 1 }}>
                      <h3>
                        <TextStyle variation="strong">
                          {issue.descriptor.title} <IssueSeverityBadge issue={issue} />
                        </TextStyle>
                      </h3>
                      {issue.subjectType == IssueTypeEnum.Url && issue.subjectId && (
                        <p>
                          <TextStyle variation="subdued">
                            Found on{" "}
                            <Link url={issue.subjectId} external>
                              {issue.subjectId}
                            </Link>
                          </TextStyle>
                        </p>
                      )}
                      {issue.subjectType == IssueTypeEnum.ShopifyProduct && issue.subjectId && (
                        <p>
                          <TextStyle variation="subdued">
                            Found on{" "}
                            <Link url={`/products/${issue.subjectId}`} external>
                              Product ID #{issue.subjectId}
                            </Link>
                          </TextStyle>
                        </p>
                      )}
                    </div>
                    <div>
                      <p>
                        <TextStyle variation="subdued">
                          Last seen at: {DateTime.fromISO(issue.lastSeenAt).toLocaleString(DateTime.DATETIME_MED)}
                        </TextStyle>
                      </p>
                    </div>
                  </div>
                </ResourceItem>
              );
            }}
          />
          {data && (
            <ResourceListPaginationContainer>
              <ConnectionPaginator paginationConfig={paginationConfig} pageInfo={data.issues.pageInfo} />
            </ResourceListPaginationContainer>
          )}
        </Card>
      </Layout.Section>
    </Page.Layout>
  );
};
