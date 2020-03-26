import * as React from "react";
import { Page } from "../common";
import { Card } from "@shopify/polaris";

export class NotFoundPage extends Page {
  public render() {
    return (
      <Page.Layout title="Page not found">
        <Page.Layout.Section>
          <Card title="Page not found" sectioned>
            <p>Sorry about</p>
          </Card>
        </Page.Layout.Section>
      </Page.Layout>
    );
  }
}
