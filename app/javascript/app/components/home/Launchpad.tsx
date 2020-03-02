import React from "react";
import { Card } from "@shopify/polaris";
import { Page } from "../common";

export default class HomePage extends Page {
  render() {
    return (
      <Page.Layout title="Launchpad">
        <Card title="Online store dashboard" sectioned>
          <p>View a summary of your online store’s performance.</p>
        </Card>
      </Page.Layout>
    );
  }
}
