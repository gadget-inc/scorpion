import React from "react";
import { Layout } from "@shopify/polaris";
import { Helmet } from "react-helmet";

export const PageLayout = (props: { title: string; children: React.ReactNode }) => {
  return (
    <Layout>
      <Helmet>
        <title>Scorpion - {props.title}</title>
      </Helmet>
      {props.children}
    </Layout>
  );
};

PageLayout.Section = Layout.Section;
