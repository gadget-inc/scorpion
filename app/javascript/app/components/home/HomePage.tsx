import React from "react";
import { Page } from "../common";
import { Card, DisplayText } from "@shopify/polaris";

export default class HomePage extends Page {
  render() {
    return (
      <Page.Layout title="Home" primaryAction={{ content: "Scan now" }}>
        <Page.Layout.Section>
          <DisplayText>Good day.</DisplayText>
        </Page.Layout.Section>
        <Page.Layout.Section>
          <Card sectioned>
            <p>Still some work to do here eh</p>
          </Card>
        </Page.Layout.Section>
      </Page.Layout>
    );
  }
}
