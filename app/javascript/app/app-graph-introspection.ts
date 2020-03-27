// THIS IS A GENERATED FILE! You shouldn't edit it manually. Regenerate it using yarn `generate-graphql`.


      export interface IntrospectionResultData {
        __schema: {
          types: {
            kind: string;
            name: string;
            possibleTypes: {
              name: string;
            }[];
          }[];
        };
      }
      const result: IntrospectionResultData = {
  "__schema": {
    "types": [
      {
        "kind": "UNION",
        "name": "FeedItemSubjectUnion",
        "possibleTypes": [
          {
            "name": "IssueChangeEvent"
          },
          {
            "name": "ProductionGroup"
          },
          {
            "name": "ShopifyAssetChangeFeedSubject"
          },
          {
            "name": "ShopifyDetectedAppChangeFeedSubject"
          },
          {
            "name": "ShopifyEventFeedSubject"
          },
          {
            "name": "ShopifyShopChangeFeedSubject"
          },
          {
            "name": "ShopifyThemeChangeFeedSubject"
          }
        ]
      }
    ]
  }
};
      export default result;
    