import React from "react";
import { Pagination } from "@shopify/polaris";
import { useQueryState } from "react-router-use-location-state";

export interface PaginationConfig {
  setBefore: (value: string) => void;
  setAfter: (value: string) => void;
  variables: { before?: string | null; after?: string | null; first?: number; last?: number };
}

export const useConnectionPagination = (pageSize = 20): PaginationConfig => {
  const [before, setBefore] = useQueryState("before", "");
  const [after, setAfter] = useQueryState("after", "");

  const forwards = before == "";

  return {
    setBefore,
    setAfter,
    variables: { before, after, first: forwards ? pageSize : undefined, last: !forwards ? pageSize : undefined },
  };
};

export const ConnectionPaginator = (props: {
  pageInfo: {
    hasPreviousPage: boolean;
    hasNextPage: boolean;
    startCursor?: string | null;
    endCursor?: string | null;
  };
  paginationConfig: PaginationConfig;
}) => (
  <Pagination
    hasNext={props.pageInfo.hasNextPage}
    onNext={() => {
      props.paginationConfig.setAfter(props.pageInfo.endCursor || "");
      props.paginationConfig.setBefore("");
    }}
    hasPrevious={props.pageInfo.hasPreviousPage}
    onPrevious={() => {
      props.paginationConfig.setBefore(props.pageInfo.startCursor || "");
      props.paginationConfig.setAfter("");
    }}
  />
);

export const ResourceListPaginationContainer = (props: { children: React.ReactNode }) => {
  return <div style={{ display: "flex", justifyContent: "center", paddingTop: "2rem", paddingBottom: "1rem" }}>{props.children}</div>;
};
