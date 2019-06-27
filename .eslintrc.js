module.exports = {
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: __dirname + "/tsconfig.json"
  },
  plugins: ["@typescript-eslint", "react-hooks"],
  extends: ["plugin:@typescript-eslint/recommended", "prettier", "prettier/@typescript-eslint", "plugin:react/recommended"],
  rules: {
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/explicit-member-accessibility": "off",
    "@typescript-eslint/camelcase": "warn",
    "@typescript-eslint/no-explicit-any": "off",
    "@typescript-eslint/no-unused-vars": [
      "warn",
      {
        argsIgnorePattern: "^_"
      }
    ],
    "react/display-name": "off",
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn"
  },
  settings: {
    react: {
      version: "detect"
    }
  }
};
