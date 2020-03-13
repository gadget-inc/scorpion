import React from "react";
import { matchPath } from "react-router-dom";
import { isUndefined } from "lodash";
import useReactRouter from "use-react-router";
import classNames from "classnames";
import styles from "./NavigationBar.module.scss";

export const NavigationBarItem = (props: { label: string; path?: string; exact?: boolean }) => {
  const { history, location } = useReactRouter();
  let pathMatch;
  if (!isUndefined(props.path)) {
    pathMatch = !!matchPath(location.pathname, { exact: props.exact, path: props.path });
  } else {
    pathMatch = false;
  }

  const onClick = React.useCallback(
    (e: React.MouseEvent) => {
      if (!isUndefined(props.path)) {
        if (props.path && props.path.startsWith("http")) {
          window.location.href = props.path;
        } else {
          history.push(props.path as any);
        }
        e.preventDefault();
      }
    },
    [history, props.path]
  );

  return (
    <li role="presentation">
      <a
        href={props.path}
        className={classNames(styles.NavigationBarItem, pathMatch && styles["NavigationBarItem-active"])}
        onClick={onClick}
      >
        <span className={styles.Title}>{props.label}</span>
      </a>
    </li>
  );
};

export const NavigationBar = () => {
  return (
    <nav className={styles.NavigationBarContainer}>
      <ul role="tablist" className={styles.NavigationBar}>
        <NavigationBarItem path="/" exact label="Home" />
        <NavigationBarItem path="/settings" label="Settings" />
      </ul>
    </nav>
  );
};
