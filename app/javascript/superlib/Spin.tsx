import React from "react";
import { Spinner, TextContainer, TextStyle } from "@shopify/polaris";

export const Spin = Spinner;

export const PageLoadSpin = () => (
  <div
    style={{
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      flexDirection: "column",
      width: "100%",
      minHeight: "20rem"
    }}
  >
    <Spin />
    <TextContainer>
      <TextStyle variation="subdued">Loading...</TextStyle>
    </TextContainer>
  </div>
);
