// THIS IS A GENERATED FILE! You shouldn't edit it manually. Regenerate it using `yarn generate-graphql`.
import gql from 'graphql-tag';
import * as React from 'react';
import * as ApolloReactCommon from '@apollo/react-common';
import * as ApolloReactComponents from '@apollo/react-components';
import * as ApolloReactHooks from '@apollo/react-hooks';
export type Maybe<T> = T | null;
export type Omit<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>>;

/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
  ISO8601DateTime: string;
  JSONScalar: any;
  MutationClientId: any;
};

export type Account = {
   __typename: 'Account';
  appUrl: Scalars['String'];
  createdAt: Scalars['ISO8601DateTime'];
  creator: User;
  discarded: Scalars['Boolean'];
  discardedAt?: Maybe<Scalars['ISO8601DateTime']>;
  id: Scalars['ID'];
  name: Scalars['String'];
  updatedAt: Scalars['ISO8601DateTime'];
};

export type AccountAttributes = {
  mutationClientId?: Maybe<Scalars['MutationClientId']>;
  name: Scalars['String'];
};

export type AppMutation = {
   __typename: 'AppMutation';
  attachDirectUploadedFile?: Maybe<AttachDirectUploadedFilePayload>;
  attachRemoteUrl?: Maybe<AttachRemoteUrlPayload>;
  updateAccount?: Maybe<UpdateAccountPayload>;
};


export type AppMutationAttachDirectUploadedFileArgs = {
  directUploadSignedId: Scalars['String'];
  attachmentContainerId: Scalars['ID'];
  attachmentContainerType: AttachmentContainerEnum;
};


export type AppMutationAttachRemoteUrlArgs = {
  url: Scalars['String'];
  attachmentContainerId: Scalars['ID'];
  attachmentContainerType: AttachmentContainerEnum;
};


export type AppMutationUpdateAccountArgs = {
  attributes: AccountAttributes;
};

export type AppQuery = {
   __typename: 'AppQuery';
  currentAccount: Account;
  currentProperty: Property;
  currentUser: User;
  feedItems: FeedItemConnection;
  issue?: Maybe<Issue>;
  issues: IssueConnection;
  users: UserConnection;
};


export type AppQueryFeedItemsArgs = {
  after?: Maybe<Scalars['String']>;
  before?: Maybe<Scalars['String']>;
  first?: Maybe<Scalars['Int']>;
  last?: Maybe<Scalars['Int']>;
};


export type AppQueryIssueArgs = {
  number: Scalars['Int'];
};


export type AppQueryIssuesArgs = {
  after?: Maybe<Scalars['String']>;
  before?: Maybe<Scalars['String']>;
  first?: Maybe<Scalars['Int']>;
  last?: Maybe<Scalars['Int']>;
};


export type AppQueryUsersArgs = {
  after?: Maybe<Scalars['String']>;
  before?: Maybe<Scalars['String']>;
  first?: Maybe<Scalars['Int']>;
  last?: Maybe<Scalars['Int']>;
};

export type AttachDirectUploadedFilePayload = {
   __typename: 'AttachDirectUploadedFilePayload';
  attachment?: Maybe<Attachment>;
  errors?: Maybe<Array<Scalars['String']>>;
};

export type Attachment = {
   __typename: 'Attachment';
  bytesize: Scalars['Int'];
  contentType: Scalars['String'];
  filename: Scalars['String'];
  id: Scalars['ID'];
  url: Scalars['String'];
};

export const enum AttachmentContainerEnum {
  NotImplemented = 'NOT_IMPLEMENTED'
};

export type AttachRemoteUrlPayload = {
   __typename: 'AttachRemoteUrlPayload';
  attachment?: Maybe<Attachment>;
  errors?: Maybe<Array<Scalars['String']>>;
};

export type Descriptor = {
   __typename: 'Descriptor';
  description: Scalars['String'];
  id: Scalars['ID'];
  key: Scalars['String'];
  severity: Scalars['String'];
  title: Scalars['String'];
};

export type DetectedApp = {
   __typename: 'DetectedApp';
  createdAt: Scalars['ISO8601DateTime'];
  firstSeenAt?: Maybe<Scalars['ISO8601DateTime']>;
  id: Scalars['ID'];
  lastSeenAt: Scalars['ISO8601DateTime'];
  name: Scalars['String'];
  reasons: Array<Scalars['String']>;
  seenLastTime: Scalars['Boolean'];
  updatedAt: Scalars['ISO8601DateTime'];
};

export type FeedItem = {
   __typename: 'FeedItem';
  createdAt: Scalars['ISO8601DateTime'];
  groupEnd: Scalars['ISO8601DateTime'];
  groupStart: Scalars['ISO8601DateTime'];
  id: Scalars['ID'];
  itemAt?: Maybe<Scalars['ISO8601DateTime']>;
  itemType: Scalars['String'];
  subjects: Array<FeedItemSubjectUnion>;
  updatedAt: Scalars['ISO8601DateTime'];
};

export type FeedItemConnection = {
   __typename: 'FeedItemConnection';
  edges: Array<FeedItemEdge>;
  nodes: Array<FeedItem>;
  pageInfo: PageInfo;
};

export type FeedItemEdge = {
   __typename: 'FeedItemEdge';
  cursor: Scalars['String'];
  node?: Maybe<FeedItem>;
};

export type FeedItemSubjectUnion = IssueChangeEvent | ProductionGroup | ShopifyAssetChangeFeedSubject | ShopifyDetectedAppChangeFeedSubject | ShopifyEventFeedSubject | ShopifyShopChangeFeedSubject | ShopifyThemeChangeFeedSubject;


export type Issue = {
   __typename: 'Issue';
  closedAt?: Maybe<Scalars['ISO8601DateTime']>;
  createdAt: Scalars['ISO8601DateTime'];
  descriptor: Descriptor;
  id: Scalars['ID'];
  key: Scalars['String'];
  keyCategory: KeyCategory;
  lastSeenAt: Scalars['ISO8601DateTime'];
  name: Scalars['String'];
  number: Scalars['Int'];
  openedAt: Scalars['ISO8601DateTime'];
  results: ResultConnection;
  updatedAt: Scalars['ISO8601DateTime'];
};


export type IssueResultsArgs = {
  after?: Maybe<Scalars['String']>;
  before?: Maybe<Scalars['String']>;
  first?: Maybe<Scalars['Int']>;
  last?: Maybe<Scalars['Int']>;
};

export type IssueChangeEvent = {
   __typename: 'IssueChangeEvent';
  action?: Maybe<Scalars['String']>;
  actionAt: Scalars['ISO8601DateTime'];
  createdAt: Scalars['ISO8601DateTime'];
  id: Scalars['ID'];
  issue: Issue;
  productionGroup?: Maybe<ProductionGroup>;
  property: Property;
  updatedAt: Scalars['ISO8601DateTime'];
};

export type IssueChangeEventConnection = {
   __typename: 'IssueChangeEventConnection';
  edges: Array<IssueChangeEventEdge>;
  nodes: Array<IssueChangeEvent>;
  pageInfo: PageInfo;
};

export type IssueChangeEventEdge = {
   __typename: 'IssueChangeEventEdge';
  cursor: Scalars['String'];
  node?: Maybe<IssueChangeEvent>;
};

export type IssueConnection = {
   __typename: 'IssueConnection';
  edges: Array<IssueEdge>;
  nodes: Array<Issue>;
  pageInfo: PageInfo;
};

export type IssueEdge = {
   __typename: 'IssueEdge';
  cursor: Scalars['String'];
  node?: Maybe<Issue>;
};


export const enum KeyCategory {
  Home = 'HOME',
  Navigation = 'NAVIGATION',
  Browsing = 'BROWSING',
  Products = 'PRODUCTS',
  Search = 'SEARCH',
  Cart = 'CART',
  Checkout = 'CHECKOUT',
  Performance = 'PERFORMANCE',
  Design = 'DESIGN',
  Seo = 'SEO',
  Security = 'SECURITY'
};


export type MutationError = {
   __typename: 'MutationError';
  field: Scalars['String'];
  fullMessage: Scalars['String'];
  message: Scalars['String'];
  mutationClientId?: Maybe<Scalars['MutationClientId']>;
  relativeField: Scalars['String'];
};

export type PageInfo = {
   __typename: 'PageInfo';
  endCursor?: Maybe<Scalars['String']>;
  hasNextPage: Scalars['Boolean'];
  hasPreviousPage: Scalars['Boolean'];
  startCursor?: Maybe<Scalars['String']>;
};

export type ProductionGroup = {
   __typename: 'ProductionGroup';
  assessmentResults: ResultConnection;
  changedIssueCount: Scalars['Int'];
  createdAt: Scalars['ISO8601DateTime'];
  id: Scalars['ID'];
  issueChangeEvents: IssueChangeEventConnection;
  property: Property;
  reason: Scalars['String'];
  startedAt: Scalars['ISO8601DateTime'];
  updatedAt: Scalars['ISO8601DateTime'];
};


export type ProductionGroupAssessmentResultsArgs = {
  after?: Maybe<Scalars['String']>;
  before?: Maybe<Scalars['String']>;
  first?: Maybe<Scalars['Int']>;
  last?: Maybe<Scalars['Int']>;
};


export type ProductionGroupIssueChangeEventsArgs = {
  after?: Maybe<Scalars['String']>;
  before?: Maybe<Scalars['String']>;
  first?: Maybe<Scalars['Int']>;
  last?: Maybe<Scalars['Int']>;
};

export type Property = {
   __typename: 'Property';
  activityFeedItems: FeedItemConnection;
  allowedDomains: Array<Scalars['String']>;
  crawlRoots: Array<Scalars['String']>;
  createdAt: Scalars['ISO8601DateTime'];
  creator: User;
  enabled: Scalars['Boolean'];
  id: Scalars['ID'];
  issues: IssueConnection;
  name: Scalars['String'];
  updatedAt: Scalars['ISO8601DateTime'];
};


export type PropertyActivityFeedItemsArgs = {
  after?: Maybe<Scalars['String']>;
  before?: Maybe<Scalars['String']>;
  first?: Maybe<Scalars['Int']>;
  last?: Maybe<Scalars['Int']>;
};


export type PropertyIssuesArgs = {
  after?: Maybe<Scalars['String']>;
  before?: Maybe<Scalars['String']>;
  first?: Maybe<Scalars['Int']>;
  last?: Maybe<Scalars['Int']>;
};

export type Result = {
   __typename: 'Result';
  assessmentAt: Scalars['ISO8601DateTime'];
  createdAt: Scalars['ISO8601DateTime'];
  details: Scalars['JSONScalar'];
  id: Scalars['ID'];
  issue?: Maybe<Issue>;
  key: Scalars['String'];
  keyCategory: KeyCategory;
  score: Scalars['Int'];
  scoreMode: Scalars['String'];
  updatedAt: Scalars['ISO8601DateTime'];
  url?: Maybe<Scalars['String']>;
};

export type ResultConnection = {
   __typename: 'ResultConnection';
  edges: Array<ResultEdge>;
  nodes: Array<Result>;
  pageInfo: PageInfo;
};

export type ResultEdge = {
   __typename: 'ResultEdge';
  cursor: Scalars['String'];
  node?: Maybe<Result>;
};

export type ShopifyAssetChangeFeedSubject = {
   __typename: 'ShopifyAssetChangeFeedSubject';
  action?: Maybe<Scalars['String']>;
  actionAt: Scalars['ISO8601DateTime'];
  createdAt: Scalars['ISO8601DateTime'];
  id: Scalars['ID'];
  key: Scalars['String'];
  theme: Theme;
  updatedAt: Scalars['ISO8601DateTime'];
};

export type ShopifyDetectedAppChangeFeedSubject = {
   __typename: 'ShopifyDetectedAppChangeFeedSubject';
  action?: Maybe<Scalars['String']>;
  actionAt: Scalars['ISO8601DateTime'];
  createdAt: Scalars['ISO8601DateTime'];
  detectedApp: DetectedApp;
  id: Scalars['ID'];
  key: Scalars['String'];
  updatedAt: Scalars['ISO8601DateTime'];
};

export type ShopifyEventFeedSubject = {
   __typename: 'ShopifyEventFeedSubject';
  arguments?: Maybe<Scalars['String']>;
  author?: Maybe<Scalars['String']>;
  createdAt: Scalars['ISO8601DateTime'];
  description?: Maybe<Scalars['String']>;
  id: Scalars['ID'];
  path?: Maybe<Scalars['String']>;
  shopifyCreatedAt: Scalars['ISO8601DateTime'];
  updatedAt: Scalars['ISO8601DateTime'];
  verb: Scalars['String'];
};

export type ShopifyShopChangeFeedSubject = {
   __typename: 'ShopifyShopChangeFeedSubject';
  createdAt: Scalars['ISO8601DateTime'];
  id: Scalars['ID'];
  newValue?: Maybe<Scalars['JSONScalar']>;
  oldValue?: Maybe<Scalars['JSONScalar']>;
  recordAttribute: Scalars['String'];
  updatedAt: Scalars['ISO8601DateTime'];
};

export type ShopifyThemeChangeFeedSubject = {
   __typename: 'ShopifyThemeChangeFeedSubject';
  createdAt: Scalars['ISO8601DateTime'];
  id: Scalars['ID'];
  newValue?: Maybe<Scalars['JSONScalar']>;
  oldValue?: Maybe<Scalars['JSONScalar']>;
  recordAttribute: Scalars['String'];
  theme: Theme;
  updatedAt: Scalars['ISO8601DateTime'];
};

export type Theme = {
   __typename: 'Theme';
  createdAt: Scalars['ISO8601DateTime'];
  id: Scalars['ID'];
  name: Scalars['String'];
  previewable: Scalars['Boolean'];
  processing: Scalars['Boolean'];
  role: Scalars['String'];
  shopifyCreatedAt?: Maybe<Scalars['ISO8601DateTime']>;
  shopifyUpdatedAt: Scalars['ISO8601DateTime'];
  updatedAt: Scalars['ISO8601DateTime'];
};

export type UpdateAccountPayload = {
   __typename: 'UpdateAccountPayload';
  account?: Maybe<Account>;
  errors?: Maybe<Array<MutationError>>;
};

export type User = {
   __typename: 'User';
  accounts: Array<Account>;
  authAreaUrl: Scalars['String'];
  createdAt: Scalars['ISO8601DateTime'];
  email: Scalars['String'];
  fullName?: Maybe<Scalars['String']>;
  id: Scalars['ID'];
  primaryTextIdentifier: Scalars['String'];
  secondaryTextIdentifier?: Maybe<Scalars['String']>;
  updatedAt: Scalars['ISO8601DateTime'];
};

export type UserConnection = {
   __typename: 'UserConnection';
  edges: Array<UserEdge>;
  nodes: Array<User>;
  pageInfo: PageInfo;
};

export type UserEdge = {
   __typename: 'UserEdge';
  cursor: Scalars['String'];
  node?: Maybe<User>;
};

export type GetIssuesForHomePageQueryVariables = {};


export type GetIssuesForHomePageQuery = (
  { __typename: 'AppQuery' }
  & { currentProperty: (
    { __typename: 'Property' }
    & { issues: (
      { __typename: 'IssueConnection' }
      & { nodes: Array<(
        { __typename: 'Issue' }
        & Pick<Issue, 'id' | 'name' | 'number' | 'key' | 'keyCategory' | 'openedAt' | 'closedAt'>
      )> }
    ) }
  ) }
);

export type GetOverallStatusFragment = (
  { __typename: 'AppQuery' }
  & { currentProperty: (
    { __typename: 'Property' }
    & Pick<Property, 'id' | 'name'>
  ) }
);

export type GetCurrentUserForSettingsQueryVariables = {};


export type GetCurrentUserForSettingsQuery = (
  { __typename: 'AppQuery' }
  & { currentUser: (
    { __typename: 'User' }
    & Pick<User, 'id' | 'fullName' | 'email'>
  ) }
);

export type GetIssueForIssuePageQueryVariables = {
  number: Scalars['Int'];
};


export type GetIssueForIssuePageQuery = (
  { __typename: 'AppQuery' }
  & { issue?: Maybe<(
    { __typename: 'Issue' }
    & Pick<Issue, 'id' | 'name' | 'number' | 'key' | 'keyCategory' | 'openedAt' | 'lastSeenAt' | 'closedAt'>
    & { descriptor: (
      { __typename: 'Descriptor' }
      & Pick<Descriptor, 'title' | 'description'>
    ) }
  )> }
);

export type AppChangeTimelineEntryDetailsFragment = (
  { __typename: 'ShopifyDetectedAppChangeFeedSubject' }
  & Pick<ShopifyDetectedAppChangeFeedSubject, 'id' | 'action' | 'actionAt' | 'key'>
  & { detectedApp: (
    { __typename: 'DetectedApp' }
    & Pick<DetectedApp, 'name' | 'reasons'>
  ) }
);

export type IssueChangeTimelineDetailsFragment = (
  { __typename: 'IssueChangeEvent' }
  & Pick<IssueChangeEvent, 'id' | 'action'>
  & { issue: (
    { __typename: 'Issue' }
    & Pick<Issue, 'name' | 'key' | 'keyCategory'>
    & { descriptor: (
      { __typename: 'Descriptor' }
      & Pick<Descriptor, 'title' | 'severity'>
    ) }
  ) }
);

export type ScanTimelineEntryDetailsFragment = (
  { __typename: 'ProductionGroup' }
  & Pick<ProductionGroup, 'id' | 'reason' | 'startedAt' | 'changedIssueCount'>
  & { issueChangeEvents: (
    { __typename: 'IssueChangeEventConnection' }
    & { nodes: Array<(
      { __typename: 'IssueChangeEvent' }
      & Pick<IssueChangeEvent, 'id' | 'action'>
      & { issue: (
        { __typename: 'Issue' }
        & Pick<Issue, 'number'>
      ) }
    )> }
  ) }
);

export type ShopifyAssetChangeTimelineDetailsFragment = (
  { __typename: 'ShopifyAssetChangeFeedSubject' }
  & Pick<ShopifyAssetChangeFeedSubject, 'id' | 'key' | 'action'>
  & { theme: (
    { __typename: 'Theme' }
    & Pick<Theme, 'id' | 'name'>
  ) }
);

export type ShopifyEventTimelineDetailsFragment = (
  { __typename: 'ShopifyEventFeedSubject' }
  & Pick<ShopifyEventFeedSubject, 'id' | 'description' | 'path'>
);

export type ShopifyShopChangeTimelineDetailsFragment = (
  { __typename: 'ShopifyShopChangeFeedSubject' }
  & Pick<ShopifyShopChangeFeedSubject, 'id' | 'recordAttribute' | 'oldValue' | 'newValue'>
);

export type ShopifyThemeChangeTimelineDetailsFragment = (
  { __typename: 'ShopifyThemeChangeFeedSubject' }
  & Pick<ShopifyThemeChangeFeedSubject, 'id' | 'recordAttribute' | 'oldValue' | 'newValue'>
  & { theme: (
    { __typename: 'Theme' }
    & Pick<Theme, 'name'>
  ) }
);

export type GetActivityFeedForTimelineQueryVariables = {};


export type GetActivityFeedForTimelineQuery = (
  { __typename: 'AppQuery' }
  & { feedItems: (
    { __typename: 'FeedItemConnection' }
    & { nodes: Array<(
      { __typename: 'FeedItem' }
      & TimelineEntryDetailsFragment
    )>, pageInfo: (
      { __typename: 'PageInfo' }
      & Pick<PageInfo, 'hasNextPage' | 'endCursor'>
    ) }
  ) }
);

export type TimelineEntryDetailsFragment = (
  { __typename: 'FeedItem' }
  & Pick<FeedItem, 'id' | 'itemAt'>
  & { subjects: Array<(
    { __typename: 'IssueChangeEvent' }
    & IssueChangeTimelineDetailsFragment
  ) | (
    { __typename: 'ProductionGroup' }
    & ScanTimelineEntryDetailsFragment
  ) | (
    { __typename: 'ShopifyAssetChangeFeedSubject' }
    & ShopifyAssetChangeTimelineDetailsFragment
  ) | (
    { __typename: 'ShopifyDetectedAppChangeFeedSubject' }
    & AppChangeTimelineEntryDetailsFragment
  ) | (
    { __typename: 'ShopifyEventFeedSubject' }
    & ShopifyEventTimelineDetailsFragment
  ) | (
    { __typename: 'ShopifyShopChangeFeedSubject' }
    & ShopifyShopChangeTimelineDetailsFragment
  ) | (
    { __typename: 'ShopifyThemeChangeFeedSubject' }
    & ShopifyThemeChangeTimelineDetailsFragment
  )> }
);

export type AttachUploadToContainerMutationVariables = {
  directUploadSignedId: Scalars['String'];
  attachmentContainerId: Scalars['ID'];
  attachmentContainerType: AttachmentContainerEnum;
};


export type AttachUploadToContainerMutation = (
  { __typename: 'AppMutation' }
  & { attachDirectUploadedFile?: Maybe<(
    { __typename: 'AttachDirectUploadedFilePayload' }
    & Pick<AttachDirectUploadedFilePayload, 'errors'>
    & { attachment?: Maybe<(
      { __typename: 'Attachment' }
      & Pick<Attachment, 'id' | 'filename' | 'contentType' | 'bytesize' | 'url'>
    )> }
  )> }
);

export type AttachRemoteUrlToContainerMutationVariables = {
  url: Scalars['String'];
  attachmentContainerId: Scalars['ID'];
  attachmentContainerType: AttachmentContainerEnum;
};


export type AttachRemoteUrlToContainerMutation = (
  { __typename: 'AppMutation' }
  & { attachRemoteUrl?: Maybe<(
    { __typename: 'AttachRemoteUrlPayload' }
    & Pick<AttachRemoteUrlPayload, 'errors'>
    & { attachment?: Maybe<(
      { __typename: 'Attachment' }
      & Pick<Attachment, 'id' | 'filename' | 'contentType' | 'bytesize' | 'url'>
    )> }
  )> }
);

export const GetOverallStatusFragmentDoc = gql`
    fragment GetOverallStatus on AppQuery {
  currentProperty {
    id
    name
  }
}
    `;
export const ScanTimelineEntryDetailsFragmentDoc = gql`
    fragment ScanTimelineEntryDetails on ProductionGroup {
  id
  reason
  startedAt
  changedIssueCount
  issueChangeEvents(first: 3) {
    nodes {
      id
      action
      issue {
        number
      }
    }
  }
}
    `;
export const AppChangeTimelineEntryDetailsFragmentDoc = gql`
    fragment AppChangeTimelineEntryDetails on ShopifyDetectedAppChangeFeedSubject {
  id
  action
  actionAt
  key
  detectedApp {
    name
    reasons
  }
}
    `;
export const IssueChangeTimelineDetailsFragmentDoc = gql`
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
export const ShopifyEventTimelineDetailsFragmentDoc = gql`
    fragment ShopifyEventTimelineDetails on ShopifyEventFeedSubject {
  id
  description
  path
}
    `;
export const ShopifyAssetChangeTimelineDetailsFragmentDoc = gql`
    fragment ShopifyAssetChangeTimelineDetails on ShopifyAssetChangeFeedSubject {
  id
  key
  action
  theme {
    id
    name
  }
}
    `;
export const ShopifyShopChangeTimelineDetailsFragmentDoc = gql`
    fragment ShopifyShopChangeTimelineDetails on ShopifyShopChangeFeedSubject {
  id
  recordAttribute
  oldValue
  newValue
}
    `;
export const ShopifyThemeChangeTimelineDetailsFragmentDoc = gql`
    fragment ShopifyThemeChangeTimelineDetails on ShopifyThemeChangeFeedSubject {
  id
  recordAttribute
  oldValue
  newValue
  theme {
    name
  }
}
    `;
export const TimelineEntryDetailsFragmentDoc = gql`
    fragment TimelineEntryDetails on FeedItem {
  id
  itemAt
  subjects {
    __typename
    ... on ProductionGroup {
      ...ScanTimelineEntryDetails
    }
    ... on ShopifyDetectedAppChangeFeedSubject {
      ...AppChangeTimelineEntryDetails
    }
    ... on IssueChangeEvent {
      ...IssueChangeTimelineDetails
    }
    ... on ShopifyEventFeedSubject {
      ...ShopifyEventTimelineDetails
    }
    ... on ShopifyAssetChangeFeedSubject {
      ...ShopifyAssetChangeTimelineDetails
    }
    ... on ShopifyShopChangeFeedSubject {
      ...ShopifyShopChangeTimelineDetails
    }
    ... on ShopifyThemeChangeFeedSubject {
      ...ShopifyThemeChangeTimelineDetails
    }
  }
}
    ${ScanTimelineEntryDetailsFragmentDoc}
${AppChangeTimelineEntryDetailsFragmentDoc}
${IssueChangeTimelineDetailsFragmentDoc}
${ShopifyEventTimelineDetailsFragmentDoc}
${ShopifyAssetChangeTimelineDetailsFragmentDoc}
${ShopifyShopChangeTimelineDetailsFragmentDoc}
${ShopifyThemeChangeTimelineDetailsFragmentDoc}`;
export const GetIssuesForHomePageDocument = gql`
    query GetIssuesForHomePage {
  currentProperty {
    issues {
      nodes {
        id
        name
        number
        key
        keyCategory
        openedAt
        closedAt
      }
    }
  }
}
    `;
export type GetIssuesForHomePageComponentProps = Omit<ApolloReactComponents.QueryComponentOptions<GetIssuesForHomePageQuery, GetIssuesForHomePageQueryVariables>, 'query'>;

    export const GetIssuesForHomePageComponent = (props: GetIssuesForHomePageComponentProps) => (
      <ApolloReactComponents.Query<GetIssuesForHomePageQuery, GetIssuesForHomePageQueryVariables> query={GetIssuesForHomePageDocument} {...props} />
    );
    

/**
 * __useGetIssuesForHomePageQuery__
 *
 * To run a query within a React component, call `useGetIssuesForHomePageQuery` and pass it any options that fit your needs.
 * When your component renders, `useGetIssuesForHomePageQuery` returns an object from Apollo Client that contains loading, error, and data properties 
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useGetIssuesForHomePageQuery({
 *   variables: {
 *   },
 * });
 */
export function useGetIssuesForHomePageQuery(baseOptions?: ApolloReactHooks.QueryHookOptions<GetIssuesForHomePageQuery, GetIssuesForHomePageQueryVariables>) {
        return ApolloReactHooks.useQuery<GetIssuesForHomePageQuery, GetIssuesForHomePageQueryVariables>(GetIssuesForHomePageDocument, baseOptions);
      }
export function useGetIssuesForHomePageLazyQuery(baseOptions?: ApolloReactHooks.LazyQueryHookOptions<GetIssuesForHomePageQuery, GetIssuesForHomePageQueryVariables>) {
          return ApolloReactHooks.useLazyQuery<GetIssuesForHomePageQuery, GetIssuesForHomePageQueryVariables>(GetIssuesForHomePageDocument, baseOptions);
        }
export type GetIssuesForHomePageQueryHookResult = ReturnType<typeof useGetIssuesForHomePageQuery>;
export type GetIssuesForHomePageLazyQueryHookResult = ReturnType<typeof useGetIssuesForHomePageLazyQuery>;
export type GetIssuesForHomePageQueryResult = ApolloReactCommon.QueryResult<GetIssuesForHomePageQuery, GetIssuesForHomePageQueryVariables>;
export const GetCurrentUserForSettingsDocument = gql`
    query GetCurrentUserForSettings {
  currentUser {
    id
    fullName
    email
  }
}
    `;
export type GetCurrentUserForSettingsComponentProps = Omit<ApolloReactComponents.QueryComponentOptions<GetCurrentUserForSettingsQuery, GetCurrentUserForSettingsQueryVariables>, 'query'>;

    export const GetCurrentUserForSettingsComponent = (props: GetCurrentUserForSettingsComponentProps) => (
      <ApolloReactComponents.Query<GetCurrentUserForSettingsQuery, GetCurrentUserForSettingsQueryVariables> query={GetCurrentUserForSettingsDocument} {...props} />
    );
    

/**
 * __useGetCurrentUserForSettingsQuery__
 *
 * To run a query within a React component, call `useGetCurrentUserForSettingsQuery` and pass it any options that fit your needs.
 * When your component renders, `useGetCurrentUserForSettingsQuery` returns an object from Apollo Client that contains loading, error, and data properties 
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useGetCurrentUserForSettingsQuery({
 *   variables: {
 *   },
 * });
 */
export function useGetCurrentUserForSettingsQuery(baseOptions?: ApolloReactHooks.QueryHookOptions<GetCurrentUserForSettingsQuery, GetCurrentUserForSettingsQueryVariables>) {
        return ApolloReactHooks.useQuery<GetCurrentUserForSettingsQuery, GetCurrentUserForSettingsQueryVariables>(GetCurrentUserForSettingsDocument, baseOptions);
      }
export function useGetCurrentUserForSettingsLazyQuery(baseOptions?: ApolloReactHooks.LazyQueryHookOptions<GetCurrentUserForSettingsQuery, GetCurrentUserForSettingsQueryVariables>) {
          return ApolloReactHooks.useLazyQuery<GetCurrentUserForSettingsQuery, GetCurrentUserForSettingsQueryVariables>(GetCurrentUserForSettingsDocument, baseOptions);
        }
export type GetCurrentUserForSettingsQueryHookResult = ReturnType<typeof useGetCurrentUserForSettingsQuery>;
export type GetCurrentUserForSettingsLazyQueryHookResult = ReturnType<typeof useGetCurrentUserForSettingsLazyQuery>;
export type GetCurrentUserForSettingsQueryResult = ApolloReactCommon.QueryResult<GetCurrentUserForSettingsQuery, GetCurrentUserForSettingsQueryVariables>;
export const GetIssueForIssuePageDocument = gql`
    query GetIssueForIssuePage($number: Int!) {
  issue(number: $number) {
    id
    name
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
  }
}
    `;
export type GetIssueForIssuePageComponentProps = Omit<ApolloReactComponents.QueryComponentOptions<GetIssueForIssuePageQuery, GetIssueForIssuePageQueryVariables>, 'query'> & ({ variables: GetIssueForIssuePageQueryVariables; skip?: boolean; } | { skip: boolean; });

    export const GetIssueForIssuePageComponent = (props: GetIssueForIssuePageComponentProps) => (
      <ApolloReactComponents.Query<GetIssueForIssuePageQuery, GetIssueForIssuePageQueryVariables> query={GetIssueForIssuePageDocument} {...props} />
    );
    

/**
 * __useGetIssueForIssuePageQuery__
 *
 * To run a query within a React component, call `useGetIssueForIssuePageQuery` and pass it any options that fit your needs.
 * When your component renders, `useGetIssueForIssuePageQuery` returns an object from Apollo Client that contains loading, error, and data properties 
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useGetIssueForIssuePageQuery({
 *   variables: {
 *      number: // value for 'number'
 *   },
 * });
 */
export function useGetIssueForIssuePageQuery(baseOptions?: ApolloReactHooks.QueryHookOptions<GetIssueForIssuePageQuery, GetIssueForIssuePageQueryVariables>) {
        return ApolloReactHooks.useQuery<GetIssueForIssuePageQuery, GetIssueForIssuePageQueryVariables>(GetIssueForIssuePageDocument, baseOptions);
      }
export function useGetIssueForIssuePageLazyQuery(baseOptions?: ApolloReactHooks.LazyQueryHookOptions<GetIssueForIssuePageQuery, GetIssueForIssuePageQueryVariables>) {
          return ApolloReactHooks.useLazyQuery<GetIssueForIssuePageQuery, GetIssueForIssuePageQueryVariables>(GetIssueForIssuePageDocument, baseOptions);
        }
export type GetIssueForIssuePageQueryHookResult = ReturnType<typeof useGetIssueForIssuePageQuery>;
export type GetIssueForIssuePageLazyQueryHookResult = ReturnType<typeof useGetIssueForIssuePageLazyQuery>;
export type GetIssueForIssuePageQueryResult = ApolloReactCommon.QueryResult<GetIssueForIssuePageQuery, GetIssueForIssuePageQueryVariables>;
export const GetActivityFeedForTimelineDocument = gql`
    query GetActivityFeedForTimeline {
  feedItems(first: 30) {
    nodes {
      ...TimelineEntryDetails
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
    ${TimelineEntryDetailsFragmentDoc}`;
export type GetActivityFeedForTimelineComponentProps = Omit<ApolloReactComponents.QueryComponentOptions<GetActivityFeedForTimelineQuery, GetActivityFeedForTimelineQueryVariables>, 'query'>;

    export const GetActivityFeedForTimelineComponent = (props: GetActivityFeedForTimelineComponentProps) => (
      <ApolloReactComponents.Query<GetActivityFeedForTimelineQuery, GetActivityFeedForTimelineQueryVariables> query={GetActivityFeedForTimelineDocument} {...props} />
    );
    

/**
 * __useGetActivityFeedForTimelineQuery__
 *
 * To run a query within a React component, call `useGetActivityFeedForTimelineQuery` and pass it any options that fit your needs.
 * When your component renders, `useGetActivityFeedForTimelineQuery` returns an object from Apollo Client that contains loading, error, and data properties 
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useGetActivityFeedForTimelineQuery({
 *   variables: {
 *   },
 * });
 */
export function useGetActivityFeedForTimelineQuery(baseOptions?: ApolloReactHooks.QueryHookOptions<GetActivityFeedForTimelineQuery, GetActivityFeedForTimelineQueryVariables>) {
        return ApolloReactHooks.useQuery<GetActivityFeedForTimelineQuery, GetActivityFeedForTimelineQueryVariables>(GetActivityFeedForTimelineDocument, baseOptions);
      }
export function useGetActivityFeedForTimelineLazyQuery(baseOptions?: ApolloReactHooks.LazyQueryHookOptions<GetActivityFeedForTimelineQuery, GetActivityFeedForTimelineQueryVariables>) {
          return ApolloReactHooks.useLazyQuery<GetActivityFeedForTimelineQuery, GetActivityFeedForTimelineQueryVariables>(GetActivityFeedForTimelineDocument, baseOptions);
        }
export type GetActivityFeedForTimelineQueryHookResult = ReturnType<typeof useGetActivityFeedForTimelineQuery>;
export type GetActivityFeedForTimelineLazyQueryHookResult = ReturnType<typeof useGetActivityFeedForTimelineLazyQuery>;
export type GetActivityFeedForTimelineQueryResult = ApolloReactCommon.QueryResult<GetActivityFeedForTimelineQuery, GetActivityFeedForTimelineQueryVariables>;
export const AttachUploadToContainerDocument = gql`
    mutation AttachUploadToContainer($directUploadSignedId: String!, $attachmentContainerId: ID!, $attachmentContainerType: AttachmentContainerEnum!) {
  attachDirectUploadedFile(directUploadSignedId: $directUploadSignedId, attachmentContainerId: $attachmentContainerId, attachmentContainerType: $attachmentContainerType) {
    attachment {
      id
      filename
      contentType
      bytesize
      url
    }
    errors
  }
}
    `;
export type AttachUploadToContainerMutationFn = ApolloReactCommon.MutationFunction<AttachUploadToContainerMutation, AttachUploadToContainerMutationVariables>;
export type AttachUploadToContainerComponentProps = Omit<ApolloReactComponents.MutationComponentOptions<AttachUploadToContainerMutation, AttachUploadToContainerMutationVariables>, 'mutation'>;

    export const AttachUploadToContainerComponent = (props: AttachUploadToContainerComponentProps) => (
      <ApolloReactComponents.Mutation<AttachUploadToContainerMutation, AttachUploadToContainerMutationVariables> mutation={AttachUploadToContainerDocument} {...props} />
    );
    

/**
 * __useAttachUploadToContainerMutation__
 *
 * To run a mutation, you first call `useAttachUploadToContainerMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useAttachUploadToContainerMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [attachUploadToContainerMutation, { data, loading, error }] = useAttachUploadToContainerMutation({
 *   variables: {
 *      directUploadSignedId: // value for 'directUploadSignedId'
 *      attachmentContainerId: // value for 'attachmentContainerId'
 *      attachmentContainerType: // value for 'attachmentContainerType'
 *   },
 * });
 */
export function useAttachUploadToContainerMutation(baseOptions?: ApolloReactHooks.MutationHookOptions<AttachUploadToContainerMutation, AttachUploadToContainerMutationVariables>) {
        return ApolloReactHooks.useMutation<AttachUploadToContainerMutation, AttachUploadToContainerMutationVariables>(AttachUploadToContainerDocument, baseOptions);
      }
export type AttachUploadToContainerMutationHookResult = ReturnType<typeof useAttachUploadToContainerMutation>;
export type AttachUploadToContainerMutationResult = ApolloReactCommon.MutationResult<AttachUploadToContainerMutation>;
export type AttachUploadToContainerMutationOptions = ApolloReactCommon.BaseMutationOptions<AttachUploadToContainerMutation, AttachUploadToContainerMutationVariables>;
export const AttachRemoteUrlToContainerDocument = gql`
    mutation AttachRemoteUrlToContainer($url: String!, $attachmentContainerId: ID!, $attachmentContainerType: AttachmentContainerEnum!) {
  attachRemoteUrl(url: $url, attachmentContainerId: $attachmentContainerId, attachmentContainerType: $attachmentContainerType) {
    attachment {
      id
      filename
      contentType
      bytesize
      url
    }
    errors
  }
}
    `;
export type AttachRemoteUrlToContainerMutationFn = ApolloReactCommon.MutationFunction<AttachRemoteUrlToContainerMutation, AttachRemoteUrlToContainerMutationVariables>;
export type AttachRemoteUrlToContainerComponentProps = Omit<ApolloReactComponents.MutationComponentOptions<AttachRemoteUrlToContainerMutation, AttachRemoteUrlToContainerMutationVariables>, 'mutation'>;

    export const AttachRemoteUrlToContainerComponent = (props: AttachRemoteUrlToContainerComponentProps) => (
      <ApolloReactComponents.Mutation<AttachRemoteUrlToContainerMutation, AttachRemoteUrlToContainerMutationVariables> mutation={AttachRemoteUrlToContainerDocument} {...props} />
    );
    

/**
 * __useAttachRemoteUrlToContainerMutation__
 *
 * To run a mutation, you first call `useAttachRemoteUrlToContainerMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useAttachRemoteUrlToContainerMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [attachRemoteUrlToContainerMutation, { data, loading, error }] = useAttachRemoteUrlToContainerMutation({
 *   variables: {
 *      url: // value for 'url'
 *      attachmentContainerId: // value for 'attachmentContainerId'
 *      attachmentContainerType: // value for 'attachmentContainerType'
 *   },
 * });
 */
export function useAttachRemoteUrlToContainerMutation(baseOptions?: ApolloReactHooks.MutationHookOptions<AttachRemoteUrlToContainerMutation, AttachRemoteUrlToContainerMutationVariables>) {
        return ApolloReactHooks.useMutation<AttachRemoteUrlToContainerMutation, AttachRemoteUrlToContainerMutationVariables>(AttachRemoteUrlToContainerDocument, baseOptions);
      }
export type AttachRemoteUrlToContainerMutationHookResult = ReturnType<typeof useAttachRemoteUrlToContainerMutation>;
export type AttachRemoteUrlToContainerMutationResult = ApolloReactCommon.MutationResult<AttachRemoteUrlToContainerMutation>;
export type AttachRemoteUrlToContainerMutationOptions = ApolloReactCommon.BaseMutationOptions<AttachRemoteUrlToContainerMutation, AttachRemoteUrlToContainerMutationVariables>;