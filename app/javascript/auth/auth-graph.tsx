// THIS IS A GENERATED FILE! You shouldn't edit it manually. Regenerate it using `yarn generate-graphql`.
import gql from 'graphql-tag';
import * as React from 'react';
import * as ApolloReactCommon from '@apollo/react-common';
import * as ApolloReactComponents from '@apollo/react-components';
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
   __typename?: 'Account',
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

export type AuthMutation = {
   __typename?: 'AuthMutation',
  createAccount?: Maybe<CreateAccountPayload>,
  discardAccount?: Maybe<DiscardAccountPayload>,
};


export type AuthMutationCreateAccountArgs = {
  account: AccountAttributes
};


export type AuthMutationDiscardAccountArgs = {
  id: Scalars['ID']
};

export type AuthQuery = {
   __typename?: 'AuthQuery',
  accounts: Array<Account>,
  discardedAccounts: Array<Account>,
};

export type BusinessLine = {
   __typename?: 'BusinessLine',
  id: Scalars['ID'],
  name: Scalars['String'],
};

export type CreateAccountPayload = {
   __typename?: 'CreateAccountPayload',
  account?: Maybe<Account>,
  errors?: Maybe<Array<MutationError>>,
};

export type DiscardAccountPayload = {
   __typename?: 'DiscardAccountPayload',
  account?: Maybe<Account>,
  errors?: Maybe<Array<MutationError>>,
};



export type MutationError = {
   __typename?: 'MutationError',
  field: Scalars['String'],
  fullMessage: Scalars['String'],
  message: Scalars['String'],
  mutationClientId?: Maybe<Scalars['MutationClientId']>,
  relativeField: Scalars['String'],
};

export type User = {
   __typename?: 'User',
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

export type AllAccountsQueryVariables = {};


export type AllAccountsQuery = (
  { __typename?: 'AuthQuery' }
  & { accounts: Array<(
    { __typename?: 'Account' }
    & Pick<Account, 'id' | 'name' | 'createdAt' | 'appUrl'>
    & { creator: (
      { __typename?: 'User' }
      & Pick<User, 'fullName'>
    ) }
  )> }
);

export type DiscardAccountMutationVariables = {
  id: Scalars['ID']
};


export type DiscardAccountMutation = (
  { __typename?: 'AuthMutation' }
  & { discardAccount: Maybe<(
    { __typename?: 'DiscardAccountPayload' }
    & { account: Maybe<(
      { __typename?: 'Account' }
      & Pick<Account, 'id' | 'name' | 'discarded'>
    )>, errors: Maybe<Array<(
      { __typename?: 'MutationError' }
      & Pick<MutationError, 'field' | 'message'>
    )>> }
  )> }
);

export type NewAccountMutationVariables = {
  account: AccountAttributes
};


export type NewAccountMutation = (
  { __typename?: 'AuthMutation' }
  & { createAccount: Maybe<(
    { __typename?: 'CreateAccountPayload' }
    & { account: Maybe<(
      { __typename?: 'Account' }
      & Pick<Account, 'id' | 'name' | 'appUrl'>
    )>, errors: Maybe<Array<(
      { __typename?: 'MutationError' }
      & Pick<MutationError, 'field' | 'relativeField' | 'message' | 'fullMessage' | 'mutationClientId'>
    )>> }
  )> }
);


export const AllAccountsDocument = gql`
    query AllAccounts {
  accounts {
    id
    name
    createdAt
    appUrl
    creator {
      fullName
    }
  }
}
    `;
export type AllAccountsComponentProps = Omit<ApolloReactComponents.QueryComponentOptions<AllAccountsQuery, AllAccountsQueryVariables>, 'query'>;

    export const AllAccountsComponent = (props: AllAccountsComponentProps) => (
      <ApolloReactComponents.Query<AllAccountsQuery, AllAccountsQueryVariables> query={AllAccountsDocument} {...props} />
    );
    
export type AllAccountsQueryResult = ApolloReactCommon.QueryResult<AllAccountsQuery, AllAccountsQueryVariables>;
export const DiscardAccountDocument = gql`
    mutation DiscardAccount($id: ID!) {
  discardAccount(id: $id) {
    account {
      id
      name
      discarded
    }
    errors {
      field
      message
    }
  }
}
    `;
export type DiscardAccountMutationFn = ApolloReactCommon.MutationFunction<DiscardAccountMutation, DiscardAccountMutationVariables>;
export type DiscardAccountComponentProps = Omit<ApolloReactComponents.MutationComponentOptions<DiscardAccountMutation, DiscardAccountMutationVariables>, 'mutation'>;

    export const DiscardAccountComponent = (props: DiscardAccountComponentProps) => (
      <ApolloReactComponents.Mutation<DiscardAccountMutation, DiscardAccountMutationVariables> mutation={DiscardAccountDocument} {...props} />
    );
    
export type DiscardAccountMutationResult = ApolloReactCommon.MutationResult<DiscardAccountMutation>;
export type DiscardAccountMutationOptions = ApolloReactCommon.BaseMutationOptions<DiscardAccountMutation, DiscardAccountMutationVariables>;
export const NewAccountDocument = gql`
    mutation NewAccount($account: AccountAttributes!) {
  createAccount(account: $account) {
    account {
      id
      name
      appUrl
    }
    errors {
      field
      relativeField
      message
      fullMessage
      mutationClientId
    }
  }
}
    `;
export type NewAccountMutationFn = ApolloReactCommon.MutationFunction<NewAccountMutation, NewAccountMutationVariables>;
export type NewAccountComponentProps = Omit<ApolloReactComponents.MutationComponentOptions<NewAccountMutation, NewAccountMutationVariables>, 'mutation'>;

    export const NewAccountComponent = (props: NewAccountComponentProps) => (
      <ApolloReactComponents.Mutation<NewAccountMutation, NewAccountMutationVariables> mutation={NewAccountDocument} {...props} />
    );
    
export type NewAccountMutationResult = ApolloReactCommon.MutationResult<NewAccountMutation>;
export type NewAccountMutationOptions = ApolloReactCommon.BaseMutationOptions<NewAccountMutation, NewAccountMutationVariables>;