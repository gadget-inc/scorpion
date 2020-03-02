import React from "react";
import { useLoads } from "react-loads";
import { Banner } from "@shopify/polaris";
import { PageLoadSpin } from "./Spin";

export const SimplePromise = <T extends any>(props: { callback: () => Promise<T>; children: (data: T) => React.ReactNode }) => {
  const { response, isRejected, isPending, isResolved } = useLoads(props.callback);

  return (
    <>
      {isPending && <PageLoadSpin />}
      {isRejected && (
        <Banner status="critical" title="Internal Error">
          <p>There was an error loading data. Please try again.</p>
        </Banner>
      )}
      {isResolved && response && props.children(response)}
    </>
  );
};
