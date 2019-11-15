import { ScorpionFlags } from "superlib";

export interface SettingsBag {
  baseUrl: string;
  signedIn: boolean;
  devMode: boolean;
  flags: ScorpionFlags;
}

export const Settings: SettingsBag = (window as any).INJECTED_SETTINGS;
