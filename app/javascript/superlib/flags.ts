import createFlags from "flag";
import { KeyPath } from "useful-types";

export interface ScorpionFlags {
  "gate.publicSignUps": boolean;
  "gate.productAccess": boolean;
  "feature.facebookAds": boolean;
  "feature.googleAds": boolean;
  "feature.googleAnalytics": boolean;
  "feature.klaviyo": boolean;
  "feature.bronto": boolean;
}

const { FlagsProvider, Flag, useFlag, useFlags } = createFlags<ScorpionFlags>();
export { FlagsProvider, Flag, useFlag, useFlags };
export type FlagKeyPath = KeyPath<ScorpionFlags>;
