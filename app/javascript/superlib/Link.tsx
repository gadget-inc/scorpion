import React from "react";
import useReactRouter from "use-react-router";
import { Link as PolarisLink, LinkProps } from "@shopify/polaris";
import { omit } from "lodash";

export const Link = (props: LinkProps) => {
  const { history } = useReactRouter();
  const { url, onClick } = props;
  const handler = React.useCallback(() => {
    if (url) {
      history.push(url);
    } else if (onClick) {
      onClick();
    }
  }, [url, onClick, history]);

  return <PolarisLink onClick={handler} {...omit(props, ["url"])} />;
};
