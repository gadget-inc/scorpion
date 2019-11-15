module.exports = {
  client: {
    service: {
      name: "scorpion",
      localSchemaFile: "./tmp/app-schema.graphql"
    },
    includes: ["./app/javascript/app/**/*.{ts,tsx}"]
  }
};
