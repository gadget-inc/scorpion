import React from "react";
import { ScorpionFlags } from "superlib";

export interface SettingsBag {
  accountId: number;
  baseUrl: string;
  devMode: boolean;
  flags: ScorpionFlags;
  directUploadUrl: string;
  analytics: {
    identify: any;
    identifyTraits: any;
    group: any;
    groupTraits: any;
  };
  shopify: {
    apiKey: string;
    shopOrigin: string;
  };
  appDomain: string;
}

export const Settings: SettingsBag = (window as any).INJECTED_SETTINGS;
export const SettingsContext = React.createContext<SettingsBag>(Settings);
