import React from "react";
import { Page } from "../common";
import { Card, DisplayText } from "@shopify/polaris";
import { OverallStatusCard } from "./OverallStatusCard";
import { Timeline } from "../timeline/Timeline";

export default class HomePage extends Page {
  render() {
    return (
      <Page.Layout title="Home">
        <Page.Layout.Section>
          <DisplayText>Good day.</DisplayText>
        </Page.Layout.Section>
        <Page.Layout.Section>
          <OverallStatusCard />
          <Timeline />
        </Page.Layout.Section>
        <Page.Layout.Section secondary>
          <Card sectioned></Card>
        </Page.Layout.Section>
      </Page.Layout>
    );
  }
}
