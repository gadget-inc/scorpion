import { get, set, isUndefined, isNull, isFunction, isArray, toPath, cloneDeep, cloneDeepWith, isArrayLike, mean } from "lodash";
import memoizeOne from "memoize-one";
import queryString from "query-string";
import { DateTime } from "luxon";
import { ExecutionResult } from "@apollo/react-common";
import { RouteComponentProps } from "react-router";
import { AppBridgeContext, IAppBridgeContext } from "@shopify/app-bridge-react/context";
import { shouldRedirect, getWindow } from "@shopify/app-bridge/client/redirect";
import { Redirect } from "@shopify/app-bridge/actions";
import { useContext } from "react";
export type AssertedKeys<T, K extends keyof T> = { [Key in K]-?: NonNullable<T[Key]> } & T;

export function assert<T>(value: T | undefined | null): T {
  if (!value) {
    throw new Error("assertion error");
  }
  return value;
}

export function assertKeys<T extends { [key: string]: any }, K extends keyof T>(object: T, keys: K[]) {
  for (const key of keys) {
    if (isUndefined(object[key]) || isNull(object[key])) {
      return false;
    }
  }
  return object as AssertedKeys<T, K>;
}

export type PropsType<Component> = Component extends React.ComponentType<infer Props> ? Props : never;

export const encodeURIParams = (params: { [key: string]: string }) =>
  Object.entries(params)
    .map(([key, val]) => `${encodeURIComponent(key)}=${encodeURIComponent(val)}`)
    .join("&");

export function invokeIfNeeded<T, U extends any[]>(f: T | ((...args: U) => T), args: U) {
  return isFunction(f) ? f(...args) : f;
}

export const isArrayOptionType = <T extends object>(value: T | readonly T[]): value is readonly T[] => isArray(value);
export const isValueOptionType = <T extends object>(value: T | readonly T[]): value is T => value.hasOwnProperty("value");

export type ISO8601DateString = string;
export const formatDate = (str: ISO8601DateString) => DateTime.fromISO(str).toLocaleString(DateTime.DATE_FULL);

export const isTouchDevice = memoizeOne(() => {
  const prefixes = " -webkit- -moz- -o- -ms- ".split(" ");
  const mq = (query: any) => {
    return window.matchMedia(query).matches;
  };

  if ("ontouchstart" in window || ((window as any).DocumentTouch && document instanceof (window as any).DocumentTouch)) {
    return true;
  }

  // include the 'heartz' as a way to have a non matching MQ to help terminate the join
  // https://git.io/vznFH
  const query = ["(", prefixes.join("touch-enabled),("), "heartz", ")"].join("");
  return mq(query);
});

const hasOwnProperty = Object.prototype.hasOwnProperty;
export const shallowEqual = (objA: any, objB: any): boolean => {
  if (Object.is(objA, objB)) {
    return true;
  }

  if (typeof objA !== "object" || objA === null || typeof objB !== "object" || objB === null) {
    return false;
  }

  const keysA = Object.keys(objA);
  const keysB = Object.keys(objB);

  if (keysA.length !== keysB.length) {
    return false;
  }

  // Test for A's keys different from B.
  for (let i = 0; i < keysA.length; i++) {
    if (!hasOwnProperty.call(objB, keysA[i]) || !Object.is(objA[keysA[i]], objB[keysA[i]])) {
      return false;
    }
  }

  return true;
};

export const shallowSubsetEqual = (keys: string[], objA: any, objB: any): boolean => {
  if (Object.is(objA, objB)) {
    return true;
  }

  if (typeof objA !== "object" || objA === null || typeof objB !== "object" || objB === null) {
    return false;
  }

  for (let i = 0; i < keys.length; i++) {
    if (!hasOwnProperty.call(objB, keys[i]) || !Object.is(objA[keys[i]], objB[keys[i]])) {
      return false;
    }
  }

  return true;
};

export interface ScorpionStyleGraphQLError {
  field: string;
  relativeField: string;
  mutationClientId?: string;
  message: string;
}

export interface ScorpionStyleRESTError {
  field: string;
  relative_field: string;
  mutation_client_id?: string;
  message: string;
}

export type SuccessfulMutationResponse<T> = {
  [K in keyof Omit<T, "errors">]: Exclude<T[K], null>;
};

export type ExecutionResultShape<Result extends ExecutionResult> = Result extends ExecutionResult<infer Shape> ? Shape : never;

// TypeScript incantation to get back the data asserting that it is present for a given mutation, detecting transport
// and validation errors at type check time
export const mutationSuccess = <
  Result extends ExecutionResult<Shape>,
  Shape = ExecutionResultShape<Result>,
  Key extends keyof Shape = keyof Shape
>(
  result: Result | undefined,
  key: Key
): SuccessfulMutationResponse<Exclude<Shape[Key], null>> | undefined => {
  if (result && !result.errors && result.data && !(result.data[key] as any).errors) {
    assert(result.data[key]);
    return result.data[key] as any;
  }

  return;
};

export const RelayConnectionQueryUpdater = memoizeOne((connectionName: string) => (previousResult: any, { fetchMoreResult }: any) => {
  const path = toPath(connectionName);
  const fetchMoreConnection = get(fetchMoreResult, path);
  const previousConnection = get(previousResult, path);
  const newEdges = fetchMoreConnection.edges;
  const pageInfo = fetchMoreConnection.pageInfo;

  return newEdges.length
    ? set(
        cloneDeep(previousResult),
        connectionName,
        // Put the new nodes at the end of the list and update `pageInfo`
        // so we have the new `endCursor` and `hasNextPage` values
        {
          __typename: previousConnection.__typename,
          edges: [...previousConnection.edges, ...newEdges],
          pageInfo,
        }
      )
    : previousResult;
});

export const replaceLocationWithNewParams = (
  params: { [key: string]: any },
  location: RouteComponentProps["location"],
  history: RouteComponentProps["history"]
) => {
  const string = queryString.stringify(params);
  const newLocation = string.length > 0 ? `${location.pathname}?${string}` : location.pathname;
  history.replace(newLocation);
};

// automerge proxy friendly version of cloneDeep
export const automergeFriendlyCloneDeep = (obj: any) => {
  return cloneDeepWith(obj, (item) => {
    if (isArrayLike(item)) {
      return item.map(cloneDeep);
    } else {
      return undefined;
    }
  });
};

// Outlier removal http://bl.ocks.org/phil-pedruco/6917114
// Borrowed from Jason Davies science library https://github.com/jasondavies/science.js/blob/master/science.v1.js
export const variance = (x: number[]) => {
  const n = x.length;
  if (n < 1) return NaN;
  if (n === 1) return 0;
  const _mean = mean(x);
  let i = -1,
    s = 0;
  while (++i < n) {
    const v = x[i] - _mean;
    s += v * v;
  }
  return s / (n - 1);
};

//A test for outliers http://en.wikipedia.org/wiki/Chauvenet%27s_criterion
const dMax = 3;
export const chauvenet = (x: number[]) => {
  const _mean = mean(x);
  const stdv = Math.sqrt(variance(x));
  let counter = 0;
  const temp = [];

  for (let i = 0; i < x.length; i++) {
    if (dMax > Math.abs(x[i] - _mean) / stdv) {
      temp[counter] = x[i];
      counter = counter + 1;
    }
  }

  return temp;
};

export const embeddedEscapeRedirect = (app: IAppBridgeContext, url: string) => {
  const fetchedWindow = getWindow();
  const currentlyEmbedded = fetchedWindow && !shouldRedirect(fetchedWindow.top);

  if (currentlyEmbedded) {
    assert(app).dispatch(Redirect.toRemote({ url }));
  } else {
    window.location.href = url;
  }
};

export const useAppBridge = () => {
  return assert(useContext(AppBridgeContext));
};
