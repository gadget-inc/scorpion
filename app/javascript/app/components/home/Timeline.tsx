import React from "react";
import { Card, Icon, IconProps, TextContainer, Heading, Stack } from "@shopify/polaris";
import gql from "graphql-tag";
import styles from "./Timeline.module.scss";

const TimelineEntry = (props: {}) => {
  return (
    <li className={styles.TimelineEntry}>
      <TextContainer>
        <Heading element="h3">Event</Heading>
      </TextContainer>
    </li>
  );
};

export const Timeline = (props: {}) => {
  return (
    <div className={styles.TimelineContainer}>
      <TextContainer>
        <Heading>Recent Activity</Heading>
      </TextContainer>

      <ul className={styles.Timeline}>
        <TimelineEntry />
        <TimelineEntry />
        <TimelineEntry />
      </ul>
    </div>
  );
};
