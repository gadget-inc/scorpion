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
  ID: string,
  String: string,
  Boolean: boolean,
  Int: number,
  Float: number,
  ISO8601DateTime: string,
  MutationClientId: any,
};

export type Account = {
   __typename: 'Account',
  appUrl: Scalars['String'],
  businessLines: Array<BusinessLine>,
  createdAt: Scalars['ISO8601DateTime'],
  creator: User,
  discarded: Scalars['Boolean'],
  discardedAt?: Maybe<Scalars['ISO8601DateTime']>,
  id: Scalars['ID'],
  name: Scalars['String'],
  updatedAt: Scalars['ISO8601DateTime'],
};

export type AccountAttributes = {
  mutationClientId?: Maybe<Scalars['MutationClientId']>,
  name: Scalars['String'],
};

export type AppMutation = {
   __typename: 'AppMutation',
  attachDirectUploadedFile?: Maybe<AttachDirectUploadedFilePayload>,
  attachRemoteUrl?: Maybe<AttachRemoteUrlPayload>,
  inviteUser?: Maybe<InviteUserPayload>,
  updateAccount?: Maybe<UpdateAccountPayload>,
};


export type AppMutationAttachDirectUploadedFileArgs = {
  directUploadSignedId: Scalars['String'],
  attachmentContainerId: Scalars['ID'],
  attachmentContainerType: AttachmentContainerEnum
};


export type AppMutationAttachRemoteUrlArgs = {
  url: Scalars['String'],
  attachmentContainerId: Scalars['ID'],
  attachmentContainerType: AttachmentContainerEnum
};


export type AppMutationInviteUserArgs = {
  user: UserInviteAttributes
};


export type AppMutationUpdateAccountArgs = {
  attributes: AccountAttributes
};

export type AppQuery = {
   __typename: 'AppQuery',
  currentAccount: Account,
  currentUser: User,
  currentUserAuthToken: Scalars['String'],
  users: UserConnection,
};


export type AppQueryUsersArgs = {
  after?: Maybe<Scalars['String']>,
  before?: Maybe<Scalars['String']>,
  first?: Maybe<Scalars['Int']>,
  last?: Maybe<Scalars['Int']>
};

export type AttachDirectUploadedFilePayload = {
   __typename: 'AttachDirectUploadedFilePayload',
  attachment?: Maybe<Attachment>,
  errors?: Maybe<Array<Scalars['String']>>,
};

export type Attachment = {
   __typename: 'Attachment',
  bytesize: Scalars['Int'],
  contentType: Scalars['String'],
  filename: Scalars['String'],
  id: Scalars['ID'],
  url: Scalars['String'],
};

export const enum AttachmentContainerEnum {
  NotImplemented = 'NOT_IMPLEMENTED'
};

export type AttachRemoteUrlPayload = {
   __typename: 'AttachRemoteUrlPayload',
  attachment?: Maybe<Attachment>,
  errors?: Maybe<Array<Scalars['String']>>,
};

export type BusinessLine = {
   __typename: 'BusinessLine',
  id: Scalars['ID'],
  name: Scalars['String'],
};

export type InviteUserPayload = {
   __typename: 'InviteUserPayload',
  errors?: Maybe<Array<MutationError>>,
  success: Scalars['Boolean'],
};



export type MutationError = {
   __typename: 'MutationError',
  field: Scalars['String'],
  fullMessage: Scalars['String'],
  message: Scalars['String'],
  mutationClientId?: Maybe<Scalars['MutationClientId']>,
  relativeField: Scalars['String'],
};

export type PageInfo = {
   __typename: 'PageInfo',
  endCursor?: Maybe<Scalars['String']>,
  hasNextPage: Scalars['Boolean'],
  hasPreviousPage: Scalars['Boolean'],
  startCursor?: Maybe<Scalars['String']>,
};

export type UpdateAccountPayload = {
   __typename: 'UpdateAccountPayload',
  account?: Maybe<Account>,
  errors?: Maybe<Array<MutationError>>,
};

export type User = {
   __typename: 'User',
  accounts: Array<Account>,
  authAreaUrl: Scalars['String'],
  createdAt: Scalars['ISO8601DateTime'],
  email: Scalars['String'],
  fullName?: Maybe<Scalars['String']>,
  id: Scalars['ID'],
  pendingInvitation: Scalars['Boolean'],
  primaryTextIdentifier: Scalars['String'],
  secondaryTextIdentifier?: Maybe<Scalars['String']>,
  updatedAt: Scalars['ISO8601DateTime'],
};

export type UserConnection = {
   __typename: 'UserConnection',
  edges: Array<UserEdge>,
  nodes: Array<User>,
  pageInfo: PageInfo,
};

export type UserEdge = {
   __typename: 'UserEdge',
  cursor: Scalars['String'],
  node?: Maybe<User>,
};

export type UserInviteAttributes = {
  mutationClientId?: Maybe<Scalars['MutationClientId']>,
  email: Scalars['String'],
};

export type SiderInfoQueryVariables = {};


export type SiderInfoQuery = (
  { __typename: 'AppQuery' }
  & { currentUser: (
    { __typename: 'User' }
    & Pick<User, 'email' | 'fullName' | 'authAreaUrl'>
    & { accounts: Array<(
      { __typename: 'Account' }
      & Pick<Account, 'id'>
    )> }
    & UserCardFragment
  ), currentAccount: (
    { __typename: 'Account' }
    & Pick<Account, 'name'>
  ) }
);

export type UserCardFragment = (
  { __typename: 'User' }
  & Pick<User, 'id' | 'email' | 'primaryTextIdentifier'>
);

export type GetAccountForSettingsQueryVariables = {};


export type GetAccountForSettingsQuery = (
  { __typename: 'AppQuery' }
  & { account: (
    { __typename: 'Account' }
    & Pick<Account, 'id' | 'name'>
  ) }
);

export type UpdateAccountSettingsMutationVariables = {
  attributes: AccountAttributes
};


export type UpdateAccountSettingsMutation = (
  { __typename: 'AppMutation' }
  & { updateAccount: Maybe<(
    { __typename: 'UpdateAccountPayload' }
    & { account: Maybe<(
      { __typename: 'Account' }
      & Pick<Account, 'id' | 'name'>
    )>, errors: Maybe<Array<(
      { __typename: 'MutationError' }
      & Pick<MutationError, 'fullMessage'>
    )>> }
  )> }
);

export type InviteNewUserMutationVariables = {
  user: UserInviteAttributes
};


export type InviteNewUserMutation = (
  { __typename: 'AppMutation' }
  & { inviteUser: Maybe<(
    { __typename: 'InviteUserPayload' }
    & Pick<InviteUserPayload, 'success'>
    & { errors: Maybe<Array<(
      { __typename: 'MutationError' }
      & Pick<MutationError, 'fullMessage'>
    )>> }
  )> }
);

export type GetUsersForSettingsQueryVariables = {};


export type GetUsersForSettingsQuery = (
  { __typename: 'AppQuery' }
  & { users: (
    { __typename: 'UserConnection' }
    & { nodes: Array<(
      { __typename: 'User' }
      & Pick<User, 'id' | 'fullName' | 'email' | 'pendingInvitation'>
      & UserCardFragment
    )> }
  ) }
);

export type AttachUploadToContainerMutationVariables = {
  directUploadSignedId: Scalars['String'],
  attachmentContainerId: Scalars['ID'],
  attachmentContainerType: AttachmentContainerEnum
};


export type AttachUploadToContainerMutation = (
  { __typename: 'AppMutation' }
  & { attachDirectUploadedFile: Maybe<(
    { __typename: 'AttachDirectUploadedFilePayload' }
    & Pick<AttachDirectUploadedFilePayload, 'errors'>
    & { attachment: Maybe<(
      { __typename: 'Attachment' }
      & Pick<Attachment, 'id' | 'filename' | 'contentType' | 'bytesize' | 'url'>
    )> }
  )> }
);

export type AttachRemoteUrlToContainerMutationVariables = {
  url: Scalars['String'],
  attachmentContainerId: Scalars['ID'],
  attachmentContainerType: AttachmentContainerEnum
};


export type AttachRemoteUrlToContainerMutation = (
  { __typename: 'AppMutation' }
  & { attachRemoteUrl: Maybe<(
    { __typename: 'AttachRemoteUrlPayload' }
    & Pick<AttachRemoteUrlPayload, 'errors'>
    & { attachment: Maybe<(
      { __typename: 'Attachment' }
      & Pick<Attachment, 'id' | 'filename' | 'contentType' | 'bytesize' | 'url'>
    )> }
  )> }
);

export const UserCardFragmentDoc = gql`
    fragment UserCard on User {
  id
  email
  primaryTextIdentifier
}
    `;
export const SiderInfoDocument = gql`
    query SiderInfo {
  currentUser {
    email
    fullName
    authAreaUrl
    ...UserCard
    accounts {
      id
    }
  }
  currentAccount {
    name
  }
}
    ${UserCardFragmentDoc}`;
export type SiderInfoComponentProps = Omit<ApolloReactComponents.QueryComponentOptions<SiderInfoQuery, SiderInfoQueryVariables>, 'query'>;

    export const SiderInfoComponent = (props: SiderInfoComponentProps) => (
      <ApolloReactComponents.Query<SiderInfoQuery, SiderInfoQueryVariables> query={SiderInfoDocument} {...props} />
    );
    

/**
 * __useSiderInfoQuery__
 *
 * To run a query within a React component, call `useSiderInfoQuery` and pass it any options that fit your needs.
 * When your component renders, `useSiderInfoQuery` returns an object from Apollo Client that contains loading, error, and data properties 
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useSiderInfoQuery({
 *   variables: {
 *   },
 * });
 */
export function useSiderInfoQuery(baseOptions?: ApolloReactHooks.QueryHookOptions<SiderInfoQuery, SiderInfoQueryVariables>) {
        return ApolloReactHooks.useQuery<SiderInfoQuery, SiderInfoQueryVariables>(SiderInfoDocument, baseOptions);
      }
export function useSiderInfoLazyQuery(baseOptions?: ApolloReactHooks.LazyQueryHookOptions<SiderInfoQuery, SiderInfoQueryVariables>) {
          return ApolloReactHooks.useLazyQuery<SiderInfoQuery, SiderInfoQueryVariables>(SiderInfoDocument, baseOptions);
        }
export type SiderInfoQueryHookResult = ReturnType<typeof useSiderInfoQuery>;
export type SiderInfoLazyQueryHookResult = ReturnType<typeof useSiderInfoLazyQuery>;
export type SiderInfoQueryResult = ApolloReactCommon.QueryResult<SiderInfoQuery, SiderInfoQueryVariables>;
export const GetAccountForSettingsDocument = gql`
    query GetAccountForSettings {
  account: currentAccount {
    id
    name
  }
}
    `;
export type GetAccountForSettingsComponentProps = Omit<ApolloReactComponents.QueryComponentOptions<GetAccountForSettingsQuery, GetAccountForSettingsQueryVariables>, 'query'>;

    export const GetAccountForSettingsComponent = (props: GetAccountForSettingsComponentProps) => (
      <ApolloReactComponents.Query<GetAccountForSettingsQuery, GetAccountForSettingsQueryVariables> query={GetAccountForSettingsDocument} {...props} />
    );
    

/**
 * __useGetAccountForSettingsQuery__
 *
 * To run a query within a React component, call `useGetAccountForSettingsQuery` and pass it any options that fit your needs.
 * When your component renders, `useGetAccountForSettingsQuery` returns an object from Apollo Client that contains loading, error, and data properties 
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useGetAccountForSettingsQuery({
 *   variables: {
 *   },
 * });
 */
export function useGetAccountForSettingsQuery(baseOptions?: ApolloReactHooks.QueryHookOptions<GetAccountForSettingsQuery, GetAccountForSettingsQueryVariables>) {
        return ApolloReactHooks.useQuery<GetAccountForSettingsQuery, GetAccountForSettingsQueryVariables>(GetAccountForSettingsDocument, baseOptions);
      }
export function useGetAccountForSettingsLazyQuery(baseOptions?: ApolloReactHooks.LazyQueryHookOptions<GetAccountForSettingsQuery, GetAccountForSettingsQueryVariables>) {
          return ApolloReactHooks.useLazyQuery<GetAccountForSettingsQuery, GetAccountForSettingsQueryVariables>(GetAccountForSettingsDocument, baseOptions);
        }
export type GetAccountForSettingsQueryHookResult = ReturnType<typeof useGetAccountForSettingsQuery>;
export type GetAccountForSettingsLazyQueryHookResult = ReturnType<typeof useGetAccountForSettingsLazyQuery>;
export type GetAccountForSettingsQueryResult = ApolloReactCommon.QueryResult<GetAccountForSettingsQuery, GetAccountForSettingsQueryVariables>;
export const UpdateAccountSettingsDocument = gql`
    mutation UpdateAccountSettings($attributes: AccountAttributes!) {
  updateAccount(attributes: $attributes) {
    account {
      id
      name
    }
    errors {
      fullMessage
    }
  }
}
    `;
export type UpdateAccountSettingsMutationFn = ApolloReactCommon.MutationFunction<UpdateAccountSettingsMutation, UpdateAccountSettingsMutationVariables>;
export type UpdateAccountSettingsComponentProps = Omit<ApolloReactComponents.MutationComponentOptions<UpdateAccountSettingsMutation, UpdateAccountSettingsMutationVariables>, 'mutation'>;

    export const UpdateAccountSettingsComponent = (props: UpdateAccountSettingsComponentProps) => (
      <ApolloReactComponents.Mutation<UpdateAccountSettingsMutation, UpdateAccountSettingsMutationVariables> mutation={UpdateAccountSettingsDocument} {...props} />
    );
    

/**
 * __useUpdateAccountSettingsMutation__
 *
 * To run a mutation, you first call `useUpdateAccountSettingsMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useUpdateAccountSettingsMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [updateAccountSettingsMutation, { data, loading, error }] = useUpdateAccountSettingsMutation({
 *   variables: {
 *      attributes: // value for 'attributes'
 *   },
 * });
 */
export function useUpdateAccountSettingsMutation(baseOptions?: ApolloReactHooks.MutationHookOptions<UpdateAccountSettingsMutation, UpdateAccountSettingsMutationVariables>) {
        return ApolloReactHooks.useMutation<UpdateAccountSettingsMutation, UpdateAccountSettingsMutationVariables>(UpdateAccountSettingsDocument, baseOptions);
      }
export type UpdateAccountSettingsMutationHookResult = ReturnType<typeof useUpdateAccountSettingsMutation>;
export type UpdateAccountSettingsMutationResult = ApolloReactCommon.MutationResult<UpdateAccountSettingsMutation>;
export type UpdateAccountSettingsMutationOptions = ApolloReactCommon.BaseMutationOptions<UpdateAccountSettingsMutation, UpdateAccountSettingsMutationVariables>;
export const InviteNewUserDocument = gql`
    mutation InviteNewUser($user: UserInviteAttributes!) {
  inviteUser(user: $user) {
    success
    errors {
      fullMessage
    }
  }
}
    `;
export type InviteNewUserMutationFn = ApolloReactCommon.MutationFunction<InviteNewUserMutation, InviteNewUserMutationVariables>;
export type InviteNewUserComponentProps = Omit<ApolloReactComponents.MutationComponentOptions<InviteNewUserMutation, InviteNewUserMutationVariables>, 'mutation'>;

    export const InviteNewUserComponent = (props: InviteNewUserComponentProps) => (
      <ApolloReactComponents.Mutation<InviteNewUserMutation, InviteNewUserMutationVariables> mutation={InviteNewUserDocument} {...props} />
    );
    

/**
 * __useInviteNewUserMutation__
 *
 * To run a mutation, you first call `useInviteNewUserMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useInviteNewUserMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [inviteNewUserMutation, { data, loading, error }] = useInviteNewUserMutation({
 *   variables: {
 *      user: // value for 'user'
 *   },
 * });
 */
export function useInviteNewUserMutation(baseOptions?: ApolloReactHooks.MutationHookOptions<InviteNewUserMutation, InviteNewUserMutationVariables>) {
        return ApolloReactHooks.useMutation<InviteNewUserMutation, InviteNewUserMutationVariables>(InviteNewUserDocument, baseOptions);
      }
export type InviteNewUserMutationHookResult = ReturnType<typeof useInviteNewUserMutation>;
export type InviteNewUserMutationResult = ApolloReactCommon.MutationResult<InviteNewUserMutation>;
export type InviteNewUserMutationOptions = ApolloReactCommon.BaseMutationOptions<InviteNewUserMutation, InviteNewUserMutationVariables>;
export const GetUsersForSettingsDocument = gql`
    query GetUsersForSettings {
  users {
    nodes {
      id
      fullName
      email
      pendingInvitation
      ...UserCard
    }
  }
}
    ${UserCardFragmentDoc}`;
export type GetUsersForSettingsComponentProps = Omit<ApolloReactComponents.QueryComponentOptions<GetUsersForSettingsQuery, GetUsersForSettingsQueryVariables>, 'query'>;

    export const GetUsersForSettingsComponent = (props: GetUsersForSettingsComponentProps) => (
      <ApolloReactComponents.Query<GetUsersForSettingsQuery, GetUsersForSettingsQueryVariables> query={GetUsersForSettingsDocument} {...props} />
    );
    

/**
 * __useGetUsersForSettingsQuery__
 *
 * To run a query within a React component, call `useGetUsersForSettingsQuery` and pass it any options that fit your needs.
 * When your component renders, `useGetUsersForSettingsQuery` returns an object from Apollo Client that contains loading, error, and data properties 
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useGetUsersForSettingsQuery({
 *   variables: {
 *   },
 * });
 */
export function useGetUsersForSettingsQuery(baseOptions?: ApolloReactHooks.QueryHookOptions<GetUsersForSettingsQuery, GetUsersForSettingsQueryVariables>) {
        return ApolloReactHooks.useQuery<GetUsersForSettingsQuery, GetUsersForSettingsQueryVariables>(GetUsersForSettingsDocument, baseOptions);
      }
export function useGetUsersForSettingsLazyQuery(baseOptions?: ApolloReactHooks.LazyQueryHookOptions<GetUsersForSettingsQuery, GetUsersForSettingsQueryVariables>) {
          return ApolloReactHooks.useLazyQuery<GetUsersForSettingsQuery, GetUsersForSettingsQueryVariables>(GetUsersForSettingsDocument, baseOptions);
        }
export type GetUsersForSettingsQueryHookResult = ReturnType<typeof useGetUsersForSettingsQuery>;
export type GetUsersForSettingsLazyQueryHookResult = ReturnType<typeof useGetUsersForSettingsLazyQuery>;
export type GetUsersForSettingsQueryResult = ApolloReactCommon.QueryResult<GetUsersForSettingsQuery, GetUsersForSettingsQueryVariables>;
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