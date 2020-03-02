// THIS IS A GENERATED FILE! You shouldn't edit it manually. Regenerate it using `yarn generate-graphql`.
import gql from 'graphql-tag';
import * as ApolloReactCommon from '@apollo/react-common';
import * as React from 'react';
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