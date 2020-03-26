import React from "react";
import { TextContainer, Heading } from "@shopify/polaris";
// import gql from "graphql-tag";
import styles from "./Timeline.module.scss";

const TimelineEntry = (_props: {}) => {
  return (
    <li className={styles.TimelineEntry}>
      <TextContainer>
        <Heading element="h3">Event</Heading>
      </TextContainer>
    </li>
  );
};

export const Timeline = (_props: {}) => {
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
