if ((window as any).SCORPION_ENTRYPOINT != "app") {
  throw new Error("Edit scope code being required outside of edit code! Other bundles shouldn't include this stuff!");
}

export * from "./Page";
