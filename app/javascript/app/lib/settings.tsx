import React from "react";
import { ScorpionFlags } from "superlib";

export interface SettingsBag {
  accountId: number;
  baseUrl: string;
  devMode: boolean;
  plaid: {
    publicKey: string;
    env: string;
    webhookUrl: string;
  };
  reportingCurrency: {
    id: string;
    isoCode: string;
    symbol: string;
    exponent: number;
  };
  flags: ScorpionFlags;
  directUploadUrl: string;
  analytics: {
    identify: any;
    identifyTraits: any;
    identifySegmentOpts: any;
    group: any;
    groupTraits: any;
  };
}

export const SettingsContext = React.createContext<SettingsBag>({} as SettingsBag);
export const Settings: SettingsBag = (window as any).INJECTED_SETTINGS;
