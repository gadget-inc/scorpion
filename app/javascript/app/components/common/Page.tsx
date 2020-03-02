import React from "react";
import { RouteComponentProps } from "react-router";
import { PageLoad } from "./PageLoad";
import { PageLayout } from "./PageLayout";

export class Page<Params = {}, S = {}> extends React.Component<RouteComponentProps<Params>, S> {
  static Load = PageLoad;
  static Layout = PageLayout;
}
