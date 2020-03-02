import createFlags from "flag";
import { KeyPath } from "useful-types";

export interface ScorpionFlags {
  "gate.publicSignUps": boolean;
}

const { FlagsProvider, Flag, useFlag, useFlags } = createFlags<ScorpionFlags>();
export { FlagsProvider, Flag, useFlag, useFlags };
export type FlagKeyPath = KeyPath<ScorpionFlags>;
