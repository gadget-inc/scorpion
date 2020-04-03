/** @jsx jsx */
import { useState, useCallback } from "react";
import { jsx } from "@emotion/core";
import { shouldRedirect, getWindow } from "@shopify/app-bridge/client/redirect";
import { DesktopMajorMonotone } from "@shopify/polaris-icons";
import { Popover, Button, ActionList } from "@shopify/polaris";
import { useAppBridge, embeddedEscapeRedirect } from "superlib";
import { Settings } from "app/lib/settings";

export const DevMenu = () => {
  const app = useAppBridge();
  const [popoverActive, setPopoverActive] = useState(false);
  const togglePopoverActive = useCallback(() => setPopoverActive((popoverActive) => !popoverActive), []);
  const fetchedWindow = getWindow();
  const currentlyEmbedded = fetchedWindow && !shouldRedirect(fetchedWindow.top);

  app.getState().then(console.log);
  return (
    <div
      css={{
        position: "fixed",
        right: "2em",
        bottom: "2em",
      }}
    >
      <Popover
        active={popoverActive}
        activator={<Button monochrome icon={DesktopMajorMonotone} onClick={togglePopoverActive} />}
        onClose={togglePopoverActive}
      >
        <ActionList
          items={[
            {
              content: "View embedded",
              disabled: currentlyEmbedded,
              onAction: () => {
                window.location.href = "https://" + Settings.shopify.shopOrigin + "/admin/apps/" + Settings.shopify.apiKey;
              },
            },
            {
              content: "Exit embedded frame",
              disabled: !currentlyEmbedded,
              onAction: () => {
                embeddedEscapeRedirect(app, Settings.appDomain + window?.location.pathname);
              },
            },
          ]}
        />
      </Popover>
    </div>
  );
};
