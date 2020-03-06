import React from "react";
import { Layout, Page } from "@shopify/polaris";
import { Helmet } from "react-helmet";
import { TitleBar } from "@shopify/app-bridge-react";
import { PropsType } from "superlib";
import { omit } from "lodash";
import { Settings } from "app/lib/settings";
import { DevMenu } from "./DevMenu";

type TitleBarProps = PropsType<typeof TitleBar>;

export const PageLayout = (props: { title: string; children: React.ReactNode } & TitleBarProps) => {
  return (
    <Page>
      <Helmet>
        <title>Scorpion - {props.title}</title>
      </Helmet>
      <TitleBar {...omit(props, ["children"])} />
      <Layout>{props.children}</Layout>
      {Settings.devMode && <DevMenu />}
    </Page>
  );
};

PageLayout.Section = Layout.Section;
